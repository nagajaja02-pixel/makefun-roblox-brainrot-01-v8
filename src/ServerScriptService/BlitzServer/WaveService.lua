local World = require(script.Parent.World)
local Base = require(script.Parent.BaseService)
local sweepEdge = World.islandHalfX + 12
local waveWidth = 2 * (World.islandHalfZ + 2)
local Wave = {}
Wave.__index = Wave

function Wave.new(map)
	workspace:SetAttribute("WavePhase", "CLEAR")
	workspace:SetAttribute("WaveAt", workspace:GetServerTimeNow() + 52)
	return setmetatable({ map = map, phase = "CLEAR", at = workspace:GetAttribute("WaveAt"), hit = {} }, Wave)
end

function Wave:setPhase(phase, at)
	self.phase = phase
	self.at = at
	workspace:SetAttribute("WavePhase", phase)
	workspace:SetAttribute("WaveAt", at)
end

function Wave:step(now, states, notify)
	if self.phase == "CLEAR" and now >= self.at then
		self:setPhase("EVACUATE", now + 14)
		for player in pairs(states) do
			notify(player, "Tsunami incoming! Reach your safehouse.", "warning")
		end
	elseif self.phase == "EVACUATE" and now >= self.at then
		local wall = World.part(self.map, "Tsunami wall", Vector3.new(11, 16, waveWidth), CFrame.new(-sweepEdge, 7, 0), Color3.fromRGB(43, 171, 237))
		wall.CanCollide = false
		local crest = World.part(self.map, "Tsunami crest", Vector3.new(12, 2, waveWidth), wall.CFrame * CFrame.new(0, 8, 0), Color3.fromRGB(158, 239, 255), Enum.Material.Neon)
		crest.CanCollide = false
		self.wall, self.crest = wall, crest
		self:setPhase("WAVE ACTIVE", now + 8)
	elseif self.wall then
		local x = -sweepEdge + math.clamp(1 - (self.at - now) / 8, 0, 1) * (2 * sweepEdge)
		self.wall.CFrame = CFrame.new(x, 7, 0)
		self.crest.CFrame = self.wall.CFrame * CFrame.new(0, 8, 0)
		for player, state in pairs(states) do
			local root = World.aliveRoot(player)
			if root and not self.hit[player] and math.abs(root.Position.X - x) <= 8 and math.abs(root.Position.Z) <= World.islandHalfZ then
				self.hit[player] = true
				if Base.isSheltered(state.base, root.Position) then
					notify(player, "Safehouse held. Your collection is safe.", "success")
				else
					notify(player, "Swept away! Get inside your safehouse next time.", "warning")
					player.Character:FindFirstChildOfClass("Humanoid").Health = 0
				end
			end
		end
		if now >= self.at then
			self.wall:Destroy()
			self.crest:Destroy()
			self.wall, self.crest = nil, nil
			table.clear(self.hit)
			self:setPhase("CLEAR", now + 54)
		end
	end
end

return Wave
