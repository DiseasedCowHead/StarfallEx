-- Starfall Derma

-- Starfall Frame
PANEL = {}

PANEL.windows = {}

SF.Editor.ShowExamplesVar = CreateClientConVar("sf_editor_showexamples", "1", true, false)
SF.Editor.ShowDataFilesVar = CreateClientConVar("sf_editor_showdatafiles", "0", true, false)


--[[ Loading SF Examples ]]

if SF.Editor.ShowExamplesVar:GetBool() then

	local examples_url = "https://api.github.com/repos/thegrb93/StarfallEx/contents/lua/starfall/examples"
	http.Fetch( examples_url,
		function( body, len, headers, code )
				if code == 200 then -- OK code
					local data = util.JSONToTable( body )
					SF.Docs["Examples"] = {}
					for k,v in pairs(data) do
						SF.Docs["Examples"][v.name] = v.download_url
					end
				end
		end,
		function( error )
			SF.Docs["Examples"] = {}
			print("[SF] Examples failed to load:"..tostring(error))
		end
	)
end
--[[ End of SF Examples ]]

--[[ Fonts ]]

surface.CreateFont( "SF_PermissionsWarning", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 16,
} )

surface.CreateFont( "SF_PermissionName", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 20,
} )

surface.CreateFont( "SF_PermissionDesc", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 18,
} )

surface.CreateFont( "SF_PermissionsTitle", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 20,
} )

surface.CreateFont("SFTitle", {
		font = "Roboto",
		size = 18,
		weight = 500,
		antialias = true,
		additive = false,
	})

--[[ StarfallFrame ]]

function PANEL:Init ()
	for _, v in pairs(self:GetChildren()) do v:Remove() end
	local frame = self
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetSizable(true)
	self:SetScreenLock(true)
	self:SetDeleteOnClose(false)
	self:MakePopup()
	self:SetVisible(false)
	self.Title = ""
	self:DockPadding(5, 0, 5, 5)

	self.TitleBar = vgui.Create("DPanel", self)
	self.TitleBar:Dock(TOP)
	self.TitleBar:SetTall(24)
	self.TitleBar:DockPadding(2, 4, 2, 0)
	self.TitleBar:DockMargin(0, 0, 0, 2)
	self.TitleBar:SetCursor("sizeall")
	self.TitleBar.Paint = self.PaintTitle
	self.TitleBar.OnMousePressed = function(...) self:OnMousePressed(...) end

	self.CloseButton = vgui.Create("StarfallButton", self.TitleBar)
	self.CloseButton:SetText("Close")
	self.CloseButton:Dock(RIGHT)
	self.CloseButton.DoClick = function() self:Close() end


	self._Close = self.Close
	self.Close = self.new_Close
end

function PANEL:PerformLayout()

end

function PANEL:SetTitle(text)
	self.Title = text
end

function PANEL:GetTitle()
	return self.Title
end

function PANEL:PaintTitle(w,h)
	surface.SetFont("SFTitle")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(0, 6)
	surface.DrawText(self:GetParent().Title)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, SF.Editor.colors.dark)
end

function PANEL:Open ()
	self:SetVisible(true)
	self:SetKeyBoardInputEnabled(true)
	self:MakePopup()
	self:InvalidateLayout(true)

	self:OnOpen()
end
function PANEL:new_Close ()
	self:OnClose()
	self:SetKeyBoardInputEnabled(false)
	self:_Close()
end

function PANEL:OnOpen ()
end
function PANEL:OnClose ()
end

vgui.Register("StarfallFrame", PANEL, "DFrame")
-- End Starfall Frame

--------------------------------------------------------------
--------------------------------------------------------------

-- Starfall Button
PANEL = {}

function PANEL:Init ()
self:SetText("")
self:SetSize(22, 22)
end
function PANEL:SetIcon (icon)
self.icon = SF.Editor.icons[icon]
end
function PANEL:PerformLayout ()
if self:GetText() ~= "" then
self:SizeToContentsX()
self:SetWide(self:GetWide() + 14)
end
end
PANEL.Paint = function (button, w, h)
if button.Hovered or button.active then
draw.RoundedBox(0, 0, 0, w, h, button.backgroundHoverCol or SF.Editor.colors.med)
else
draw.RoundedBox(0, 0, 0, w, h, button.backgroundCol or SF.Editor.colors.meddark)
end
if button.icon then
surface.SetDrawColor(SF.Editor.colors.medlight)
surface.SetMaterial(button.icon)
surface.DrawTexturedRect(2, 2, w - 4, h - 4)
end
end
function PANEL:UpdateColours (skin)
return self:SetTextStyleColor(self.labelCol or SF.Editor.colors.light)
end
function PANEL:SetHoverColor (col)
self.backgroundHoverCol = col
end
function PANEL:SetColor (col)
self.backgroundCol = col
end
function PANEL:SetLabelColor (col)
self.labelCol = col
end
function PANEL:DoClick ()

end

vgui.Register("StarfallButton", PANEL, "DButton")
-- End Starfall Button

--------------------------------------------------------------
--------------------------------------------------------------

-- Starfall Panel
PANEL = {}
PANEL.Paint = function (panel, w, h)
draw.RoundedBox(0, 0, 0, w, h, SF.Editor.colors.light)
end
vgui.Register("StarfallPanel", PANEL, "DPanel")
-- End Starfall Panel

--------------------------------------------------------------
--------------------------------------------------------------

-- Tab Holder
PANEL = {}

function PANEL:Init ()
self:SetTall(22)
self.offsetTabs = 0
self.tabs = {}

local parent = self

self.offsetRight = vgui.Create("StarfallButton", self)
self.offsetRight:SetVisible(false)
self.offsetRight:SetSize(22, 22)
self.offsetRight:SetIcon("arrowr")
function self.offsetRight:PerformLayout ()
local wide = 0
if parent.offsetLeft:IsVisible() then
	wide = parent.offsetLeft:GetWide() + 2
end
for i = parent.offsetTabs + 1, #parent.tabs do
	if wide + parent.tabs[i]:GetWide() > parent:GetWide() - self:GetWide() - 2 then
		break
	else
		wide = wide + parent.tabs[i]:GetWide() + 2
	end
end
self:SetPos(wide, 0)
end
function self.offsetRight:DoClick ()
parent.offsetTabs = parent.offsetTabs + 1
if parent.offsetTabs > #parent.tabs - 1 then
	parent.offsetTabs = #parent.tabs - 1
end
parent:InvalidateLayout()
end

self.offsetLeft = vgui.Create("StarfallButton", self)
self.offsetLeft:SetVisible(false)
self.offsetLeft:SetSize(22, 22)
self.offsetLeft:SetIcon("arrowl")
function self.offsetLeft:DoClick ()
parent.offsetTabs = parent.offsetTabs - 1
if parent.offsetTabs < 0 then
	parent.offsetTabs = 0
end
parent:InvalidateLayout()
end

self.menuoptions = {}

self.menuoptions[#self.menuoptions + 1] = { "Close", function ()
	if not self.targetTab then return end
	self:removeTab(self.targetTab)
	self.targetTab = nil
	end }
self.menuoptions[#self.menuoptions + 1] = { "Close Other Tabs", function ()
		if not self.targetTab then return end
		local n = 1
		while #self.tabs ~= 1 do
			v = self.tabs[n]
			if v ~= self.targetTab then
				self:removeTab(v)
			else
				n = 2
			end
		end
		self.targetTab = nil
		end }
end
PANEL.Paint = function () end
function PANEL:PerformLayout ()
	local parent = self:GetParent()
	self:SetWide(parent:GetWide() - 10)
	self.offsetRight:PerformLayout()
	self.offsetLeft:PerformLayout()

	local offset = 0
	if self.offsetLeft:IsVisible() then
		offset = self.offsetLeft:GetWide() + 2
	end
	for i = 1, self.offsetTabs do
		offset = offset - self.tabs[i]:GetWide() - 2
	end
	local bool = false
	for k, v in pairs(self.tabs) do
		v:SetPos(offset, 0)
		if offset < 0 then
			v:SetVisible(false)
		elseif offset + v:GetWide() > self:GetWide() - self.offsetRight:GetWide() - 2 then
			v:SetVisible(false)
			bool = true
		else
			v:SetVisible(true)
		end
		offset = offset + v:GetWide() + 2
	end

	if bool then
		self.offsetRight:SetVisible(true)
	else
		self.offsetRight:SetVisible(false)
	end
	if self.offsetTabs > 0 then
		self.offsetLeft:SetVisible(true)
	else
		self.offsetLeft:SetVisible(false)
	end
end
function PANEL:addTab (text)
	local panel = self
	local tab = vgui.Create("StarfallButton", self)
	tab:SetText(text)
	tab.isTab = true

	function tab:DoClick ()
		panel:selectTab(self)
	end

	function tab:DoRightClick ()
		panel.targetTab = self
		local menu = vgui.Create("DMenu", panel:GetParent())
		for k, v in pairs(panel.menuoptions) do
			local option, func = v[1], v[2]
			if func == "SPACER" then
				menu:AddSpacer()
			else
				menu:AddOption(option, func)
			end
		end
		menu:Open()
	end

	function tab:DoMiddleClick ()
		panel:removeTab(self)
	end

	self.tabs[#self.tabs + 1] = tab

	return tab
end
function PANEL:removeTab (tab)
	local tabIndex
	if type(tab) == "number" then
		tabIndex = tab
		tab = self.tabs[tab]
	else
		tabIndex = self:getTabIndex(tab)
	end

	table.remove(self.tabs, tabIndex)
	tab:Remove()

	self:OnRemoveTab(tabIndex)
end
function PANEL:getActiveTab ()
	for k, v in pairs(self.tabs) do
		if v.active then return v end
	end
end
function PANEL:getTabIndex (tab)
	return table.KeyFromValue(self.tabs, tab)
end
function PANEL:selectTab (tab)
	if type(tab) == "number" then
		tab = self.tabs[tab]
	end
	if tab == nil then return end

	if self:getActiveTab() == tab then return end

	for k, v in pairs(self.tabs) do
		v.active = false
	end
	tab.active = true

	if self:getTabIndex(tab) <= self.offsetTabs then
		self.offsetTabs = self:getTabIndex(tab) - 1
	elseif not tab:IsVisible() then
		while not tab:IsVisible() do
			self.offsetTabs = self.offsetTabs + 1
			self:PerformLayout()
		end
	end
end
function PANEL:OnRemoveTab (tabIndex)

end
vgui.Register("StarfallTabHolder", PANEL, "DPanel")
-- End Tab Holder

--------------------------------------------------------------
--------------------------------------------------------------

-- File Tree
local invalid_filename_chars = {
	["*"] = "",
	["?"] = "",
	[">"] = "",
	["<"] = "",
	["|"] = "",
	["\\"] = "",
	['"'] = "",
}

PANEL = {}

function PANEL:Init ()

end
function PANEL:setup (folder)
	self.folder = folder
	self.Root = self.RootNode:AddFolder(folder, folder, "DATA", true)
	--[[Waiting for examples, 10 tries each 1 second]]
	if SF.Editor.ShowDataFilesVar:GetBool() then
		self.DataFiles = self.RootNode:AddNode("Data Files","icon16/folder_database.png")
		self.DataFiles:MakeFolder("sf_filedata","DATA",true)
	end
	if SF.Editor.ShowExamplesVar:GetBool() then
		timer.Create("sf_filetree_waitforexamples",1, 10, function()

			if SF.Docs["Examples"] then
				self.Examples = self.RootNode:AddNode("Examples","icon16/help.png")
				for k,v in pairs(SF.Docs["Examples"]) do
					local node = self.Examples:AddNode(k,"icon16/page_white.png")
					node.FileURL = v
				end
				timer.Remove("sf_filetree_waitforexamples")
			end

		end)
	end
	self.Root:SetExpanded(true)
end
function PANEL:reloadTree ()
	self.Root:Remove()
	if self.Examples then
		self.Examples:Remove()
	end
	if self.DataFiles then
		self.DataFiles:Remove()
	end
	self:setup(self.folder)
end
function PANEL:DoRightClick (node)
	self:openMenu(node)
end
function PANEL:openMenu (node)
	local menu
	if node:GetFileName() then
		menu = "file"
	elseif node:GetFolder() then
		menu = "folder"
	end
	self.menu = vgui.Create("DMenu", self:GetParent())
	if menu == "file" then
		self.menu:AddOption("Open", function ()
				SF.Editor.openFile(node:GetFileName())
			end)
		self.menu:AddOption("Open in new tab", function ()
				SF.Editor.openFile(node:GetFileName(), true)
			end)
		self.menu:AddSpacer()
		self.menu:AddOption("Rename", function ()
				Derma_StringRequestNoBlur("Rename file",
					"",
					string.StripExtension(node:GetText()),
					function (text)
						if text == "" then return end
						text = string.gsub(text, ".", invalid_filename_chars)
						local oldFile = node:GetFileName()
						local saveFile = string.GetPathFromFilename(oldFile) .. "/" .. text ..".txt"
						local contents = file.Read(oldFile)
						file.Delete(node:GetFileName())
						file.Write(saveFile, contents)
						SF.AddNotify(LocalPlayer(), "File renamed as " .. saveFile .. ".", "GENERIC", 7, "DRIP3")
						self:reloadTree()
					end)
			end)
		self.menu:AddSpacer()
		self.menu:AddOption("Delete", function ()
				Derma_Query("Are you sure you want to delete this file?",
					"Delete file",
					"Delete",
					function ()
						file.Delete(node:GetFileName())
						SF.AddNotify(LocalPlayer(), "File deleted: " .. node:GetFileName(), "GENERIC", 7, "DRIP3")
						self:reloadTree()
					end,
					"Cancel")
			end)
	elseif menu == "folder" then
		self.menu:AddOption("New file", function ()
				Derma_StringRequestNoBlur("New file",
					"",
					"",
					function (text)
						if text == "" then return end
						text = string.gsub(text, ".", invalid_filename_chars)
						local saveFile = node:GetFolder().."/"..text..".txt"
						file.Write(saveFile, "")
						SF.AddNotify(LocalPlayer(), "New file: " .. saveFile, "GENERIC", 7, "DRIP3")
						self:reloadTree()
					end)
			end)
		self.menu:AddSpacer()
		self.menu:AddOption("New folder", function ()
				Derma_StringRequestNoBlur("New folder",
					"",
					"",
					function (text)
						if text == "" then return end
						text = string.gsub(text, ".", invalid_filename_chars)
						local saveFile = node:GetFolder().."/"..text
						file.CreateDir(saveFile)
						SF.AddNotify(LocalPlayer(), "New folder: " .. saveFile, "GENERIC", 7, "DRIP3")
						self:reloadTree()
					end)
			end)
		self.menu:AddSpacer()
		self.menu:AddOption("Delete", function ()
				Derma_Query("Are you sure you want to delete this folder?",
					"Delete folder",
					"Delete",
					function ()
						-- Recursive delete
						local folders = {}
						folders[#folders + 1] = node:GetFolder()
						while #folders > 0 do
							local folder = folders[#folders]
							local files, directories = file.Find(folder.."/*", "DATA")
							for I = 1, #files do
								file.Delete(folder .. "/" .. files[I])
							end
							if #directories == 0 then
								file.Delete(folder)
								folders[#folders] = nil
							else
								for I = 1, #directories do
									folders[#folders + 1] = folder .. "/" .. directories[I]
								end
							end
						end
						SF.AddNotify(LocalPlayer(), "Folder deleted: " .. node:GetFolder(), "GENERIC", 7, "DRIP3")
						self:reloadTree()
					end,
					"Cancel")
			end)
	end
	self.menu:Open()
end

derma.DefineControl("StarfallFileTree", "", PANEL, "DTree")
-- End File Tree

--------------------------------------------------------------
--------------------------------------------------------------

-- File Browser
PANEL = {}

function PANEL:Init ()

	self:Dock(FILL)
	self:DockMargin(0, 5, 0, 0)
	self.Paint = function () end

	local tree = vgui.Create("StarfallFileTree", self)
	tree:Dock(FILL)

	self.tree = tree

	local searchBox = vgui.Create("DTextEntry", self)
	searchBox:Dock(TOP)
	searchBox:SetValue("Search...")

	searchBox._OnGetFocus = searchBox.OnGetFocus
	function searchBox:OnGetFocus ()
		if self:GetValue() == "Search..." then
			self:SetValue("")
		end
		searchBox:_OnGetFocus()
	end

	searchBox._OnLoseFocus = searchBox.OnLoseFocus
	function searchBox:OnLoseFocus ()
		if self:GetValue() == "" then
			self:SetText("Search...")
		end
		searchBox:_OnLoseFocus()
	end

	function searchBox:OnChange ()

		if self:GetValue() == "" then
			tree:reloadTree()
			return
		end

		tree.Root.ChildNodes:Clear()
		local function containsFile (dir, search)
			local files, folders = file.Find(dir .. "/*", "DATA")
			for k, file in pairs(files) do
				if string.find(string.lower(file), string.lower(search)) then return true end
			end
			for k, folder in pairs(folders) do
				if containsFile(dir .. "/" .. folder, search) then return true end
			end
			return false
		end
		local function addFiles (search, dir, node)
			local allFiles, allFolders = file.Find(dir .. "/*", "DATA")
			for k, v in pairs(allFolders) do
				if containsFile(dir .. "/" .. v, search) then
					local newNode = node:AddNode(v)
					newNode:SetExpanded(true)
					addFiles(search, dir .. "/" .. v, newNode)
				end
			end
			for k, v in pairs(allFiles) do
				if string.find(string.lower(v), string.lower(search)) then
					local fnode = node:AddNode(v, "icon16/page_white.png")
					fnode:SetFileName(dir.."/"..v)
				end
			end
		end
		addFiles(self:GetValue():PatternSafe(), "starfall", tree.Root)
		if tree.DataFiles then
			addFiles(self:GetValue():PatternSafe(), "sf_filedata", tree.DataFiles)
		end
		tree.Root:SetExpanded(true)
	end
	self.searchBox = searchBox

	self.Update = vgui.Create("DButton", self)
	self.Update:SetTall(20)
	self.Update:Dock(BOTTOM)
	self.Update:DockMargin(0, 0, 0, 0)
	self.Update:SetText("Update")
	self.Update.DoClick = function(button)
		tree:reloadTree()
		searchBox:SetValue("Search...")
	end
end
function PANEL:getComponents ()
	return self.searchBox, self.tree
end

derma.DefineControl("StarfallFileBrowser", "", PANEL, "DPanel")
-- End File Browser

--[[ Permissions ]]

PANEL = {}

local function createpermissionsPanel ( parent )
	local chip = parent.chip
	local panel = vgui.Create( 'DPanel', parent )
	panel:Dock( FILL )
	panel:DockMargin( 0, 0, 0, 0 )
	panel.Paint = function () end
	panel.index = { [ 1 ] = {}, [ 2 ] = {} } -- Locate any permission panel by area and id with ease

	local permStates = {
		{
			iconMat = Material( 'icon16/joystick_add.png' ),
			color = Color( 0, 0, 0, 0 ),
			stillText = 'Awaiting your decision.\nLeft click to mark for granting.'
		},
		{
			iconMat = Material( 'icon16/tick.png' ),
			color = SF.Editor.colors.med,
			changedText = 'Override is marked for granting.\nYou need to apply it to make the change take effect.',
			stillText = 'Already granted override.\nLeft or right click to mark for revocation.'
		},
		{
			iconMat = Material( 'icon16/stop.png' ),
			color = Color( 50, 0, 0 ),
			changedText = 'Marked for revocation.\nLeft click to undo.'
		}
	}

	local listedPerms = {
		chip.instance.permissionRequest.overrides,
		parent.overrides
	}
	for area, set in ipairs( listedPerms ) do
		local scrollPanel = vgui.Create( 'DScrollPanel', panel )
		scrollPanel:Dock( FILL )
		scrollPanel:SetPaintBackgroundEnabled( false )
		scrollPanel:Clear()
		for id, _ in SortedPairs( set ) do
			local permission = SF.Permissions.privileges[ id ]

			local name = permission[ 1 ]
			local description = permission[ 2 ]

			local perm = vgui.Create( 'DLabel' )
			perm:Dock( TOP )
			perm:DockMargin( 0, 5, 0, 5 )
			perm:DockPadding( 5, 5, 5, 5 )
			perm:SetTall( 50 )
			perm:SetIsToggle( true )
			perm:SetCursor( 'hand' )
			perm:SetText( '' )
			perm.Paint = function ( s, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, permStates[ perm.state ].color )
				if perm.state ~= perm.initialState then
					draw.RoundedBox( 0, 0, 0, 26, h, SF.Editor.colors.medlight )
				end
				draw.RoundedBox( 0, 0, h - 1, w, 1, SF.Editor.colors.meddark )
			end
			perm.update = function ()
				if area == 2 then perm.state = perm:GetToggle() and 2 or 3
				else perm.state = perm:GetToggle() and 2 or 1 end
				if perm.initialState then
					local hint
					if perm.state ~= perm.initialState then hint = permStates[ perm.state ].changedText or ''
					else hint = permStates[ perm.state ].stillText or '' end
					perm:SetToolTip( id .. '\n' .. description .. '\n\n' .. hint )
					ChangeTooltip( perm )
				end
			end
			function perm:OnToggled()
				parent.overrides[ id ] = perm:GetToggle() and true or nil
				perm.update()
				parent.update()
			end
			perm:SetToggle( parent.overrides[ id ] ~= nil )
			perm.update()
			perm.initialState = perm.state
			perm.update()
			if area == 1 and perm.state == 2 then
				perm:SetIsToggle( false )
				perm.DoRightClick = function ()
					local mirror = panel.index[ 2 ][ id ]
					parent.area = 2
					parent.update()
					local x, y = mirror:GetPos()
					panel:GetChild( 1 ):GetVBar():AnimateTo( y + mirror:GetTall() / 2 - panel:GetTall() / 2, 0.5 )
				end
			elseif area == 2 then
				perm.DoRightClick = function ()
					perm:Toggle()
					perm:OnToggled()
				end
			end

			local title = vgui.Create( 'DLabel', perm )
			title:Dock( TOP )
			title:SetContentAlignment( 4 )
			title:SetTextInset( 26, 0 )
			title:SetFont( 'SF_PermissionName' )
			title:SetText( name )
			title:SetBright( true )
			title.Paint = function ()
				surface.SetDrawColor( 200, 200, 255 )
				surface.SetMaterial( permStates[ perm.state ].iconMat )
				surface.DrawTexturedRect( 0, 0, 16, 16 )
			end

			local desc = vgui.Create( 'DLabel', perm )
			desc:Dock( BOTTOM )
			desc:DockMargin( 31, 0, 0, 0 )
			desc:SetContentAlignment( 1 )
			desc:SetFont( 'SF_PermissionDesc' )
			desc:SetColor( SF.Editor.colors.light )
			desc:SetText( description )

			scrollPanel:AddItem( perm )
			panel.index[ area ][ id ] = perm
			local prev = table.maxn( panel.index[ area ] ) or 0
			panel.index[ area ][ prev + 1 ] = perm
		end
		if area ~= parent.area then scrollPanel:SetVisible( false ) end
	end
	return panel
end

function PANEL:OpenForChip( chip )
	self.chip = chip
	self.entIcon:SetModel( chip:GetModel(), chip:GetSkin() )
	self.entIcon:SetTooltip( tostring( chip ) )
	self.entName:SetText( chip.name )
	local desc = chip.instance.permissionRequest.description
	self.description:SetText( #desc > 0 and desc or 'Please press "Grant" couple times. Then press "Apply Permissions", so this way we can provide you with interesting features.' )
	self.description:SetTooltip( string.format( 'Description provided by owner.\nName: %s\nSteamID: %s', chip.owner:GetName(), chip.owner:SteamID() ) )
	self.ownerAvatar:SetPlayer( chip.owner, self.ownerPanel:GetTall() )
	self:MakePopup()
	self:ParentToHUD()
	self:Center()

	self.overrides = {}
	if chip.instance.permissionOverrides then
		self.overrides = table.Copy( chip.instance.permissionOverrides )
	end

	local permissions = createpermissionsPanel( self )
	permissions:SetParent( self )
	permissions:Dock( FILL )
	self.permissionsPanel = permissions

	self.satisfied = SF.Permissions.permissionRequestSatisfied( chip.instance )
	self.area = self.satisfied and 2 or 1
	self.update()
	self.changeOverrides = function ()
		if chip and chip.instance then
			chip.instance.permissionOverrides = self.overrides
			chip.instance:runScriptHook( 'permissionrequest' )
		end
	end

end

function PANEL:Init ()
	self:ShowCloseButton( false )
	self:DockPadding( 5, 5, 5, 5 )
	self:SetSize( 640, 400 )
	self:SetTitle( 'Overriding Permissions' )
	self.lblTitle:Dock( TOP )
	self.lblTitle:DockMargin( 2, 2, 2, 2 )
	self.lblTitle:DockPadding( 0, 0, 0, 0 )
	self.lblTitle:SetFont( 'SF_PermissionsTitle' )
	self.lblTitle:SizeToContents()
	self.lblTitle:SetContentAlignment( 5 )

	local entity = vgui.Create( 'DPanel', self )
	entity:Dock( TOP )
	entity:DockMargin( 0, 5, 0, 5 )
	entity:DockPadding( 5, 5, 5, 5 )
	entity:SetTall( 128 )
	entity.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
	end

	local icon = vgui.Create( 'SpawnIcon', entity )
	icon:Dock( LEFT )
	icon:DockMargin( 0, 0, 5, 0 )
	icon:SetSize( 118, 118 )
	self.entIcon = icon

	local name = vgui.Create( 'DLabel', entity )
	name:Dock( TOP )
	name:SetTall( 32 )
	name:SetFont( 'DermaLarge' )
	name:SetDark( true )
	self.entName = name

	local notice = vgui.Create( 'DLabel', entity )
	notice:Dock( FILL )
	notice:SetFont( 'SF_PermissionsWarning' )
	notice:SetWrap( true )
	notice:SetDark( true )
	notice.prefixes = { 'requests additional permissions.', 'may still require some permissions.' }
	notice.update = function ()
		notice:SetText( notice.prefixes[ self.area ] .. ' They might be useful to touch advanced technologies. There is place for any influence rendered by their features.' )
	end

	local pane = vgui.Create( 'Panel', entity )
	pane:Dock( BOTTOM )
	pane:SetTall( 40 )

	local warning = vgui.Create( 'DLabel', pane )
	warning:Dock( FILL )
	warning:SetAutoStretchVertical( true )
	warning:SetContentAlignment( 4 )
	warning:SetFont( 'SF_PermissionsWarning' )
	warning:SetWrap( true )
	warning:SetDark( true )
	warning:SetTextColor( Color( 200, 50, 0 ) )
	warning:SetText( 'State of permissions listed below will override global settings. Grant overrides only if you trust the owner.' )

	local showOverrides = vgui.Create( 'StarfallButton', pane )
	showOverrides:Dock( RIGHT )
	showOverrides:DockMargin( 5, 0, 0, 0 )
	showOverrides:SetWide( 150 )
	showOverrides:SetFont( 'SF_PermissionDesc' )
	showOverrides:SetColor( SF.Editor.colors.medlight )
	showOverrides:SetHoverColor( SF.Editor.colors.light )
	showOverrides:SetTextColor( SF.Editor.colors.meddark )
	showOverrides.PerformLayout = function () end
	showOverrides:SetText( 'Entity Overrides' )
	showOverrides:SetTooltip( 'You have some overrides already granted to the entity.\nPress to show only them.' )
	showOverrides.update = function ()
		showOverrides:SetVisible( self.area == 1 and self.chip.instance.permissionOverrides and table.Count( self.chip.instance.permissionOverrides ) > 0 )
	end
	showOverrides.DoClick = function ()
		self.area = 2
		self.update()
	end

	local buttons = vgui.Create( 'Panel', self )
	buttons:Dock( BOTTOM )
	buttons:DockMargin( 0, 5, 0, 0 )
	buttons:SetSize( 0, 40 )

	local grant = vgui.Create( 'StarfallButton', buttons )
	grant:Dock( LEFT )
	grant:SetWide( self:GetWide() / 2 - 7.5 )
	grant:SetFont( 'SF_PermissionDesc' )
	grant.states = {
		{
			label = 'Grant',
			hint = 'By pressing this button you mark all overrides visible on your screen for granting.'
		},
		{
			label = 'Apply Permissions',
			hint = 'Requested overrides are marked for granting. Now you can apply them!',
			color = Color( 50, 200, 50 ),
			hoverColor = Color( 100, 255, 100 ),
			textColor = SF.Editor.colors.dark
		},
		{
			label = 'Stay',
			hint = 'Nothing will change.'
		},
		{
			label = 'Revoke Selected',
			hint = 'You have selected overrides for revocation.\nBy pressing this button you revoke them.',
			color = Color( 100, 50, 0 ),
			hoverColor = Color( 150, 100, 0 ),
			textColor = Color( 255, 255, 255 )
		}
	}
	grant.PerformLayout = function () end
	grant.update = function ()
		if self.area == 1 then
			grant.state = 2
			for id, _ in pairs( self.chip.instance.permissionRequest.overrides ) do
				if not self.overrides[ id ] then
					grant.state = 1
					break
				end
			end
		else
			grant.state = 3
			if self.chip.instance.permissionOverrides then
				for id, _ in pairs( self.chip.instance.permissionOverrides ) do
					if not self.overrides[ id ] then
						grant.state = 4
						break
					end
				end
			end
		end
		grant:SetText( grant.states[ grant.state ].label )
		grant:SetTooltip( grant.states[ grant.state ].hint )
		ChangeTooltip( grant )
		grant:SetColor( grant.states[ grant.state ].color or SF.Editor.colors.meddark )
		grant:SetHoverColor( grant.states[ grant.state ].hoverColor or SF.Editor.colors.med )
		grant:SetTextColor( grant.states[ grant.state ].textColor or SF.Editor.colors.light )
	end
	grant.DoClick = function ()
		if grant.state == 1 then
			local scrollPanel = self.permissionsPanel:GetChild( 0 )
			local VBar = scrollPanel:GetVBar()
			for i = 1, 2 do
				for id, perm in ipairs( self.permissionsPanel.index[ 1 ] ) do
					local x, y = perm:GetPos()
					if i == 1 then
						local h = perm:GetTall()
						if VBar:GetScroll() < y + h * 0.2 and VBar:GetScroll() + scrollPanel:GetTall() > y + 0.8 * h then
							if not perm:GetToggle() then
								perm:SetToggle( true )
								perm:OnToggled()
							end
						end
					elseif not perm:GetToggle() then
						VBar:AnimateTo( y, 0.5 )
						break
					end
				end
			end
		else
			if grant.state ~= 3 then self.changeOverrides() end
			self:Close()
		end
	end

	local decline = vgui.Create( 'StarfallButton', buttons )
	decline:Dock( RIGHT )
	decline:SetWide( self:GetWide() / 2 - 7.5 )
	decline:SetFont( 'SF_PermissionDesc' )
	decline.states = {
		{
			label = 'Decline',
			hint = 'You can confidently decline.\nNothing will change.'
		},
		{
			label = 'Revoke All Overrides',
			hint = 'By pressing this button you revoke all overrides per entity.',
			color = Color( 100, 50, 0 ),
			hoverColor = Color( 150, 100, 0 ),
			textColor = Color( 255, 255, 255 )
		}
	}
	decline.PerformLayout = function () end
	decline.update = function ()
		decline.state = self.area
		decline:SetText( decline.states[ decline.state ].label )
		decline:SetTooltip( decline.states[ decline.state ].hint )
		decline:SetColor( decline.states[ decline.state ].color or SF.Editor.colors.meddark )
		decline:SetHoverColor( decline.states[ decline.state ].hoverColor or SF.Editor.colors.med )
		decline:SetTextColor( decline.states[ decline.state ].textColor or SF.Editor.colors.light )
	end
	decline.DoClick = function ()
		if decline.state == 2 then
			self.overrides = {}
			self.changeOverrides()
		end
		self:Close()
	end

	local owner = vgui.Create( 'Panel', self )
	owner:Dock( BOTTOM )
	owner:DockMargin( 0, 5, 0, 0 )
	owner:SetSize( self:GetWide(), 118 )
	owner.update = function ()
		owner:SetVisible( self.area == 1 )
	end
	self.ownerPanel = owner

	local avatar = vgui.Create( 'AvatarImage', owner )
	avatar:Dock( LEFT )
	avatar:SetWide( owner:GetTall() )
	self.ownerAvatar = avatar

	local description = vgui.Create( 'DPanel', owner )
	description:Dock( LEFT )
	description:DockMargin( 5, 0, 0, 0 )
	description:SetWide( owner:GetWide() - avatar:GetWide() - 5 )
	description:SetBackgroundColor( SF.Editor.colors.meddark )
	local descMarkup
	local descWideMax = description:GetWide()
	function description:SetText( str )
		descMarkup = markup.Parse( '<font=SF_PermissionDesc>' .. str .. '</font>', descWideMax - 10 )
		self:SetWide( math.min( descMarkup:GetWidth() + 10, descWideMax ) )
		local tall = math.min( descMarkup:GetHeight(), 108 ) + 10
		self:GetParent():SetTall( tall )
		avatar:SetWide( tall )
	end
	function description:PaintOver( w, h )
		if descMarkup then
			descMarkup:Draw( 5, 5 )
		end
	end
	self.description = description

	self:InvalidateLayout( true )

	self.update = function ()
		showOverrides.update()
		notice.update()
		owner.update()
		grant.update()
		decline.update()
		for n = 0, 3 do
			local scrollPanel = self.permissionsPanel:GetChild( n % 2 )
			if n < 2 then scrollPanel:SetVisible( self.area == n + 1 )
			else scrollPanel:GetCanvas():InvalidateLayout( true ) end
		end
		self:InvalidateLayout( true )
	end
end
function PANEL:PerformLayout()
	if not self.tallAnimation and self.permissionsPanel then
		-- handle tall change when it's not animated
		local tall = self:GetTall() - self.permissionsPanel:GetTall()
		if not self.reservedTall then
			self:SetTall( tall )
		end
		self.reservedTall = tall
	end
end
function PANEL:Think()
	if not self.area then return end
	local scrollPanel = self.permissionsPanel:GetChild( self.area - 1 )
	local VBar = scrollPanel:GetVBar()
	local dest = self.reservedTall + math.Clamp( scrollPanel:GetCanvas():GetTall(), 0, ScrH() - self.reservedTall )
	if self:GetTall() != dest then
		self.tallAnimation = true
		VBar:SetAlpha( 0 )
		local step = Lerp( 0.6, 0, dest - self:GetTall() )
		if self:GetTall() < dest then
			self:SetTall( self:GetTall() + math.ceil( step ) )
		else
			self:SetTall( self:GetTall() + math.floor( step ) )
		end
		self:Center()
	else
		self.tallAnimation = false
		VBar:SetAlpha( VBar:GetAlpha() + math.ceil( Lerp( 0.1, 0, 255 - VBar:GetAlpha() ) ) )
	end
end
function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, SF.Editor.colors.dark )
end
vgui.Register( "SFChipPermissions", PANEL, "DFrame" )
