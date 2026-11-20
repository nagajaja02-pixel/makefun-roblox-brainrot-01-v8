local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")

local CarryPose = require(script.Parent.CarryPose)
local Menu = require(script.Parent.Menu)
CarryPose.start(Players, RunService)
local player = Players.LocalPlayer
local ui = Instance.new("ScreenGui")
ui.Name = "Brainrot Blitz HUD"
ui.ResetOnSpawn = false
local playerGui = player:WaitForChild("PlayerGui")
ui.Parent = playerGui
Menu.mount(ui, player)

local black = Color3.fromRGB(0, 0, 0)
local green = Color3.fromRGB(117, 255, 103)
local white = Color3.fromRGB(240, 247, 255)
local aqua = Color3.fromRGB(104, 255, 222)
local gold = Color3.fromRGB(255, 204, 112)
local red = Color3.fromRGB(255, 133, 148)
local muted = Color3.fromRGB(169, 193, 215)

local function container(name, position, anchor, width, height)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Position = position
	frame.AnchorPoint = anchor
	frame.Size = UDim2.fromOffset(width, height)
	frame.BackgroundTransparency = 1
	frame.Parent = ui
	return frame
end

local function outline(item)
	local stroke = Instance.new("UIStroke")
	stroke.Color = black
	stroke.Thickness = 1.8
	stroke.Parent = item
end

local function label(parent, x, y, height, size, color, align)
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Position = UDim2.fromOffset(x, y)
	item.Size = UDim2.new(1, -2 * x, 0, height)
	item.TextColor3 = color
	item.TextXAlignment = align or Enum.TextXAlignment.Left
	item.TextSize = size
	item.TextTruncate = Enum.TextTruncate.AtEnd
	item.Font = Enum.Font.GothamBold
	outline(item)
	item.Parent = parent
	return item
end

local centered = Enum.TextXAlignment.Center
local economy = container("Economy", UDim2.new(0, 15, 1, -15), Vector2.new(0, 1), 240, 77)
local cash = label(economy, 0, 0, 39, 35, green)
cash.Font = Enum.Font.GothamBlack
local rate = label(economy, 0, 40, 19, 16, green)
local crew = label(economy, 0, 59, 18, 13, white)

local alerts = container("Tsunami", UDim2.new(1, -14, 0, 53), Vector2.new(1, 0), 200, 60)
local wave = label(alerts, 0, 0, 27, 18, aqua, Enum.TextXAlignment.Right)
local shield = label(alerts, 0, 28, 24, 13, white, Enum.TextXAlignment.Right)

local orders = container("Objective", UDim2.new(0.5, 0, 1, -28), Vector2.new(0.5, 1), 440, 52)
local objective = label(orders, 10, 3, 26, 17, white, centered)
local upgrade = label(orders, 10, 29, 21, 13, white, centered)
local toast = container("Feedback", UDim2.new(0.5, 0, 1, -88), Vector2.new(0.5, 1), 465, 46)
local toastLabel = label(toast, 7, 0, 46, 15, white, centered)
toastLabel.TextWrapped = true
toast.Visible = false

local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundTransparency = 1
flash.ZIndex = 0
flash.Parent = ui

local toastSerial = 0
local flashTween
ReplicatedStorage:WaitForChild("BlitzFeedback").OnClientEvent:Connect(function(text, style)
	toastSerial += 1
	local serial = toastSerial
	local tint = style == "warning" and red or aqua
	toastLabel.Text = text
	toastLabel.TextColor3 = tint
	toast.Visible = true
	if flashTween then
		flashTween:Cancel()
	end
	flash.BackgroundColor3 = tint
	flash.BackgroundTransparency = 0.89
	flashTween = TweenService:Create(flash, TweenInfo.new(0.55), { BackgroundTransparency = 1 })
	flashTween:Play()
	task.delay(3.5, function()
		if toastSerial == serial then
			toast.Visible = false
		end
	end)
end)

local function formatCash(amount)
	for _, unit in ipairs({ { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }) do
		if amount >= unit[1] then
			local digits = string.format("%.2f", amount / unit[1]):gsub("0+$", ""):gsub("%.$", "")
			return digits .. unit[2]
		end
	end
	return tostring(amount)
end

local function refreshEconomy()
	cash.Text = "$" .. formatCash(player:GetAttribute("Cash") or 0)
	rate.Text = "+$" .. tostring(player:GetAttribute("Rate") or 0) .. " / sec"
	crew.Text = string.format("%d stands   •   %d rebirths", player:GetAttribute("Capacity") or 4, player:GetAttribute("Rebirths") or 0)
	local price = player:GetAttribute("Level") == 3 and "All stands unlocked"
		or "Expand $" .. tostring(player:GetAttribute("UpgradePrice") or 550)
	upgrade.Text = price
	local cargo = player:GetAttribute("Carrying")
	if cargo and cargo ~= "" then
		objective.Text = "DELIVER HOME OR SELL  /  " .. cargo
		objective.TextColor3 = gold
	else
		objective.Text = "Buy an import on the conveyor"
		objective.TextColor3 = white
	end
end

for _, attribute in ipairs({ "Cash", "Rate", "Capacity", "Level", "Rebirths", "UpgradePrice", "Carrying" }) do
	player:GetAttributeChangedSignal(attribute):Connect(refreshEconomy)
end
refreshEconomy()

task.spawn(function()
	local harbor = workspace:WaitForChild("Blitz Harbor")
	local shop = harbor:WaitForChild("Brainrot Shop")
	local prompt = shop:WaitForChild("Counter"):WaitForChild("SellBrainrot")
	local function refreshSellPrompt()
		local cargo = player:GetAttribute("Carrying")
		local price = player:GetAttribute("SellPrice")
		local canSell = cargo and cargo ~= "" and price ~= nil
		if canSell then
			prompt.ActionText = string.format("Sell %s for $%d", cargo, price)
		end
		prompt.Enabled = canSell == true
	end
	player:GetAttributeChangedSignal("Carrying"):Connect(refreshSellPrompt)
	player:GetAttributeChangedSignal("SellPrice"):Connect(refreshSellPrompt)
	refreshSellPrompt()
end)

local homeMarker = Instance.new("Attachment")
homeMarker.Name = "Home direction"
homeMarker.Parent = workspace.Terrain
local beacon = Instance.new("BillboardGui")
beacon.Size = UDim2.fromOffset(120, 29)
beacon.AlwaysOnTop = true
beacon.MaxDistance = 310
beacon.Parent = homeMarker
label(beacon, 0, 0, 29, 20, aqua, centered).Text = "▼ HOME"

local function markHome()
	local home = player:GetAttribute("Home")
	beacon.Enabled = home ~= nil
	if home then
		homeMarker.Position = home + Vector3.new(0, 13, 0)
	end
end
player:GetAttributeChangedSignal("Home"):Connect(markHome)
markHome()

local function filterStandPrompt(prompt)
	local isOwner = prompt:GetAttribute("OwnerUserId") == player.UserId
	prompt.Enabled = isOwner == prompt:GetAttribute("OwnerOnly")
end

CollectionService:GetInstanceAddedSignal("StandPrompt"):Connect(filterStandPrompt)
for _, prompt in ipairs(CollectionService:GetTagged("StandPrompt")) do
	filterStandPrompt(prompt)
end

local buyPrompts = {}

ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
	if prompt.Style ~= Enum.ProximityPromptStyle.Custom or buyPrompts[prompt] then
		return
	end

	local board = Instance.new("BillboardGui")
	board.Size = UDim2.fromOffset(160, 38)
	board.StudsOffsetWorldSpace = Vector3.new(0, -1.1, 0)
	board.AlwaysOnTop = true
	board.Active = true
	board.Adornee = prompt.Parent
	board.Parent = playerGui

	local button = Instance.new("TextButton")
	button.Size = UDim2.fromScale(1, 1)
	button.BackgroundTransparency = 1
	button.AutoButtonColor = false
	button.Active = true
	button.Font = Enum.Font.GothamBold
	button.TextSize = 17
	button.TextColor3 = green
	local hint
	if inputType == Enum.ProximityPromptInputType.Gamepad then
		hint = prompt.GamepadKeyCode.Name:gsub("^Button", "")
	elseif inputType == Enum.ProximityPromptInputType.Keyboard then
		hint = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
	end
	button.Text = hint and hint ~= "" and ("[" .. hint .. "]  " .. prompt.ActionText) or prompt.ActionText
	outline(button)
	button.Parent = board

	local held
	button.InputBegan:Connect(function(input)
		if not held and (input.UserInputType == Enum.UserInputType.Touch
			or (prompt.ClickablePrompt and input.UserInputType == Enum.UserInputType.MouseButton1)) then
			held = input
			prompt:InputHoldBegin()
		end
	end)
	local release = UserInputService.InputEnded:Connect(function(input)
		if input == held then
			held = nil
			prompt:InputHoldEnd()
		end
	end)
	buyPrompts[prompt] = function()
		release:Disconnect()
		board:Destroy()
		if held then
			prompt:InputHoldEnd()
		end
	end
end)

ProximityPromptService.PromptHidden:Connect(function(prompt)
	local remove = buyPrompts[prompt]
	if remove then
		buyPrompts[prompt] = nil
		remove()
	end
end)

-- Resolve projected label collisions front to back for the local camera.
local function fitConveyorLabels(camera)
	local candidates = {}
	for _, board in ipairs(CollectionService:GetTagged("ConveyorBrainrotLabel")) do
		local stack = board:FindFirstChild("Stack")
		local anchor = board.Parent
		if stack and anchor then
			local position, onScreen = camera:WorldToViewportPoint(anchor.Position + board.StudsOffsetWorldSpace)
			local distance = (camera.CFrame.Position - anchor.Position).Magnitude
			if board.Enabled and onScreen and distance <= board.MaxDistance then
				table.insert(candidates, { board = board, stack = stack, position = position })
			else
				stack.Visible = false
			end
		end
	end
	table.sort(candidates, function(a, b)
		return a.position.Z < b.position.Z
	end)
	local placed = {}
	for _, candidate in ipairs(candidates) do
		local p = candidate.position
		local halfWidth = candidate.board.Size.X.Offset / 2 + 2
		local halfHeight = candidate.board.Size.Y.Offset / 2 + 2
		local overlaps = false
		for _, box in ipairs(placed) do
			if math.abs(p.X - box.x) < halfWidth + box.halfWidth
				and math.abs(p.Y - box.y) < halfHeight + box.halfHeight then
				overlaps = true
				break
			end
		end
		candidate.stack.Visible = not overlaps
		if not overlaps then
			table.insert(placed, { x = p.X, y = p.Y, halfWidth = halfWidth, halfHeight = halfHeight })
		end
	end
end

RunService.PreRender:Connect(function()
	local camera = workspace.CurrentCamera
	if camera then
		fitConveyorLabels(camera)
	end
end)

local function fitHUD()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local width = viewport.X
	local compact = width < 760
	economy.Size = UDim2.fromOffset(width < 480 and 184 or 240, 77)
	alerts.Size = UDim2.fromOffset(width < 480 and 153 or 200, 60)
	orders.Size = UDim2.fromOffset(math.max(1, math.min(width - 26, 440)), 52)
	toast.Size = UDim2.fromOffset(math.max(1, math.min(width - 26, 465)), 46)
	wave.TextSize = width < 480 and 15 or 18
	orders.Position = UDim2.new(0.5, 0, 1, compact and -96 or -24)
	toast.Position = UDim2.new(0.5, 0, 1, compact and -151 or -81)
end

local clock = 1
RunService.Heartbeat:Connect(function(dt)
	clock += dt
	if clock < 0.15 then
		return
	end
	clock = 0
	local now = workspace:GetServerTimeNow()
	local phase = workspace:GetAttribute("WavePhase") or "CLEAR"
	local seconds = math.max(0, math.ceil((workspace:GetAttribute("WaveAt") or now) - now))
	wave.Text = (phase == "CLEAR" and "WAVE ALERT" or phase) .. "  " .. seconds .. "s"
	wave.TextColor3 = phase == "CLEAR" and aqua or phase == "EVACUATE" and gold or red
	local locked = math.max(0, math.ceil((player:GetAttribute("LockUntil") or now) - now))
	local ready = math.max(0, math.ceil((player:GetAttribute("LockReady") or now) - now))
	shield.Text = locked > 0 and ("Shield up  •  " .. locked .. "s") or ready > 0 and ("Shield ready in " .. ready .. "s") or "Shield ready at base"
	shield.TextColor3 = locked > 0 and aqua or muted
	fitHUD()
end)
