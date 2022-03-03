ConVar_Tbl = {}
local addon_settings = file.Find("settings_panel_info/*", "LUA")
for _, file in pairs(addon_settings) do
    AddCSLuaFile("settings_panel_info/"..file)
    local fileName = string.sub(file, 1, -5)
    fileName = string.Replace(fileName, "_", " ")
    ConVar_Tbl[fileName] = {
        subtree = include("settings_panel_info/"..file),
    }
end


function SetupDefaultConvars(tbl_nodes)
	for k, node in pairs(tbl_nodes) do
        if (node["controls"]!=nil) then
            for j, control in pairs(node["controls"]) do
                if (control["convar"]!=nil) then
                    CreateConVar(control["convar"], control["default"], FCVAR_ARCHIVE, control["desc"])
                end
            end
        end
        if (node["subtree"]!=nil) then
            SetupDefaultConvars(node["subtree"])
        end
	end
end

SetupDefaultConvars(ConVar_Tbl)

concommand.Add("settings_panel", function(ply)
    net.Start("SettingsPanel")
    net.Send(ply)
end)

hook.Add("PlayerSay", "settings_panel", function(sender, text, teamChat)
    if (text=="!settings_panel") then
        sender:ConCommand("settings_panel")
        return ""
    end
end)

if SERVER then
    util.AddNetworkString("SettingsPanel")
    AddCSLuaFile("client/cl_init.lua")
end