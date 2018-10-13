contain(folderName)
	{
	if(regExMatch(a_scriptDir, "i)\\" folderName "$"))
		{
		if(fileExist("deleteOld"))
			{
			regExMatch(a_scriptDir, "((?:[^\\]+\\)+[^\\]+)\\" folderName, oldFileDir)
			fileDelete, % oldFileDir1 "\" a_scriptName
			fileDelete, deleteOld
			msgBox, This file has been moved to %a_scriptDir% and will continue running there.
			}
		}
	else
		{
		newDir := a_scriptDir "\" folderName
		if(not fileExist(newDir))
			fileCreateDir, % newDir
		fileCopy, % a_scriptFullPath, % newDir
		fileOpen(newDir "\deleteOld", "w")
		run, % newDir "\" a_scriptName, % newDir
		exitApp
		}
	}