local cooldowns = {}

-- Función para detectar el framework
local function DetectFramework()
    if GetResourceState('es_extended') == 'started' then
        Config.Framework = 'esx'
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        Config.Framework = 'qbcore'
        QBCore = exports['qb-core']:GetCoreObject()
    else
        print("^1[ERROR]^0 No se detectó ESX ni QBCore. El script no funcionará correctamente.")
    end
end

-- Función para notificaciones
local function Notify(src, message)
    if Config.Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', src, message)
    elseif Config.Framework == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', src, message)
    end
end

-- Función para obtener el jugador
local function GetPlayer(src)
    if Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(src)
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetPlayer(src)
    end
end

-- Función para obtener el nivel de la banda
local function GetBandLevel(xp)
    for i = #Config.BandLevels, 1, -1 do
        if xp >= Config.BandLevels[i].xpRequired then
            return Config.BandLevels[i]
        end
    end
    return Config.BandLevels[1]
end

-- Función para obtener el identificador del jugador
local function GetIdentifier(player)
    if Config.Framework == 'esx' then
        return player.identifier
    elseif Config.Framework == 'qbcore' then
        return player.PlayerData.citizenid
    end
end

-- Función para obtener el ID de una banda por nombre
local function GetBandId(bandName, cb)
    MySQL.query('SELECT id FROM pavel_bands WHERE name = ?', { bandName }, function(result)
        if result[1] then
            cb(result[1].id)
        else
            cb(nil)
        end
    end)
end

-- Función para crear una banda en la base de datos
RegisterNetEvent('pavel_ilegal:createBand')
AddEventHandler('pavel_ilegal:createBand', function(bandName, leader)
    local src = source
    local player = GetPlayer(src)

    if player then
        local isAdmin = false
        if Config.Framework == 'esx' then
            isAdmin = Config.AdminGroups[player.getGroup()]
        elseif Config.Framework == 'qbcore' then
            isAdmin = Config.AdminGroups[player.PlayerData.job.name]
        end

        if isAdmin then
            MySQL.query('SELECT 1 FROM pavel_bands WHERE name = ?', { bandName }, function(result)
                if not result[1] then
                    MySQL.insert('INSERT INTO pavel_bands (name, leader, xp, money) VALUES (?, ?, 0, 0)', { bandName, leader }, function()
                        Notify(src, "Banda creada: " .. bandName)
                    end)
                else
                    Notify(src, "La banda ya existe.")
                end
            end)
        else
            Notify(src, "No tienes permisos.")
        end
    end
end)

-- Función para añadir un miembro a la banda
RegisterNetEvent('pavel_ilegal:addMember')
AddEventHandler('pavel_ilegal:addMember', function(bandName, memberIdentifier)
    local src = source
    GetBandId(bandName, function(bandId)
        if bandId then
            MySQL.query('SELECT COUNT(*) as count FROM pavel_band_members WHERE band_id = ?', { bandId }, function(result)
                local currentMembers = result[1].count
                MySQL.query('SELECT xp FROM pavel_bands WHERE id = ?', { bandId }, function(xpResult)
                    local xp = xpResult[1].xp
                    local currentLevel = GetBandLevel(xp)

                    if currentMembers < currentLevel.maxMembers then
                        MySQL.insert('INSERT INTO pavel_band_members (band_id, identifier) VALUES (?, ?)', { bandId, memberIdentifier }, function()
                            Notify(src, "Miembro añadido a " .. bandName)
                        end)
                    else
                        Notify(src, "La banda ha alcanzado el límite de miembros para su nivel.")
                    end
                end)
            end)
        else
            Notify(src, "La banda no existe.")
        end
    end)
end)

-- Función para iniciar una actividad ilegal
RegisterNetEvent('pavel_ilegal:startActivity')
AddEventHandler('pavel_ilegal:startActivity', function(activityType, bandName)
    local src = source
    local player = GetPlayer(src)

    if player then
        GetBandId(bandName, function(bandId)
            if bandId then
                local identifier = GetIdentifier(player)
                MySQL.query('SELECT 1 FROM pavel_band_members WHERE band_id = ? AND identifier = ?', { bandId, identifier }, function(memberResult)
                    MySQL.query('SELECT leader, xp, money FROM pavel_bands WHERE id = ?', { bandId }, function(bandResult)
                        local band = bandResult[1]
                        local isMember = (memberResult[1] or band.leader == identifier)

                        if isMember then
                            if not cooldowns[bandName] or not cooldowns[bandName][activityType] or cooldowns[bandName][activityType] < os.time() then
                                local cops = 0
                                for _, p in ipairs(GetPlayers()) do
                                    local targetPlayer = GetPlayer(tonumber(p))
                                    if targetPlayer then
                                        if Config.Framework == 'esx' and targetPlayer.job.name == 'police' then
                                            cops = cops + 1
                                        elseif Config.Framework == 'qbcore' and targetPlayer.PlayerData.job.name == 'police' then
                                            cops = cops + 1
                                        end
                                    end
                                end

                                if cops >= Config.Activities[activityType].minPolice then
                                    local activity = Config.Activities[activityType]
                                    local currentLevel = GetBandLevel(band.xp)
                                    local reward = math.floor(math.random(activity.reward.min, activity.reward.max) * currentLevel.rewardBonus)
                                    local xp = activity.xp

                                    MySQL.update('UPDATE pavel_bands SET money = money + ?, xp = xp + ? WHERE id = ?', { reward, xp, bandId })
                                    cooldowns[bandName] = cooldowns[bandName] or {}
                                    cooldowns[bandName][activityType] = os.time() + activity.cooldown

                                    Notify(src, string.format("Actividad completada. Recompensa: $%s | XP: %s", reward, xp))
                                else
                                    Notify(src, "No hay suficientes policías en servicio.")
                                end
                            else
                                Notify(src, "La actividad está en cooldown.")
                            end
                        else
                            Notify(src, "No eres miembro de esta banda.")
                        end
                    end)
                end)
            else
                Notify(src, "La banda no existe.")
            end
        end)
    end
end)

-- Función para depositar dinero en la caja fuerte
RegisterNetEvent('pavel_ilegal:depositMoney')
AddEventHandler('pavel_ilegal:depositMoney', function(bandName, amount)
    local src = source
    local player = GetPlayer(src)

    if player then
        GetBandId(bandName, function(bandId)
            if bandId then
                local identifier = GetIdentifier(player)
                MySQL.query('SELECT 1 FROM pavel_band_members WHERE band_id = ? AND identifier = ?', { bandId, identifier }, function(memberResult)
                    MySQL.query('SELECT leader, money FROM pavel_bands WHERE id = ?', { bandId }, function(bandResult)
                        local band = bandResult[1]
                        local isMember = (memberResult[1] or band.leader == identifier)

                        if isMember then
                            if player.getMoney() >= amount then
                                player.removeMoney(amount)
                                MySQL.update('UPDATE pavel_bands SET money = money + ? WHERE id = ?', { amount, bandId })
                                Notify(src, "Depositaste $" .. amount .. " en la caja fuerte.")
                            else
                                Notify(src, "No tienes suficiente dinero.")
                            end
                        else
                            Notify(src, "No eres miembro de esta banda.")
                        end
                    end)
                end)
            else
                Notify(src, "La banda no existe.")
            end
        end)
    end
end)

-- Función para retirar dinero de la caja fuerte
RegisterNetEvent('pavel_ilegal:withdrawMoney')
AddEventHandler('pavel_ilegal:withdrawMoney', function(bandName, amount)
    local src = source
    local player = GetPlayer(src)

    if player then
        GetBandId(bandName, function(bandId)
            if bandId then
                local identifier = GetIdentifier(player)
                MySQL.query('SELECT 1 FROM pavel_band_members WHERE band_id = ? AND identifier = ?', { bandId, identifier }, function(memberResult)
                    MySQL.query('SELECT leader, money FROM pavel_bands WHERE id = ?', { bandId }, function(bandResult)
                        local band = bandResult[1]
                        local isMember = (memberResult[1] or band.leader == identifier)

                        if isMember then
                            if band.money >= amount then
                                MySQL.update('UPDATE pavel_bands SET money = money - ? WHERE id = ?', { amount, bandId })
                                player.addMoney(amount)
                                Notify(src, "Retiraste $" .. amount .. " de la caja fuerte.")
                            else
                                Notify(src, "La banda no tiene suficiente dinero.")
                            end
                        else
                            Notify(src, "No eres miembro de esta banda.")
                        end
                    end)
                end)
            else
                Notify(src, "La banda no existe.")
            end
        end)
    end
end)

-- Función para guardar objetos en el armario
RegisterNetEvent('pavel_ilegal:saveOutfit')
AddEventHandler('pavel_ilegal:saveOutfit', function(bandName, outfitName, outfitData)
    local src = source
    local player = GetPlayer(src)

    if player then
        GetBandId(bandName, function(bandId)
            if bandId then
                local identifier = GetIdentifier(player)
                MySQL.query('SELECT 1 FROM pavel_band_members WHERE band_id = ? AND identifier = ?', { bandId, identifier }, function(memberResult)
                    MySQL.query('SELECT leader FROM pavel_bands WHERE id = ?', { bandId }, function(bandResult)
                        local band = bandResult[1]
                        local isMember = (memberResult[1] or band.leader == identifier)

                        if isMember then
                            MySQL.query('SELECT items FROM pavel_wardrobe WHERE band_id = ? AND identifier = ?', { bandId, identifier }, function(result)
                                local items = {}
                                if result[1] then
                                    items = json.decode(result[1].items) or {}
                                end
                                items[outfitName] = outfitData
                                MySQL.update('INSERT INTO pavel_wardrobe (band_id, identifier, items) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE items = ?',
                                    { bandId, identifier, json.encode(items), json.encode(items) })
                                Notify(src, "Outfit guardado: " .. outfitName)
                            end)
                        else
                            Notify(src, "No eres miembro de esta banda.")
                        end
                    end)
                end)
            else
                Notify(src, "La banda no existe.")
            end
        end)
    end
end)

-- Función para cargar objetos del armario
RegisterNetEvent('pavel_ilegal:loadOutfit')
AddEventHandler('pavel_ilegal:loadOutfit', function(bandName, outfitName)
    local src = source
    local player = GetPlayer(src)

    if player then
        GetBandId(bandName, function(bandId)
            if bandId then
                local identifier = GetIdentifier(player)
                MySQL.query('SELECT 1 FROM pavel_band_members WHERE band_id = ? AND identifier = ?', { bandId, identifier }, function(memberResult)
                    MySQL.query('SELECT leader FROM pavel_bands WHERE id = ?', { bandId }, function(bandResult)
                        local band = bandResult[1]
                        local isMember = (memberResult[1] or band.leader == identifier)

                        if isMember then
                            MySQL.query('SELECT items FROM pavel_wardrobe WHERE band_id = ? AND identifier = ?', { bandId, identifier }, function(result)
                                if result[1] and result[1].items then
                                    local items = json.decode(result[1].items)
                                    if items[outfitName] then
                                        TriggerClientEvent('pavel_ilegal:applyOutfit', src, items[outfitName])
                                    else
                                        Notify(src, "El outfit no existe.")
                                    end
                                else
                                    Notify(src, "No tienes outfits guardados.")
                                end
                            end)
                        else
                            Notify(src, "No eres miembro de esta banda.")
                        end
                    end)
                end)
            else
                Notify(src, "La banda no existe.")
            end
        end)
    end
end)

-- Función para guardar un vehículo en el garaje
RegisterNetEvent('pavel_ilegal:saveVehicle')
AddEventHandler('pavel_ilegal:saveVehicle', function(bandName, vehicleProps)
    local src = source
    local player = GetPlayer(src)

    if player then
        GetBandId(bandName, function(bandId)
            if bandId then
                local identifier = GetIdentifier(player)
                MySQL.query('SELECT 1 FROM pavel_band_members WHERE band_id = ? AND identifier = ?', { bandId, identifier }, function(memberResult)
                    MySQL.query('SELECT leader FROM pavel_bands WHERE id = ?', { bandId }, function(bandResult)
                        local band = bandResult[1]
                        local isMember = (memberResult[1] or band.leader == identifier)

                        if isMember then
                            MySQL.query('SELECT 1 FROM pavel_garage WHERE plate = ?', { vehicleProps.plate }, function(result)
                                if not result[1] then
                                    MySQL.insert('INSERT INTO pavel_garage (band_id, plate, vehicle) VALUES (?, ?, ?)',
                                        { bandId, vehicleProps.plate, json.encode(vehicleProps) })
                                    Notify(src, "Vehículo guardado: " .. vehicleProps.plate)
                                else
                                    Notify(src, "El vehículo ya está guardado.")
                                end
                            end)
                        else
                            Notify(src, "No eres miembro de esta banda.")
                        end
                    end)
                end)
            else
                Notify(src, "La banda no existe.")
            end
        end)
    end
end)

-- Función para sacar un vehículo del garaje
RegisterNetEvent('pavel_ilegal:spawnVehicle')
AddEventHandler('pavel_ilegal:spawnVehicle', function(bandName, plate)
    local src = source
    local player = GetPlayer(src)

    if player then
        GetBandId(bandName, function(bandId)
            if bandId then
                local identifier = GetIdentifier(player)
                MySQL.query('SELECT 1 FROM pavel_band_members WHERE band_id = ? AND identifier = ?', { bandId, identifier }, function(memberResult)
                    MySQL.query('SELECT leader FROM pavel_bands WHERE id = ?', { bandId }, function(bandResult)
                        local band = bandResult[1]
                        local isMember = (memberResult[1] or band.leader == identifier)

                        if isMember then
                            MySQL.query('SELECT vehicle FROM pavel_garage WHERE band_id = ? AND plate = ?', { bandId, plate }, function(result)
                                if result[1] then
                                    TriggerClientEvent('pavel_ilegal:spawnVehicleClient', src, json.decode(result[1].vehicle))
                                else
                                    Notify(src, "El vehículo no existe en el garaje.")
                                end
                            end)
                        else
                            Notify(src, "No eres miembro de esta banda.")
                        end
                    end)
                end)
            else
                Notify(src, "La banda no existe.")
            end
        end)
    end
end)

-- Detectar framework al iniciar el script
DetectFramework()