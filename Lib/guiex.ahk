#include <mkex>
#if guiex.tabHelp.focused(guiex.tabHelp.loops) && not mkex.inKW
#if
detectHiddenWindows, on

class guiex
	{
	align(changing, reference, xywh, alignment := .5, guiName := "") ;aligns one control with another
		{
		guiControlGet, %changing%, %guiName%pos
		guiControlGet, %reference%, %guiName%pos
		if(guiName)
			guiName .= ":"
		if(xywh = "x" or xywh = "y")
			{
			wh := xywh = "x" ? "W" : "H"
			if(xywh = "x")
				wh := "W"
			else
				wh := "H"
			guiControl, %guiName%move, % changing, % format(xywh "{}", round(%reference%%xywh% + %reference%%wh% * alignment - %changing%%wh% * alignment))
			}
		else
			{
			xy := xywh = "w" ? "X" : "Y"
			guiControl, %guiName%move, % changing, % format(xywh "{}", %reference%%xy% + %reference%%xywh% * alignment - %changing%%xy%)
			}
		}
	backMove(winTitle := "" , winText := "", excludeTitle := "", exludeText := "") ;makes the non-interactable client aera able to move the window via click and drag
		{
		winGetPos,,, width, height, %winTitle%, %winText%, %excludeTitle%, %excludeText%
		gui, add, text, gguiex.backMoveFunc w%width% h%height% x0 y0 backgroundTrans
		}
	backMoveFunc() ;the function that makes backMove work
		{
		postMessage, 0xA1, 2
		return
		}
	hkGroup(hks, vars, limits := "", positioning := "", hkBoxWidth := "", xPadding := "m", yPadding := "m", guiName := "") ;creates a group of hotkey boxes with text to the left explaining what they're for
		{
		local firstVarStr := vars[1]
		local lastVarStr := vars[vars.length()]
		static c := 1
		if(limits) ;sets up the hotkey limits
			{
			if(not isObject(limits))
				local limNum := limits
				limits := []
				loop, % hks.length()
					limits.push(limNum)
			}
		else
			{
			limits := []
			loop, % hks.length()
				limits.push(0)
			}
		if(hkBoxWidth)
			hkBoxWidth := "w" hkBoxWidth
		if(guiName)
			guiName .= ":"
		gui, %guiName%add, text, % format("v{} {} right section", "hkGroup" c "_text1", positioning), % hks[1] ":"
		local k, v
		for k, v in hks
			if(k >= 2)
				gui, %guiName%add, text, % format("v{} right", "hkGroup" c "_text" k), % v ":"
		gui, %guiName%add, hotkey, % format("v{} x+{} ys {} limit{}", vars[1], xPadding, hkBoxWidth, limits[1]), % %firstVarStr%
		for k, v in vars
			if(k >= 2)
			gui, %guiName%add, hotkey, % format("v{} y+{} {} limit{}", v, yPadding, hkBoxWidth, limits[k]), % %v%
		local maxTextWidth := 0
		for k, v in vars ;gets info for positioning
			{
			guiControlGet, %v%, %guiName%pos
			guiControlGet, hkGroup%c%_text%k%, %guiName%pos
			if(hkGroup%c%_text%k%W > maxTextWidth)
				maxTextWidth := hkGroup%c%_text%k%W
			}
		local l := hks.length()
		local m
		if(xPadding = "m")
			m := %lastVarStr%X - (hkGroup%c%_text%l%X + hkGroup%c%_text%l%W)
		else
			m := xPadding
		for k, v in vars ;positions the controls
			{
			guiControl, %guiName%move, hkGroup%c%_text%k%, % format("w{} y{}", maxTextWidth, %v%Y + round((%v%H - hkGroup%c%_text%k%H) / 2))
			if(%v%X - (hkGroup%c%_text%k%X + maxTextWidth) != m)
				guiControl, %guiName%move, %v%, % "x" hkGroup%c%_text%k%X + maxTextWidth + m
			}
		local x1 := hkGroup%c%_text1X
		local y1 := %firstVarStr%Y
		local x2 := hkGroup%c%_text1X + maxTextWidth + m + %firstVarStr%W
		local y2 := %lastVarStr%Y + %lastVarStr%H
		gui, %guiName%add, text, % format("x{} y{} w{} h{} hidden", x1, y1, x2 - x1, y2 - y1)
		c++
		;gui, %guiName%show, hide autoSize
		}
	keyWait(options := "", waitText := "waiting...", guiName := "") ;makes a button that when pressed waits for a key to be pressed, similar to a hotkey but can use more keys and only takes in one key
		{
		global
		static c := 0
		local var, var1
		regExMatch(options, "i)v(\S+)", var)
		if(var1)
			guiex.kwHelp.text[var1] := waitText	
		else
			{
			local vLabel := "vkeyWait" ++c
			guiex.kwHelp.text["keyWait" c] := waitText
			}
		if(guiName)
			guiName .= ":"
		gui, %guiName%add, button, % vLabel " gguiex.kwHelp.getKey " options , % waitText ;if vLable is empty, the assigned variable is in the options
		if(%var1%)
			guiControl, %guiName%text, % var1, % %var1%
		else
			guiControl, %guiName%text, % var1
		}
	class kwHelp ;support for keyWait
		{
		static text := {}
		static currentKW
		static inTimer
		getKey()
			{
			if(guiex.kwHelp.inTimer)
				{
				guiName := guiex.kwHelp.currentKW.guiName ":"
				guiControl, %guiName%text, % guiex.kwHelp.currentKW.id
				guiex.kwHelp.inTimer := false
				}
			guiControl, text, % a_guiControl ;, % guiex.kwHelp.text[a_guiControl]
			%a_guiControl% := ;Has to be here because if you close a window in the middle of a mkex keyWait the variable won't update
			t := guiex.kwHelp.waitingTimer.bind(kwHelp)
			guiex.kwHelp.currentKW := {id: a_guiControl, guiName: a_gui, text: guiex.kwHelp.text[a_guiControl]}
			setTimer, % t, 1400
			;guiex.kwHelp.waitingTimer()
			if(%a_guiControl% := mkex.keyWait())
				{
				setTimer, % t, delete
				guiControl, text, % a_guiControl, % %a_guiControl%
				}
			else
				{
				setTimer, % t, delete
				guiControl, text, % a_guiControl
				}
			}
		waitingTimer()
			{
			guiex.kwHelp.inTimer := true
			guiName := guiex.kwHelp.currentKW.guiName ":"
			guiControl, %guiName%text, % guiex.kwHelp.currentKW.id, % guiex.kwHelp.currentKW.text
			t := a_tickCount
			while a_tickCount - t < 700 and a_timeIdleKeyboard >= 500 and mkex.inKW
				{}
			guiControl, %guiName%text, % guiex.kwHelp.currentKW.id
			guiex.kwHelp.inTimer := false
			}
			
		}
	kwGroup(kws, vars, waitText := "waiting...", positioning := "", kwBoxWidth := "", xPadding := "m", yPadding := "m", guiName := "") ;creates a group of keyWait buttons with text to the left explaining what they're for
		{
		local firstVarStr := vars[1]
		local lastVarStr := vars[vars.length()]
		static c := 1
		if(kwBoxWidth)
			kwBoxWidth := "w" kwBoxWidth
		if(guiName)
			guiName .= ":"
		gui, %guiName%add, text, % format("v{} {} right section", "kwGroup" c "_text1", positioning), % kws[1] ":"
		local k, v
		for k, v in kws
			if(k >= 2)
				gui, %guiName%add, text, % format("v{} right", "kwGroup" c "_text" k), % v ":"
		guiex.keyWait(format("v{} x+{} ys {}", vars[1], xPadding, kwBoxWidth), waitText, guiName)
		for k, v in vars
			if(k >= 2)
				guiex.keyWait(format("v{} y+{} {} limit{}", v, yPadding, kwBoxWidth), waitText, guiName)
		local maxTextWidth := 0
		for k, v in vars ;gets info for positioning
			{
			guiControlGet, %v%, %guiName%pos
			guiControlGet, kwGroup%c%_text%k%, %guiName%pos
			if(kwGroup%c%_text%k%W > maxTextWidth)
				maxTextWidth := kwGroup%c%_text%k%W
			}
		local l := kws.length()
		local m
		if(xPadding = "m")
			m := %lastVarStr%X - (kwGroup%c%_text%l%X + kwGroup%c%_text%l%W)
		else
			m := xPadding
		for k, v in vars ;positions the controls
			{
			guiControl, %guiName%move, kwGroup%c%_text%k%, % format("w{} y{}", maxTextWidth, %v%Y + round((%v%H - kwGroup%c%_text%k%H) / 2))
			if(%v%X - (kwGroup%c%_text%k%X + maxTextWidth) != m)
				guiControl, %guiName%move, %v%, % "x" kwGroup%c%_text%k%X + maxTextWidth + m
			}
		local x1 := kwGroup%c%_text1X
		local y1 := %firstVarStr%Y
		local x2 := kwGroup%c%_text1X + maxTextWidth + m + %firstVarStr%W
		local y2 := %lastVarStr%Y + %lastVarStr%H
		gui, %guiName%add, text, % format("x{} y{} w{} h{} hidden", x1, y1, x2 - x1, y2 - y1)
		c++
		;gui, %guiName%show, hide autoSize
		}
	tab(T)
		{
		for guiName, tabLoops in T
			{
			guiex.tabHelp.loops[guiName] := {}
			for k, tabLoop in tabLoops
				guiex.tabHelp.loops[guiName].push(tabLoop)
			}	
		next := guiex.tabHelp.next.bind(guiex.tabHelp)
		hotkey, if, guiex.tabHelp.focused(guiex.tabHelp.loops) && not mkex.inKW
		hotkey, tab, % next
		hotkey, +tab, % next
		hotkey, if
		}
	class tabHelp
		{
		static loops := {}
		static c := 0
		focused(T)
			{
			for guiName, tabLoops in T
				{
				guiControlget, control, %guiName%:focusV
				for k, tabLoop in tabLoops
					for j, cont in tabLoop
						if(control = cont)
							return {guiName: guiName
								,loop: tabLoop
								,spot: j}
				}
			}
		next(control := "")
			{
			if(not control)
				control := guiex.tabHelp.focused(guiex.tabHelp.loops)
			if(not a_thisHotkey ~= "\+")
				nextSpot := control.spot = control.loop.length() ? 1 : control.spot + 1
			else
				nextSpot := control.spot = 1 ? control.loop.length() : control.spot - 1
			guiName := control.guiName
			guiControlGet, visible, %guiName%:visible, % control.loop[nextSpot]
			guicontrolGet, enabled, %guiName%:enabled, % control.loop[nextSpot]
			if(visible and enabled)
				{
				guiControl, %guiName%:focus, % control.loop[nextSpot]
				try guiControl, %guiName%:+default, % control.loop[nextSpot]
				}
			else
				guiex.tabHelp.next({guiName: guiName
					,loop: control.loop
					,spot: nextSpot})
			}
		}
	}
