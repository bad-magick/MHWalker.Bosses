#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Run_Obfuscator=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ScreenCapture.au3>
#include <WinAPI.au3>
#include <GDIPlus.au3>

AutoItSetOption("MustDeclareVars", 1)

Dim $clientPos[2]
Dim $clientSize[2]
Global $hBMP
Global $hBitmap
Global $BitmapData
Global $Stride
Global $Scan0
Dim $hasCap = False
Dim $hwnd
Dim $count
Dim $px

If (Not WinExists("[Class:Valve001;Title:Vindictus]")) Then
	MsgBox(0, "Error", "Vindictus window not found.")
	Exit
Else
	$hwnd = WinGetHandle("[Class:Valve001]")
EndIf
HotKeySet("{END}", "ExitApp")

MsgBox(0, "Check", "Make sure the Vindictus window is completely visible." & @CRLF & "Click in Vindictus and press END to stop." & @CRLF & "Bot will automaticallt start when you press Ok.")
_GDIPlus_Startup()
ControlSend($hwnd, "", "", "{NUMPAD3}")
UpdatePosition()

While(1)
	Sleep(2000)
	$count = 0
	Do
		Sleep(100)
		UpdatePosition()
		$count += 1
	Until ((ColorDistanceYUV(fastPixelGetColor(290, 12), 0xC31011) <= 16) Or (ColorDistanceYUV(fastPixelGetColor(290, 12), 0xCB2019) <= 16) Or ($count > 30))
	;MsgBox(0, "asdf", Hex(fastPixelGetColor(290, 12)))
	;Exit
	Sleep(2000)

	ControlSend($hwnd, "", "", "{NUMPADMULT}")
	ControlSend("", "", "", "", 0)
	ControlSend($hwnd, "", "", "{NUMPAD4}")
	ControlSend("", "", "", "", 0)
	ControlSend($hwnd, "", "", "[")
	ControlSend("", "", "", "", 0)
	Sleep(500)
	ControlSend($hwnd, "", "", "{NUMPAD4}")
	ControlSend("", "", "", "", 0)
	Sleep(1000)

	UpdatePosition()
	$count = 0
	$px = fastPixelGetColor($clientSize[0] / 2, $clientSize[1] / 4)
	Do
		Sleep(100)
		UpdatePosition()
		$count += 1
	Until (fastPixelGetColor($clientSize[0] / 2, $clientSize[1] / 4) <> $px) Or ($count > 30)

	ControlSend($hwnd, "", "", "{NUMPADDIV}")
	ControlSend("", "", "", "", 0)
	Sleep(3000)
	ControlSend($hwnd, "", "", "{NUMPADDIV}")
	ControlSend("", "", "", "", 0)

	Sleep(1000)
	ControlSend($hwnd, "", "", "{w DOWN}")
	ControlSend("", "", "", "", 0)
	Sleep(6500)
	ControlSend($hwnd, "", "", "{w UP}")
	ControlSend("", "", "", "", 0)

	Sleep(500)
	Dim $i = 0
	For $i = 1 To 15
		ControlSend($hwnd, "", "", "e")
		Sleep(200)
	Next
	ControlSend($hwnd, "", "", "{NUMPAD3}")
	ControlSend("", "", "", "", 0)
WEnd

Func ExitApp()
	If (WinActive($hwnd)) Then
		ReleaseScreen()
		_GDIPlus_Shutdown()
		MsgBox(0, "Exit", "Program aborted.")
		Exit
	Else
		HotKeySet("{END}")
		Send("{END}")
		HotKeySet("{END}", "ExitApp")
	EndIf
EndFunc

Func CaptureScreen ()
	If $hasCap Then
		ReleaseScreen()
	EndIf

	;Dim $w = _WinAPI_GetClientWidth($hwnd)
	;Dim $h = _WinAPI_GetClientHeight($hwnd)
	;Dim $hDDC = _WinAPI_GetDC($hwnd)
	;Dim $hCDC = _WinAPI_CreateCompatibleDC($hDDC)
	;$hBMP = _WinAPI_CreateCompatibleBitmap($hDDC, $w, $h)
	;_WinAPI_SelectObject($hCDC, $hBMP)
	;_WinAPI_BitBlt($hCDC, 0, 0, $w, $h, $hDDC, 0, 0, 0x00CC0020)
	;_WinAPI_ReleaseDC($hwnd, $hDDC)
	;_WinAPI_DeleteDC($hCDC)

	$hBMP = _ScreenCapture_Capture("", $clientPos[0], $clientPos[1], $clientPos[0] + $clientSize[0], $clientPos[1] + $clientSize[1], False)
	$hBitmap = _GDIPlus_BitmapCreateFromHBITMAP ($hBMP)
	$BitmapData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, _GDIPlus_ImageGetWidth($hBitmap), _GDIPlus_ImageGetHeight($hBitmap), BitOR($GDIP_ILMREAD, $GDIP_ILMWRITE), $GDIP_PXF32RGB)
	$Stride = DllStructGetData($BitmapData, "Stride")
	$Scan0 = DllStructGetData($BitmapData, "Scan0")
	$hasCap = True
EndFunc

Func ReleaseScreen()
	If $hasCap Then
		_GDIPlus_BitmapUnlockBits($hBitmap, $BitmapData)
		_GDIPlus_ImageDispose($hBitmap)
		_WinAPI_DeleteObject($hBMP)
		$hasCap = False
	EndIf
EndFunc

Func fastPixelGetColor ($x, $y)
	If (($x == 0) And ($y == 0)) Then
		Return 0
	EndIf
	Dim $pixel = DllStructCreate("dword", $Scan0 + ($y * $Stride) + ($x * 4))
	Return BitAnd(DllStructGetData($pixel, 1), 0x00FFFFFF)
EndFunc

Func UpdatePosition()
	Dim $tPoint = DllStructCreate("int X;int Y")
	DllStructSetData($tPoint, "X", 0)
	DllStructSetData($tPoint, "Y", 0)
	_WinAPI_ClientToScreen(WinGetHandle("[Class:Valve001]"), $tPoint)
	Dim $x = DllStructGetData($tPoint, "X")
	Dim $y = DllStructGetData($tPoint, "Y")
	$clientPos[0] = $x

	$clientPos[1] = $y
	$clientSize = WinGetClientSize("[Class:Valve001]")
	CaptureScreen()
EndFunc

Func GetRed($color)
	Return BitShift(BitAND($color, 0xFF0000), 0x10)
EndFunc

Func GetGreen($color)
	Return BitShift(BitAnd($color, 0x00FF00), 0x08)
EndFunc

Func GetBlue($color)
	Return BitAND($color, 0x0000FF)
EndFunc

Func RGBtoYUV($color)
	Dim $YUV[3]
	$YUV[0] = 0.299 * GetRed($color) + 0.587 * GetGreen($color) + 0.114 * GetBlue($color)
	$YUV[1] = (GetBlue($color) - $YUV[0]) * 0.565
	$YUV[2] = (GetRed($color) - $YUV[0]) * 0.713
	Return $YUV
EndFunc

Func _ColorDistanceYUV($color1, $color2)
	Return Sqrt((($color1[0] - $color2[0])^2) + (($color1[1] - $color2[1])^2) + (($color1[2] - $color2[2])^2))
EndFunc

Func ColorDistanceYUV($color1, $color2)
	Return _ColorDistanceYUV(RGBtoYUV($color1), RGBtoYUV($color2))
EndFunc

Func ColorDistanceRGB($color1, $color2)
	Return Sqrt(((GetRed($color1) - GetRed($color2))^2) + ((GetGreen($color1) - GetGreen($color2))^2) + ((GetBlue($color1) - GetBlue($color2))^2))
EndFunc
