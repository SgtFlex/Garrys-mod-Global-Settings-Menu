return {
    ["Entity 1"] = { --An example with all possible table values filled so you know what you can work with
        model = "models/combine_helicopter/helicopter_bomb01.mdl", --The model used for users to easily identify what they're modifying
        icon = "icon16/bomb.png", --The icon dispalyed for the node in the tree part of the menu
        controls = {
            ["Explosion Damage"] = {
                convar = "ma_bomb_damage", --The name of the convar you wish to use. Make sure it's unique!
                default = 100, --The default value used when the convars(Console variables) are created
                desc = "The bomb's damage.", --Tooltip displayed on hover
                panel = {type = "DNumberWang", min = 0, max = 100},
                --The type of panel used for displaying this convar. The types supported are "DNumberWang", "DNumSlider", "DCheckBox", "DButton". 
                --More will come in the future so check the changelog if you're looking for more
            },
            ["Explode bomb!"] = {
                panel = {type = "DButton", onclick = function(self)
                    print("Boom!")
                end}
            },
        },
    },
    ["Entity 2"] = {
        controls = {
            ["Health"] = {
                convar = "entity2_health",
                default = 0,
                desc = "Controls health.",
                panel = {type = "DNumberWang"}
            },
        },
    },
    ["Wildlife"] = { --This node is meant just for categorizing. Doesn't actually open a menu when clicked since there's no controls present
        subtree = {
            ["Entity 3"] = { --Since Entity3 is a child of Wildlife, it is presumed that Entity3 is some sort of wildlife
                controls = {
                    ["Health"] = {
                        convar = "entity3_health",
                        default = 0,
                        desc = "Controls health.",
                        panel = {type = "DNumberWang"}
                    },
                },
                subtree = {
                    ["Weapon"] = { --Since Weapon is a child node of Entity3, it's presume that it's a part of Entity3. You get the idea?
                        controls = {
                            ["Damage"] = {
                                convar = "entity3_weapon_dmg",
                                default = 0,
                                desc = "Controls entity3's weapon damage.",
                                panel = {type = "DNumberWang"}
                            },
                            ["Fire Rate"] = {
                                convar = "entity3_weapon_fr",
                                default = 0,
                                desc = "Controls entity3's weapon fire rate.",
                                panel = {type = "DNumberWang", min = 0.001}
                            },
                        },
                    },
                },
            },
        },
    },
}
--convar REQUIRED per control (except DButton)
--default REQUIRED per control (except DButton)
--everything else is optional. Values will be autocompleted (like type will be autofilled to DNumberWang) or left out (like desc) if blank.
--DButton can execute code when clicked. Look at example above