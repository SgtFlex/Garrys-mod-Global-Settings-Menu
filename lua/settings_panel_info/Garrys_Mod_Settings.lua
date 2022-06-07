return {
    name = "Garrys Mod",
    icon = "games/16/garrysmod.png",
    subtree = {
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
        ["Tools"] = {
            subtree = {
                ["Physics Gun"] = {
                    controls = {
                        ["Time to Arrive"] = {
                            convar = "physgun_timeToArrive",
                            desc = "How fast the held entity should arrive to target position in front of the player",
                            default = 0.05,
                        },
                        ["Time to Arrive (Ragdolls)"] = {
                            convar = "physgun_timeToArriveRagdoll",
                            desc = "How fast the held ragdoll should arrive to target position in front of the player",
                            default = 0.1,
                        },
                        ["Teleport Distance"] = {
                            convar = "physgun_teleportDistance",
                            default = 0,
                            desc = "If distance between target position and current position of held entity is greater than this, the held entity will teleport to target position, instead of trying to get there by flying.",
                        },
                        ["Limited functionality"] = {
                            convar = "physgun_limited",
                            default = 0,
                            desc = "When enabled the physgun can only pickup props and ragdolls.",
                            panel = {type = "DCheckBox"}
                        },
                        ["Rotation Sensitivity"] = {
                            convar = "physgun_rotation_sensitivity",
                            default = 0.05,
                            desc = "The sensitivity of rotation",
                        },
                        ["Scrolling Sensitivity"] = {
                            convar = "physgun_wheelspeed",
                            default = 10,
                            desc = "The sensitivity of scrolling",
                        },
                        ["Max Angular Velocity"] = {
                            convar = "physgun_maxAngular",
                            default = 5000,
                            desc = "Max angular velocity of held entity",
                        },
                        ["Max Angular Damping"] = {
                            convar = "physgun_maxAngularDamping",
                            default = 10000,
                            desc = "Max Angular Damping of held entity",
                        },
                        ["Max Speed"] = {
                            convar = "physgun_maxSpeed",
                            default = 5000,
                            desc = "Max velocity of held entity",
                        },
                        ["Max Speed Damping"] = {
                            convar = "physgun_maxSpeed",
                            default = 5000,
                            desc = "Max velocity damping of held entity",
                        },
                        ["Grid Snap Amount"] = {
                            convar = "gm_snapgrid",
                            default = 0,
                            desc = "Snaps your props to a grid based on the value set",
                        },
                        ["Rotation Snap Amount"] = {
                            convar = "gm_snapangles",
                            default = 45,
                            desc = "How many degrees should the entity snap when rotating with shift+e",
                        },
                    }
                }
            }
        }
    }
}