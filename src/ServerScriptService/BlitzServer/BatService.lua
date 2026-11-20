local Players = game:GetService("Players")
local Tween = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local World = require(script.Parent.World)
local Steal = require(script.Parent.StealService)
local Bat = {}
function Bat.start(states, onRaid, notify)
	local function join(player)
		local readyAt = 0
		local function give()
			local backpack = player:FindFirstChildOfClass("Backpack")
			if not backpack or not World.aliveRoot(player) then return end
			for _, parent in ipairs({backpack, player.Character}) do
				if parent:FindFirstChild("Baseball Bat") then return end
			end
			local tool = Instance.new("Tool")
			tool.Name = "Baseball Bat"
			tool.ToolTip = "Swing to knock back a player • 1.2s cooldown"
			tool.CanBeDropped = false
			local handle = Instance.new("Part")
			handle.Name = "Handle"
			handle.Size = Vector3.new(0.32, 3.8, 0.32)
			handle.Color = Color3.fromRGB(160, 99, 52)
			handle.CanCollide = false
			handle.Massless = true
			handle.Parent = tool
			local barrel = Instance.new("Part")
			barrel.Name = "Barrel"
			barrel.Shape = Enum.PartType.Cylinder
			barrel.Size = Vector3.new(2.5, 0.65, 0.65)
			barrel.CFrame = handle.CFrame * CFrame.new(0, 0.65, 0) * CFrame.Angles(0, 0, math.pi / 2)
			barrel.Color = handle.Color
			barrel.CanCollide = false
			barrel.Massless = true
			barrel.Parent = tool
			local weld = Instance.new("WeldConstraint")
			weld.Part0, weld.Part1, weld.Parent = handle, barrel, handle
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxasset://sounds/swordslash.wav"
			sound.Volume = 0.7
			sound.Parent = handle
			tool.Activated:Connect(function()
				local root = World.aliveRoot(player)
				local state = states[player]
				local now = os.clock()
				if not root or tool.Parent ~= player.Character or not state or not state.ready
					or state.savingRebirth or now < readyAt then return end
				readyAt = now + 1.2
				sound:Play()
				local grip = tool.Grip
				Tween:Create(tool, TweenInfo.new(0.15), {Grip = grip * CFrame.Angles(0, 0, -1.7)}):Play()
				task.delay(0.32, function()
					if tool.Parent then Tween:Create(tool, TweenInfo.new(0.18), {Grip = grip}):Play() end
				end)
				task.delay(0.12, function()
					root = World.aliveRoot(player)
					if not root or tool.Parent ~= player.Character then return end
					for target, victim in pairs(states) do
						local other = World.aliveRoot(target)
						if target ~= player and other and victim.ready and not victim.savingRebirth then
							local offset = other.Position - root.Position
							if offset.Magnitude > 0.1 and offset.Magnitude <= 7 and root.CFrame.LookVector:Dot(offset.Unit) > 0.25 then
								local params = RaycastParams.new()
								params.FilterType = Enum.RaycastFilterType.Exclude
								params.FilterDescendantsInstances = {player.Character, target.Character}
								params.RespectCanCollide = true
								if not workspace:Raycast(root.Position, offset, params) then
									if victim.carry then Steal.returnRaid(victim, states, onRaid, notify) end
									local flat = Vector3.new(offset.X, 0, offset.Z)
									local direction = flat.Magnitude > 0.1 and flat.Unit or root.CFrame.LookVector
									other:SetNetworkOwner(nil)
									other.AssemblyLinearVelocity = direction * 65 + Vector3.new(0, 28, 0)
									task.delay(0.35, function() if other.Parent then other:SetNetworkOwnershipAuto() end end)
									local flash = Instance.new("Highlight")
									flash.FillColor = Color3.fromRGB(255, 212, 112)
									flash.Adornee, flash.Parent = target.Character, target.Character
									Debris:AddItem(flash, 0.25)
									local hit = Instance.new("Sound")
									hit.SoundId = "rbxasset://sounds/impact_water.mp3"
									hit.Parent = other
									hit:Play()
									Debris:AddItem(hit, 2)
								end
							end
						end
					end
				end)
			end)
			tool.Parent = backpack
		end
		task.spawn(function()
			while player.Parent == Players do give(); task.wait(2) end
		end)
	end
	Players.PlayerAdded:Connect(join)
	for _, player in ipairs(Players:GetPlayers()) do join(player) end
end
return Bat
