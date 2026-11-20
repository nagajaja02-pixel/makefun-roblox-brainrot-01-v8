-- MerchantService: the merchant who sells brainrots from a stall by the
-- conveyor. The stall stocks three characters at a time, priced a quarter
-- above the conveyor for the certainty of buying at once, and the stock
-- turns over every ninety seconds. Clients learn the stock through a
-- remote; buying goes through another one, validated on the server.

local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
local BrainrotModels = require(script.Parent.BrainrotModels)

local MerchantService = {}

local services = nil
local stock = {}
local stockRemote = nil
local rotateTime = 90
local markup = 1.25

-- The merchant's price for a character: a quarter over the conveyor price.
local function merchantPrice(char)
	return math.floor(char.price * markup)
end

-- Pick three different characters for the stall, leaning toward the
-- pricier ones so the stall feels different from the belt.
local function rollStock()
	local pool = {}
	for _, char in ipairs(BrainrotData.Characters) do
		table.insert(pool, char)
	end
	local picked = {}
	while #picked < 3 and #pool > 0 do
		local idx = math.random(#pool)
		local char = pool[idx]
		table.remove(pool, idx)
		-- A pricey character is more likely to make the stall.
		if char.price >= 900 or math.random() < 0.5 then
			table.insert(picked, char)
		end
	end
	while #picked < 3 do
		local char = BrainrotData.Characters[math.random(#BrainrotData.Characters)]
		local seen = false
		for _, other in ipairs(picked) do
			if other.id == char.id then
				seen = true
			end
		end
		if not seen then
			table.insert(picked, char)
		end
	end
	stock = {}
	for _, char in ipairs(picked) do
		table.insert(stock, { id = char.id, price = merchantPrice(char) })
	end
end

-- Tell every client what the stall holds right now.
local function broadcastStock()
	local payload = {}
	for _, entry in ipairs(stock) do
		table.insert(payload, { id = entry.id, price = entry.price })
	end
	stockRemote:FireAllClients(payload)
end

-- Build the merchant: a stall counter and a figure behind it, by the belt.
local function buildMerchant()
	local stall = Instance.new("Folder")
	stall.Name = "MerchantStall"
	stall.Parent = workspace.Island
	local function mkPart(name, size, pos, color, material)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Position = pos
		p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic
		p.Anchored = true
		p.Parent = stall
		return p
	end
	-- The counter and its striped awning.
	mkPart("Counter", Vector3.new(8, 2, 3), Vector3.new(-40, 1, -12), Color3.fromRGB(150, 110, 70), Enum.Material.Wood)
	mkPart("Awning", Vector3.new(9, 0.4, 5), Vector3.new(-40, 6, -12), Color3.fromRGB(220, 60, 60), Enum.Material.Fabric)
	mkPart("PostL", Vector3.new(0.5, 6, 0.5), Vector3.new(-44, 3, -12), Color3.fromRGB(90, 70, 50), Enum.Material.Wood)
	mkPart("PostR", Vector3.new(0.5, 6, 0.5), Vector3.new(-36, 3, -12), Color3.fromRGB(90, 70, 50), Enum.Material.Wood)
	-- The merchant figure: a body, a head, and a wide hat.
	mkPart("Body", Vector3.new(2, 2.2, 1.3), Vector3.new(-40, 1.1, -14), Color3.fromRGB(120, 80, 160), Enum.Material.SmoothPlastic)
	mkPart("Head", Vector3.new(1.5, 1, 1.2), Vector3.new(-40, 2.7, -14), Color3.fromRGB(240, 200, 160), Enum.Material.SmoothPlastic)
	mkPart("Hat", Vector3.new(2.6, 0.4, 2.6), Vector3.new(-40, 3.4, -14), Color3.fromRGB(60, 40, 20), Enum.Material.SmoothPlastic)
	local gui = Instance.new("BillboardGui")
	gui.Name = "NameLabel"
	gui.Size = UDim2.new(0, 120, 0, 30)
	gui.StudsOffset = Vector3.new(0, 4.4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = stall
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "MERCHANT"
	label.TextColor3 = Color3.fromRGB(255, 220, 90)
	label.TextStrokeTransparency = 0.2
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
end

-- Buy one of the stocked characters. It lands straight on a free stand.
function MerchantService.buy(player, charId)
	local entry = nil
	for _, item in ipairs(stock) do
		if item.id == charId then
			entry = item
			break
		end
	end
	if entry == nil then
		return false
	end
	local char = BrainrotData.byId(charId)
	if char == nil then
		return false
	end
	if not services.Money:canAfford(player, entry.price) then
		return false
	end
	if not services.Base:hasFreeStand(player) then
		return false
	end
	services.Money:spend(player, entry.price)
	services.Base:place(player, char, "Normal")
	return true
end

-- Build the stall, open the remotes, and rotate the stock.
function MerchantService.init(deps)
	services = deps
	buildMerchant()
	stockRemote = Instance.new("RemoteEvent")
	stockRemote.Name = "MerchantStock"
	stockRemote.Parent = game:GetService("ReplicatedStorage")
	local buyRemote = Instance.new("RemoteEvent")
	buyRemote.Name = "BuyMerchant"
	buyRemote.Parent = game:GetService("ReplicatedStorage")
	buyRemote.OnServerEvent:Connect(function(player, charId)
		if typeof(charId) == "string" then
			MerchantService.buy(player, charId)
		end
	end)
	rollStock()
	broadcastStock()
	game:GetService("Players").PlayerAdded:Connect(function(player)
		task.wait(2)
		local payload = {}
		for _, entry in ipairs(stock) do
			table.insert(payload, { id = entry.id, price = entry.price })
		end
		stockRemote:FireClient(player, payload)
	end)
	task.spawn(function()
		while true do
			task.wait(rotateTime)
			rollStock()
			broadcastStock()
		end
	end)
end

return MerchantService
