﻿using System;
using System.Linq;
using System.Runtime.InteropServices;
using Microsoft.VisualStudio.OLE.Interop;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Text.Editor;
using Microsoft.VisualStudio.Utilities;
using System.ComponentModel.Composition;
using Microsoft.VisualStudio.Language.Intellisense;
using Microsoft.VisualStudio.TextManager.Interop;
using Microsoft.VisualStudio.Text;
using XSharpModel;
using Microsoft.VisualStudio.Editor;
using Microsoft.VisualStudio.Text.Tagging;
#pragma warning disable CS0649 // Field is never assigned to, for the imported fields

namespace XSharp.LanguageService
{
    [Export(typeof(IVsTextViewCreationListener))]
    [Name("XSharp Completion Provider")]
    [TextViewRole(PredefinedTextViewRoles.Editable)]
    [ContentType(XSharpConstants.LanguageName)]
    internal class XSharpCompletionProvider : IVsTextViewCreationListener
    {

        [Import]
        internal IVsEditorAdaptersFactoryService AdapterService;

        [Import]
        internal ICompletionBroker CompletionBroker { get; set; }

         [Import]
        internal IBufferTagAggregatorFactoryService BufferTagAggregatorFactoryService { get; set; }
        public void VsTextViewCreated(IVsTextView textViewAdapter)
        {
            if (XSettings.DisableCodeCompletion)
                return;
            ITextView textView = AdapterService.GetWpfTextView(textViewAdapter);
            if (textView == null)
                return;
            textView.Properties.GetOrCreateSingletonProperty(
                 () => new XSharpCompletionCommandHandler(textViewAdapter,
                    textView,
                    CompletionBroker,
                    BufferTagAggregatorFactoryService
                    ));
        }
    }
    internal class XSharpCompletionCommandHandler : IOleCommandTarget
    {
        readonly ITextView _textView;
        readonly ICompletionBroker _completionBroker;
        private ICompletionSession _completionSession;
        readonly IOleCommandTarget m_nextCommandHandler;
        readonly IBufferTagAggregatorFactoryService _aggregator;
        bool completionWasSelected = false;
        CompletionSelectionStatus completionWas;

        internal XSharpCompletionCommandHandler(IVsTextView textViewAdapter, ITextView textView,
            ICompletionBroker completionBroker, IBufferTagAggregatorFactoryService aggregator)
        {
            this._textView = textView;
            this._completionBroker = completionBroker;
            this._completionSession = null;
            this._aggregator = aggregator;
            //add this to the filter chain
            textViewAdapter.AddCommandFilter(this, out m_nextCommandHandler);
        }


        public int Exec(ref Guid pguidCmdGroup, uint nCmdID, uint nCmdexecopt, IntPtr pvaIn, IntPtr pvaOut)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            int result = VSConstants.S_OK;
            bool handled = false;
            Guid cmdGroup = pguidCmdGroup;
            // 1. Pre-process
            if (XSettings.DisableCodeCompletion)
            {
                ;
            }
            else if (pguidCmdGroup == VSConstants.VSStd2K )
            {
                switch ((VSConstants.VSStd2KCmdID)nCmdID)
                {
                    case VSConstants.VSStd2KCmdID.COMPLETEWORD:
                    case VSConstants.VSStd2KCmdID.AUTOCOMPLETE:
                    case VSConstants.VSStd2KCmdID.SHOWMEMBERLIST:
                        // in this case we WANT to include keywords in the list
                        // when they type LOCA we want to include LOCAL as well
                        handled = StartCompletionSession(nCmdID, '\0', true);
                        break;
                    case VSConstants.VSStd2KCmdID.RETURN:
                        handled = CompleteCompletionSession();
                        break;
                    case VSConstants.VSStd2KCmdID.TAB:
                        handled = CompleteCompletionSession( );
                        break;
                    case VSConstants.VSStd2KCmdID.CANCEL:
                        handled = CancelCompletionSession();
                        break;
                    case VSConstants.VSStd2KCmdID.TYPECHAR:
                        char ch = GetTypeChar(pvaIn);
                        if (_completionSession != null)
                        {
                            if (char.IsLetterOrDigit(ch) || ch == '_')
                                FilterCompletionSession(ch);
                            else
                            {
                                if (completionWasSelected && (XSettings.EditorCommitChars.Contains(ch)))
                                {
                                    CompleteCompletionSession( true, ch);
                                }
                                else
                                {
                                    CancelCompletionSession();
                                }
                                if ((ch == ':') || (ch == '.'))
                                {
                                    StartCompletionSession(nCmdID, ch);
                                }
                            }
                            //
                        }
                        break;
                    default:
                        break;
                }
            }
            else if (pguidCmdGroup == VSConstants.GUID_VSStandardCommandSet97)
            {
                switch ((VSConstants.VSStd97CmdID)nCmdID)
                {
                    case VSConstants.VSStd97CmdID.Undo:
                    case VSConstants.VSStd97CmdID.Redo:
                        CancelCompletionSession();
                        break;

                    default:
                        break;
                }
            }
            // 2. Let others do their thing
            // Let others do their thing
            if (!handled)
            {
                if (_completionSession != null)
                {
                    if (_completionSession.SelectedCompletionSet != null)
                    {
                        completionWasSelected = _completionSession.SelectedCompletionSet.SelectionStatus.IsSelected;
                        if (completionWasSelected)
                        {
                            completionWas = _completionSession.SelectedCompletionSet.SelectionStatus;
                        }
                        else
                            completionWas = null;
                    }
                }
                result = m_nextCommandHandler.Exec(ref cmdGroup, nCmdID, nCmdexecopt, pvaIn, pvaOut);
            }           // 3. Post process
            if (ErrorHandler.Succeeded(result) && ! XSettings.DisableCodeCompletion)
            {
                if (pguidCmdGroup == VSConstants.VSStd2K)
                {

                    switch ((VSConstants.VSStd2KCmdID)nCmdID)
                    {
                        case VSConstants.VSStd2KCmdID.BACKSPACE:
                            FilterCompletionSession('\0');
                            break;

                        case VSConstants.VSStd2KCmdID.TYPECHAR:
                            char ch = GetTypeChar(pvaIn);
                            if (_completionSession == null)
                            {
                                switch (ch)
                                {
                                    case ':':
                                    case '.':
                                        StartCompletionSession(nCmdID, ch);
                                        break;
                                    default:
                                        completeCurrentToken(nCmdID, ch);
                                        break;
                                }
                            }
                            break;
                        default:
                            break;

                    }
                }
            }
            
            return result;
        }
        private void completeCurrentToken(uint nCmdID, char ch)
        {
            if (!XSettings.EditorCompletionListAfterEachChar)
                return;
            SnapshotPoint caret = _textView.Caret.Position.BufferPosition;
            if (cursorIsInStringorComment(caret))
            {
                return;
            }
            if (char.IsLetterOrDigit(ch) || ch == '_')
            {
                var line = caret.GetContainingLine();

                var lineText = line.GetText();
                var pos = caret.Position - line.Start.Position;
                int chars = 0;
                bool done = false;
                // count the number of characters in the current word. When > 2 then trigger completion
                for (int i = pos - 1; i >= 0; i--)
                {
                    switch (lineText[i])
                    {
                        case ' ':
                        case '\t':
                            done = true;
                            break;
                    }
                    if (done)
                        break;
                    chars++;
                    if (chars > 2)
                        break;
                }
                if (chars > 2)
                {
                    StartCompletionSession(nCmdID, '\0', true);
                }
            }
        }

        private void FilterCompletionSession(char ch)
        {

            WriteOutputMessage("FilterCompletionSession()");
            if (_completionSession == null)
                return;

            WriteOutputMessage(" --> in Filter");
            if (_completionSession.SelectedCompletionSet != null)
            {
                WriteOutputMessage(" --> Filtering ?");
                _completionSession.SelectedCompletionSet.Filter();
                if (_completionSession.SelectedCompletionSet.Completions.Count == 0)
                {
                    CancelCompletionSession();
                }
                else
                {
                    WriteOutputMessage(" --> Selecting ");
                    _completionSession.SelectedCompletionSet.SelectBestMatch();
                    _completionSession.SelectedCompletionSet.Recalculate();
                }
            }

        }


        bool CancelCompletionSession()
        {
            SetActive(false);
            if (_completionSession == null)
            {
                return false;
            }
            _completionSession.Dismiss();
            return true;
        }

        bool CompleteCompletionSession(bool force = false, char ch = ' ')
        {
            bool showParameterTips = false;
            SetActive(false);
            if (_completionSession == null)
            {
                return false;
            }
            bool commit = false;
            bool moveBack = false;
            Completion completion = null;
            XSCompletion xscompletion = null;
            ITextCaret caret = null;
            WriteOutputMessage("CompleteCompletionSession()");
            if (_completionSession.SelectedCompletionSet != null)
            {
                //if (completionWas != null)
                //{
                //    _completionSession.SelectedCompletionSet.SelectionStatus = completionWas;
                //}
                
                if (_completionSession.SelectedCompletionSet.SelectionStatus.Completion != null)
                {
                    completion = _completionSession.SelectedCompletionSet.SelectionStatus.Completion;
                }
                xscompletion = completion as XSCompletion;
                Kind kind = Kind.Unknown;
                if (xscompletion != null)
                {
                    kind = xscompletion.Kind;
                }
                if (kind == Kind.Keyword)
                {
                    formatKeyword(completion);
                }
                showParameterTips = kind.HasParameters();
                if ((_completionSession.SelectedCompletionSet.Completions.Count > 0) && (_completionSession.SelectedCompletionSet.SelectionStatus.IsSelected))
                {

                    if (XSettings.EditorCompletionAutoPairs)
                    {
                        caret = _completionSession.TextView.Caret;
                        WriteOutputMessage(" --> select " + completion.InsertionText);
                        if (completion.InsertionText.EndsWith("("))
                        {
                            moveBack = true;
                            completion.InsertionText += ")";
                        }
                        else if (completion.InsertionText.EndsWith("{"))
                        {
                            moveBack = true;
                            completion.InsertionText += "}";
                        }
                        else if (completion.InsertionText.EndsWith("["))
                        {
                            moveBack = true;
                            completion.InsertionText += "]";
                        }
                        else
                        {
                            if (kind == Kind.Constructor)
                            {
                                moveBack = true;
                                completion.InsertionText += "{}";
                                showParameterTips = true;
                            }
                            if (kind.HasParameters())
                            {
                                moveBack = true;
                                completion.InsertionText += "()";
                                showParameterTips = true;
                            }
                        }
                    }
                    commit = true;
                }
                else if (force)
                {
                    if (completion != null)
                    {
                        // Push the completion char into the InsertionText if needed
                        if (!completion.InsertionText.EndsWith(ch.ToString()))
                        {
                            completion.InsertionText += ch;
                        }
                        if (XSettings.EditorCompletionAutoPairs)
                        {
                            caret = _completionSession.TextView.Caret;
                            if (ch == '(')
                            {
                                completion.InsertionText += ')';
                                moveBack = true;
                            }
                            else if (ch == '{')
                            {
                                completion.InsertionText += '}';
                                moveBack = true;
                            }
                            else if (ch == '[')
                            {
                                completion.InsertionText += ']';
                                moveBack = true;
                            }
                        }
                    }
                    commit = true;
                }
            }
            if (commit)
            {
                WriteOutputMessage(" --> Commit");
                _completionSession.Commit();
                if (moveBack && (caret != null))
                {
                    caret.MoveToPreviousCaretPosition();
                }
                if (showParameterTips && xscompletion != null)
                {
                    // send command to editor to Signature Helper
                    var sigHelper = _textView.Properties.GetProperty<XSharpSignatureHelpCommandHandler>(typeof(XSharpSignatureHelpCommandHandler));
                    if (sigHelper != null)
                    {
                        sigHelper.StartSignatureSession(false, null, xscompletion.Value);
                    }
                }
                return true;
            }

            WriteOutputMessage(" --> Dismiss");
            _completionSession.Dismiss();


            return false;
        }
        bool StartCompletionSession(uint nCmdId, char typedChar, bool includeKeywords = false)
        {
            WriteOutputMessage("StartCompletionSession()");

            if (_completionSession != null)
            {
                if (!_completionSession.IsDismissed)
                    return false;
            }
            SnapshotPoint caret = _textView.Caret.Position.BufferPosition;
            if (cursorIsAfterSLComment(caret))
                return false;

            ITextSnapshot snapshot = caret.Snapshot;

            if (!_completionBroker.IsCompletionActive(_textView))
            {
                _completionSession = _completionBroker.CreateCompletionSession(_textView, snapshot.CreateTrackingPoint(caret, PointTrackingMode.Positive), true);
            }
            else
            {
                _completionSession = _completionBroker.GetSessions(_textView)[0];
            }

            _completionSession.Dismissed += OnCompletionSessionDismiss;
            _completionSession.Committed += OnCompletionSessionCommitted;
            _completionSession.SelectedCompletionSetChanged += _completionSession_SelectedCompletionSetChanged;

            _completionSession.Properties[XsCompletionProperties.Command] = nCmdId;
            _completionSession.Properties[XsCompletionProperties.Char] = typedChar;
            _completionSession.Properties[XsCompletionProperties.Type] = null;
            _completionSession.Properties[XsCompletionProperties.IncludeKeywords] = includeKeywords;
            SetActive(true);
            try
            {
                _completionSession.Start();
            }
            catch (Exception e)
            {
                WriteOutputMessage("Start Completion failed");
                XSettings.DisplayException(e);
            }
            return true;
        }

        private void _completionSession_SelectedCompletionSetChanged(object sender, ValueChangedEventArgs<CompletionSet> e)
        {
            if (e.NewValue.SelectionStatus.IsSelected == false)
            {
                ;
            }
        }
        private void SetActive(bool set)
        {
            if (_textView.Properties.ContainsProperty("XCompletionSession"))
            {
                if (!set)
                    _textView.Properties.RemoveProperty("XCompletionSession");
            }
            else if (set)
                _textView.Properties.AddProperty("XCompletionSession",1);

        }

        private void OnCompletionSessionCommitted(object sender, EventArgs e)
        {
            // it MUST be the case....
            WriteOutputMessage("OnCompletionSessionCommitted()");

            if (_completionSession.SelectedCompletionSet.SelectionStatus.Completion != null)
            {
                if (_completionSession.SelectedCompletionSet.SelectionStatus.Completion.InsertionText.EndsWith("("))
                {
                    _completionSession.Properties.TryGetProperty(XsCompletionProperties.Type, out IXTypeSymbol type);
                    string method = _completionSession.SelectedCompletionSet.SelectionStatus.Completion.InsertionText;
                    _completionSession.Properties.TryGetProperty(XsCompletionProperties.Char, out char triggerChar);
                    method = method.Substring(0, method.Length - 1);
                    _completionSession.Dismiss();
                    

                    //StartSignatureSession(false, type, method, triggerChar);
                }
            }
            //
        }

        private void OnCompletionSessionDismiss(object sender, EventArgs e)
        {
            if (_completionSession.SelectedCompletionSet != null)
            {
                _completionSession.SelectedCompletionSet.Filter();
            }
            //
            _completionSession.Dismissed -= OnCompletionSessionDismiss;
            _completionSession.Committed -= OnCompletionSessionCommitted;
            _completionSession.SelectedCompletionSetChanged -= _completionSession_SelectedCompletionSetChanged;
            _completionSession = null;
        }

        public int QueryStatus(ref Guid pguidCmdGroup, uint cCmds, OLECMD[] prgCmds, IntPtr pCmdText)
        {
            Microsoft.VisualStudio.Shell.ThreadHelper.ThrowIfNotOnUIThread();
            return m_nextCommandHandler.QueryStatus(ref pguidCmdGroup, cCmds, prgCmds, pCmdText);
        }
        internal void WriteOutputMessage(string strMessage)
        {
            if (XSettings.EnableCodeCompletionLog && XSettings.EnableLogging)
            {
                XSettings.DisplayOutputMessage("XSharp.Completion:"+ strMessage);
            }
        }
        private char GetTypeChar(IntPtr pvaIn)
        {
            return (char)(ushort)Marshal.GetObjectForNativeVariant(pvaIn);
        }
        private bool cursorIsInStringorComment(SnapshotPoint caret)
        {
            var classification = getClassification(caret);
            return IsCommentOrString(classification);
        }
        private bool cursorIsAfterSLComment(SnapshotPoint caret)
        {

            var classification = getClassification(caret);
            return classification != null && classification.ToLower() == "comment";
        }
        void formatKeyword(Completion completion)
        {
            completion.InsertionText = XSettings.FormatKeyword(completion.InsertionText);
        }

        private string getClassification(SnapshotPoint caret)
        {
            var line = caret.GetContainingLine();
            SnapshotSpan lineSpan = new SnapshotSpan(line.Start, caret.Position - line.Start);
            var tagAggregator = _aggregator.CreateTagAggregator<IClassificationTag>(_textView.TextBuffer);
            var tags = tagAggregator.GetTags(lineSpan);
            var tag = tags.LastOrDefault();
            return tag?.Tag?.ClassificationType?.Classification;
        }
        private bool IsCommentOrString(string classification)
        {
            if (string.IsNullOrEmpty(classification))
                return false;
            switch (classification.ToLower())
            {
                case "comment":
                case "string":
                case "xsharp.text":
                    return true;
            }
            return false;
        }
    }
}
