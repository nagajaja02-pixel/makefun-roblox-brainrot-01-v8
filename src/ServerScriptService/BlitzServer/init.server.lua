local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(script.World)
local Base = require(script.BaseService)
local Shield = require(script.ShieldService)
local Money = require(script.MoneyService)
local Steal = require(script.StealService)
local Wave = require(script.WaveService)
local Conveyor = require(script.ConveyorService)
local Merchant = require(script.MerchantService)

local map = World.buildHarbor()
local bases = Base.build(map)
local states = {}
local function openRebirthStore()
	local ok, store = pcall(function()
		return DataStoreService:GetDataStore("BlitzRebirthsV1")
	end)
	return ok and store or nil
end
local rebirthStore
local storeAttempted = false
local feedback = Instance.new("RemoteEvent")
feedback.Name = "BlitzFeedback"
feedback.Parent = ReplicatedStorage
local rebirthRequest = Instance.new("RemoteEvent")
rebirthRequest.Name = "BlitzRebirth"
rebirthRequest.Parent = ReplicatedStorage

local function notify(player, text, style)
	if player.Parent == Players then
		feedback:FireClient(player, text, style)
	end
end

local function raidStand(player, victim, index, slot)
	if player == victim.player and states[player] == victim then
		Steal.pickupOwn(victim, index, slot, notify)
	else
		Steal.beginRaid(player, victim, index, slot, states, notify)
	end
end

local function upgradeBase(state)
	if state.level == 3 then
		notify(state.player, "All eight stands are open.", "warning")
		return
	end
	if not Money.spend(state, Money.upgradePrice(state)) then
		notify(state.player, "Save more cash to open two stands.", "warning")
		return
	end
	state.level += 1
	Base.refreshStands(state)
	Money.publish(state)
	notify(state.player, "Base expanded. Two more income stands are open.", "success")
end

local function rebirthCollection(state)
	if state.carry then
		notify(state.player, "Deliver your brainrot before rebirthing.", "warning")
		return
	end
	for _, slot in pairs(state.slots) do
		if slot.inTransit then
			notify(state.player, "Wait until the active raid is resolved.", "warning")
			return
		end
	end
	if state.cash < Money.rebirthPrice(state) then
		notify(state.player, "Save more cash to rebirth.", "warning")
		return
	end
	local rebirths = state.rebirths + 1
	if rebirthStore then
		state.savingRebirth = true
		local ok, saved = pcall(function()
			return rebirthStore:UpdateAsync(tostring(state.player.UserId), function(previous)
				return math.max(tonumber(previous) or 0, rebirths)
			end)
		end)
		state.savingRebirth = false
		if states[state.player] ~= state then
			return
		end
		if not ok then
			notify(state.player, "Rebirth save unavailable. Your crew and cash are safe.", "warning")
			return
		end
		rebirths = saved
	end
	state.rebirths = rebirths
	state.cash = Base.startingCash
	Base.clearCollection(state)
	Money.publish(state)
	notify(state.player, "Reborn! Added +50% income.", "success")
end

rebirthRequest.OnServerEvent:Connect(function(player)
	local state = states[player]
	if state and state.ready and not state.savingRebirth and World.aliveRoot(player) then
		rebirthCollection(state)
	end
end)

for _, base in ipairs(bases) do
	for index, terminal in ipairs(base.controls) do
		local action = ({ "Raise 26s shield", "Buy two stands" })[index]
		World.prompt(terminal, action, terminal.Name, 0.25).Triggered:Connect(function(player)
			local state = states[player]
			if not state or state.savingRebirth or state.base ~= base or not World.near(player, terminal) then
				return
			end
			if index == 1 then
				local now = workspace:GetServerTimeNow()
				if now >= state.lockReady then
					Shield.activate(state, now)
					notify(player, "Shield up. Raiders are blocked for 26 seconds.", "success")
				else
					notify(player, string.format("Shield ready in %ds.", math.ceil(state.lockReady - now)), "warning")
				end
			else
				upgradeBase(state)
			end
		end)
	end
end

local function assignSafehouse(player)
	if not storeAttempted then
		storeAttempted = true
		rebirthStore = openRebirthStore()
	end
	if states[player] then
		return
	end
	local base
	for _, candidate in ipairs(bases) do
		if not candidate.owner then
			base = candidate
			break
		end
	end
	if not base then
		player:Kick("This harbor has six safehouses. Join another server for a free plot.")
		return
	end
	base.owner = player
	local state = { player = player, base = base, slots = {}, cash = Base.startingCash, rate = 0, level = 1, rebirths = 0 }
	states[player] = state
	player:SetAttribute("Carrying", "")
	player:SetAttribute("Home", base.entrance)
	player.RespawnLocation = nil
	local function trackShieldCharacter(character)
		if state.releaseShieldCharacter then
			state.releaseShieldCharacter()
		end
		state.releaseShieldCharacter = Shield.trackCharacter(character, base.ownerCollisionGroup)
	end
	if player.Character then
		trackShieldCharacter(player.Character)
	end
	Shield.activate(state, workspace:GetServerTimeNow())
	Base.refreshStands(state)
	Money.publish(state)

	state.characterAdded = player.CharacterAdded:Connect(function(character)
		trackShieldCharacter(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			if state.carry then
				Steal.returnRaid(state, states, raidStand, notify)
			end
			task.delay(3, function()
				if states[player] == state then
					player:LoadCharacter()
				end
			end)
		end)
		character:WaitForChild("HumanoidRootPart")
		if states[player] == state and player.Character == character then
			character:PivotTo(base.frame * CFrame.new(0, 4.5, 0))
		end
	end)
	if rebirthStore then
		local ok, saved = pcall(function()
			return rebirthStore:GetAsync(tostring(player.UserId))
		end)
		if states[player] ~= state then
			return
		end
		if ok then
			state.rebirths = tonumber(saved) or 0
			Money.publish(state)
		end
	end
	state.ready = true
	player:LoadCharacter()
end

Players.PlayerAdded:Connect(assignSafehouse)
Players.PlayerRemoving:Connect(function(player)
	local state = states[player]
	if not state then
		return
	end
	if state.carry then
		Steal.returnRaid(state, states, raidStand, notify)
	end
	Base.clearCollection(state)
	state.base.owner = nil
	Shield.clear(state.base)
	state.characterAdded:Disconnect()
	if state.releaseShieldCharacter then
		state.releaseShieldCharacter()
	end
	for _, stand in ipairs(state.base.stands) do
		stand.Color = World.steel
	end
	states[player] = nil
end)

require(script.CollectionService).start()
require(script.BatService).start(states, raidStand, notify)

local conveyor = Conveyor.new(map, states, notify)
local wave = Wave.new(map)
Merchant.build(map, states, notify)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(assignSafehouse, player)
end

local incomeClock = 0
local movementClock = 0
RunService.Heartbeat:Connect(function(dt)
	local now = workspace:GetServerTimeNow()
	incomeClock += dt
	while incomeClock >= 1 do
		incomeClock -= 1
		Money.payIncome(states)
	end
	movementClock += dt
	if movementClock < 1 / 24 then
		return
	end
	conveyor:step(movementClock, now)
	movementClock = 0
	wave:step(now, states, notify)
	for player, state in pairs(states) do
		Shield.update(state, now)
		local root = World.aliveRoot(player)
		if state.carry and root then
			if Base.isSheltered(state.base, root.Position) then
				if not state.carry.waitForExit then
					Steal.deliverCarry(state, raidStand, notify)
				end
			else
				state.carry.waitForExit = false
			end
		end
	end
end)
