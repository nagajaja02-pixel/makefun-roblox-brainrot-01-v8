-- BrainrotData: the shared catalogue for Brainrot Blitz.
-- Both the server and the client require this module, so it holds no state:
-- only the character list, the mutation rules, the economy numbers, and a
-- few pure helpers every other system can call without side effects.

local BrainrotData = {}

-- The thirteen characters, cheapest first. Five rarities, prices and income
-- climbing steeply so the late game still feels like a climb. Each entry
-- carries the colours its 3D model is built from and a one-line caption the
-- model builder shows on its name label.
BrainrotData.Characters = {
	{ id = "sahur", name = "Tung Tung Tung Sahur", tier = "Common", price = 50, income = 2,
		body = Color3.fromRGB(139, 94, 52), accent = Color3.fromRGB(92, 58, 28),
		caption = "A log that knocks three times.", trait = "log" },
	{ id = "boneca", name = "Boneca Ambalabu", tier = "Common", price = 80, income = 3,
		body = Color3.fromRGB(244, 164, 196), accent = Color3.fromRGB(190, 90, 140),
		caption = "A little doll with a big stare.", trait = "doll" },
	{ id = "trippi", name = "Trippi Troppi", tier = "Common", price = 120, income = 5,
		body = Color3.fromRGB(64, 180, 190), accent = Color3.fromRGB(30, 120, 130),
		caption = "Three fins, one mission.", trait = "fish" },
	{ id = "lirili", name = "Lirili Larila", tier = "Rare", price = 260, income = 11,
		body = Color3.fromRGB(120, 190, 90), accent = Color3.fromRGB(70, 130, 50),
		caption = "A cactus that hums in the sun.", trait = "cactus" },
	{ id = "frigo", name = "Frigo Camelo", tier = "Rare", price = 420, income = 17,
		body = Color3.fromRGB(170, 210, 235), accent = Color3.fromRGB(90, 140, 180),
		caption = "Cold on the outside, cool inside.", trait = "fridge" },
	{ id = "chimpanzini", name = "Chimpanzini Bananini", tier = "Rare", price = 650, income = 26,
		body = Color3.fromRGB(250, 215, 90), accent = Color3.fromRGB(200, 150, 40),
		caption = "Half chimp, half banana, all chaos.", trait = "banana" },
	{ id = "patapim", name = "Brr Brr Patapim", tier = "Epic", price = 950, income = 38,
		body = Color3.fromRGB(150, 200, 250), accent = Color3.fromRGB(80, 130, 200),
		caption = "Shivers when it walks.", trait = "ice" },
	{ id = "ballerina", name = "Ballerina Cappuccina", tier = "Epic", price = 1500, income = 60,
		body = Color3.fromRGB(210, 150, 100), accent = Color3.fromRGB(150, 90, 60),
		caption = "Dances on espresso.", trait = "dancer" },
	{ id = "assassino", name = "Cappuccino Assassino", tier = "Epic", price = 2200, income = 88,
		body = Color3.fromRGB(80, 55, 40), accent = Color3.fromRGB(40, 25, 18),
		caption = "Silent, foamy, deadly.", trait = "assassin" },
	{ id = "orangutini", name = "Orangutini Ananasini", tier = "Legendary", price = 3400, income = 135,
		body = Color3.fromRGB(245, 170, 60), accent = Color3.fromRGB(200, 120, 30),
		caption = "An orangutan in a pineapple suit.", trait = "pineapple" },
	{ id = "vaca", name = "La Vaca Saturno Saturnita", tier = "Legendary", price = 5200, income = 210,
		body = Color3.fromRGB(170, 130, 220), accent = Color3.fromRGB(110, 70, 160),
		caption = "A cow with rings like Saturn.", trait = "cow" },
	{ id = "tralalero", name = "Tralalero Tralala", tier = "Mythic", price = 8500, income = 340,
		body = Color3.fromRGB(70, 130, 220), accent = Color3.fromRGB(30, 70, 150),
		caption = "Three legs, one shark, endless song.", trait = "shark" },
	{ id = "bombardiro", name = "Bombardiro Crocodilo", tier = "Mythic", price = 12500, income = 500,
		body = Color3.fromRGB(90, 160, 80), accent = Color3.fromRGB(50, 100, 45),
		caption = "A crocodile that drops in from the sky.", trait = "croc" },
}

-- Rarity order, cheapest tier first. Used by the index menu and by the
-- conveyor when it weights which character to spawn.
BrainrotData.Tiers = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Divine", "Celestial" }

-- Original harbor creatures extend the catalogue without replacing existing entries.
local additions = {
	{id = "pebble_pogo", name = "Pebble Pogo", tier = "Common", price = 150, income = 6, design = 1},
	{id = "noodle_narwhal", name = "Noodle Narwhal", tier = "Common", price = 168, income = 6, design = 2},
	{id = "waffle_wisp", name = "Waffle Wisp", tier = "Common", price = 186, income = 7, design = 3},
	{id = "mango_mantis", name = "Mango Mantis", tier = "Common", price = 204, income = 8, design = 4},
	{id = "bubble_badger", name = "Bubble Badger", tier = "Rare", price = 700, income = 28, design = 5},
	{id = "pickle_pilot", name = "Pickle Pilot", tier = "Rare", price = 784, income = 31, design = 6},
	{id = "jelly_juggler", name = "Jelly Juggler", tier = "Rare", price = 868, income = 34, design = 7},
	{id = "taffy_turtle", name = "Taffy Turtle", tier = "Rare", price = 952, income = 38, design = 8},
	{id = "cobalt_crab", name = "Cobalt Crab", tier = "Epic", price = 2400, income = 96, design = 9},
	{id = "velvet_volcano", name = "Velvet Volcano", tier = "Epic", price = 2688, income = 107, design = 10},
	{id = "marble_moth", name = "Marble Moth", tier = "Epic", price = 2976, income = 119, design = 11},
	{id = "copper_comet", name = "Copper Comet", tier = "Epic", price = 3264, income = 130, design = 12},
	{id = "prism_penguin", name = "Prism Penguin", tier = "Legendary", price = 5600, income = 224, design = 13},
	{id = "orbit_otter", name = "Orbit Otter", tier = "Legendary", price = 6272, income = 250, design = 14},
	{id = "ember_egret", name = "Ember Egret", tier = "Legendary", price = 6944, income = 277, design = 15},
	{id = "glacier_gecko", name = "Glacier Gecko", tier = "Legendary", price = 7616, income = 304, design = 16},
	{id = "nova_newt", name = "Nova Newt", tier = "Mythic", price = 13000, income = 520, design = 17},
	{id = "quantum_quokka", name = "Quantum Quokka", tier = "Mythic", price = 14560, income = 582, design = 18},
	{id = "eclipse_elk", name = "Eclipse Elk", tier = "Mythic", price = 16120, income = 644, design = 19},
	{id = "nebula_nautilus", name = "Nebula Nautilus", tier = "Mythic", price = 17680, income = 707, design = 20},
	{id = "solar_salamander", name = "Solar Salamander", tier = "Secret", price = 30000, income = 1200, design = 21},
	{id = "aurora_axolotl", name = "Aurora Axolotl", tier = "Secret", price = 33600, income = 1344, design = 22},
	{id = "stardust_stag", name = "Stardust Stag", tier = "Secret", price = 37200, income = 1488, design = 23},
	{id = "lunar_lynx", name = "Lunar Lynx", tier = "Divine", price = 108800, income = 4352, design = 24},
	{id = "infinity_ibis", name = "Infinity Ibis", tier = "Divine", price = 80000, income = 3200, design = 25},
	{id = "zenith_zebra", name = "Zenith Zebra", tier = "Divine", price = 89600, income = 3584, design = 26},
	{id = "celestial_seraph", name = "Celestial Seraph", tier = "Celestial", price = 297600, income = 11904, design = 27},
}
BrainrotData.TierWeights = {Common=1, Rare=0.6, Epic=0.35, Legendary=0.18, Mythic=0.08, Secret=0.025, Divine=0.008, Celestial=0.002}
BrainrotData.TierColors = {
 Common=Color3.fromRGB(158,190,170), Rare=Color3.fromRGB(70,170,255), Epic=Color3.fromRGB(185,100,255),
 Legendary=Color3.fromRGB(255,194,60), Mythic=Color3.fromRGB(255,85,120), Secret=Color3.fromRGB(95,255,195),
 Divine=Color3.fromRGB(255,240,170), Celestial=Color3.fromRGB(150,185,255),
}
for _, char in ipairs(additions) do
 char.body = Color3.fromHSV((char.design * 0.137) % 1, 0.55, 0.85)
 char.accent = BrainrotData.TierColors[char.tier]
 char.caption = "A curious visitor from beyond the harbor."
 table.insert(BrainrotData.Characters, char)
end
local totalWeight = 0
for _, char in ipairs(BrainrotData.Characters) do
 char.spawnWeight = BrainrotData.TierWeights[char.tier]
 totalWeight += char.spawnWeight
end
for _, char in ipairs(BrainrotData.Characters) do char.spawnChance = char.spawnWeight / totalWeight end
function BrainrotData.pickCharacter(roll, luck)
 local total = 0
 local function weight(char)
  return char.spawnWeight * ((char.tier ~= "Common" and char.tier ~= "Rare") and (luck or 1) or 1)
 end
 for _, char in ipairs(BrainrotData.Characters) do total += weight(char) end
 local cursor = math.clamp(roll, 0, 0.999999999) * total
 for _, char in ipairs(BrainrotData.Characters) do
  cursor -= weight(char)
  if cursor < 0 then return char end
 end
 return BrainrotData.Characters[1]
end

-- Mutation: a small slice of spawns comes out Diamond (three times the
-- income) and a slightly bigger slice comes out Gold (twice the income).
-- The rest are normal.
BrainrotData.Mutation = {
	goldChance = 0.07,
	diamondChance = 0.02,
	goldMult = 2,
	diamondMult = 3,
}

-- The economy every system shares.
BrainrotData.Economy = {
	startCash = 150,
	startStands = 4,
	maxStands = 8,
	upgradeBase = 100,
	sellFraction = 0.5,
	rebirthBase = 12000,
	rebirthBoost = 0.5,
	rebirthStore = "BlitzRebirthsV1",
}

-- The conveyor belt: where it runs, how fast, how often a new character
-- rolls out.
BrainrotData.Conveyor = {
	spawnInterval = 3.5,
	speed = 4.2,
	startX = -131,
	endX = 131,
}

-- The tsunami rhythm: first wave, warning window, sweep length, gap.
BrainrotData.Wave = {
	firstAt = 52,
	warnTime = 14,
	sweepTime = 8,
	gap = 54,
}

-- The shield: how long it holds, then how long before it can rise again.
BrainrotData.Shield = {
	duration = 26,
	cooldown = 48,
}

-- The six safehouse plots: three on each side of the conveyor, at the
-- island's left, centre and right.
BrainrotData.Bases = {
	{ x = -82, z = -51 },
	{ x = 0, z = -51 },
	{ x = 82, z = -51 },
	{ x = -82, z = 51 },
	{ x = 0, z = 51 },
	{ x = 82, z = 51 },
}

-- Look a character up by its id. Returns nil for an unknown id.
function BrainrotData.byId(id)
	for _, char in ipairs(BrainrotData.Characters) do
		if char.id == id then
			return char
		end
	end
	return nil
end

-- Roll a mutation for a fresh spawn. Diamond is the rarest, Gold the next.
function BrainrotData.rollMutation()
	local roll = math.random()
	if roll < BrainrotData.Mutation.diamondChance then
		return "Diamond"
	elseif roll < BrainrotData.Mutation.diamondChance + BrainrotData.Mutation.goldChance then
		return "Gold"
	end
	return "Normal"
end

-- The income a character actually pays out, mutation included.
function BrainrotData.mutationIncome(char, mutation)
	if mutation == "Diamond" then
		return char.income * BrainrotData.Mutation.diamondMult
	elseif mutation == "Gold" then
		return char.income * BrainrotData.Mutation.goldMult
	end
	return char.income
end

-- What the next stand costs. The price climbs with the square of the
-- stands the player already owns, so late stands are a real decision.
function BrainrotData.upgradeCost(stands)
	return BrainrotData.Economy.upgradeBase * stands * stands
end

-- What the next rebirth costs: a flat base times one more than the
-- rebirths the player already has.
function BrainrotData.rebirthCost(rebirths)
	return BrainrotData.Economy.rebirthBase * (rebirths + 1)
end

-- What a character sells for: half what it cost to buy.
function BrainrotData.sellPrice(price)
	return math.floor(price * BrainrotData.Economy.sellFraction)
end

return BrainrotData
