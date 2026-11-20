local World = require(script.Parent.World)
local Base = require(script.Parent.BaseService)
local Money = require(script.Parent.MoneyService)
local Models = require(script.Parent.BrainrotModels)
local Collection = require(script.Parent.CollectionService)
local Steal = {}

local function weld(parent, part0, part1)
	local joint = Instance.new("WeldConstraint")
	joint.Part0 = part0
	joint.Part1 = part1
	joint.Parent = parent
end

function Steal.startCarry(state, unit, source, sourceIndex)
	local root = World.aliveRoot(state.player)
	local model = Models.sculpt(workspace, unit, CFrame.new(), nil)
	local pivot = model.PrimaryPart
	model:PivotTo(root.CFrame * CFrame.new(0, 4.45, -0.35))
	for _, part in ipairs(model:GetChildren()) do
		if part:IsA("BasePart") then
			part.Massless = true
			if part ~= pivot then
				weld(pivot, pivot, part)
			end
			part.Anchored = false
		end
	end
	weld(pivot, root, pivot)
	if not source then Collection.record(state.player, unit) end
	local ownPickup = source == state
	state.carry = {
		unit = unit, source = source, sourceIndex = sourceIndex, model = model,
		waitForExit = ownPickup and Base.isSheltered(state.base, root.Position),
	}
	state.player:SetAttribute("SellPrice", math.floor(unit.price / 2))
	state.player:SetAttribute("Carrying", unit.entry[1])
end

function Steal.clearCarry(state)
	local carry = state.carry
	carry.model:Destroy()
	state.carry = nil
	state.player:SetAttribute("Carrying", "")
	state.player:SetAttribute("SellPrice", nil)
	return carry
end

function Steal.pickupOwn(state, index, slot, notify)
	if state.savingRebirth or state.carry or state.slots[index] ~= slot or slot.inTransit
		or not slot.model or not World.near(state.player, slot.model.PrimaryPart) then
		return
	end
	slot.inTransit = true
	slot.model:Destroy()
	slot.model = nil
	Steal.startCarry(state, slot.unit, state, index)
	Money.publish(state)
	notify(state.player, "Sell at the merchant, or leave and re-enter to install.", "success")
end

function Steal.returnRaid(state, states, onRaid, notify)
	local carry = Steal.clearCarry(state)
	local victim = carry.source
	if victim and states[victim.player] == victim then
		local index = carry.sourceIndex
		local slot = victim.slots[index]
		if slot and slot.inTransit then
			Base.parkUnit(victim, index, slot, onRaid)
			notify(victim.player, carry.unit.entry[1] .. " returned to your base.", "success")
		end
	elseif not victim then
		state.cash += carry.unit.price
		Money.publish(state)
	end
end

function Steal.beginRaid(player, victim, index, slot, states, notify)
	local thief = states[player]
	if not thief or thief.savingRebirth or victim.savingRebirth or thief == victim or states[victim.player] ~= victim
		or victim.slots[index] ~= slot or slot.inTransit or not slot.model or not World.near(player, slot.model.PrimaryPart) then
		return
	end
	if workspace:GetServerTimeNow() < victim.lockUntil then
		notify(player, "That safehouse is shielded.", "warning")
		return
	end
	if thief.carry or not Base.freeSlot(thief) then
		notify(player, "You need free hands and a free stand.", "warning")
		return
	end
	slot.inTransit = true
	slot.model:Destroy()
	slot.model = nil
	Money.publish(victim)
	Steal.startCarry(thief, slot.unit, victim, index)
	notify(player, "Raid started! Run back to your safehouse.", "success")
	notify(victim.player, player.DisplayName .. " grabbed " .. slot.unit.entry[1] .. "!", "warning")
end

local function removeSourceSlot(state, carry, notify)
	local source = carry.source
	if not source then
		return
	end
	local slot = source.slots[carry.sourceIndex]
	if slot and slot.inTransit then
		source.slots[carry.sourceIndex] = nil
		if source ~= state then
			Money.publish(source)
			notify(source.player, carry.unit.entry[1] .. " was stolen.", "warning")
		end
	end
end

function Steal.deliverCarry(state, onRaid, notify)
	local carry = state.carry
	local index = Base.freeSlot(state) or (carry.source == state and carry.sourceIndex)
	if not index then
		return
	end
	Steal.clearCarry(state)
	removeSourceSlot(state, carry, notify)
	Base.parkUnit(state, index, { unit = carry.unit }, onRaid)
	Collection.record(state.player, carry.unit)
	notify(state.player, string.format("%s installed  •  +$%d/s base rate", carry.unit.entry[1], carry.unit.rate), "success")
end

function Steal.sellCarry(state, notify)
	local carry = Steal.clearCarry(state)
	removeSourceSlot(state, carry, notify)
	local price = math.floor(carry.unit.price / 2)
	state.cash += price
	Money.publish(state)
	notify(state.player, string.format("Sold %s for $%d.", carry.unit.entry[1], price), "success")
end

return Steal
