-- StealService: stealing, carrying, returning and selling brainrots.
-- A player clicks a character on someone else's stand to steal it. If the
-- victim's shield is up the raid is refused. Otherwise the character is
-- lifted off the stand and welded in front of the thief, who must walk it
-- home: reaching their own base places it on a free stand, while the victim
-- catching up with them sends it straight back. Selling is a RemoteEvent
-- the client fires from the character menu.

local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
local BrainrotModels = require(script.Parent.BrainrotModels)

local StealService = {}

local services = nil
local carrying = {}

-- Unanchor every part of a model and weld its primary part in front of a
-- character, so the model rides along as the player walks.
local function attachCarry(model, character)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
		end
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return false
	end
	local weld = Instance.new("Weld")
	weld.Name = "CarryWeld"
	weld.Part0 = root
	weld.Part1 = model.PrimaryPart
	weld.C0 = CFrame.new(0, 0.5, -2.5)
	weld.Parent = model.PrimaryPart
	model:PivotTo(root.CFrame * CFrame.new(0, 0.5, -2.5))
	return true
end

-- Is a position inside a base's plot?
local function inBase(base, pos)
	return math.abs(pos.X - base.pos.x) < 11 and math.abs(pos.Z - base.pos.z) < 9
end

-- Try to steal the character on a victim's stand. Returns true on success.
function StealService.trySteal(thief, victim, standId)
	if thief == victim then
		return false
	end
	if carrying[thief.UserId] ~= nil then
		return false
	end
	if not services.Base:hasFreeStand(thief) then
		return false
	end
	if services.Shield:isActive(victim) then
		return false
	end
	local record = services.Base:takePlaced(victim, standId)
	if record == nil then
		return false
	end
	local character = thief.Character
	if character == nil then
		-- The thief has no character to carry with: put it back.
		services.Base:place(victim, record.char, record.mutation)
		return false
	end
	if not attachCarry(record.model, character) then
		services.Base:place(victim, record.char, record.mutation)
		return false
	end
	carrying[thief.UserId] = {
		thief = thief,
		victim = victim,
		standId = standId,
		char = record.char,
		mutation = record.mutation,
		model = record.model,
	}
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			StealService.returnCarried(thief)
		end)
	end
	return true
end

-- Place the carried character on the thief's first free stand.
function StealService.deliver(thief)
	local carry = carrying[thief.UserId]
	if carry == nil then
		return false
	end
	if not services.Base:hasFreeStand(thief) then
		return false
	end
	local weld = carry.model.PrimaryPart:FindFirstChild("CarryWeld")
	if weld then
		weld:Destroy()
	end
	for _, descendant in ipairs(carry.model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
		end
	end
	carry.model:Destroy()
	carrying[thief.UserId] = nil
	services.Base:place(thief, carry.char, carry.mutation)
	local stats = thief:FindFirstChild("leaderstats")
	local steals = stats and stats:FindFirstChild("Steals")
	if steals then steals.Value += 1 end
	return true
end

-- Send a carried character back to its owner's stand. If the original
-- stand is taken, any free stand of the victim will do; with nowhere to
-- go, the victim is paid the full price instead.
function StealService.returnCarried(thief, showDrop)
	local carry = carrying[thief.UserId]
	if carry == nil then
		return false
	end
	carrying[thief.UserId] = nil
    if showDrop then
        -- A short, noninteractive falling copy makes the failed theft readable.
        local falling = carry.model:Clone()
        falling.Name = "DroppedBrainrot"
        for _, child in ipairs(falling:GetDescendants()) do
            if child:IsA("BasePart") then
                child.Anchored = true
                child.CanCollide = false
                child.CanQuery = false
                child.CanTouch = false
                game:GetService("TweenService"):Create(child, TweenInfo.new(0.35), {
                    Position = child.Position - Vector3.new(0, 3, 0), Transparency = 1,
                }):Play()
            elseif child:IsA("BillboardGui") or child:IsA("ClickDetector")
                or child:IsA("JointInstance") or child:IsA("WeldConstraint") then child:Destroy() end
        end
        falling.Parent = workspace
        game:GetService("Debris"):AddItem(falling, 0.4)
    end
	carry.model:Destroy()
	local victim = carry.victim
	local base = services.Base:getBase(victim)
	if base == nil then
		return false
	end
	if base.placed[carry.standId] == nil and base.stands >= carry.standId then
		services.Base:place(victim, carry.char, carry.mutation)
	elseif services.Base:hasFreeStand(victim) then
		services.Base:place(victim, carry.char, carry.mutation)
	else
		services.Money:earn(victim, carry.char.price)
	end
	return true
end

-- Sell the character on one of the player's own stands for half its price.
function StealService.sell(player, standId)
	local record = services.Base:removePlaced(player, standId)
	if record == nil then
		return false
	end
	services.Money:earn(player, BrainrotData.sellPrice(record.char.price))
	return true
end

-- The carry watch: victims catching up send the character home, and
-- thieves reaching their own base deliver it.
local function carryWatch()
	while true do
		task.wait(0.2)
		for userId, carry in pairs(carrying) do
			local thief = carry.thief
			local victim = carry.victim
			local thiefChar = thief.Character
			local victimChar = victim.Character
			if thiefChar == nil or victimChar == nil then
				StealService.returnCarried(thief)
			else
				local thiefRoot = thiefChar:FindFirstChild("HumanoidRootPart")
				local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")
				if thiefRoot == nil or victimRoot == nil then
					StealService.returnCarried(thief)
				elseif (thiefRoot.Position - victimRoot.Position).Magnitude < 4 then
					StealService.returnCarried(thief)
				else
					local base = services.Base:getBase(thief)
					if base ~= nil and inBase(base, thiefRoot.Position) then
						StealService.deliver(thief)
					end
				end
			end
		end
	end
end

-- Create the sell remote and start the carry watch.
function StealService.init(deps)
	services = deps
	local sellRemote = Instance.new("RemoteEvent")
	sellRemote.Name = "SellBrainrot"
	sellRemote.Parent = game:GetService("ReplicatedStorage")
	sellRemote.OnServerEvent:Connect(function(player, standId)
		if typeof(standId) == "number" then
			StealService.sell(player, standId)
		end
	end)
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		if carrying[player.UserId] ~= nil then
			StealService.returnCarried(player)
		end
	end)
	task.spawn(carryWatch)
end

return StealService
