local bandNPCs = {}

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

-- Evento para iniciar una actividad
RegisterNUICallback('startActivity', function(data, cb)
    TriggerServerEvent('pavel_ilegal:startActivity', data.activityType, data.bandName)
    cb('ok')
end)

-- Evento para depositar dinero
RegisterNUICallback('depositMoney', function(data, cb)
    TriggerServerEvent('pavel_ilegal:depositMoney', data.bandName, data.amount)
    cb('ok')
end)

-- Evento para retirar dinero
RegisterNUICallback('withdrawMoney', function(data, cb)
    TriggerServerEvent('pavel_ilegal:withdrawMoney', data.bandName, data.amount)
    cb('ok')
end)

-- Evento para guardar outfit
RegisterNUICallback('saveOutfit', function(data, cb)
    local playerPed = PlayerPedId()
    local outfitData = {
        model = GetEntityModel(playerPed),
        components = {},
        props = {}
    }

    for i = 0, 11 do
        outfitData.components[i] = { drawable = GetPedDrawableVariation(playerPed, i), texture = GetPedTextureVariation(playerPed, i), palette = GetPedPaletteVariation(playerPed, i) }
    end

    for i = 0, 7 do
        outfitData.props[i] = { drawable = GetPedPropIndex(playerPed, i), texture = GetPedPropTextureIndex(playerPed, i) }
    end

    TriggerServerEvent('pavel_ilegal:saveOutfit', data.bandName, data.outfitName, outfitData)
    cb('ok')
end)

-- Evento para cargar outfit
RegisterNUICallback('loadOutfit', function(data, cb)
    TriggerServerEvent('pavel_ilegal:loadOutfit', data.bandName, data.outfitName)
    cb('ok')
end)

-- Evento para aplicar outfit
RegisterNetEvent('pavel_ilegal:applyOutfit')
AddEventHandler('pavel_ilegal:applyOutfit', function(outfitData)
    local playerPed = PlayerPedId()

    RequestModel(outfitData.model)
    while not HasModelLoaded(outfitData.model) do
        Wait(1)
    end
    SetPlayerModel(PlayerId(), outfitData.model)
    playerPed = PlayerPedId()

    for componentId, component in pairs(outfitData.components) do
        SetPedComponentVariation(playerPed, componentId, component.drawable, component.texture, component.palette)
    end

    for propId, prop in pairs(outfitData.props) do
        SetPedPropIndex(playerPed, propId, prop.drawable, prop.texture, true)
    end
end)

-- Evento para guardar vehículo
RegisterNUICallback('saveVehicle', function(data, cb)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and vehicle ~= 0 then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle) -- o QBCore.Functions.GetVehicleProperties(vehicle)
        TriggerServerEvent('pavel_ilegal:saveVehicle', data.bandName, vehicleProps)
    else
        Notify("No estás en un vehículo.")
    end
    cb('ok')
end)

-- Evento para spawnear vehículo
RegisterNetEvent('pavel_ilegal:spawnVehicleClient')
AddEventHandler('pavel_ilegal:spawnVehicleClient', function(vehicleProps)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    ESX.Game.SpawnVehicle(vehicleProps.model, playerCoords, 0.0, function(vehicle)
        ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    end)
end)

-- Función para crear NPCs
local function CreateNPCs()
    for _, npc in ipairs(Config.NPCPositions) do
        RequestModel(npc.model)
        while not HasModelLoaded(npc.model) do
            Wait(1)
        end

        local ped = CreatePed(4, GetHashKey(npc.model), npc.coords, npc.heading, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        table.insert(bandNPCs, {
            ped = ped,
            type = npc.type,
            coords = npc.coords
        })
    end
end

-- Función para interactuar con NPCs
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, npc in ipairs(bandNPCs) do
            local distance = #(playerCoords - npc.coords)
            if distance < 2.0 then
                DrawText3D(npc.coords.x, npc.coords.y, npc.coords.z + 1.0, "[E] Interactuar")

                if IsControlJustPressed(0, 38) then
                    OpenNPCMenu(npc.type)
                end
            end
        end
    end
end)

-- Función para abrir el menú del NPC
function OpenNPCMenu(type)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openNPCMenu',
        npcType = type
    })
end

-- Función para dibujar texto 3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Crear NPCs al iniciar el script
CreateThread(function()
    CreateNPCs()
end)