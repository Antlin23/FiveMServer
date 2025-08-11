
local bennysEnter = vector3(-205.0, -1303.0, 30.0) -- Benny's entrance
local bennysInside = vector3(-222.47, -1329.49, 30.40) -- Inside Benny's (updated)
local bennysExit = vector3(-223.7, -1291.6, 31.0) -- Where player/car respawn after exit
local insideHeading = 269.76 -- Heading for inside Benny's
local insideTuner = false
local tunerCooldown = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        local pos = GetEntityCoords(playerPed)

        if tunerCooldown > 0 then
            tunerCooldown = tunerCooldown - 1
        end

    local xyDist = #(vector2(pos.x, pos.y) - vector2(bennysEnter.x, bennysEnter.y))
    if not insideTuner and tunerCooldown == 0 and xyDist < 5.0 and playerVeh ~= 0 and GetPedInVehicleSeat(playerVeh, -1) == playerPed then
            -- Show prompt
            SetTextComponentFormat("STRING")
            AddTextComponentString("Press ~INPUT_CONTEXT~ to enter Drift Tuner")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustPressed(0, 51) then -- E key
                    -- Add cool effect: screen fade
                    DoScreenFadeOut(500)
                    Citizen.Wait(600)

                    -- Teleport both vehicle and player inside
                    SetEntityCoords(playerVeh, bennysInside.x, bennysInside.y, bennysInside.z, false, false, false, true)
                    SetEntityHeading(playerVeh, insideHeading)
                    SetEntityCoords(playerPed, bennysInside.x, bennysInside.y, bennysInside.z, false, false, false, true)
                    SetEntityHeading(playerPed, insideHeading)
                    TaskWarpPedIntoVehicle(playerPed, playerVeh, -1)

                    SetVehicleFixed(playerVeh) -- Restores car health
                    SetVehicleDirtLevel(playerVeh, 0.0) -- Cleans car
                    DoScreenFadeIn(800)
                insideTuner = true
                TriggerEvent('drift:isInTuner', true)
                tunerCooldown = 200 -- about 3 seconds
            end
        end

        if insideTuner then
                -- Block movement and vehicle controls
                DisableControlAction(0, 63, true) -- Vehicle controls
                DisableControlAction(0, 64, true)
                DisableControlAction(0, 71, true)
                DisableControlAction(0, 72, true)
                DisableControlAction(0, 75, true) -- Exit vehicle
        end
    end
end)



RegisterNetEvent('drift:exitTuner')
AddEventHandler('drift:exitTuner', function()
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    DoScreenFadeOut(500)
    Citizen.Wait(600)
    SetEntityCoords(playerVeh, bennysExit.x, bennysExit.y, bennysExit.z, false, false, false, true)
    SetEntityHeading(playerVeh, insideHeading)
    SetEntityCoords(playerPed, bennysExit.x, bennysExit.y, bennysExit.z, false, false, false, true)
    SetEntityHeading(playerPed, insideHeading)
    TaskWarpPedIntoVehicle(playerPed, playerVeh, -1)
    DoScreenFadeIn(800)
    insideTuner = false
    TriggerEvent('drift:isInTuner', false)
    FreezeEntityPosition(playerPed, false)
    SetEntityVisible(playerPed, true)
    notify("Exited Drift Tuner.")
    tunerCooldown = 200 -- about 3 seconds
end)

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

-- Add Drift Tuner blip at Benny's location
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(bennysEnter.x, bennysEnter.y, bennysEnter.z)
    SetBlipSprite(blip, 72) -- Use mod shop icon
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 38) -- Cyan
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drift Tuner")
    EndTextCommandSetBlipName(blip)
end)