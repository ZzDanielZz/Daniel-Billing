-- /* Configuration */
Config = {
    -- /* Framework Configuration */
    FrameworkType = "QB", -- QB / ESX
    esxLegacy = false, -- Change To True If You Use Old ESX

    -- /* Debugging Configuration */
    Debug = false,  -- Toggle Debugging On/Off
    DevMode = false, -- Enabling Send UI Command

    -- /* QBCore Configuration */
    Core = "QBCore", -- Change Only If You Use Custom QBCore Framework
    Framework = "qb-core", -- Change Only If You Use Custom QBCore Framework

    -- /* System Configuration */
    TargetSystem = "qb-target", -- Choose between "qb-target", "ox_target", or "drawtext"
    Notify = "qb-core", -- Notify System / ox_lib / qb-core / esx

    -- /* Exploit Configuration */
    AntiExploit = true, -- Enable Anti Exploit checks

    -- /* Places Configuration */
    Business = {
        ["bank"] = {
            coords = vector3(-1024.184, -2733.377, 13.757),
            jobs = {"banker"},
            interaction = "[E] - To Access Bank Billing",  -- Interaction label
            UseBossMenu = false,
            Distance = 2, -- Change Only If You Use DrawText
        },
        ["store"] = {
            coords = vector3(374.0, -833.0, 29.0),
            jobs = {"shopkeeper"},
            interaction = "access_store",  -- Interaction label
            UseBossMenu = false,
            Distance = 2, -- Change Only If You Use DrawText
        }
    }
}
