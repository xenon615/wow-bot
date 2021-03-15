#include <Misc.au3>
#include <Array.au3>
#include <WinAPI.au3>
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>

Opt("PixelCoordMode", 2)
Opt("MouseCoordMode", 2)
local $hwnd = WinGetHandle("World of Warcraft")
WinActivate($hwnd)
WinWaitActive($hwnd)
Local $color_index = 0, $wait_time = 0, $Paused = False
local $clientSize = WinGetClientSize($hwnd)
Local $start_time = 0
Local $red_colors[1], $blue_colors[1], $bobber_colors[0], $bobber_tolerance, $splash_tolerance , $frame[4]
$dll = DllOpen("user32.dll")

HotKeySet("{F11}", "Pause")
HotKeySet("{F10}", "Kill")
HotKeySet("{F6}", 'Tolerance')
HotKeySet("{F7}", 'Tolerance')
HotKeySet("!{F6}", 'Tolerance')
HotKeySet("!{F7}", 'Tolerance')

Setup()
;~  ---



;~  ---

Func Pause()
	$Paused = NOT $Paused
	While $Paused
		Sleep(100)
	WEnd
EndFunc

;~  ---

Func Kill()
    IniWrite('fisher.ini', 'Common', 'bobber_tolerance', $bobber_tolerance)
    IniWrite('fisher.ini', 'Common', 'splash_tolerance', $splash_tolerance)
    IniWrite('fisher.ini', 'Common', 'frame', _ArrayToString($frame, ','))
    Exit
EndFunc

;~  ---

While(True)
    pole()
WEnd

;~ ---

Func Tolerance()
    If @HotKeyPressed == '{F6}' Then
        $bobber_tolerance = $bobber_tolerance - 1
        Debug('Bobber: ' & $bobber_tolerance)
    ElseIf @HotKeyPressed == '{F7}' Then
        $bobber_tolerance = $bobber_tolerance + 1
        Debug('Bobber: ' & $bobber_tolerance)
    ElseIf @HotKeyPressed == '!{F6}' Then
        $splash_tolerance = $splash_tolerance - 1
        Debug('Splash: ' & $splash_tolerance)
    Else
        $splash_tolerance = $splash_tolerance + 1
        Debug('Splash: ' & $splash_tolerance)
    EndIf    
Endfunc

;~  ---

Func pole()
    send('1')
    Sleep(1000)
    find()
EndFunc 

;~  ---

Func find()
    $wait_time = Random(10000, 30000)
    Local $start_time = TimerInit()
    While TimerDiff($start_time) < $wait_time
        
        local $pos = PixelSearch($frame[0], $frame[1], $frame[2], $frame[3], $bobber_colors[$color_index], $bobber_tolerance , 2)    
        If not @error Then
            Debug('Found ' & $color_index)
            MouseMove($pos[0], $pos[1])
            return splash($pos[0] , $pos[1])
        Else
            if Ubound($bobber_colors) == ($color_index + 1) Then
                $color_index = 0
            Else
                $color_index = $color_index + 1 
            EndIf
            Debug('Color index ' & $color_index)
        EndIf
        Sleep(100)
    WEnd
EndFunc 

;~  ---

Func splash($mouseX, $mouseY)
    $wait_time = Random(10000, 30000)
    Local $start_time = TimerInit()
    Local $dim = 20
    $x0 = $mouseX - $dim    
    $y0 = $mouseY - $dim
    $x1  = $mouseX + $dim
    $y1 = $mouseY + $dim
    $splash_color = 0xF6F6F6
    ;~ $splash_color = 0xFFFFFF
    While TimerDiff($start_time) < $wait_time
        $pos = PixelSearch($x0, $y0, $x1, $y1, $splash_color, $splash_tolerance, 2)
        if not @error then
            Sleep(Random(100, 1000))
            Send("{SHIFTDOWN}")
            Sleep(100)
            MouseClick("right", $pos[0], $pos[1], 1, 2)
            Sleep(100)
            Send("{SHIFTUP}")
            Sleep(Random(5000, 6000))
            ExitLoop
        endif
        Sleep(10)
    Wend
    pole()
EndFunc

;~  ---

Func Debug($text)
    ToolTip($text, 100, 100,'Info', 1, 1 + 4)
EndFunc 

;~  ---

Func Setup()
    Local $cn[2] = ['red', 'blue']
    For $i = 0 To 1
        Local $s = IniRead('fisher.ini', 'Common', $cn[$i] & '_colors', '')
        if $s <> '' Then
            Local $sa = StringSplit($s, ',')
            For $j=1 To $sa[0]
                _ArrayAdd($bobber_colors, Int(StringStripWS($sa[$j], 8)))
            Next 
        EndIf        
    Next 
    ;~ _ArrayDisplay($bobber_colors)    


    $bobber_tolerance = Int(IniRead('fisher.ini', 'Common', 'bobber_tolerance', '5'))
    $splash_tolerance = Int(IniRead('fisher.ini', 'Common', 'splash_tolerance', '15'))
    Local $fa = StringSplit(IniRead('fisher.ini', 'Common', 'frame', '0,0,0,0'), ',')
    For $i = 1 To 4
        $frame[$i - 1] = int(StringStripWS($fa[$i], 8))
    Next
    If $frame[3] == 0 Then
        Beep()
        Debug('click on upper left corner')
        While 1
            If _IsPressed("01") Then
                $frame[0] = MouseGetPos(0)
                $frame[1] = MouseGetPos(1)
                ExitLoop
            EndIf
        WEnd
        Sleep(1000)
        Beep()
        Debug('click on lower right corner')
        While 1
            If _IsPressed("01") Then
                $frame[2] = MouseGetPos(0)
                $frame[3] = MouseGetPos(1)
                ExitLoop
            EndIf
        WEnd
    
    EndIf
    ;~ _ArrayDisplay($frame)

    ConsoleWrite($bobber_tolerance & @LF)
    ConsoleWrite($splash_tolerance & @LF)
    ;~ Exit
    Beep(1000)
    
    MouseMove($frame[0], $frame[1], 1)
    MouseMove($frame[2], $frame[1], 50)
    MouseMove($frame[2], $frame[3], 50)
    MouseMove($frame[0], $frame[3], 50)
    MouseMove($frame[0], $frame[1], 50)
    Beep()
    MouseMove($clientSize[0] / 2, $clientSize[1] / 2, 0)
    
EndFunc

