﻿using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.Classification;
using Microsoft.CodeAnalysis.Text;
using Microsoft.VisualStudio.Text;
using Microsoft.VisualStudio.Text.Classification;
using Microsoft.VisualStudio.Text.Tagging;
using Microsoft.VisualStudio.Utilities;
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.Linq;
using System.Threading.Tasks;
using LanguageService.CodeAnalysis.XSharp;
using Microsoft.VisualStudio.ComponentModelHost;
using LanguageService.CodeAnalysis.XSharp.SyntaxParser;
using LanguageService.SyntaxTree;

namespace XSharpColorizer
{

    [Export(typeof(ITaggerProvider))]
    [ContentType("XSharp")]
    [TagType(typeof(IClassificationTag))]
    internal class XSharpColorizerProvider : ITaggerProvider
    {

        [Export]
        [Name("XSharp")]
        [BaseDefinition("code")]
        internal static ContentTypeDefinition XSharpContentType = null;

        [Export]
        [FileExtension(".prg")]
        [ContentType("XSharp")]
        internal static FileExtensionToContentTypeDefinition XSharpFileType = null;

        [Import]
        internal IClassificationTypeRegistryService ClassificationRegistry = null; // Set via MEF

        public ITagger<T> CreateTagger<T>(ITextBuffer buffer) where T : ITag
        {
            return (ITagger<T>)new XSharpColorizer(buffer, ClassificationRegistry);
        }
    }

    class XSharpColorizer : ITagger<IClassificationTag>
    {
        private ITextBuffer Buffer;
        public ITextSnapshot Snapshot { get; set; }
        private IClassificationType xsharpKeywordType;
        private IClassificationType xsharpIdentifierType;
        private IClassificationType xsharpCommentType;
        private IClassificationType xsharpOperatorType;
        private IClassificationType xsharpConstantType;
        private IClassificationType xsharpStringType;
        private IClassificationType xsharpBraceOpenType;
        private IClassificationType xsharpBraceCloseType;
        private XSharpTagger xsTagger;
#pragma warning disable CS0067
        public event EventHandler<SnapshotSpanEventArgs> TagsChanged;
#pragma warning restore CS0067
        private List<ITagSpan<IClassificationTag>> tags;

        internal XSharpColorizer(ITextBuffer buffer, IClassificationTypeRegistryService registry)
        {
            this.Buffer = buffer;
            this.Snapshot = buffer.CurrentSnapshot;

            xsTagger = new XSharpTagger(registry);

            tags = new List<ITagSpan<IClassificationTag>>();
            //
            xsharpKeywordType = registry.GetClassificationType(Constants.XSharpKeywordFormat);
            xsharpIdentifierType = registry.GetClassificationType(Constants.XSharpIdentifierFormat);
            xsharpCommentType = registry.GetClassificationType(Constants.XSharpCommentFormat);
            xsharpOperatorType = registry.GetClassificationType(Constants.XSharpOperatorFormat);
            xsharpConstantType = registry.GetClassificationType(Constants.XSharpConstantFormat);
            xsharpStringType = registry.GetClassificationType(Constants.XSharpStringFormat);
            xsharpBraceOpenType = registry.GetClassificationType(Constants.XSharpBraceOpenFormat);
            xsharpBraceCloseType = registry.GetClassificationType(Constants.XSharpBraceCloseFormat);

            this.Buffer.Changed += OnBufferChanged;
            //
            Colorize();
        }


        void OnBufferChanged(object sender, TextContentChangedEventArgs e)
        {
            // If this isn't the most up-to-date version of the buffer, then ignore it for now (we'll eventually get another change event).
            if (e.After != Buffer.CurrentSnapshot)
                return;
            Colorize();
        }


        /// <summary>
        /// Parse the current Snapshot, and build the Tag List
        /// </summary>
        private void Colorize()
        {
            // RvdH 2016-02-23
            // This method now uses the Lexer to get the tokens in the buffer and uses some static methods of the lexer to 
            // distinguish between different types of tokens.
            // because the (current version of) the parser does not have info about comments anymore as well 
            // some other tokens, such as preprocessor tokens
            // Since some keywords can also be used as identifiers we will also parse the source in the parser to 
            // change some keywords to identifiers.
            // We can probably also get the list of tokens from the parser but I have no idea how to do that at this moment

            this.Snapshot = this.Buffer.CurrentSnapshot;
            var stream = new AntlrInputStream(this.Snapshot.GetText());
            var lexer = new XSharpLexer(stream);
            var token = lexer.NextToken();
            tags.Clear();
            
            while (token.Type != XSharpLexer.Eof)
            {
                var tokenType = token.Type;
                TextSpan tokenSpan = new TextSpan(token.StartIndex, token.StopIndex - token.StartIndex + 1);
                if (XSharpLexer.IsKeyword(tokenType))
                {
                    tags.Add(tokenSpan.ToTagSpan(Snapshot, xsharpKeywordType));
                }
                else if (XSharpLexer.IsConstant(tokenType))
                {
                    if (tokenType == XSharpLexer.STRING_CONST || tokenType == XSharpLexer.ESCAPED_STRING_CONST)
                        tags.Add(tokenSpan.ToTagSpan(Snapshot, xsharpStringType));
                    else
                        tags.Add(tokenSpan.ToTagSpan(Snapshot, xsharpConstantType));

                }
                else if (XSharpLexer.IsOperator(tokenType))
                {
                    switch (tokenType)
                    {
                        case LanguageService.CodeAnalysis.XSharp.SyntaxParser.XSharpLexer.LPAREN:
                        case LanguageService.CodeAnalysis.XSharp.SyntaxParser.XSharpLexer.LCURLY:
                        case LanguageService.CodeAnalysis.XSharp.SyntaxParser.XSharpLexer.LBRKT:
                            tags.Add(tokenSpan.ToTagSpan(Snapshot, xsharpBraceOpenType));
                            break;

                        case LanguageService.CodeAnalysis.XSharp.SyntaxParser.XSharpLexer.RPAREN:
                        case LanguageService.CodeAnalysis.XSharp.SyntaxParser.XSharpLexer.RCURLY:
                        case LanguageService.CodeAnalysis.XSharp.SyntaxParser.XSharpLexer.RBRKT:
                            tags.Add(tokenSpan.ToTagSpan(Snapshot, xsharpBraceCloseType));
                            break;
                        default:
                            tags.Add(tokenSpan.ToTagSpan(Snapshot, xsharpOperatorType));
                            break;
                    }
                }
                else if (XSharpLexer.IsIdentifier(tokenType))
                {
                    tags.Add(tokenSpan.ToTagSpan(Snapshot, xsharpIdentifierType));
                }
                else if (XSharpLexer.IsComment(tokenType))
                {
                    tags.Add(tokenSpan.ToTagSpan(Snapshot, xsharpCommentType));
                }
                token = lexer.NextToken();
            }
            // parse for positional keywords that change the colors
            xsTagger.Parse(this.Snapshot);
            foreach (var tag in xsTagger.Tags)
            {
                tags.Add(tag);
            }
        }

        public IEnumerable<ITagSpan<IClassificationTag>> GetTags(NormalizedSnapshotSpanCollection spans)
        {
            if ((spans.Count == 0) || (this.tags == null) || (this.tags.Count == 0) )
            {
                //return Enumerable.Empty<ITagSpan<IClassificationTag>>();
                yield break;
            }
            //
            SnapshotSpan entire = new SnapshotSpan(spans[0].Start, spans[spans.Count - 1].End).TranslateTo(this.Snapshot, SpanTrackingMode.EdgeExclusive);
            //
            foreach ( var tag in this.tags )
            {
                //if ( tag.Span.Start.Position >= entire.Start.Position &&
                //     tag.Span.End.Position <= entire.End.Position )
                {
                    yield return tag;
                }
            }
        }

     }
}
