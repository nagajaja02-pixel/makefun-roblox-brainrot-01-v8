-- WaveService: the tsunami that sweeps the island on a schedule.
-- A wave is announced fourteen seconds before it arrives, then a wall of
-- water crosses the island for eight seconds. Anyone still on low ground
-- when it passes is knocked about, loses a little cash, and drops whatever
-- they were carrying. Roofs and the lookout deck are the safe places.

local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)

local WaveService = {}

local services = nil
local warnRemote = nil
local waveWall = nil

-- The height that counts as safe: roofs and the lookout sit above it.
local safeHeight = 6

-- Build the wall of water once, hidden, and keep it for every wave.
local function buildWall()
	local wall = Instance.new("Part")
	wall.Name = "TsunamiWall"
	wall.Size = Vector3.new(268, 14, 6)
	wall.Position = Vector3.new(0, 7, -120)
	wall.Color = Color3.fromRGB(60, 140, 220)
	wall.Material = Enum.Material.Water
	wall.Transparency = 0.45
	wall.Anchored = true
	wall.CanCollide = false
	wall.Parent = workspace.Island
	return wall
end

-- Hit every player who is still on low ground: a shove, a small fine, and
-- a dropped carry. Each player is hit at most once per wave.
local function sweepHit(hit)
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if hit[player.UserId] then
			continue
		end
		local character = player.Character
		if character == nil then
			continue
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		if root == nil then
			continue
		end
		if root.Position.Y >= safeHeight then
			continue
		end
		if math.abs(root.Position.X) > 134 or math.abs(root.Position.Z) > 100 then
			continue
		end
		hit[player.UserId] = true
		-- A shove toward the south dock.
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			root.AssemblyLinearVelocity = Vector3.new(0, 12, 30)
			task.delay(0.6, function()
				if humanoid.Parent ~= nil then
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				end
			end)
		end
		-- A small fine: five percent of what the player holds.
		local fine = math.floor(services.Money:getCash(player) * 0.05)
		if fine > 0 then
			services.Money:spend(player, fine)
		end
		-- A carried brainrot is dropped and goes home.
		services.Steal:returnCarried(player)
	end
end

-- One wave: warn, then sweep the wall across the island.
local function runWave()
	warnRemote:FireAllClients("warn", BrainrotData.Wave.warnTime)
	task.wait(BrainrotData.Wave.warnTime)
	warnRemote:FireAllClients("sweep", BrainrotData.Wave.sweepTime)
	local hit = {}
	local start = os.clock()
	while os.clock() - start < BrainrotData.Wave.sweepTime do
		local progress = (os.clock() - start) / BrainrotData.Wave.sweepTime
		local z = -120 + progress * 240
		waveWall.Position = Vector3.new(0, 7, z)
		sweepHit(hit)
		task.wait(0.25)
	end
	waveWall.Position = Vector3.new(0, 7, -120)
	warnRemote:FireAllClients("clear")
end

-- The wave loop: first wave after the opening delay, then one every gap.
local function waveLoop()
	task.wait(BrainrotData.Wave.firstAt)
	while true do
		runWave()
		task.wait(BrainrotData.Wave.gap)
	end
end

-- Build the wall, open the warning remote, and start the loop.
function WaveService.init(deps)
	services = deps
	waveWall = buildWall()
	warnRemote = Instance.new("RemoteEvent")
	warnRemote.Name = "Tsunami"
	warnRemote.Parent = game:GetService("ReplicatedStorage")
	task.spawn(waveLoop)
end

return WaveService
