local MODULE = {}
MODULE.name			= "Sound Player"
MODULE.author		= "Aptann"
MODULE.fileTypes = { "wav", "mp3" }

function MODULE:SpawnUI(fileName, filePath)

	if !self.open then

		self.frame = vgui.Create("DFrame")
		self.frame:SetSize(400, 130)
		self.frame:MakePopup()
		self.frame:Center()
		self.frame.OnClose = function()
			self.sound:Stop()
			self.open = false
		end


		self.topPanel = vgui.Create("DPanel", self.frame)
		self.topPanel:Dock(FILL)
		self.topPanel:DockPadding(5, 5, 5, 5)
		self.topPanel:SetDrawBackground(false)

		self.volumeSlider = vgui.Create("DNumSlider", self.topPanel)
		self.volumeSlider:Dock(TOP)
		self.volumeSlider:SetText("Volume")
		self.volumeSlider:SetValue(1)
		self.volumeSlider.OnValueChanged = function(slider, val)
			self.sound:ChangeVolume(val, 0)
		end

		self.pitchSlider = vgui.Create("DNumSlider", self.topPanel)
		self.pitchSlider:Dock(TOP)
		self.pitchSlider:SetText("Pitch")
		self.pitchSlider:SetMin(0)
		self.pitchSlider:SetMax(255)
		self.pitchSlider:SetDecimals(0)
		self.pitchSlider:SetValue(100)
		self.pitchSlider.OnValueChanged = function(slider, val)
			self.sound:ChangePitch(val, 0)
		end

		self.bottomPanel = vgui.Create("DPanel", self.frame)
		self.bottomPanel:Dock(BOTTOM)
		self.bottomPanel:DockPadding(5, 5, 5, 5)
		self.bottomPanel:SetHeight(30)
		self.bottomPanel:SetDrawBackground(false)

		self.playButton = vgui.Create("DButton", self.bottomPanel)
		self.playButton:Dock(LEFT)
		self.playButton:SetText("Stop")
		self.playButton.DoClick = function(button)
			if self.playing then
				self.sound:Stop()
				button:SetText("Play")
				self.playing = false
			else
				self.sound:Play()
				self.sound:ChangeVolume(self.volumeSlider:GetValue() ,0)
				self.sound:ChangePitch(self.pitchSlider:GetValue() ,0)
				button:SetText("Stop")
				self.playing = true

			end
		end

	end

	self.open = true

	self.frame:SetTitle("Sound Player - " .. fileName)

	if self.sound then
		self.sound:Stop()
	end

	self.sound = CreateSound(LocalPlayer(), resourceBrowser.trimPath(filePath, true))
	self.sound:Play()
	self.sound:ChangeVolume(self.volumeSlider:GetValue(), 0)
	self.sound:ChangePitch(self.pitchSlider:GetValue(), 0)

	self.playing = true

	return true

end

resourceBrowser.registerModule(MODULE)