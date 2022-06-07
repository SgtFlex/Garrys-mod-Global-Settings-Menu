ConVar_Tbl = {}
local addon_settings = file.Find("settings_panel_info/*", "LUA")
for _, file in pairs(addon_settings) do
    AddCSLuaFile("settings_panel_info/"..file)
    local fileName = string.sub(file, 1, -5)
    fileName = string.Replace(fileName, "_", " ")
    local tbl = include("settings_panel_info/"..file)
    local name = tbl.name or fileName
    ConVar_Tbl[name] = tbl
end

CreateClientConVar("gsm_search_controls", 1, true, false, "Searches controls in GSM")
CreateClientConVar("gsm_search_tags", 1, true, false, "Searches controls in GSM")

--Keep in shared I think..
function SetupDefaultConvars(tbl_nodes)
    for k, node in pairs(tbl_nodes) do
        if (node["controls"]!=nil) then
            for j, control in pairs(node["controls"]) do
                if (control["convar"]!=nil and !ConVarExists(control["convar"])) then
                    local min = (control.panel and control["panel"]["min"]) or 0
                    local max = (control.panel and control["panel"]["max"]) or 99999999
                    if control["client"]!=true then
                        CreateConVar(control["convar"], control["default"], bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED), control["desc"], min, max)
                    else
                        if CLIENT then
                            CreateClientConVar(control["convar"], control["default"], true, false, control["desc"], min, max)
                        end
                    end
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
    ["globalsettingsmenu"] = true,
    ["gsm"] = true,
}

if CLIENT then
    for name, _ in pairs(synonyms) do
        concommand.Add(name, function(ply, cmd, args, argStr)
            CreateSettingsMenu(argStr)
        end, nil, "Opens Global Settings Menu")

        concommand.Add("!"..name, function(ply, cmd, args, argStr)
            CreateSettingsMenu(argStr)
        end, nil, "Opens Global Settings Menu")
    end
end





if SERVER then
    AddCSLuaFile("client/cl_init.lua")

    hook.Add("PlayerSay", "settings_panel", function(sender, text, teamChat)
        if (string.StartWith(text, "!")==false) then return end
        local w1 = string.lower(string.sub(text, 2, 4))
        local w2 = string.lower(string.sub(text, 6))
        if (synonyms[w1]==true) then
            sender:ConCommand("gsm".." "..w2)
            return ""
        end
    end)
end