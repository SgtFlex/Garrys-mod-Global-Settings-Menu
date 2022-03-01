
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

	local DHoriz = vgui.Create("DHorizontalScroller", main)
	DHoriz:SetSize(200,0)
	DHoriz:Dock(LEFT)
	DHoriz:SetOverlap( -4 )
	

	local tree = vgui.Create("DTree", DHoriz)
	tree:Dock(FILL)
	tree:SetSize(500,0)
	tree.PaintOver = function(self, x, y)
		self:SizeToChildren()
	end
	DHoriz:AddPanel(tree)



	function tree:CreateNode(nodeName, nodeInfo)
		local node = self:AddNode(nodeName)
		node.CreateNode = self.CreateNode

		function node:CreateNodeSheet(nodeName, nodeInfo)
			local frame = vgui.Create("DPanel", main)
			frame.Paint = nil
		
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

			local nodeItems = {}
			for controlName, controlInfo in SortedPairs(nodeInfo["controls"]) do
				local label = vgui.Create("DLabel", form)
				label:SetText(controlName)
				label:SetTooltip(controlInfo["desc"])
				label:Dock(LEFT)
				
				
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
					item = vgui.Create("DNumberWang", control)
					local min = (controlInfo.panel and controlInfo["panel"]["min"]) or 0
					local max = (controlInfo.panel and controlInfo["panel"]["max"]) or 9999999
					item:SetMin(min)
					item:SetMax(max)
					item:SetValue(GetConVar(controlInfo["convar"]):GetFloat())
					item:SetConVar(controlInfo["convar"])
					item:Dock(LEFT)
				end
				item:SetZPos(2)
				
				
				table.insert(nodeItems, item)
				item.Default = controlInfo["default"]
				if (controlInfo.panel and controlInfo["panel"]["desc"]) then item:SetTooltip(controlInfo["desc"]) end
				
				local resButton = vgui.Create("DButton", control)
				resButton:SetZPos(1)
				resButton:Dock(LEFT)
				
				resButton:SetSize(16,16)
				resButton:SetIcon("icon16/arrow_rotate_clockwise.png")
				resButton:SetToolTip("Resets this setting to default.")
				resButton.DoClick = function()
					item:SetValue(item.Default)
				end
				form:AddItem(label, control)
				
				label:SetSize(200,0)
				resButton:DockMargin(0, 0, 20, 0)

				
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
			-- local button = vgui.Create("DButton", frame)
			-- button:Dock(BOTTOM)
			-- button:SetText("Reset Equipment Settings")
			-- button.DoClick = function()
			-- 	for _, convar in pairs(tbl_controls) do
			-- 		LocalPlayer():ConCommand(controlInfo["convar"].." "..controlInfo["default"])
			-- 	end
			-- end
		
			return frame
		end



		if (nodeInfo["icon"]!=nil) then 
			node:SetIcon(nodeInfo["icon"]) 
		elseif (nodeInfo["controls"]!=nil) then
			node:SetIcon("icon16/bullet_go.png")			
		end
		node.DoClick = function()
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
		if (nodeInfo["subtree"]!=nil) then
			for nodeName, nodeInfo in SortedPairs(nodeInfo["subtree"]) do
				node:CreateNode(nodeName, nodeInfo) --Get the subtree of this node and run this again
			end
		end

		return node
	end
    



	local sheet = nil
	for nodeName, nodeInfo in SortedPairs(ConVar_Tbl) do
		tree:CreateNode(nodeName, nodeInfo)
	end

	-- local resetAll = vgui.Create("DButton", main)
	-- resetAll:Dock(BOTTOM)
	-- resetAll:SetText("Reset ALL Settings")
	-- resetAll.DoClick = function()
	-- 	for tbl_name, tbl_controls in pairs(allInfo) do
	-- 		for _, convar in pairs(tbl_controls) do
	-- 			LocalPlayer():ConCommand(convar["convar"].." "..convar["default"])
	-- 		end
	-- 	end
	-- end
end





function allInfo:AddControls(tbl)
	table.insert(allInfo, tbl)
end



net.Receive("SettingsPanel", function()
    CreateSettingsMenu()
end)

return allInfo