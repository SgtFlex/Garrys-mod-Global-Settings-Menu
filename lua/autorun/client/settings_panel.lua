local allInfo = {}
function CreateSettingsMenu()
	local main = vgui.Create( "DFrame" )
	main:SetSize(700, 700)
	main:DockPadding(20, 40, 20, 20)
	main:SetSizable(true)
	main:SetTitle( "Flex's Settings Panel" ) 
	main:SetVisible( true ) 
	main:SetDraggable( true ) 
	main:ShowCloseButton( true ) 
	main:MakePopup()
	main:Center()

	local left = vgui.Create("DPanel", main)
	left:SetSize(200, 0)
	left:Dock(LEFT)

	local trees = {}
	local search = vgui.Create("DTextEntry",left)
	search:SetSize(0, 20)
	search:Dock(TOP)
	search:SetPlaceholderText("Search...")
	search:SetUpdateOnType(true)

	local searchInfo = vgui.Create("DCheckBoxLabel", left)
	searchInfo:SetSize(0, 20)
	searchInfo:Dock(TOP)
	searchInfo:SetText("+Search controls.")
	searchInfo:SetToolTip("Also searches and displays the controls of a node that match the search.")
	searchInfo:SetTextColor(Color(0,0,0,255))
	searchInfo:SetValue(true)

	local searchTags = vgui.Create("DCheckBoxLabel", left)
	searchTags:SetSize(0, 20)
	searchTags:Dock(TOP)
	searchTags:SetText("+Search tags.")
	searchTags:SetToolTip("Also searches the tags of nodes (and also control's tags if +Search Controls is enabled).")
	searchTags:SetTextColor(Color(0,0,0,255))
	searchTags:SetValue(true)
	

	local clearButton = nil
	search.OnValueChange = function(self, value)
		
		if (value!="" and !clearButton) then
			clearButton = vgui.Create("DImageButton", self)
			clearButton:Dock(RIGHT)
			clearButton:SetSize(20, 20)
			clearButton:SetImage("icon16/cancel.png")
			clearButton.DoClick = function(self)
				search:SetValue("")
				clearButton:Remove()
				clearButton = nil
			end
		else
			if (clear) then
				clear:Remove()
				clearButton = nil
			end
		end
		local foundName = false
		local foundTag = false
		for k, tree in pairs(trees) do
			nodeStack = util.Stack()
			nodeStack:Push(tree:Root())
			while (nodeStack:Size() > 0) do
				local node = nodeStack:Pop()
				node.searchTerm = nil
				if (string.match(string.lower(node:GetText()), string.lower(value))) then
					foundName = true
				elseif (foundName==false and searchTags:GetChecked()==true and node.tags!=nil) then
					for k, v in pairs(node.tags) do
						if (string.match(string.lower(v), string.lower(value))) then 
							foundName = true
							break 
						end
					end
				end
				if (foundName==false and searchInfo:GetChecked()==true and node.controls!=nil) then --If we name didn't match, then search the tags of the node
					for k, v in pairs(node.controls) do
						local desc = v["desc"] or ""
						if (string.match(string.lower(k..desc), string.lower(value))) then 
							foundTag = true
							node.searchTerm = value
							break
						end
						if (v.tags and searchTags:GetChecked()==true) then
							for i, j in pairs(v.tags) do --search the tags of each control
								if (string.match(string.lower(j), string.lower(value))) then 
									foundTag = true
									node.searchTerm = value
									break
								end
							end
						end
					end
				end
				if (foundName==true or foundTag==true) then
					local showNode = node
					while (showNode!=nil) do
						showNode:SetVisible(true)
						showNode:SetExpanded(true)
						if (!showNode:IsRootNode()) then
							showNode = showNode:GetParentNode()
						else
							showNode = nil
						end
					end
					foundName = false
					foundTag = false
				else
					node:SetVisible(false)
					node:SetExpanded(false)
				end
				
				for k, nodeChild in pairs(node:GetChildNodes()) do
					nodeStack:Push(nodeChild)
				end
			end
		end
	end

	searchInfo.OnChange = function()
		search.OnValueChange(self, search:GetValue())
	end
	searchTags.OnChange = function()
		search.OnValueChange(self, search:GetValue())
	end

	local DHoriz = vgui.Create("DHorizontalScroller", left)
	DHoriz:Dock(FILL)
	DHoriz:SetOverlap( -4 )
	
	local tree = vgui.Create("DTree", DHoriz)
	table.insert(trees, tree)
	tree:Dock(FILL)
	tree:SetSize(500,0)
	tree.PaintOver = function(self, x, y)
		self:SizeToChildren()
	end
	DHoriz:AddPanel(tree)

	function tree:CreateNode(nodeName, nodeInfo)
		local node = self:AddNode(nodeName)
		if (nodeInfo.controls) then node.controls = nodeInfo["controls"] end
		if (nodeInfo.tags) then node.tags = nodeInfo["tags"] end
		node.CreateNode = self.CreateNode
		
		

		function node:CreateNodeSheet(nodeName, nodeInfo)
			
			local frame = vgui.Create("DPanel", main)
			frame.Paint = nil

			local searchForm = vgui.Create("DTextEntry", frame)
			searchForm:Dock(TOP)
			searchForm:SetSize(0,20)
			searchForm:SetPlaceholderText("Search...")
			searchForm:SetUpdateOnType(true)
			
		
			local scroll = vgui.Create("DScrollPanel", frame)
			scroll:Dock(FILL)
		
			local form = vgui.Create("DForm", scroll)
			form:Dock(TOP)
			form:SetName(nodeName)
			form:DoExpansion(true)
			form:DockPadding(0, 0, 0, 10)
			form.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, Color(0,0,100, 225))
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
		
			if (nodeInfo["model"]!=nil) then
				local model = vgui.Create("DModelPanel", form)
				model:SetSize(200, 200)
				model:SetModel(nodeInfo["model"])
				local z = select(2, model.Entity:GetRenderBounds()).z
				model:SetCamPos(Vector(model.Entity:GetModelRadius()*2,0,z))
				model:SetLookAt(Vector(0,0,z/2))
				model:SetAnimated(true)
				model.PaintOver = function(self, w, h)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawOutlinedRect(0, 0, w, h)
				end
				form:AddItem(model)
			end
			
			local formRows = {}
			local nodeItems = {}
			for controlName, controlInfo in SortedPairs(nodeInfo["controls"]) do
				local label = vgui.Create("DLabel", form)
				label:SetText(controlName)
				label:Dock(LEFT)
				if (controlInfo["desc"]) then label:SetToolTip(controlInfo["desc"]) end
				
				local item = nil
				local control = vgui.Create("DPanel")
				control:Dock(FILL)
				control.Paint = nil

				if (!controlInfo.panel or controlInfo["panel"]["type"]=="DNumberWang") then --Create a DNumberWang by default
					item = vgui.Create("DNumberWang", control)
					local min = (controlInfo.panel and controlInfo["panel"]["min"]) or 0
					local max = (controlInfo.panel and controlInfo["panel"]["max"]) or 9999999
					item:SetMin(min)
					item:SetMax(max)
					item:SetValue(GetConVar(controlInfo["convar"]):GetFloat())
					item:SetConVar(controlInfo["convar"])
					item:Dock(LEFT)
				elseif (controlInfo["panel"]["type"]=="DNumberSlider") then
					local min = (controlInfo.panel and controlInfo["panel"]["min"]) or 0
					local max = (controlInfo.panel and controlInfo["panel"]["max"]) or 9999999
					item = vgui.Create("DNumSlider", control)
					item:SetDecimals(0)
					item:SetMin(min)
					item:SetMax(max)
					item:SetSize(200,0)
					--item:SetValue(GetConVar(controlInfo["convar"]):GetFloat())
					item:SetConVar(controlInfo["convar"])
					item:GetTextArea():Dock(LEFT)
					item:Dock(FILL)
				elseif (controlInfo["panel"]["type"]=="DCheckBox") then
					item = vgui.Create("DCheckBox", control)
					item:SetValue(GetConVar(controlInfo["convar"]):GetBool())
					item:SetConVar(controlInfo["convar"])
					item.DoClick = function()
						item:Toggle()
					end
					item:Dock(LEFT)
				elseif (controlInfo["panel"]["type"]=="DComboBox") then
					item = vgui.Create("DComboBox", control)
					item:SetValue(GetConVar(controlInfo["convar"]):GetString())
					for k, v in pairs(controlInfo["panel"]["options"]) do
						item:AddChoice(k, v)
					end
					item.OnSelect = function(index, value, data)
						LocalPlayer():ConCommand(controlInfo["convar"].." "..data)
					end
					item:Dock(FILL)
				elseif (controlInfo["panel"]["type"]=="DButton") then
					item = vgui.Create("DButton", control)
					item:SetText(controlName)
					if (controlInfo["panel"]["onclick"]!=nil) then
						item.DoClick = controlInfo["panel"]["onclick"]
					end
					item:Dock(LEFT)
				else
					if (pcall(function() item = vgui.Create(controlInfo.panel.type, control) end)==false) then
						item:Dock(LEFT)
						item.OnValueChanged = controlInfo.ExtraOnValueChanged
					end
				end
				item:SetZPos(2)
				if (controlInfo.ExtraOnValueChange) then controlInfo.ExtraOnValueChange() end
				
				table.insert(nodeItems, item)
				item.Default = controlInfo["default"]
				if (controlInfo["desc"]) then item:SetTooltip(controlInfo["desc"]) end
				
				if (controlInfo.default) then
					local resButton = vgui.Create("DButton", control)
					resButton:SetZPos(1)
					resButton:Dock(LEFT)
					resButton:SetSize(16,16)
					resButton:SetIcon("icon16/arrow_rotate_clockwise.png")
					resButton:SetToolTip("Resets this setting to default.")
					resButton.DoClick = function()
						item:SetValue(item.Default)
					end
					resButton:DockMargin(0, 0, 20, 0)
				end
				table.insert(formRows, {label, resButton, item, controlInfo["tags"]})
				
				form:AddItem(label, control)
				item:GetParent():SizeToChildren(false, true)
				
				label:SetSize(200,0)
				
			end

			searchForm.OnValueChange = function(self, value)
				local found = false
				for k, row in pairs(formRows) do
					found = false
					local label = row[1]:GetText()
					if (string.match(string.lower(label..row[1]:GetTooltip()), string.lower(value))) then
						found = true
					elseif (searchTags:GetChecked()==true and row[4]!=nil) then
						for i, j in pairs(row[4]) do
							if (string.match(string.lower(j), string.lower(value))) then
								found = true
								break
							end
						end
					else
						found = false
					end
					row[1]:GetParent():SetVisible(found)
				end
				form:InvalidateLayout()
				form:SizeToChildren(false, true)
			end
			if (self.searchTerm) then
				searchForm:SetValue(self.searchTerm)
			end

			
			local resNode = vgui.Create("DButton", frame)
			resNode:SetToolTip("Resets all settings within this node.")
			resNode:SetText("Reset Node Settings")
			resNode:Dock(BOTTOM)
			resNode.DoClick = function()
				for _, item in pairs(nodeItems) do
					item:SetValue(item.Default)
				end
			end
		
			return frame
		end



		if (nodeInfo["icon"]!=nil) then 
			node:SetIcon(nodeInfo["icon"]) 
		elseif (nodeInfo["controls"]!=nil) then
			node:SetIcon("icon16/bullet_go.png")			
		end
		node.DoClick = function(self)
			if (nodeInfo["controls"]!=nil) then
				if !IsValid(sheet) then
					sheet = vgui.Create("DPropertySheet", main)
					sheet:Dock(FILL)
					sheet.tabs = {}
					sheet:SetFadeTime(0)
				end
				for k, v in pairs(sheet:GetItems()) do
					if (v.Name == nodeName) then
						sheet:SetActiveTab(v.Tab)
						return
					end
				end
				local unitP = self:CreateNodeSheet(nodeName, nodeInfo)
				local tab_Tbl = sheet:AddSheet(nodeName, unitP)
				unitP:SetParent(sheet)
				sheet:SetActiveTab(tab_Tbl.Tab)
				tab_Tbl.Tab.DoRightClick = function(self)
					if (#sheet:GetItems()<=1) then
						sheet:Remove()
					else
						sheet:CloseTab(self, true)
					end                    
				end
			end
		end
		node.DoRightClick = function(self)
			self:ExpandRecurse(!node.Expanded)
		end
		node.children = {}
		if (nodeInfo["subtree"]!=nil) then
			for nodeName, nodeInfo in SortedPairs(nodeInfo["subtree"]) do
				node.children[nodeName] = node:CreateNode(nodeName, nodeInfo) --Get the subtree of this node and run this again
				-- node.children.parent = node
			end
		end
		node.labDesc = {}
		if (nodeInfo["controls"]!=nil) then
			for name, control in pairs(nodeInfo["controls"]) do
				local a = string.lower(name)
				local b = (control.desc and string.lower(" "..control["desc"])) or ""
				node.labDesc[a..b]=true
			end
		end
		

		return node
	end
	local sheet = nil
	for nodeName, nodeInfo in SortedPairs(ConVar_Tbl) do
		tree:CreateNode(nodeName, nodeInfo)
	end
end





function allInfo:AddControls(tbl)
	table.insert(allInfo, tbl)
end

return allInfo