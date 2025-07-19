local QBCore = exports["qb-core"]:GetCoreObject()
ESX = nil
lib.locale()
------------------------------
---
---██╗   ██╗ █████╗ ██████╗ ██╗ █████╗ ██████╗ ██╗     ███████╗███████╗
---██║   ██║██╔══██╗██╔══██╗██║██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝
---██║   ██║███████║██████╔╝██║███████║██████╔╝██║     █████╗  ███████╗
---╚██╗ ██╔╝██╔══██║██╔══██╗██║██╔══██║██╔══██╗██║     ██╔══╝  ╚════██║
--- ╚████╔╝ ██║  ██║██║  ██║██║██║  ██║██████╔╝███████╗███████╗███████║
---  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝
---
------------------------------
local attachedProp = nil
local targetActive = false
local alreadyCall = false
------------------------------
---
---███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
---██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
---█████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
---██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
---██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
---╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
---
------------------------------
local function clearProp()
    if attachedProp and DoesEntityExist(attachedProp) then
        DeleteEntity(attachedProp)
        attachedProp = 0
    end
end

local function stopAnimation()
    ClearPedTasks(PlayerPedId())
    clearProp()
end

local function attachProp(prop, xP, yP, zP, xRot, yRot, zRot)
    clearProp()
    local model = prop
    local boneNumber = 28422
    SetCurrentPedWeapon(cache.ped, 0xA2719263, false)
    local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumber)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    attachedProp = CreateObject(model, 1.0, 1.0, 1.0, 1, 1, 0)
    local x, y, z = xP, yP, zP
    local xR, yR, zR = xRot, yRot, zRot
    AttachEntityToEntity(attachedProp, GetPlayerPed(-1), bone, x, y, z, xR, yR, zR, 0, true, false, true, 2, true)
end

local function handleAnimation(dict, name, prop, x, y, z, xR, yR, zR)
    local animDict = dict
    if not DoesAnimDictExist(animDict) then
        return false
    end
    RequestAnimDict(animDict)
    while (not HasAnimDictLoaded(animDict)) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, name, 5.0, 5.0, -1, 51, 0, false, false, false)
    if prop then
        attachProp(prop, x, y, z, xR, yR, zR)
    end
end

local function hasNumberCard(cb)
    if Config.Inventory == "ox" then
        local items = exports.ox_inventory:GetPlayerItems()
        if not items then return cb(false) end
        for _, item in pairs(items) do
            if item.name == "number_card" and item.count > 0 then
                return cb(true)
            end
        end
        return cb(false)
    elseif Config.Inventory == "qb" then
        local item = exports['qb-inventory']:HasItem("number_card")
        if item.count > 0 then
            return cb(true)
        end
        return cb(false)
    end
end

local function addPhoneboxTarget()
    if targetActive then return end
    targetActive = true
    if Config.Target == "ox" then
        exports.ox_target:addModel(Config.PhoneBoxes, {
            label = "Call Someone",
            icon = "fas fa-phone",
            distance = 2,
            onSelect = function(data)
                if alreadyCall == false then
                    alreadyCall = true
                    local entity = data.entity
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(entity)
                    TaskGoStraightToCoord(ped, coords.x, coords.y, coords.z, 1.0, -1, GetEntityHeading(ped), 1.0)
                    CreateThread(function()
                        while true do
                            Wait(100)
                            local pedCoords = GetEntityCoords(ped)
                            local distance = #(pedCoords - coords)
                            if Config.Debug == true then print("[DEBUG] " .. distance) end
                            if distance <= 1.47 then
                                ClearPedTasks(ped)
                                TaskTurnPedToFaceEntity(ped, entity, -1)
                                break
                            end
                        end
                        TriggerEvent("blackcontact:callSomeone")
                    end)
                else
                    lib.notify({
                        type = "error",
                        icon = "fas fa-envelope",
                        title = "Someone",
                        description = "You already call me!"
                    })
                end
            end
        })
    elseif Config.Target == "qb" then
        exports['qb-target']:AddTargetModel(Config.PhoneBoxes, {
            options = {
                {
                    label = "Call Someone",
                    icon = "fas fa-phone",
                    action = function(entity)
                        if alreadyCall == false then
                            alreadyCall = true
                            local ped = PlayerPedId()
                            local coords = GetEntityCoords(entity)
                            TaskGoStraightToCoord(ped, coords.x, coords.y, coords.z, 1.0, -1, GetEntityHeading(ped), 1.0)
                            CreateThread(function()
                                while true do
                                    Wait(100)
                                    local pedCoords = GetEntityCoords(ped)
                                    local distance = #(pedCoords - coords)
                                    if Config.Debug == true then print("[DEBUG] " .. distance) end
                                    if distance <= 1.47 then
                                        ClearPedTasks(ped)
                                        TaskTurnPedToFaceEntity(ped, entity, -1)
                                        break
                                    end
                                end
                                TriggerEvent("blackcontact:callSomeone")
                            end)
                        else
                            lib.notify({
                                type = "error",
                                icon = "fas fa-envelope",
                                title = "Someone",
                                description = "You already call me!"
                            })
                        end
                    end
                }
            },
            distance = 2
        })
    end
end

local function removePhoneboxTarget()
    if not targetActive then return end
    targetActive = false
    
    if Config.Target == "ox" then
        exports.ox_target:removeModel(Config.PhoneBoxes)
    elseif Config.Target == "qb" then
        exports['qb-target']:RemoveTargetModel(Config.PhoneBoxes)
    end
end

local function SetCount(item)
    local input = lib.inputDialog("How much do you want to purchase?", {
        {
            type = 'number',
            label = "Enter quantity (" .. item.label .. ")",
            icon = "hashtag",
            default = 1,
            required = true,
            min = 1
        },
    })
    if not input or not input[1] then
        lib.showContext('someone_menu')
        return nil
    end
    local amount = tonumber(input[1])
    if amount < 1 then
        lib.showContext('someone_menu')
        return nil
    else
        return amount
    end
end

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
RegisterNetEvent("blackcontact:callSomeone", function()
    lib.progressBar({
        duration = 1500,
        label = "Calling Someone",
        useWhileDead = false,
        allowCuffed = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = 'anim@amb@prop_human_atm@interior@female@idle_a',
            clip = 'idle_b'
        },
    })
    FreezeEntityPosition(PlayerPedId(), true)
    handleAnimation("mp_common", "givetake1_a")
    Wait(1500)
    stopAnimation()
    handleAnimation("random@kidnap_girl", "ig_1_girl_on_phone_loop", "vw_prop_casino_phone_01b_handle", 0.0, -0.030, -0.01, -90.0, 0.0, 0.0)
    Wait(1000)
    lib.notify({type = "inform", icon = "fas fa-phone", title = "Someone", description = "Hey, so you found my number, so what do you want to purchase?", duration = 3000})
    local options = {}
    local items = Config.Items
    local invFramework = "nui://ox_inventory/web/images/"
    if Config.Inventory == "ox" then
        invFramework = "nui://ox_inventory/web/images/"
    elseif Config.Inventory == "qb" then
        invFramework = "nui://qb-inventory/html/images/"
    end
    for i = 1, #items do
        local item = items[i]
        options[#options + 1] = {
            title = item.label,
            description = "Price: " .. item.value .. "$",
            icon = invFramework .. item.name .. ".png",
            image = invFramework .. item.name .. ".png",
            onSelect = function()
                TriggerEvent("blackcontact:orderPackage", item)
            end
        }
    end
    lib.registerContext({
        id = "someone_menu",
        title = "What do you want to purchase?",
        onExit = function()
            alreadyCall = false
            stopAnimation()
            handleAnimation("mp_common", "givetake1_b", "vw_prop_casino_phone_01b_handle", 0.06, 0.01, -0.02, 180.0, 180.0, 0.0)
            Wait(1500)
            stopAnimation()
            FreezeEntityPosition(PlayerPedId(), false)
        end,
        options = options
    })
    lib.showContext("someone_menu")
end)

RegisterNetEvent("blackcontact:orderPackage", function(item)
    local count = SetCount(item)
    if count then
        alreadyCall = false
        item.count = count
        lib.notify({type = "inform", icon = "fas fa-phone", title = "Someone", description = "Okay, your package is on way, I will send the location to your phone in a few seconds, don't forget to prepare the money, I'm watching you!", duration = 5000})
        Wait(5000)
        stopAnimation()
        handleAnimation("mp_common", "givetake1_b", "vw_prop_casino_phone_01b_handle", 0.06, 0.01, -0.02, 180.0, 180.0, 0.0)
        Wait(1500)
        stopAnimation()
        FreezeEntityPosition(PlayerPedId(), false)
        Wait(5000)
        lib.notify({type = "inform", icon = "fas fa-envelope", title = "Mail: Someone", description = "Your package is ready, location is attached.", duration = 3000})
        local coords = Config.Coords[math.random(1, #Config.Coords)]
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, Config.Blip.sprite)
        SetBlipScale(blip, Config.Blip.scale)
        SetBlipColour(blip, Config.Blip.colour)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.label)
        EndTextCommandSetBlipName(blip)
        local zoneName = "package_" .. item.name
        if Config.Target == "ox" then
            exports.ox_target:addSphereZone({
                name = zoneName,
                coords = vector3(coords.x, coords.y, coords.z + 0.5),
                debug = Config.Debug,
                radius = 0.8,
                options = {
                    label = "Pick Up Package",
                    icon = "fas fa-hand",
                    distance = 2,
                    onSelect = function()
                        if Config.Framework == "qb" then
                            QBCore.Functions.TriggerCallback("blackcontact:pickupPackage", function(success)
                                if success then
                                    RemoveBlip(blip)
                                    exports.ox_target:removeZone(zoneName)
                                    Wait(2000)
                                    lib.notify({
                                        type = "inform",
                                        title = "Mail: Someone",
                                        icon = "fas fa-envelope",
                                        description = "Thank you for your cooperation, call me if you need anything.",
                                    })
                                else
                                    lib.notify({
                                        type = "error",
                                        title = "Mail: Someone",
                                        icon = "fas fa-envelope",
                                        description = "I told you I was watching you, put your money in and pick up the package!",
                                    })
                                end
                            end, item)
                        elseif Config.Framework == "ox" then
                            lib.callback("blackcontact:pickupPackage", function(success)
                                if success then
                                    RemoveBlip(blip)
                                    exports.ox_target:removeZone(zoneName)
                                    Wait(2000)
                                    lib.notify({
                                        type = "inform",
                                        title = "Mail: Someone",
                                        icon = "fas fa-envelope",
                                        description = "Thank you for your cooperation, call me if you need anything.",
                                    })
                                else
                                    lib.notify({
                                        type = "error",
                                        title = "Mail: Someone",
                                        icon = "fas fa-envelope",
                                        description = "I told you I was watching you, put your money in and pick up the package!",
                                    })
                                end
                            end, item)
                        elseif Config.Framework == "ESX" then
                            ESX.TriggerClientCallback("blackcontact:pickupPackage", function(success)
                                if success then
                                    RemoveBlip(blip)
                                    exports.ox_target:removeZone(zoneName)
                                    Wait(2000)
                                    lib.notify({
                                        type = "inform",
                                        title = "Mail: Someone",
                                        icon = "fas fa-envelope",
                                        description = "Thank you for your cooperation, call me if you need anything.",
                                    })
                                else
                                    lib.notify({
                                        type = "error",
                                        title = "Mail: Someone",
                                        icon = "fas fa-envelope",
                                        description = "I told you I was watching you, put your money in and pick up the package!",
                                    })
                                end
                            end, item)
                        end
                    end
                }
            })
        elseif Config.Target == "qb" then
            exports['qb-target']:AddCircleZone(zoneName, vector3(coords.x, coords.y, coords.z + 0.5), 0.8, {
                name = zoneName,
                debugPoly = Config.Debug,
                useZ = true
            }, {
                options = {
                    {
                        icon = "fas fa-hand",
                        label = "Pick Up Package",
                        action = function()
                            if Config.Framework == "qb" then
                                QBCore.Functions.TriggerCallback("blackcontact:pickupPackage", function(success)
                                    if success then
                                        RemoveBlip(blip)
                                        exports.ox_target:removeZone(zoneName)
                                        Wait(2000)
                                        lib.notify({
                                            type = "inform",
                                            title = "Mail: Someone",
                                            icon = "fas fa-envelope",
                                            description = "Thank you for your cooperation, call me if you need anything.",
                                        })
                                    else
                                        lib.notify({
                                            type = "error",
                                            title = "Mail: Someone",
                                            icon = "fas fa-envelope",
                                            description = "I told you I was watching you, put your money in and pick up the package!",
                                        })
                                    end
                                end, item)
                            elseif Config.Framework == "ox" then
                                lib.callback("blackcontact:pickupPackage", function(success)
                                    if success then
                                        RemoveBlip(blip)
                                        exports.ox_target:removeZone(zoneName)
                                        Wait(2000)
                                        lib.notify({
                                            type = "inform",
                                            title = "Mail: Someone",
                                            icon = "fas fa-envelope",
                                            description = "Thank you for your cooperation, call me if you need anything.",
                                        })
                                    else
                                        lib.notify({
                                            type = "error",
                                            title = "Mail: Someone",
                                            icon = "fas fa-envelope",
                                            description = "I told you I was watching you, put your money in and pick up the package!",
                                        })
                                    end
                                end, item)
                            elseif Config.Framework == "ESX" then
                                ESX.TriggerClientCallback("blackcontact:pickupPackage", function(success)
                                    if success then
                                        RemoveBlip(blip)
                                        exports.ox_target:removeZone(zoneName)
                                        Wait(2000)
                                        lib.notify({
                                            type = "inform",
                                            title = "Mail: Someone",
                                            icon = "fas fa-envelope",
                                            description = "Thank you for your cooperation, call me if you need anything.",
                                        })
                                    else
                                        lib.notify({
                                            type = "error",
                                            title = "Mail: Someone",
                                            icon = "fas fa-envelope",
                                            description = "I told you I was watching you, put your money in and pick up the package!",
                                        })
                                    end
                                end, item)
                            end
                        end,
                        drawDistance = 5.0,
                        drawColor = {255, 255, 255, 255},
                        successDrawColor = {0, 255, 0, 255}
                    }
                },
                distance = 2
            })
        end
    end
end)

------------------------------
---
---████████╗██╗  ██╗██████╗ ███████╗ █████╗ ██████╗ ███████╗
---╚══██╔══╝██║  ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝
---   ██║   ███████║██████╔╝█████╗  ███████║██║  ██║███████╗
---   ██║   ██╔══██║██╔══██╗██╔══╝  ██╔══██║██║  ██║╚════██║
---   ██║   ██║  ██║██║  ██║███████╗██║  ██║██████╔╝███████║
---   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝
---
------------------------------
Citizen.CreateThread(function()
    Wait(0)
    local pedData = Config.SomeonePed
    local modelHash = GetHashKey(pedData.model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
    RequestAnimDict(pedData.dict)
    while not HasAnimDictLoaded(pedData.dict) do
        Wait(10)
    end
    local ped = CreatePed(0, modelHash, pedData.coords.x, pedData.coords.y, pedData.coords.z - 1.0, pedData.coords.w, false, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskPlayAnim(ped, pedData.dict, pedData.name, 8.0, -8.0, -1, 1, 0, false, false, false)
    if Config.Debug == true then print("[DEBUG] Ped created.") end
    if Config.Target == "ox" then
        if Config.Debug == true then print("[DEBUG] OX Target found.") end
        exports.ox_target:addModel(pedData.model, {
            {
                label = "Talk Someone",
                icon = "fa-solid fa-comments",
                distance = 2.0,
                onSelect = function()
                    handleAnimation("mp_common", "givetake1_a")
                    TaskPlayAnim(ped, "mp_common", "givetake1_b", 8.0, -8.0, -1, 1, 0, false, false, false)
                    Wait(2500)
                    stopAnimation()
                    TaskPlayAnim(ped, pedData.dict, pedData.name, 8.0, -8.0, -1, 1, 0, false, false, false)
                    lib.notify({type = "success", icon = "fas fa-address-card", title = "Someone", description = "Now, with this number, you can contact the seller from the phone boxes, if you found this card, he will answer your calls.", duration = 3000})
                    if Config.Framework == "qb" then
                        QBCore.Functions.TriggerCallback("blackcontact:getCard")
                    elseif Config.Framework == "ox" then
                        lib.callback("blackcontact:getCard")
                    elseif Config.Framework == "ESX" then
                        ESX.TriggerClientCallback("blackcontact:getCard")
                    end
                end
            }
        })
    elseif Config.Target == "qb" then
        if Config.Debug == true then print("[DEBUG] QB Target found.") end
        exports['qb-target']:AddTargetModel(pedData.model, {
            options = {
                {
                    icon = "fas fa-comments",
                    label = "Talk Someone",
                    action = function()
                        if Config.Framework == "qb" then
                            QBCore.Functions.TriggerCallback("blackcontact:getCard")
                        elseif Config.Framework == "ox" then
                            lib.callback("blackcontact:getCard")
                        elseif Config.Framework == "ESX" then
                            ESX.TriggerClientCallback("blackcontact:getCard")
                        end
                        lib.notify({type = "success", icon = "fas fa-adress-card", title = "Someone", description = "Now, with this number, you can contact the seller from the phone boxes, if you found this card, he will answer your calls.", duration = 3000})
                    end,
                }
            },
            distance = 2
        })
    end
    if Config.Debug == true then print("[DEBUG] Targed added.") end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        hasNumberCard(function(hasIt)
            if hasIt then
                addPhoneboxTarget()
            else
                removePhoneboxTarget()
            end
        end)
    end
end)
