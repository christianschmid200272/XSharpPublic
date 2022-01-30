﻿using Microsoft.VisualStudio.Language.Intellisense;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.VisualStudio.Imaging.Interop;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using Microsoft.VisualStudio.Text;
using System.Threading;
using XSharpModel;
using System.Reflection;
using Microsoft.VisualStudio.Text.Editor;
using XSharp.LanguageService;
using System.Collections.Immutable;
using Microsoft.VisualStudio.Text.Adornments;
using System.Text;
using System.Linq;
using XSharp.LanguageService.LightBulb;

namespace XSharp.Project.Editors.LightBulb
{
    internal class ConstructorSuggestedAction : ISuggestedAction
    {
        private readonly ITextSnapshot m_snapshot;

        public ConstructorSuggestedAction(ITextSnapshot snapshot)
        {
            m_snapshot = snapshot;
        }

        private readonly ITextView m_textView;
        private readonly XSharpModel.TextRange _range;
        private ITextBuffer _textBuffer;
        private IXTypeSymbol _classEntity;
        private List<IXMemberSymbol> _fieldsNProps;
        private List<string> _existingCtor;

        public ConstructorSuggestedAction(ITextView textView, ITextBuffer textBuffer, IXTypeSymbol classEntity, XSharpModel.TextRange range, List<IXMemberSymbol> members)
        {
            this.m_textView = textView;
            this.m_snapshot = this.m_textView.TextSnapshot;
            this._textBuffer = textBuffer;
            this._classEntity = classEntity;
            this._range = range;
            this._fieldsNProps = members;
        }

        public ConstructorSuggestedAction(ITextView textView, ITextBuffer textBuffer, IXTypeSymbol classEntity, XSharpModel.TextRange range, List<IXMemberSymbol> members, List<string> existingCtor) :
            this(textView, textBuffer, classEntity, range, members)
        {
            this._existingCtor = existingCtor;
        }

        public Task<object> GetPreviewAsync(CancellationToken cancellationToken)
        {
            try
            {
                // Show preview only for default Constructor
                if (_fieldsNProps == null)
                {
                    List<Inline> content = new List<Inline>();
                    //
                    foreach (string desc in CreateCtor("", 0))
                    {
                        Run temp = new Run(desc + Environment.NewLine);
                        content.Add(temp);
                    }
                    // Create a "simple" list... Would be cool to have Colors...
                    var textBlock = new TextBlock
                    {
                        Padding = new Thickness(5)
                    };
                    textBlock.Inlines.AddRange(content);
                    return Task.FromResult<object>(textBlock);
                }
            }
            catch (Exception e)
            {
                WriteOutputMessage(e.Message);
            }
            return Task.FromResult<object>(null);
        }

        public Task<IEnumerable<SuggestedActionSet>> GetActionSetsAsync(CancellationToken cancellationToken)
        {
            return Task.FromResult<IEnumerable<SuggestedActionSet>>(null);
        }

        public bool HasActionSets
        {
            get { return false; }
        }
        public string DisplayText
        {
            get
            {
                if (_fieldsNProps == null)
                    return "Generate default constructor";

                return "Generate constructor...";
            }
        }


        public ImageMoniker IconMoniker
        {
            get { return default; }
        }
        public string IconAutomationText
        {
            get
            {
                return null;
            }
        }
        public string InputGestureText
        {
            get
            {
                return null;
            }
        }
        public bool HasPreview
        {
            get { return true; }
        }

        public void Dispose()
        {
        }

        public bool TryGetTelemetryId(out Guid telemetryId)
        {
            // This is a sample action and doesn't participate in LightBulb telemetry
            telemetryId = Guid.Empty;
            return false;
        }

        // The job is done here !!
        public void Invoke(CancellationToken cancellationToken)
        {
            try
            {
                var settings = m_textView.TextBuffer.Properties.GetProperty<SourceCodeEditorSettings>(typeof(SourceCodeEditorSettings));
                //m_span.TextBuffer.Replace(m_span.GetSpan(m_snapshot), ");
                StringBuilder insertText;
                // Last line of the Entity
                int lineNumber = Math.Min(_range.EndLine, m_snapshot.LineCount - 1);
                ITextSnapshotLine lastLine = m_snapshot.GetLineFromLineNumber(lineNumber);
                // Retrieve the text
                string lineText = lastLine.GetText();
                // and count how many spaces we have before
                int count = lineText.TakeWhile(Char.IsWhiteSpace).Count();
                // Get these as prefix
                string prefix = lineText.Substring(0, count);
                List<Inline> content = new List<Inline>();
                // Add a comment  ??
                insertText = new StringBuilder();
                // Create an Edit Session
                var editSession = m_textView.TextBuffer.CreateEdit();
                try
                {
                    foreach (string line in CreateCtor(prefix, settings.IndentSize))
                    {
                        insertText.AppendLine(line);
                    }
                    // Inject code
                    editSession.Insert(lastLine.Start.Position, insertText.ToString());
                }
                catch (Exception e)
                {
                    WriteOutputMessage("editSession : error " + e.Message);
                }
                finally
                {
                    // Validate the Edit Session ?
                    if (editSession.HasEffectiveChanges)
                    {
                        editSession.Apply();

                    }
                    else
                    {
                        editSession.Cancel();
                    }
                    //
                }
            }
            catch (Exception e)
            {
                WriteOutputMessage(e.Message);
            }
        }

        private List<String> CreateCtor(string prefix, int indentSize)
        {
            List<String> result = new List<string>();
            try
            {
                String indent = new string(' ', indentSize);
                //
                StringBuilder insertText = new StringBuilder();
                
                //
                if (_fieldsNProps == null)
                {
                    insertText.Append(prefix);
                    insertText.Append("PUBLIC ");
                    insertText.Append("CONSTRUCTOR()");
                    result.Add(insertText.ToString());
                    insertText.Clear();
                    insertText.Append(prefix);
                    insertText.Append(indent);
                    insertText.Append("RETURN");
                    insertText.AppendLine();
                    result.Add(insertText.ToString());
                }
                else
                {
                    CtorParamsDlg dlg = new CtorParamsDlg();
                    dlg.FillMembers(_fieldsNProps);
                    if ( dlg.ShowDialog() == System.Windows.Forms.DialogResult.OK )
                    {
                        insertText.Append(prefix);
                        insertText.Append("PUBLIC ");
                        insertText.Append("CONSTRUCTOR(");
                        //
                        StringBuilder insertCode = new StringBuilder();
                        string ctorDef = "";
                        int max = dlg.FieldsNProps.Count;
                        foreach ( var mbr in dlg.FieldsNProps)
                        {
                            insertText.Append(" ");
                            string paramDef = mbr.Prototype.Trim( new char[] { '_' });
                            string paramName = paramDef.Substring(0,paramDef.IndexOf(' '));
                            insertText.Append(paramDef);
                            max--;
                            if ( max > 0)
                                insertText.Append(",");
                            //
                            insertCode.Append(prefix);
                            insertCode.Append(indent);
                            insertCode.Append("SELF:");
                            insertCode.Append(mbr.Name);
                            insertCode.Append(" := ");
                            insertCode.AppendLine(paramName);
                            //
                            ctorDef += mbr.TypeName;
                            if (max > 0)
                                ctorDef += ",";
                        }
                        // Does this Constructor already exist ?
                        if ( _existingCtor.FindIndex(x => string.Compare(x, ctorDef, true) == 0) == -1 )
                        {
                            //
                            insertText.Append(" )");
                            result.Add(insertText.ToString());
                            insertText.Clear();
                            //
                            insertText.Append(insertCode.ToString());
                            //
                            insertText.Append(prefix);
                            insertText.Append(indent);
                            insertText.Append("RETURN");
                            insertText.AppendLine();
                            result.Add(insertText.ToString());
                        }
                    }
                }
            }
            catch (Exception e)
            {
                WriteOutputMessage(e.Message);
            }
            //
            //result.Add(insertText.ToString());
            return result;
        }

        internal void WriteOutputMessage(string strMessage)
        {
            if (XSettings.EnableParameterLog && XSettings.EnableLogging)
            {
                XSettings.LogMessage("ConstructorSuggestedAction:" + strMessage);
            }
        }


    }






}
