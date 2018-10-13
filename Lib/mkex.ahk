#if mkex.inKW
#if
class mkex
	{
	static inKW
	clickImage(imageAndOptions, xOffset := 0, yOffest := 0, coMode := "window", notFoundMsg := true)
		{
		mouseex_clickimage_retry:
		;if(wholeScreen)
			
		winGetPos,,, width, height, a
		imageSearch, x, y, 0, 0, % width, % height, % imageAndOptions
		controlClick, % format("x{} y{}", x + xOffset, y + yOffest), a 
		if(not errorLevel)
			return [x, y]
		else
			{
			if(notFoundMsg)
				{
				msgBox, 2, % imageAndOptions, The Image was not found.
				ifMsgBox, abort
					exitApp
				ifMsgBox, retry
					goto, mouseex_clickimage_retry
				}
			return false
			}
		}
	keyWait()
		{
		mkex.inKW := true
		kwc := mkex.kwHelp.cancel.bind(kwHelp)
		hotkey, if, mkex.inKW
		hotkey, ~lButton, % kwc
		hotkey, if
		Input, keyName, l1, {Escape}{Backspace}{LControl}{LShift}{NumpadMult}{LAlt}{CapsLock}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{Pause}{ScrollLock}{NumpadHome}{NumpadUp}{NumpadPgUp}{NumpadSub}{NumpadLeft}{NumpadClear}{NumpadRight}{NumpadAdd}{NumpadEnd}{NumpadDown}{NumpadPgDn}{NumpadIns}{NumpadDel}{PrintScreen}{F11}{F12}{Help}{F13}{F14}{F15}{F16}{F17}{F18}{F19}{F20}{F21}{F22}{F23}{F24}{Media_Prev}{Media_Next}{NumpadEnter}{RControl}{Volume_Mute}{Launch_App2}{Media_Play_Pause}{Media_Stop}{Volume_Down}{Volume_Up}{Browser_Home}{NumpadDiv}{RShift}{RAlt}{Numlock}{CtrlBreak}{Home}{Up}{PgUp}{Left}{Right}{End}{Down}{PgDn}{Insert}{Delete}{LWin}{RWin}{AppsKey}{Sleep}{Browser_Search}{Browser_Favorites}{Browser_Refresh}{Browser_Stop}{Browser_Forward}{Browser_Back}{Launch_App1}{Launch_Mail}{Launch_Media}{Numpad0}{Numpad1}{Numpad2}{Numpad3}{Numpad4}{Numpad5}{Numpad6}{Numpad7}{Numpad8}{Numpad9}{NumpadDot}
		if((el := errorLevel) ~= "EndKey:")
			regExMatch(el, "[^:]+$", keyName)
		mkex.inKW := false
		return getKeyName(keyName)
		}
	class kwHelp
		{
		cancel()
			{
			input
			mkex.inKW := false ;for threads that cause keyWait() to buffer
			}
		}
	paste(text := "")
		{
		if(text)
			clipboard := text
		sendInput, ^v
		}
	}