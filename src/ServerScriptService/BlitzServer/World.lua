local Lighting = game:GetService("Lighting")
local flat = Enum.Material.SmoothPlastic
local World = {}
World.ink = Color3.fromRGB(19, 28, 48)
World.steel = Color3.fromRGB(99, 150, 181)
World.aqua = Color3.fromRGB(78, 255, 218)
World.gold = Color3.fromRGB(255, 199, 101)
World.white = Color3.fromRGB(244, 248, 255)
World.islandHalfX = 134
World.islandHalfZ = 100
World.plotSpacing = 82
World.plotRow = 51
World.beltTop = 1.8
World.wallThickness = 3
World.machineDepth = 20
World.importBack = -World.islandHalfX + World.wallThickness
World.importCenter = World.importBack + World.machineDepth / 2
World.receiverBack = World.islandHalfX - World.wallThickness
World.receiverCenter = World.receiverBack - World.machineDepth / 2
World.importCurtain = World.importCenter + 6
World.receiverCurtain = World.receiverCenter - 6

function World.part(parent, name, size, frame, color, material, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = frame
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Shape = shape or Enum.PartType.Block
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function World.sign(part, text, color, width, height, offset, distance)
	local board = Instance.new("BillboardGui")
	board.Size = UDim2.fromOffset(width, height)
	board.StudsOffsetWorldSpace = offset
	board.MaxDistance = distance or 64
	board.AlwaysOnTop = true
	board.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = World.ink
	label.BackgroundTransparency = 0.12
	label.TextColor3 = color
	label.TextSize = height >= 50 and 15 or 18
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = board
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = label
	return label
end

function World.surfaceSign(part, text, color)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(512, 80)
	gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	gui.LightInfluence = 0.15
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.94, 0.82)
	label.Position = UDim2.fromScale(0.03, 0.09)
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui
end

function World.prompt(part, action, object, duration)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = action
	prompt.ObjectText = object
	prompt.HoldDuration = duration or 0.12
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = part
	return prompt
end

function World.aliveRoot(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart")
end

function World.near(player, part)
	local root = World.aliveRoot(player)
	return root and part.Parent and (root.Position - part.Position).Magnitude <= 13
end

function World.buildHarbor()
	Lighting.ClockTime = 10.5
	Lighting.Brightness = 3.5
	Lighting.Ambient = Color3.fromRGB(180, 172, 160)
	Lighting.OutdoorAmbient = Color3.fromRGB(191, 194, 188)
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.12
	atmosphere.Glare = 0.12
	atmosphere.Haze = 0.35
	atmosphere.Color = Color3.fromRGB(206, 234, 255)
	atmosphere.Decay = Color3.fromRGB(167, 206, 246)
	atmosphere.Parent = Lighting
	local clouds = Instance.new("Clouds")
	clouds.Color = Color3.fromRGB(255, 249, 238)
	clouds.Cover = 0.26
	clouds.Density = 0.72
	clouds.Parent = workspace.Terrain
	local map = Instance.new("Folder")
	map.Name = "Blitz Harbor"
	map.Parent = workspace
	World.part(map, "Ocean", Vector3.new(1300, 8, 1300), CFrame.new(0, -8, 0), Color3.fromRGB(35, 172, 235), Enum.Material.SmoothPlastic)
	local halfX, halfZ = World.islandHalfX, World.islandHalfZ
	World.part(map, "Harbor island", Vector3.new(2 * halfX, 8, 2 * halfZ),
		CFrame.new(0, -4, 0), Color3.fromRGB(103, 188, 62), Enum.Material.SmoothPlastic)

	local function detail(name, sx, sy, sz, x, y, z, color, material, angle, shape)
		local part = World.part(map, name, Vector3.new(sx, sy, sz),
			CFrame.new(x, y, z) * CFrame.Angles(0, 0, angle or 0), color, material, shape)
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		return part
	end
	local teal = Color3.fromRGB(25, 169, 164)
	local vermilion = Color3.fromRGB(244, 101, 75)
	local cream = Color3.fromRGB(255, 232, 185)
	local glow = Enum.Material.Neon
	local brown = Color3.fromRGB(139, 87, 51)
	local coping = Color3.fromRGB(195, 134, 83)
	local rubber = Color3.fromRGB(42, 62, 76)
	local hazard = Color3.fromRGB(255, 209, 52)
	local top = World.beltTop
	local beltStart, beltEnd = World.importBack, World.receiverBack
	local beltLength = beltEnd - beltStart
	local beltCenter = (beltStart + beltEnd) / 2
	local belt = World.part(map, "Conveyor", Vector3.new(beltLength, 0.56, 16),
		CFrame.new(beltCenter, top - 0.28, 0), rubber, Enum.Material.SmoothPlastic)
	for x = beltStart + 2, beltEnd - 2, 4 do
		detail("Conveyor tread", 0.22, 0.06, 15.5, x, top + 0.02, 0, World.steel, flat)
	end
	for x = World.importCurtain + 5, World.receiverCurtain - 4, 14 do
		detail("Conveyor support crossbeam", 1.15, 0.4, 16.8, x, 1.14, 0, World.steel, flat)
		for _, z in ipairs({ -6.8, 6.8 }) do
			detail("Conveyor foot", 2.4, 0.18, 2.2, x, 0.09, z, World.steel, flat)
			detail("Conveyor leg", 0.85, 1.15, 0.85, x, 0.65, z, World.steel, flat)
		end
	end
	local beltLights = { World.gold, World.aqua, Color3.fromRGB(255, 121, 190), Color3.fromRGB(132, 177, 255) }
	for _, side in ipairs({ -1, 1 }) do
		local railZ = side * 8
		detail("Steel edge rail", beltLength, 0.35, 0.48, beltCenter, top + 0.22, railZ, World.steel, flat)
		detail("Hazard edge", beltLength, 0.24, 0.43, beltCenter, top - 0.33, railZ, hazard, flat)
		for x = World.importCurtain + 3, World.receiverCurtain - 2, 4 do
			detail("Hazard stripe", 1.05, 0.26, 0.45, x, top - 0.33, railZ, rubber, flat, 0.26)
		end
		for x = World.importCurtain + 5, World.receiverCurtain - 4, 7 do
			detail("Roller end cap", 0.64, 0.64, 0.28, x, top - 0.77, railZ, World.steel, flat, 0, Enum.PartType.Ball)
			detail("Rail light", 1.8, 0.12, 0.36, x, top + 0.45, railZ, beltLights[((x - World.importCurtain - 5) / 7 + side) % 4 + 1], glow)
		end
	end
	for _, x in ipairs({ beltStart + 0.55, beltEnd - 0.55 }) do
		local roller = detail("Drive roller", 16.8, 1.1, 1.1, x, top - 0.53, 0,
			World.steel, flat, 0, Enum.PartType.Cylinder)
		roller.CFrame *= CFrame.Angles(0, math.pi / 2, 0)
	end
	for _, side in ipairs({ -1, 1 }) do
		local x = side < 0 and World.importCenter or World.receiverCenter
		local curtain = side < 0 and World.importCurtain or World.receiverCurtain
		local mouth = curtain - side * 3
		for _, z in ipairs({ -9.5, 9.5 }) do
			World.part(map, "Machine housing", Vector3.new(World.machineDepth, 12, 3), CFrame.new(x, 6, z), teal, flat)
			detail("Portal jamb", 1.6, 10, 1.5, mouth, 5, z, World.steel, flat)
			detail("Machine warning light", 1.5, 0.4, 1.5, x, 12.2, z, hazard, glow)
			for vent = -6, 6, 2 do
				detail("Machine cooling vent", 0.6, 3.8, 0.16, x + vent, 5, z / math.abs(z) * 11.06, rubber, flat)
			end
		end
		World.part(map, "Machine backplate", Vector3.new(1.5, 12, 19), CFrame.new(x + side * (World.machineDepth / 2 - 0.75), 6, 0), teal, flat)
		detail("Machine roof", World.machineDepth, 2, 22, x, 11, 0, World.steel, flat)
		for z = -7.5, 7.5, 1 do
			detail("Flexible portal curtain", 0.25, 8.1, 1, curtain, 5.85, z, rubber)
		end
		local fascia = detail("Machine header", 1.8, 2.6, 22, mouth, 9.85, 0, World.ink, flat)
		World.sign(fascia, side < 0 and "BLITZ IMPORTS" or "RETURN PROCESSOR",
			World.white, 221, 32, Vector3.new(0, 2.4, 0), 90)
	end

	local wallHeight, thickness = 18, World.wallThickness
	for _, side in ipairs({ -1, 1 }) do
		local edgeX, edgeZ = side * (halfX - thickness / 2), side * (halfZ - thickness / 2)
		World.part(map, "Perimeter wall", Vector3.new(2 * halfX, wallHeight, thickness),
			CFrame.new(0, wallHeight / 2, edgeZ), brown, flat)
		World.part(map, "Perimeter wall", Vector3.new(thickness, wallHeight, 2 * halfZ),
			CFrame.new(edgeX, wallHeight / 2, 0), brown, flat)
		detail("Wall coping", 2 * halfX, 0.85, 3.5, 0, wallHeight, edgeZ, coping, flat)
		detail("Wall coping", 3.5, 0.85, 2 * halfZ, edgeX, wallHeight, 0, coping, flat)
		for x = -120, 120, 24 do
			detail("Wall pilaster", 1.25, wallHeight, 0.4, x, wallHeight / 2, edgeZ - side * 1.6, coping, flat)
		end
		for z = -80, 80, 20 do
			detail("Wall pilaster", 0.4, wallHeight, 1.25, edgeX - side * 1.6, wallHeight / 2, z, coping, flat)
		end
	end

	for _, side in ipairs({ -1, 1 }) do
		local lane = side * 25
		detail("Evacuation path", beltLength, 0.06, 6, 0, 0.03, lane, cream, flat)
		for x = beltStart + 5, beltEnd - 5, 6 do
			detail("Evacuation lane marker", 3, 0.06, 0.26, x, 0.065, lane, teal)
		end
		for _, x in ipairs({ -World.plotSpacing, 0, World.plotSpacing }) do
			detail("Safehouse approach", 9, 0.06, 12, x, 0.035, side * 33, cream, flat)
		end
		for _, x in ipairs({ -110, -41, 41, 110 }) do
			local z = side * 31
			detail("Street lamp post", 0.45, 10, 0.45, x, 5, z, World.steel, flat)
			detail("Street lamp arm", 0.5, 0.45, 3.4, x, 9.8, z - side * 1.35, World.steel, flat)
			detail("Street lamp diffuser", 1.35, 0.3, 1.65, x, 9.52, z - side * 2.6, cream, glow)
			detail("Harbor banner", 2.4, 3.5, 0.16, x + 1.3, 6.7, z, side < 0 and teal or vermilion)
			detail("Banner crossbar", 2.8, 0.16, 0.25, x + 1.2, 8.5, z, World.steel, flat)
		end
		for _, x in ipairs({ -41, 41 }) do
			local z = side * 53
			for offset = -7, 7, 7 do
				detail("Decorative fence post", 0.45, 2.7, 0.45, x, 1.35, z + offset, coping, flat)
			end
			for _, y in ipairs({ 0.95, 2.15 }) do
				detail("Decorative fence rail", 0.24, 0.25, 14.4, x, y, z, cream, flat)
			end
			detail("Cargo crate", 3.4, 3.4, 3.4, x + 5, 1.7, z + side * 4, coping, flat)
			detail("Crate brace", 0.3, 4.25, 0.13, x + 5, 1.7, z + side * 4 - 1.74, cream, flat, 0.75)
			detail("Cargo barrel", 2.7, 2.1, 2.1, x - 5, 1.35, z, vermilion, flat, math.pi / 2, Enum.PartType.Cylinder)
			for _, y in ipairs({ 0.5, 2.2 }) do
				detail("Barrel hoop", 0.22, 2.18, 2.18, x - 5, y, z, World.steel, flat, math.pi / 2, Enum.PartType.Cylinder)
			end
		end
		for _, x in ipairs({ -111, -41, 41, 111 }) do
			local z = side * 78
			detail("Palm trunk", 1.3, 10, 1.3, x, 5, z, brown, flat, 0.12)
			for leaf = 0, 5 do
				local azimuth = leaf * math.pi / 3
				local frond = detail("Palm frond", 6.5, 0.55, 2.15, x, 10.6, z,
					Color3.fromRGB(48, 150 + 12 * (leaf % 3), 69), nil, 0, Enum.PartType.Ball)
				frond.CFrame *= CFrame.Angles(0, azimuth, 0) * CFrame.new(2.5, -0.2, 0) * CFrame.Angles(0, 0, -0.22)
			end
			for offset = -4, 4, 4 do
				detail("Shrub", 4.7, 2.75, 3.4, x + offset, 1.3, z + 3, Color3.fromRGB(53, 153, 68),
					Enum.Material.SmoothPlastic, 0, Enum.PartType.Ball)
			end
		end
		local post = detail("Wayfinding post", 0.45, 4.5, 0.45, 17, 2.25, side * 30, World.steel, flat)
		World.sign(post, "SAFEHOUSES", World.aqua, 133, 26, Vector3.new(0, 2.4, 0), 38)
		for x = -105, 105, 35 do
			detail("Wake stripe", 12, 0.05, 0.45, x, -3.96, side * (halfZ + 17 + math.abs(x) % 12),
				Color3.fromRGB(169, 235, 255))
		end
	end

	-- Keep the round-three harbor backdrop outside the playable perimeter.
	local function backdrop(name, sx, sy, sz, x, y, z, color, material, angle)
		return detail(name, sx, sy, sz, x, y, z + halfZ - 48, color, material, angle)
	end
	backdrop("Cargo wharf", 105, 1.8, 33, -47, -1.1, 72, teal, Enum.Material.SmoothPlastic)
	for x = -94, -4, 10 do
		backdrop("Wharf piling", 1.8, 7, 1.8, x, -2.8, 86, World.steel, Enum.Material.SmoothPlastic)
		backdrop("Wharf deck seam", 0.2, 0.05, 29, x, -0.18, 72, World.steel)
	end
	backdrop("Customs warehouse", 33, 12, 15, -73, 6, 76, cream, Enum.Material.SmoothPlastic)
	for _, side in ipairs({ -1, 1 }) do
		backdrop("Warehouse cladding", 0.42, 11.8, 15.2, -73 + side * 16.4, 6, 76, teal, flat)
		backdrop("Warehouse roof", 18, 0.65, 17, -73 + side * 8.5, 13.45, 76, teal, flat, -side * 0.17)
	end
	for _, x in ipairs({ -82, -64 }) do
		backdrop("Loading door frame", 10.2, 8.5, 0.45, x, 4.25, 68.4, teal, flat)
		backdrop("Loading roller door", 8.8, 7.2, 0.48, x, 3.6, 68.15, World.steel, flat)
		for y = 1, 7 do
			backdrop("Door slat", 8.7, 0.12, 0.12, x, y, 67.86, cream, flat)
		end
	end
	local fascia = backdrop("Customs fascia", 16, 2.5, 0.35, -73, 10, 68.3, teal, flat)
	World.surfaceSign(fascia, "BLITZ CUSTOMS", World.white)

	for _, cargo in ipairs({
		{ -46, 3, 74, vermilion }, { -30, 3, 74, teal },
		{ -38, 9, 74, World.gold }, { -15, 3, 81, Color3.fromRGB(87, 136, 239) },
	}) do
		local x, y, z, color = table.unpack(cargo)
		backdrop("Freight container", 15.6, 6, 7.4, x, y, z, color, flat)
		for offset = -7, 7 do
			backdrop("Container rib", 0.18, 5.6, 0.22, x + offset, y, z - 3.76, color:Lerp(World.ink, 0.26), flat)
		end
		for _, side in ipairs({ -1, 1 }) do
			backdrop("Container frame", 15.8, 0.25, 7.55, x, y + side * 2.87, z, color:Lerp(World.white, 0.22), flat)
		end
	end

	backdrop("Crane pedestal", 7, 1.5, 7, -10, 0.55, 67, World.steel, flat)
	for _, side in ipairs({ -1, 1 }) do
		backdrop("Crane tower upright", 0.75, 24, 2, -10 + side * 1.6, 12.8, 67, World.gold, flat)
	end
	for y = 3, 23, 4 do
		backdrop("Crane lattice", 5.2, 0.32, 1.2, -10, y, 67, World.gold, flat, y % 8 == 3 and 0.78 or -0.78)
	end
	backdrop("Crane boom", 38, 1.6, 2.3, -20, 24.8, 67, World.gold, flat)
	backdrop("Crane boom stay", 24, 0.38, 0.55, -20, 27, 67, World.steel, flat, -0.18)
	backdrop("Crane operator cab", 4, 3, 3.3, -7, 22, 67, teal, flat)
	backdrop("Crane cab window", 3.3, 1.95, 0.15, -7, 22.2, 65.27, Color3.fromRGB(137, 219, 240), flat)
	backdrop("Crane hoist cable", 0.17, 10, 0.17, -32, 19, 67, World.ink, flat)
	backdrop("Crane hook", 1.15, 0.65, 0.7, -32, 13.75, 67, World.gold, flat)
	return map, belt
end

return World
