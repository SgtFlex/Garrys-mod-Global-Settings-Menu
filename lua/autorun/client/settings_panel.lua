local allInfo = {}
local main = nil
local search = nil
function CreateSettingsMenu(searchText)
	if main and main:IsValid() then 
		main:Show()
		if searchText then
			search:SetValue(searchText)
		end
		return 
	end
	main = vgui.Create( "DFrame" )
	main:SetSize(700, 700)
	main:DockPadding(10, 30, 10, 10)
	main:SetSizable(true)
	main:SetTitle( "Flex's Settings Panel" ) 
	main:SetVisible( true ) 
	main:SetDraggable( true ) 
	main:ShowCloseButton( true ) 
	main:MakePopup()
	main:Center()
	main.btnMinim:SetDisabled(false)
	function main.btnMinim:DoClick()
		main:Hide()
	end

	main.btnMaxim:SetDisabled(false)
	function main.btnMaxim:DoClick()
		main:SetSize(ScrW(), ScrH())
		main:Center()
	end

	-- function main:OnCursorEntered()
	-- 	main:KillFocus()
	-- 	print("entered")
	-- end

	-- function main:OnCursorExited()
	-- 	main:KillFocus()
	-- 	print("exited")
	-- end


	local left = vgui.Create("DFrame", main)
	left:SetSize(200, 0)
	left:Dock(LEFT)
	left:SetSizable(true)
	left:SetDraggable(false)
	left:ShowCloseButton(false)
	function left:Paint(w, h)
		surface.SetDrawColor(200,200,200,255)
		surface.DrawRect(0, 0, w, h)
	end
	left:SetTitle("Settings Navigation")

	local trees = {}
	search = vgui.Create("DTextEntry",left)
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
	searchInfo:SetConVar("gsm_search_controls")

	local searchTags = vgui.Create("DCheckBoxLabel", left)
	searchTags:SetSize(0, 20)
	searchTags:Dock(TOP)
	searchTags:SetText("+Search tags.")
	searchTags:SetToolTip("Also searches the tags of nodes (and also control's tags if +Search Controls is enabled).")
	searchTags:SetTextColor(Color(0,0,0,255))
	searchTags:SetConVar("gsm_search_tags")
	
	
	local clearButton = nil
	search.OnValueChange = function(self, value)
		
		if (value != "") then
			if not clearButton then
				clearButton = vgui.Create("DImageButton", self)
				clearButton:Dock(RIGHT)
				clearButton:SetSize(20, 20)
				clearButton:SetImage("icon16/cancel.png")

				function clearButton:DoClick()
					search:SetValue("")
					self:Remove()
					self = nil
				end
			end
		elseif clearButton and clearButton:IsValid() then
			clearButton:Remove()
			clearButton = nil
		end
		local foundName = false
		local foundTag = false
		for k, tree in pairs(trees) do
			nodeStack = util.Stack()
			nodeStack:Push(tree:Root())
			while (nodeStack:Size() > 0) do
				local node = nodeStack:Pop()
				node.searchTerm = nil
				if (string.lower(node:GetText()) == string.lower(value)) then
					node:DoClick()
					foundName = true
				elseif (string.match(string.lower(node:GetText()), string.lower(value))) then
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
		if search:GetValue()!="" then
			search.OnValueChange(self, search:GetValue())
		end
	end
	searchTags.OnChange = function()
		if search:GetValue()!="" then
			search.OnValueChange(self, search:GetValue())
		end
	end

	if searchText then 
		search:SetValue(searchText) 
	end

	local contain1 = vgui.Create("DPanel", left)
	contain1:Dock(TOP)
	contain1:SetSize(0, 20)

	local collapseB = vgui.Create("DButton", contain1)
	collapseB:Dock(LEFT)
	collapseB:SetWide(100)
	collapseB:SetText("Collapse All")

	function collapseB:DoClick()
		for k, tree in pairs(trees) do
			nodeStack = util.Stack()
			nodeStack:Push(tree:Root())
			while (nodeStack:Size() > 0) do
				local node = nodeStack:Pop()

				---Do things with node
				if (tree:Root() != node) then
					node:SetExpanded(false)
				end

				---end node code
				for k, nodeChild in pairs(node:GetChildNodes()) do
					nodeStack:Push(nodeChild)
				end
			end
		end
	end

	local expandB = vgui.Create("DButton", contain1)
	expandB:Dock(RIGHT)
	expandB:SetWide(100)
	expandB:SetText("Expand All")

	function expandB:DoClick()
		for k, tree in pairs(trees) do
			nodeStack = util.Stack()
			nodeStack:Push(tree:Root())
			while (nodeStack:Size() > 0) do
				local node = nodeStack:Pop()

				---Do things with node
				node:SetExpanded(true)

				---end node code
				for k, nodeChild in pairs(node:GetChildNodes()) do
					nodeStack:Push(nodeChild)
				end
			end
		end
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

	tree:GetVBar():Dock(LEFT)
	tree:GetCanvas():DockPadding(15, 0, 0, 0)

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
			local changeTypes = {
				["OnChange"] = true,
				["OnValueChange"] = true,
				["OnValueChanged"] = true,
			}
			local alt = true
			for controlName, controlInfo in SortedPairs(nodeInfo["controls"]) do
				alt = !alt
				local label = vgui.Create("DLabel", form)
				label:SetText(controlName)
				label:Dock(LEFT)
				if (controlInfo["desc"]) then label:SetToolTip(controlInfo["desc"]) end
				
				local item = nil
				local control = vgui.Create("DPanel")
				control:Dock(FILL)
				control.Paint = nil
				
				local panelT = ((controlInfo.panel and controlInfo.panel.type) or "DNumberWang")
				item = vgui.Create(panelT)
				item:SetParent(control)
				item:Dock(LEFT)
				local resButton = nil
				if (controlInfo.default) then
					resButton = vgui.Create("DButton", control)
					resButton:SetZPos(1)
					resButton:Dock(LEFT)
					resButton:SetSize(16,16)
					resButton:SetIcon("icon16/arrow_rotate_clockwise.png")
					resButton:SetToolTip("Resets this setting to default.")
					resButton.m_Image:Dock(FILL)
					resButton:DockMargin(0, 0, 20, 0)

					

					local usable = true
					function resButton:SetUsable(bool)
						if (bool==true) then
							usable = true
							self:SetMouseInputEnabled(true)
						else
							usable = false
							self:SetMouseInputEnabled(false)
						end
					end

					function resButton:GetUsable()
						return usable
					end

					function resButton:Paint(w, h)
						local vis = nil
						if (resButton:GetUsable()==true) then
							vis = 255
						else
							vis = 75
						end
						draw.RoundedBox(3.5, 0, 0, w, h, Color(255, 255, 255, vis))
					end

					function resButton:DoClick()
						item:SetValue(item.Default)
						self:SetUsable(false)
					end

				end
				
				local adjustments = {
					-- DNumSlider is composed of 4 different Derma elements: DLabel, DNumberScratch, DSlider, and DTextEntry
					-- I like the makeup of DNumSlider, it just needs some adjustments to work within a DForm properly
					["DNumSlider"] = function(panel)
						panel:SetSize(500, 0)
						panel:Dock(FILL) 
						
						panel:GetTextArea():SetSize(30, 0)
						panel:GetTextArea():Dock(LEFT)
						panel.Scratch:SetImageVisible(true)
						panel.Scratch:SetSize(50, 0)
						panel.Scratch:Dock(LEFT)
						panel.Slider:SetSize(150, 0)
						panel.Slider:Dock(LEFT)
						panel.Label:SetVisible(true) --For some reason controls the number scratch
						panel.Label:Dock(LEFT)
						panel:SetMin((controlInfo.panel and controlInfo.panel.min) or 0)
						panel:SetMax((controlInfo.panel and controlInfo.panel.max) or 100)
						panel:SetDecimals((controlInfo.panel and controlInfo.panel.decimals) or 0)
						
					end,
					["DNumberWang"] = function(panel)
						panel:SetMin((controlInfo.panel and controlInfo.panel.min) or 0)
						panel:SetMax((controlInfo.panel and controlInfo.panel.max) or 1000000)
						local _, fraction = math.modf(controlInfo.default)
						local count = math.max(0, #tostring(fraction) - 2)
						local decimals = (controlInfo.panel and controlInfo.panel.decimals) or count or 0
						panel:SetDecimals(decimals)
						panel:SetInterval(1/10^(decimals))
					end,
					["DButton"] = function(panel)
						panel:SetText(controlName)
					end
				}
				
				

				if (adjustments[panelT]) then adjustments[panelT](item) end --Uses adjustments per panel type. Essentially a switch statement
				
				if (controlInfo.convar) then 
					item:SetValue(GetConVar(controlInfo.convar):GetFloat())
					item:SetConVar(controlInfo.convar) 
				end
				if (controlInfo.default and (item:GetValue() == controlInfo.default or (item.GetChecked and (item:GetChecked() and 1 or 0) == controlInfo.default))) then resButton:SetUsable(false) end
				if (controlInfo.panel) then
					for k, v in pairs(controlInfo.panel) do --If things like OnChange or OnValueChange are provided, change it to the value provided
						
						if (controlInfo.convar and changeTypes[k]==true) then
							cvars.AddChangeCallback(controlInfo.convar, controlInfo.OnChange)
						else
							item[k] = v
						end
					end
				end

				for k, v in pairs(changeTypes) do
					if resButton and item[k] then
						item[k] = function(self, value)
							local decimals = (controlInfo.panel and controlInfo.panel.decimals) or 0
							if (isbool(value)) then value = (value and 1) or 0 end
							if (math.Round(value, decimals) != controlInfo.default) then
								resButton:SetUsable(true)
							else
								resButton:SetUsable(false)
							end
						end
					end
				end

				if (controlInfo.convar and controlInfo.OnChange) then
					cvars.AddChangeCallback(controlInfo.convar, controlInfo.OnChange)
				end

				if (controlInfo.panel and controlInfo.panel.extra) then controlInfo.panel.extra(item) end

				item:SetZPos(2)
				if (controlInfo.ExtraOnValueChange) then controlInfo.ExtraOnValueChange() end
				
				table.insert(nodeItems, item)
				item.Default = controlInfo["default"]
				if (controlInfo["desc"]) then item:SetTooltip(controlInfo["desc"]) end
				
				
				table.insert(formRows, {label, resButton, item, controlInfo["tags"]})
				
				form:AddItem(label, control)
				local p = item:GetParent():GetParent()
				p:DockPadding(5, 5, 5, 5)
				p:DockMargin(5, 0, 5, 0)
				p:SizeToChildren(false, true)
				p.paintAlt = alt
				function p:Paint(w, h)
					if self.paintAlt==true then
						surface.SetDrawColor(255,255,255,10)
						surface.DrawRect(0, 0, w, h)
					end
				end

				

				label:SetSize(200,0)
				
			end


			local clearForm = nil
			searchForm.OnValueChange = function(self, value)

				if (value != "") then
					if not clearForm then
						clearForm = vgui.Create("DImageButton", self)
						clearForm:Dock(RIGHT)
						clearForm:SetSize(20, 20)
						clearForm:SetImage("icon16/cancel.png")
		
						function clearForm:DoClick()
							searchForm:SetValue("")
							self:Remove()
							self = nil
						end
					end
				elseif clearForm and clearForm:IsValid() then
					clearForm:Remove()
					clearForm = nil
				end

				
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