local _CurrentResource = GetCurrentResourceName()
local CACHE = {
    Hashes = {},
    ValidModelHashes = {},
    ValidAnimDicts = {},
    GroundAtCoords = {},
}

DEFAULT_HASH = `__DEFAULT`

Logger = {
	Debug = function(message, ...)
		print(("[%s] DEBUG: " .. message):format(_CurrentResource or "unknown", ...))
	end,
	
	DebugIf = function(condition, message, ...)
		if condition == true then
			print(("[%s] DEBUG: " .. message):format(_CurrentResource or "unknown", ...))
		end
	end,
	
	Info = function(message, ...)
		print(("[%s] INFO: " .. message):format(_CurrentResource or "unknown", ...))
	end,
	
	InfoIf = function(condition, message, ...)
		if condition == true then
			print(("[%s] INFO: " .. message):format(_CurrentResource or "unknown", ...))
		end
	end,
	
	Warn = function(message, ...)
		print(("[%s] WARN: " .. message):format(_CurrentResource or "unknown", ...))
	end,
	
	WarnIf = function(condition, message, ...)
		if condition == true then
			print(("[%s] WARN: " .. message):format(_CurrentResource or "unknown", ...))
		end
	end,
	
	Error = function(message, ...)
		print(("[%s] ERROR: " .. message):format(_CurrentResource or "unknown", ...))
	end,
	
	ErrorIf = function(condition, message, ...)
		if condition == true then
			print(("[%s] ERROR: " .. message):format(_CurrentResource or "unknown", ...))
		end
	end,
}

function GetHash(str)
    local hash = CACHE.Hashes[str]
    if not hash then
        hash = joaat(str)
        CACHE.Hashes[str] = hash
    end
    return hash
end

function IsModelHashValid(hash)
	local modelValid = CACHE.ValidModelHashes[hash]
	if modelValid == nil then
		modelValid = IsModelValid(hash)
		CACHE.ValidModelHashes[hash] = modelValid
	end
    return modelValid
end

function IsAnimDictValid(dict)
	local valid = CACHE.ValidAnimDicts[dict]
	if valid == nil then
		valid = DoesAnimDictExist(dict)
		CACHE.ValidAnimDicts[dict] = valid
	end
    return valid
end

function Lerp(a, b, t)
    return a + (b - a) * t
end

function GetOffsetFromCoordsInWorldCoords(position, rotation, offset)
    local rotX = math.rad(rotation.x)
    local rotY = math.rad(rotation.y)
    local rotZ = math.rad(rotation.z)

    local matrix = {
        {
            math.cos(rotZ) * math.cos(rotY) - math.sin(rotZ) * math.sin(rotX) * math.sin(rotY),
            math.cos(rotY) * math.sin(rotZ) + math.cos(rotZ) * math.sin(rotX) * math.sin(rotY),
            (-1 * math.cos(rotX)) * math.sin(rotY),
            1
        },
        {
            (-1 * math.cos(rotX)) * math.sin(rotZ),
            math.cos(rotZ) * math.cos(rotX),
            math.sin(rotX),
            1
        },
        {
            math.cos(rotZ) * math.sin(rotY) + math.cos(rotY) * math.sin(rotZ) * math.sin(rotX),
            math.sin(rotZ) * math.sin(rotY) - math.cos(rotZ) * math.cos(rotY) * math.sin(rotX),
            math.cos(rotX) * math.cos(rotY),
            1
        },
        {
            position.x,
            position.y,
            position.z,
            1
        }
    }

    local x = offset.x * matrix[1][1] + offset.y * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
    local y = offset.x * matrix[1][2] + offset.y * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
    local z = offset.x * matrix[1][3] + offset.y * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]

    return vector3(x, y, z)
end

function Ternary(condition, trueValue, falseValue)
    if condition then
        return trueValue
    else
        return falseValue
    end
end

function GetOppositeRotationValue(rotVal)
    return rotVal + (180.0 * Ternary(rotVal < 0.0, 1, -1))
end

function GetOffsetBetweenRotValues(rotVal1, rotVal2)
    local a = rotVal1
    local c = rotVal2
    local b = c - a
    return b
end

function GetOffsetBetweenRotations(rot1, rot2)
    return vector3(
        GetOffsetBetweenRotValues(rot1.x, rot2.x),
        GetOffsetBetweenRotValues(rot1.y, rot2.y),
        GetOffsetBetweenRotValues(rot1.z, rot2.z)
    )
end

function Round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function GroundCoords(coords, maxRetries, retryCount)
	retryCount = retryCount or 0
	maxRetries = maxRetries or 3
	local origCoords = coords
	coords = vector3(Round(coords.x, 1), Round(coords.y, 1), Round(coords.z, 1))
	local key = vector2(coords.x, coords.y)
	local _result = function(z)
		return vector3(origCoords.x, origCoords.y, z)
	end

	-- Check the cache
	if CACHE.GroundAtCoords[key] ~= nil then
		return _result(CACHE.GroundAtCoords[key])
	end
	
	-- Try to fetch
	RequestCollisionAtCoord(coords.x, coords.y, coords.x)
	local fetchSuccessful, zCoord = GetGroundZExcludingObjectsFor_3dCoord(coords.x, coords.y, coords.z, true)

	-- If the fetch failed, and we are still able to retry, try again
	if not fetchSuccessful and retryCount < maxRetries then
		return GroundCoords(origCoords, maxRetries, retryCount + 1)
	end

	-- If the fetch was successful cache the result, otherwise default
	if fetchSuccessful then
		CACHE.GroundAtCoords[key] = zCoord
		return _result(zCoord)
	else
		local playerPos = GetEntityCoords(PlayerPedId())
		return _result(playerPos.z - 0.9)
	end
end

function LoadRopeTexturesAsync(timeout)
    timeout = timeout or 1000
    local _promise = promise.new()

    local runFunc = function()
        -- Check if the textures are loaded
        if not RopeAreTexturesLoaded(modelHash) then
            _promise:resolve(true)
        end

        -- Try to load the textures
        local timer = 0
        while not RopeAreTexturesLoaded(modelHash) and timer < timeout do
            RopeLoadTextures(modelHash)
            timer = timer + 1
            Citizen.Wait(1)
        end

        local result = RopeAreTexturesLoaded(modelHash)
        _promise:resolve(result == 1)
    end

    runFunc()
    return _promise
end

function RequestModelAsync(modelName, timeout)
    timeout = timeout or 1000
    local _promise = promise.new()

    local runFunc = function()
        -- Get the hash for the model
        local modelHash = type(modelName) == "string" and GetHash(modelName) or modelName
        
        -- Get the model validity state
        local modelValid = IsModelHashValid(modelHash)

        -- Check if the model is valid
        if not modelValid then
            _promise:resolve(false)
        end

        -- Check if the model is loaded
        if HasModelLoaded(modelHash) then
            _promise:resolve(true)
        end

        -- Try to requets the model
        local timer = 0
        while not HasModelLoaded(modelHash) and timer < timeout do
            RequestModel(modelHash)
            timer = timer + 1
            Citizen.Wait(1)
        end

        local result = HasModelLoaded(modelHash)
        _promise:resolve(result == 1)
    end

    runFunc()
    return _promise
end

function LerpVector3(vectorA, vectorB, lerpVal)
    if vectorB == 0.0 or vectorB == nil then
        return vector3(Lerp(vectorA.x, 0.0, lerpVal), Lerp(vectorA.y, 0.0, lerpVal), Lerp(vectorA.z, 0.0, lerpVal))
    elseif vectorA == 0.0 or vectorA == nil then
        return vector3(Lerp(0.0, vectorB.x, lerpVal), Lerp(0.0, vectorB.y, lerpVal), Lerp(0.0, vectorB.z, lerpVal))
    else
        return vector3(Lerp(vectorA.x, vectorB.x, lerpVal), Lerp(vectorA.y, vectorB.y, lerpVal), Lerp(vectorA.z, vectorB.z, lerpVal))
    end
end

function DrawText2DThisFrame(drawOptions)
    -- Validate the draw options
    if drawOptions.coords == nil then error("Missing options field \"coords\", it must be a valid vector3 or vector2 object!", 2) end
    local coords = drawOptions.coords

    if drawOptions.text == nil or drawOptions.text == "" then error("Missing options field \"text\", it must be a valid string!", 2) end
    local text = drawOptions.text
    
    local colour = drawOptions.colour or { r = 255, g = 255, b = 255, a = 215 }
    local scale = drawOptions.scale or 0.35
    local outline = drawOptions.outline or false
    local font = drawOptions.font or 4
    local alignment = drawOptions.alignment or 1

    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour.r, colour.g, colour.b, colour.a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    if outline == true then SetTextOutline() end

    if alignment == 0 or alignment == 2 then
        SetTextJustification(alignment)

        if alignment == 2 then
            SetTextWrap(0, coords.x)
        end
    end 

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(coords.x, coords.y)
end