local PhysicsService = game:GetService("PhysicsService")

local World = require(script.Parent.World)

local Shield = {}
local activeDuration = 26
local cooldown = 48
local cyan = Color3.fromRGB(36, 232, 255)

function Shield.trackCharacter(character, ownerGroup)
	local function assign(part, group)
		if part:IsA("BasePart") then
			part.CollisionGroup = group
		end
	end

	local added = character.DescendantAdded:Connect(function(part)
		assign(part, ownerGroup)
	end)
	for _, part in ipairs(character:GetDescendants()) do
		assign(part, ownerGroup)
	end
	return function()
		added:Disconnect()
		for _, part in ipairs(character:GetDescendants()) do
			assign(part, "Default")
		end
	end
end

function Shield.build(frame, plot, cornerX, cornerZ, floor, top)
	local ownerGroup = "SafehouseOwner" .. plot
	local barrierGroup = "SafehouseBarrier" .. plot
	PhysicsService:RegisterCollisionGroup(ownerGroup)
	PhysicsService:RegisterCollisionGroup(barrierGroup)
	-- New groups collide with every group by default. Only this plot's owner is exempt.
	PhysicsService:CollisionGroupSetCollidable(barrierGroup, ownerGroup, false)

	local visual = Instance.new("Folder")
	visual.Name = "Shield lasers"
	local beamWidth, barrierWidth = 0.26, 0.3
	local beamY = top - beamWidth / 2
	local height = top - floor
	local centerY = (floor + top) / 2
	-- Side panels span both corners. End panels butt up against their inner faces.
	local spanX, spanZ = 2 * cornerX - barrierWidth, 2 * cornerZ + barrierWidth
	local function laser(name, sx, sy, sz, x, y, z, transparency, collidable)
		local part = World.part(visual, name, Vector3.new(sx, sy, sz),
			frame * CFrame.new(x, y, z), cyan, Enum.Material.Neon)
		part.Transparency = transparency
		part.CanCollide = collidable == true
		part.CanTouch = false
		part.CanQuery = part.CanCollide
		part.CastShadow = false
		if collidable then
			part.CollisionGroup = barrierGroup
		end
	end

	for _, side in ipairs({ -1, 1 }) do
		local x, z = side * cornerX, side * cornerZ
		laser("Shield side", barrierWidth, height, spanZ, x, centerY, 0, 0.92, true)
		laser("Shield end", spanX, height, barrierWidth, 0, centerY, z, 0.92, true)
		laser("Shield side beam", beamWidth, beamWidth, spanZ - 0.02, x, beamY - 0.02, 0, 0.12)
		laser("Shield end beam", spanX - 0.02, beamWidth, beamWidth, 0, beamY - 0.02, z, 0.12)
		local barHeight = height - 0.2
		for along = -16, 16, 4 do
			laser("Shield side bar", 0.21, barHeight, 0.21, x, centerY, along, 0.22)
		end
		for along = -10, 10, 4 do
			laser("Shield end bar", 0.21, barHeight, 0.21, along, centerY, z, 0.22)
		end
	end
	return visual, ownerGroup
end

function Shield.update(state, now)
	local base = state.base
	local locked = now < state.lockUntil
	local parent = locked and base.model or nil
	if base.shieldVisual.Parent ~= parent then
		base.shieldVisual.Parent = parent
		base.gate.Color = locked and World.aqua or World.gold
		base.title.Text = string.format("%s  /  %s", state.player.DisplayName, locked and "SHIELDED" or "RAIDABLE")
	end
end

function Shield.activate(state, now)
	state.lockUntil = now + activeDuration
	state.lockReady = now + cooldown
	state.player:SetAttribute("LockUntil", state.lockUntil)
	state.player:SetAttribute("LockReady", state.lockReady)
	Shield.update(state, now)
end

function Shield.clear(base)
	base.shieldVisual.Parent = nil
	base.title.Text = "AVAILABLE SAFEHOUSE"
	base.gate.Color = World.aqua
end

return Shield
