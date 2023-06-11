#Requires AutoHotkey v1.1

; Install AutoHotkey 1.1 to run this script https://www.autohotkey.com/
;
; Monitors the color of the top left pixel of the WoW window and sends a keypress event
; every time the pixel turns gray, when a hardware event is required to proceed.

TRIGGER_KEY := "{Pause}" ; Key used to trigger the hardware event in WoW
PIXEL_COLOR := "0x333333" ; Color of the top left pixel when MessageQueue has pending actions requiring a hardware event

Loop {
	; Get all World of Warcraft window IDs
	WinGet, windowIds, List, World of Warcraft

	; Iterate over all WoW windows
	Loop %windowIds% {
		; Get window ID
		windowId := windowIds%A_Index%

		; Fetch WoW client position on screen, regardless of the window borders
		VarSetCapacity(clientRect, 16, 0)
		DllCall("user32\ClientToScreen", Ptr,windowId, Ptr,&clientRect)
		clientX := NumGet(&clientRect, 0, "Int")
		clientY := NumGet(&clientRect, 4, "Int")

		; Get top left pixel color
		CoordMode, Pixel, Screen
		PixelGetColor, color, clientX, clientY

		; Pixel matches trigger color
		if (color = PIXEL_COLOR) {
			; Send trigger key to the targeted window
			ControlSend, , %TRIGGER_KEY%, ahk_id %windowId%

			; Add delay to prevent button spam and being accidentally flagged for botting by WoW's anti-cheat system
			Random delay, 300, 600
			Sleep delay
		}
	}

	Sleep 5 ; 5ms corresponds to 200 FPS/Hz. Should fit all screen refresh rates.
}
