// Delete old controls (DEVELOPMENT PURPOSES ONLY)
if resourceBrowser != nil and resourceBrowser.frame != nil then
	resourceBrowser.frame:Remove() print("removed!") end

resourceBrowser = {}
resourceBrowser.modules = {}

function resourceBrowser.registerModule(module)

	table.insert(resourceBrowser.modules, module)
	Msg("\tRegistered module \"".. module.name .."\"\n")

end

local function loadModules()
	Msg("Loading Resource Browser modules...\n")

	resourceBrowser.modules = {}
	local files, directories = file.Find("addons/resourcebrowser/lua/resourcebrowser/modules/*", "GAME")
	for k,v in pairs(files) do
		include("resourcebrowser/modules/" .. v)
	end

	Msg("Done loading Resource Browser modules\n")
end

local function containsInvalidCharacters(str)
	local len = string.len(str)
	for i=1,len do
		local byte = string.byte(str, i, i+1)
		if byte >= 128 then
			return true
		end
	end

	return false
end

local function getPathFromNode(node)
	local path = node:GetText()

	local currentNode = node
	while currentNode != nil do
		local text = currentNode:GetText()
		if(text == "") then
			break end

		if currentNode != node then
			path = currentNode:GetText() .. "/" .. path
		end

		if currentNode.GetParentNode == nil then
			break end
		currentNode = currentNode:GetParentNode()
	end

	return path
end

function initBrowser()
	// Create the base interface
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Resource Browser 2")
	frame:SetSize(ScrW() * 0.5, ScrH() * 0.65)
	frame:Center()
	frame:Hide()
	frame:SetSizable(true)
	frame:SetDeleteOnClose(false)


	local topPanel = vgui.Create("DPanel", frame)
	topPanel:Dock(TOP)
	topPanel:SetDrawBackground(false)
	topPanel:SetHeight(30)
	topPanel:DockPadding(0, 0, 0, 5)

	local textPath = vgui.Create("DTextEntry", topPanel)
	textPath:Dock(FILL)
	textPath.OnEnter = function(self)
		resourceBrowser.browsePath(textPath:GetText())
	end

	local refreshPanel = vgui.Create("DPanel", topPanel)
	refreshPanel:SetWidth(32)
	refreshPanel:Dock(RIGHT)
	refreshPanel:SetDrawBackground(false)
	refreshPanel:DockPadding(4,4,4,4)
	print(refreshPanel:GetTall())

	local refreshButton = vgui.Create("DImageButton", refreshPanel)
	refreshButton:SetSize(16,16)
	refreshButton:SetPos(8,5)
	refreshButton:SetImage("icon16/arrow_refresh.png")
	refreshButton.DoClick = function(self)
		resourceBrowser.refreshDirectoryTree()
	end


	local bottomPanel = vgui.Create("DPanel", frame)
	bottomPanel:Dock(BOTTOM)
	bottomPanel:SetDrawBackground(false)
	bottomPanel:SetHeight(18)
	bottomPanel:DockPadding(0, 3, 0, 0)

	local statusLabel = vgui.Create("DLabel", bottomPanel)
	statusLabel:Dock(LEFT)
	statusLabel:SetText("ready")
	statusLabel:SetWidth(frame:GetWide() * 0.2)

	local statusProgressBar = vgui.Create("DProgress", bottomPanel)
	statusProgressBar:Dock(RIGHT)
	statusProgressBar:Hide()


	local leftPanel = vgui.Create("DPanel", frame)
	leftPanel:SetDrawBackground(false)
	local rightPanel = vgui.Create("DPanel", frame)
	rightPanel:SetDrawBackground(false)

	local div = vgui.Create("DHorizontalDivider", frame)
	div:Dock(FILL)
	div:SetLeft(leftPanel)
	div:SetRight(rightPanel)
	div:SetDividerWidth(4)
	div:SetLeftMin(40)
	div:SetRightMin(150)
	div:SetLeftWidth(frame:GetWide() * 0.2)

	// Directory tree
	local directoryTree = vgui.Create("DTree", leftPanel)
	directoryTree:Dock(FILL)
	directoryTree.OnNodeSelected = function(self, node)
		local path = getPathFromNode(node)
		resourceBrowser.browsePath(path, node)
	end

	local fileList = vgui.Create("DListView", rightPanel)
	fileList:Dock(FILL)
	fileList:AddColumn("File")
	fileList:AddColumn("Type")
	fileList:AddColumn("Size")
	fileList:AddColumn("Last Modified")

	fileList.OnRowRightClick = function(self, index, line)
		local cmenu = DermaMenu()
		cmenu:AddOption("Open", function() resourceBrowser.openFile(resourceBrowser.path .. "/" .. line:GetColumnText(1)) end)
		cmenu:AddSpacer()
		cmenu:AddOption("Refresh", function() resourceBrowser.refreshFiles() end)
		cmenu:AddSpacer()
		cmenu:AddOption("Copy path", function() resourceBrowser.copyPathToClipboard(resourceBrowser.path .. "/" .. line:GetColumnText(1), false) end)
		cmenu:AddOption("Copy trimmed", function() resourceBrowser.copyPathToClipboard(resourceBrowser.path .. "/" .. line:GetColumnText(1), true) end)
		cmenu:AddSpacer()
		cmenu:AddOption("Delete", function() resourceBrowser.deleteFile(resourceBrowser.path .. "/" .. line:GetColumnText(1)) end)

		cmenu:SetPos(gui.MouseX(), gui.MouseY())
		cmenu:Open()
	end

	fileList.DoDoubleClick = function(self, index, line)
		resourceBrowser.openFile(resourceBrowser.path .. "/" .. line:GetColumnText(1))
	end

	// Load filetype modules
	loadModules()

	// Expose the controls
	resourceBrowser.frame = frame
	resourceBrowser.directoryTree = directoryTree
	resourceBrowser.fileList = fileList
	resourceBrowser.statusLabel = statusLabel
	resourceBrowser.statusProgressBar = statusProgressBar
	resourceBrowser.textPath = textPath
	resourceBrowser.refreshButton = refreshButton

	resourceBrowser.initialized = false
	resourceBrowser.path = nil
end

function resourceBrowser.setStatus(statusText)
	if statusText == nil then
		statusText = "ready" end

	resourceBrowser.statusLabel:SetText(statusText)
end

function resourceBrowser.setStatusProgress(progress)
	resourceBrowser.statusProgressBar:SetFraction(progress)

	if progress >= 1.0 then
		resourceBrowser.statusProgressBar:Hide()
	else
		resourceBrowser.statusProgressBar:Show()
	end
end

function resourceBrowser.openFile(filePath)
	// TODO: Use file modules to determine what to open
	if !file.Exists(filePath, "GAME") then
		Derma_Message("File does not exist", "Uh oh!", "OK")
	end

	local fileType = string.GetExtensionFromFilename(filePath)

	for k,v in pairs(resourceBrowser.modules) do
		if table.HasValue(v.fileTypes, fileType) then
			local handled = v:SpawnUI(filePath)

			if handled then
				break
			end
		end
	end

end

function resourceBrowser.deleteFile(filePath)
	if !string.StartWith(filePath, "data/") then
		Derma_Message("Due to file library restrictions, files can only be removed from the data folder", "Delete File", "OK")
		return
	end

	if !file.Exists(filePath, "GAME") then
		Derma_Message("File does not exist", "Uh oh!", "OK")
	end

	Derma_Query("Are you sure you want to remove this file?", "Delete File", "Yes", function()
		file.Delete(string.Replace(filePath, "data/", ""))
		resourceBrowser.browsePath(string.sub(filePath, 1, string.find(filePath, "/([^/]+)$")))
	end, "No")
end

function resourceBrowser.copyPathToClipboard(filePath, trim)
	if trim then
		local rootStart, rootEnd = string.find(filePath, "^[^/]+/")
		filePath = string.sub(filePath, rootEnd + 1, string.len(filePath))
		local extStart, extEnd = string.find(test, "([^%.]+)$")
		filePath = string.sub(filePath, 1, extStart - 2)
	end

	SetClipboardText(filePath)
end

function resourceBrowser.refreshFiles()
	error("Not implemented")
end

local timeResumed = 0
local totalDirectories = 0
local directoriesDone = 0

local function populateTree(path, node, isRoot)
	local searchPath = path .. "/*"
	if path == "" then
		searchPath = "*" end

	local files, directories = file.Find(searchPath, "GAME", "namedesc")
	if isRoot then
		totalDirectories = #directories - 1 end

	for k,v in pairs(directories) do
		if v == "/" then
			continue end

		if isRoot then
			directoriesDone = directoriesDone + 1 end
		resourceBrowser.setStatusProgress(directoriesDone / totalDirectories)

		if containsInvalidCharacters(v) then continue end


		local node = node:AddNode(v)

		if SysTime() - timeResumed > 0.07 then
			coroutine.yield()
		end
		populateTree(path != "" and path .. "/" .. v or v, node)
	end
end

function resourceBrowser.refreshDirectoryTree()
	local dt = resourceBrowser.directoryTree

	totalDirectories = 0
	directoriesDone = 0

	if dt.RootNode.ChildNodes then
		dt.RootNode.ChildNodes:Remove()
		dt.RootNode.ChildNodes = nil
		dt.RootNode:SetNeedsPopulating(false)
		dt.RootNode:InvalidateLayout()
		dt.RootNode.Expander:SetExpanded(false)
	end
	
	resourceBrowser.setStatus("populating directory tree")
	resourceBrowser.setStatusProgress(0)

	resourceBrowser.onDirectoryListRefreshStart()
	local c = coroutine.create(function() populateTree("", dt, true) end)
	hook.Add("Think", "resourcebrowser populateTree Think", function()
		timeResumed = SysTime()
		if(!coroutine.resume(c)) then
			hook.Remove("Think", "resourcebrowser populateTree Think")
			resourceBrowser.onDirectoryListRefreshComplete()
			resourceBrowser.setStatus()
		end
	end)
end

function resourceBrowser.browsePath(path, node)
	print(path)
	if !file.Exists(path, "GAME") or !file.IsDir(path, "GAME") then
		// Revert to root path if the directory doesn't exist or path leads to a file
		path = ""
	end
	resourceBrowser.path = path
	resourceBrowser.textPath:SetText(path)

	if node == nil then
		// Update tree to reflect the new path
		local dt = resourceBrowser.directoryTree
		local parts = string.Explode("/", path)
		local node = dt.RootNode
		local prevNode = nil
		for k,v in pairs(parts) do
			local children = node.ChildNodes:GetChildren()
			for ci,cv in pairs(children) do
				if cv.name == v then
					prevNode = node
					node = cv
					break
				end
			end
		end

		dt:SetSelectedItem(node)
		if prevNode != nil then
			prevNode:ExpandTo(true) end
	end

	// Populate file list
	local fl = resourceBrowser.fileList
	fl:Clear()

	local files, directories = file.Find(path .. "/*", "GAME")
	for k,v in pairs(files) do
		if !file.Exists(path .. "/".. v, "GAME") then continue end

		local fileSize = file.Size(path .. "/" .. v, "GAME")
		fl:AddLine(v, string.GetExtensionFromFilename(v), string.NiceSize(fileSize), "")
	end
end

function resourceBrowser.open()
	if !resourceBrowser.initialized then
		resourceBrowser.refreshDirectoryTree()
		resourceBrowser.initialized = true
	end

	resourceBrowser.frame:Show(true)
	resourceBrowser.frame:MakePopup()
end

function resourceBrowser.close()
	resourceBrowser.frame:Hide(false)
end

/*
	Events
*/

function resourceBrowser.onDirectoryListRefreshComplete()
	resourceBrowser.refreshButton:SetDisabled(false)
end

function resourceBrowser.onDirectoryListRefreshStart()
	resourceBrowser.refreshButton:SetDisabled(true)
end

/*
	ConCommands
*/

concommand.Add("rb_reload_modules", function()
	loadModules()
end)

concommand.Add("rb_open", function()
	resourceBrowser.open()
end)

initBrowser()