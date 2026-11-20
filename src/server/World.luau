-- World: builds the island of Brainrot Blitz once, when the server starts.
-- The island is a harbour rectangle, the conveyor runs down its middle, six
-- safehouse plots sit on either side of the belt, and a few raised roofs
-- give players somewhere dry to stand when the tsunami comes.

local World = {}

-- The island's footprint, in studs.
World.Width = 268
World.Depth = 200

-- Make one anchored part. `opts` may carry shape, material, transparency
-- and whether players can collide with it.
local function mkPart(parent, name, size, pos, color, opts)
	opts = opts or {}
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = opts.material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = opts.canCollide ~= false
	if opts.shape then
		p.Shape = opts.shape
	end
	if opts.transparency then
		p.Transparency = opts.transparency
	end
	p.Parent = parent
	return p
end

-- A floating text board: a part with a SurfaceGui on its front face.
local function mkSign(parent, name, text, pos, size, color)
	local board = mkPart(parent, name, size, pos, Color3.fromRGB(30, 30, 40), { material = Enum.Material.SmoothPlastic })
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(255, 220, 90)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
	return board
end

-- A ProximityPrompt on a part, with a short hold. The caller connects to
-- its Triggered event.
function World.prompt(parent, action, object, hold)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = action
	prompt.ObjectText = object
	prompt.HoldDuration = hold or 0.3
	prompt.MaxActivationDistance = 10
	prompt.Parent = parent
	return prompt
end

-- Build the whole island. Returns the references other services need:
-- the belt, the base plots, the roofs, and the lookout deck.
function World.build()
	local island = Instance.new("Folder")
	island.Name = "Island"
	island.Parent = workspace

	-- The ground: a grass slab whose top surface sits at Y 0, so every
	-- character model (base at Y 0) stands on it.
	mkPart(island, "Ground", Vector3.new(World.Width, 2, World.Depth), Vector3.new(0, -1, 0),
		Color3.fromRGB(110, 190, 90), { material = Enum.Material.Grass })

	-- The sea around the island, a little lower and see-through.
	mkPart(island, "Sea", Vector3.new(420, 1, 340), Vector3.new(0, -1.4, 0),
		Color3.fromRGB(60, 140, 220), { material = Enum.Material.Water, transparency = 0.25, canCollide = false })

	-- A sand rim along the shore, so the island reads as a beach.
	mkPart(island, "SandNorth", Vector3.new(World.Width, 0.4, 8), Vector3.new(0, 0.1, -96), Color3.fromRGB(235, 210, 150), { material = Enum.Material.Sand, canCollide = false })
	mkPart(island, "SandSouth", Vector3.new(World.Width, 0.4, 8), Vector3.new(0, 0.1, 96), Color3.fromRGB(235, 210, 150), { material = Enum.Material.Sand, canCollide = false })

	-- The conveyor belt: a long dark platform down the middle of the island,
	-- from one end to the other, with a pale stripe down its centre.
	local belt = mkPart(island, "Belt", Vector3.new(262, 1, 6), Vector3.new(0, 0.5, 0),
		Color3.fromRGB(45, 45, 55), { material = Enum.Material.Metal })
	mkPart(island, "BeltStripe", Vector3.new(262, 0.2, 1), Vector3.new(0, 1.05, 0),
		Color3.fromRGB(255, 220, 90), { material = Enum.Material.Neon, canCollide = false })
	-- Low rails on both sides of the belt, so the characters stay on it.
	mkPart(island, "RailNorth", Vector3.new(262, 1.2, 0.6), Vector3.new(0, 1.1, -3.2), Color3.fromRGB(200, 200, 210), { material = Enum.Material.Metal })
	mkPart(island, "RailSouth", Vector3.new(262, 1.2, 0.6), Vector3.new(0, 1.1, 3.2), Color3.fromRGB(200, 200, 210), { material = Enum.Material.Metal })
	-- End gates: a frame at each end of the belt.
	for _, x in ipairs({ -131, 131 }) do
		mkPart(island, "Gate", Vector3.new(1, 6, 8), Vector3.new(x, 3, 0), Color3.fromRGB(255, 120, 60), { material = Enum.Material.Metal })
	end

	-- Perimeter walls: low blocks around the island edge, with gaps at the
	-- two short ends where the docks stick out.
	for _, z in ipairs({ -98, 98 }) do
		mkPart(island, "Wall", Vector3.new(World.Width, 3, 2), Vector3.new(0, 1.5, z), Color3.fromRGB(180, 170, 150), { material = Enum.Material.Concrete })
	end
	for _, x in ipairs({ -132, 132 }) do
		mkPart(island, "Wall", Vector3.new(2, 3, 120), Vector3.new(x, 1.5, -40), Color3.fromRGB(180, 170, 150), { material = Enum.Material.Concrete })
		mkPart(island, "Wall", Vector3.new(2, 3, 120), Vector3.new(x, 1.5, 40), Color3.fromRGB(180, 170, 150), { material = Enum.Material.Concrete })
	end

	-- The big welcome arch at the south dock.
	mkSign(island, "Welcome", "BRAINROT BLITZ", Vector3.new(0, 6, 92), Vector3.new(30, 7, 1), Color3.fromRGB(255, 220, 90))
	mkPart(island, "ArchL", Vector3.new(1.5, 7, 1.5), Vector3.new(-15, 3.5, 92), Color3.fromRGB(200, 90, 60), { material = Enum.Material.Metal })
	mkPart(island, "ArchR", Vector3.new(1.5, 7, 1.5), Vector3.new(15, 3.5, 92), Color3.fromRGB(200, 90, 60), { material = Enum.Material.Metal })

	-- Harbour decoration: crates stacked near the belt, lamps along it, and
	-- palm trees at the corners.
	local crateSpots = { { -60, -20 }, { -58, 22 }, { 60, -22 }, { 58, 20 }, { -20, -70 }, { 24, 70 } }
	for i, spot in ipairs(crateSpots) do
		mkPart(island, "Crate" .. i, Vector3.new(4, 4, 4), Vector3.new(spot[1], 2, spot[2]), Color3.fromRGB(180, 130, 70), { material = Enum.Material.Wood })
		mkPart(island, "CrateTop" .. i, Vector3.new(3, 3, 3), Vector3.new(spot[1] + 0.5, 5.5, spot[2]), Color3.fromRGB(200, 150, 85), { material = Enum.Material.Wood })
	end
	for _, x in ipairs({ -100, -50, 0, 50, 100 }) do
		mkPart(island, "LampPost", Vector3.new(0.6, 7, 0.6), Vector3.new(x, 3.5, -8), Color3.fromRGB(60, 60, 70), { material = Enum.Material.Metal })
		mkPart(island, "Lamp", Vector3.new(1.2, 1.2, 1.2), Vector3.new(x, 7.4, -8), Color3.fromRGB(255, 240, 180), { material = Enum.Material.Neon, canCollide = false })
	end
	local palmSpots = { { -120, -85 }, { 120, -85 }, { -120, 85 }, { 120, 85 } }
	for i, spot in ipairs(palmSpots) do
		mkPart(island, "PalmTrunk" .. i, Vector3.new(1.2, 9, 1.2), Vector3.new(spot[1], 4.5, spot[2]), Color3.fromRGB(140, 100, 60), { material = Enum.Material.Wood })
		local leaves = mkPart(island, "PalmTop" .. i, Vector3.new(7, 2, 7), Vector3.new(spot[1], 9.6, spot[2]), Color3.fromRGB(60, 170, 80), { material = Enum.Material.SmoothPlastic, shape = Enum.PartType.Ball })
		leaves.CanCollide = false
	end

	-- The lookout deck in the middle of the north side: the tallest safe
	-- spot when the wave comes.
	local deck = mkPart(island, "Lookout", Vector3.new(16, 1, 10), Vector3.new(0, 9, -78), Color3.fromRGB(150, 110, 70), { material = Enum.Material.Wood })
	mkPart(island, "LookoutLegL", Vector3.new(1, 9, 1), Vector3.new(-7, 4.5, -82), Color3.fromRGB(120, 85, 55), { material = Enum.Material.Wood })
	mkPart(island, "LookoutLegR", Vector3.new(1, 9, 1), Vector3.new(7, 4.5, -82), Color3.fromRGB(120, 85, 55), { material = Enum.Material.Wood })
	mkSign(island, "LookoutSign", "LOOKOUT - HIGH GROUND", Vector3.new(0, 12, -78), Vector3.new(14, 3, 1), Color3.fromRGB(120, 220, 255))

	-- The spawn pads near the south dock.
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(20, 1, 8)
	spawn.Position = Vector3.new(0, 0.5, 80)
	spawn.Color = Color3.fromRGB(90, 200, 120)
	spawn.Anchored = true
	spawn.Parent = island

	-- Daylight: a bright late-morning sky, so the island reads clearly.
	local lighting = game:GetService("Lighting")
	lighting.ClockTime = 10.5
	lighting.Brightness = 2
	lighting.Ambient = Color3.fromRGB(150, 150, 160)

	return {
		island = island,
		belt = belt,
		deck = deck,
		spawn = spawn,
	}
end

return World
