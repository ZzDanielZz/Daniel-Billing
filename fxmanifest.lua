fx_version "adamant"
game "gta5"
lua54 "yes"

author "Daniel"
description "Daniel Clean UI Billing System For Business"
version "1.0.0"
ui_page 'Build/main.html'

client_scripts {
    "Client/*.lua",
}

server_scripts {
    "Server/*.lua",
    "Shared/Discord.lua"
}

shared_scripts {
    "Shared/Config.lua",
    --'@ox_lib/init.lua', -- Uncomment If You Use OX Notify System
}

files {
    -- UI
    'Build/main.html',
    'Build/script.js',
    'Build/style.css',
}