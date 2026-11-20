local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Rules = require(game:GetService("ReplicatedStorage").Shared.CombatRules)
local Combat = {}
local last = {}
local function pulse(position)
	local p = Instance.new("Part")
	p.Name = "BasketballImpact"
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.one
	p.CFrame = CFrame.new(position)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.Material = Enum.Material.Neon
	p.Color = Color3.fromRGB(255, 176, 60)
	p.Parent = workspace
	TweenService:Create(p, TweenInfo.new(0.25), {Size = Vector3.one * 5, Transparency = 1}):Play()
	Debris:AddItem(p, 0.3)
end
function Combat.init(services)
	local function give(character)
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		local backpack = player:WaitForChild("Backpack")
		if backpack:FindFirstChild("Basketball") then return end
		local tool = Instance.new("Tool")
		tool.Name = "Basketball"
		tool.CanBeDropped = false
		tool.ToolTip = "Swing to stop a thief"
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Shape = Enum.PartType.Ball
		handle.Size = Vector3.one * 1.4
		handle.Color = Color3.fromRGB(235, 113, 30)
		handle.Material = Enum.Material.Pebble
		handle.Massless = true
		handle.CanCollide = false
		handle.Parent = tool
		tool.Activated:Connect(function()
			local root = character:FindFirstChild("HumanoidRootPart")
			local hum = character:FindFirstChildOfClass("Humanoid")
			local now = os.clock()
			if tool.Parent ~= character or not root or not hum or hum.Health <= 0
				or now - (last[player] or -math.huge) < Rules.Cooldown then return end
			last[player] = now
			-- Procedural tool animation: no externally owned animation asset.
			tool.Grip = CFrame.Angles(0, 0, -1.2)
			TweenService:Create(tool, TweenInfo.new(0.22), {Grip = CFrame.identity}):Play()
			for _, target in ipairs(Players:GetPlayers()) do
				if target == player then continue end
				local tc = target.Character
				local tr = tc and tc:FindFirstChild("HumanoidRootPart")
				local th = tc and tc:FindFirstChildOfClass("Humanoid")
				if not tr or not th then continue end
				local delta = tr.Position - root.Position
				local distance = delta.Magnitude
				if distance <= 0 or distance > Rules.Range then continue end
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {character}
				local hit = workspace:Raycast(root.Position, delta, params)
				local clear = hit == nil or hit.Instance:IsDescendantOf(tc)
				if Rules.allowed(now, -math.huge, distance,
					root.CFrame.LookVector:Dot(delta.Unit), th.Health > 0, tool.Parent == character, clear) then
					services.Steal.returnCarried(target, true)
					tr:ApplyImpulse((delta.Unit * 32 + Vector3.new(0, 12, 0)) * tr.AssemblyMass)
					pulse(tr.Position)
				end
			end
		end)
		tool.Parent = backpack
	end
	local function join(player)
		player.CharacterAdded:Connect(give)
		if player.Character then task.spawn(give, player.Character) end
	end
	Players.PlayerAdded:Connect(join)
	Players.PlayerRemoving:Connect(function(player) last[player] = nil end)
	for _, player in ipairs(Players:GetPlayers()) do join(player) end
end
return Combat
