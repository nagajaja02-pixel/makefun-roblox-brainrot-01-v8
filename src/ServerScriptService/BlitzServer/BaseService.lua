local World = require(script.Parent.World)
local flat = Enum.Material.SmoothPlastic
local Money = require(script.Parent.MoneyService)
local Shield = require(script.Parent.ShieldService)
local Models = require(script.Parent.BrainrotModels)

local Base = {}
Base.startingCash = 150

local width, depth = 26, 40
local halfWidth, halfDepth = width / 2, depth / 2
local cornerWidth = 1.2
local shieldX, shieldZ = halfWidth - cornerWidth / 2, halfDepth - cornerWidth / 2
local deckTop, wallTop = 0.4, 9.6
local windowBottom, windowTop = 5.4, 8.65
local doorWidth, doorTop = 6, 7.5

local plotColors = {
	Color3.fromRGB(27, 192, 190), Color3.fromRGB(250, 115, 93), Color3.fromRGB(85, 144, 247),
	Color3.fromRGB(197, 119, 247), Color3.fromRGB(103, 200, 92), Color3.fromRGB(248, 177, 56),
}

function Base.build(map)
	local bases = {}
	for _, z in ipairs({ -World.plotRow, World.plotRow }) do
		for _, x in ipairs({ 0, -World.plotSpacing, World.plotSpacing }) do
			local model = Instance.new("Model")
			model.Name = "Safehouse " .. (#bases + 1)
			model.Parent = map
			local frame = CFrame.new(x, 0, z) * CFrame.Angles(0, z < 0 and math.pi or 0, 0)
			local function part(name, size, lx, ly, lz, color, material)
				return World.part(model, name, size, frame * CFrame.new(lx, ly, lz), color, material)
			end
			local plot = #bases + 1
			local accent = plotColors[plot]
			local pale = accent:Lerp(World.white, 0.78)
			local panel = accent:Lerp(World.ink, 0.24)
			local neon = Enum.Material.Neon
			local function detail(name, sx, sy, sz, lx, ly, lz, color, material)
				local item = part(name, Vector3.new(sx, sy, sz), lx, ly, lz, color, material)
				item.CanCollide = false
				item.CanTouch = false
				item.CanQuery = false
				return item
			end

			part("Shelter deck", Vector3.new(width, deckTop, depth), 0, deckTop / 2, 0, pale, flat)
			local wallHeight = wallTop - deckTop
			local wallY = deckTop + wallHeight / 2
			local innerWidth, sideSpan = width - 2 * cornerWidth, depth - 2 * cornerWidth
			local jambWidth = (innerWidth - doorWidth) / 2
			part("Rear service wall", Vector3.new(innerWidth, wallHeight, cornerWidth), 0, wallY, shieldZ, panel, flat)
			for _, side in ipairs({ -1, 1 }) do
				for _, endSide in ipairs({ -1, 1 }) do
					part("Shield corner pier", Vector3.new(cornerWidth, wallHeight, cornerWidth),
						side * shieldX, wallY, endSide * shieldZ, World.ink, flat)
				end
				local wallX = side * shieldX
				part("Side wall", Vector3.new(cornerWidth, windowBottom - deckTop, sideSpan),
					wallX, (deckTop + windowBottom) / 2, 0, panel, flat)
				part("Side window header", Vector3.new(cornerWidth, wallTop - windowTop, sideSpan),
					wallX, (windowTop + wallTop) / 2, 0, World.ink, flat)
				-- Recessed glazing keeps the sightline open even when players jump at the sill.
				local window = part("Side display window", Vector3.new(0.16, windowTop - windowBottom, sideSpan),
					wallX, (windowBottom + windowTop) / 2, 0, pale, flat)
				window.Transparency = 0.78
				window.CastShadow = false
				part("Front wall", Vector3.new(jambWidth, wallHeight, cornerWidth),
					side * (doorWidth + jambWidth) / 2, wallY, -shieldZ, panel, flat)
				detail("Canopy wing", 6.8, 0.7, sideSpan - 0.8, side * 8, 9.25, 0, accent)
				detail("Canopy edge light", 0.22, 0.12, 34, side * 5, 8.84, 0, pale, neon)
				detail("Aisle guide", 0.18, 0.03, 35, side * 4.7, 0.415, -0.5, panel)
			end
			detail("Raised service canopy", 18, 0.65, 6, 0, 10.725, 17, accent)
			local fascia = part("Safehouse nameboard", Vector3.new(doorWidth, wallTop - doorTop, cornerWidth),
				0, (wallTop + doorTop) / 2, -shieldZ, World.ink, flat)
			World.surfaceSign(fascia, string.format("SAFEHOUSE  %02d", plot), World.white)
			local gate = detail("Shield status", 4, 0.18, 0.14, 0, 7.36, -shieldZ - 0.53, World.aqua, neon)
			local title = World.sign(gate, "AVAILABLE SAFEHOUSE", World.white, 255, 34, Vector3.new(0, 2.8, 0))
			local drop = detail("Drop zone", 9, 0.03, 6, 0, 0.415, -14, World.aqua, neon)
			World.sign(drop, "DELIVERY  /  WAVE SHELTER", World.aqua, 235, 27, Vector3.new(0, 0.85, 0), 33)
			local controls = {}
			for index, titleText in ipairs({ "SHIELD", "EXPAND BASE" }) do
				local color = index == 1 and World.aqua or World.gold
				local terminal = part(titleText, Vector3.new(3.2, 1.24, 2.5), (index - 1.5) * 6, 1.02, 16.5, color)
				World.sign(terminal, titleText, color, 115, 23, Vector3.new(0, 1.4, 0), 23)
				controls[index] = terminal
			end
			local stands = {}
			for index = 1, 8 do
				local side = index % 2 == 1 and -1 or 1
				local column = 8
				local row = -11 + math.floor((index - 1) / 2) * 7
				local stand = part("Income stand " .. index, Vector3.new(5.2, 0.54, 4), side * column, 0.67, row, World.steel)
				detail("Display apron", 5.2, 0.26, 0.26, side * column, 0.53, row - 2.13, panel)
				detail("Display light", 4.2, 0.08, 0.08, side * column, 0.56, row - 2.3, pale, neon)
				stands[index] = stand
			end
			local shieldVisual, ownerCollisionGroup = Shield.build(frame, plot, shieldX - 0.8, shieldZ - 0.8, deckTop, wallTop)
			table.insert(bases, {
				frame = frame, gate = gate, title = title, stands = stands, controls = controls, model = model,
				entrance = (frame * CFrame.new(0, 0, -halfDepth + 4)).Position,
				shieldVisual = shieldVisual, ownerCollisionGroup = ownerCollisionGroup,
			})
		end
	end
	return bases
end

function Base.isSheltered(base, position)
	local point = base.frame:PointToObjectSpace(position)
	return math.abs(point.X) < halfWidth - 0.8 and point.Z > -halfDepth + 1 and point.Z < halfDepth - 1 and point.Y >= 0 and point.Y < 13
end

function Base.freeSlot(state)
	for index = 1, Money.capacity(state) do
		if not state.slots[index] then
			return index
		end
	end
end

function Base.refreshStands(state)
	for index, stand in ipairs(state.base.stands) do
		stand.Color = index <= Money.capacity(state) and World.aqua or World.steel
	end
end

function Base.parkUnit(state, index, slot, onRaid)
	local stand = state.base.stands[index]
	slot.inTransit = false
	slot.model = Models.sculpt(state.base.model, slot.unit, stand.CFrame * CFrame.new(0, 0.29, 0), slot.unit.entry[7])
	state.slots[index] = slot
	for _, part in ipairs(slot.model:GetChildren()) do
		if part:IsA("BasePart") then
			part.CanQuery = true
		end
	end
	local pickup = World.prompt(slot.model.PrimaryPart, "Pick Up", slot.unit.entry[1], 0)
	pickup.ClickablePrompt = false
	pickup:SetAttribute("OwnerUserId", state.player.UserId)
	pickup:SetAttribute("OwnerOnly", true)
	pickup:AddTag("StandPrompt")
	pickup.Triggered:Connect(function(player)
		if player == state.player then
			onRaid(player, state, index, slot)
		end
	end)

	local raid = World.prompt(slot.model.PrimaryPart, "Raid", slot.unit.entry[1], 1.25)
	raid:SetAttribute("OwnerUserId", state.player.UserId)
	raid:SetAttribute("OwnerOnly", false)
	raid:AddTag("StandPrompt")
	raid.Triggered:Connect(function(player)
		if player ~= state.player then
			onRaid(player, state, index, slot)
		end
	end)
	Money.publish(state)
end

function Base.clearCollection(state)
	for _, slot in pairs(state.slots) do
		if slot.model then
			slot.model:Destroy()
		end
	end
	table.clear(state.slots)
end

return Base
