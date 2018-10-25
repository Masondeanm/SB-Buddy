#include <guiex>
#include <iniex>
#include <contain>
#singleInstance, force
#UseHook
#maxHotkeysPerInterval, 1000
sendMode, input

contain("SB Buddy")
fileInstall, icon.ico, icon.ico
fileInstall, suspend.ico, suspend.ico
fileInstall, settings.ini, settings.ini

menu, tray, noStandard
menu, tray, icon, icon.ico,, 1
menu, tray, tip, SB Buddy
menu, tray, add, Hotkeys, launchHotkey
menu, tray, add, Swap Profiles, launchProfiles
menu, tray, add, Help, launchHelp
menu, tray, add, Close, close

ini := {suspend: ["susp"]
	,chat: ["command", "fac", "reply"]
	,controls: ["attack", "chat", "down", "equip", "inv", "jump", "left", "right", "up"]
	,"warp toggle": ["warp_toggle"]
	,options: ["chatBreak", "moving_swap", "use_chatBreak"]
	,profiles: {}}
loop, 5
{i := a_index
	loop, 8
		{
		ini.profiles.push("p" i a_index)
		if(a_index <= 7)
			ini.profiles.push("c" i a_index)
		}
	}
iniex.create(ini)
iniex.get()
currentProfile := 1
tabLoops := {profiles: []}
loop, 5
{p := a_index
	buttons := []
	loop, 8
		buttons.push("p" p a_index)
	tabLoops.profiles.push(buttons)
	}
guiex.tab(tabLoops)
;gosub, launchHotkey
assignKeys:
	if(not susp)
		msgBox, It's highly recommended that you assign a key to suspend the script. This will toggle the program on and off if needed. (Do not use "Esc".)
	if(not chat)
		msgBox, Entering your "Chat" key is very important. It's used to suspend the program so you can chat without having to suspend the program manually. It is also necessary for using the chat hotkeys.
	for k, v in suspendKeys
		try hotkey, % v, off
	for k, v in chatCommands
		try hotkey, % v, off
	try hotkey, % warpToggle, off
	inputs := [up, down, left, right, attack, jump]
	chatCommands := {fac: fac, command: command, reply: reply}
	suspendKeys := [susp, chat]
	warpToggle := warp_toggle
	hotkey, ifWinActive, StarBreak
	for k, v in chatCommands
		try hotkey, % v, % k, on
	gosub, suspend
	if(use_chatBreak)
		gosub, chatBreak
	if(inv and equip and down and right)
		{
		if(moving_swap and not (up and left and attack))
			msgBox, Not all keys are assigned. Those that aren't cannot be used while you swap items.
		profiles := []
		loop, 5
		{p := a_index
			profiles.push([])
			c := 1
			while c <= 8
				{
				d := c + 1
				if(c%p%%c% and p%p%%c% and p%p%%d%)
					{
					cycle := [p%p%%c%]
					c++
					cycle.push(p%p%%c%)
					profiles[p].push(cycle)
					}
				else if(p%p%%c%)
					profiles[p].push(p%p%%c%)
				else
					break
				c++
				}
			}
		loop, 5
			hotkey, +%a_index%, itemSwap
		gosub, itemSwap
		}
	return
suspend:
	try hotkey, % susp, suspend2, on
	try hotkey, % chat, suspend3, on
	return
suspend2:
	suspend
	if(a_isSuspended)
		menu, tray, icon, suspend.ico
	else
		menu, tray, icon, icon.ico
	return
suspend3:
	suspend
	if(a_isSuspended)
		menu, tray, icon, suspend.ico
	else
		menu, tray, icon, icon.ico
	send, {%chat%}
	return
#if winActive("StarBreak")
~esc::
	suspend, off
	menu, tray, icon, icon.ico
	return
~lButton::
	suspend, off
	menu, tray, icon, icon.ico
	return
fac:
	suspend, on
	menu, tray, icon, suspend.ico
	send, {%chat%}/f{space}
	return
reply:
	suspend, on
	menu, tray, icon, suspend.ico
	send, {%chat%}/r{space}
	return
command:
	suspend, on
	menu, tray, icon, suspend.ico
	send, {%chat%}/
	return
chatBreak:
	if(not (up and down and left and right and attack and jump))
		msgBox, Not all keys are assigned. Those that aren't cannot be used to break out of chat.
	for i, v in inputs
		{
		x := i + 1
		while x <= inputs.length()           
			{
			try hotkey, % "~" . v . " & ~" . inputs[x], break
			try hotkey, % "~" . inputs[x] . " & ~" . v, break
			x++
			}
		}
		return
break:
	suspend, permit
	if(a_isSuspended)
		{
		regExMatch(a_thisHotkey, "~(.+) & ~(.+)", keys)
		for i, v in inputs
			if(getKeyState(v, "p") and v != keys1 and v!= keys2)
				{
				input := v
				send, {bs}{bs}{bs}{esc}{%v% down}{%keys1% down}
				if(keys2 = attack)
					sleep, 25
				send, {%keys2% down}
				suspend, off
				menu, tray, icon, icon.ico
				if(not getKeyState(keys2, "p"))
					send, {%keys2% up}
				break
				}
		}
	return
itemSwap:
	for k, v in cycleRef
		try hotkey, % k, off
	for k, v in selectRef
		try hotkey, % k, off
	if(a_thisHotkey ~= "^\+[1-5]$")
		currentProfile := subStr(a_thisHotkey, 2)
	cycleVar := []
	cycleRef := {}
	selectRef := {}
	counter := 0
	WTTracker := 1
	if(warp_toggle and not(up and left))
		msgBox, Up and Left must be assigned to use Warp Toggle.
	else
		try hotkey, % warp_toggle, warpToggle, on
	for i, v in profiles[currentProfile]
		{
		if(isObject(v))
			{
			cycleVar.insertAt(cycleVar.length() + 1, 0)
			counter += 2
			cycleRef[v[1]] := {cycle: cycleVar.length(), spot: counter - 1, direction: 0}
			cycleRef[v[2]] := {cycle: cycleVar.length(), spot: counter - 1, direction: 1}
			hotkey, % v[1], cycle, on
			hotkey, % v[2], cycle, on
			}
		else
			{
			counter ++
			selectRef[v] := counter
			if(v)
				hotkey, % v, select, on
			}
		}
	selectRef[warp_toggle] := counter + 1
	return
cycle:
	cycle := cycleRef[a_thisHotkey].cycle
	spot := cycleRef[a_thisHotkey].spot
	direction := cycleRef[a_thisHotkey].direction
	if cycleVar[cycle] = mod(0 + direction, 2)
		{
		cycleVar[cycle] := mod(0 + direction + 1, 2)
		selectRef[a_thisHotkey] := spot
		goto, select
		}
	else
		{
		cycleVar[cycle] := mod(0 + direction, 2)
		selectRef[a_thisHotkey] := spot + 1
		goto, select
		}
	return
select:
	spot := selectRef[a_thisHotkey]	
	send, {%inv%}
	if(spot != 1)
		if(spot = 2 or spot = 3)
			{
			send, {%right%}
			if(spot = 3)
				send, {%right%}
			}
		else if(spot > 3)
			{
			send, {%down%}
			if(spot != 4)
				if(spot = 5 or spot = 6)
					{
					send, {%right%}
					if(spot = 6)
						send, {%right%}
					}
				else
					{
					send, {%down%}
					if(spot = 8)
						send, {%right%}
					}
			}
	/*if(spot = 2)
		send, {%right%}
	else if(spot = 3)
		send, {%right%}{%right%}
	else if(spot = 4)
		send, {%down%}
	else if(spot = 5)
		send, {%down%}{%right%}
	else if(spot = 6)
		send, {%down%}{%right%}{%right%}
	else if spot = 7
		send, {%down%}{%down%}
	else if(spot = 8)
		send, {%down%}{%down%}{%right%}
		*/
	send, {%equip%}{%inv%}
	if(moving_swap)
		{
		for i, v in inputs
			if(v != jump)
				if(getKeyState(v, "p"))
					send, % "{" . inputs[i] . " down}"
		for i, v in inputs
			if(v != jump)
				if(not getKeyState(v, "p"))
					send, % "{" . inputs[i] . " up}"
		}
	return
warpToggle:
	if(WTTracker = 1)
		{
		send, {%inv%}{%up%}{%left%}{%left%}{%equip%}{%inv%}
		WTTracker := 0
		}
	else
		{
		gosub, select
		WTTracker := 1
		}
	if(moving_swap)
		{
		for i, v in inputs
			if(v != jump)
				if(getKeyState(v, "p"))
					send, % "{" . inputs[i] . " down}"
		}
	return
launchHotkey:
	gui, hotkeys:new
	gui, font, s10 w600
	gui, add, text,, Suspend Hotkey:
	gui, font
	guiex.keyWait("vsusp w60")
	gui, font, s10 w600
	gui, add, text, y+20, Chat Hotkeys:
	gui, font
	guiex.kwGroup(["Chat Command", "Faction Chat", "Reply"], ["command", "fac", "reply"],,, 60)
	gui, font, s10 w600
	gui, add, text, y+20, Warp Toggle:
	gui, font
	guiex.keyWait("vwarp_toggle w60")
	gui, font, s10 w600
	gui, add, text, y+20, Options:
	gui, font
	moving_swap := moving_swap ? moving_swap : 0
	use_chatBreak := use_chatBreak ? use_chatBreak : 0
	gui, add, checkbox, vmoving_swap checked%moving_swap% right, Moving Swap:
	gui, add, checkbox, vuse_chatBreak checked%use_chatBreak% right, ChatBreak:
	gui, font, s10 w600
	gui, add, text, x200 ym, Controls:
	gui, font
	guiex.kwGroup(["Inventory", "Iteract", "Up", "Down", "Left", "Right", "Main Attack", "Jump", "Chat"]
		,["inv", "equip", "up", "down", "left", "right", "attack", "jump", "chat"],,, 60)
	guiex.align("use_chatBreak", "moving_swap", "x", 1)
	gui, show,, Hotkey Setup
	return
launchProfiles:
	gui, profiles:new
	gui, add, tab2, gupdateProfile buttons, 1|2|3|4|5
	loop, 5
	{pLoopIndex := a_index
		loop, 7
			cState%a_index% := c%pLoopIndex%%a_index% ? c%pLoopIndex%%a_index% : 0
		gui, tab, % a_index
		guiex.keyWait("vp" a_index "1 section w60 h60")
		guiex.keyWait("vp" a_index "4 w60 h60")
		guiex.keyWait("vp" a_index "7 w60 h60")
		gui, add, checkbox, vc%a_index%1 gcycleCheck checked%cState1% -tabStop x+m ys w13 h13
		gui, add, checkbox, vc%a_index%4 gcycleCheck checked%cState4% -tabStop w13 h13
		gui, add, checkbox, vc%a_index%7 gcycleCheck checked%cState7% -tabStop w13 h13
		guiex.keyWait("vp" a_index "2 x+m ys w60 h60")
		guiex.keyWait("vp" a_index "5 w60 h60")
		guiex.keyWait("vp" a_index "8 w60 h60")
		gui, add, checkbox, vc%a_index%2 gcycleCheck checked%cState2% -tabStop x+m ys w13 h13
		gui, add, checkbox, vc%a_index%5 gcycleCheck checked%cState5% -tabStop w13 h13
		guiex.keyWait("vp" a_index "3 x+m ys w60 h60")
		guiex.keyWait("vp" a_index "6 w60 h60")
		gui, add, checkbox, vc%a_index%3 gcycleCheck checked%cState3% -tabStop x+m ys w13 h13
		gui, add, checkbox, vc%a_index%6 gcycleCheck checked%cState6% -tabStop w13 h13
		alignmentObj := [1, 1, 1, 4, 4, 4, 7]
		loop, 7
			{
			guiex.align("c" pLoopIndex a_index, "p" pLoopIndex alignmentObj[a_index], "y")
			if(cState%a_index%)
				{
				prev := a_index - 1
				next := a_index + 1
				guiControl, hide, c%pLoopIndex%%prev%
				guiControl, hide, c%pLoopIndex%%next%
				}
			}
		}
	gui, show,, Swap Profiles
	return
hotkeysGuiClose:
	gui, submit
	iniex.put()
	gosub assignKeys
	return
profilesGuiClose:
	gui, submit
updateProfile:
	iniex.put()
	gosub, assignKeys
	return
cycleCheck:
	guiControlGet, %a_guiControl%
	regExMatch(a_guiControl, "c(?P<profile>\d)(?P<cycle>\d)", cbInfo)
	if(cbInfoCycle >= 2)
		{
		prev2 := cbInfoCycle - 2
		prev := cbInfoCycle - 1
		}
	else
		{
		prev2 := 
		prev := 
		}
	next := cbInfoCycle + 1
	next2 := cbInfoCycle + 2
	if(%a_guiControl%)
		{
		guiControl, hide, c%cbInfoProfile%%prev%
		guiControl, hide, c%cbInfoProfile%%next%
		}
	else
		{
		guiControlGet, c%cbInfoProfile%%prev2%
		guiControlGet, c%cbInfoProfile%%next2%
		if(not c%cbInfoProfile%%prev2%)
			guiControl, show, c%cbInfoProfile%%prev%
		if(not c%cbInfoProfile%%next2%)
			guiControl, show, c%cbInfoProfile%%next%		
		}
	return
launchHelp:
	gui, help:new
	gui, add, text,, (click to see help)
	gui, font, s10 w600
	gui, add, text, gchatBreakHelp, ChatBreak
	gui, add, text, gmovingSwapHelp, Moving Swap
	gui, add, text, gsuspendHelp, Suspending
	gui, add, text, gprofileHelp, Swap Profiles
	gui, add, text, gwarpToggleHelp, Warp Toggle
	gui, show, w188, Help
	return
chatBreakHelp:
	gui, new
	gui, font, s10
	gui, add, text, w300, If ChatBreak is on, pressing three of your movement/attack keys at the same time while in chat mode will cause your character to break out of chat mode.
	gui, show,, ChatBreak
	return
movingSwapHelp:
	gui, new
	gui, font, s10
	gui, add, text, w300, If you check Moving Swap in the Hotkeys section, your character will be able to swap items without interrupting your movement and attacking. It is not perfect however. Due to how the game handels opening your inventory while the "Jump" button is pressed down, if you swap while having your jump button down, you will perform a full height jump.
	gui, show,, Moving Swap
	return
suspendHelp:
	gui, new
	gui, font, s10
	gui, add, text, w300,
		(lTrim join`n`n
		Suspending SB Buddy will disable all of its features. This is useful if you ever want to use keys that SB Buddy uses, for somethings else. The suspend key (that you can set up in the Hotkeys section) will toggle the suspension of the SB Buddy on and off.
		Your "Chat" key will automatically suspend SB Buddy, allowing you to type whatever you want without having to use your suspend key to toggle SB Buddy off when you type. Hitting "Chat" again to send the message will resume SB Buddy.
		Esc and the Left Mouse Button automatically unsuspend SB Buddy. This way if you quit out of chat mode without sending a message, SB buddy will still go back to being active.
		All features that involve the game's chat mode intelligently toggle the suspension so that you should never have to do it manually while using them.
		)
	gui, show,, ChatBreak
	return
profileHelp:
	gui, new
	gui, font, s10
	gui, add, text, w300,
		(lTrim join`n`n
		SB Buddy uses what are called Swap Profiles. Each profile lets you set up a different way your swap keys will work. (This is only needed if you're going to use different cycles for different shells.) You can make up to 5 profiles (one for each shell) and you'll be able to switch between them by using "Shift" plus "1", "2", "3", "4", or "5".
		Click (or hit Enter/Space) over one of the blank spots in the Swap Profiles section to assign a key that will swap that spot.
		The checkboxes to the right of each inventory spot are for setting up cycles. If you check that box, the key to the left and the key to the right (wrapped down to the next row if you're at the end) will be in a cycle together. This means that those keys will cycle forwards and backwards between the items in those two spots, and the one you have currently equipped.
		Your Profiles are saved whenever you switch tabs or close the window.
		)
	gui, show,, Swap Profiles
	return
warpToggleHelp:
	gui, new
	gui, font, s10
	gui, add, text, w300,
		(lTrim join`n`n
		Warp Toggle lets you take off and put on your warp with the press of a button. In order for it to work, the first blank inventory spot in the swap profile you're currently using must be the first empty inventory spot in your inventory. If your Swap Profile is blank, this is the first spot in your inventory.
		Even though this is called Warp Toggle (because the only useful time to take off a shell's item would be for hyperleeching/attacking) it will have the same effect, regardless of what shell you're using.
		(You must have an implant slot for this to work.)
		)
	gui, show,, Warp Toggle
	return
close:
	exitApp
