local QBCore = exports["qb-core"]:GetCoreObject()
ESX = nil
lib.locale()

------------------------------
---
---███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
---██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
---█████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
---██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
---███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
---╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
---
------------------------------
---
if Config.Framework == "qb" then
    if Config.Debug then print("[DEBUG] Framework: " .. Config.Framework) end
    QBCore.Functions.CreateCallback("blackcontact:getCard", function(source)
        if Config.Inventory == "ox" then
            if Config.Debug == true then print("[DEBUG] OX Inventory found.") end
            exports.ox_inventory:AddItem(source, "number_card", 1)
        elseif Config.Inventory == "qb" then
            if Config.Debug == true then print("[DEBUG] QB Inventory found.") end
            exports['qb-inventory']:AddItem(source, "number_card", 1)
        end
        if Config.Debug == true then print("[DEBUG] Item added.") end
    end)
elseif Config.Framework == "ox" then
    if Config.Debug then print("[DEBUG] Framework: " .. Config.Framework) end
    lib.callback.register("blackcontact:getCard", function(source)
        if Config.Inventory == "ox" then
            if Config.Debug == true then print("[DEBUG] OX Inventory found.") end
            exports.ox_inventory:AddItem(source, "number_card", 1)
        elseif Config.Inventory == "qb" then
            if Config.Debug == true then print("[DEBUG] QB Inventory found.") end
            exports['qb-inventory']:AddItem(source, "number_card", 1)
        end
        if Config.Debug == true then print("[DEBUG] Item added.") end
    end)
elseif Config.Framework == "ESX" then
    if Config.Debug then print("[DEBUG] Framework: " .. Config.Framework) end
    ESX.RegisterServerCallback("blackcontact:getCard", function(source)
        if Config.Inventory == "ox" then
            if Config.Debug == true then print("[DEBUG] OX Inventory found.") end
            exports.ox_inventory:AddItem(source, "number_card", 1)
        elseif Config.Inventory == "qb" then
            if Config.Debug == true then print("[DEBUG] QB Inventory found.") end
            exports['qb-inventory']:AddItem(source, "number_card", 1)
        end
        if Config.Debug == true then print("[DEBUG] Item added.") end
    end)
end

if Config.Framework == "qb" then
    if Config.Debug then print("[DEBUG] Framework: " .. Config.Framework) end
    QBCore.Functions.CreateCallback("blackcontact:pickupPackage", function(source, cb, item)
        local totalPrice = (tonumber(item.value)) * (tonumber(item.count))
        if Config.Inventory == "ox" then
            local money = exports.ox_inventory:GetItemCount(source, "money")
            if money >= totalPrice then
                exports.ox_inventory:RemoveItem(source, "money", totalPrice)
                exports.ox_inventory:AddItem(source, item.name, item.count)
                cb(true)
            else
                cb(false)
            end
        elseif Config.Inventory == "qb" then
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then return end
            Player.Functions.RemoveMoney('cash', totalPrice)
            exports['qb-inventory']:AddItem(source, item.name, item.count)
        end
    end)
elseif Config.Framework == "ox" then
    if Config.Debug then print("[DEBUG] Framework: " .. Config.Framework) end
    lib.callback.register("blackcontact:pickupPackage", function(source, cb, item)
        local totalPrice = (tonumber(item.value)) * (tonumber(item.count))
        if Config.Inventory == "ox" then
            local money = exports.ox_inventory:GetItemCount(source, "money")
            if money >= totalPrice then
                exports.ox_inventory:RemoveItem(source, "money", totalPrice)
                exports.ox_inventory:AddItem(source, item.name, item.count)
                cb(true)
            else
                cb(false)
            end
        elseif Config.Inventory == "qb" then
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then return end
            Player.Functions.RemoveMoney('cash', totalPrice)
            exports['qb-inventory']:AddItem(source, item.name, item.count)
        end
    end)
elseif Config.Framework == "ESX" then
    if Config.Debug then print("[DEBUG] Framework: " .. Config.Framework) end
    ESX.RegisterServerCallback("blackcontact:pickupPackage", function(source, cb, item)
        local totalPrice = (tonumber(item.value)) * (tonumber(item.count))
        if Config.Inventory == "ox" then
            local money = exports.ox_inventory:GetItemCount(source, "money")
            if money >= totalPrice then
                exports.ox_inventory:RemoveItem(source, "money", totalPrice)
                exports.ox_inventory:AddItem(source, item.name, item.count)
                cb(true)
            else
                cb(false)
            end
        elseif Config.Inventory == "qb" then
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then return end
            Player.Functions.RemoveMoney('cash', totalPrice)
            exports['qb-inventory']:AddItem(source, item.name, item.count)
        end
    end)
end
