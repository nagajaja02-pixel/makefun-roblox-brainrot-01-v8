-- ConveyorService: runs the belt down the middle of the island.
-- A new character rolls out every few seconds, rides the belt from one end
-- to the other, and either gets bought (a player clicks it) or falls off
-- the far end. Services are injected through init, so no module requires
-- another service at load time.

local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
local BrainrotModels = require(script.Parent.BrainrotModels)

local ConveyorService = {}

local services = nil
local items = {}
local nextId = 1
local spawnTimer = 0

-- How likely a rolled character is to actually appear, by tier. Cheap
-- characters flood the belt; Mythics are a rare sight.
local function pickCharacter()
 return BrainrotData.pickCharacter(math.random(), workspace:GetAttribute("EventLuck") or 1)
end

-- The price tag floating over a character on the belt.
local function priceTag(model, char, mutation)
	local gui = Instance.new("BillboardGui")
	gui.Name = "PriceTag"
	gui.Size = UDim2.new(0, 110, 0, 40)
	gui.StudsOffset = Vector3.new(0, -1.2, 0)
	gui.AlwaysOnTop = true
	gui.Parent = model
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.BackgroundTransparency = 0.25
	label.Text = "$" .. tostring(char.price) .. "  •  $" .. tostring(BrainrotData.mutationIncome(char, mutation)) .. "/s"
	label.TextColor3 = Color3.fromRGB(255, 230, 120)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
end

-- Spawn one character at the start of the belt.
local function spawnOne()
	local char = pickCharacter()
	local mutation = BrainrotData.rollMutation()
	if math.random() < (workspace:GetAttribute("EventGoldChance") or 0) then mutation = "Gold" end
	local model = BrainrotModels.build(char, mutation)
	model:PivotTo(CFrame.new(BrainrotData.Conveyor.startX, 1, 0) * CFrame.Angles(0, math.rad(90), 0))
	model.Parent = workspace.Island

	priceTag(model, char, mutation)

	local item = {
		id = nextId,
		char = char,
		mutation = mutation,
		model = model,
		x = BrainrotData.Conveyor.startX,
	}
	nextId += 1

	-- Clicking the model buys it: the server checks cash and a free stand.
	local detector = Instance.new("ClickDetector")
	detector.MaxActivationDistance = 24
	detector.Parent = model.Body
	detector.MouseClick:Connect(function(player)
		ConveyorService.buy(player, item.id)
	end)

	table.insert(items, item)
	return item
end

-- Move every item along the belt; drop the ones that reach the far end.
local function tick(dt)
	for i = #items, 1, -1 do
		local item = items[i]
		item.x += BrainrotData.Conveyor.speed * dt
		if item.x >= BrainrotData.Conveyor.endX then
			item.model:Destroy()
			table.remove(items, i)
		else
			item.model:PivotTo(CFrame.new(item.x, 1, 0) * CFrame.Angles(0, math.rad(90), 0))
		end
	end
end

-- Buy the character on the belt. Cash and a free stand are both required.
function ConveyorService.buy(player, itemId)
	local idx = nil
	for i, item in ipairs(items) do
		if item.id == itemId then
			idx = i
			break
		end
	end
	if idx == nil then
		return false
	end
	local item = items[idx]
	if not services.Money:canAfford(player, item.char.price) then
		return false
	end
	if not services.Base:hasFreeStand(player) then
		return false
	end
	services.Money:spend(player, item.char.price)
	table.remove(items, idx)
	item.model:Destroy()
	services.Base:place(player, item.char, item.mutation)
	return true
end

-- The items currently on the belt (a copy, so callers cannot mutate it).
function ConveyorService.getItems()
	local copy = {}
	for i, item in ipairs(items) do
		copy[i] = item
	end
	return copy
end

-- Start the spawn timer and the movement loop.
function ConveyorService.init(deps)
	services = deps
	spawnTimer = 0
	game:GetService("RunService").Heartbeat:Connect(function(dt)
		spawnTimer += dt
		if spawnTimer >= BrainrotData.Conveyor.spawnInterval * (workspace:GetAttribute("EventSpawnInterval") or 1) then
			spawnTimer = 0
			spawnOne()
		end
		tick(dt)
	end)
	-- A few characters already on the belt when the first player arrives.
	spawnOne()
	spawnOne()
end

return ConveyorService
