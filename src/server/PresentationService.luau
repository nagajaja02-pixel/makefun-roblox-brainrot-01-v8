-- Appearance only: existing geometry and gameplay properties stay intact.
local Lighting = game:GetService("Lighting")
local Presentation = {}
function Presentation.init()
	Lighting.ClockTime = 16.4
	Lighting.Brightness = 2.2
	Lighting.Ambient = Color3.fromRGB(90, 108, 132)
	Lighting.OutdoorAmbient = Color3.fromRGB(146, 161, 177)
	Lighting.EnvironmentDiffuseScale = 0.7
	Lighting.EnvironmentSpecularScale = 0.65
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "HarborAtmosphere"
	atmosphere.Density = 0.23
	atmosphere.Haze = 1.2
	atmosphere.Color = Color3.fromRGB(200, 224, 255)
	atmosphere.Decay = Color3.fromRGB(255, 203, 152)
	atmosphere.Parent = Lighting
	local sky = Instance.new("Sky")
	sky.Name = "HarborSky"
	sky.CelestialBodiesShown = true
	sky.StarCount = 900
	sky.Parent = Lighting
	local grade = Instance.new("ColorCorrectionEffect")
	grade.Name = "HarborGrade"
	grade.Saturation = 0.12
	grade.Contrast = 0.07
	grade.Brightness = 0.015
	grade.Parent = Lighting
	for _, p in ipairs(workspace.Island:GetDescendants()) do
		if p:IsA("BasePart") then
			local name = string.lower(p.Name)
			if name:find("roof") then p.Material = Enum.Material.Slate
			elseif name:find("floor") then p.Material = Enum.Material.Cobblestone
			elseif name:find("belt") then p.Material = Enum.Material.DiamondPlate
			elseif name:find("wall") then p.Material = Enum.Material.Brick
			elseif name:find("dock") then p.Material = Enum.Material.WoodPlanks end
		end
	end
	local decor = Instance.new("Folder")
	decor.Name = "HarborDetails"
	decor.Parent = workspace.Island
	-- Original primitive pennants and dock bollards: twenty-four cheap parts.
	for _, z in ipairs({-88, 88}) do
		for x = -110, 110, 44 do
			local post = Instance.new("Part")
			post.Name = "MooringPost"
			post.Size = Vector3.new(0.7, 4, 0.7)
			post.Position = Vector3.new(x, 2, z)
			post.Material = Enum.Material.WoodPlanks
			post.Color = Color3.fromRGB(100, 73, 53)
			post.Anchored = true
			post.CanCollide = false
			post.CanQuery = false
			post.CanTouch = false
			post.CastShadow = false
			post.Parent = decor
			local flag = post:Clone()
			flag.Name = "HarborPennant"
			flag.Size = Vector3.new(2, 1, 0.08)
			flag.Position = post.Position + Vector3.new(0.8, 1.3, 0)
			flag.Color = Color3.fromRGB(45, 193, 190)
			flag.Material = Enum.Material.Fabric
			flag.Parent = decor
		end
	end
end
return Presentation
