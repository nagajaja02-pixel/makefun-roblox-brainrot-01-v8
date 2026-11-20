local World = require(script.Parent.World)
local Models = {}

local rgb = Color3.fromRGB
local ink, ivory, gold = World.ink, World.white, World.gold
local silver = rgb(177, 202, 213)
local rose = rgb(244, 96, 110)
local black = rgb(0, 0, 0)
local green = rgb(117, 255, 103)
local brown = rgb(113, 65, 42)
local ball = Enum.PartType.Ball
local tube = Enum.PartType.Cylinder
local neon = Enum.Material.Neon

-- The sculpts face -Z and share a floor plane. Cylinders run along local X.
local cast = {}

cast.sahur = function(p, face, hue)
	p("Carved timber", 1.48, 2.72, 1.3, 0, 2.17, 0, hue)
	p("End grain", 1.3, 0.12, 1.12, 0, 3.57, 0, brown)
	for _, side in ipairs({ -1, 1 }) do
		p("Wood grain", 0.07, 1.54, 0.04, side * 0.59, 1.87, -0.66, brown, nil, side * 0.08)
		p("Arm", 0.27, 1.22, 0.32, side * 0.91, 1.62, 0, hue, ball, side * 0.34)
		p("Leg", 0.31, 0.94, 0.37, side * 0.43, 0.63, 0, hue)
		p("Foot", 0.5, 0.31, 0.76, side * 0.43, 0.17, -0.17, hue, ball)
	end
	p("Drum beater", 0.27, 1.75, 0.27, 1.42, 1.45, -0.23, brown, nil, 0.48)
	p("Beater head", 0.48, 0.65, 0.5, 1.03, 2.24, -0.23, gold, ball, 0.48)
	face(0, 2.69, -0.66, 0.34, 0.74, 0.03, 0.23, 0.35)
end

cast.boneca = function(p, face, hue)
	p("Tire", 0.85, 2.08, 2.08, 0, 1.56, 0, ink, tube).Orientation = Vector3.new(0, 90, 0)
	p("Rim", 0.22, 1.18, 1.18, 0, 1.56, -0.44, silver, tube).Orientation = Vector3.new(0, 90, 0)
	p("Frog head", 2.17, 1.15, 1.35, 0, 2.65, -0.15, hue, ball)
	for _, side in ipairs({ -1, 1 }) do
		p("Eye bulge", 0.8, 0.8, 0.7, side * 0.55, 3.08, -0.45, hue, ball)
		p("Long leg", 0.36, 1.22, 0.39, side * 0.79, 0.73, -0.02, rgb(215, 162, 118), ball, side * 0.27)
		p("Foot", 0.56, 0.29, 0.78, side * 0.96, 0.16, -0.21, rgb(215, 162, 118), ball)
	end
	face(0, 2.98, -0.81, 0.54, 0.83, -0.03, 0.1, 0.21)
end

cast.trippi = function(p, face, hue)
	for step = 0, 4 do
		local size = 1.45 - step * 0.19
		p("Shrimp segment", size, size * 0.78, 0.87, 0, 0.73 + step * step * 0.065,
			-0.26 + step * 0.43, hue:Lerp(rose, step * 0.14), ball)
	end
	p("Cat head", 1.74, 1.4, 1.3, 0, 1.72, -0.76, ivory, ball)
	for _, side in ipairs({ -1, 1 }) do
		p("Pointed ear", 0.53, 0.63, 0.31, side * 0.59, 2.31, -0.79, hue, nil, side * 0.45)
		p("Tail fan", 0.59, 0.16, 0.85, side * 0.24, 1.94, 1.7, rose, ball, side * 0.32)
		p("Whisker", 0.48, 0.05, 0.06, side * 0.72, 1.57, -1.34, brown, nil, side * 0.18)
	end
	face(0, 1.86, -1.39, 0.37, 0.76, 0.05, 0.17, 0.24)
end

cast.lirili = function(p, face, hue)
	p("Cactus body", 1.59, 2.29, 1.34, 0, 1.65, 0, hue, ball)
	p("Elephant head", 1.55, 1.25, 1.34, 0, 2.84, -0.34, silver, ball)
	p("Trunk", 0.34, 1.13, 0.4, 0, 2.36, -1.05, silver, ball, -0.26)
	for _, side in ipairs({ -1, 1 }) do
		p("Elephant ear", 0.94, 1.19, 0.36, side * 0.84, 2.84, -0.27, silver, ball, side * 0.36)
		p("Cactus rib", 0.16, 1.22, 0.17, side * 0.39, 1.53, -0.54, hue:Lerp(ink, 0.25), ball)
		p("Sandal sole", 0.69, 0.19, 1.2, side * 0.49, 0.1, -0.22, brown)
		p("Sandal strap", 0.66, 0.2, 0.32, side * 0.49, 0.27, -0.39, gold)
		p("Foot", 0.56, 0.64, 0.83, side * 0.49, 0.43, -0.06, silver, ball)
	end
	face(0, 2.98, -0.98, 0.34, 0.66, -0.04, -0.12, 0.13)
end

cast.frigo = function(p, face, hue)
	p("Refrigerator", 1.73, 2.28, 1.39, 0, 1.63, 0.24, hue)
	p("Freezer door", 1.65, 0.61, 0.18, 0, 2.39, -0.5, ivory)
	p("Fridge door", 1.65, 1.43, 0.18, 0, 1.33, -0.5, ivory)
	p("Door handle", 0.11, 0.54, 0.14, -0.61, 1.6, -0.65, silver)
	p("Camel neck", 0.62, 1.56, 0.59, 0.47, 2.56, -0.55, gold, ball, -0.29)
	p("Camel head", 1.12, 0.88, 1.14, 0.59, 3.36, -0.71, gold, ball)
	p("Muzzle", 0.77, 0.47, 0.69, 0.59, 3.14, -1.18, brown, ball)
	for _, side in ipairs({ -1, 1 }) do
		p("Camel ear", 0.28, 0.44, 0.26, 0.59 + side * 0.35, 3.75, -0.66, gold, ball, side * 0.38)
		p("Work boot", 0.65, 0.47, 1.04, side * 0.55, 0.24, 0.02, brown, ball)
	end
	face(0.59, 3.47, -1.22, 0.22, 0.47, 0.02, -0.18, 0.14)
end

cast.banana = function(p, face, hue)
	p("Banana middle", 1.34, 2.26, 1.19, 0, 1.25, 0, hue, ball)
	p("Monkey head", 1.62, 1.43, 1.19, 0, 2.53, -0.15, brown, ball)
	p("Monkey muzzle", 1.02, 0.54, 0.53, 0, 2.23, -0.62, rgb(221, 158, 111), ball)
	for _, side in ipairs({ -1, 1 }) do
		p("Ear", 0.51, 0.59, 0.4, side * 0.77, 2.59, -0.17, brown, ball)
		p("Banana peel", 0.58, 1.65, 0.51, side * 0.67, 1.34, -0.31, hue, ball, side * 0.6)
		p("Monkey foot", 0.62, 0.3, 0.8, side * 0.44, 0.16, -0.16, brown, ball)
	end
	p("Banana stem", 0.25, 0.46, 0.3, 0, 0.28, 0.55, brown, ball, 0.43)
	face(0, 2.67, -0.71, 0.35, 0.74, 0.08, 0.22, 0.38)
end

cast.patapim = function(p, face, hue)
	p("Knotted trunk", 1.83, 2.45, 1.22, 0, 1.94, 0.11, brown, ball)
	p("Moss canopy", 2.52, 1.26, 1.52, 0, 3.28, 0.14, hue, ball)
	p("Long nose", 0.47, 0.48, 0.98, 0, 2.47, -0.76, gold, ball)
	for _, side in ipairs({ -1, 1 }) do
		p("Branch arm", 0.43, 1.64, 0.47, side * 1.06, 1.67, 0, brown, ball, side * 0.33)
		p("Moss tuft", 0.98, 0.63, 0.8, side * 0.91, 2.99, -0.25, hue, ball)
		p("Oversized root foot", 1.03, 0.59, 1.53, side * 0.68, 0.29, -0.45, brown, ball)
	end
	face(0, 2.72, -0.54, 0.44, 0.85, -0.08, 0.24, 0.17)
end

local function cup(p, y, hue)
	p("Porcelain cup", 1.08, 1.6, 1.45, 0, y, 0, hue, tube, math.pi / 2)
	p("Cup rim", 0.13, 1.69, 1.53, 0, y + 0.56, 0, ivory, tube, math.pi / 2)
	p("Coffee", 0.06, 1.46, 1.27, 0, y + 0.64, 0, brown, tube, math.pi / 2)
	p("Foam swirl", 0.06, 0.61, 0.4, 0.14, y + 0.68, -0.06, ivory, tube, math.pi / 2)
	for _, side in ipairs({ -1, 1 }) do
		p("Handle joint", 0.41, 0.17, 0.31, 0.84, y + side * 0.26, 0, hue)
	end
	p("Handle grip", 0.19, 0.61, 0.31, 1.08, y, 0, hue)
end

cast.ballerina = function(p, face, hue)
	cup(p, 3.07, ivory)
	p("Bodice", 1.14, 1.18, 0.75, 0, 1.97, 0, hue, ball)
	p("Tutu hem", 2.59, 0.33, 1.77, 0, 1.23, 0, hue, ball)
	p("Tutu top", 1.89, 0.42, 1.39, 0, 1.42, 0, hue:Lerp(ivory, 0.44), ball)
	for _, side in ipairs({ -1, 1 }) do
		p("Ballet arm", 0.27, 1.13, 0.27, side * 0.82, 2.03 + side * 0.28, 0, ivory, ball, side * -0.85)
		p("Ballet leg", 0.24, 1.13, 0.3, side * 0.36, 0.69, 0, ivory, ball, side * 0.29)
		p("Ribbon slipper", 0.34, 0.36, 0.61, side * 0.48, 0.18, -0.1, hue, ball)
	end
	face(0, 3.15, -0.72, 0.34, 0.7, 0.03, 0.02, 0.28)
end

cast.assassino = function(p, face, hue)
	cup(p, 2.55, hue)
	p("Ninja tunic", 1.29, 1.24, 0.78, 0, 1.16, 0, ink, ball)
	p("Headband", 1.58, 0.55, 0.21, 0, 2.66, -0.65, ink)
	p("Band tails", 0.73, 0.21, 0.17, -1.06, 2.62, -0.49, rose, nil, -0.28)
	for _, side in ipairs({ -1, 1 }) do
		p("Split-toe boot", 0.5, 0.52, 0.7, side * 0.44, 0.27, -0.12, hue, ball)
		p("Sleeve", 0.39, 0.85, 0.42, side * 0.84, 1.54, -0.06, ink, ball, side * 0.58)
		p("Foam blade", 0.18, 1.22, 0.13, side * 1.19, 1.98, -0.38, silver, nil, side * -0.36)
		p("Blade hilt", 0.48, 0.15, 0.22, side * 1.02, 1.52, -0.38, gold, nil, side * -0.36)
	end
	face(0, 2.7, -0.79, 0.31, 0.68, 0, -0.44, 0.13)
end

cast.ananasini = function(p, face, hue)
	p("Pineapple body", 1.86, 2.03, 1.45, 0, 1.33, 0, hue, ball)
	p("Orangutan head", 1.62, 1.35, 1.27, 0, 2.72, -0.17, rgb(180, 88, 42), ball)
	p("Face patch", 1.28, 0.96, 0.54, 0, 2.65, -0.66, gold, ball)
	for _, side in ipairs({ -1, 1 }) do
		p("Leaf crown", 0.32, 0.87, 0.33, side * 0.32, 3.48, 0, rgb(81, 174, 93), ball, -side * 0.55)
		p("Long ape arm", 0.55, 1.73, 0.56, side * 1.08, 1.22, 0, brown, ball, side * 0.28)
		p("Knuckles", 0.68, 0.43, 0.61, side * 1.29, 0.34, -0.1, brown, ball)
		for row = 0, 2 do
			p("Pineapple scale", 0.24, 0.27, 0.09, side * (0.29 + row % 2 * 0.16),
				0.89 + row * 0.34, -0.66, brown, nil, math.pi / 4)
		end
	end
	face(0, 2.77, -0.91, 0.33, 0.69, -0.045, 0.2, 0.35)
end

cast.tralalero = function(p, face, hue)
	p("Shark body", 1.79, 1.52, 3.18, 0, 1.54, 0.17, hue, ball)
	p("Pale belly", 1.57, 0.77, 2.82, 0, 1.25, 0.07, ivory, ball)
	p("Snout", 1.7, 0.92, 1.25, 0, 1.56, -1.22, hue, ball)
	p("Dorsal fin", 0.29, 1.05, 0.76, 0, 2.5, 0.15, hue, ball).Orientation = Vector3.new(-22, 0, 0)
	p("Tail fin", 0.36, 1.37, 0.8, 0, 1.72, 1.64, hue, ball).Orientation = Vector3.new(26, 0, 0)
	for _, side in ipairs({ -1, 1 }) do
		p("Side fin", 1.01, 0.25, 0.82, side * 0.91, 1.49, 0.09, hue, ball, side * -0.36)
	end
	for _, offset in ipairs({ Vector3.new(-0.66, 0, -0.56), Vector3.new(0.66, 0, -0.56), Vector3.new(0, 0, 0.97) }) do
		local x, z = offset.X, offset.Z
		p("Shark leg", 0.4, 0.91, 0.45, x, 0.69, z, hue, ball)
		p("Sneaker sole", 0.68, 0.2, 1.01, x, 0.13, z - 0.15, ivory, ball)
		p("Blue sneaker", 0.64, 0.39, 0.98, x, 0.34, z - 0.15, rgb(52, 102, 223), ball)
		p("Laces", 0.38, 0.06, 0.24, x, 0.52, z - 0.3, ivory)
	end
	face(0, 1.75, -1.78, 0.38, 0.68, 0.07, -0.12, 0.24)
end

cast.bombardiro = function(p, face, hue)
	p("Aircraft fuselage", 1.04, 1.1, 2.78, 0, 1.65, 0.54, silver, ball)
	p("Tail stabilizer", 1.56, 0.16, 0.57, 0, 1.98, 1.62, hue)
	p("Tail fin", 0.19, 0.78, 0.68, 0, 2.4, 1.56, hue, ball)
	p("Crocodile head", 1.33, 0.95, 1.4, 0, 1.84, -0.56, hue, ball)
	p("Long snout", 1.12, 0.47, 1.36, 0, 1.59, -1.25, hue, ball)
	p("Lower jaw", 1, 0.22, 1.18, 0, 1.36, -1.22, gold, ball)
	for _, side in ipairs({ -1, 1 }) do
		p("Wing", 1.76, 0.16, 0.93, side * 1.06, 1.71, 0.4, silver).Orientation = Vector3.new(0, side * -16, 0)
		p("Engine nacelle", 0.48, 0.46, 0.84, side * 1.15, 1.55, 0.16, hue, ball)
		p("Propeller", 0.91, 0.12, 0.09, side * 1.15, 1.54, -0.29, ink, nil, side * 0.58)
		p("Tooth", 0.14, 0.22, 0.16, side * 0.4, 1.47, -1.62, ivory, ball)
	end
	face(0, 2.05, -1.08, 0.33, 0.62, 0.05, -0.33, 0.15)
end

cast.saturnita = function(p, face, hue)
	p("Planet body", 2.09, 1.94, 1.84, 0, 1.69, 0.15, hue, ball)
	for i = 1, 20 do
		local angle = i * math.pi / 10
		p("Saturn ring", 0.55, 0.16, 0.51, math.cos(angle) * 1.61,
			1.76 + math.cos(angle) * 0.33, math.sin(angle) * 1.38 + 0.15, gold, ball)
	end
	p("Cow head", 1.47, 1.18, 1.02, 0, 2.73, -0.52, ivory, ball)
	p("Pink muzzle", 1.12, 0.52, 0.53, 0, 2.45, -1, rose, ball)
	p("Cow patch", 0.73, 0.46, 0.24, -0.44, 1.33, -0.57, ink, ball, 0.36)
	for _, side in ipairs({ -1, 1 }) do
		p("Cow ear", 0.62, 0.31, 0.4, side * 0.77, 2.9, -0.44, ink, ball, side * 0.34)
		p("Horn", 0.26, 0.54, 0.26, side * 0.43, 3.32, -0.39, gold, ball, -side * 0.32)
		p("Hoof", 0.48, 0.67, 0.54, side * 0.53, 0.34, -0.09, ink, ball)
	end
	face(0, 2.85, -1.04, 0.35, 0.67, 0.025, 0.04, 0.19)
end

-- Round 2 additions. Existing thirteen sculpts above remain unchanged.
cast.toast = function(p, face, hue)
 p("Toast crust",2,2.1,0.65,0,1.9,0,hue,nil)
 p("Bread center",1.65,1.75,0.16,0,1.95,-0.4,ivory)
 for _,side in ipairs({-1,1}) do p("Wheel",0.6,0.6,0.42,side*0.85,0.36,0,ink,ball) end
 p("Butter",0.65,0.3,0.15,0,2.65,-0.52,gold)
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.05,-0.8,0.3,0.62,0.02,0.12,0.26)
end

cast.donut = function(p, face, hue)
 for i=1,12 do local a=i*math.pi/6; p("Donut dough",0.65,0.65,0.7,math.cos(a)*0.73,1.8+math.sin(a)*0.73,0,gold,ball); p("Pink icing",0.58,0.56,0.18,math.cos(a)*0.73,1.8+math.sin(a)*0.73,-0.38,hue,ball) end
 p("Duck head",1.1,0.9,0.9,0,3,0,gold,ball)
 p("Duck bill",0.85,0.22,0.65,0,2.7,-0.55,rose)
 face(0,3.1,-0.46,0.3,0.62,0.02,0.12,0.26)
end

cast.sushi = function(p, face, hue)
 p("Seaweed roll",1.9,1.65,1.4,0,1.7,0,ink)
 p("Rice",1.75,0.25,1.3,0,2.6,0,ivory)
 p("Salmon topping",1.9,0.3,1.4,0,2.85,0,hue)
 for _,side in ipairs({-1,1}) do p("Cat ear",0.55,0.65,0.55,side*0.62,3.1,0,hue,nil,side*0.3); p("Whisker",0.6,0.06,0.08,side*0.8,1.6,-0.75,ivory) end
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.05,-0.8,0.3,0.62,0.02,0.12,0.26)
end

cast.sandal = function(p, face, hue)
 p("Banana sole",1.5,0.5,2.8,0,0.65,0,hue,ball)
 p("Sandal strap",1.6,0.5,0.4,0,1,-0.35,rose)
 p("Banana upright",0.85,2.4,0.8,0,2,0.6,hue,ball,-0.25)
 p("Banana tip",0.35,0.4,0.35,0.3,3.25,0.6,brown)
 face(0,2.3,0.15,0.3,0.62,0.02,0.12,0.26)
end

cast.radio = function(p, face, hue)
 p("Radio body",2.1,1.7,0.9,0,1.65,0,hue)
 p("Speaker",0.14,1,1,-0.5,1.5,-0.52,ink,tube,math.pi/2).Orientation=Vector3.new(0,90,0)
 for _,side in ipairs({-1,1}) do p("Frog eye mound",0.7,0.7,0.7,side*0.6,2.65,0,hue,ball) end
 p("Antenna",0.08,1.2,0.08,0.85,3,0,silver,nil,-0.3)
 p("Tuning dial",0.35,0.35,0.2,0.6,1.2,-0.55,gold,ball)
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.65,-0.36,0.3,0.62,0.02,0.12,0.26)
end

cast.umbrella = function(p, face, hue)
 p("Penguin body",1.5,2.2,1.3,0,1.6,0,ink,ball)
 p("White belly",1,1.5,0.3,0,1.4,-0.6,ivory,ball)
 p("Beak",0.6,0.3,0.6,0,2,-0.85,gold)
 p("Umbrella shaft",0.12,2.8,0.12,1.1,2,0,silver)
 for i=1,8 do local a=i*math.pi/4; p("Umbrella canopy",1.4,0.3,1.2,0.55+math.cos(a)*0.7,3.45,math.sin(a)*0.7,i%2==0 and hue or gold,ball) end
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.4,-0.6,0.3,0.62,0.02,0.12,0.26)
end

cast.mushroom = function(p, face, hue)
 p("Giraffe neck",0.65,2.3,0.7,0,1.8,0,gold)
 p("Giraffe muzzle",1.2,0.8,1.1,0,2.7,-0.2,gold,ball)
 p("Mushroom cap",2.5,0.9,1.9,0,3.35,0,hue,ball)
 for _,side in ipairs({-1,1}) do p("Cap spot",0.5,0.12,0.45,side*0.65,3.76,0,ivory,ball); p("Neck spot",0.2,0.3,0.08,side*0.2,1.6,-0.38,brown) end
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.8,-0.76,0.3,0.62,0.02,0.12,0.26)
end

cast.rocket = function(p, face, hue)
 p("Meatball",1.8,1.8,1.8,0,2,0,hue,ball)
 p("Rocket nose",0.9,1.1,0.9,0,3.1,0,silver,ball)
 p("Soup bowl",2.1,0.6,1.7,0,0.85,0,ivory,ball)
 for _,side in ipairs({-1,1}) do p("Rocket booster",0.45,1.6,0.55,side*1,1.6,0,silver); p("Flame",0.4,0.7,0.4,side*1,0.5,0,gold,ball) end
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.05,-0.8,0.3,0.62,0.02,0.12,0.26)
end

cast.guitar = function(p, face, hue)
 p("Octopus head",1.8,1.5,1.4,0,2.7,0,hue,ball)
 for i=1,8 do local a=i*math.pi/4; p("Tentacle",0.45,1.3,0.45,math.cos(a)*1.05,0.9,math.sin(a)*0.7,hue,ball,math.cos(a)*0.55) end
 p("Guitar body",1.4,1.5,0.4,0,1.4,-0.85,gold,ball)
 p("Guitar neck",0.3,1.6,0.25,0.55,2.2,-0.9,brown,nil,-0.45)
 for i=1,3 do p("String",0.025,1.2,0.03,(i-2)*0.12,1.5,-1.08,ivory) end
 face(0,2.8,-0.68,0.3,0.62,0.02,0.12,0.26)
end

cast.chef = function(p, face, hue)
 p("Cactus",1.5,2,1.25,0,1.65,0,hue,ball)
 for _,side in ipairs({-1,1}) do p("Cactus arm",0.5,1.4,0.5,side*0.95,1.9,0,hue,ball,side*0.4) end
 p("Chef hat band",1.5,0.5,1.25,0,2.85,0,ivory)
 for i=-1,1 do p("Chef hat puff",0.85,0.85,0.9,i*0.5,3.3,0,ivory,ball) end
 p("Apron",1.05,0.9,0.12,0,1.25,-0.64,ivory)
 p("Spatula",0.6,0.6,0.12,1.3,2.65,0,silver)
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.05,-0.8,0.3,0.62,0.02,0.12,0.26)
end

cast.dragon = function(p, face, hue)
 p("Pineapple dragon",1.65,2,1.4,0,1.65,0,hue,ball)
 p("Dragon snout",1.4,0.7,1,0,2.4,-0.5,hue,ball)
 for _,side in ipairs({-1,1}) do p("Dragon wing",1.2,1.7,0.25,side*1.15,2.1,0.3,green,nil,side*-0.55); p("Leaf horn",0.3,1,0.3,side*0.45,3.1,0,green,ball,side*0.3) end
 p("Tail",0.55,0.55,1.8,0,1.1,1.1,hue,ball)
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.6,-0.95,0.3,0.62,0.02,0.12,0.26)
end

cast.tv = function(p, face, hue)
 for i=-3,3 do local a=i*0.38; p("Peacock feather",0.55,2,0.3,math.sin(a)*1.6,2.1+math.cos(a)*0.6,0.6,hue,ball,-a); p("Feather eye",0.3,0.4,0.15,math.sin(a)*2,2.5+math.cos(a)*0.8,0.4,gold,ball) end
 p("Television",2,1.6,0.9,0,1.65,-0.2,ink)
 p("Screen",1.7,1.25,0.15,0,1.65,-0.72,hue)
 for _,side in ipairs({-1,1}) do p("TV aerial",0.08,0.9,0.08,side*0.35,2.8,0,silver,nil,side*-0.65) end
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.05,-0.8,0.3,0.62,0.02,0.12,0.26)
end

cast.piano = function(p, face, hue)
 p("Piano shell",2.1,1.6,1.25,0,1.8,0,hue)
 for i=1,9 do p("Ivory key",0.2,0.18,0.5,-1+i*0.2,1.2,-0.8,ivory); if i%3~=0 then p("Black key",0.1,0.13,0.25,-1+i*0.2,1.34,-0.65,ink) end end
 for _,side in ipairs({-1,1}) do p("Crab claw",0.75,0.7,0.7,side*1.5,2,0,hue,ball); for i=1,3 do p("Crab leg",1.1,0.17,0.2,side*1.1,0.35+i*0.18,(i-2)*0.45,hue,nil,side*0.4) end end
 face(0,2.05,-0.8,0.3,0.62,0.02,0.12,0.26)
end

cast.moon = function(p, face, hue)
 p("Moon rhino",2.2,2,1.6,0,1.8,0,hue,ball)
 p("Rhino muzzle",1.5,0.9,1,0,1.8,-0.9,hue,ball)
 p("Lunar horn",0.4,1.2,0.45,0,2.4,-1.1,ivory,ball,-0.2)
 for _,side in ipairs({-1,1}) do p("Moon crater",0.5,0.6,0.1,side*0.7,2.3,-0.68,silver,ball); p("Rhino ear",0.5,0.6,0.4,side*0.8,2.9,0,hue,ball) end
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.5,-0.7,0.3,0.62,0.02,0.12,0.26)
end

cast.comet = function(p, face, hue)
 p("Komodo body",1.4,1.8,1.5,0,1.6,0,hue,ball)
 p("Komodo snout",1.3,0.65,1.3,0,2.1,-0.7,hue,ball)
 for i=1,5 do p("Comet tail",0.65-i*0.07,0.65-i*0.07,0.65,0,1.3+i*0.2,0.7+i*0.38,i%2==0 and gold or silver,ball); p("Dorsal star",0.3,0.5,0.25,0,2.5-i*0.2,i*0.35,gold,nil,math.pi/4) end
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0,2.4,-0.75,0.3,0.62,0.02,0.12,0.26)
end

cast.jelly = function(p, face, hue)
 p("Jelly bell",2.2,1.4,1.8,0,2.35,0,hue,ball)
 for i=1,8 do local a=i*math.pi/4; p("Jelly tentacle",0.2,1.8,0.2,math.cos(a)*0.8,1,math.sin(a)*0.6,hue,ball,math.cos(a)*0.25) end
 p("Crown band",1.4,0.3,1.1,0,3.1,0,gold)
 for i=-1,1 do p("Crown point",0.25,0.7,0.3,i*0.5,3.5,0,gold,nil,i*0.2); p("Crown gem",0.22,0.22,0.2,i*0.5,3.8,-0.05,silver,ball) end
 face(0,2.05,-0.8,0.3,0.62,0.02,0.12,0.26)
end

cast.galaxy = function(p, face, hue)
 p("Swan body",2,1.3,2,0,1.2,0,hue,ball)
 p("Swan neck",0.55,1.9,0.6,0,2.2,-0.6,ivory,ball,-0.25)
 p("Swan head",0.95,0.85,0.95,0.2,3.1,-0.65,hue,ball)
 p("Golden beak",0.6,0.25,0.7,0.2,2.9,-1.25,gold)
 for _,side in ipairs({-1,1}) do p("Nebula wing",0.7,1.7,1.6,side*1.05,1.8,0,hue,ball,side*-0.55) end
 for i=1,14 do local a=i*math.pi/7; p("Orbit star",0.22,0.22,0.22,math.cos(a)*1.8,2+math.sin(a)*0.7,math.sin(a)*1.1,gold,nil,math.pi/4) end
 for _,side in ipairs({-1,1}) do p("Foot",0.5,0.45,0.75,side*0.5,0.23,-0.15,hue,ball) end
 face(0.2,3.2,-1.1,0.3,0.62,0.02,0.12,0.26)
end

local function addLabel(pivot, unit, caption)
	local board = Instance.new("BillboardGui")
	board.Name = "Brainrot label"
	board.Size = UDim2.fromOffset(186, 79)
	board.StudsOffsetWorldSpace = Vector3.new(0, 4.25, 0)
	board.MaxDistance = 38
	board.AlwaysOnTop = true
	board.Parent = pivot
	local stack = Instance.new("Frame")
	stack.Name = "Stack"
	stack.Size = UDim2.fromScale(1, 1)
	stack.BackgroundTransparency = 1
	stack.Parent = board

	local function line(text, color, y, height, size)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 0, height)
		label.Position = UDim2.fromOffset(0, y)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = color
		label.TextSize = size
		label.Font = Enum.Font.GothamBold
		local outline = Instance.new("UIStroke")
		outline.Color = black
		outline.Thickness = 1.6
		outline.Parent = label
		label.Parent = stack
		return label
	end

	if unit.mutation ~= "" then
		local spec = require(game.ReplicatedStorage.MutationData)[unit.mutation]
		line(unit.mutation .. " x" .. spec.multiplier .. " • " .. spec.effect, spec.color, 0, 14, 10)
	end
	local name = line(unit.entry[1], ivory, 14, 20, 16)
	name.TextScaled = true
	local nameSize = Instance.new("UITextSizeConstraint")
	nameSize.MaxTextSize = 16
	nameSize.Parent = name
	line(unit.rarity.name, unit.rarity.color, 34, 15, 13)
	line(string.format("+$%d/s", unit.rate), green, 49, 15, 13)
	line(caption, caption:sub(1, 1) == "$" and green or ivory, 64, 15, 13)
end

function Models.sculpt(parent, unit, pose, caption)
	local model = Instance.new("Model")
	model.Name = unit.entry[1]
	local mutation = unit.mutation
	local diamond = mutation == "Diamond"
	local hue = mutation == "Gold" and gold or diamond and rgb(122, 225, 255) or unit.entry[6]
	local function piece(name, sx, sy, sz, x, y, z, color, shape, tilt, material)
		local part = World.part(model, name, Vector3.new(sx, sy, sz),
			CFrame.new(x, y, z) * CFrame.Angles(0, 0, tilt or 0), color, material, shape)
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		return part
	end
	-- Gaze, brow angle and mouth opening set each character's expression.
	local function face(x, y, z, spread, scale, gaze, brow, mouth)
		for _, side in ipairs({ -1, 1 }) do
			local eyeX = x + side * spread
			local eyeY = y + side * gaze * 0.37
			local pupilX = eyeX + gaze
			piece("Eye white", 0.66 * scale, 0.7 * scale, 0.27, eyeX, eyeY, z, ivory, ball)
			piece("Pupil", 0.32 * scale, 0.4 * scale, 0.17, pupilX, eyeY, z - 0.12, ink, ball)
			piece("Eye highlight", 0.12 * scale, 0.12 * scale, 0.06,
				pupilX - 0.055 * scale, eyeY + 0.09 * scale, z - 0.2, ivory, ball)
			piece("Brow", 0.51 * scale, 0.14 * scale, 0.16,
				eyeX, eyeY + 0.41 * scale, z - 0.02, ink, ball, side * brow)
		end
		local mouthY = y - (0.35 + mouth * 0.27) * scale
		piece("Mouth", (0.82 - mouth * 0.63) * scale, mouth * scale, 0.18,
			x, mouthY, z - 0.035, ink, ball, gaze * 1.45)
		if mouth >= 0.3 then
			piece("Tongue", 0.28 * scale, 0.12 * scale, 0.09,
				x, mouthY - mouth * 0.21 * scale, z - 0.11, rose, ball)
		end
	end

	-- Preserve the existing conveyor, carry and prompt reference point across all body shapes.
	cast[unit.entry[5]](piece, face, hue)
	local pivot = model:FindFirstChildWhichIsA("BasePart")
	pivot.PivotOffset = pivot.CFrame:ToObjectSpace(CFrame.new(0, 2.05, 0))
	model.PrimaryPart = pivot
	if mutation ~= "" then
		local shine = diamond and rgb(176, 245, 255) or rgb(255, 220, 112)
		for _, side in ipairs({ -1, 1 }) do
			piece(diamond and "Diamond crystal" or "Gold sparkle", diamond and 0.23 or 0.37,
				diamond and 0.72 or 0.37, 0.28, side * 2.04, 2.72 + side * 0.42, -0.3,
				shine, nil, side * math.pi / 4, neon)
		end
	end

	require(script.Parent.MutationService).decorate(model, unit)
	if caption then
		addLabel(pivot, unit, caption)
	end
	model:PivotTo(pose * CFrame.new(0, 2.05, 0))
	model.Parent = parent
	return model
end

return Models
