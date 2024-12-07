Config = {}

Config["DebugMode"] = false

--[[
	Forces the rope for the remote to not clip through the ground,
	this can reduce performance and make the script run a lot more expensively
]]
Config["GroundRemoteRope"] = false


Config["MaxHookReach"] = 10.0


Config["RemoteModel"] = `w_am_digiscanner_reh`


Config["HookModel"] = `prop_v_hook_s`


Config["TowTrucks"] = {
	--[[
		This config is used as an example config
		and also serves as a fallback config for when
		some config values are not found elsewhere.
	]]
	[`__DEFAULT`] = {
		--[[
			The model hash of the vehicle
		]]
		truckModel = `flatbed3`,

		--[[
			The model hash of the bed prop
		]]
		bedModel = `flatbed3_base`,

		--[[
			The extra number for toggling the bed 
			on the vehicle
		]]
		bedExtraIndex = 1,

		--[[
			The multiplier applied to the lerp calculation.
			In other words, this is a speed multiplier
			to the raise and lower process.
		]]
		lerpMult = 4.0,

		--[[
			If the truck has a remote that can be 
			grabbed to control the bed movement
		]]
		hasRemote = true,

		--[[
			The offset from the vehicle where the 
			remote can be retrieved from.

			Only used if "hasRemote" is set to true.
		]]
		remoteStorageOffset = vector3(-1.05, -1.0, 0.0),

		--[[
			The offset from the vehicle where the 
			control box for the bed is located.
			It's this location where the truck can
			be controlled by the user.

			Only used if "hasRemote" is set to false.
		]]
		controlBoxOffset = vector3(-1.05, -1.0, 0.0),
		
		--[[
			The offset from the bed on where the rope
			for the hook starts.
		]]
		hookRootOffset = vector3(0.025, 4.5, 0.1),

		--[[
			The offset from the bed that would attach a 
			car centered onto the bed.
		]]
		bedAttachOffset = vector3(0.0, 1.5, 0.3),

		--[[
			The offsets which control how the bed 
			slides from raised to lowered.

			When a bed is in default position it's
			using the "raised" offset. In the process
			of lowering the bed the bed will start
			at the "raised" offset, slide back to the
			"back" offset and then tilt to the "lowered"
			offset. This process is reversed when going
			from lowered to raised.
		]]
		bedOffsets = {
			raised = {
				pos = vector3(0.0, -3.8, 0.45),
				rot = vector3(0.0, 0.0, 0.0),
			},
			back = {
				pos = vector3(0.0, -4.0, 0.0),
				rot = vector3(0.0, 0.0, 0.0),
			},
			lowered = {
				pos = vector3(0.0, -0.4, -1.0),
				rot = vector3(12.0, 0.0, 0.0),
			},
		},
	},

	[`flatbed3`] = {
		truckModel = `flatbed3`,
		bedModel = `flatbed3_base`,
		bedExtraIndex = 1,
		lerpMult = 4.0,
		hasRemote = true,
		remoteStorageOffset = vector3(-1.05, -1.0, 0.0),
		controlBoxOffset = vector3(-1.05, -1.0, 0.0),
		hookRootOffset = vector3(0.025, 4.5, 0.1),
		bedAttachOffset = vector3(0.0, 1.5, 0.3),
		bedOffsets = {
			raised = {
				pos = vector3(0.0, -3.8, 0.45),
				rot = vector3(0.0, 0.0, 0.0),
			},
			back = {
				pos = vector3(0.0, -4.0, 0.0),
				rot = vector3(0.0, 0.0, 0.0),
			},
			lowered = {
				pos = vector3(0.0, -0.4, -1.0),
				rot = vector3(12.0, 0.0, 0.0),
			},
		},
	},
}