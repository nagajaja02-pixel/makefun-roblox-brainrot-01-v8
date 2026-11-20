local Money = {}

function Money.capacity(state)
	return 4 + (state.level - 1) * 2
end

function Money.upgradePrice(state)
	return 550 * state.level ^ 2
end

function Money.rebirthPrice(state)
	return 12000 * (state.rebirths + 1)
end

function Money.publish(state)
	local rawRate = 0
	for _, slot in pairs(state.slots) do
		if not slot.inTransit then
			rawRate += slot.unit.rate
		end
	end
	state.rate = math.floor(rawRate * (1 + 0.5 * state.rebirths))
	local player = state.player
	player:SetAttribute("Cash", state.cash)
	player:SetAttribute("Rate", state.rate)
	player:SetAttribute("Capacity", Money.capacity(state))
	player:SetAttribute("Level", state.level)
	player:SetAttribute("Rebirths", state.rebirths)
	player:SetAttribute("UpgradePrice", Money.upgradePrice(state))
	player:SetAttribute("RebirthPrice", Money.rebirthPrice(state))
end

function Money.spend(state, price)
	if state.cash < price then
		return false
	end
	state.cash -= price
	return true
end

function Money.payIncome(states)
	for _, state in pairs(states) do
		state.cash += state.rate
		state.player:SetAttribute("Cash", state.cash)
	end
end

return Money
