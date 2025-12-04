-- Comando para abrir el menú de bandas
RegisterCommand('pavelilegal', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openMenu' })
end)

-- Evento para recibir notificaciones
RegisterNetEvent('pavel_ilegal:notify')
AddEventHandler('pavel_ilegal:notify', function(message)
    -- Mostrar notificación en pantalla
    ESX.ShowNotification(message) -- Si usas ESX
end)
