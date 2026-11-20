-- BaseService: owns the six safehouses and everything that sits on them.
-- Each player who joins claims one free base. A base holds stands (four at
-- first, up to eight), each stand holding one brainrot that earns money.
-- The service also builds the shield shell and the roof each base wears.

local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
local BrainrotModels = require(script.Parent.BrainrotModels)

local BaseService = {}

local services = nil
local bases = {}
local byPlayer = {}

-- The eight stand slots inside one base, two rows of four.
local slotOffsets = {
	{ x = -7.5, z = -4 },
	{ x = -2.5, z = -4 },
	{ x = 2.5, z = -4 },
	{ x = 7.5, z = -4 },
	{ x = -7.5, z = 4 },
	{ x = -2.5, z = 4 },
	{ x = 2.5, z = 4 },
	{ x = 7.5, z = 4 },
}

local function mkPart(parent, name, size, pos, color, opts)
	opts = opts or {}
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = opts.material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = true
	p.Parent = parent
	return p
end

-- Build one base plot: floor, sign, stand pads, roof with a ramp, and the
-- shield shell (invisible until the shield rises).
local function buildBase(index, pos)
	local folder = Instance.new("Folder")
	folder.Name = "Base" .. index
	folder.Parent = workspace.Island

	-- The floor slab, flush with the island ground.
	mkPart(folder, "Floor", Vector3.new(22, 1, 18), Vector3.new(pos.x, -0.5, pos.z), Color3.fromRGB(200, 190, 170), { material = Enum.Material.Concrete })

	-- A coloured border so each base reads as its own plot.
	mkPart(folder, "BorderN", Vector3.new(22, 0.4, 1), Vector3.new(pos.x, 0.2, pos.z - 8.5), Color3.fromRGB(90, 140, 220), { material = Enum.Material.Neon })
	mkPart(folder, "BorderS", Vector3.new(22, 0.4, 1), Vector3.new(pos.x, 0.2, pos.z + 8.5), Color3.fromRGB(90, 140, 220), { material = Enum.Material.Neon })

	-- The sign naming the base.
	local sign = mkPart(folder, "Sign", Vector3.new(8, 2.5, 0.6), Vector3.new(pos.x, 3.5, pos.z - 8.5), Color3.fromRGB(30, 30, 40))
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "BASE " .. index
	label.TextColor3 = Color3.fromRGB(255, 220, 90)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui

	-- The stand pads: a low disc per slot. Only the first four are live
	-- until the owner upgrades.
	local pads = {}
	for i, off in ipairs(slotOffsets) do
		local pad = mkPart(folder, "Pad" .. i, Vector3.new(3.4, 0.4, 3.4), Vector3.new(pos.x + off.x, 0.2, pos.z + off.z), Color3.fromRGB(120, 120, 135), { material = Enum.Material.Metal })
		pad.Shape = Enum.PartType.Cylinder
		pads[i] = pad
	end

	-- The roof: a flat platform high enough to stay dry, with a ramp up
	-- from the south side and four posts holding it.
	mkPart(folder, "Roof", Vector3.new(22, 1, 18), Vector3.new(pos.x, 7, pos.z), Color3.fromRGB(170, 120, 70), { material = Enum.Material.Wood })
	for _, dx in ipairs({ -10, 10 }) do
		for _, dz in ipairs({ -8, 8 }) do
			mkPart(folder, "Post", Vector3.new(1, 7, 1), Vector3.new(pos.x + dx, 3.5, pos.z + dz), Color3.fromRGB(140, 100, 60), { material = Enum.Material.Wood })
		end
	end
	local ramp = mkPart(folder, "Ramp", Vector3.new(4, 0.6, 10), Vector3.new(pos.x, 3.5, pos.z + 13), Color3.fromRGB(150, 110, 70), { material = Enum.Material.Wood })
	ramp.Rotation = Vector3.new(-35, 0, 0)

	-- The shield shell: a glowing box around the whole base, hidden until
	-- the shield is raised.
	local shell = mkPart(folder, "ShieldShell", Vector3.new(23, 9, 19), Vector3.new(pos.x, 4.5, pos.z), Color3.fromRGB(80, 180, 255), { material = Enum.Material.Neon })
	shell.Transparency = 1
	shell.CanCollide = false

	return {
		index = index,
		pos = pos,
		folder = folder,
		pads = pads,
		shieldPart = shell,
		owner = nil,
		stands = BrainrotData.Economy.startStands,
		placed = {},
	}
end

-- Give a joining player the first base nobody owns.
local function assignBase(player)
	for _, base in ipairs(bases) do
		if base.owner == nil then
			base.owner = player
			byPlayer[player.UserId] = base
			return base
		end
	end
	return nil
end

-- The base a player owns, or nil.
function BaseService.getBase(player)
	return byPlayer[player.UserId]
end

-- Does the player have a stand with nothing on it?
function BaseService.hasFreeStand(player)
	local base = byPlayer[player.UserId]
	if base == nil then
		return false
	end
	for i = 1, base.stands do
		if base.placed[i] == nil then
			return true
		end
	end
	return false
end

-- Put a character on the player's first free stand. Returns the record.
function BaseService.place(player, char, mutation)
	local base = byPlayer[player.UserId]
	if base == nil then
		return nil
	end
	local slot = nil
	for i = 1, base.stands do
		if base.placed[i] == nil then
			slot = i
			break
		end
	end
	if slot == nil then
		return nil
	end
	local off = slotOffsets[slot]
	local model = BrainrotModels.build(char, mutation)
	model:PivotTo(CFrame.new(base.pos.x + off.x, 0.4, base.pos.z + off.z))
	model.Parent = base.folder
	local record = {
		standId = slot,
		char = char,
		mutation = mutation,
		model = model,
	}
	base.placed[slot] = record
	-- Clicking a placed character is a steal attempt by anyone but its
	-- owner (the owner's own clicks do nothing; selling goes through the
	-- character menu instead).
	local detector = Instance.new("ClickDetector")
	detector.MaxActivationDistance = 24
	detector.Parent = model.Body
	detector.MouseClick:Connect(function(clicker)
		if clicker ~= player then
			services.Steal:trySteal(clicker, player, slot)
		end
	end)
	return record
end

-- Take a character off a stand and hand its record back WITHOUT destroying
-- the model, so the caller can carry it somewhere else (a steal). The
-- caller owns the model from here on.
function BaseService.takePlaced(player, standId)
	local base = byPlayer[player.UserId]
	if base == nil then
		return nil
	end
	local record = base.placed[standId]
	if record == nil then
		return nil
	end
	base.placed[standId] = nil
	return record
end

-- Take a character off a stand and hand its record back (for a steal or
-- a sale). The model is destroyed; the caller decides what happens next.
function BaseService.removePlaced(player, standId)
	local record = BaseService.takePlaced(player, standId)
	if record == nil then
		return nil
	end
	if record.model then
		record.model:Destroy()
	end
	return record
end

-- Every character the player currently has on stands.
function BaseService.getPlaced(player)
	local base = byPlayer[player.UserId]
	if base == nil then
		return {}
	end
	local out = {}
	for _, record in pairs(base.placed) do
		table.insert(out, record)
	end
	return out
end

-- How many stands the player owns right now.
function BaseService.getStandCount(player)
	local base = byPlayer[player.UserId]
	if base == nil then
		return 0
	end
	return base.stands
end

-- Buy one more stand, up to the maximum. Returns true when it worked.
function BaseService.upgrade(player)
	local base = byPlayer[player.UserId]
	if base == nil then
		return false
	end
	if base.stands >= BrainrotData.Economy.maxStands then
		return false
	end
	local cost = BrainrotData.upgradeCost(base.stands)
	if not services.Money:canAfford(player, cost) then
		return false
	end
	services.Money:spend(player, cost)
	base.stands += 1
	return true
end

-- Show or hide the shield shell around a player's base. When the shield
-- is up the shell is both visible and solid, so it really blocks raiders;
-- when it is down the shell is invisible and lets everyone through. The
-- shell's CanCollide flag is what makes the Shield collision group matter.
function BaseService.setShield(player, visible)
	local base = byPlayer[player.UserId]
	if base == nil then
		return
	end
	base.shieldPart.Transparency = visible and 0.6 or 1
	base.shieldPart.CanCollide = visible
end

-- Release a player's base when they leave.
local function freeBase(player)
	local base = byPlayer[player.UserId]
	if base == nil then
		return
	end
	for _, record in pairs(base.placed) do
		if record.model then
			record.model:Destroy()
		end
	end
	base.placed = {}
	base.stands = BrainrotData.Economy.startStands
	base.owner = nil
	base.shieldPart.Transparency = 1
	byPlayer[player.UserId] = nil
end

-- Build all six bases and hook player join/leave.
function BaseService.init(deps)
	services = deps
	for i, pos in ipairs(BrainrotData.Bases) do
		bases[i] = buildBase(i, pos)
	end
	-- The client buys a stand upgrade through this remote.
	local upgradeRemote = Instance.new("RemoteEvent")
	upgradeRemote.Name = "UpgradeStand"
	upgradeRemote.Parent = game:GetService("ReplicatedStorage")
	upgradeRemote.OnServerEvent:Connect(function(player)
		BaseService.upgrade(player)
	end)
	local players = game:GetService("Players")
	players.PlayerAdded:Connect(function(player)
		assignBase(player)
	end)
	players.PlayerRemoving:Connect(function(player)
		freeBase(player)
	end)
	for _, player in ipairs(players:GetPlayers()) do
		assignBase(player)
	end
end

return BaseService
