local MODULE = {}
MODULE.name			= "Sound Player"
MODULE.author		= "Deruu"
MODULE.fileTypes = { "wav" }

function MODULE:SpawnUI(fileName, filePath)

	self.frame = vgui.Create("DFrame")
	self.frame:SetSize(ScrW() * 0.25, ScrH() * 0.15)
	self.frame:SetTitle("Sound - " .. fileName)
	self.frame:MakePopup()

	

	return true

end

resourceBrowser.registerModule(MODULE)