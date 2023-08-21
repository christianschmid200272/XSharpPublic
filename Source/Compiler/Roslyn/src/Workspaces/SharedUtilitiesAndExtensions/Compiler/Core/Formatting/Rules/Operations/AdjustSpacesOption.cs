﻿// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

namespace Microsoft.CodeAnalysis.Formatting.Rules
{
    /// <summary>
    /// Options for <see cref="AdjustSpacesOperation"/>.
    /// </summary>
    internal enum AdjustSpacesOption
    {
        /// <summary>
        /// Preserve spaces as it is
        /// </summary>
        PreserveSpaces,

        /// <summary>
        /// <see cref="DefaultSpacesIfOnSingleLine"/> means a default space operation created by the formatting
        /// engine by itself. It has its own option kind to indicates that this is an operation
        /// generated by the engine itself. 
        /// </summary>
        DefaultSpacesIfOnSingleLine,

        /// <summary>
        /// <see cref="ForceSpacesIfOnSingleLine"/> means forcing the specified spaces between two tokens if two
        /// tokens are on a single line. 
        /// </summary>
        ForceSpacesIfOnSingleLine,

        /// <summary>
        /// <see cref="ForceSpaces"/> means forcing the specified spaces regardless of positions of two tokens.
        /// </summary>
        ForceSpaces,

        /// <summary>
        /// If two tokens are on a single line, second token will be placed at current indentation if possible
        /// </summary>
        DynamicSpaceToIndentationIfOnSingleLine,
    }
}
