﻿using Microsoft.VisualStudio.Debugger.CallStack;
using Microsoft.VisualStudio.Debugger.Evaluation;
using Microsoft.VisualStudio.Debugger;
using Microsoft.VisualStudio.Shell;
using System;
using System.Linq;
using System.Threading.Tasks;
using Community.VisualStudio.Toolkit;
using XSharpModel;
using XSharp.Debugger.Support;
using System.Collections.Generic;

namespace XSharp.Debugger.UI
{
    internal class Support
    {
        internal static DkmLanguage language;
        private const DkmEvaluationFlags inspectionFlags =
            DkmEvaluationFlags.TreatAsExpression |
            DkmEvaluationFlags.ForceRealFuncEval;

        internal static EnvDTE.Debugger debugger;
        internal static DkmProcess currentProcess = null;
        internal static bool? IsRtLoaded = null;
        static IList<IDebuggerToolWindow> windows;


        static Support()
        {
            var lang_name = Constants.DbgXSharpLanguageName;
            var vend_id = Guid.Parse(Constants.XSharpVendorString);
            var lang_id = Guid.Parse(Constants.XSharpLanguageString);
            language = DkmLanguage.Create(lang_name, new DkmCompilerId(vend_id, lang_id));
            debugger = XSharpDebuggerUIPackage.XInstance.Dte.Debugger;
            windows = new List<IDebuggerToolWindow>();
        }
        internal static string StripResult(string str)
        {
            if (str != null )
            {
                if (str.IndexOf(RtLink.ErrorPrefix) == -1)
                {
                    if (str.StartsWith("\"") && str.EndsWith("\""))
                    {
                        str = str.Substring(1, str.Length - 2);
                    }
                }
                else
                {
                    VS.StatusBar.ShowMessageAsync(str).FireAndForget();
                    str = "";
                }
            }
            return str;
        }
        internal static async Task<string> GetMemVarsAsync()
        {
            var result = await Support.ExecExpressionAsync("XSharp.Debugger.Support.RtLink.GetMemVars()");
            return StripResult(result);
        }

        internal static async Task<bool> IsRTLoadedAsync()
        {
            if (IsRtLoaded.HasValue && ! IsProcessChanged())
                return IsRtLoaded.Value;
            var result = await Support.ExecExpressionAsync("XSharp.Debugger.Support.RtLink.IsRTLoaded()");
            IsRtLoaded = StripResult(result).ToLower() == "true";
            return IsRtLoaded.Value;
        }

        internal static async Task<string> GetGlobalsAsync()
        {
            var result = await Support.ExecExpressionAsync("XSharp.Debugger.Support.RtLink.GetGlobals()");
            return StripResult(result);
        }
        internal static async Task<string> GetSettingsAsync()
        {
            var result = await Support.ExecExpressionAsync("XSharp.Debugger.Support.RtLink.GetSettings()");
            return StripResult(result);
        }
        internal static async Task<string> GetWorkareasAsync()
        {
            var result = await Support.ExecExpressionAsync("XSharp.Debugger.Support.RtLink.GetWorkareas()");
            return StripResult(result);
        }

        static bool IsProcessChanged()
        {
            var proc = DkmProcess.GetProcesses().FirstOrDefault();
            return proc != currentProcess;
        }
        static async Task<object> LoadSupportDLLAsync()
        {
            var proc = DkmProcess.GetProcesses().FirstOrDefault();
            if (IsProcessChanged())
            {
                currentProcess = proc;
                IsRtLoaded = null;
                var path = System.IO.Path.GetDirectoryName(typeof(Support).Assembly.Location);
                var fileName = System.IO.Path.Combine(path, "XSharp.Debugger.Support.dll");
                var loaded = await ExecExpressionAsync("System.Reflection.Assembly.LoadFile(\"" + fileName + "\")");
            }
            return proc;
        }

        internal static async Task<string> ExecExpressionAsync(string source)
        {
            if (XDebuggerSettings.DebuggerMode != DebuggerMode.Break)
            {
                return "";
            }
            await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();
            var sf = debugger.CurrentStackFrame;
            if (sf == null)
            {
                return "";
            }
            var dkmsf = DkmStackFrame.ExtractFromDTEObject(sf);
            var thr = dkmsf.Thread;
            var proc = (DkmProcess) await LoadSupportDLLAsync();
            var expr = DkmLanguageExpression.Create(language, DkmEvaluationFlags.None, source, null);
            var wl = DkmWorkList.Create(null);
            var insp = DkmInspectionSession.Create(proc, null);
            var inst = dkmsf.RuntimeInstance;
            var ictx = DkmInspectionContext.Create(insp, inst, thr, 0,
                                                   inspectionFlags, DkmFuncEvalFlags.None, 10,
                                                   language, null);

            DkmEvaluationResult res = null;
            ictx.EvaluateExpression(wl, expr, dkmsf, (result) => { res = result.ResultObject; });
            wl.Execute();
            string value = "";
            if (res is DkmSuccessEvaluationResult sucres)
            {
                value = sucres.Value;
            }
            return value;
        }
        internal static void RegisterWindow(IDebuggerToolWindow oWindow)
        {
            if (! windows.Contains(oWindow))
            {
                windows.Add(oWindow);
            }
        }
        internal static void RefreshWindows()
        {
            foreach (var window in windows)
            {
                window.Refresh();
            }

        }
        internal static void ClearWindows()
        {
            foreach (var window in windows)
            {
                window.Clear();
            }
        }
        
    }
    
}
