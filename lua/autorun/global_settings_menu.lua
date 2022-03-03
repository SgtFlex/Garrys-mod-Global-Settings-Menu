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

local synonyms = {
    ["global_settings_menu"] = true,
    ["global settings menu"] = true,
    ["globalsettingsmenu"] = true,
    ["gsm"] = true,
}

for name, _ in pairs(synonyms) do
    concommand.Add(name, function(ply)
        net.Start("SettingsPanel")
        net.Send(ply)
    end)

    concommand.Add("!"..name, function(ply)
        net.Start("SettingsPanel")
        net.Send(ply)
    end)
end


hook.Add("PlayerSay", "settings_panel", function(sender, text, teamChat)
    if ("!"..tostring(synonyms[text])) then
        sender:ConCommand("gsm")
        return ""
    end
end)

if SERVER then
    util.AddNetworkString("SettingsPanel")
    AddCSLuaFile("client/cl_init.lua")
end