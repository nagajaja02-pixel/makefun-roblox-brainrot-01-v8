-- CarryPose: raises both arms while the player carries a brainrot, and
-- puts them back down when the carry ends. Carrying is detected by the
-- CarryWeld the server puts on the carried model: its Part0 is the
-- carrier's HumanoidRootPart.

local CarryPose = {}

-- Find the shoulder joints of a character (R6 and R15 both) and remember
-- their resting angles.
local function findShoulders(character)
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if torso == nil then
		return {}
	end
	local out = {}
	for _, child in ipairs(torso:GetChildren()) do
		if child:IsA("Motor6D") and (child.Name == "Left Shoulder" or child.Name == "Right Shoulder" or child.Name == "LeftShoulder" or child.Name == "RightShoulder") then
			out[child.Name] = { joint = child, rest = child.C0 }
		end
	end
	return out
end

-- Is this character carrying a brainrot right now? The carried model
-- lives under the island and carries a CarryWeld pointing at the root.
local function isCarrying(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return false
	end
	local island = workspace:FindFirstChild("Island")
	if island == nil then
		return false
	end
	for _, descendant in ipairs(island:GetDescendants()) do
		if descendant:IsA("Weld") and descendant.Name == "CarryWeld" and descendant.Part0 == root then
			return true
		end
	end
	return false
end

-- Raise both arms forward, as if holding something up in front.
local function raise(shoulders)
	for name, entry in pairs(shoulders) do
		local joint = entry.joint
		if name:find("Left") then
			joint.C0 = entry.rest * CFrame.Angles(0, 0, math.rad(-120))
		else
			joint.C0 = entry.rest * CFrame.Angles(0, 0, math.rad(120))
		end
	end
end

-- Put the arms back where they were.
local function lower(shoulders)
	for _, entry in pairs(shoulders) do
		entry.joint.C0 = entry.rest
	end
end

-- Watch one character: check the carry state a few times a second and
-- pose the arms to match.
local function watchCharacter(character)
	local shoulders = findShoulders(character)
	if next(shoulders) == nil then
		return
	end
	local raised = false
	task.spawn(function()
		while character.Parent ~= nil do
			local carrying = isCarrying(character)
			if carrying and not raised then
				raise(shoulders)
				raised = true
			elseif not carrying and raised then
				lower(shoulders)
				raised = false
			end
			task.wait(0.25)
		end
		if raised then
			lower(shoulders)
		end
	end)
end

-- Watch the player's character, now and on every respawn.
function CarryPose.watch(player)
	local function onCharacter(character)
		task.wait(0.5)
		watchCharacter(character)
	end
	if player.Character then
		onCharacter(player.Character)
	end
	player.CharacterAdded:Connect(onCharacter)
end

return CarryPose
