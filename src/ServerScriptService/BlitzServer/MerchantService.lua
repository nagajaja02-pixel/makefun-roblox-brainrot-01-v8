local World = require(script.Parent.World)
local Steal = require(script.Parent.StealService)

local Merchant = {}

function Merchant.build(map, states, notify)
	local shop = Instance.new("Model")
	shop.Name = "Brainrot Shop"
	local frame = CFrame.new(41, 0, -16) * CFrame.Angles(0, math.pi, 0)
	local red = Color3.fromRGB(243, 90, 82)
	local cream = Color3.fromRGB(255, 231, 177)
	local green = Color3.fromRGB(37, 189, 144)
	local skin = Color3.fromRGB(210, 143, 91)

	local function part(parent, name, size, x, y, z, color)
		return World.part(parent, name, size, frame * CFrame.new(x, y, z), color)
	end

	part(shop, "Deck", Vector3.new(13, 0.28, 9), 0, 0.14, 0, cream)
	part(shop, "Rear wall", Vector3.new(12, 6, 0.4), 0, 3.25, 4, green)
	part(shop, "Roof", Vector3.new(14, 0.55, 10), 0, 6.8, 0, red)
	for _, x in ipairs({ -5.65, 5.65 }) do
		part(shop, "Front post", Vector3.new(0.5, 6.4, 0.5), x, 3.4, -3.65, green)
	end
	for index = -4, 4 do
		part(shop, "Awning trim", Vector3.new(1.5, 0.45, 0.4), index * 1.5, 6.3, -4.8, index % 2 == 0 and red or cream)
	end
	part(shop, "Counter base", Vector3.new(10, 2.2, 1.5), 0, 1.38, -2.8, green)
	local counter = part(shop, "Counter", Vector3.new(10.5, 0.3, 1.9), 0, 2.62, -2.8, cream)
	local sign = part(shop, "Fascia", Vector3.new(10.2, 1.55, 0.3), 0, 7.35, -4.95, World.ink)
	World.surfaceSign(sign, "BRAINROT SHOP", World.gold)

	local npc = Instance.new("Model")
	npc.Name = "Merchant"
	npc.Parent = shop
	part(npc, "Apron", Vector3.new(1.65, 1.75, 0.8), 0, 2.63, -0.55, World.gold)
	local head = part(npc, "Head", Vector3.new(1.1, 1.1, 1), 0, 4, -0.55, skin)
	part(npc, "Cap", Vector3.new(1.55, 0.27, 1.3), 0, 4.57, -0.65, red)
	part(npc, "Smile", Vector3.new(0.36, 0.08, 0.05), 0, 3.79, -1.06, World.ink)
	for _, side in ipairs({ -1, 1 }) do
		part(npc, "Eye", Vector3.new(0.12, 0.15, 0.05), side * 0.24, 4.1, -1.06, World.ink)
		part(npc, "Arm", Vector3.new(0.38, 1.44, 0.48), side * 1.02, 2.72, -0.65, skin)
		part(npc, "Leg", Vector3.new(0.56, 1.5, 0.65), side * 0.43, 1.03, -0.55, World.ink)
	end
	World.sign(head, "MERCHANT", World.white, 128, 26, Vector3.new(0, 1.25, 0), 54)

	local prompt = World.prompt(counter, "Sell brainrot", "Merchant", 0.35)
	prompt.Name = "SellBrainrot"
	prompt.Triggered:Connect(function(player)
		local state = states[player]
		if state and state.carry and not state.savingRebirth and World.near(player, counter) then
			Steal.sellCarry(state, notify)
		end
	end)
	shop.Parent = map
end

return Merchant
