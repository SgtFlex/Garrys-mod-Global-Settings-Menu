AddCSLuaFile()

-- Example 1) All values present
-- ["Active Camo Equipment"] = {
--     icon = nil,
--     model = nil,
--     controls = {
--         ["Resource Max"] = {
--             convar = "h_active_camo_resource_max",
--             default = 100,
--             desc = "The maximum resource for this equipment.",
--             panel = {
--                 type = "DNumberWang",
--                 min = 0,
--                 max = 99999,
--             }
--         },
--         ["Resource Regen"] = {
--             convar = "h_active_camo_resource_regen",
--             default = 5,
--             desc = "The resource regenerated per second.",
--             panel = {
--                 type = "DNumberWang",
--                 min = 0,
--                 max = 99999,
--             }
--         },
--     },
--     subtree = nil
-- },

-- Example 2) little values present
-- ["Active Camo Equipment"] = {
--     controls = {
--         ["Resource Max"] = {
--             convar = "h_active_camo_resource_max",
--             default = 100,
--         },
--         ["Resource Regen"] = {
--             convar = "h_active_camo_resource_regen",
--             default = 5,
--             panel = {
--                 type = "DNumberSlider",
--             }
--         },
--     },
-- },

-- You can copy paste this for a 'node' and fill in what you need
-- ["Name of Node"] = {
--     icon = nil,
--     model = nil,
--     controls = {
--         ["Control 1"] = {
--             convar = "h_control_1",
--             default = 100,
--             desc = "The maximum resource for this equipment.",
--             panel = {
--                 type = "DNumberWang",
--                 min = 0,
--                 max = 99999,
--             }
--         },
--         ["Resource Regen"] = {
--             convar = "h_control_1",
--             default = 5,
--             desc = "The resource regenerated per second.",
--             panel = {
--                 type = "DNumberWang",
--                 min = 0,
--                 max = 99999,
--             }
--         },
--     },
--     subtree = nil
-- },

return {
    ["AI Settings"] = {
        controls = {
            ["AI Disable"] = {
                convar = "ai_disabled",
                default = 0,
                desc = "Enables/Disables AI's thinking.",
                panel = {type = "DCheckBox",}
            },
            ["AI Ignore Players"] = {
                convar = "ai_ignoreplayers",
                default = 0,
                desc = "Enables/Disables AI's perception of players.",
                panel = {type = "DCheckBox",}
            },
            ["AI Keep Corpses"] = {
                convar = "ai_force_serverside_ragdoll",
                default = 0,
                desc = "Enables/Disables serverside ragdolls from dead NPCs.",
                panel = {type = "DCheckBox",}
            },
        },
    },
    ["Developer"] = {
        controls = {
            ["Developer Mode"] = {
                convar = "developer",
                default = 0,
                desc = "Enables Gmod Developer mode.",
                panel = {type = "DCheckBox",}
            },
        }
    },
    ["General"] = {
        controls = {
            ["Multi-Core"] = {
                convar = "gmod_mcore_test",
                default = 0,
                desc = "WARNING: CAN CAUSE INSTABILITY OR CRASHES. Enables use of Multi-core in Gmod.",
                panel = {type = "DCheckBox",}
            },
            ["God mode"] = {
                desc = "NOTE: REQUIRES 'sv_cheats 1' IN ORDER TO WORK. Makes it so players never take damage.",
                panel = {type = "DButton",
                onclick = function(self) 
                    LocalPlayer():ConCommand("god") 
                end,}
            },
            ["Buddha mode"] = {
                desc = "NOTE: REQUIRES 'sv_cheats 1' IN ORDER TO WORK. Player can take damage but never dies.",
                panel = {type = "DButton",
                onclick = function(self) 
                    LocalPlayer():ConCommand("buddha") 
                end,}
            },
        },
    },
}