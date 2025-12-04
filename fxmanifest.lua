fx_version 'cerulean'
game 'gta5'

author 'Pavel775 Network'
description 'Script para gestionar bandas ilegales en FiveM (ESX/QBCore) con NPCs y niveles By Pavel775 Network'
version '1.1.0'

ui_page 'html/ui.html'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua'
}

files {
    'html/ui.html',
    'html/style.css',
    'html/script.js'
}
dependencies {
    'es_extended', -- Para ESX
    'qb-core'      -- Para QBCore
}
-- Comando para abrir el menú
RegisterCommand('pavelilegal', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openMenu' })
end)