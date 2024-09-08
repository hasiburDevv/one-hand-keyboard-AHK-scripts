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
global NORMAL_SPACE_MODE := false
global NORMAL_GUI_MODE := false
global NORMAL_ALT_MODE := false
global SYMBOL_MODE := false
global NUMBER_MODE := false
global NUMPAD_SYMBOL_MODE := false ; Variable to track the state of the numpad symbol layer
global NUMPAD_NUMBER_MODE := false
global IS_RBUTTON_DOWN := false ; Initialize flags to track the state of RButton down

index_TooltipX := 960 ; tooltip 1 index layer
normal_TooltipX_Space := index_TooltipX - 117 ; tooltip 2 visual layer
normal_TooltipX_Alt := index_TooltipX - 117 ; tooltip 9 visual layer
; A_CaretX-50, A_CaretY-50 ; tooltip 3 for display chord dict
number_TooltipX := index_TooltipX + 100 ; tooltip 4 number layer
symbol_TooltipX := index_TooltipX + 100 ; tooltip 5 symbol layer
numpad_symbol_TooltipX := index_TooltipX + 100 ; tooltip 6 numpad symbol layer
numpad_number_TooltipX := index_TooltipX + 100 ; tooltip 7 numpad number layer
; MouseGetPos, x, y tooltip 8 for copied message
/*
   ----------------------------------------------
   ----------------------------------------------
   -------------Basic letter typing--------------
   ----------------------------------------------
   ----------------------------------------------
*/

#If INSERT_MODE ; Start of INSERT_MODE

; Detect if d is pressed and released without combination
*d::
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
~d & s::return

#IfWinActive, ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe
~d & f::Send, {Esc}  ; d + f ESC when VS Code is active
#If  ; End conditional hotkeys

; switch between windows
~d & f::
    Send, {Alt Down}
	Send, {Tab}
	Send, {Alt Up}
return

~d & g::AltTab ;Send Alt+Tab to shift to right
~d & v::return
~d & t::return

	#If INSERT_MODE_II ; start of INSERT_MODE_II
	;fn row
	;*Esc::
	*1::capslock
	*2::SendInput, % (GetKeyState("Shift", "P") ? "J" : indexMode("j"))
	*3::
		SetKeyDelay -1
		Send {Backspace}
		Gosub, BackspaceLabel
	return
	*4::SendInput, % (GetKeyState("Shift", "P") ? "X" : indexMode("x"))
	*5::return

	;top row
	*q::SendInput, % (GetKeyState("Shift", "P") ? "Z" : indexMode("z"))
	*w::SendInput, % (GetKeyState("Shift", "P") ? "B" : indexMode("b"))
	*e::
        send, {Enter}
        SearchString := ""
        ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000
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
	~Space & 2::Send 9
	~Space & 3::Send 8
	~Space & 4::Send 7
	~Space & 5::return
	;top row
	~Space & w::Send, 5
	~Space & e::Send, 1
	~Space & r::Send, 0
	~Space & t::Send, 9
	;home row
    ~Space & a::Send, 6
	~Space & s::Send {Left} ; h - move cursor left
	~Space & d::Send {Down} ; j - move cursor down
	~Space & d Up::
		INSERT_MODE_II := true

        ToolTip, Index, % index_TooltipX, 0, 1
	return
	~Space & f::Send {Up} ; k - move cursor up
	~Space & g::Send {Right} ; l - move cursor right
	;bottom row
	~Space & z::Send, 7
	~Space & x::Send, 4
	~Space & c::Send, 3
	~Space & v::Send, 2
	~Space & b::Send, 8

	#If ;end of INSERT_MODE_II
	return

;fn row
;3 0e1 2, 546, 987

*1::return
*2::send {Tab}

*3::
	send, {Enter}
	SearchString := ""
	ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000
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

LWin::Alt
LCtrl & Alt::Reload	; Hotkey to reload the script
LCtrl & Space::Suspend ; Hotkey to suspend the script

Alt::
	gosub, NormalLabelAlt
return

Tab::
	gosub, NumberLebelTab
return

CapsLock::
	gosub, SymbolLebelCapsLock
return


Space::
if LongPress(200)
	Gosub, NormalLabelSpace
Else
	gosub, SpacebarLabel
return


/*
   ----------------------------------------------
   ----------------------------------------------
   --------------Space with any key--------------
   ----------------------------------------------
   ----------------------------------------------
*/

;fn row
~Space & 1::return
~Space & 2::Send 9
~Space & 3::Send 8
~Space & 4::Send 7
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

NormalLabelSpace:
if !NORMAL_SPACE_MODE {
	NORMAL_SPACE_MODE := true
	SYMBOL_MODE := false
	NUMBER_MODE := false
	INSERT_MODE := false
    INSERT_MODE_II := false

	ToolTip,,,,4
	ToolTip,,,,5
	ToolTip,Normal, % normal_TooltipX_Space, 0, 2
	}
Return

#If NORMAL_SPACE_MODE
	;fn row
	$1::return
	$2::return
	$3::
	if LongPress(200)
		Send, ^{Home}
	Else
		Send, {Home}
	return

	$4::
	if LongPress(200)
		Send, ^{End}
	Else
		Send, {End}
	return
	$5::return

    ; Top row remapping
    $q::Send, {Tab}
    $w::return
    $e::return
    $r::return
    $t::return

	;home row
	$a::return
	$s::Send {Left} ;h - move cursor left
	$d::Send {Down} ;j - move cursor down
	$f::Send {Up} ;k - move cursor up
	$g::Send {Right} ;l - move cursor right

    ; Bottom row remapping
    $z::Send, ^z
	$^z::Send, ^y
    $x::Send, ^{Left}
    $c::Send, {WheelDown}
    $v::Send, {WheelUp}
    $b::Send, ^{Right}

	; Define the hotkey to show or destroy the GUI
	$Space::
	ToolTip,,,,2
	ToolTip,,,,4
	ToolTip,,,,5

	if LongPress(200) {
		guiOpen := true
		NORMAL_SPACE_MODE := false
		SYMBOL_MODE := false
		NUMBER_MODE := false

		Gosub, Gui1Setup  ; Call the setup for the specific GUI
	} else {
		guiOpen := false
		NORMAL_SPACE_MODE := false
		SYMBOL_MODE := false
		NUMBER_MODE := false
		INSERT_MODE := true

		if TOGGLE {
			INSERT_MODE_II := true

			ToolTip, Index, % index_TooltipX, 0, 1
		}
		return
	}
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

; Global variables to track which GUI is currently displayed
global CurrentGui := 1
global TotalGuis := 5
global guiOpen := false

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
	NORMAL_SPACE_MODE := false
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
	Gui, 1:Add, Button, x101 y479 w140 h110 BackgroundTrans gGui1Button15Action, Button 15

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

Gui2Setup:
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
	NORMAL_SPACE_MODE := false
	NORMAL_ALT_MODE := false
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
	NORMAL_SPACE_MODE := false
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
if !SYMBOL_MODE {
	SYMBOL_MODE := true
	NUMBER_MODE := false
	NORMAL_SPACE_MODE := false
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
	NORMAL_SPACE_MODE := false
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
	NORMAL_SPACE_MODE := false
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
    NORMAL_SPACE_MODE := false
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
	NORMAL_SPACE_MODE := false
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
    NORMAL_SPACE_MODE := false
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
	NORMAL_SPACE_MODE := false
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
		NORMAL_ALT_MODE := false
		NORMAL_SPACE_MODE := false
		NUMBER_MODE := false
		SYMBOL_MODE := false
		INSERT_MODE := true

		if TOGGLE {
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

		if LongPress(200)
			Gosub, NormalLabelSpace
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
	g := Morse()
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
Gui, 50:Add, Button, x2 y60 w50 h50 BackgroundTrans gdothis20, Button 2
Gui, 50:Add, Button, x2 y120 w50 h50 BackgroundTrans gdothis30, New Button 3
Gui, 50:Add, Button, x2 y180 w50 h50 BackgroundTrans gdothis40, New Button 7
Gui, 50:Add, Button, x2 y240 w50 h50 BackgroundTrans gdothis50, New Button 8

; Buttons (2nd column)
Gui, 50:Add, Button, x62 y0 w50 h50 ,
Gui, 50:Add, Button, x62 y60 w50 h50 BackgroundTrans gdothis3, Opener
Gui, 50:Add, Button, x62 y120 w50 h50 BackgroundTrans gclosewanrmenu, Close
Gui, 50:Add, Button, x62 y180 w50 h50 BackgroundTrans gdothis14, New Button 9
Gui, 50:Add, Button, x62 y240 w50 h50 BackgroundTrans gdothis15, New Button 10

; Buttons (3rd column)
Gui, 50:Add, Button, x122 y0 w50 h50 BackgroundTrans gdothis5, Minimize
Gui, 50:Add, Button, x122 y60 w50 h50 BackgroundTrans gdothis4, Hello
Gui, 50:Add, Button, x122 y180 w50 h50 BackgroundTrans gdothis11, New Button 11
Gui, 50:Add, Button, x122 y240 w50 h50 BackgroundTrans gdothis32, New Button 12

; Buttons (4th column)
Gui, 50:Add, Button, x182 y0 w50 h50 BackgroundTrans gdothis1, Maximize
Gui, 50:Add, Button, x182 y60 w50 h50 BackgroundTrans gdothis2, and this
Gui, 50:Add, Button, x182 y120 w50 h50 BackgroundTrans gdothis13, New Button 13
Gui, 50:Add, Button, x182 y180 w50 h50 BackgroundTrans gdothis14, New Button 14
Gui, 50:Add, Button, x182 y240 w50 h50 BackgroundTrans gdothis59, New Button 59
; New Buttons (5th column)
Gui, 50:Add, Button, x242 y0 w50 h50 BackgroundTrans gdothis9, Close
Gui, 50:Add, Button, x242 y60 w50 h50 BackgroundTrans gdothis100, New Button 5
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
Gui, 50:Destroy
msgbox, and this
Return

dothis3:
Gui, 50:Destroy
msgbox, Opener
Return

dothis4:
Gui, 50:Destroy
msgbox, Hello
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
Gui, 50:Destroy
msgbox, New Button 11
Return

dothis30:
Gui, 50:Destroy
msgbox, New Button 12
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
Gui, 50:Destroy
msgbox, New Button 15
Return

dothis111:
Gui, 50:Destroy
msgbox, New Button 16
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

#IfWinActive, ahk_class Chrome_WidgetWin_1
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
	;global parts

	word := False
	parts := False

	;https://www.autohotkey.com/boards/viewtopic.php?t=29213
	;https://www.autohotkey.com/boards/viewtopic.php?t=17811
    ;C:\Users\shant\Desktop\onehand-keyboard-AHK-scripts\chording_dictionary\mison.txt

	Loop, Read, C:\Users\Dell\Downloads\mison.txt
		{

			parts:=strsplit(A_LoopReadLine, A_Space,,2) ;https://www.autohotkey.com/boards/viewtopic.php?t=90924

			If RegExMatch(parts.1,  "^" SearchString "$") ;https://www.autohotkey.com/boards/viewtopic.php?t=2399
				{
					match := parts.1
					word := parts.2
					;break
					;Continue ;second concerned line
				}
		}

	if(word)
		ToolTip, %match%:%word%, A_CaretX-50, A_CaretY-50, 3, 2000
	else{
		l := StrLen(SearchString)
		StringLeft, OutputVar, SearchString, 10  ; Stores the string "This" in OutputVar.
		if (l > 10){
		;ToolTip, %OutputVar% %l%:?, A_CaretX-50, A_CaretY-50, 1, 2000
		}else{
		;ToolTip, %SearchString%:?, A_CaretX-50, A_CaretY-50, 1, 2000
		}
	}
}

SpacebarLabel:
	SetKeyDelay -1
	Send {space}
	SetKeyDelay -1

	if(word)
	{
		KeyWait, Space, U
		l := StrLen(match)+1
		SetKeyDelay, -1
		Send, {Backspace %l%}%word%{space}
		SetKeyDelay, -1
		word := ""

		ToolTip, , A_CaretX-50, A_CaretY-50, 3, 2000 ;tooltip will reset only when the chord match, after the send operation
	}
	SearchString := ""
    ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000 ;tooltip string will be reset
return

BackspaceLabel:
	SetKeyDelay -1
	len := StrLen(SearchString)

	if(len > 10)
	{
		l := (len - 1)
		SearchString := SubStr( SearchString, 1, (len - 1))
		StringLeft, OutputVar, SearchString, 10

		ToolTip,%OutputVar% %l%:?, A_CaretX-50, A_CaretY-50, 3, 2000
		word := ""
	}
	else
	{
		SearchString := SubStr( SearchString, 1, (len - 1))

		if(!SearchString)
			ToolTip,, A_CaretX-50, A_CaretY-50, 3, 2000
		else
			ToolTip,%SearchString%:?, A_CaretX-50, A_CaretY-50, 3, 2000

		word := ""
	}
return

LongPress(Timeout) {
    RegExMatch(Hotkey:=A_ThisHotkey, "\W$|\w*$", Key)
	KeyWait %Key%
	IF (Key Hotkey) <> (A_PriorKey A_ThisHotkey)
	   Exit
    Return A_TimeSinceThisHotkey > Timeout
}

Morse(timeout = 300) {
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