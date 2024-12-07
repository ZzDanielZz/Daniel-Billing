local display = false
local usingESX = false
ESX = nil

Notify = function(message, type)
    if Config.Notify == "ox_lib" then
        exports.ox_lib:notify({
            title = type or "Info",
            description = message,
            icon = "fa-solid fa-info-circle",
            type = type or "info"
        })
    elseif Config.Notify == "qb-core" then
        if Core and Core.Functions.Notify then
            Core.Functions.Notify(message, type)
        else
            Debug("QB-Core Notify not found.", "INFO")
        end
    elseif Config.Notify == "esx" then
        if usingESX and ESX.ShowNotification then
            ESX.ShowNotification(message)
        else
            Debug("ESX Notify not found.", "INFO")
        end
    else
        Debug("Unknown Notify System in config.", "INFO")
    end
end    

Debug = function(message, type)
    if Config.Debug then
        local debugType = type or "INFO"
        print(string.format("^5[DEBUG - %s]: ^0%s", debugType, message))
    end
end

RegisterNUICallback('openPaymentContainer', function(data, cb)
    Debug("Received NUI callback: openPaymentContainer", "INFO")
    Debug(string.format("Data - Player ID: %s, Amount: %s", data.playerId, data.amount), "DATA")

    local playerId = tonumber(data.playerId)
    local amount = tonumber(data.amount)
    local BillerId = GetPlayerServerId(PlayerId())

    if playerId and amount then
        if playerId ~= GetPlayerServerId(PlayerId()) then

            local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
            if targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                local billerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(billerCoords - targetCoords)

                if distance <= 10.0 then
                    local src = GetPlayerServerId(PlayerId())
                    TriggerServerEvent("Daniel-Billing:checkForBan", src)
                    TriggerServerEvent("Daniel-Billing:ServerSideOpen", playerId, amount, BillerId)
                    cb("ok")
                else
                    Notify("Player is too far away to bill!", "error")
                    Debug(string.format("Player is too far away: %.2f units", distance), "ERROR")
                    cb("error")
                end
            else
                Notify("Unable to locate the player!", "error")
                Debug("Target player ped could not be found", "ERROR")
                cb("error")
            end
        else
            Notify("You Can't Bill Yourself!", "error")
            Debug("Player cannot bill themselves", "ERROR")
            cb("error")
        end
    else
        Notify("Missing Information!", "error")
        Debug("Invalid data received in openPaymentContainer callback", "ERROR")
        cb("error")
    end
end)

RegisterNetEvent('Daniel-Billing:openPaymentContainer')
AddEventHandler('Daniel-Billing:openPaymentContainer', function(playerId, amount, BillerId)
    if Config.AntiExploit then
        Debug(string.format("Net Event Triggered - Player ID: %d, Amount: %d, Biller ID: %s", playerId, amount, BillerId), "INFO")
    end

    playerId = tonumber(playerId)
    amount = tonumber(amount)

    if playerId and amount then
        Debug("Player Tried To Give Invoice To Himself !", "ERROR")
        if playerId ~= PlayerId() then
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = "openPaymentContainer",
                playerId = playerId,
                amount = amount,
                BillerId = BillerId
            })
        else
            Debug("Player cannot bill themselves", "ERROR")
        end
    else
        Debug("Invalid playerId or amount received in openPaymentContainer", "ERROR")
    end
end)

Citizen.CreateThread(function()
    if Config.FrameworkType == 'ESX' then
        if Config.esxLegacy then
            ESX = exports["es_extended"]:getSharedObject()
        else
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
            while ESX.GetPlayerData().job == nil do
                Citizen.Wait(10)
            end
        end
        usingESX = true
        Debug("Framework initialized: ESX", "INIT")
    elseif Config.FrameworkType == 'QB' then
        Core = exports[Config.Framework]:GetCoreObject()
        usingESX = false
        Debug("Framework initialized: QB-Core", "INIT")
    end
end)

setDisplay = function(bool)
    if bool then
        Debug("Enabling UI display", "UI")
        SetTimecycleModifier("bloom")
        SetTimecycleModifierStrength(0)

        Citizen.CreateThread(function()
            local startTime = GetGameTimer()
            local duration = 500
            while GetGameTimer() - startTime < duration do
                local progress = (GetGameTimer() - startTime) / duration
                SetTimecycleModifierStrength(progress * 1.5)
                Citizen.Wait(0)
            end
        end)

        display = bool
        SetNuiFocus(bool, bool)
        SendNUIMessage({
            type = "toggle",
            status = bool
        })
    else
        Debug("Disabling UI display", "UI")
        ClearTimecycleModifier()
        SetTimecycleModifierStrength(0)

        display = bool
        SetNuiFocus(bool, bool)
        SendNUIMessage({
            type = "toggle",
            status = bool
        })
    end
end

if Config.DevMode then
    RegisterCommand("BillingTest", function()
        setDisplay(not display)
    end)
end

RegisterNUICallback("closeUI", function(data, cb)
    Debug("NUI callback: closeUI received", "UI")
    setDisplay(false)
    cb("ok")
end)

RegisterNUICallback('PayBill', function(data, cb)
    Debug("NUI callback: PayBill received", "UI")
    if data and data.playerId and data.amount and data.method then
        local playerId = tonumber(data.playerId)
        local amount = tonumber(data.amount)
        local method = data.method
        local BillerId = data.BillerId

        Debug(string.format("Processing payment - PlayerID: %d, Amount: %d, Method: %s, BillerID: %s", playerId, amount, method, BillerId), "DATA")
        TriggerServerEvent('Daniel-Billing:server:processPayment', playerId, method, amount, BillerId)
        cb({ message = "Payment processed successfully!" })
    else
        Debug("Invalid data received in PayBill callback", "ERROR")
        cb({ message = "Error: Invalid data received!" })
    end
end)

DrawText3D = function(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local scale = 0.35

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

initializeTargets = function()
    for business, data in pairs(Config.Business) do
        local coords = data.coords
        local jobs = data.jobs

        if Config.TargetSystem == "qb-target" then
            exports["qb-target"]:AddBoxZone(business, coords, 1.0, 1.0, {
                name = business,
                heading = 0,
                debugPoly = false,
                minZ = coords.z - 1,
                maxZ = coords.z + 1,
            }, {
                options = {
                    {
                        type = "client",
                        event = "business:interact",
                        icon = "fa-solid fa-briefcase",
                        label = data.interaction,
                        job = jobs
                    }
                },
                distance = 2.0
            })
        elseif Config.TargetSystem == "ox_target" then
            exports["ox_target"]:addBoxZone({
                coords = coords,
                size = vec3(1.0, 1.0, 1.0),
                rotation = 0,
                debug = false,
                options = {
                    {
                        name = business,
                        event = "business:interact",
                        icon = "fa-solid fa-briefcase",
                        label = data.interaction,
                        groups = jobs
                    }
                }
            })
        elseif Config.TargetSystem == "drawtext" then
            Citizen.CreateThread(function()
                while true do
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local dist = #(playerCoords - coords)

                    if dist < data.Distance then
                        local hasJob = false
                        if usingESX then
                            for _, job in pairs(jobs) do
                                if ESX.GetPlayerData().job.name == job then
                                    hasJob = true
                                    break
                                end
                            end
                        elseif not usingESX then
                            for _, job in pairs(jobs) do
                                if Core.Functions.GetPlayerData().job.name == job then
                                    hasJob = true
                                    break
                                end
                            end
                        end

                        if hasJob then
                            DrawText3D(coords.x, coords.y, coords.z + 1.0, data.interaction)
                            if IsControlJustPressed(0, 38) then
                                TriggerEvent("business:interact")
                            end
                        end
                    end

                    Citizen.Wait(0)
                end
            end)
        end
    end
end

RegisterNetEvent("business:interact", function()
    setDisplay(not display)
end)

Citizen.CreateThread(initializeTargets)
