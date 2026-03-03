#Requires AutoHotkey v2.0.0+
;==============================================================
; getSelectedRouteAlias — Gets the network interface alias Windows selects for routing traffic to a remote IP
;
; GitHub: https://github.com/SevenKeyboard/get-selected-route-alias
; Author: SevenKeyboard Ltd. (2026)
; License: The Unlicense
;
; Documentation / References:
;   Find-NetRoute
;     https://learn.microsoft.com/en-us/powershell/module/nettcpip/find-netroute?view=windowsserver2025-ps
;==============================================================

/*
Example Usage:
    msgbox(getSelectedRouteAlias()) ;  e.g. "Ethernet" or "NordLynx"
*/

class VersionManager_getSelectedRouteAlias
{
    static _ := this._init()
    static _init()    {
        global
        GETSELECTEDROUTEALIAS_VERSION := "1.0.0"
    }
}
getSelectedRouteAlias(remoteIPAddress := "1.1.1.1", attachTimeout := 2)    {
    result := ""
    prevDetectHiddenWindows := detectHiddenWindows(true)
    try  {
        run(A_ComSpec,, "Hide", &pid)
        if (!winWait("ahk_pid " . pid,, attachTimeout))
            return ""
        if (!dllCall("Kernel32.dll\AttachConsole", "UInt",pid, "Int"))
            return ""
        try  {
            shell   := comObject("WScript.Shell")
            ps      := format("
            (Join LTrim RTrim0
                Find-NetRoute -RemoteIPAddress '{1}' | 
                Select-Object -First 1 -ExpandProperty InterfaceAlias
            )", remoteIPAddress) ;  Return the alias of the interface selected by Windows for traffic to remoteIPAddress.
            exec    := shell.Exec('powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "' . ps . '"')
            result  := trim(exec.StdOut.ReadAll())
        }  finally  {
            dllCall("Kernel32.dll\FreeConsole", "Int")
            try winClose("ahk_pid " . pid)
        }
    }  finally  {
        detectHiddenWindows prevDetectHiddenWindows
    }
    return result
}