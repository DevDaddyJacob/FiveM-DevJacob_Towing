local myOwnership = {}
local ropeSync = {}

local function deleteRope(storageKey) 
    -- print(storageKey, "Delete pre checks for local copy of rope", ropeSync[storageKey].ropeHandle)
    if 
        ropeSync[storageKey] ~= nil 
        and ropeSync[storageKey].ropeHandle ~= nil
        and DoesRopeExist(ropeSync[storageKey].ropeHandle)
    then
        -- print(storageKey, "Deleting local copy of rope", ropeSync[storageKey].ropeHandle)
        DeleteRope(ropeSync[storageKey].ropeHandle)
    end

    ropeSync[storageKey] = nil
end

local function updateRope(data)
    if ropeSync[data.truckNetId] == nil then return end
    if ropeSync[data.truckNetId].ropeHandle == nil then return end
    if not DoesRopeExist(ropeSync[data.truckNetId].ropeHandle) then return end

    RopeResetLength(ropeSync[data.truckNetId].ropeHandle, data.length)
    ropeSync[data.truckNetId].data = data
end

local function createRope(storageKey, data)
    local truckHandle = NetworkGetEntityFromNetworkId(data.truckNetId)
    local targetHandle = NetworkGetEntityFromNetworkId(data.targetEntity.netId)

    -- Load rope textures
    local texturesLoaded = Citizen.Await(loadRopeTexturesAsync())
    if texturesLoaded == false then
        Logger.Error("Failed to load rope textures")
        return
    end

    -- Create the rope
    local ropeHandle = AddRope(
        data.ropeRoot.x, data.ropeRoot.y, data.ropeRoot.z, 
        0.0, 0.0, 0.0, 
        data.maxLength + 0.001,
        3,
        data.length + 0.001,
        0.0,
        0.5,
        false,
        true,
        true,
        1.0,
        true,
        0)

    ActivatePhysics(ropeHandle)
        
    -- print(
    --     storageKey,
    --     "Creating local copy of hook rope",
    --     ropeHandle,
    --     "-",
    --     data.ropeRoot.x, data.ropeRoot.y, data.ropeRoot.z, 
    --     0.0, 0.0, 0.0, 
    --     data.maxLength + 0.001,
    --     3,
    --     data.length + 0.001,
    --     0.0,
    --     0.5,
    --     false,
    --     true,
    --     true,
    --     1.0,
    --     true,
    --     0
    -- )

    AttachEntitiesToRope(
        ropeHandle,
        truckHandle,
        targetHandle, 
        data.truckAttachPos.x,
        data.truckAttachPos.y,
        data.truckAttachPos.z,
        data.targetEntity.attachPos.x,
        data.targetEntity.attachPos.y,
        data.targetEntity.attachPos.z,
        data.length,
        false,
        false,
        data.truckAttachBone,
        data.targetEntity.attachBone)

    RopeResetLength(ropeHandle, data.length + 0.01)

    ropeSync[storageKey] = {
        data = data,
        ropeHandle = ropeHandle
    }
        
    -- print(
    --     storageKey,
    --     "Attachting local copy of hook rope",
    --     data.truckNetId,
    --     data.targetEntity.netId,
    --     "-",
    --     ropeHandle,
    --     truckHandle,
    --     targetHandle, 
    --     data.truckAttachPos.x,
    --     data.truckAttachPos.y,
    --     data.truckAttachPos.z,
    --     data.targetEntity.attachPos.x,
    --     data.targetEntity.attachPos.y,
    --     data.targetEntity.attachPos.z,
    --     data.length,
    --     false,
    --     false,
    --     data.truckAttachBone,
    --     data.targetEntity.attachBone
    -- )

end

AddStateBagChangeHandler("DevJacob_Tow:Rope", nil, function(bagName, key, value, reserved, replicated)
    -- print("StateBagHandler", bagName, key, value, reserved, replicated)
    local entityHandle = GetEntityFromStateBagName(bagName)
    if entityHandle == 0 then return end
    local entityNetId = NetworkGetNetworkIdFromEntity(entityHandle)
    local storageKey = entityNetId

    -- If we are deleting the rope
    if value == nil then
        if myOwnership[storageKey] == true then
            myOwnership[storageKey] = nil
        else
            deleteRope(storageKey)
        end
        return
    end

    -- Check if we are controlling the entity
    if value.ownerServerId == GetPlayerServerId(PlayerId()) then
        myOwnership[storageKey] = true
        return
    end

    -- If we are creating the rope
    if value ~= nil and ropeSync[storageKey] == nil then
        createRope(storageKey, value)
        return
    end

    -- If we are updating the rope
    if value ~= nil and ropeSync[storageKey] ~= nil then
        updateRope(storageKey, value)
        return
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for key, value in pairs(ropeSync) do
        if 
            value ~= nil 
            and value.ropeHandle ~= nil
            and DoesRopeExist(value.ropeHandle)
        then
            DeleteRope(value.ropeHandle)
        end
    end
end)