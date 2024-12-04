local usingESX = false
local ESX = nil
local DONTTOUCH = nil
local legitplayers = {}
local currentplayerID = nil

DiscordLog = function(eventName, eventType, message)
    local webhookURL = nil
    local color = 3447003
    local logName = "Server Log"
    for _, config in pairs(Discord) do
        if config.id == eventName then
            webhookURL = config[eventType]
            color = config.color
            logName = config.logName
            break
        end
    end

    if webhookURL then
        local content = {
            username = "Daniel Billing System",
            embeds = {{
                title = logName,
                description = message,
                color = color,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        }

        local jsonData = json.encode(content)

        PerformHttpRequest(webhookURL, function(err, text, headers)
            if err == 204 or err == 200 then
                Debug("Discord Log sent successfully!", "DATA")
            else
                Debug("Failed to send Discord Log! Error: " .. err, "ERROR")
            end
        end, 'POST', jsonData, { ['Content-Type'] = 'application/json' })
    else
        Debug("Invalid eventName: " .. eventName, "ERROR")
    end
end

ServerNotify = function(playerId, message, type)
    if Config.Notify == "ox_lib" then
        TriggerClientEvent("ox_lib:notify", playerId, {
            title = type or "Info",
            description = message,
            icon = "fa-solid fa-info-circle",
            type = type or "info"
        })
    elseif Config.Notify == "qb-core" then
        TriggerClientEvent("QBCore:Notify", playerId, message, type)
    elseif Config.Notify == "esx" then
        TriggerClientEvent("esx:showNotification", playerId, message)
    else
        Debug("Unknown Notify System in config.", "INFO")
    end
end

Debug = function(message, type)
    if Config.Debug then
        local debugType = type or "INFO"
        print(string.format("^2[DEBUG - %s]: ^0%s", debugType, message))
    end
end

RegisterServerEvent("Daniel-Billing:checkForBan")
AddEventHandler("Daniel-Billing:checkForBan", function(source)
    local src = source
    currentplayerID = source
    table.insert(legitplayers, src)
    Debug("Added Data " .. src, "SUCCESS")
end)

RegisterServerEvent("Daniel-Billing:ServerSideOpen")
AddEventHandler("Daniel-Billing:ServerSideOpen", function(playerId, amount, BillerId)
    local BillerId2 = tonumber(BillerId)
    local playerId = tonumber(playerId)

    if Config.AntiExploit then
        if currentplayerID == nil then
            Debug("Suspicious: currentplayerID is nil, possible exploit attempt", "CHEAT DETECTION")
            DropPlayer(source, "Suspicious Activity Detected")
            return
        end
    
        local isLegit = false
        for i, v in ipairs(legitplayers) do
            if v == currentplayerID then
                isLegit = true
                break
            end
        end
    
        if not isLegit then
            Debug("Suspicious: Player not in legitplayers list, possible exploit attempt", "CHEAT DETECTION")
            DropPlayer(currentplayerID, "Suspicious Activity Detected")
        else
            Debug("Player passed anti-exploit check", "INFO")
        end 

        --Debug(string.format("Method: %s | Source: %d | Event Received", method, source), "EVENT")
        Debug(string.format("Data - Player ID: %d, Amount: %d, Biller ID: %s", playerId, amount, BillerId2), "DATA")

        if playerId == nil then
            print(tonumber(playerId))
            Debug("Suspicious: Invalid Player ID received", "CHEAT DETECTION")
            DropPlayer(source, "Suspicious Activity")
        end
        if amount <= 0 then
            Debug("Suspicious: Invalid Amount received (<= 0)", "CHEAT DETECTION")
            DropPlayer(source, "Suspicious Activity")
        end
        if not BillerId2 or BillerId2 == "" or BillerId2 == nil or BillerId2 == playerId then
            Debug("Suspicious: Invalid Biller ID received or Tried To Bill Himself", "CHEAT DETECTION")
            print(tonumber(BillerId2))
            DropPlayer(source, "Suspicious Activity")
        end
    end

    local payer = QBCore.Functions.GetPlayer(playerId)
    local biller = QBCore.Functions.GetPlayer(BillerId2)

    if payer and biller then
        Debug(string.format("Payer Source: %d, Biller Source: %d", payer.PlayerData.source, biller.PlayerData.source), "SOURCE CHECK")

        TriggerClientEvent('Daniel-Billing:openPaymentContainer', payer.PlayerData.source, playerId, amount, BillerId2)

        for i, v in ipairs(legitplayers) do
            if v == currentplayerID then
                table.remove(legitplayers, i)
                Debug("Removed player from Legit Players table: " .. currentplayerID, "INFO")
                break
            end
        end
        
        DiscordLog(1, "invoices", "**A new invoice has been created.** \n **__Biller Id:__ " .. BillerId2 .. "**\n **__Billed Player ID:__ " .. playerId .. "**\n **__Amount:__ " .. amount .. "**")
    else
        Debug("Invalid payer or biller data received", "ERROR")
    end
end)

if Config.DevMode then
    RegisterCommand('openUIForPlayer', function(source, args, rawCommand)
        local targetPlayerId = tonumber(args[1])
        local amount = tonumber(args[2])
        local src = source

        if targetPlayerId and amount then
            DiscordLog(2, "DevCommand", "**Command Has Been Used !** \n **__PlayerID:__ " .. targetPlayerId .. "** \n **__Amount:__ " .. amount .. "**")
            Debug("Used Command With Args | Player ID, " .. targetPlayerId .. " Amount " .. amount, "INFO")

            TriggerClientEvent('Daniel-Billing:openPaymentContainer', targetPlayerId, targetPlayerId, amount, src)
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Server', 'Invalid player ID or amount.'}
            })
        end
    end, false)
end

Citizen.CreateThread(function()
    if Config.FrameworkType == 'ESX' then
        if Config.esxLegacy then
            ESX = exports["es_extended"]:getSharedObject()
            Debug("Framework initialized: New ESX", "INIT")
        else
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
            Debug("Framework initialized: Legacy ESX", "INIT")
        end
        usingESX = true
    elseif Config.FrameworkType == 'QB' then
        QBCore = exports[Config.Framework]:GetCoreObject()
        Debug("Framework initialized: QB-Core", "INIT")
        usingESX = false
    end
end)

removeCash = function(playerId, amount)
    playerId.Functions.RemoveMoney("cash", amount)
    return true
end

removeBankBalance = function(playerId, amount)
    playerId.Functions.RemoveMoney("bank", amount)
    return true
end

RegisterServerEvent('Daniel-Billing:server:processPayment')
AddEventHandler('Daniel-Billing:server:processPayment', function(playerId, method, amount, BillerId)
    Debug("Server Event: processPayment received", "EVENT")
    Debug(string.format("Processing payment - Payer: %d, Biller: %d, Method: %s, Amount: %d", playerId, BillerId, method, amount), "DATA")

    local payer = QBCore.Functions.GetPlayer(tonumber(playerId))
    local biller = QBCore.Functions.GetPlayer(tonumber(BillerId))

    if payer and biller then
        if method == "cash" and payer.Functions.RemoveMoney("cash", amount) then
            biller.Functions.AddMoney("cash", amount)
            DiscordLog(3, "InvoicesPayments", "**Invoice Has Been Paid.** \n **__Payment Method:__ " .. method .. "**\n **__Payer ID:__ " .. playerId .. "** \n **__Amount:__ " .. amount .. "** \n **__Biller ID:__ " .. BillerId .. "**")
            ServerNotify(payer.PlayerData.source, 'Payment successful via Cash!', 'success')
            ServerNotify(biller.PlayerData.source, 'Invoice paid in Cash!', 'success')
        elseif method == "bank" and payer.Functions.RemoveMoney("bank", amount) then
            biller.Functions.AddMoney("bank", amount)
            ServerNotify(payer.PlayerData.source, 'Payment successful via Bank!', 'success')
            ServerNotify(biller.PlayerData.source, 'Invoice paid via Bank!', 'success')
        else
            ServerNotify(payer.PlayerData.source, 'Insufficient funds!', 'error')
            Debug("Payment failed due to insufficient funds", "ERROR")
        end
    else
        Debug("Invalid payer or biller during payment processing", "ERROR")
    end
end)