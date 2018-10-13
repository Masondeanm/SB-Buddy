class iniex
	{
	static ini := {}
	create(sections)
		{
		for sectionName, section in sections
			{
			iniex.ini[sectionName] := {}
			for key, iniKey in section
				iniex.ini[sectionName][iniKey] := ""
			}
		}
	get(file := "settings.ini")
		{
		iniRead, sections, % file
		loop, parse, sections, `n
			iniex.getSection(a_loopField, file)
		}
	getSection(iniex_section, iniex_file := "settings.ini")
		{
		local iniex_sectionLines, iniex_iniLine, iniex_iniLineKey
		iniRead, iniex_sectionLines, % iniex_file, % iniex_section
		loop, parse, iniex_sectionLines, `n
			{
			regExMatch(a_loopField, "(?P<key>[^=]+)=", iniex_iniLine)
			iniRead, %iniex_iniLineKey%, % iniex_file, % iniex_section, % iniex_iniLineKey
			iniex.ini[iniex_section][iniex_iniLineKey] := %iniex_iniLineKey%
			}
		}
	put(file := "settings.ini", delete := true)
		{
		iniex.update()
		for sectionName, section in iniex.ini
			for key, value in section
				if(value != "")
					iniWrite, % value, % file , % sectionName, % key
				else
					if(delete)
						iniDelete, % file, % sectionName, % key
		}
	update()
		{
		for iniex_secName, iniex_section in iniex.ini
			for iniex_key, iniex_v in iniex_section
				iniex.ini[iniex_secName][iniex_key] := %iniex_key%
		}
	}