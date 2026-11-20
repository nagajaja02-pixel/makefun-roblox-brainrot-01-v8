local Data = require(game:GetService("ReplicatedStorage"):WaitForChild("BrainrotData"))
local Models = require(script.Parent.BrainrotModels)
local World = require(script.Parent.World)
local Base = require(script.Parent.BaseService)
local Money = require(script.Parent.MoneyService)
local Steal = require(script.Parent.StealService)

local pivotHeight = World.beltTop + 2.05

local Conveyor = {}
Conveyor.__index = Conveyor

function Conveyor.new(map, states, notify)
	local self = setmetatable({ map = map, states = states, notify = notify, offers = {}, clock = 0, serial = 0 }, Conveyor)
	for index = 1, #Data.cast do
		local starter = index == 6 and 1 or index == 5 and 2 or index == 7 and 3
		self:spawnOffer(World.importCurtain + index * 17, starter and Data.create(starter, false) or Data.create(index, true))
	end
	return self
end

function Conveyor:spawnOffer(x, unit)
	local model = Models.sculpt(self.map, unit, CFrame.new(x, pivotHeight, 0), string.format("$%d", unit.price))
	local label = model.PrimaryPart:FindFirstChildOfClass("BillboardGui")
	label.AlwaysOnTop = false
	label:AddTag("ConveyorBrainrotLabel")
	local offer = { model = model, x = x }
	local visible = x > World.importCurtain and x < World.receiverCurtain
	label.Enabled = visible
	self.offers[offer] = true
	local prompt = World.prompt(model.PrimaryPart, "Buy  $" .. unit.price, unit.entry[1])
	prompt.Style = Enum.ProximityPromptStyle.Custom
	offer.prompt = prompt
	offer.label = label
	prompt.Enabled = visible
	prompt.Triggered:Connect(function(player)
		local state = self.states[player]
		if not self.offers[offer] or not prompt.Enabled or not state or state.savingRebirth or not World.near(player, model.PrimaryPart) then
			return
		end
		if state.carry or not Base.freeSlot(state) then
			self.notify(player, "You need free hands and a free stand.", "warning")
		elseif not Money.spend(state, unit.price) then
			self.notify(player, "Save more cash for " .. unit.entry[1] .. ".", "warning")
		else
			self.offers[offer] = nil
			model:Destroy()
			Steal.startCarry(state, unit, nil, nil)
			Money.publish(state)
			self.notify(player, "Purchased! Carry it into your safehouse.", "success")
		end
	end)
end

function Conveyor:step(dt, now)
	self.clock += dt
	if self.clock >= 3.4 then
		self.clock -= 3.4
		self.serial += 1
		local unit = self.serial % 3 == 0 and Data.create(math.random(3), false) or Data.randomOffer()
		self:spawnOffer(World.importCenter, unit)
	end
	for offer in pairs(self.offers) do
		offer.x += dt * 4.2
		if offer.x >= World.receiverCurtain + 6 then
			self.offers[offer] = nil
			offer.model:Destroy()
		else
			local visible = offer.x > World.importCurtain and offer.x < World.receiverCurtain
			offer.prompt.Enabled = visible
			offer.label.Enabled = visible
			local stride = now * 7 + offer.x * 0.4
			offer.model:PivotTo(CFrame.new(offer.x, pivotHeight + math.abs(math.sin(stride)) * 0.26, 0)
				* CFrame.Angles(0, math.sin(stride * 0.5) * 0.34, math.sin(stride) * 0.13))
		end
	end
end

return Conveyor
