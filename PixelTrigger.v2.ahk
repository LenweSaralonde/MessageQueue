#Requires AutoHotkey v2.0

; Install AutoHotkey 2.0 to run this script https://www.autohotkey.com/
;
; Monitors the color of the top left pixel of the WoW window and sends a keypress event
; every time the pixel turns gray, when a hardware event is required to proceed.

TRIGGER_KEY := "{Pause}" ; Key used to trigger the hardware event in WoW
PIXEL_COLOR := "0x333333" ; Color of the top left pixel when MessageQueue has pending actions requiring a hardware event

Loop {
	; Get all World of Warcraft window IDs
	windowIds := WinGetList("World of Warcraft")

	; Iterate over all WoW windows
	for windowId in windowIds {
		; Fetch WoW client position on screen, regardless of the window borders
		WinGetClientPos &clientX, &clientY, &clientW, &clientH, windowId

		; Get top left pixel color
		CoordMode "Pixel", "Screen"
		color := PixelGetColor(clientX, clientY)

		; Pixel matches trigger color
		if (color = PIXEL_COLOR) {
			; Send trigger key to the targeted window
			ControlSend TRIGGER_KEY, windowId

			; Add delay to prevent button spam and being accidentally flagged for botting by WoW's anti-cheat system
			delay := Random(300, 600)
			Sleep delay
		}
	}

	Sleep 5 ; 5ms corresponds to 200 FPS/Hz. Should fit all screen refresh rates.
}
