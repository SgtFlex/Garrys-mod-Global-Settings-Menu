return {
    name = "Template", --ONLY APPLIES TO ROOT NODE. If provided, the root node will be named this. Otherwise it will use the filename
    icon = "icon16/bomb.png", --The icon for the root node
    subtree = {
        ["Entity 1"] = { --An example with all possible table values filled so you know what you can work with
            model = "models/combine_helicopter/helicopter_bomb01.mdl", --The model used for users to easily identify what they're modifying
            icon = "icon16/bomb.png", --The icon dispalyed for the node in the tree part of the menu
            tags = {"hello world", "tester"}, --When searching nodes, this node will be displayed if part of the search term resembles one of these tags. 
            --for example: Try searching "test"  and this node will come up since "test" resembles "tester", which is one of this node's tags
            controls = {
                ["Explosion Damage"] = {
                    client = false, --Is this a client convar or a serverside one? (Things like entity health, damage, etc are NOT client convars. Only stuff like FOV, HUD bounds, etc are).
                    convar = "ma_bomb_damage", --The name of the convar you wish to use. Make sure it's unique!
                    default = 100, --The default value used when the convars(Console variables) are created
                    desc = "The bomb's damage.", --Tooltip displayed on hover
                    panel = {type = "DNumberWang", max = 100},
                    --The type of panel used for displaying this convar. All types of DPanels are supported like "DNumberWang", "DNumSlider", "DCheckBox", "DButton" and more. This link provides the supported types: https://wiki.facepunch.com/gmod/VGUI_Element_List
                    --More will come in the future so check the changelog if you're looking for more
                    tags = {"hurt", "injure"}, --When searching controls, this control will be displayed if part of the search term resembles one of these tags
                    
                },
                ["Explode bomb!"] = {
                    panel = {type = "DButton", DoClick = function(self)
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
}

--Values will be autocompleted (like type will be autofilled to DNumberWang) or left out (like desc) if blank.