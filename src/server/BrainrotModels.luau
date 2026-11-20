-- BrainrotModels: builds the 3D model of one brainrot character from parts.
-- Every model faces -Z, its base sits at Y 0, and it carries a readable
-- name label. The model is built fresh for each spawn, so a character on the
-- conveyor, on a stand, or being carried is always the same construction.

local BrainrotModels = {}

-- A plain part, anchored, with the given size, position and colour.
local function part(parent, name, size, pos, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.Parent = parent
	return p
end

-- The name label every model wears: name on top, tier and mutation below,
-- coloured by rarity so a Mythic reads at a glance.
local function nameLabel(model, char, mutation)
	local gui = Instance.new("BillboardGui")
	gui.Name = "NameLabel"
	gui.Size = UDim2.new(0, 120, 0, 44)
	gui.StudsOffset = Vector3.new(0, 3.4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = model

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.55, 0)
	title.BackgroundTransparency = 1
	title.Text = char.name
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextStrokeTransparency = 0.2
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = gui

	local sub = Instance.new("TextLabel")
	sub.Name = "Sub"
	sub.Size = UDim2.new(1, 0, 0.45, 0)
	sub.Position = UDim2.new(0, 0, 0.55, 0)
	sub.BackgroundTransparency = 1
	local tag = char.tier
	if mutation == "Gold" then
		tag = tag .. " • GOLD x2"
		sub.TextColor3 = Color3.fromRGB(255, 215, 0)
	elseif mutation == "Diamond" then
		tag = tag .. " • DIAMOND x3"
		sub.TextColor3 = Color3.fromRGB(120, 220, 255)
	else
		sub.TextColor3 = Color3.fromRGB(220, 220, 220)
	end
	sub.Text = tag
	sub.TextStrokeTransparency = 0.2
	sub.TextScaled = true
	sub.Font = Enum.Font.Gotham
	sub.Parent = gui
end

-- The trait feature: a few extra parts that make each character read as
-- what its name says. Kept deliberately simple so every model builds fast.
local function addTrait(model, trait, body, accent)
	if trait == "log" then
		-- A wooden log with rings on its face.
		local ring = part(model, "Ring", Vector3.new(1.4, 1.4, 0.2), Vector3.new(0, 1.6, -0.65), accent, Enum.Material.Wood)
		ring.Shape = Enum.PartType.Cylinder
		ring.Rotation = Vector3.new(90, 0, 0)
		part(model, "Knob", Vector3.new(0.5, 0.5, 0.4), Vector3.new(0, 2.6, 0), body, Enum.Material.Wood)
	elseif trait == "doll" then
		-- A doll with a bow and button eyes.
		part(model, "Bow", Vector3.new(1.2, 0.4, 0.3), Vector3.new(0, 2.5, -0.6), accent, Enum.Material.Fabric)
		part(model, "EyeL", Vector3.new(0.25, 0.25, 0.2), Vector3.new(-0.4, 1.9, -0.65), Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic)
		part(model, "EyeR", Vector3.new(0.25, 0.25, 0.2), Vector3.new(0.4, 1.9, -0.65), Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic)
	elseif trait == "fish" then
		-- A fish with a tail fin and a dorsal fin.
		part(model, "Tail", Vector3.new(0.3, 1.0, 0.8), Vector3.new(0, 1.4, 0.8), accent, Enum.Material.SmoothPlastic)
		part(model, "Fin", Vector3.new(0.2, 0.9, 0.6), Vector3.new(0, 2.7, 0.1), accent, Enum.Material.SmoothPlastic)
	elseif trait == "cactus" then
		-- A cactus with two arms and a flower.
		part(model, "ArmL", Vector3.new(0.4, 1.0, 0.4), Vector3.new(-1.1, 1.6, 0), accent, Enum.Material.SmoothPlastic)
		part(model, "ArmR", Vector3.new(0.4, 1.0, 0.4), Vector3.new(1.1, 1.9, 0), accent, Enum.Material.SmoothPlastic)
		part(model, "Flower", Vector3.new(0.6, 0.3, 0.6), Vector3.new(0, 3.1, 0), Color3.fromRGB(255, 120, 180), Enum.Material.Neon)
	elseif trait == "fridge" then
		-- A fridge with a handle and a cold glow strip.
		part(model, "Handle", Vector3.new(0.2, 1.2, 0.2), Vector3.new(0.7, 1.6, -0.7), accent, Enum.Material.Metal)
		part(model, "Glow", Vector3.new(1.6, 0.2, 0.2), Vector3.new(0, 2.2, -0.65), Color3.fromRGB(150, 220, 255), Enum.Material.Neon)
	elseif trait == "banana" then
		-- A banana with a peel tip and a cheeky face.
		part(model, "Tip", Vector3.new(0.5, 0.6, 0.5), Vector3.new(0, 3.0, 0), accent, Enum.Material.SmoothPlastic)
		part(model, "Peel", Vector3.new(1.8, 0.4, 0.4), Vector3.new(0, 0.4, 0.3), accent, Enum.Material.SmoothPlastic)
	elseif trait == "ice" then
		-- An ice creature with crystal spikes.
		part(model, "SpikeL", Vector3.new(0.3, 0.9, 0.3), Vector3.new(-0.7, 2.8, 0), Color3.fromRGB(200, 235, 255), Enum.Material.Ice)
		part(model, "SpikeR", Vector3.new(0.3, 0.9, 0.3), Vector3.new(0.7, 2.8, 0), Color3.fromRGB(200, 235, 255), Enum.Material.Ice)
		part(model, "SpikeM", Vector3.new(0.3, 1.2, 0.3), Vector3.new(0, 3.1, 0), Color3.fromRGB(200, 235, 255), Enum.Material.Ice)
	elseif trait == "dancer" then
		-- A dancer with a tutu and a bun.
		local tutu = part(model, "Tutu", Vector3.new(2.4, 0.3, 2.4), Vector3.new(0, 0.9, 0), Color3.fromRGB(255, 255, 255), Enum.Material.Fabric)
		tutu.Shape = Enum.PartType.Cylinder
		part(model, "Bun", Vector3.new(0.6, 0.5, 0.6), Vector3.new(0, 3.1, 0), accent, Enum.Material.SmoothPlastic)
	elseif trait == "assassin" then
		-- An assassin with a mask band and a foam blade.
		part(model, "Mask", Vector3.new(1.5, 0.4, 0.2), Vector3.new(0, 1.9, -0.65), Color3.fromRGB(15, 15, 15), Enum.Material.SmoothPlastic)
		part(model, "Blade", Vector3.new(0.2, 1.1, 0.5), Vector3.new(1.1, 1.4, -0.2), Color3.fromRGB(230, 230, 230), Enum.Material.Metal)
	elseif trait == "pineapple" then
		-- A pineapple with leafy crown and a belly patch.
		part(model, "LeafL", Vector3.new(0.3, 1.0, 0.3), Vector3.new(-0.4, 3.1, 0), Color3.fromRGB(60, 160, 70), Enum.Material.SmoothPlastic)
		part(model, "LeafR", Vector3.new(0.3, 1.0, 0.3), Vector3.new(0.4, 3.1, 0), Color3.fromRGB(60, 160, 70), Enum.Material.SmoothPlastic)
		part(model, "Patch", Vector3.new(1.0, 1.0, 0.2), Vector3.new(0, 1.2, -0.65), accent, Enum.Material.SmoothPlastic)
	elseif trait == "cow" then
		-- A cow with horns and a ring around its middle like a planet.
		part(model, "HornL", Vector3.new(0.3, 0.7, 0.3), Vector3.new(-0.8, 3.0, 0), Color3.fromRGB(240, 230, 210), Enum.Material.SmoothPlastic)
		part(model, "HornR", Vector3.new(0.3, 0.7, 0.3), Vector3.new(0.8, 3.0, 0), Color3.fromRGB(240, 230, 210), Enum.Material.SmoothPlastic)
		local ring = part(model, "Ring", Vector3.new(3.2, 0.15, 3.2), Vector3.new(0, 1.4, 0), accent, Enum.Material.Neon)
		ring.Shape = Enum.PartType.Cylinder
	elseif trait == "shark" then
		-- A shark with a dorsal fin, a tail and three little legs.
		part(model, "Fin", Vector3.new(0.2, 1.0, 0.7), Vector3.new(0, 2.9, 0.2), accent, Enum.Material.SmoothPlastic)
		part(model, "Tail", Vector3.new(0.3, 1.1, 0.9), Vector3.new(0, 1.4, 0.9), accent, Enum.Material.SmoothPlastic)
		part(model, "Leg1", Vector3.new(0.3, 0.6, 0.3), Vector3.new(-0.5, 0.3, -0.3), accent, Enum.Material.SmoothPlastic)
		part(model, "Leg2", Vector3.new(0.3, 0.6, 0.3), Vector3.new(0.5, 0.3, -0.3), accent, Enum.Material.SmoothPlastic)
		part(model, "Leg3", Vector3.new(0.3, 0.6, 0.3), Vector3.new(0, 0.3, 0.5), accent, Enum.Material.SmoothPlastic)
	elseif trait == "croc" then
		-- A crocodile with a long snout, a tail and a bomb fin.
		part(model, "Snout", Vector3.new(1.2, 0.6, 1.4), Vector3.new(0, 1.2, -1.1), accent, Enum.Material.SmoothPlastic)
		part(model, "Tail", Vector3.new(0.4, 0.5, 1.6), Vector3.new(0, 1.0, 1.4), accent, Enum.Material.SmoothPlastic)
		part(model, "Bomb", Vector3.new(0.7, 0.7, 0.7), Vector3.new(0, 3.2, 0), Color3.fromRGB(40, 40, 40), Enum.Material.Metal)
	end
end

-- Build one character model. `char` is a BrainrotData entry, `mutation` is
-- "Normal", "Gold" or "Diamond". The model is anchored and ready to be
-- placed; the caller positions it with PivotTo.
function BrainrotModels.build(char, mutation)
	local model = Instance.new("Model")
	model.Name = char.id

	-- The body: a rounded block in the character's colour.
	local body = part(model, "Body", Vector3.new(2, 2.2, 1.3), Vector3.new(0, 1.3, 0), char.body, Enum.Material.SmoothPlastic)
	body.Shape = Enum.PartType.Block

	-- The head: a smaller block on top, in the accent colour.
	part(model, "Head", Vector3.new(1.5, 0.9, 1.1), Vector3.new(0, 2.85, 0), char.accent, Enum.Material.SmoothPlastic)

	-- Two eyes on the front face, so the character reads from the front.
	part(model, "EyeL", Vector3.new(0.25, 0.35, 0.15), Vector3.new(-0.4, 2.9, -0.6), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
	part(model, "EyeR", Vector3.new(0.25, 0.35, 0.15), Vector3.new(0.4, 2.9, -0.6), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)

	-- The trait feature that makes this one different from the rest.
	addTrait(model, char.trait, char.body, char.accent)
 if char.design then
  -- Each design has a different radial crest, body proportion and orbit.
  local d = char.design
  body.Size = Vector3.new(1.5 + d % 4 * 0.25, 1.8 + d % 5 * 0.15, 1.2)
  body.Shape = (d % 3 == 0) and Enum.PartType.Ball or Enum.PartType.Block
  for j = 1, 3 + d % 5 do
   local angle = j * math.pi * 2 / (3 + d % 5)
   local crest = part(model, "Crest" .. j, Vector3.new(0.25, 0.4 + d * 0.025, 0.25),
    Vector3.new(math.cos(angle) * 1.1, 3.3, math.sin(angle) * 0.8), char.accent, Enum.Material.Neon)
   crest.Rotation = Vector3.new(0, d * 13, math.deg(angle))
  end
  part(model, "Signature", Vector3.new(0.4, 0.4, 0.4), Vector3.new((d % 3 - 1) * 0.7, 1.4, -0.8), char.accent)
 end
 local palette = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
 local aura = part(model, "RarityHalo", Vector3.new(2.5, 0.08, 2.5), Vector3.new(0, 0.1, 0), palette.TierColors[char.tier], Enum.Material.Neon)
 aura.Shape = Enum.PartType.Cylinder
 aura.Transparency = 0.45

	-- A mutated character wears a glowing trim so its value is visible.
	if mutation == "Gold" then
		part(model, "Trim", Vector3.new(2.3, 0.25, 1.6), Vector3.new(0, 0.25, 0), Color3.fromRGB(255, 215, 0), Enum.Material.Neon)
	elseif mutation == "Diamond" then
		part(model, "Trim", Vector3.new(2.3, 0.25, 1.6), Vector3.new(0, 0.25, 0), Color3.fromRGB(120, 220, 255), Enum.Material.Neon)
	end

	-- The readable name label above the model.
	nameLabel(model, char, mutation)

	model.PrimaryPart = body
	return model
end

return BrainrotModels
