-- Comando para abrir el menú
RegisterCommand('pavelilegal', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openMenu' })
end)

-- Evento para cerrar el menú
RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Evento para crear una banda
RegisterNUICallback('createBand', function(data, cb)
    TriggerServerEvent('pavel_ilegal:createBand', data.bandName, data.leader)
    cb('ok')
end)

-- Evento para añadir miembros
RegisterNUICallback('addMember', function(data, cb)
    TriggerServerEvent('pavel_ilegal:addMember', data.bandName, data.member)
    cb('ok')
end)

-- Evento para eliminar bandas
RegisterNUICallback('deleteBand', function(data, cb)
    TriggerServerEvent('pavel_ilegal:deleteBand', data.bandName)
    cb('ok')
end)