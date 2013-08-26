local MODULE = {}
MODULE.name			= "Text Viewer"
MODULE.author		= "Deruu"
MODULE.fileTypes = { "txt" }

function MODULE:SpawnUI(fileName, filePath)

	self.frame = vgui.Create("DFrame")
	self.frame:SetSize(ScrW() * 0.5, ScrH() * 0.5)
	self.frame:MakePopup()
	self.frame:Center()
	self.frame:SetTitle("Text Viewer - " .. fileName)

	self.textEntry = vgui.Create("DTextEntry", self.frame)
	self.textEntry:Dock(FILL)
	self.textEntry:SetMultiline(true)
	self.textEntry:SizeToContents()
	
	self.textEntry:SetText(file.Read(filePath, "GAME"))

	return true

end

resourceBrowser.registerModule(MODULE)