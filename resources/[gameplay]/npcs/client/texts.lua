-- Enter/exit club
local enterPos = vector3(-1389.0, -585.8, 30.1) -- Outside entrance
local exitPos = vector3(-1387.0, -589.0, 30.1)  -- Inside location

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Outside: Enter nightclub
        if #(playerCoords - enterPos) < 2.0 then
            DrawText3D(enterPos.x, enterPos.y, enterPos.z + 1.0, "[E] Enter Nightclub")
            if IsControlJustReleased(0, 38) then -- E key
                SetEntityCoords(playerPed, exitPos.x, exitPos.y, exitPos.z)
                TriggerEvent("chat:addMessage", { args = { "^2You entered the nightclub!" } })
            end
        end
        
        -- Inside: Exit nightclub
        if #(playerCoords - exitPos) < 2.0 then
            DrawText3D(exitPos.x, exitPos.y, exitPos.z + 1.0, "[E] Exit Nightclub")
            if IsControlJustReleased(0, 38) then -- E key
                SetEntityCoords(playerPed, enterPos.x, enterPos.y, enterPos.z)
                TriggerEvent("chat:addMessage", { args = { "^2You exited the nightclub!" } })
            end
        end
    end
end)


-- Welcome text
local welcomePos = vector3(-828.19, 172.75, 70)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        if #(playerCoords - welcomePos) < 10.0 then
            DrawText3D(welcomePos.x, welcomePos.y, welcomePos.z + 2.2, "Welcome to Overload FiveM server!")
            DrawText3D(welcomePos.x, welcomePos.y, welcomePos.z + 1.6, "Earn money by drifting!")
            DrawText3D(welcomePos.x, welcomePos.y, welcomePos.z + 1.9, "Access the menu by pressing [M].")
            DrawText3D(welcomePos.x, welcomePos.y, welcomePos.z + 1.3, "Enter the Drift Tuner to install drift tune on your car.")
            DrawText3D(welcomePos.x, welcomePos.y, welcomePos.z + 1.0, "See the drift leaderboard by pressing [U].")
        end
    end
end)


-- Helper function for 3D text
function DrawText3D(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextFont(4) -- More stylish font
    SetTextProportional(1)
    SetTextScale(0.45, 0.45) -- Slightly bigger
    SetTextColour(0, 255, 150, 220) -- Custom color (teal)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end