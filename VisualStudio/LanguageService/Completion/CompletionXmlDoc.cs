﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
//------------------------------------------------------------------------------

using System;
using System.Linq;
using Microsoft.VisualStudio.OLE.Interop;
using Microsoft.VisualStudio.Text.Editor;
using Microsoft.VisualStudio.Utilities;
using System.ComponentModel.Composition;
using Microsoft.VisualStudio.Text;
using XSharpModel;
using Microsoft.VisualStudio.Editor;
using System.Collections.Generic;
using System.Text;
namespace XSharp.LanguageService
{
    [Export(typeof(IVsTextViewCreationListener))]
    [Name("XSharp Completion Provider")]
    [TextViewRole(PredefinedTextViewRoles.Editable)]
    [ContentType(XSharpConstants.LanguageName)]
    internal partial class XSharpCompletionCommandHandler : IOleCommandTarget
    {
        /// <summary>
        /// Push XMLDoc /// after a return char if we are just after an existing line with XMLDoc
        /// </summary>
        private void InjectXMLDoc()
        {
            try
            {
                // Retrieve Position
                SnapshotPoint caret = _textView.Caret.Position.BufferPosition;
                var line = caret.GetContainingLine();
                if ((line.LineNumber >= _textView.TextSnapshot.LineCount - 1) || (line.LineNumber == 0))
                    return;
                // Do not classify here. Not really needed yet
                ITextSnapshotLine lineUp = _textView.TextSnapshot.GetLineFromLineNumber(line.LineNumber - 1);
                ITextSnapshotLine lineDown = _textView.TextSnapshot.GetLineFromLineNumber(line.LineNumber + 1);
                string prevLine = lineUp.GetText();
                string nextLine = lineDown.GetText().Trim();
                var afterADocComment = prevLine.Trim().StartsWith("///");
                var beforeDocComment = nextLine.StartsWith("///") || String.IsNullOrEmpty(nextLine);
                // Ok, check the content
                if (afterADocComment && beforeDocComment)
                {
                    // Get the line
                    // To retrieve the text and align to it
                    int count = prevLine.TakeWhile(Char.IsWhiteSpace).Count();
                    string prefix;
                    if (prevLine.Length >= count + 4)
                        prefix = prevLine.Substring(0, count + 4); // copy starting whitespace + /// + separator
                    else
                        prefix = prevLine + " ";
                    _textView.TextBuffer.Insert(caret.Position, prefix);
                    // Move the Caret
                    _textView.Caret.MoveTo(new SnapshotPoint(_textView.TextSnapshot, caret.Position + prefix.Length));
                }
            }
            catch (Exception e)
            {
                WriteOutputMessage("InjectXMLDoc: error " + e.Message);
            }
        }
        /// <summary>
        /// Insert XMLDoc Comments
        /// </summary>
        private void InsertXMLDoc()
        {
            try
            {
                // Retrieve Position
                SnapshotPoint caret = _textView.Caret.Position.BufferPosition;
                var line = caret.GetContainingLine();
                if (line.LineNumber >= _textView.TextSnapshot.LineCount - 1)
                    return;
                string lineText = line.GetText();
                // Remove all type of spaces
                lineText = lineText.Trim(' ', '\t');
                // XMLDoc ?
                if (lineText == "///")
                {
                    // Check next && previous Line . No need to classify here. We'll do that later
                    // when we're not next to a comment
                    var lineDown = _textView.TextSnapshot.GetLineFromLineNumber(line.LineNumber + 1);
                    var nextToAComment = lineDown.GetText().Trim().StartsWith("///");
                    if (!nextToAComment && line.LineNumber > 0)
                    {
                        var lineUp = _textView.TextSnapshot.GetLineFromLineNumber(line.LineNumber - 1);
                        nextToAComment = lineUp.GetText().Trim().StartsWith("///");

                    }
                    if (!nextToAComment)
                    {
                        // force buffer to be classified to see if we are on a line before a comment
                        var classifier = _textView.TextBuffer.GetClassifier();
                        _ = classifier.ClassifyWhenNeededAsync();
                        var doc = _textView.TextBuffer.GetDocument();
                        if (doc == null)
                            return;
                        // Make sure that the entity list matches the contents of the buffer
                        // Parse the entities
                        classifier.Parse();
                        var entity = _textView.FindEntity(lineDown.Start);
                        if (entity != null && entity.Range.StartLine >= line.LineNumber)
                        {
                            // Default information
                            // Retrieve the original line, and keep the prefix
                            lineText = line.GetText().TrimEnd();
                            string prefix = lineText.Remove(lineText.Length - 3, 3);
                            // Insert XMLDoc template
                            var sb = new StringBuilder();
                            sb.AppendLine($" <summary>\r\n{prefix}/// \r\n{prefix}/// </summary>");
                            var member = entity as XSourceMemberSymbol;
                            var type = entity as XSourceTypeSymbol;
                            if (type != null && type.Kind == Kind.Delegate)
                            {
                                // delegate have a generated Invoke method with the parameters and return type
                                member = type.Members.First() as XSourceMemberSymbol;
                            }
                            IList<string> typeParameters = null;
                            if (member != null)
                            {
                                typeParameters = member.TypeParameters;
                                // Now fill with retrieved information
                                foreach (var param in member.Parameters)
                                {
                                    sb.AppendLine(prefix + $"/// <param name=\"{param.Name}\"></param>");
                                }
                                if (member.Kind.IsProperty())
                                {
                                    sb.AppendLine(prefix + "/// <value></value>");
                                }
                                else if (member.Kind.HasReturnType() && !member.Kind.IsField())
                                {
                                    if ((string.Compare(member.ReturnType, "void", true) != 0))
                                    {
                                        sb.AppendLine(prefix + "/// <returns></returns>");
                                    }
                                }
                            }
                            if (type != null)
                            {
                                typeParameters = type.TypeParameters;
                            }
                            if (typeParameters != null)
                            {
                                foreach (var typeparam in typeParameters)
                                {
                                    sb.AppendLine(prefix + $"/// <typeparam name=\"{typeparam}\"></typeparam>");
                                }
                            }
                            // remove last CRLF from sb
                            if (sb.Length > 2)
                                sb.Length = sb.Length - 2;
                            _textView.TextBuffer.Insert(_textView.Caret.Position.BufferPosition.Position, sb.ToString());
                            // Move the Caret in the Summary area
                            ITextSnapshotLine moveToline = _textView.TextSnapshot.GetLineFromLineNumber(line.LineNumber + 1);
                            SnapshotPoint point = new SnapshotPoint(moveToline.Snapshot, moveToline.End.Position);
                            _textView.Caret.MoveTo(point);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                WriteOutputMessage("InsertXMLDoc: error " + e.Message);
            }
        }

    }
}
