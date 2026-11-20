-- ShieldService: the laser shield around each safehouse, and the thirteen
-- collision groups the island uses. Raising a shield turns its glowing
-- shell solid, so raiders cannot walk in, and any steal attempt against
-- that base is refused outright. A shield holds for twenty-six seconds;
-- once it falls, forty-eight seconds must pass before it can rise again,
-- so the full cycle from one activation to the next is seventy-four.

local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)

local ShieldService = {}

local services = nil
local physics = game:GetService("PhysicsService")

-- The thirteen collision groups: the actors, the places, and one group per
-- base so a base's parts can be told apart from the rest of the island.
local groupNames = {
	"Players",
	"Brainrots",
	"Conveyor",
	"Shield",
	"Water",
	"Decor",
	"Merchant",
	"Base1",
	"Base2",
	"Base3",
	"Base4",
	"Base5",
	"Base6",
}

-- Per player: when their shield was raised, when it ends, and when the
-- next one may rise.
local shields = {}

-- Is the player's shield up right now?
function ShieldService.isActive(player)
	local record = shields[player.UserId]
	if record == nil then
		return false
	end
	return os.clock() < record.endsAt
end

-- When the player's shield may next be raised (a Unix-free clock time).
function ShieldService.getReadyAt(player)
	local record = shields[player.UserId]
	if record == nil then
		return 0
	end
	return record.readyAgainAt
end

-- Raise the player's shield. Refused while it is already up or cooling down.
function ShieldService.activate(player)
	local now = os.clock()
	local record = shields[player.UserId]
	if record ~= nil and now < record.readyAgainAt then
		return false
	end
	local endsAt = now + BrainrotData.Shield.duration
	-- The cooldown is counted AFTER the shield ends, not from activation:
	-- twenty-six seconds of shield, then forty-eight of cooldown.
	local readyAgainAt = endsAt + BrainrotData.Shield.cooldown
	shields[player.UserId] = {
		activatedAt = now,
		endsAt = endsAt,
		readyAgainAt = readyAgainAt,
	}
	services.Base:setShield(player, true)
	return true
end

-- Drop a shield early (when the player leaves, for instance).
function ShieldService.deactivate(player)
	shields[player.UserId] = nil
	services.Base:setShield(player, false)
end

-- The watch: hide shells whose shields have run out. The shell's own
-- CanCollide flag is what blocks or lets players through, so the watch
-- only has to hide the shell.
local function shieldWatch()
	while true do
		task.wait(0.5)
		for userId, record in pairs(shields) do
			if os.clock() >= record.endsAt then
				local player = game:GetService("Players"):GetPlayerByUserId(userId)
				if player then
					services.Base:setShield(player, false)
				end
			end
		end
	end
end

-- Register the groups, set their default relationships, and open the
-- raise-shield remote.
function ShieldService.init(deps)
	services = deps
	for _, name in ipairs(groupNames) do
		physics:RegisterCollisionGroup(name)
	end
	-- The sea never blocks anyone, and carried brainrots never push their
	-- carrier around. Everything else collides by default. The Shield
	-- group stays collidable with Players at all times: whether a shield
	-- shell actually blocks is decided by the shell's own CanCollide flag,
	-- which BaseService flips when the shield rises and falls.
	physics:SetCollisionGroupCollidable("Shield", "Players", true)

	local raiseRemote = Instance.new("RemoteEvent")
	raiseRemote.Name = "RaiseShield"
	raiseRemote.Parent = game:GetService("ReplicatedStorage")
	raiseRemote.OnServerEvent:Connect(function(player)
		ShieldService.activate(player)
	end)
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		ShieldService.deactivate(player)
	end)
	task.spawn(shieldWatch)
end

return ShieldService
