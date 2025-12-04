Config = {}

-- Permisos para crear bandas (puedes usar ACE o roles de ESX/QBCore)
Config.AdminGroups = {
    ['admin'] = true,
    ['superadmin'] = true
}

-- Mensajes de notificación
Config.Notify = function(src, message)
    TriggerClientEvent('esx:showNotification', src, message) -- Cambia a tu sistema de notificaciones
end