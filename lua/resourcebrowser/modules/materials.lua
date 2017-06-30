local MODULE = {}
MODULE.name			= "Material Viewer"
MODULE.author		= "Aptann"
MODULE.fileTypes = { "vtf", "vmt" }

function MODULE:SpawnUI(fileName, filePath)

	self.frame = vgui.Create("DFrame")
	self.frame:SetSize(ScrW() * 0.3, ScrW() * 0.3)
	self.frame:MakePopup()
	self.frame:Center()
	self.frame:SetTitle("Material Viewer - " .. fileName)
	self.frame:SetSizable(true)

	self.panel = vgui.Create("DPanel", self.frame)
	self.panel:Dock(FILL)
	self.panel:SetBackgroundColor(Color(0,0,0,255))

	self.image = vgui.Create("DImage", self.panel)
	self.image:Dock(FILL)
	self.image:SetImage(resourceBrowser.trimPath(filePath))

	return true

end

resourceBrowser.registerModule(MODULE)