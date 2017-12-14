#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

CoordMode, Mouse, Client

BreakLoop = 0
Gui, Add, Text,, How many boxes to open?
Gui, Add, Edit
Gui, Add, UpDown, vRunCount Range1-100000, 1 ym
Gui, Add, Checkbox, -Wrap vKeepHasPrio, Keep Loot if possible?
Gui, Add, Text,, `nTo open boxess, hit "Run" or ctrl+F12`nTo stop, hit "Cancel" or ctrl+shift+F12
Gui, Font, cFF0000
Gui, Add, Text,, Before You start: make sure you have the`n"Open Loot Box" screen ready ingame!
Gui, Font,
Gui, Add, Button, default vRunButton, Run
Gui, Add, Button, xp+35 vp vCancelButton, Cancel
GuiControl, Disable, CancelButton
Gui, Show, x20 y20 h190 w210, AutoICBING
return  ; End of auto-execute section. The script is idle until the user does something.

GuiClose:
ExitApp

ButtonCancel:
^+F12::
BreakLoop = 1
GuiControl, Enable, RunButton
GuiControl, Disable, CancelButton
return

ButtonRun:
^F12::

; Get form values
GuiControlGet, KeepHasPrio
GuiControlGet, RunCount

; First check if game is running and the right size
WinGet, hwnd,,5.6ICBING
GetClientSize(hwnd, cWidth, cHeight)
if (cWidth == 0 && cHeight == 0) {
    MsgBox,,Error, Please start "I can't believe it's not gambling" first
    return
}
if (cWidth != 1600 || cHeight != 900) {
    MsgBox,,Error, Your game is running at %w%x%h% - Please set resolution to 1600x900
    return
}

GuiControl, Disable, RunButton
GuiControl, Enable, CancelButton

; Make sure the user knows what will happen
MsgBox, 1,Last warning, WARNING: Do not touch you mouse after this dialog!`n%RunCount% box(es) will be opened.`nTo cancel at any time press "Ctrl+F12"`nTo start, Press now "Enter" or click "Ok"
IfMsgBox Cancel
{
    GuiControl, Enable, RunButton
    GuiControl, Disable, CancelButton
    return
}

; Activate game window
WinActivate, ahk_id %hwnd%

Current = %RunCount%
LoopTimes = %RunCount%

Loop %LoopTimes% {
if (BreakLoop = 1) {
    BreakLoop = 0
    break
}

; Open one box
OpenBox(hwnd, KeepHasPrio)

; Update the form
Current--
GuiControl,,RunCount,%Current%

; Needed so a cancel comes through in any case
Sleep, 100
}

; We're done, back to normal
GuiControl, Enable, RunButton
GuiControl, Disable, CancelButton
return

; Returns the inner size of the game window, the game resolution
GetClientSize(hwnd, ByRef cWidth, ByRef cHeight)
{
    VarSetCapacity(rc, 16)
    DllCall("GetClientRect", "uint", hwnd, "uint", &rc)
    cWidth := NumGet(rc, 8, "int")
    cHeight := NumGet(rc, 12, "int")
}

; Main work
OpenBox(hwnd, KeepHasPrio) {
    Click, 570 780 ; Click yellow "open loot box" button
    Sleep 5700 ; Wait loot box to open
    
    ; Click all keep buttons first, then remaining sell buttons
    if (KeepHasPrio = 1) {
        Click, 1280 600 ; Keep loot, if possible
        Sleep 400 ; Wait for the game to register the last click

        ; Same for the other three loot boxes:

        Click, 960 610
        Sleep 400

        Click 610 600
        Sleep 400

        Click 240 610
        Sleep 400
    }
    
    Click, 1300 630 ; Sell loot, if possible
    Sleep 400 ; Wait for the game to register the last click
    
    ; Same for the other three loot boxes:

    Click, 950 640
    Sleep 400

    Click, 600 630
    Sleep 400
    
    Click, 230 640
    Sleep 400
}