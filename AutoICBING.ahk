#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

CoordMode, Mouse, Client

BreakLoop = 0
GameWindowTitle = 5.6ICBING
Gui, Add, Text,, How many boxes to open?
Gui, Add, Edit
Gui, Add, UpDown, vRunCount Range1-100000, 1 ym
Gui, Add, Checkbox, -Wrap vKeepHasPrio, Keep box content if possible?
Gui, Add, Text,, `nTo open boxes, hit "Run" or ctrl+F12`nTo stop, hit "Cancel" or ctrl+shift+F12
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
WinGet, hwnd,,%GameWindowTitle%
GameRes := GetGameRes(GameWindowTitle)
if (GameRes == 0) {
    return
}

GuiControl, Disable, RunButton
GuiControl, Enable, CancelButton

; Make sure the user knows what will happen
MsgBox, 1,Last warning, WARNING: Do not touch you mouse after this dialog!`n%RunCount% box(es) will be opened.`nTo cancel at any time press "Ctrl+Shift+F12"`nTo start, Press now "Enter" or click "Ok"
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

; Check if the user canceled the Loop
if (BreakLoop = 1) {
    BreakLoop = 0
    break
}

GameRes := GetGameRes(GameWindowTitle)

; Make sure the game wasn't closed since last loop
if (GameRes == 0) {
    break
}

; Open one box
if(GameRes == 1) {
    OpenBoxInLowRes(hwnd, KeepHasPrio)
} else if(GameRes == 3) {
    OpenBoxInLowestRes(hwnd, KeepHasPrio)
}
else {
    OpenBoxInHiRes(hwnd, KeepHasPrio)
}

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

; Returns 0 if the game is not running or the wrong size, 1 if running in LowRes, 2 if running in HiRes
; Used to set BreakLoop variable
; Will show a message box on error
GetGameRes(WinTitle) {
    IfWinNotExist, %WinTitle%
    {
        MsgBox,,Error, Please start "I can't believe it's not gambling" first
        return 0
    }
    
    WinGet, currentHwnd,,%WinTitle%
    GetClientSize(currentHwnd, cWidth, cHeight)
    if (cWidth == 1360 && cHeight == 768) {
        return 1
    }
    if (cWidth == 1600 && cHeight == 900) {
        return 2
    }
    if (cWidth == 1280 && cHeight == 1024) {
        return 3
    }
    MsgBox,,Error, Your game is running at %cWidth%x%cHeight%`nPlease set resolution to 1600x900, 1360x768 or 1280x1024
    return 0
}

; Main work for 1280x1024
OpenBoxInLowestRes(hwnd, KeepHasPrio) {
    Click, 460 780 ; Click yellow "open loot box" button
    Sleep 5700 ; Wait for box to open
    
    ; Click all keep buttons first, then remaining sell buttons
    if (KeepHasPrio != 1) {
        Click, 570 780 ; Click "Sell All" button
        Sleep 150
        return
    }
    
    Click, 1190 680 ; Keep box content, if possible
    Sleep 400 ; Wait for the game to register the last click

    ; Same for the other three boxes:

    Click, 820 690
    Sleep 400

    Click 430 680
    Sleep 400

    Click 10 690
    Sleep 400

    Click, 570 780 ; Click "Sell All" button
    Sleep 150
}

; Main work for 1360x768
OpenBoxInLowRes(hwnd, KeepHasPrio) {
    Click, 490 660 ; Click yellow "open loot box" button
    Sleep 5700 ; Wait for box to open
    
    ; Click all keep buttons first, then remaining sell buttons
    if (KeepHasPrio != 1) {
        Click, 600 670 ; Click "Sell All" button
        Sleep 150
        return
    }
    
    Click, 1070 515 ; Keep box content, if possible
    Sleep 400 ; Wait for the game to register the last click

    ; Same for the other three boxes:

    Click, 800 520
    Sleep 400

    Click 500 515
    Sleep 400

    Click 200 520
    Sleep 400

    Click, 600 670 ; Click "Sell All" button
    Sleep 150
}

; Main work for 1600x900
OpenBoxInHiRes(hwnd, KeepHasPrio) {
    Click, 570 780 ; Click yellow "open loot box" button
    Sleep 5500 ; Wait for box to open
    
    ; Click all keep buttons first, then remaining sell buttons
    if (KeepHasPrio != 1) {
        Click, 750 780 ; Click "Sell All" button
        Sleep 150
        return    
    }
    
    Click, 1280 600 ; Keep loot, if possible
    Sleep 400 ; Wait for the game to register the last click

    ; Same for the other three boxes:

    Click, 960 610
    Sleep 400

    Click 610 600
    Sleep 400

    Click 240 610
    Sleep 400

    Click, 750 780 ; Click "Sell All" button
    Sleep 150
}
