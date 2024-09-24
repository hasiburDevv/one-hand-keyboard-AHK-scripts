﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;Suspend, on
#InstallKeybdHook
#SingleInstance, force
#MaxHotkeysPerInterval 200
#Persistent
;SendMode Input
;#UseHook
;SetCapsLockState, alwaysoff
;KeyHistory
SetCapsLockState, AlwaysOff
CoordMode, ToolTip
; Get the mouse cursor's current position
;MouseGetPos, x, y

global INSERT_MODE := true
global INSERT_MODE_II := false ; Variable to track the state of the index layer
global TOGGLE := false
global VIM_NORMAL_SPACE_MODE := false
global NORMAL_GUI_MODE := false
global NORMAL_ALT_MODE := false
global SYMBOL_MODE := false
global NUMBER_MODE := false
global NUMPAD_SYMBOL_MODE := false ; Variable to track the state of the numpad symbol layer
global NUMPAD_NUMBER_MODE := false
global IS_RBUTTON_DOWN := false ; Initialize flags to track the state of RButton down
;global CapsLockArrow := false

global CHECK_IS_ON_VIM_VISUAL_SPACE_MODE := false
global CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
global VSCodeTabSwitchWhileInsetMode := false
global VISUAL_MODE := false
global DELETE_MODE := false
global YANK_MODE := false
global CHANGE_MODE := false

global char_visual := false
global line_visual := false
global block_visual := false

; Global variables to track which GUI is currently displayed
global CurrentGui := 1
global TotalGuis := 5
global guiOpen := false

index_TooltipX := A_ScreenWidth / 2 ; tooltip 1 index layer
vim_normal_TooltipX_Space := index_TooltipX - 117 ; tooltip 2 noraml layer 1
normal_TooltipX_Alt := index_TooltipX - 117 ; tooltip 9 normal layer 2
chord_TooltipX := index_TooltipX ; tooltip 3 for display chord dict
chord_TooltipY := A_ScreenHeight - 34  ; Y coordinate at the very bottom edge of the screen
; A_CaretX-50, A_CaretY-50 ; tooltip 3 for display chord dict
number_TooltipX := index_TooltipX + 100 ; tooltip 4 number layer
symbol_TooltipX := index_TooltipX + 100 ; tooltip 5 symbol layer
numpad_symbol_TooltipX := index_TooltipX + 100 ; tooltip 6 numpad symbol layer
numpad_number_TooltipX := index_TooltipX + 100 ; tooltip 7 numpad number layer
; MouseGetPos, x, y tooltip 8 for rbutton copy message
del_yank_change_visual_inside_NormalMode_TooltipX := index_TooltipX - 225 ; tooltip for 10 delete, yank, change, visual mode operation

SetBatchLines, -1
DetectHiddenWindows, On

; Initialize the variable to track if VS Code is active
global IsVSCodeActive := False

; Set up a timer to check the active window every 1000 milliseconds (1 second)
SetTimer, CheckActiveWindow, 500

CheckActiveWindow:
	; Get the title of the currently active window
    WinGetActiveTitle, activeTitle

    ; Check if the active window is Visual Studio Code
    if InStr(activeTitle, "Visual Studio Code")
    {
        if !IsVSCodeActive
        {
            IsVSCodeActive := True
			if CHECK_IS_ON_VIM_NORMAL_SPACE_MODE  ; Check if the mode is enabled
				Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active and mode is enabled

			else if CHECK_IS_ON_VIM_VISUAL_SPACE_MODE
				Gosub, Vim_VisualLabel
		}
    }
	else
    {
        if IsVSCodeActive
        {
            IsVSCodeActive := False

			ToolTip,,,,2
			ToolTip,,,,4
			ToolTip,,,,5
			ToolTip,,,,10
			;ToolTip,,,,9

			VIM_NORMAL_SPACE_MODE := false
			VISUAL_MODE := false
			SYMBOL_MODE := false
			NUMBER_MODE := false


			;guiOpen := false
			;CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := true
			INSERT_MODE := true

			if TOGGLE {
				INSERT_MODE_II := true

				ToolTip, Index, % index_TooltipX, 0, 1
			}
			return


        }
    }
Return

/*
s   ----------------------------------------------
   ----------------------------------------------
   -------------Basic letter typing--------------
   ----------------------------------------------
   ----------------------------------------------
*/

#If INSERT_MODE ; Start of INSERT_MODE

; Detect if d is pressed and released without combination
$d::
    KeyWait, d, T0.1  ; Wait to see if the d key is held down for 300ms/100ms
    if ErrorLevel
        return  ; If d is held down, do nothing
    KeyWait, d  ; Wait for the d key to be released
    return

$d Up::
    ; Check if d is pressed alone
    if (A_PriorKey != "d")
        return  ; If the prior key wasn't d alone, do nothing

    ; TOGGLE the INSERT_MODE_II state
    INSERT_MODE_II := !INSERT_MODE_II
    if INSERT_MODE_II {
        TOGGLE := true
        ToolTip, Index, % index_TooltipX, 0, 1
    } else {
        TOGGLE := false
        ToolTip,,,, 1
    }
return

; Hotkeys for d & other N key combinations
~d & s::Send {Up}
~d & f::Send {Down}
~d & g::AltTab
~d & v::Send {Right}
~d & x::Send {Left}
~d & r::return
d & Space::
	Gosub, Gui1Setup
return

	#If INSERT_MODE_II ; start of INSERT_MODE_II
	;fn row
	;*Esc::
	*1::
    if GetKeyState("CapsLock", "T")  ; Check if CapsLock is on
        SetCapsLockState, Off  ; Turn CapsLock off
    else
        SetCapsLockState, On   ; Turn CapsLock on
	return
	*2::send {Tab}
	*3::
		SetKeyDelay -1
		Send {Backspace}
		SetKeyDelay -1
		Gosub, BackspaceLabel
	return
	*4::SendInput, % (GetKeyState("Shift", "P") ? "X" : indexMode("x"))
	*5::return

	;top row
	*q::SendInput, % (GetKeyState("Shift", "P") ? "Z" : indexMode("z"))
	*w::SendInput, % (GetKeyState("Shift", "P") ? "B" : indexMode("b"))
	*e::
		Gosub, EnterLabel
	return
	*r::SendInput, % (GetKeyState("Shift", "P") ? "G" : indexMode("g"))
	*t::SendInput, % (GetKeyState("Shift", "P") ? "J" : indexMode("j"))

	;home row
    *a::SendInput, % (GetKeyState("Shift", "P") ? "U" : indexMode("u"))
    *s::SendInput, % (GetKeyState("Shift", "P") ? "O" : indexMode("o"))
    *f::SendInput, % (GetKeyState("Shift", "P") ? "R" : indexMode("r"))
    *g::SendInput, % (GetKeyState("Shift", "P") ? "C" : indexMode("c"))

	;bottom row
	;*LShift::Tab
	*z::SendInput, % (GetKeyState("Shift", "P") ? "M" : indexMode("m"))
	*x::SendInput, % (GetKeyState("Shift", "P") ? "Y" : indexMode("y"))
	*c::SendInput, % (GetKeyState("Shift", "P") ? "V" : indexMode("v"))
	*v::SendInput, % (GetKeyState("Shift", "P") ? "F" : indexMode("f"))
	*b::SendInput, % (GetKeyState("Shift", "P") ? "P" : indexMode("p"))

	;fn row
	~Space & 1::return
	~Space & 2::return
	~Space & 3::return
	~Space & 4::return
	~Space & 5::return
	;top row
	~Space & w::Send, 2
	~Space & e::Send, 3
	~Space & r::Send, 4
	~Space & t::return

/*
[2] [3] [4]
[1] [0] [5] [9]
[6] [7] [8]
*/

	;home row
    ~Space & a::return
	~Space & s::Send, 1
	~Space & d::Send, 0
	~Space & d Up::
		INSERT_MODE_II := true

        ToolTip, Index, % index_TooltipX, 0, 1
	return
	~Space & f::Send, 5
	~Space & g::Send, 9
	;bottom row
	~Space & z::return
	~Space & x::Send, 6
	~Space & c::Send, 7
	~Space & v::Send, 8
	~Space & b::return

	#If ;end of INSERT_MODE_II
	return

;fn row
*1::
    if GetKeyState("CapsLock", "T")  ; Check if CapsLock is on
        SetCapsLockState, Off  ; Turn CapsLock off
    else
        SetCapsLockState, On   ; Turn CapsLock on
return

*2::send {Tab}

*3::
	Gosub, EnterLabel
return

*4::SendInput, % (GetKeyState("Shift", "P") ? "X" : indexMode("x"))
*5::return

;top row
*q::indexMode("q")
*w::indexMode("h")
*e::indexMode("t")
*r::indexMode("i")
*t::indexMode("p")

;home row
*a::indexMode("s")
*s::indexMode("e")
*f::indexMode("a")
*g::indexMode("w")

;bottom row
*z::indexMode("n")
*x::indexMode("l")
*c::
		SetKeyDelay -1
		Send {Backspace}
		SetKeyDelay -1
		Gosub, BackspaceLabel
return
*v::indexMode("d")
*b::indexMode("k")

#If ;end of INSERT_MODE
return

/*
   ----------------------------------------------
   ----------------------------------------------
   ------------Other modifier key----------------
   ----------------------------------------------
   ----------------------------------------------
*/

/*
; Declare global variables
global CtrlIsPressed := false
global ShiftIsPressed := false

; Ctrl key behavior
*Ctrl::
    if (CtrlIsPressed) {
        Send, {Ctrl up}  ; Release the Ctrl key if it's already "pressed"
        CtrlIsPressed := false
    } else {
        Send, {Ctrl down}  ; Hold down the Ctrl key
        CtrlIsPressed := true
        SetTimer, ReleaseCtrl, -5000  ; Release Ctrl key after 5 seconds if no other key is pressed
    }
return

; Shift key behavior
*Shift::
    if (ShiftIsPressed) {
        Send, {Shift up}  ; Release the Shift key if it's already "pressed"
        ShiftIsPressed := false
    } else {
        Send, {Shift down}  ; Hold down the Shift key
        ShiftIsPressed := true
        SetTimer, ReleaseShift, -5000  ; Release Shift key after 5 seconds if no other key is pressed
    }
return

; Release Ctrl when another key is pressed
ReleaseCtrl:
    if (CtrlIsPressed) {
        Send, {Ctrl up}
        CtrlIsPressed := false
    }
return

; Release Shift when another key is pressed
ReleaseShift:
    if (ShiftIsPressed) {
        Send, {Shift up}
        ShiftIsPressed := false
    }
return
*/


LShift & d::
LCtrl & d::

    ; TOGGLE the INSERT_MODE_II state
    INSERT_MODE_II := !INSERT_MODE_II
    if INSERT_MODE_II {
        TOGGLE := true
        ToolTip, Index, % index_TooltipX, 0, 1
    } else {
        TOGGLE := false
        ToolTip,,,, 1
	}
return

LCtrl & a::Send, ^x
LCtrl & s::Send, ^z
LCtrl & z::Send, ^c

LCtrl & x::Send, ^v

LWin::Alt
LCtrl & Alt::Reload	; Hotkey to reload the script
LCtrl & Space::Suspend ; Hotkey to suspend the script

Alt::
	if VIM_NORMAL_SPACE_MODE
		Send, i

	gosub, NormalLabelAlt
return

Tab::
	if VIM_NORMAL_SPACE_MODE
		Send, i

	gosub, NumberLebelTab
return

CapsLock::
	if VIM_NORMAL_SPACE_MODE
		Send, i

	gosub, SymbolLebelCapsLock
return



/*
;_--------------------
#Include Chrome.ahk  ; Include Chrome.ahk library

; Start Chrome and attach to the remote debugging port
chrome := new Chrome()
page := chrome.GetPage()

$space::
    if WinActive("ahk_class Chrome_WidgetWin_1 ahk_exe chrome.exe") {
        url := page.Evaluate("window.location.href").Value  ; Get the URL of the active tab
        if InStr(url, "youtube.com") {
            Send, {Space}
        }
    }
return
*/
;_-------=_-----------
Space::
if LongPress(200) {  ; Check if Space key is held down for more than 200ms

	if WinActive("ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe") {
		Send, {Esc}
		Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active
    }
} else {
		SetKeyDelay -1
		Send {space} ; Action for short press
		SetKeyDelay -1

		SearchString := ""
		ToolTip,, % chord_TooltipX, % chord_TooltipY, 3
		;ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000
	}
return

/*
    ; Wait for any character input from the user
    Input, SingleChar, L1  ; Waits for a single character input
    if (CHECK_REPLACE_CHAR && ErrorLevel != Timeout)
    {
        CHECK_REPLACE_CHAR := false
		Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active
    }
return
*/

/*
   ----------------------------------------------
   ----------------------------------------------
   --------------Space with any key--------------
   ----------------------------------------------
   ----------------------------------------------
*/

;fn row
~Space & 1::return
~Space & 2::return
~Space & 3::return
~Space & 4::return
~Space & 5::return
;top row
~Space & w::tapMode("w","/","\") ; two key hotkey short/long
~Space & e::tapMode("e","-","_") ; two key hotkey short/long
~Space & r::tapMode("r","=","+") ; two key hotkey short/long
~Space & t::tapMode("t","&","$") ; two key hotkey short/long
;home row
~Space & a::tapMode("a","!","%") ; two key hotkey short/long
~Space & s::tapMode("s","`'","""") ; two key hotkey short/long

~Space & d::tapMode("d",";",":") ; two key hotkey short/long
~Space & d Up::
	INSERT_MODE_II := false

	ToolTip,,,, 1
return

~Space & f::tapMode("f",".",",") ; two key hotkey short/long
~Space & g::tapMode("g","*","?") ; two key hotkey short/long
;bottom row
~Space & z::tapMode("z","<",">") ; two key hotkey short/long
~Space & x::tapMode("x","[","]") ; two key hotkey short/long
~Space & c::tapMode("c","(",")") ; two key hotkey
~Space & v::tapMode("v","{","}") ; two key hotkey
~Space & b::tapMode("b","`#","@") ; two key hotkey short/long


/*
   --------------------------------------------------
   --------------------------------------------------
   ----long press Space to active normal layer 1-----
   --------------------------------------------------
   --------------------------------------------------
*/

Vim_NormalLabelSpace:
if !VIM_NORMAL_SPACE_MODE {
	CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := true

	VIM_NORMAL_SPACE_MODE := true
	VSCodeTabSwitchWhileInsetMode := false
	NORMAL_ALT_MODE := false
	;guiOpen := false
	SYMBOL_MODE := false
	NUMBER_MODE := false
	INSERT_MODE := false
    INSERT_MODE_II := false

	ToolTip,,,,4
	ToolTip,,,,5
	ToolTip,,,,9
	ToolTip,Normal, % vim_normal_TooltipX_Space, 0, 2
	}
Return

if VSCodeTabSwitchWhileInsetMode {

	VSCodeTabSwitchWhileInsetMode := false
	CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
	VIM_NORMAL_SPACE_MODE := false
	Send, {Esc}
	Send, a ; long keyPress to go to the next char where the curser point and enter insert mode

	SYMBOL_MODE := false
	NUMBER_MODE := false
	INSERT_MODE := true

	if TOGGLE {
		INSERT_MODE_II := true

		ToolTip, Index, % index_TooltipX, 0, 1
	}
}
return


#If VIM_NORMAL_SPACE_MODE

; Detect mouse click and drag (selection)
~LButton::
    MouseGetPos, x1, y1
    KeyWait, LButton, D  ; Wait for left mouse button down
    KeyWait, LButton, U  ; Wait for left mouse button up
    MouseGetPos, x2, y2

    ; Check if the mouse was dragged (i.e., x1 != x2 or y1 != y2)
    if (x1 != x2 or y1 != y2) {
		Sleep, 100
        ; Simulate pressing 'v' to enter visual mode in Vim
		char_visual := true
		gosub, Vim_VisualLabel
    }
return

	;$Tab::Send, r
/*
	$CapsLock::
		Send, r

        ; Define a hotkey for the replacement logic
        ;Send r ; Send the 'r' key to Vim to enter replace mode
    	; Switch to the insert layer for letter typing
		CHECK_REPLACE_CHAR := true
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
		VIM_NORMAL_SPACE_MODE := false
		SYMBOL_MODE := false
		NUMBER_MODE := false
		INSERT_MODE := true

		if TOGGLE {
			INSERT_MODE_II := true

			ToolTip, Index, % index_TooltipX, 0, 1
		}
	return
*/
	CapsLock & q::
		Send, ^{Tab}
		Send, {Esc}
		Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active and mode is enabled
	return

	;fn row
	;$1::return
	$2::
	if LongPress(200)
		Send, gg ;go to the first line of the document
	Else
		Send, {^} ;jump to the first non-blank character of the line
	return
	$3::
	if LongPress(200)
		Send, {Enter}
	Else
		Send, {Backspace}
	return
	$4::
	if LongPress(200)
		Send, G ;go to the last line of the document
	Else
		Send, $ ;jump to the end of the line
	return
	;$5::return

    ; Top row remapping
    $q::Send, >>  ;indent (move right) line one shiftwidth
    $w::Gosub, DeleteLabel
    $e::Gosub, YankLabel
    $r::Gosub, ChangeLabel
    $t::Send, p ;put (paste) the clipboard after cursor

	; home row
	$a::Send {Left} ;h - move cursor left
	$s::Send {Up} ;k - move cursor up
	$f::Send {Right} ;l - move cursor right
	$d::Send {Down} ;j - move cursor down

	$g::
		g := Morse(200)
		If (g = "00") {
		Send, {Alt Down}
		Send, {Tab}
		Send, {Alt Up}
		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,5

		;guiOpen := false
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := true
		VIM_NORMAL_SPACE_MODE := false
		SYMBOL_MODE := false
		NUMBER_MODE := false
		INSERT_MODE := true

		if TOGGLE {
			INSERT_MODE_II := true

			ToolTip, Index, % index_TooltipX, 0, 1
		}
	}
	Else If (g = "0") {
		char_visual := true

		Send, v
		gosub, Vim_VisualLabel
	}
	Else If (g = "1") {
		 block_visual := true

		Send, ^v
		gosub, Vim_VisualLabel
	}
	Return

	+s:: ; shift
		 line_visual := true

		Send, V
		gosub, Vim_VisualLabel
	return
/*
	^s:: ; ctrl
		 block_visual := true

		Send, ^v
		gosub, Vim_VisualLabel
	return
    */

    ; Bottom row remapping
    $z::Send, b ;jump backwards to the start of a word
    $x::Send, {WheelUp}
    $c::Send, {WheelDown}
    $v::Send, w ;jump forwards to the start of a worddd

    $b::
		keyPress := Morse(200)
		If (keyPress = "00")
			Send, ^r ; short keyPress to redo
		else If (keyPress = "0")
			Send, u ; short keyPress to undo
	return

	;d & g::Send, !{Tab}
	d & g Up::

		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,5

		;guiOpen := false
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := true
		VIM_NORMAL_SPACE_MODE := false
		SYMBOL_MODE := false
		NUMBER_MODE := false
		INSERT_MODE := true

		if TOGGLE {
			INSERT_MODE_II := true

			ToolTip, Index, % index_TooltipX, 0, 1
		}
	return

	; Define the hotkey to show or destroy the GUI
	$Space::
	ToolTip,,,,2
	ToolTip,,,,4
	ToolTip,,,,5

	keyPress := Morse(200)
	If (keyPress = "00")
		Send, o  ; double short keyPress to go next line and enter insert mode
	else If (keyPress = "1")
		Send, i ; short keyPress to go to the prev char where the curser point and enter insert mode
	else If (keyPress = "0")
		Send, a ; long keyPress to go to the next char where the curser point and enter insert mode

	CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
	VIM_NORMAL_SPACE_MODE := false
	SYMBOL_MODE := false
	NUMBER_MODE := false
	INSERT_MODE := true

	if TOGGLE {
		INSERT_MODE_II := true

		ToolTip, Index, % index_TooltipX, 0, 1
	}
	return
#If
return

/*
   --------------------------------------------------
   --------------------------------------------------
   -----------visual layer inside normal-------------
   --------------------------------------------------
   --------------------------------------------------
*/

Vim_VisualLabel:
if !VISUAL_MODE {

	VISUAL_MODE := true
	CHECK_IS_ON_VIM_VISUAL_SPACE_MODE := true

	;guiOpen := false
	VIM_NORMAL_SPACE_MODE := false
	CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
	SYMBOL_MODE := false
	NUMBER_MODE := false
	INSERT_MODE := false
    INSERT_MODE_II := false

	ToolTip,,,,2
	ToolTip,,,,4
	ToolTip,,,,5

	if char_visual
		ToolTip, VISUAL, % del_yank_change_visual_inside_NormalMode_TooltipX, 0, 10
	Else if line_visual
		ToolTip, VISUAL LINE, % del_yank_change_visual_inside_NormalMode_TooltipX, 0, 10
	Else if block_visual
		ToolTip, VISUAL BLOCK, % del_yank_change_visual_inside_NormalMode_TooltipX, 0, 10

}
return

#If VISUAL_MODE

	~LButton::
	~RButton::
		; If you click the left or right mouse button
		Send, {Esc}  ; Send the Esc key to exit Visual mode and return to Normal mode

		ToolTip,,,,10
		VISUAL_MODE := false
		char_visual := false
		line_visual := false
	    block_visual := false

		CHECK_IS_ON_VIM_VISUAL_SPACE_MODE := false
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := true

		Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active
	Return

	$Alt::return
	$Tab::return
	$CapsLock::return
	$Down::return
	$Shift::return
	$Ctrl::return
	$Right::return

	;fn row
	;$1::return
	$2::
	if LongPress(200)
		Send, gg ;go to the first line of the document
	Else
		Send, {^} ;jump to the first non-blank character of the line
	return

	$3::return

	$4::
	if LongPress(200)
		Send, G ;go to the last line of the document
	Else
		Send, $ ;jump to the end of the line
	return
	;$5::return

	; Top row remapping
	$q::return
	$w::
		Send, d

		ToolTip,,,,10
		VISUAL_MODE := false
		char_visual := false
		line_visual := false
	    block_visual := false

		CHECK_IS_ON_VIM_VISUAL_SPACE_MODE := false
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := true

		Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active
	return

	$e::
		Send, y

		ToolTip,,,,10
		VISUAL_MODE := false
		char_visual := false
		line_visual := false
	    block_visual := false


		CHECK_IS_ON_VIM_VISUAL_SPACE_MODE := false
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := true

		Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active
	return

	$r::
		Send, c

		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,5
		ToolTip,,,,10

		char_visual := false
		line_visual := false
	    block_visual := false

		VISUAL_MODE := false
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
		CHECK_IS_ON_VIM_VISUAL_SPACE_MODE := false
		VIM_NORMAL_SPACE_MODE := false
		SYMBOL_MODE := false
		NUMBER_MODE := false
		INSERT_MODE := true

		if TOGGLE {
			INSERT_MODE_II := true

			ToolTip, Index, % index_TooltipX, 0, 1
		}

	return

	$t::
		Send, p ;put (paste) the clipboard after cursor
		ToolTip,,,,10
		VISUAL_MODE := false
		char_visual := false
		line_visual := false
	    block_visual := false


		CHECK_IS_ON_VIM_VISUAL_SPACE_MODE := false
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := true

		Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active
	return

	; home row
	$a::Send {Left} ;h - move cursor left
	$s::Send {Up} ;k - move cursor up
	$f::Send {Right} ;l - move cursor right
	$d::Send {Down} ;j - move cursor down

	$g::
		Send, {Esc}
		ToolTip,,,,10
		VISUAL_MODE := false
		CHECK_IS_ON_VIM_VISUAL_SPACE_MODE := false
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := true

		char_visual := false
		line_visual := false
	    block_visual := false

		Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active
	Return

    ; Bottom row remapping
    $z::Send, b ;jump backwards to the start of a word
	;$^z::Send, ^r ;redo
    $x::Send, {WheelUp}
    $c::Send, {WheelDown}
    $v::Send, w ;jump forwards to the start of a word
    $b::return

	; Define the hotkey to show or destroy the GUI
	$Space::
		Send, {Esc}

		g := Morse(200)
		If (g = "00")
			Send, o  ; double short click to go next line and enter insert mode
		else If (g = "1")
			Send, a ; long click to go to the next char where the curser point and enter insert mode
		else If (g = "0")
			Send, i ; short click to go to the prev char where the curser point and enter insert mode

		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,5
		ToolTip,,,,10

		;guiOpen := false
		VISUAL_MODE := false
		char_visual := false
		line_visual := false
	    block_visual := false

		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
		CHECK_IS_ON_VIM_VISUAL_SPACE_MODE := false
		VIM_NORMAL_SPACE_MODE := false
		SYMBOL_MODE := false
		NUMBER_MODE := false
		INSERT_MODE := true

		if TOGGLE {
			INSERT_MODE_II := true

			ToolTip, Index, % index_TooltipX, 0, 1
		}
	return

	;d & g::Send, !{Tab}
	d & g Up::

		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,5
		ToolTip,,,,10

		VISUAL_MODE := false
		/*
		char_visual := false
		line_visual := false
	    block_visual := false
		*/
		CHECK_IS_ON_VIM_VISUAL_SPACE_MODE := true
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
		VIM_NORMAL_SPACE_MODE := false
		SYMBOL_MODE := false
		NUMBER_MODE := false
		INSERT_MODE := true

		if TOGGLE {
			INSERT_MODE_II := true

			ToolTip, Index, % index_TooltipX, 0, 1
		}
	return

	#If
return


/*
   --------------------------------------------------
   --------------------------------------------------
   ----------------delete/cut------------------------
   --------------------------------------------------
   --------------------------------------------------
*/

DeleteLabel:
if !DELETE_MODE {
	DELETE_MODE := true
	VIM_NORMAL_SPACE_MODE := false

	ToolTip, DELETE, % del_yank_change_visual_inside_NormalMode_TooltipX, 0, 10
	}
	return

	#If DELETE_MODE

		$Alt::return
		$Tab::return
		$CapsLock::return
		$Down::return
		$Shift::return
		$Ctrl::return
		$Right::return

		; fn row
		$1::return
		$2::return
		$3::return
		$4::return
		$5::return

		; top row
		$q::return
		$w::
			Send, dd ;delete (cut) a line
			DELETE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
		$e::
			Send, x ;delete (cut) a char
			DELETE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
		$r::return
		$t::return

		; home row
		$a::
			Send, dw ;delete (cut) the characters of the word from the cursor position to the start of the next word
			DELETE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
		$s::
			Send, d0 ;delete/cut from the cursor to the beginning of the line/ d0
			DELETE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
		$d::
			Send, d$ ;delete (cut) to the end of the line
			DELETE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
		$f::
			Send, diw ;delete (cut) word under the cursor
			DELETE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
		$g::
			Send, daw ;delete (cut) word under the cursor and the space after or before it
			DELETE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return

		; Bottom row remapping
		$z::return
		$x::return
		$c::
			Send, dgg ;delete/cut from the cursor to the beginning of the file
			DELETE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
		$v::
			Send, dG ; delete/cut from the cursor to the end of the file/
			DELETE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return

		$b::return
		$Space::
			DELETE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
	#If
return

/*
   --------------------------------------------------
   --------------------------------------------------
   -----------------yank/copy------------------------
   --------------------------------------------------
   --------------------------------------------------
*/

YankLabel:
if !YANK_MODE {
	YANK_MODE := true
	VIM_NORMAL_SPACE_MODE := false

	ToolTip, YANK, % del_yank_change_visual_inside_NormalMode_TooltipX, 0, 10
	}
	return

	#If YANK_MODE

		$Alt::return
		$Tab::return
		$CapsLock::return
		$Down::return
		$Shift::return
		$Ctrl::return
		$Right::return

		; fn row
		$1::return
		$2::return
		$3::return
		$4::return
		$5::return

		; top row
		$q::return
		$w::return
		$e::
			Send, yy ;Select and yank/copy a single line
			YANK_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
		$r::
			Send, yl ;Select and yank/copy a single char
			YANK_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
		$t::return

		; home row
		$a::
			Send, yw ;yank/copy from the cursor to the beginning of the next word
			YANK_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return

		$s::
			Send, y0 ;yank/copy from the cursor to the beginning of the line
			YANK_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return

		$d::
			Send, y$ ;yank/copy from the cursor to the end of the line
			YANK_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return

		$f::
			Send, yiw ;yank/copy the entire word under the cursor. 'iw' focuses on the word itself, ignoring spaces or punctuation around it.
			YANK_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return

		$g::
			Send, yaw ; yank/copy the entire word under the cursor. "aw" includes spaces or punctuation around the word, making it more inclusive in its selection.
			YANK_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return

		; Bottom row remapping
		$z::return
		$x::return
		$c::
			Send, ygg ;yank/copy from the cursor to the beginning of the file
			YANK_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return

		$v::
			Send, yG ;yank/copy from the cursor to the end of the file
			YANK_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
		$b::return
		$Space::
			YANK_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
	#If
return

/*
   --------------------------------------------------
   --------------------------------------------------
   ----------------change/del------------------------
   --------------------------------------------------
   --------------------------------------------------
*/

changeToindex:
		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,5

		;guiOpen := false
		VIM_NORMAL_SPACE_MODE := false
		SYMBOL_MODE := false
		NUMBER_MODE := false
		INSERT_MODE := true

		if TOGGLE {
			INSERT_MODE_II := true

			ToolTip, Index, % index_TooltipX, 0, 1
		}
		return
return

ChangeLabel:
if !CHANGE_MODE {
	CHANGE_MODE := true
	VIM_NORMAL_SPACE_MODE := false

	ToolTip, CHANGE, % del_yank_change_visual_inside_NormalMode_TooltipX, 0, 10
	}
return

	#If CHANGE_MODE

		$Alt::return
		$Tab::return
		$CapsLock::return
		$Down::return
		$Shift::return
		$Ctrl::return
		$Right::return

		; fn row
		$1::return
		$2::return
		$3::return
		$4::return
		$5::return

		; top row
		$q::return
		$w::return
		$e::
			Send, s ;Select and change/del a single char
			CHANGE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
			Gosub, changeToindex
		return
		$r::
			Send, cc ;Select and change/del a single line
			CHANGE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
			Gosub, changeToindex
		return
		$t::return

		; home row
		$a::
			Send, cw ;change/del from the cursor to the beginning of the next word
			CHANGE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
			Gosub, changeToindex
		return

		$s::
			Send, c0 ;change/del from the cursor to the beginning of the line
			CHANGE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
			Gosub, changeToindex
		return

		$d::
			Send, c$ ;change/del from the cursor to the end of the line
			CHANGE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
			Gosub, changeToindex
		return

		$f::
			Send, ciw ;change/del the entire word under the cursor. 'iw' focuses on the word itself, ignoring spaces or punctuation around it.
			CHANGE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
			Gosub, changeToindex
		return

		$g::
			Send, caw ;change/del the entire word under the cursor. "aw" includes spaces or punctuation around the word, making it more inclusive in its selection.
			CHANGE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
			Gosub, changeToindex
		return


		; Bottom row remapping
		$z::return
		$x::return
		$c::
			Send, cgg ;change/del from the cursor to the beginning of the file
			CHANGE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
			Gosub, changeToindex
		return

		$v::
			Send, cG ;change/del from the cursor to the end of the file
			CHANGE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
			Gosub, changeToindex
		return
		$b::return
		$Space::
			CHANGE_MODE := false
			VIM_NORMAL_SPACE_MODE := true
			ToolTip,,,,10
		return
	#If
return

/*
   --------------------------------------------------
   --------------------------------------------------
   -----------------------gui------------------------
   --------------------------------------------------
   --------------------------------------------------
*/

checkGui:
	; Code to execute after the jump
	if !guiOpen {
		guiOpen := true
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
		VIM_NORMAL_SPACE_MODE := false
		SYMBOL_MODE := false
		NUMBER_MODE := false
		INSERT_MODE := false
		INSERT_MODE_II := false
	}
return

liveDisplayGui:
    ; Calculate the position for the input display GUI
    ScreenWidth := A_ScreenWidth ; 1920
    ScreenHeight := A_ScreenHeight ; 1080

	DisplayHeight := 40  ; Height of the input display box
	DisplayWidth := 67  ; Width of the input display box

	; Calculate Y position for the bottom of the screen
	DisplayY := ScreenHeight - DisplayHeight - 54  ; 20 pixels above the bottom for padding

	; Calculate X position to center the display horizontally
	DisplayX := (ScreenWidth - DisplayWidth) // 2.02

    ; Create the separate large text box for live input display
	Gui, 6:New, -Caption +AlwaysOnTop +ToolWindow +HWNDMyInputDisplay  ; Create a new GUI window for the input display

    Gui, 6:Color, White  ; Set the background color to white
    Gui, 6:Font, Bold s15, Verdana  ; Set the font size and style

	Gui, 6:Add, Text, w%DisplayWidth% h%DisplayHeight% vInputText BackgroundWhite cBlack ,....  ; Large display area

	; Position the input display GUI at the bottom of the screen
	Gui, 6:Show, x%DisplayX% y%DisplayY% w%DisplayWidth% h%DisplayHeight% NoActivate
return

; Define the remapped hotkeys for switching between GUIs
#If guiOpen

	;fn row
    $1::gosub Gui1Setup
    $2::gosub Gui2Setup
    $3::gosub Gui3Setup
    $4::gosub Gui4Setup
    $5::gosub Gui5Setup

    ; Top row remapping
    $q::return
    $w::HandleNumber(7)
    $e::HandleNumber(8)
    $r::HandleNumber(9)
    $t::return

    ; Home row remapping
	$a::HandleNumber(1)
    $s::HandleNumber(4)
    $d::HandleNumber(5)
    $f::HandleNumber(6)
    $g::HandleNumber(0)

    ; Bottom row remapping
    $z::return
    $x::HandleNumber(1)
    $c::HandleNumber(2)
    $v::HandleNumber(3)
    $b::return

    $Alt::return
    $Tab::return
    $CapsLock::return
    $Down::return
    $Shift::return
    $Ctrl::return
    $Right::return

	$space::
	Gui, 1:Destroy
	Gui, 2:Destroy
	Gui, 3:Destroy
	Gui, 4:Destroy
	Gui, 5:Destroy
	Gui, 6:Destroy

	guiOpen := false
	VIM_NORMAL_SPACE_MODE := false
	SYMBOL_MODE := false
	NUMBER_MODE := false
	INSERT_MODE := true

	if TOGGLE {
		INSERT_MODE_II := true

		ToolTip, Index, % index_TooltipX, 0, 1
	}
	return
#If


; Define the GUI setups
Gui1Setup:

	gosub, checkGui
	CurrentGui := 1

	Gui, 2:Destroy
	Gui, 3:Destroy
	Gui, 4:Destroy
	Gui, 5:Destroy

	; GUI Configuration
	Gui, 1:New, +LastFound +AlwaysOnTop -Caption +ToolWindow ; +HwndMyGui  ; Remove window borders and make GUI always on top
	Gui, 1:Color, EEAA99  ; Set the background color (which will also be the transparent color)
	WinSet, TransColor, EEAA99  ; Make the color EEAA99 transparent

	; Add transparent buttons w 150 h 120
	Gui, 1:Add, Button, x101 y1 w140 h110 BackgroundTrans gGui1Button11Action, Volume Min
	Gui, 1:Add, Button, x101 y119 w140 h110 BackgroundTrans gGui1Button12Action, Volume Max
	Gui, 1:Add, Button, x101 y239 w140 h110 BackgroundTrans gGui1Button13Action, Volume Mute
	Gui, 1:Add, Button, x101 y359 w140 h110 BackgroundTrans gGui1Button14Action, Show Tooltip
	Gui, 1:Add, Button, x101 y479 w140 h110 BackgroundTrans gGui1Button15Action, guiOpen: %guiOpen%

	Gui, 1:Add, Button, x251 y1 w140 h110 BackgroundTrans gGui1Button16Action, Button 16
	Gui, 1:Add, Button, x251 y119 w140 h110 BackgroundTrans gGui1Button17Action, Button 17
	Gui, 1:Add, Button, x251 y239 w140 h110 BackgroundTrans gGui1Button18Action, Button 18
	Gui, 1:Add, Button, x251 y359 w140 h110 BackgroundTrans gGui1Button19Action, Button 19
	Gui, 1:Add, Button, x251 y479 w140 h110 BackgroundTrans gGui1Button20Action, Button 20

	Gui, 1:Add, Button, x401 y1 w140 h110 BackgroundTrans gGui1Button21Action, Button 21
	Gui, 1:Add, Button, x401 y119 w140 h110 BackgroundTrans gGui1Button22Action, Button 22
	Gui, 1:Add, Button, x401 y239 w140 h110 BackgroundTrans gGui1Button23Action, Button 23
	Gui, 1:Add, Button, x401 y359 w140 h110 BackgroundTrans gGui1Button24Action, Button 24
	Gui, 1:Add, Button, x401 y479 w140 h110 BackgroundTrans gGui1Button25Action, Button 25

	Gui, 1:Add, Button, x551 y1 w140 h110 BackgroundTrans gGui1Button26Action, Button 26
	Gui, 1:Add, Button, x551 y119 w140 h110 BackgroundTrans gGui1Button27Action, Button 27
	Gui, 1:Add, Button, x551 y239 w140 h110 BackgroundTrans gGui1Button28Action, %CurrentGui%
	Gui, 1:Add, Button, x551 y359 w140 h110 BackgroundTrans gGui1Button29Action, Button 29
	Gui, 1:Add, Button, x551 y479 w140 h110 BackgroundTrans gGui1Button30Action, Button 30

	Gui, 1:Add, Button, x701 y1 w140 h110 BackgroundTrans gGui1Button31Action, Button 31
	Gui, 1:Add, Button, x701 y119 w140 h110 BackgroundTrans gGui1Button32Action, Button 32
	Gui, 1:Add, Button, x701 y239 w140 h110 BackgroundTrans gGui1Button33Action, Button 33
	Gui, 1:Add, Button, x701 y359 w140 h110 BackgroundTrans gGui1Button34Action, Button 34
	Gui, 1:Add, Button, x701 y479 w140 h110 BackgroundTrans gGui1Button35Action, Button 35

	Gui, 1:Add, Button, x851 y1 w140 h110 BackgroundTrans gGui1Button36Action, Button 36
	Gui, 1:Add, Button, x851 y119 w140 h110 BackgroundTrans gGui1Button37Action, Button 37
	Gui, 1:Add, Button, x851 y239 w140 h110 BackgroundTrans gGui1Button38Action, Button 38
	Gui, 1:Add, Button, x851 y359 w140 h110 BackgroundTrans gGui1Button39Action, Button 39
	Gui, 1:Add, Button, x851 y479 w140 h110 BackgroundTrans gGui1Button40Action, Button 40

	Gui, 1:Add, Button, x1001 y1 w140 h110 BackgroundTrans gGui1Button41Action, Button 41
	Gui, 1:Add, Button, x1001 y119 w140 h110 BackgroundTrans gGui1Button42Action, Button 42
	Gui, 1:Add, Button, x1001 y239 w140 h110 BackgroundTrans gGui1Button43Action, Button 43
	Gui, 1:Add, Button, x1001 y359 w140 h110 BackgroundTrans gGui1Button44Action, Button 44
	Gui, 1:Add, Button, x1001 y479 w140 h110 BackgroundTrans gGui1Button45Action, Button 45

	Gui, 1:Add, Button, x1151 y239 w50 h110 BackgroundTrans gGui1Button0Action, Next

	Gui, 1:Show, w1246 h621, Control Panel  ; Display the GUI with the buttons

	gosub, liveDisplayGui
return

Gui2Setup:
	gosub, checkGui
	CurrentGui := 2

	Gui, 1:Destroy
	Gui, 3:Destroy
	Gui, 4:Destroy
	Gui, 5:Destroy

	; GUI Configuration
	Gui, 2:New, +LastFound +AlwaysOnTop -Caption +ToolWindow ; +HwndMyGui  ; Remove window borders and make GUI always on top
	Gui, 2:Color, EEAA99  ; Set the background color (which will also be the transparent color)
	WinSet, TransColor, EEAA99  ; Make the color EEAA99 transparent

	; Add transparent buttons w 150 h 120
	Gui, 2:Add, Button, x41 y239 w50 h110 BackgroundTrans gGui2Button1Action, Prev

	Gui, 2:Add, Button, x101 y1 w140 h110 BackgroundTrans , Volume Min
	Gui, 2:Add, Button, x101 y119 w140 h110 BackgroundTrans , Volume Max
	Gui, 2:Add, Button, x101 y239 w140 h110 BackgroundTrans , Volume Mute
	Gui, 2:Add, Button, x101 y359 w140 h110 BackgroundTrans , Show Tooltip
	Gui, 2:Add, Button, x101 y479 w140 h110 BackgroundTrans , Button 15

	Gui, 2:Add, Button, x251 y1 w140 h110 BackgroundTrans , Button 16
	Gui, 2:Add, Button, x251 y119 w140 h110 BackgroundTrans , Button 17
	Gui, 2:Add, Button, x251 y239 w140 h110 BackgroundTrans , Button 18
	Gui, 2:Add, Button, x251 y359 w140 h110 BackgroundTrans , Button 19
	Gui, 2:Add, Button, x251 y479 w140 h110 BackgroundTrans , Button 20

	Gui, 2:Add, Button, x401 y1 w140 h110 BackgroundTrans , Button 21
	Gui, 2:Add, Button, x401 y119 w140 h110 BackgroundTrans , Button 22
	Gui, 2:Add, Button, x401 y239 w140 h110 BackgroundTrans , Button 23
	Gui, 2:Add, Button, x401 y359 w140 h110 BackgroundTrans , Button 24
	Gui, 2:Add, Button, x401 y479 w140 h110 BackgroundTrans , Button 25

	Gui, 2:Add, Button, x551 y1 w140 h110 BackgroundTrans , Button 26
	Gui, 2:Add, Button, x551 y119 w140 h110 BackgroundTrans , Button 27
	Gui, 2:Add, Button, x551 y239 w140 h110 BackgroundTrans gGui2Button28Action, %CurrentGui%
	Gui, 2:Add, Button, x551 y359 w140 h110 BackgroundTrans , Button 29
	Gui, 2:Add, Button, x551 y479 w140 h110 BackgroundTrans , Button 30

	Gui, 2:Add, Button, x701 y1 w140 h110 BackgroundTrans , Button 31
	Gui, 2:Add, Button, x701 y119 w140 h110 BackgroundTrans , Button 32
	Gui, 2:Add, Button, x701 y239 w140 h110 BackgroundTrans , Button 33
	Gui, 2:Add, Button, x701 y359 w140 h110 BackgroundTrans , Button 34
	Gui, 2:Add, Button, x701 y479 w140 h110 BackgroundTrans , Button 35

	Gui, 2:Add, Button, x851 y1 w140 h110 BackgroundTrans , Button 36
	Gui, 2:Add, Button, x851 y119 w140 h110 BackgroundTrans , Button 37
	Gui, 2:Add, Button, x851 y239 w140 h110 BackgroundTrans , Button 38
	Gui, 2:Add, Button, x851 y359 w140 h110 BackgroundTrans , Button 39
	Gui, 2:Add, Button, x851 y479 w140 h110 BackgroundTrans , Button 40

	Gui, 2:Add, Button, x1001 y1 w140 h110 BackgroundTrans , Button 41
	Gui, 2:Add, Button, x1001 y119 w140 h110 BackgroundTrans , Button 42
	Gui, 2:Add, Button, x1001 y239 w140 h110 BackgroundTrans , Button 43
	Gui, 2:Add, Button, x1001 y359 w140 h110 BackgroundTrans , Button 44
	Gui, 2:Add, Button, x1001 y479 w140 h110 BackgroundTrans , Button 45

	Gui, 2:Add, Button, x1151 y239 w50 h110 BackgroundTrans gGui2Button0Action, Next

	Gui, 2:Show, w1246 h621, Control Panel  ; Display the GUI with the buttons

return

Gui3Setup:

	gosub, checkGui
	CurrentGui := 3

	Gui, 1:Destroy
	Gui, 2:Destroy
	Gui, 4:Destroy
	Gui, 5:Destroy

    Gui, 3:New, +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, 3:Color, EEAA99
    Gui, 3:Add, Text, x10 y10 w200 h30, %CurrentGui%
    Gui, 3:Show, w400 h300, Control Panel

    Gui, 3:Add, Button, x100 y100 w200 h50 gGoNext, Next
    Gui, 3:Add, Button, x100 y200 w200 h50 gGoBack, Prev
    ; Add more GUI 3 controls here...
return

Gui4Setup:

	gosub, checkGui
	CurrentGui := 4

	Gui, 1:Destroy
	Gui, 2:Destroy
	Gui, 3:Destroy
	Gui, 5:Destroy

    Gui, 4:New, +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, 4:Color, EEAA99
    Gui, 4:Add, Text, x10 y10 w200 h30, %CurrentGui%
    Gui, 4:Show, w400 h300, GUI 4

    Gui, 4:Add, Button, x100 y100 w200 h50 gGoNext, Next
    Gui, 4:Add, Button, x100 y200 w200 h50 gGoBack, Prev

    ; Add more GUI 4 controls here...
return

Gui5Setup:

	gosub, checkGui
	CurrentGui := 5

	Gui, 1:Destroy
	Gui, 2:Destroy
	Gui, 3:Destroy
	Gui, 4:Destroy

    Gui, 5:New, +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, 5:Color, EEAA99
    Gui, 5:Add, Text, x10 y10 w200 h30, %CurrentGui%
    Gui, 5:Show, w400 h300, Control Panel

    Gui, 5:Add, Button, x100 y200 w200 h50 gGoBack, Prev
    ; Add more GUI 5 controls here...
return


; Go to the next GUI
GoNext:
    if (CurrentGui < 5) {
		CurrentGui += 1

		Loop, %TotalGuis% {
			Gui, %A_Index%:Destroy
		}

		Gosub, Gui%CurrentGui%Setup  ; Call the setup for the specific GUI
    }
return

; Go to the previous GUI
GoBack:
    if (CurrentGui > 1) {
		CurrentGui -= 1

		Loop, %TotalGuis% {
			Gui, %A_Index%:Destroy
		}

		Gosub, Gui%CurrentGui%Setup  ; Call the setup for the specific GUI
    }
return


; Handle number input and update live display
HandleNumber(Number) {
    global guiOpen, NumberInput, LastInputTime
    if (guiOpen) {  ; Only process input when GUI is open
        ; Only allow input if the length is less than 2 digits
        if (StrLen(NumberInput) < 2) {
            NumberInput .= Number  ; Append the new number to the input
            LastInputTime := A_TickCount
		}
            GuiControl, 6:, InputText, %NumberInput%  ; Update the live input display
            SetTimer, ProcessInput, -500  ; Start a timer to wait for 500ms

    }
}
return

ProcessInput:
{
    global guiOpen, NumberInput, LastInputTime
    if (guiOpen && (A_TickCount - LastInputTime >= 500)) {
        ; Check if the input is a valid button number
        if (IsButtonNumber(NumberInput)) {
				if (CurrentGui = 1)
					Gosub, Gui1Button%NumberInput%Action  ; Trigger corresponding button action
				else if (CurrentGui = 2)
					Gosub, Gui2Button%NumberInput%Action  ; Trigger corresponding button action
        } else {
            ; If not a valid button number, reset the input
            NumberInput := ""
        }

        ; Reset the display and input fields
        GuiControl, 6:, InputText, ...  ; Clear the live input display
        NumberInput := ""  ; Reset the input after handling
    }
}
return

IsButtonNumber(Number) {
    ; Return true only for numbers between 11 and 45
    return (Number >= 11 && Number <= 45) || (Number = 0) || (Number = 1)
}


; Actions for each button gui 1

Gui1Button11Action:
    ; Set volume to 0 (mute)
	SoundSet, 0  ; Mute the system volume
	Tooltip, Volume Min
	Sleep, 1000
    Tooltip
return

Gui1Button12Action:
    ; Set volume to 100 (maximum)
    SoundSet, 80, Master
	Tooltip, Volume Maximum
    Sleep, 1000
    Tooltip
return

Gui1Button13Action:
    SoundSet, +0, , mute  ; This toggles mute/unmute for the default audio device
	Tooltip, Vol Mute
    Sleep, 1000
    Tooltip
return

Gui1Button14Action:
    Tooltip, Hello! This is a tooltip 14.
    Sleep, 1000
    Tooltip
return

Gui1Button15Action:
	Tooltip, You clicked Button 15
    Sleep, 1000
	Tooltip
return

Gui1Button16Action:
    Tooltip, You clicked Button 16
    Sleep, 1000
    Tooltip
return

Gui1Button17Action:
    Tooltip, You clicked Button 17
    Sleep, 1000
    Tooltip
return

Gui1Button18Action:
    Tooltip, You clicked Button 18
    Sleep, 1000
    Tooltip
return

Gui1Button19Action:
    Tooltip, You clicked Button 19
    Sleep, 1000
    Tooltip
return

Gui1Button20Action:
    Tooltip, You clicked Button 20
    Sleep, 1000
    Tooltip
return

Gui1Button21Action:
    Tooltip, You clicked Button 21
    Sleep, 1000
    Tooltip
return

Gui1Button22Action:
    Tooltip, You clicked Button 22
    Sleep, 1000
    Tooltip
return

Gui1Button23Action:
    Tooltip, You clicked Button 23
    Sleep, 1000
    Tooltip
return

Gui1Button24Action:
    Tooltip, You clicked Button 24
    Sleep, 1000
    Tooltip
return

Gui1Button25Action:
    Tooltip, You clicked Button 25
    Sleep, 1000
    Tooltip
return

Gui1Button26Action:
    Tooltip, You clicked Button 26
    Sleep, 1000
    Tooltip
return

Gui1Button27Action:
    Tooltip, You clicked Button 27
    Sleep, 1000
    Tooltip
return

Gui1Button28Action:
    Tooltip, You clicked Button 28 with %CurrentGui%
    Sleep, 1000
    Tooltip
return


Gui1Button29Action:
    Tooltip, You clicked Button 29
    Sleep, 1000
    Tooltip
return

Gui1Button30Action:
    Tooltip, You clicked Button 30
    Sleep, 1000
    Tooltip
return

Gui1Button31Action:
    Tooltip, You clicked Button 31
    Sleep, 1000
    Tooltip
return

Gui1Button32Action:
    Tooltip, You clicked Button 32
    Sleep, 1000
    Tooltip
return

Gui1Button33Action:
    Tooltip, You clicked Button 33
    Sleep, 1000
    Tooltip
return

Gui1Button34Action:
    Tooltip, You clicked Button 34
    Sleep, 1000
    Tooltip
return

Gui1Button35Action:
    Tooltip, You clicked Button 35
    Sleep, 1000
    Tooltip
return

Gui1Button36Action:
    Tooltip, You clicked Button 36
    Sleep, 1000
    Tooltip
return

Gui1Button37Action:
    Tooltip, You clicked Button 37
    Sleep, 1000
    Tooltip
return

Gui1Button38Action:
    Tooltip, You clicked Button 38
    Sleep, 1000
    Tooltip
return

Gui1Button39Action:
    Tooltip, You clicked Button 39
    Sleep, 1000
    Tooltip
return

Gui1Button40Action:
    Tooltip, You clicked Button 40
    Sleep, 1000
    Tooltip
return

Gui1Button41Action:
    Tooltip, You clicked Button 41
    Sleep, 1000
    Tooltip
return

Gui1Button42Action:
    Tooltip, You clicked Button 42
    Sleep, 1000
    Tooltip
return

Gui1Button43Action:
    Tooltip, You clicked Button 43
    Sleep, 1000
    Tooltip
return

Gui1Button44Action:
    Tooltip, You clicked Button 44
    Sleep, 1000
    Tooltip
return

Gui1Button45Action:
    Tooltip, You clicked Button 45
    Sleep, 1000
    Tooltip
return

Gui1Button1Action:
return

Gui1Button0Action:
	Gosub, Gui2Setup
return

; --------------------------------------------------------------------------------------

; Actions for each button gui 2
Gui2Button28Action:
    Tooltip, You clicked Button 28 with %CurrentGui%
    Sleep, 1000
    Tooltip
return

Gui2Button0Action:
	Gosub, Gui3Setup
return

Gui2Button1Action:
	Gosub, Gui1Setup
return

/*
   ----------------------------------------------
   ----------------------------------------------
   ---------------Tab Number layer---------------
   ----------------------------------------------
   ----------------------------------------------
*/

NumberLebelTab:
if !NUMBER_MODE {
	NUMBER_MODE := true
	SYMBOL_MODE := false
	VIM_NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
	;CapsLockArrow := true
	INSERT_MODE := false
	;INSERT_MODE_II := false

	ToolTip,,,,2
	ToolTip,,,,5
	ToolTip,,,,9
	ToolTip, Numpad, % number_TooltipX, 0, 4
}
Return

#If NUMBER_MODE
	;fn/num row
	$1::return
	$2::return
	$3::return
	$4::return
	$5::return

	;top row
	$q::return
	$w::Send 7
	$e::send 8
	$r::send 9
	$t::return

	;home row
	$a::return
	$s::send 4
	$d::send 5
	$f::send 6
	$g::send 0

	;bottom row
	$z::return
 	$x::send 1
 	$c::send 2
	$v::send 3
	$b::return

	$Tab::
	SYMBOL_MODE := false
	NUMBER_MODE := false
	VIM_NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
	INSERT_MODE := true

	if TOGGLE {
		INSERT_MODE_II := true

		ToolTip,,,,4
		ToolTip,,,,5
		ToolTip,,,,9
		ToolTip, Index, % index_TooltipX, 0, 1
	} else {
		ToolTip,,,,4
		ToolTip,,,,5
		ToolTip,,,,9
	}
	return

	$CapsLock::
	layer := 2
		SYMBOL_MODE := true
		NUMBER_MODE := false
		VIM_NORMAL_SPACE_MODE := false
		NORMAL_ALT_MODE := false
		INSERT_MODE := false
		;INSERT_MODE_II := false

		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,9
		ToolTip, Symbol, % symbol_TooltipX, 0, 5
	return
#If
return

/*
   ----------------------------------------------
   ----------------------------------------------
   -----------Capslock symbol layer--------------
   ----------------------------------------------
   ----------------------------------------------
*/

SymbolLebelCapsLock:
last := layer, layer := 3 ; Set the current layer to 3 when CapsLock is pressed

	;CapsLockArrow := true
	SYMBOL_MODE := true
	NORMAL_ALT_MODE := false
	INSERT_MODE := false
	INSERT_MODE_II := false
/*


	SYMBOL_MODE := true
	NUMBER_MODE := true
	VIM_NORMAL_SPACE_MODE := false
*/
	ToolTip,,,,2
	ToolTip,,,,4
	ToolTip,,,,9

KeyWait CapsLock ; Wait for CapsLock to be released

;layer := A_Priorkey != "CapsLock" ? last : last = 2 ? 1 : 2

if (A_PriorKey != "CapsLock") {
    layer := last
} else {
    if (last = 2) {
		layer := 1
    } else {
        layer := 2
    }
}

if (layer = 2) {

	SYMBOL_MODE := true
	NUMBER_MODE := false
	VIM_NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
	INSERT_MODE := false
	;INSERT_MODE_II := false

	ToolTip,,,,2
	ToolTip,,,,4
	ToolTip,,,,9
	ToolTip, Symbol, % symbol_TooltipX, 0, 5
} else {

	;CapsLockArrow := false
	SYMBOL_MODE := false
	NUMBER_MODE := false
	VIM_NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
	INSERT_MODE := true

	ToolTip,,,,2
	ToolTip,,,,4
	ToolTip,,,,9
	ToolTip,,,,5

	if TOGGLE {
		INSERT_MODE_II := true

		ToolTip, Index, % index_TooltipX, 0, 1
	}
	return
}


#If (layer = 2)
	;fn/num row in the keyboard
	$1::return
	$2::tapMode("","~","")
	$3::tapMode("","|","")
	$4::tapMode("","^","")
	$5::return

	;top row in the keyboard
	$q::tapMode("","``","")
	$w::tapMode("w","/","\")
	$e::tapMode("e","-","_")
	$r::tapMode("r","=","+")
	$t::tapMode("t","&","$")

	;home row in the keyboard
	$a::tapMode("a","!","%")
	$s::tapMode("s","'","""")
	$d::tapMode("d",";",":")
	$f::tapMode("f",".",",")
	$g::tapMode("g","*","?")

	;bottom row in the keyboard
	$z::tapMode("z","<",">")
	$x::tapMode("x","[","]")
	$c::tapMode("c","(",")")
	$v::tapMode("v","{","}")
	$b::tapMode("b","#","@")

	$Alt::
		layer := 1
		NORMAL_ALT_MODE := true
		VIM_NORMAL_SPACE_MODE := false
		CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
		NUMBER_MODE := false
		SYMBOL_MODE := false
		INSERT_MODE := false
		INSERT_MODE_II := false

		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,5
		ToolTip,Normal 2, % normal_TooltipX_Alt, 0, 9
	return

#If (layer = 3)
	$q::
	if WinActive("ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe") {

		Send, ^{Tab}
		if CHECK_IS_ON_VIM_NORMAL_SPACE_MODE {
			Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active

			VSCodeTabSwitchWhileInsetMode := true
		} else
			Send, {Esc}
			Send, a
    }
	return

	$w::send, {Up}
	$a::Send, {Left}
	$s::send, {Down}
	$d::Send, {Right}
#If
return

;-------------------------------------------
/*
CapsLock::
	if VIM_NORMAL_SPACE_MODE
		Send, i

	gosub, SymbolLebelCapsLock
return

#If GetKeyState("CapsLock", "P")
	ToolTip,,,,2
	ToolTip,,,,4
	ToolTip,,,,9
	ToolTip,,,,5

    $w::Send, {Up}
    $a::Send, {Left}
    $s::Send, {Down}
    $d::Send, {Right}
#If

SymbolLebelCapsLock:
if !SYMBOL_MODE {
	SYMBOL_MODE := true
	NUMBER_MODE := false
	VIM_NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
	INSERT_MODE := false
	;INSERT_MODE_II := false

	ToolTip,,,,2
	ToolTip,,,,4
	ToolTip,,,,9
	ToolTip, Symbol, % symbol_TooltipX, 0, 5
	}
Return

#If SYMBOL_MODE
	;fn/num row in the keyboard
	$1::return
	$2::tapMode("","~","")
	$3::tapMode("","|","")
	$4::tapMode("","^","")
	$5::return

	;top row in the keyboard
	$q::tapMode("","``","")
	$w::tapMode("w","/","\")
	$e::tapMode("e","-","_")
	$r::tapMode("r","=","+")
	$t::tapMode("t","&","$")

	;home row in the keyboard
	$a::tapMode("a","!","%")
	$s::tapMode("s","'","""")
	$d::tapMode("d",";",":")
	$f::tapMode("f",".",",")
	$g::tapMode("g","*","?")

	;bottom row in the keyboard
	$z::tapMode("z","<",">")
	$x::tapMode("x","[","]")
	$c::tapMode("c","(",")")
	$v::tapMode("v","{","}")
	$b::tapMode("b","#","@")

	$CapsLock::
	SYMBOL_MODE := false
	NUMBER_MODE := false
	VIM_NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
	INSERT_MODE := true

	if (TOGGLE) {
		INSERT_MODE_II := true

		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,5
		ToolTip,,,,9
		ToolTip, Index, % index_TooltipX, 0, 1
	} else {
		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,5
		ToolTip,,,,9
	}
	return
#If
return
*/

/*
   ----------------------------------------------
   ----------------------------------------------
   ----------------Numpad Keys-------------------
   ----------------------------------------------
   ----------------------------------------------
*/

; SC037 NumpadMult
SC11C::LShift ;numpadenter
SC053::LCtrl ;NumpadDot:Scancode has higher presidence

*SC051::Send, {blind}{Control Down}{Shift Down} ;Numpad3
*SC051 Up::Send, {blind}{Control Up}{Shift Up}

;SC04D::Alt ;Numpad6
/*
NumpadDot::
Send {LShift down}
KeyWait, NumpadDot ; wait for LShift to be released
Send {LShift up}
return
*/

/*
   ----------------------------------------------
   -----------Symbols layer section--------------
   -----------Layer one/ Backspace------------
   ----------------------------------------------
   ----------------------------------------------
*/

; Hotkey to activate the numpad symbol layer
Down::
	; Activate the numpad symbol layer
	NUMPAD_SYMBOL_MODE := true
	VIM_NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
	SYMBOL_MODE := false
	NUMBER_MODE := false
	INSERT_MODE := false
	INSERT_MODE_II := false

	; Show the symbol layer tooltip
	ToolTip,Numpad Symbol, % numpad_symbol_TooltipX, 0, 6

	; Hide any other tooltips
	ToolTip,,,,2
	ToolTip,,,,4
	ToolTip,,,,5
	ToolTip,,,,9
return

Down Up::
	if (A_PriorKey = "Down") {
		Send, {Down}
	}
    ; Deactivate the numpad symbol layer
    NUMPAD_SYMBOL_MODE := false

    ; Reset other modes and show the appropriate tooltip
    SYMBOL_MODE := false
    NUMBER_MODE := false
    VIM_NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
    INSERT_MODE := true

    if TOGGLE {
        INSERT_MODE_II := true

        ; Hide any other tooltips
        ToolTip,,,,2
        ToolTip,,,,4
        ToolTip,,,,5
        ToolTip,,,,6
		ToolTip,,,,9

        ; Show the index layer tooltip
        ToolTip, Index, % index_TooltipX, 0, 1
    } else {
        ; Hide any other tooltips
        ToolTip,,,,2
        ToolTip,,,,4
        ToolTip,,,,5
        ToolTip,,,,6
		ToolTip,,,,9
    }
return

; Define behavior within the symbol layer
#If NUMPAD_SYMBOL_MODE
	;fn row in the keyboard
	$1::return
	$2::tapMode("","~","")
	$3::tapMode("","|","")
	$4::tapMode("","^","")
	$5::return

	;top row in the keyboard
	$q::tapMode("","``","")
	$w::tapMode("w","/","\")
	$e::tapMode("e","-","_")
	$r::tapMode("r","=","+")
	$t::tapMode("t","&","$")

	;home row in the keyboard
	$a::tapMode("a","!","%")
	$s::tapMode("s","'","""")
	$d::tapMode("d",";",":")
	$f::tapMode("f",".",",")
	$g::tapMode("g","*","?")

	;bottom row in the keyboard
	$z::tapMode("z","<",">")
	$x::tapMode("x","[","]")
	$c::tapMode("c","(",")")
	$v::tapMode("v","{","}")
	$b::tapMode("b","#","@")
#If
return

/*
   ----------------------------------------------
   -----------Number layer section---------------
   -----------Layer two/ NumpadAdd---------------
   ----------------------------------------------
   ----------------------------------------------
*/

; Hotkey to activate the numpad number layer
Right::
	; Activate the numpad number layer
	NUMPAD_NUMBER_MODE := true
	VIM_NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
	SYMBOL_MODE := false
	NUMBER_MODE := false
	INSERT_MODE := false
	INSERT_MODE_II := false

	; Show the number layer tooltip
	ToolTip,Numpad Number, % numpad_number_TooltipX, 0, 7

	; Hide any other tooltips
	ToolTip,,,,2
	ToolTip,,,,9
	ToolTip,,,,4
	ToolTip,,,,5
return

Right Up::
	if (A_PriorKey = "Right") {
		Send, {Right}
	}
    ; Deactivate the numpad number layer
    NUMPAD_NUMBER_MODE := false

    ; Reset other modes and show the appropriate tooltip
    SYMBOL_MODE := false
    NUMBER_MODE := false
    VIM_NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
    INSERT_MODE := true

    if TOGGLE {
        INSERT_MODE_II := true

        ; Hide any other tooltips
        ToolTip,,,,2
        ToolTip,,,,4
        ToolTip,,,,5
        ToolTip,,,,7
		ToolTip,,,,9

        ; Show the index layer tooltip
        ToolTip, Index, % index_TooltipX, 0, 1
    } else {
        ; Hide any other tooltips
        ToolTip,,,,2
        ToolTip,,,,4
        ToolTip,,,,5
        ToolTip,,,,7
		ToolTip,,,,9
    }
return

; Define behavior within the number layer
#If NUMPAD_NUMBER_MODE
	;fn/num row
	$1::return
	$2::return
	$3::
		SetKeyDelay -1
		Send {Backspace}
		Gosub, BackspaceLabel
	return
	$4::return
	$5::return

	;top row
	$q::return
	$w::Send 7
	$e::send 8
	$r::send 9
	$t::return

	;home row
	$a::return
	$s::send 4
	$d::send 5
	$f::send 6
	$g::send 0

	;bottom row
	$z::return
 	$x::send 1
 	$c::send 2
	$v::send 3
	$b::return
#If
return
/*
   --------------------------------------------------
   --------------------------------------------------
   -------press alt to active normal layer 2---------
   --------------------------------------------------
   --------------------------------------------------
*/

NormalLabelAlt:
if !NORMAL_ALT_MODE {
	NORMAL_ALT_MODE := true
	VIM_NORMAL_SPACE_MODE := false
	CHECK_IS_ON_VIM_NORMAL_SPACE_MODE := false
	NUMBER_MODE := false
	SYMBOL_MODE := false
	INSERT_MODE := false
	INSERT_MODE_II := false

	ToolTip,,,,2
	ToolTip,,,,4
	ToolTip,,,,5
	ToolTip,Normal 2, % normal_TooltipX_Alt, 0, 9
}
Return

#If NORMAL_ALT_MODE
	;$1::#^c ;shortcut key to TOGGLE invert color filter
	$1::Send #{PrintScreen}
	$2::Send, {LWin}
	$3::Send, {F5}
	$4::Reload ; Hotkey to reload the script
	$5::Suspend ; Hotkey to suspend the script

	$d::Send {WheelUp 5} ;scrollspeed:=5
	$f::Send {WheelDown 5} ;scrollspeed:=5

	$Alt::
	Space::
		ToolTip,,,,2
		ToolTip,,,,4
		ToolTip,,,,5
		ToolTip,,,,9

		NORMAL_ALT_MODE := false
		VIM_NORMAL_SPACE_MODE := false
		NUMBER_MODE := false
		SYMBOL_MODE := false
		INSERT_MODE := true

		if TOGGLE {
			INSERT_MODE_II := true

			ToolTip, Index, % index_TooltipX, 0, 1
		}

		if LongPress(200) {
			if WinActive("ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe") {
				Send, {Esc}
				Gosub, Vim_NormalLabelSpace  ; Trigger Vim_NormalLabelSpace if VS Code is active
			}
		}
		return
#If
return


/*
   -----------------------------------------------
   ---------------Productivity mouse--------------
   -----------------------------------------------
   -----------------------------------------------
*/

RButton::
	g := Morse(300)
	If (g = "1") {
		Send, +{LButton}
		Send, ^c ; single long click to copy text

		ToolTip, Copied!, 900, 500, 8

		; Hide the tooltip after 1 second
		SetTimer, HideTooltip, -1000
	}
	/*
	Else If (g = "01")
		Send ^z ; short long to click undo action
	Else If (g = "10")
		Send ^y  ; long short to click redo action
    */
	Else If (g = "00")
		Send ^v  ; double short click to paste from clipboard
	Else If (g = "0")
		Send {RButton} ; single short click to send rbutton

Return

; Function to hide the tooltip
HideTooltip:
    ToolTip,,,,8
return

; --------------------------------------------------------------------------


mbutton::
CoordMode, Mouse, Screen
MouseGetPos, XposA, YposA
XposA -= 80
YposA -= 80
gui, 50:destroy
Gui, 50:Color, EEAA99

; Buttons (1st column)
Gui, 50:Add, Button, x2 y0 w50 h50 BackgroundTrans gdothis10, Button 1
Gui, 50:Add, Button, x2 y60 w50 h50 BackgroundTrans gdothis20, Undo
Gui, 50:Add, Button, x2 y120 w50 h50 BackgroundTrans gdothis30, Redo
Gui, 50:Add, Button, x2 y180 w50 h50 BackgroundTrans gdothis40,
Gui, 50:Add, Button, x2 y240 w50 h50 BackgroundTrans gdothis50,

; Buttons (2nd column)
Gui, 50:Add, Button, x62 y0 w50 h50 ,
Gui, 50:Add, Button, x62 y60 w50 h50 BackgroundTrans gdothis3, Cut
Gui, 50:Add, Button, x62 y120 w50 h50 BackgroundTrans gclosewanrmenu, Close
Gui, 50:Add, Button, x62 y180 w50 h50 BackgroundTrans gdothis14, New Button 9
Gui, 50:Add, Button, x62 y240 w50 h50 BackgroundTrans gdothis15, New Button 10

; Buttons (3rd column)
Gui, 50:Add, Button, x122 y0 w50 h50 BackgroundTrans gdothis5, Minimize
Gui, 50:Add, Button, x122 y60 w50 h50 BackgroundTrans gdothis4, Copy
Gui, 50:Add, Button, x122 y180 w50 h50 BackgroundTrans gdothis11, New Button 11
Gui, 50:Add, Button, x122 y240 w50 h50 BackgroundTrans gdothis32, New Button 12

; Buttons (4th column)
Gui, 50:Add, Button, x182 y0 w50 h50 BackgroundTrans gdothis1, Maximize
Gui, 50:Add, Button, x182 y60 w50 h50 BackgroundTrans gdothis2, Paste
Gui, 50:Add, Button, x182 y120 w50 h50 BackgroundTrans gdothis13, New Button 13
Gui, 50:Add, Button, x182 y180 w50 h50 BackgroundTrans gdothis14, New Button 14
Gui, 50:Add, Button, x182 y240 w50 h50 BackgroundTrans gdothis59, New Button 59
; New Buttons (5th column)
Gui, 50:Add, Button, x242 y0 w50 h50 BackgroundTrans gdothis9, Close
Gui, 50:Add, Button, x242 y60 w50 h50 BackgroundTrans gdothis100, Select All
Gui, 50:Add, Button, x242 y120 w50 h50 BackgroundTrans gdothis111, New Button 6
Gui, 50:Add, Button, x242 y180 w50 h50 BackgroundTrans gdothis99, New Button 99
Gui, 50:Add, Button, x242 y240 w50 h50 BackgroundTrans gdothis78, New Button 78

Gui 50:+LastFound +AlwaysOnTop +ToolWindow
WinSet, TransColor, EEAA99
Gui 50:-Caption
Gui, 50:Show, x%XposA% y%YposA% h300 w299, menus ; Adjust width to accommodate the new columns
Return

SetTitleMatchMode 2

closewanrmenu:
Gui, 50:Destroy
return

; Button actions
dothis1:
Gui, 50:Destroy
WinMaximize, A
Return

dothis2:
Send, ^p
Return

dothis3:
Send, ^x
Return

dothis4:
Send, ^c
Return

dothis5:
Gui, 50:Destroy
WinMinimize, A
Return

dothis6:
Gui, 50:Destroy
msgbox, New Button 1
Return

dothis7:
Gui, 50:Destroy
msgbox, New Button 2
Return

dothis8:
Gui, 50:Destroy
msgbox, New Button 3
Return

dothis9:
Gui, 50:Destroy
WinClose, A
Return

dothis10:
Gui, 50:Destroy
msgbox, New Button 5
Return

dothis11:
Gui, 50:Destroy
msgbox, New Button 6
Return

dothis12:
Gui, 50:Destroy
msgbox, New Button 7
Return

dothis13:
Gui, 50:Destroy
msgbox, New Button 8
Return

dothis14:
Gui, 50:Destroy
msgbox, New Button 9
Return

dothis15:
Gui, 50:Destroy
msgbox, New Button 10
Return

dothis20:
Send, ^z ;undo
Return

dothis30:
Send, ^y ;redo
Return

dothis32:
Gui, 50:Destroy
msgbox, New Button 17
Return

dothis40:
Gui, 50:Destroy
msgbox, New Button 13
Return

dothis50:
Gui, 50:Destroy
msgbox, New Button 14
Return

dothis100:
Send, ^a
Return

dothis111:
Gui, 50:Destroy
msgbox, New Button 15
Return

dothis59:
Gui, 50:Destroy
msgbox, New Button 59
Return

dothis99:
Gui, 50:Destroy
msgbox, New Button 99
Return

dothis78:
Gui, 50:Destroy
msgbox, New Button 78
Return

/*
f1::
Menu MyMenu, Add, A Item 1, item1handler
Menu MyMenu, Add, B Item 2, item2handler
Menu MyMenu, Show
Return
item1handler:
Msgbox, You pressed item 1
Return
item2handler:
Msgbox, You pressed item 2
Return
*/

/*
   ----------------------------------------------
   ----------------------------------------------
   --------------chrome autmation----------------
   ----------------------------------------------
   ----------------------------------------------
*/


#IfWinActive, ahk_class Chrome_WidgetWin_1 ahk_exe chrome.exe

$space::Send, {Space Down}
$space Up::Send, {Space Up}

/*
$space::
WinGetTitle, Title, A
	if (InStr(Title, "YouTube")) {
		Send, {Space Down}
	} else {
		SetKeyDelay -1
		Send {space} ; Action for short press
		SetKeyDelay -1

		SearchString := ""
		ToolTip,, % chord_TooltipX, % chord_TooltipY, 3
		;ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000

	}
return

$space Up::
WinGetTitle, Title, A
	if (InStr(Title, "YouTube")) {
		Send, {Space Up}
}

*/



/*
; Remap 'v' to 'f' only when YouTube is active
~v::
    ; Check if YouTube is in the active tab's URL
    if WinActive("ahk_class Chrome_WidgetWin_1") {
        WinGetTitle, Title, A
        if (InStr(Title, "YouTube")) {
            Send f  ; Remap 'v' to 'f' on YouTube
        }
    }
return
*/


;$Space::Send, i
/*
$Space::
	g := Morse(300)
	If (g = "00")
		Send F  ; double short press to open link on the same page in vimium extension
	Else If (g = "0")
		Send, f ; single short press to open link on the new tab in vimium extension
Return
*/
/*
	;fn/num row
	$1::return
	$2::return
	$3::return
	$4::return
	$5::return

	;top row
	$q::return
	$w::Send 7
	$e::send 8
	$r::send 9
	$t::return

	;home row
	$a::return
	$s::send 4
	$d::send 5
	$f::send 6
	$g::send 0

	;bottom row
	$z::return
 	$x::send 1
 	$c::send 2
	$v::send 3
	$b::return

	$Tab::return

	$CapsLock::return
*/

/*
ClickCount := 0
StartX := 0
StartY := 0
EndX := 0
EndY := 0

; Single left click to start/end text selection and double-click to paste clipboard contents
RButton::
    ClickCount++
    If (ClickCount = 1) {
        ; First click - start selection
        MouseGetPos, StartX, StartY
    } Else If (ClickCount = 2) {
        ; Second click - end selection
        MouseGetPos, EndX, EndY
        ; Determine selection direction
        if (EndX < StartX) {
            Temp := EndX
            EndX := StartX
            StartX := Temp
            Temp := EndY
            EndY := StartY
            StartY := Temp
        }
        ; Select text between Start and End positions
        MouseMove, StartX, StartY
        Sleep 50 ; Adjust sleep time if necessary
        MouseClickDrag, Left, , , EndX, EndY

        ; Copy selected text to clipboard
        Send, ^c
        ClickCount := 0 ; Reset click counter after selection
    } Else If (ClickCount = 3) {
        ; Third click (double-click) - paste clipboard contents
        Send, ^v
        ClickCount := 0 ; Reset click counter after paste
    }
Return
*/
#If

 /*
   ----------------------------------------------
   ----------------------------------------------
   ----------------change volume-----------------
   ----------------------------------------------
   ----------------------------------------------
 */

#If MouseIsOver("ahk_class Shell_TrayWnd")
   WheelUp::Send {Volume_Up}
   WheelDown::Send {Volume_Down}
#If

MouseIsOver(WinTitle)
{
   MouseGetPos,,, Win
   Return WinExist(WinTitle . " ahk_id " . Win)
}

 /*
   ----------------------------------------------
   ----------------------------------------------
   --------------shorthand-----------------------
   ----------------------------------------------
   ----------------------------------------------
 */

;::btw::by the way

/*
   ----------------------------------------------
   ----------------------------------------------
   -------------Other additional code------------
   ----------------------------------------------
   ----------------------------------------------
 */

global SearchString

tapMode(ByRef physicalKey,ByRef shortTap, ByRef longTap)
{
	if (physicalKey == "" && longTap == ""){
		Send, {blind}{%shortTap%}
		SearchString := SearchString shortTap  ; implicit concat
		;return
		searchChord(SearchString)
	}
	else {
		KeyWait, %physicalKey%, T0.16

			if (ErrorLevel) {
				SetKeyDelay -1
				Send, {blind}{%longTap%}
				SearchString := SearchString . longTap  ; Explicit concat
				searchChord(SearchString)
			}
			else {
				SetKeyDelay -1
				Send, {blind}{%shortTap%}
				SearchString := SearchString . shortTap  ; Explicit concat
				searchChord(SearchString)
			}

		KeyWait, %physicalKey%
		return
	}
}


indexMode(ByRef letters)
{
	Send, {blind}{%letters%}
	SearchString := SearchString letters  ; implicit ataeae
	searchChord(SearchString)

}

searchChord(ByRef SearchString)
{
	global word
	global match
	global curserPos
	;global parts

	word := False
	parts := False

	;https://www.autohotkey.com/boards/viewtopic.php?t=29213
	;https://www.autohotkey.com/boards/viewtopic.php?t=17811
    ;C:\Users\shant\Desktop\onehand-keyboard-AHK-scripts\chording_dictionary\mison.txt

	Loop, Read, C:\Users\Dell\Downloads\chord.txt
	{

    ; Split each line by the '|' character into 3 parts
    parts := StrSplit(A_LoopReadLine, "|")

    ; Ensure there are 3 parts: match, word, and curserPos
    if (parts.MaxIndex() = 3)
	{
        ; Use RegExMatch to find exact match with parts.1 (the 'match' field)
        if RegExMatch(parts.1, "^" SearchString "$")
		{
            match := parts.1  ; First part: the match string
            word := parts.2   ; Second part: the word
            curserPos := parts.3  ; Third part: the cursor position
		}
	}
}

	if(word)
		;ToolTip, %match%:%word%, % chord_TooltipX, % chord_TooltipY, 3
		ToolTip, %match%:%word%, A_CaretX-50, A_CaretY-50, 3, 2000
	else {
		l := StrLen(SearchString)
		StringLeft, OutputVar, SearchString, 10  ; Stores the string "This" in OutputVar.

		ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000
		/*
		if (l > 10){

		;ToolTip, %OutputVar% %l%:?, % chord_TooltipX, % chord_TooltipY, 3
		;ToolTip, %OutputVar% %l%:?, A_CaretX-50, A_CaretY-50, 1, 2000
		}else{
		;ToolTip, %SearchString%:?, % chord_TooltipX, % chord_TooltipY, 3

		;ToolTip, %SearchString%:?, A_CaretX-50, A_CaretY-50, 1, 2000
		}
		*/
	}
}

EnterLabel:
	if !word
	{
		SetKeyDelay -1
		send, {Enter}
		SetKeyDelay -1
	}
	else
	{
		KeyWait, Enter, U
		l := StrLen(match)

		SetKeyDelay, -1
		Send, {Backspace %l%}%word%{Left %curserPos%}
		SetKeyDelay, -1
		word := ""
		ToolTip,, % chord_TooltipX, % chord_TooltipY, 3
		;ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000 ;tooltip will reset only when the chord match, after the send operation
	}
	SearchString := ""
	ToolTip,, % chord_TooltipX, % chord_TooltipY, 3
    ;ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000 ;tooltip string will be reset
return

BackspaceLabel:
	SetKeyDelay -1
	len := StrLen(SearchString)

	if(len > 10)
	{
		l := (len - 1)
		SearchString := SubStr( SearchString, 1, (len - 1))
		StringLeft, OutputVar, SearchString, 10

		;ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000
		;ToolTip,%OutputVar% %l%:?, A_CaretX-50, A_CaretY-50, 3, 2000 ; hide tooltip because it irritate workflow
		ToolTip,%OutputVar% %l%:?, % chord_TooltipX, % chord_TooltipY, 3
		word := ""
	}
	else
	{
		SearchString := SubStr( SearchString, 1, (len - 1))

		if(!SearchString)
			ToolTip,, % chord_TooltipX, % chord_TooltipY, 3
			;ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000
		else
			;ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000
			;ToolTip,%SearchString%:?, A_CaretX-50, A_CaretY-50, 3, 2000 ; hide tooltip because it irritate workflow
			ToolTip,%SearchString%:?, % chord_TooltipX, % chord_TooltipY, 3

		word := ""
	}

LongPress(Timeout) {
    RegExMatch(Hotkey:=A_ThisHotkey, "\W$|\w*$", Key)
	KeyWait %Key%
	IF (Key Hotkey) <> (A_PriorKey A_ThisHotkey)
	   Exit
    Return A_TimeSinceThisHotkey > Timeout
}

Morse(timeout) {
   tout := timeout/1000
   key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]")
   Loop {
      t := A_TickCount
      KeyWait %key%
      Pattern .= A_TickCount-t > timeout
      KeyWait %key%,DT%tout%
    if (ErrorLevel)
      Return Pattern
   }
}

; end of the script