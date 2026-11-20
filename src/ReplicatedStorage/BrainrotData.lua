local Data = {}

Data.rarities = {
	{ name = "Common", color = Color3.fromRGB(126, 249, 182), weight = 52 },
	{ name = "Rare", color = Color3.fromRGB(103, 202, 255), weight = 26 },
	{ name = "Epic", color = Color3.fromRGB(215, 143, 255), weight = 14 },
	{ name = "Legendary", color = Color3.fromRGB(255, 191, 80), weight = 6 },
	{ name = "Mythic", color = Color3.fromRGB(255, 112, 158), weight = 2 },
}

-- Name, tier, price, income, silhouette, body color, caption.
Data.cast = {
	{ "Tung Tung Tung Sahur", 1, 40, 4, "sahur", Color3.fromRGB(176, 105, 56), "Midnight drummer" },
	{ "Boneca Ambalabu", 1, 65, 7, "boneca", Color3.fromRGB(103, 204, 99), "One-wheel frog" },
	{ "Trippi Troppi", 1, 90, 10, "trippi", Color3.fromRGB(243, 139, 99), "Shrimp-tail cat" },
	{ "Lirili Larila", 2, 190, 22, "lirili", Color3.fromRGB(82, 171, 114), "Desert explorer" },
	{ "Frigo Camelo", 2, 330, 39, "frigo", Color3.fromRGB(174, 221, 233), "Cold cargo" },
	{ "Chimpanzini Bananini", 2, 490, 58, "banana", Color3.fromRGB(246, 196, 59), "Banana bunch" },
	{ "Brr Brr Patapim", 3, 850, 103, "patapim", Color3.fromRGB(98, 151, 67), "Forest wanderer" },
	{ "Ballerina Cappuccina", 3, 1350, 170, "ballerina", Color3.fromRGB(243, 129, 168), "Porcelain pirouette" },
	{ "Cappuccino Assassino", 3, 2100, 275, "assassino", Color3.fromRGB(90, 77, 110), "Silent espresso" },
	{ "Orangutini Ananasini", 4, 3700, 510, "ananasini", Color3.fromRGB(231, 157, 51), "Pineapple crown" },
	{ "Tralalero Tralala", 4, 5600, 820, "tralalero", Color3.fromRGB(80, 158, 197), "Three fresh kicks" },
	{ "Bombardiro Crocodilo", 5, 9500, 1550, "bombardiro", Color3.fromRGB(106, 141, 115), "Crocodile airframe" },
	{ "La Vaca Saturno Saturnita", 5, 14500, 2500, "saturnita", Color3.fromRGB(170, 134, 221), "Orbital cow" },
	{ "Roti Roda Rotini", 1, 110, 12, "toast", Color3.fromRGB(221, 155, 83), "Breakfast on wheels" },
	{ "Donat Bebek Dondoni", 1, 125, 14, "donut", Color3.fromRGB(248, 151, 187), "Quacking sprinkles" },
	{ "Sushi Kucing Susini", 1, 145, 16, "sushi", Color3.fromRGB(245, 123, 107), "Purring rice roll" },
	{ "Sandal Pisang Plokplok", 1, 165, 18, "sandal", Color3.fromRGB(232, 211, 67), "Slippery footsteps" },
	{ "Radio Kodok Ribbitini", 2, 240, 28, "radio", Color3.fromRGB(89, 194, 178), "Pond FM live" },
	{ "Payung Penguin Pingpung", 2, 380, 45, "umbrella", Color3.fromRGB(104, 150, 229), "Rainproof waddler" },
	{ "Jamur Jerapah Jambulini", 2, 570, 68, "mushroom", Color3.fromRGB(226, 98, 68), "Tall mushroom dreams" },
	{ "Bakso Roket Blasini", 3, 1050, 130, "rocket", Color3.fromRGB(195, 129, 95), "Soup space program" },
	{ "Gitar Gurita Jrengini", 3, 1650, 210, "guitar", Color3.fromRGB(166, 103, 218), "Eight-arm encore" },
	{ "Kaktus Koki Kriukini", 3, 2600, 340, "chef", Color3.fromRGB(95, 179, 120), "Prickly head chef" },
	{ "Nanas Naga Nganasini", 4, 4200, 600, "dragon", Color3.fromRGB(235, 175, 52), "Fruit-breath dragon" },
	{ "Televisi Merak Glitchini", 4, 6500, 980, "tv", Color3.fromRGB(78, 174, 199), "Peacock prime time" },
	{ "Piano Kepiting Klaklini", 4, 7800, 1170, "piano", Color3.fromRGB(202, 84, 93), "Sideways concerto" },
	{ "Bulan Badak Bumbum", 5, 17000, 3000, "moon", Color3.fromRGB(144, 161, 216), "Lunar horn patrol" },
	{ "Komodo Kosmik Komedini", 5, 21000, 3800, "comet", Color3.fromRGB(101, 210, 194), "Tail of stardust" },
	{ "Mahkota Ubur Uberini", 5, 26000, 4800, "jelly", Color3.fromRGB(219, 117, 221), "Royal jelly parade" },
	{ "Galaksi Angsa Gonggini", 5, 32000, 6200, "galaxy", Color3.fromRGB(117, 103, 221), "Honk beyond infinity" },
}

Data.mutations = require(script.Parent.MutationData)
function Data.mutate(unit, name)
	assert(name == "" or Data.mutations[name], "Unknown mutation")
	unit.mutation = name
	local multiplier = Data.mutations[name] and Data.mutations[name].multiplier or 1
	unit.rate = unit.entry[4] * multiplier
	unit.price = math.floor(unit.entry[3] * (1 + (multiplier - 1) * 0.35))
	return unit
end
function Data.create(index, allowMutation)
	local entry = Data.cast[index]
	local mutation = ""
	if allowMutation then
		local roll = math.random(10000)
		for _, name in ipairs({"Celestial", "Cosmic", "Poison", "Electric", "Rainbow", "Diamond", "Gold"}) do
			roll -= Data.mutations[name].chance
			if roll <= 0 then mutation = name; break end
		end
		if Data.eventMutation and math.random() < (Data.eventChance or 0.4) then mutation = Data.eventMutation end
	end
	local multiplier = Data.mutations[mutation] and Data.mutations[mutation].multiplier or 1
	return {
		entry = entry,
		rarity = Data.rarities[entry[2]],
		mutation = mutation,
		price = math.floor(entry[3] * (1 + (multiplier - 1) * 0.35)),
		rate = entry[4] * multiplier,
	}
end

function Data.randomOffer()
	local roll = math.random(100)
	for tier, rarity in ipairs(Data.rarities) do
		roll -= rarity.weight
		if roll <= 0 then
			local candidates = {}
			for index, entry in ipairs(Data.cast) do
				if entry[2] == tier then
					table.insert(candidates, index)
				end
			end
			return Data.create(candidates[math.random(#candidates)], true)
		end
	end
end

return Data
