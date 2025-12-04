fx_version 'cerulean'
game 'gta5'

author 'Pavel775 Network'
description 'Script para gestionar bandas ilegales en FiveM (ESX/QBCore) con NPCs y niveles de banda.'
version '1.1.0'

ui_page 'html/ui.html'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- o '@mysql-async/lib/MySQL.lua' si usas ghmattimysql
    'config.lua',
    'server.lua'
}

files {
    'html/ui.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'oxmysql' -- o 'mysql-async'
}