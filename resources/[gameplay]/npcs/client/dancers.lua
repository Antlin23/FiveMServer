local dancerPeds = {}
local dancerModels = {
    "a_f_y_clubcust_02",   -- Female clubber
    "ig_djgeneric_01",-- DJ/club staff
    "ig_claypain",-- red hipster
    "s_f_y_clubbar_01"     -- female partier, black clothes
}local dancerPositions = {
    vector4(-1388.0, -620.0, 30.82, 314.0), -- In front of Bahama Mamas dj set
    vector4(-1389.0, -616.0, 30.82, 300.0),
    vector4(-1384.0, -619.0, 30.82, 317.5),
    vector4(-1387.0, -617.4, 30.82, 295.5),
    vector4(-1385.1, -628.63, 30.82, 352.32)
}

-- Dancers
Citizen.CreateThread(function()
    for i, pos in ipairs(dancerPositions) do
        local model = dancerModels[(i - 1) % #dancerModels + 1]
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(100)
        end
        local ped = CreatePed(4, model, pos.x, pos.y, pos.z - 1.0, pos.w, false, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_PARTYING", 0, true) -- Example dance anim
        table.insert(dancerPeds, ped)
    end
end)

-- Doorman
Citizen.CreateThread(function()
    local model = "s_m_y_doorman_01"
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    local pos = vector4(-1390.3, -586.7, 30.23, 16.8) -- Bahama Mamas main entrance door
    local ped = CreatePed(4, model, pos.x, pos.y, pos.z - 1.0, pos.w, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_GUARD_STAND", 0, true) -- Guard stance
    table.insert(dancerPeds, ped)
end)