﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;Suspend, on
#InstallKeybdHook
#SingleInstance, force
#MaxHotkeysPerInterval 200
;SendMode Input
;#UseHook
;SetCapsLockState, alwaysoff
;KeyHistory
SetCapsLockState, AlwaysOff

CoordMode, Tooltip, Screen ;relative to the active window by default

; ^Ctrl +Shift #Win !Alt

;*#c::Run Calc.exe --- Win+C, Shift+Win+C, Ctrl+Win+C, etc. will all trigger this hotkey.
;*ScrollLock::Run Notepad --- Pressing ScrollLock will trigger this hotkey even when modifier key(s) are down.

*;::send, {blind}b
*q::send, {blind}y
*b::send, {blind}u
*y::send, {blind}r
*u::send, {blind}s
*r::send, {blind}o

*-::send, {blind}c
*k::send, {blind}d
*c::send, {blind}t
*d::send, {blind}h
*t::send, {blind}e
*h::send, {blind}a
*e::send, {blind}z

*'::send, {blind}g
*x::send, {blind}v
*g::send, {blind}w
*v::send, {blind}n
*w::send, {blind}i
*n::send, {blind}.

;----------------
*a::send, {blind}x
*z::send, {blind}p
;----------------
; SC037 NumpadMult


SC053::LShift ;NumpadDot:Scancode has higher presidence
SC051::LCtrl ;Numpad3
*SC04D::Send, {blind}{Control Down}{Shift Down} ;numpad6
*SC04D Up::Send, {blind}{Control Up}{Shift Up}
SC049::Alt ;Numpad9
/*
NumpadDot::
Send {LShift down}
KeyWait, NumpadDot ; wait for LShift to be released
Send {LShift up}
return
*/

;0123 546 987
;$,::Send {.}
*m::Send 3
*/::
	KeyWait, /, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send 5 ;long
	}
	else {
			SetKeyDelay -1
			send 0 ;single
	}

	KeyWait, /
return

*p::
	KeyWait, p, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send 4 ;long
	}
	else {
			SetKeyDelay -1
			send 1 ;single
	}


	KeyWait, p
return

*f::
	KeyWait, f, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send 6 ;long
	}
	else {
			SetKeyDelay -1
			send 2 ;single
	}

	KeyWait, f
return

/*
mirror_k = p
mirror_c = fl
mirror_d = m
mirror_t = l
mirror_h = j
return
*/

; This key may help, as the space-on-up may get annoying, especially if you type fast.
Control & Space::Suspend

; Not exactly mirror but as close as we can get, Capslock enter, Tab backspace.

Space & b::Send {Up}
Space & y::Send {Backspace}
Space & u::Send {Enter}

Space & g::Send {left}
Space & v:: Send {Down}
Space & w:: Send {Right}
Space & n::Send {,}

;Space & k::Send {p}
Space & k::
  if Shift = D
  {
	send, {blind}P
  }
  else
  {
	send, {blind}p
  }
  return

;Space & c::Send {f}
Space & c::

  if Shift = D
  {
	send, {blind}F
  }
  else
  {
	send, {blind}f
  }
  return

;Space & d::Send {m}
Space & d::
  if Shift = D
  {
	send, {blind}M
  }
  else
  {
	send, {blind}m
  }
  return

;Space & t::Send {l}
Space & t::
  if Shift = D
  {
	send, {blind}L
  }
  else
  {
	send, {blind}l
  }
  return

;Space & h::Send {j}
Space & h::
  if Shift = D
  {
	send, {blind}J
  }
  else
  {
	send, {blind}j
  }
  return

;Space & `;::Send {q}
Space & `;::
  if Shift = D
  {
	send, {blind}Q
  }
  else
  {
	send, {blind}q
  }
  return

;Space & -::Send {k}
Space & -::
  if Shift = D
  {
	send, {blind}K
  }
  else
  {
	send, {blind}k
  }
	return

;Space & '::Send {x}
Space & '::
  if Shift = D
  {
	send, {blind}X
  }
  else
  {
	send, {blind}x
  }
	return

Space & /::
  if Shift = D
  {
	send 9
  }
  else
  {
	send 9
  }
	return

Space & p::
  if Shift = D
  {
	send 8
  }
  else
  {
	send 8
  }
	return

Space & f::
  if Shift = D
  {
	send 7
  }
  else
  {
	send 7
  }
	return
/*
; Without this capslock would shift only letters, this resolves that issue.
+CapsLock::   ; Must catch capslock and Shift capslock to make this work.
CapsLock::
  if CapsState = D
  {
    CapsState = U
    Send {LShift Up}
  }
  else
  {
    CapsState = D
    Send {LShift Down}
  }
  return

Shift::CapsState = U  ; User pressed shift which toggles shift back up.
; The only strange part of this setup is that although capslock will toggle
; shift state, hitting the shift key will not toggle, it will act as a shift
; key reguardless of the capslock state and release afterward.

*/

; If spacebar didn't modify anything, send a real space keystroke upon release.
space::
SetKeyDelay -1
Send {space}
return

/*
space & t::
space & d::
space & c::
space & h::
space & k::
space & a::
space & e::
*/
; Determine the mirror key, if there is one:
if A_ThisHotkey = space & ``
   MirrorKey = '
else if A_ThisHotkey = space & `;
   MirrorKey = a
else if A_ThisHotkey = space & ,
   MirrorKey = c
else if A_ThisHotkey = space & .
   MirrorKey = x
else if A_ThisHotkey = space & /
   MirrorKey = z
else  ; To avoid runtime errors due to invalid var names, do this part last.
{
   StringRight, ThisKey, A_ThisHotkey, 1
   StringTrimRight, MirrorKey, mirror_%ThisKey%, 0  ; Retrieve "array" element.
   if MirrorKey =  ; No mirror, script probably needs adjustment.
      return
}

Modifiers =
GetKeyState, state1, LWin
GetKeyState, state2, RWin
state = %state1%%state2%
if state <> UU  ; At least one Windows key is down.
   Modifiers = %Modifiers%#
GetKeyState, state1, Control
if state1 = D
   Modifiers = %Modifiers%^
GetKeyState, state1, Alt
if state1 = D
   Modifiers = %Modifiers%!
GetKeyState, state1, Shift
if state1 = D
   Modifiers = %Modifiers%+
Send %Modifiers%{%MirrorKey%}
return


;symbols layer section
;this section is mainly for symbol layer.you have to press and hold numpadenter to active this layer


NumpadEnter::
last := layer, layer := 3

	ToolTip Standard tooltip
	ToolTipFont("s12","Serif Bold")
	ToolTipColor("Red","White")
	ToolTip, Symbols, 683, 2
KeyWait NumpadEnter

layer := A_Priorkey != "NumpadEnter" ? last : last = 2 ? 1 : 2

if (layer = 2) {
	;ToolTip Standard tooltip
	;ToolTipFont("s12","Serif Bold")
	;ToolTipColor("Red","White")
	;ToolTip, layer 2, 683, 2
	ToolTip, ,
} else {
	ToolTip, ,
}
Return




; #If (layer = 2)

 #If (layer = 3)
;second row in the keyboard
;second row in the keyboard
$b::
	KeyWait, b, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		Send {\} ;long
	}
	else {
			SetKeyDelay -1
			Send {/} ;single
	}

	KeyWait, b
return

$y::
	KeyWait, y, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {:} ;long
	}
	else {
			SetKeyDelay -1
			send {;} ;single
	}

	KeyWait, y
return

$u::
	KeyWait, u, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		Send {`"} ;long
	}
	else {
			SetKeyDelay -1
			Send {'} ;single
	}

	KeyWait, u
return

$r::
	KeyWait, r, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {!} ;long
	}
	else {
			SetKeyDelay -1
			send {?} ;single
	}

	KeyWait, r
return

;third row in the keyboard
;third row in the keyboard
$-::
	KeyWait, -, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {|} ;long
	}
	else {
			SetKeyDelay -1
			send {``} ;single
	}

	KeyWait, -
return

$k::
	KeyWait, k, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {#} ;long
	}
	else {
			SetKeyDelay -1
			send {`%} ;single
	}

	KeyWait, k
return

$c::
	KeyWait, c, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {@} ;long
	}
	else {
			SetKeyDelay -1
			send {&} ;single
	}

	KeyWait, c
return

$d::
	KeyWait, d, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {$} ;long
	}
	else {
			SetKeyDelay -1
			send {*} ;single
	}

	KeyWait, d
return

$t::
	KeyWait, t, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {+} ;long
	}
	else {
			SetKeyDelay -1
			send {=} ;single
	}

	KeyWait, t
return

$h::
	KeyWait, h, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {_} ;long
	}
	else {
			SetKeyDelay -1
			send {-} ;single
	}

	KeyWait, h
return


;forth row in the keyboard
;forth row in the keyboard
$'::
	KeyWait, ', T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {~} ;long
	}
	else {
			SetKeyDelay -1
			send {^} ;single
	}

	KeyWait, '
return


$x::
	KeyWait, x, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {>} ;long
	}
	else {
			SetKeyDelay -1
			send {<} ;single
	}

	KeyWait, x
return

$g::
	KeyWait, g, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {)} ;long
	}
	else {
			SetKeyDelay -1
			send {(} ;single
	}

	KeyWait, g
return

$v::
	KeyWait, v, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {]} ;long
	}
	else {
			SetKeyDelay -1
			send {[} ;single
	}

	KeyWait, v
return

$w::
	KeyWait, w, T0.23

	if (ErrorLevel) {
		SetKeyDelay -1
		send {}} ;long
	}
	else {
			SetKeyDelay -1
			send {{} ;single
	}

	KeyWait, w
return
#If
;number layer section
;this section is mainly for number layer.you have to press and hold numpadsub to active this layer


NumpadSub::
last := lay, lay := 3

	ToolTip Standard tooltip
	ToolTipFont("s12","Serif Bold")
	ToolTipColor("Red","White")
	ToolTip, Numbers, 683, 2
KeyWait NumpadSub

lay := A_Priorkey != "NumpadSub" ? last : last = 2 ? 1 : 2

if (lay = 2) {
	;ToolTip Standard tooltip
	;ToolTipFont("s12","Serif Bold")
	;ToolTipColor("Red","White")
	;ToolTip, layer 2, 683, 2
	ToolTip, ,
} else {
	ToolTip, ,
}
return

;#If (lay = 2)

#If (lay = 3)
 $b::Send 7
 $y::send 8
 $u::send 9
 $c::send 4
 $d::send 5
 $t::send 6
 $g::send 1
 $v::send 2
 $w::send 3
 $h::send 0
#If

/* -----------------------
|  Layer three/ numpadAdd
|  -----------------------
*/

; This is specifically for Kinesis keyboards using the Colemak keyboard layout, to mirror the keyboard so you can type both sides of it using only the left hand.

; A #CommentFlag will need to be included if we can manage to map ;
/*
mirror_1 = 0
mirror_2 = 9
mirror_backspace = space
return

*/

NumpadAdd & q::Send ^t
NumpadAdd & b::Send ^w
NumpadAdd & y::Send ^s
NumpadAdd & u::Send ^x
NumpadAdd & r::Send ^a

NumpadAdd & -::
Send ^c
#Persistent
ToolTip, copied.
SetTimer, RemoveToolTip, -1000
return

RemoveToolTip:
ToolTip
return

NumpadAdd & k::Send ^v
NumpadAdd & c::Send #s
NumpadAdd & d::Send #e

; If delete didn't modify anything, send a real delete key
; upon release. oooien
NumpadAdd::
SetKeyDelay -1
Send {Enter}
return

/*
delete & 1::
delete & 2::
delete & backspace::
*/
; Determine the mirror key, if there is one:
;StringLeft, ThisKey, A_ThisHotkey, 1
;ThisKey := A_ThisHotkey
ThisKey := SubStr(A_ThisHotkey, 10)

;StringTrimRight, MirrorKey, mirror_%ThisKey%, 0  ; Retrieve "array" element.
MirrorKey := mirror_%ThisKey%
;if MirrorKey =  ; No mirror, so do nothing?
;   return

Modifiers =
GetKeyState, state1, LWin
GetKeyState, state2, RWin
state = %state1%%state2%
if state <> UU  ; At least one Windows key is down.
   Modifiers = %Modifiers%#
GetKeyState, state1, Control
if state1 = D
   Modifiers = %Modifiers%^
GetKeyState, state1, Alt
if state1 = D
   Modifiers = %Modifiers%!
GetKeyState, state1, Shift
if state1 = D
   Modifiers = %Modifiers%+
Send %Modifiers%{%MirrorKey%}
return


/* -----------------
|  Arrow Keys
|  -----------------
*/

; Up i(q)
CapsLock & q::
if GetKeyState("Shift", "D")
    if GetKeyState("Alt", "D")
        Send +!{Up}
    else if GetKeyState("Ctrl", "D")
        Send +^{Up}
    else
        Send +{Up}
else if GetKeyState("Ctrl", "D")
    if (GetKeyState("Alt", "D"))
        Send ^!{Up}
    else
        Send ^{Up}
else if GetKeyState("Alt", "D")
    Send !{Up}
else
    Send {Up}
return

; Left j(-)
; Mac-style alt+left maps to home
CapsLock & -::
if GetKeyState("Shift", "D")
    if GetKeyState("Alt", "D")
        Send +{Home}
    else if GetKeyState("Ctrl", "D")
        Send +^{Left}
    else
        Send +{Left}
else if GetKeyState("Ctrl", "D")
    if (GetKeyState("Alt", "D"))
        Send ^{Home}
    else
        Send ^{Left}
else if GetKeyState("Alt", "D")
    Send {Home}
else
    Send {Left}
return

; Down k(k)
CapsLock & k::
if GetKeyState("Shift", "D")
    if GetKeyState("Alt", "D")
        SendInput +!{Down}
    else if GetKeyState("Ctrl", "D")
        Send +^{Down}
    else
        Send +{Down}
else if GetKeyState("Ctrl", "D")
    if (GetKeyState("Alt", "D"))
        SendInput ^!{Down}
    else
        Send ^{Down}
else if GetKeyState("Alt", "D")
    SendInput !{Down}
else
    Send {Down}
return

; Right l(c)
; Mac-style alt+left maps to end
CapsLock & c::
if GetKeyState("Shift", "D")
    if GetKeyState("Alt", "D")
        Send +{End}
    else if GetKeyState("Ctrl", "D")
        Send +^{Right}
    else
        Send +{Right}
else if GetKeyState("Ctrl", "D")
    if (GetKeyState("Alt", "D"))
        Send ^{End}
    else
        Send ^{Right}
else if GetKeyState("Alt", "D")
    Send {End}
else
    Send {Right}
return


; ToolTipOpt v1.004
; Changes:
;  v1.001 - Pass "Default" to restore a setting to default
;  v1.002 - ANSI compatibility
;  v1.003 - Added workarounds for ToolTip's parameter being overwritten
;           by code within the message hook.
;  v1.004 - Fixed text colour.

ToolTipFont(Options := "", Name := "", hwnd := "") {
    static hfont := 0
    if (hwnd = "")
        hfont := Options="Default" ? 0 : _TTG("Font", Options, Name), _TTHook()
    else
        DllCall("SendMessage", "ptr", hwnd, "uint", 0x30, "ptr", hfont, "ptr", 0)
}

ToolTipColor(Background := "", Text := "", hwnd := "") {
    static bc := "", tc := ""
    if (hwnd = "") {
        if (Background != "")
            bc := Background="Default" ? "" : _TTG("Color", Background)
        if (Text != "")
            tc := Text="Default" ? "" : _TTG("Color", Text)
        _TTHook()
    }
    else {
        VarSetCapacity(empty, 2, 0)
        DllCall("UxTheme.dll\SetWindowTheme", "ptr", hwnd, "ptr", 0
            , "ptr", (bc != "" && tc != "") ? &empty : 0)
        if (bc != "")
            DllCall("SendMessage", "ptr", hwnd, "uint", 1043, "ptr", bc, "ptr", 0)
        if (tc != "")
            DllCall("SendMessage", "ptr", hwnd, "uint", 1044, "ptr", tc, "ptr", 0)
    }
}

_TTHook() {
    static hook := 0
    if !hook
        hook := DllCall("SetWindowsHookExW", "int", 4
            , "ptr", RegisterCallback("_TTWndProc"), "ptr", 0
            , "uint", DllCall("GetCurrentThreadId"), "ptr")
}

_TTWndProc(nCode, _wp, _lp) {
    Critical 999
   ;lParam  := NumGet(_lp+0*A_PtrSize)
   ;wParam  := NumGet(_lp+1*A_PtrSize)
    uMsg    := NumGet(_lp+2*A_PtrSize, "uint")
    hwnd    := NumGet(_lp+3*A_PtrSize)
    if (nCode >= 0 && (uMsg = 1081 || uMsg = 1036)) {
        _hack_ = ahk_id %hwnd%
        WinGetClass wclass, %_hack_%
        if (wclass = "tooltips_class32") {
            ToolTipColor(,, hwnd)
            ToolTipFont(,, hwnd)
        }
    }
    return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", _wp, "ptr", _lp, "ptr")
}

_TTG(Cmd, Arg1, Arg2 := "") {
    static htext := 0, hgui := 0
    if !htext {
        Gui _TTG: Add, Text, +hwndhtext
        Gui _TTG: +hwndhgui +0x40000000
    }
    Gui _TTG: %Cmd%, %Arg1%, %Arg2%
    if (Cmd = "Font") {
        GuiControl _TTG: Font, %htext%
        SendMessage 0x31, 0, 0,, ahk_id %htext%
        return ErrorLevel
    }
    if (Cmd = "Color") {
        hdc := DllCall("GetDC", "ptr", htext, "ptr")
        SendMessage 0x138, hdc, htext,, ahk_id %hgui%
        clr := DllCall("GetBkColor", "ptr", hdc, "uint")
        DllCall("ReleaseDC", "ptr", htext, "ptr", hdc)
        return clr
    }
}

