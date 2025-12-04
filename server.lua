local bands = {}

-- Evento para crear una banda
RegisterNetEvent('pavel_ilegal:createBand')
AddEventHandler('pavel_ilegal:createBand', function(bandName, leader)
    local src = source
    local player = GetPlayerIdentifiers(src)[1]

    -- Verificar permisos (ejemplo con ESX)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and Config.AdminGroups[xPlayer.getGroup()] then
        if not bands[bandName] then
            bands[bandName] = {
                name = bandName,
                leader = leader,
                members = {},
                activities = {}
            }
            Config.Notify(src, "Banda creada: " .. bandName)
        else
            Config.Notify(src, "La banda ya existe.")
        end
    else
        Config.Notify(src, "No tienes permisos para crear bandas.")
    end
end)

-- Evento para añadir miembros
RegisterNetEvent('pavel_ilegal:addMember')
AddEventHandler('pavel_ilegal:addMember', function(bandName, member)
    local src = source
    if bands[bandName] then
        table.insert(bands[bandName].members, member)
        Config.Notify(src, "Miembro añadido a " .. bandName)
    else
        Config.Notify(src, "La banda no existe.")
    end
end)

-- Evento para eliminar bandas
RegisterNetEvent('pavel_ilegal:deleteBand')
AddEventHandler('pavel_ilegal:deleteBand', function(bandName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and Config.AdminGroups[xPlayer.getGroup()] then
        if bands[bandName] then
            bands[bandName] = nil
            Config.Notify(src, "Banda eliminada: " .. bandName)
        else
            Config.Notify(src, "La banda no existe.")
        end
    else
        Config.Notify(src, "No tienes permisos.")
    end
end)