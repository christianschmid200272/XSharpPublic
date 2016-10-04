﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
using System;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Project;
using Microsoft.VisualStudio.Shell.Interop;
using VsCommands = Microsoft.VisualStudio.VSConstants.VSStd97CmdID;
using VsCommands2K = Microsoft.VisualStudio.VSConstants.VSStd2KCmdID;
using OleConstants = Microsoft.VisualStudio.OLE.Interop.Constants;

namespace XSharp.Project
{

    /// <summary>
    /// Represents a Folder node in a Vulcan project.
    /// </summary>
    public class XSharpFolderNode : FolderNode, IProjectSourceNode
    {
        // =========================================================================================
        // Member Variables
        // =========================================================================================

        private bool isNonMemberItem;

        // =========================================================================================
        // Constructors
        // =========================================================================================

        /// <summary>
        /// Initializes a new instance of the <see cref="VulcanFolderNode"/> class.
        /// </summary>
        /// <param name="root">The root <see cref="VulcanProjectNode"/> that contains this node.</param>
        /// <param name="directoryPath">Root of the hierarchy.</param>
        /// <param name="element">The element that contains MSBuild properties.</param>
        public XSharpFolderNode(XSharpProjectNode root, string directoryPath, ProjectElement element)
           : this(root, directoryPath, element, false)
        {
            root.AddURL(this.Url, this);
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="VulcanFileNode"/> class.
        /// </summary>
        /// <param name="root">The root <see cref="VulcanProjectNode"/> that contains this node.</param>
        /// <param name="directoryPath">Root of the hierarchy</param>
        /// <param name="element">The element that contains MSBuild properties.</param>
        /// <param name="isNonMemberItem">Indicates if this node is not a member of the project.</param>
        [SuppressMessage("Microsoft.Naming", "CA1702:CompoundWordsShouldBeCasedCorrectly", MessageId = "NonMember")]
        public XSharpFolderNode(XSharpProjectNode root, string directoryPath, ProjectElement element, bool isNonMemberItem)
           : base(root, directoryPath, element)
        {
            this.isNonMemberItem = isNonMemberItem;
            root.AddURL(this.Url, this);
            // Folders do not participate in SCC.
            base.ExcludeNodeFromScc = true;
        }

        /// <summary>
        /// Menu Command Id for Folder item.
        /// </summary>
        /// <value>Menu Command Id for Folder item.</value>
        public override int MenuCommandId
        {
            get
            {
                if (this.IsNonMemberItem)
                {
                    return VsMenus.IDM_VS_CTXT_XPROJ_MULTIITEM;
                }

                return base.MenuCommandId;
            }
        }

        /// <summary>
        /// Specifies if a Node is under source control.
        /// </summary>
        /// <value>Specifies if a Node is under source control.</value>
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Scc")]
        public override bool ExcludeNodeFromScc
        {
            get
            {
                // Non member items donot participate in SCC.
                if (this.IsNonMemberItem)
                {
                    return true;
                }

                return base.ExcludeNodeFromScc;
            }

            set
            {
                base.ExcludeNodeFromScc = value;
            }
        }

        // =========================================================================================
        // IProjectSourceNode Properties
        // =========================================================================================

        /// <summary>
        /// Flag that indicates if this node is not a member of the project.
        /// </summary>
        /// <value>true if the item is not a member of the project build, false otherwise.</value>
        public bool IsNonMemberItem
        {
            get
            {
                return this.isNonMemberItem;
            }
        }

        // =========================================================================================
        // Methods
        // =========================================================================================

        /// <summary>
        /// Sets the node property.
        /// </summary>
        /// <param name="propid">Property id.</param>
        /// <param name="value">Property value.</param>
        /// <returns>Returns success or failure code.</returns>
        public override int SetProperty(int propid, object value)
        {
            int result;
            __VSHPROPID id = (__VSHPROPID)propid;
            switch (id)
            {
                case __VSHPROPID.VSHPROPID_IsNonMemberItem:
                    if (value == null)
                    {
                        throw new ArgumentNullException("value");
                    }

                    bool boolValue = false;
                    CCITracing.TraceCall(this.ID + "," + id.ToString());
                    if (bool.TryParse(value.ToString(), out boolValue))
                    {
                        this.isNonMemberItem = boolValue;
                    }
                    else
                    {
                        SupportMethods.TraceFail("Could not parse the IsNonMemberItem property value.");
                    }

                    result = VSConstants.S_OK;
                    break;

                default:
                    result = base.SetProperty(propid, value);
                    break;
            }

            return result;
        }

        /// <summary>
        /// Gets the node property.
        /// </summary>
        /// <param name="propId">Property id.</param>
        /// <returns>The property value.</returns>
        public override object GetProperty(int propId)
        {
            switch ((__VSHPROPID)propId)
            {
                case __VSHPROPID.VSHPROPID_IsNonMemberItem:
                    return this.IsNonMemberItem;
            }

            return base.GetProperty(propId);
        }

        /// <summary>
        /// Provides the node name for inline editing of caption.
        /// Overridden to disable this functionality for non member folder node.
        /// </summary>
        /// <returns>Caption of the folder node if the node is a member item, null otherwise.</returns>
        public override string GetEditLabel()
        {
            if (this.IsNonMemberItem)
            {
                return null;
            }

            return base.GetEditLabel();
        }


        public override int SetEditLabel(string label)
        {
            int iResult;
            String sOldUrl = this.Url;
            iResult = base.SetEditLabel(label);
            if (iResult == VSConstants.S_OK && String.Compare(this.Url, sOldUrl, true) != 0)
            {
                XSharpProjectNode project = this.ProjectMgr as XSharpProjectNode;
                if (project != null)
                {
                    project.RemoveURL(sOldUrl);
                    project.AddURL(this.Url, this);
                }
            }
            return iResult;
        }

        // Because the IsExpanded is not working properly (as of this date, 10/18/2007), that's why we are using the
        // GetIconHandle method. When we fix the IsExpanded property, we should switch to ImageIndex property instead
        // of this method.

        /// <summary>
        /// Gets the image icon handle for the folder node.
        /// </summary>
        /// <param name="open">Flag that indicated if the folder is in expanded (opened) mode.</param>
        /// <returns>Image icon handle.</returns>
        public override object GetIconHandle(bool open)
        {
            if (this.IsNonMemberItem)
            {
                return this.ProjectMgr.ImageHandler.GetIconHandle(open ? (int)ProjectNode.ImageName.OpenExcludedFolder : (int)ProjectNode.ImageName.ExcludedFolder);
            }

            return base.GetIconHandle(open);
        }

        /// <summary>
        /// Expands the folder.
        /// </summary>
        public void ExpandFolder()
        {
            this.SetExpanded(true);
        }

        /// <summary>
        /// Collapses the folder.
        /// </summary>
        public void CollapseFolder()
        {
            this.SetExpanded(false);
        }

        // =========================================================================================
        // IProjectSourceNode Methods
        // =========================================================================================

        /// <summary>
        /// Exclude the item from the project system.
        /// </summary>
        /// <returns>Returns success or failure code.</returns>
        [SuppressMessage("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        int IProjectSourceNode.ExcludeFromProject()
        {
            XSharpProjectNode projectNode = this.ProjectMgr as XSharpProjectNode;
            if (projectNode == null || projectNode.IsClosed)
            {
                return (int)OleConstants.OLECMDERR_E_NOTSUPPORTED;
            }
            else if (this.IsNonMemberItem)
            {
                return VSConstants.S_OK; // do nothing, just ignore it.
            }

            using (SupportMethods.NewWaitCursor())
            {
                // Check out the project file.
                if (!projectNode.QueryEditProjectFile(false))
                {
                    throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
                }

                // remove children, if any, before removing from the hierarchy
                for (HierarchyNode child = this.FirstChild; child != null; child = child.NextSibling)
                {
                    IProjectSourceNode node = child as IProjectSourceNode;
                    if (node != null)
                    {
                        int result = node.ExcludeFromProject();
                        if (result != VSConstants.S_OK)
                        {
                            return result;
                        }
                    }
                }

                if (projectNode != null && projectNode.ShowAllFilesEnabled && Directory.Exists(this.Url))
                {
                    string url = this.Url;
                    this.SetProperty((int)__VSHPROPID.VSHPROPID_IsNonMemberItem, true);
                    this.ItemNode.RemoveFromProjectFile();
                    this.ItemNode = new ProjectElement(this.ProjectMgr, null, true);  // now we have to create a new ItemNode to indicate that this is virtual node.
                    this.ItemNode.Rename(url);
                    this.ItemNode.SetMetadata(ProjectFileConstants.Name, this.Url);
                    this.ReDraw(UIHierarchyElement.Icon); // we have to redraw the icon of the node as it is now not a member of the project and shoul be drawn using a different icon.
                }
                else if (this.Parent != null) // the project node has no parentNode
                {
                    // this is important to make it non member item. otherwise, the multi-selection scenario would
                    // not work if it has any parent child relation.
                    this.SetProperty((int)__VSHPROPID.VSHPROPID_IsNonMemberItem, true);

                    // remove from the hierarchy
                    this.OnItemDeleted();
                    this.Parent.RemoveChild(this);
                    this.ItemNode.RemoveFromProjectFile();
                }

                // refresh property browser...
                SupportMethods.RefreshPropertyBrowser();
            }

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Include the item into the project system.
        /// </summary>
        /// <returns>Returns success or failure code.</returns>
        [SuppressMessage("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        int IProjectSourceNode.IncludeInProject()
        {
            return ((IProjectSourceNode)this).IncludeInProject(true);
        }

        /// <summary>
        /// Include the item into the project system recursively.
        /// </summary>
        /// <param name="recursive">Flag that indicates if the inclusion should be recursive or not.</param>
        /// <returns>Returns success or failure code.</returns>
        [SuppressMessage("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        int IProjectSourceNode.IncludeInProject(bool recursive)
        {
            if (this.ProjectMgr == null || this.ProjectMgr.IsClosed)
            {
                return (int)OleConstants.OLECMDERR_E_NOTSUPPORTED;
            }
            else if (!this.IsNonMemberItem)
            {
                return VSConstants.S_OK; // do nothing, just ignore it.
            }

            using (SupportMethods.NewWaitCursor())
            {
                // Check out the project file.
                if (!this.ProjectMgr.QueryEditProjectFile(false))
                {
                    throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
                }

                // make sure that all parent folders are included in the project
                SupportMethods.EnsureParentFolderIncluded(this);

                // now add this node to the project.
                this.AddToMSBuild(recursive);
                this.ReDraw(UIHierarchyElement.Icon);

                // refresh property browser...
                SupportMethods.RefreshPropertyBrowser();
            }

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Creates an object derived from <see cref="NodeProperties"/> that will be used to expose
        /// properties specific for this object to the property browser.
        /// </summary>
        /// <returns>A new <see cref="VulcanFileNodeProperties"/> object.</returns>
        protected override NodeProperties CreatePropertiesObject()
        {
            return new FolderNodeProperties(this);
        }

        /// <summary>
        /// Handles command status on a node. Should be overridden by descendant nodes. If a command cannot be handled then the base should be called.
        /// </summary>
        /// <param name="cmdGroup">A unique identifier of the command group. The pguidCmdGroup parameter can be NULL to specify the standard group.</param>
        /// <param name="cmd">The command to query status for.</param>
        /// <param name="pCmdText">Pointer to an OLECMDTEXT structure in which to return the name and/or status information of a single command. Can be NULL to indicate that the caller does not require this information.</param>
        /// <param name="result">An out parameter specifying the QueryStatusResult of the command.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        [SuppressMessage("Microsoft.Naming", "CA1725:ParameterNamesShouldMatchBaseDeclaration", MessageId = "0#", Justification = "Suppressing to avoid conflict with style cop.")]
        protected override int QueryStatusOnNode(Guid cmdGroup, uint cmd, IntPtr pCmdText, ref QueryStatusResult result)
        {
            int returnCode;
            if (SupportMethods.QueryStatusOnProjectSourceNode(this, cmdGroup, cmd, ref result, out returnCode))
            {
                return returnCode;
            }

            return base.QueryStatusOnNode(cmdGroup, cmd, pCmdText, ref result);
        }

        private const VsCommands2K ExploreFolderInWindowsCommand = (VsCommands2K)1635;
        /// <summary>
        /// Handles command execution.
        /// </summary>
        /// <param name="cmdGroup">Unique identifier of the command group</param>
        /// <param name="cmd">The command to be executed.</param>
        /// <param name="cmdexecopt">Values describe how the object should execute the command.</param>
        /// <param name="pvaIn">Pointer to a VARIANTARG structure containing input arguments. Can be NULL</param>
        /// <param name="pvaOut">VARIANTARG structure to receive command output. Can be NULL.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        [SuppressMessage("Microsoft.Naming", "CA1725:ParameterNamesShouldMatchBaseDeclaration", MessageId = "0#", Justification = "Suppressing to avoid conflict with style cop.")]
        [SuppressMessage("Microsoft.Naming", "CA1725:ParameterNamesShouldMatchBaseDeclaration", MessageId = "2#", Justification = "Suppressing to avoid conflict with style cop.")]
        protected override int ExecCommandOnNode(Guid cmdGroup, uint cmd, uint cmdexecopt, IntPtr pvaIn, IntPtr pvaOut)
        {
            if (cmdGroup == VsMenus.guidStandardCommandSet2K)
            {
                switch ((VsCommands2K)cmd)
                {
                    case VsCommands2K.INCLUDEINPROJECT:
                        return ((IProjectSourceNode)this).IncludeInProject();

                    case VsCommands2K.EXCLUDEFROMPROJECT:
                        return ((IProjectSourceNode)this).ExcludeFromProject();

                    case ExploreFolderInWindowsCommand:
                        SupportMethods.ExploreFolderInWindows(this.GetMkDocument());
                        return VSConstants.S_OK;

                    case VsCommands2K.SLNREFRESH:
                        SupportMethods.RefreshProject(this);
                        return VSConstants.S_OK;
                }
            }

            if (cmdGroup == VsMenus.guidStandardCommandSet97)
            {
                switch ((VsCommands)cmd)
                {
                    case VsCommands.Refresh:
                        SupportMethods.RefreshProject(this);
                        return VSConstants.S_OK;
                }
            }

            return base.ExecCommandOnNode(cmdGroup, cmd, cmdexecopt, pvaIn, pvaOut);
        }

        /// <summary>
        /// Adds the this node to the build system.
        /// </summary>
        /// <param name="recursive">Flag to indicate if the addition should be recursive.</param>
        protected virtual void AddToMSBuild(bool recursive)
        {
            XSharpProjectNode projectNode = this.ProjectMgr as XSharpProjectNode;
            if (projectNode == null || projectNode.IsClosed)
            {
                return; // do nothing
            }

            this.ItemNode = projectNode.AddFolderToMsBuild(this.Url);
            this.SetProperty((int)__VSHPROPID.VSHPROPID_IsNonMemberItem, false);
            if (recursive)
            {
                for (HierarchyNode node = this.FirstChild; node != null; node = node.NextSibling)
                {
                    IProjectSourceNode sourceNode = node as IProjectSourceNode;
                    if (sourceNode != null)
                    {
                        sourceNode.IncludeInProject(recursive);
                    }
                }
            }
        }
        protected internal override void DeleteFromStorage(string path)
        {
            if (File.Exists(path))
            {
                File.SetAttributes(path, FileAttributes.Normal); // make sure it's not readonly.
                OurNativeMethods.ShellDelete(path, OurNativeMethods.RecycleOption.SendToRecycleBin,
                   OurNativeMethods.UICancelOption.DoNothing, OurNativeMethods.FileOrDirectory.Directory);

            }
        }

        public override void OnItemDeleted()
        {
            if (this.ProjectMgr is XSharpProjectNode)
            {
                XSharpProjectNode projectNode = (XSharpProjectNode)this.ProjectMgr;
                if (projectNode != null)
                    projectNode.RemoveURL(this);

                base.OnItemDeleted();
            }
        }

        /// <summary>
        /// Sets the expanded state of the folder.
        /// </summary>
        /// <param name="expanded">Flag that indicates the expanded state of the folder.
        /// This should be 'true' for expanded and 'false' for collapsed state.</param>
        protected void SetExpanded(bool expanded)
        {
            this.IsExpanded = expanded;
            this.SetProperty((int)__VSHPROPID.VSHPROPID_Expanded, expanded);

            // If we are in automation mode then skip the ui part
            if (!Utilities.IsInAutomationFunction(this.ProjectMgr.Site))
            {
                IVsUIHierarchyWindow uiWindow = UIHierarchyUtilities.GetUIHierarchyWindow(this.ProjectMgr.Site, SolutionExplorer);
                int result = uiWindow.ExpandItem(this.ProjectMgr, this.ID, expanded ? EXPANDFLAGS.EXPF_ExpandFolder : EXPANDFLAGS.EXPF_CollapseFolder);
                ErrorHandler.ThrowOnFailure(result);

                // then post the expand command to the shell. Folder verification and creation will
                // happen in the setlabel code...
                IVsUIShell shell = SupportMethods.GetService<IVsUIShell, SVsUIShell>(this.ProjectMgr.Site);

                object dummy = null;
                Guid cmdGroup = VsMenus.guidStandardCommandSet97;
                result = shell.PostExecCommand(ref cmdGroup, (uint)(expanded ? VsCommands.Expand : VsCommands.Collapse), 0, ref dummy);
                ErrorHandler.ThrowOnFailure(result);
            }
        }
        #region Dispose Methods
        protected override void Dispose(bool disposing)
        {
            if (this.ProjectMgr is XSharpProjectNode)
            {
                XSharpProjectNode projectNode = (XSharpProjectNode)this.ProjectMgr;
                if (projectNode != null)
                    projectNode.RemoveURL(this);
            }
            base.Dispose(disposing);
        }
        #endregion

    }
}