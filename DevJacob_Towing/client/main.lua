local currentTowTruck = nil
local canOperateBed = false
local movementControls = {
    lowerBed = false,
    raiseBed = false,
}

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    if currentTowTruck ~= nil then
        currentTowTruck:Destroy()
    end
end)

-- Vehicle detection thread
Citizen.CreateThread(function()
    while true do
        Wait(100)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, true)
        
        -- Check if we got a return on the vehicle
        if vehicle == 0 then
            goto continue
        end

        -- Check if the vehicle is a tow truck
        local vehicleHash = GetEntityModel(vehicle)
        local towTruckConfig = Config.TowTrucks[vehicleHash]
        if towTruckConfig == nil then
            if currentTowTruck ~= nil then
                currentTowTruck:SetAction(TowTruck.ACTION.NONE)
            else
                canOperateBed = false
            end
            goto continue
        end

        -- Ensure we have control of the entity
        if not NetworkHasControlOfEntity(vehicle) then
            if currentTowTruck ~= nil then
                currentTowTruck:SetAction(TowTruck.ACTION.NONE)
            else
                canOperateBed = false
            end
            goto continue
        end

        -- Create the truck object
        if currentTowTruck == nil then
            currentTowTruck = TowTruck.new(towTruckConfig, vehicle)
        else
            local vehicleNetId = VehToNet(vehicle)
            if currentTowTruck.truckNetId ~= vehicleNetId then
                currentTowTruck = TowTruck.new(towTruckConfig, vehicle)
            end
        end

        -- Check if the player can operate the bed
        if currentTowTruck ~= nil then
            local isInSeat = playerPed == GetPedInVehicleSeat(vehicle, -1)
            local hasRemote = currentTowTruck:IsRemoteInUse()
            local canControlBed = currentTowTruck:CanControlBed()

            canOperateBed = currentTowTruck.truckHandle == vehicle 
                and (isInSeat or hasRemote or canControlBed)
            
            if not canOperateBed then
                currentTowTruck:SetAction(TowTruck.ACTION.NONE)
            end
        end

        ::continue::
    end
end)

RegisterKeyMapping("+DevJacob_LowerBed", "Lower Tow Truck Bed", "KEYBOARD", "PAGEDOWN")
RegisterCommand("+DevJacob_LowerBed", function()

    -- Ensure the current tow truck exists
    if currentTowTruck == nil then
        return
    end
    
    -- Check if the player can operate the bed
    if not canOperateBed then 
        return
    end

    -- Ensure the other movement key isn't in use
    if movementControls.raiseBed == true then
        return
    end

    movementControls.lowerBed = true
    currentTowTruck:SetAction(TowTruck.ACTION.LOWERING)
end)

RegisterCommand("-DevJacob_LowerBed", function()

    -- Ensure the current tow truck exists
    if currentTowTruck == nil then
        return
    end

    -- Ensure the the movement key is infact in use
    if movementControls.lowerBed == false then
        return
    end

    movementControls.lowerBed = false
    currentTowTruck:SetAction(TowTruck.ACTION.NONE)
end)

RegisterKeyMapping("+DevJacob_RaiseBed", "Raise Tow Truck Bed", "KEYBOARD", "PAGEUP")
RegisterCommand("+DevJacob_RaiseBed", function()

    -- Ensure the current tow truck exists
    if currentTowTruck == nil then
        return
    end
    
    -- Check if the player can operate the bed
    if not canOperateBed then 
        return
    end

    -- Ensure the other movement key isn't in use
    if movementControls.lowerBed == true then
        return
    end

    movementControls.raiseBed = true
    currentTowTruck:SetAction(TowTruck.ACTION.RAISING)
end)

RegisterCommand("-DevJacob_RaiseBed", function()

    -- Ensure the current tow truck exists
    if currentTowTruck == nil then
        return
    end

    -- Ensure the the movement key is infact in use
    if movementControls.raiseBed == false then
        return
    end

    movementControls.raiseBed = false
    currentTowTruck:SetAction(TowTruck.ACTION.NONE)
end)

-- local RUN = false
-- RegisterCommand("test", function()
--     if RUN == true then 
--         RUN = false
--         return
--     end

--     local playerPed = PlayerPedId()
--     local vehicle = GetVehiclePedIsIn(playerPed, true)
--     RUN = true
--     for i = 0.0, 1.0, 0.005 do
--         if not RUN then break end
--         print(i)
--         SetVehicleFixed(vehicle)
--         SetVehicleBulldozerArmPosition(vehicle, i, false)
--         Citizen.Wait(1000)
--     end
-- end)


-- RegisterCommand("test2", function()
--     local playerPed = PlayerPedId()
--     local vehicle = GetVehiclePedIsIn(playerPed, true)
--     SetHydraulicRaised(vehicle, true)
-- end)


-- RegisterCommand("test3", function()
--     local playerPed = PlayerPedId()
--     local vehicle = GetVehiclePedIsIn(playerPed, true)
--     SetHydraulicRaised(vehicle, false)
-- end)