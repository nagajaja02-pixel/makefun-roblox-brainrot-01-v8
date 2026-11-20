local CarryPose = {}

local shoulderNames = {
	["Left Shoulder"] = true,
	["Right Shoulder"] = true,
	LeftShoulder = true,
	RightShoulder = true,
}
local lift = CFrame.Angles(math.rad(168), 0, 0)

local function collectShoulders(character)
	local shoulders = {}
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if torso then
		for _, joint in ipairs(character:GetDescendants()) do
			if shoulderNames[joint.Name] and joint:IsA("Motor6D") and joint.Part0 == torso and joint.Part1 then
				local original = joint.C0
				table.insert(shoulders, {
					joint = joint,
					original = original,
					raised = CFrame.new(original.Position) * lift * original.Rotation,
				})
			end
		end
	end
	return shoulders
end

function CarryPose.start(players, runService)
	local active = {}

	local function restore(player)
		local pose = active[player]
		if pose then
			for _, shoulder in ipairs(pose.shoulders) do
				shoulder.joint.C0 = shoulder.original
			end
			active[player] = nil
		end
	end

	players.PlayerRemoving:Connect(restore)
	runService.RenderStepped:Connect(function()
		for _, player in ipairs(players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local cargo = player:GetAttribute("Carrying")
			local pose = active[player]
			if pose and (pose.character ~= character or not humanoid or humanoid.Health <= 0 or not cargo or cargo == "") then
				restore(player)
				pose = nil
			end
			if humanoid and humanoid.Health > 0 and cargo and cargo ~= "" then
				if not pose then
					local shoulders = collectShoulders(character)
					if #shoulders == 2 then
						pose = { character = character, shoulders = shoulders }
						active[player] = pose
					end
				end
				if pose then
					for _, shoulder in ipairs(pose.shoulders) do
						shoulder.joint.C0 = shoulder.raised
					end
				end
			end
		end
	end)

	-- Animator writes Transform before PreSimulation. Keep its leg and torso motion.
	runService.PreSimulation:Connect(function()
		for _, pose in pairs(active) do
			for _, shoulder in ipairs(pose.shoulders) do
				shoulder.joint.Transform = CFrame.identity
			end
		end
	end)
end

return CarryPose
