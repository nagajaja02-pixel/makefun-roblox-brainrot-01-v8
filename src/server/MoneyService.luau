-- MoneyService: holds every player's cash and pays their income.
-- Cash starts at the opening amount, income is summed once a second from
-- the characters on the player's stands (mutation and rebirth included),
-- and the numbers are mirrored into leaderstats so the client HUD can read
-- them. Rebirths persist in a DataStore; a failed load or save just falls
-- back to zero rather than breaking the game.

local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)

local MoneyService = {}

local services = nil
local cash = {}
local rebirths = {}
local store = nil

local function getStore()
	if store ~= nil then
		return store
	end
	local ok, result = pcall(function()
		return game:GetService("DataStoreService"):GetDataStore(BrainrotData.Economy.rebirthStore)
	end)
	if ok then
		store = result
	end
	return store
end

-- Build the leaderstats folder a player sees, with live Cash, Income and
-- Rebirths values.
local function makeLeaderstats(player)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player
	local cashValue = Instance.new("IntValue")
	cashValue.Name = "Cash"
	cashValue.Value = BrainrotData.Economy.startCash
	cashValue.Parent = folder
	local incomeValue = Instance.new("IntValue")
	incomeValue.Name = "Income"
	incomeValue.Value = 0
	incomeValue.Parent = folder
	local rebirthValue = Instance.new("IntValue")
	rebirthValue.Name = "Rebirths"
	rebirthValue.Value = 0
	rebirthValue.Parent = folder
	return folder
end

-- The income rate right now: every placed character's mutated income,
-- boosted by half again per rebirth the player has.
function MoneyService.getIncomePerSecond(player)
	local total = 0
	for _, record in ipairs(services.Base:getPlaced(player)) do
		total += BrainrotData.mutationIncome(record.char, record.mutation)
	end
	local boost = 1 + BrainrotData.Economy.rebirthBoost * (rebirths[player.UserId] or 0)
	return math.floor(total * boost)
end

-- How much cash the player holds.
function MoneyService.getCash(player)
	return cash[player.UserId] or BrainrotData.Economy.startCash
end

-- Can the player pay this amount?
function MoneyService.canAfford(player, amount)
	return MoneyService.getCash(player) >= amount
end

-- Take cash away. Returns false when the player cannot pay.
function MoneyService.spend(player, amount)
	if not MoneyService.canAfford(player, amount) then
		return false
	end
	cash[player.UserId] = MoneyService.getCash(player) - amount
	MoneyService.sync(player)
	return true
end

-- Add cash (a sale, a merchant deal, a reward).
function MoneyService.earn(player, amount)
	cash[player.UserId] = MoneyService.getCash(player) + amount
	MoneyService.sync(player)
end

-- How many rebirths the player has.
function MoneyService.getRebirths(player)
	return rebirths[player.UserId] or 0
end

-- Buy a rebirth: it costs more each time and permanently lifts income by
-- half again. The count is saved right away.
function MoneyService.rebirth(player)
	local count = MoneyService.getRebirths(player)
	local cost = BrainrotData.rebirthCost(count)
	if not MoneyService.canAfford(player, cost) then
		return false
	end
	MoneyService.spend(player, cost)
	rebirths[player.UserId] = count + 1
	MoneyService.sync(player)
	local ds = getStore()
	if ds ~= nil then
		pcall(function()
			ds:SetAsync(tostring(player.UserId), rebirths[player.UserId])
		end)
	end
	return true
end

-- Push the current numbers into the player's leaderstats.
function MoneyService.sync(player)
	local folder = player:FindFirstChild("leaderstats")
	if folder == nil then
		return
	end
	local cashValue = folder:FindFirstChild("Cash")
	if cashValue then
		cashValue.Value = MoneyService.getCash(player)
	end
	local incomeValue = folder:FindFirstChild("Income")
	if incomeValue then
		incomeValue.Value = MoneyService.getIncomePerSecond(player)
	end
	local rebirthValue = folder:FindFirstChild("Rebirths")
	if rebirthValue then
		rebirthValue.Value = MoneyService.getRebirths(player)
	end
end

-- Load a player's rebirth count when they join, defaulting to zero.
local function onPlayerAdded(player)
	cash[player.UserId] = BrainrotData.Economy.startCash
	rebirths[player.UserId] = 0
	makeLeaderstats(player)
	local ds = getStore()
	if ds ~= nil then
		local ok, saved = pcall(function()
			return ds:GetAsync(tostring(player.UserId))
		end)
		if ok and typeof(saved) == "number" then
			rebirths[player.UserId] = saved
		end
	end
	MoneyService.sync(player)
end

-- Save a player's rebirth count and drop their state when they leave.
local function onPlayerRemoving(player)
	local ds = getStore()
	if ds ~= nil then
		pcall(function()
			ds:SetAsync(tostring(player.UserId), rebirths[player.UserId] or 0)
		end)
	end
	cash[player.UserId] = nil
	rebirths[player.UserId] = nil
end

-- Pay every player their income once a second.
local function payLoop()
	while true do
		task.wait(1)
		for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
			local income = MoneyService.getIncomePerSecond(player)
			if income > 0 then
				MoneyService.earn(player, income)
			else
				MoneyService.sync(player)
			end
		end
	end
end

-- Hook players and start the pay loop.
function MoneyService.init(deps)
	services = deps
	-- The client buys a rebirth through this remote.
	local rebirthRemote = Instance.new("RemoteEvent")
	rebirthRemote.Name = "Rebirth"
	rebirthRemote.Parent = game:GetService("ReplicatedStorage")
	rebirthRemote.OnServerEvent:Connect(function(player)
		MoneyService.rebirth(player)
	end)
	local players = game:GetService("Players")
	players.PlayerAdded:Connect(onPlayerAdded)
	players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in ipairs(players:GetPlayers()) do
		onPlayerAdded(player)
	end
	task.spawn(payLoop)
end

return MoneyService
