local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage:WaitForChild("BrainrotData"))

local Menu = {}
local pink = Color3.fromRGB(213, 54, 136)
local blue = Color3.fromRGB(37, 114, 204)
local green = Color3.fromRGB(104, 255, 142)

local function text(parent, className, value, size, position, bounds)
	local item = Instance.new(className)
	item.Size = bounds
	item.Position = position
	item.BackgroundTransparency = 1
	item.Text = value
	item.TextSize = size
	item.Font = Enum.Font.GothamBlack
	item.TextColor3 = Color3.new(1, 1, 1)
	item.TextStrokeColor3 = Color3.new(0, 0, 0)
	item.TextStrokeTransparency = 0
	item.Parent = parent
	return item
end

local function style(frame, color, transparency)
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = transparency
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame
	local edge = Instance.new("UIStroke")
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Thickness = 2
	edge.Parent = frame
end

function Menu.mount(hud, player)
	local gui = Instance.new("ScreenGui")
	gui.Name = "Blitz Menus"
	gui.DisplayOrder = 2
	gui.ResetOnSpawn = false
	gui.Parent = hud.Parent

	local shortcuts = Instance.new("Frame")
	shortcuts.Size = UDim2.fromOffset(74, 136)
	shortcuts.Position = UDim2.new(0, 12, 0.47, 0)
	shortcuts.AnchorPoint = Vector2.new(0, 0.5)
	shortcuts.BackgroundTransparency = 1
	shortcuts.Parent = gui

	local window = Instance.new("Frame")
	window.Size = UDim2.new(0.9, 0, 0.8, 0)
	window.Position = UDim2.fromScale(0.5, 0.5)
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Active = true
	window.Visible = false
	window.Parent = gui
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(412, 365)
	limit.Parent = window

	local title = text(window, "TextLabel", "", 25, UDim2.fromOffset(52, 6), UDim2.new(1, -104, 0, 38))
	local close = text(window, "TextButton", "×", 25, UDim2.new(1, -45, 0, 8), UDim2.fromOffset(36, 32))

	local rebirth = Instance.new("Frame")
	rebirth.BackgroundTransparency = 1
	rebirth.Size = UDim2.new(1, -24, 1, -58)
	rebirth.Position = UDim2.fromOffset(12, 48)
	rebirth.Parent = window
	local description = text(rebirth, "TextLabel", "", 17, UDim2.new(), UDim2.new(1, 0, 1, -51))
	description.TextWrapped = true
	description.TextScaled = true
	local descriptionSize = Instance.new("UITextSizeConstraint")
	descriptionSize.MaxTextSize = 19
	descriptionSize.Parent = description
	local confirm = text(rebirth, "TextButton", "Confirm", 17, UDim2.new(0, 0, 1, -42), UDim2.new(0.5, -4, 0, 40))
	style(confirm, Color3.fromRGB(26, 129, 66), 0.08)
	local cancel = text(rebirth, "TextButton", "Cancel", 17, UDim2.new(0.5, 4, 1, -42), UDim2.new(0.5, -4, 0, 40))
	style(cancel, Color3.fromRGB(119, 47, 94), 0.08)

	local index = Instance.new("ScrollingFrame")
	index.Position = UDim2.fromOffset(12, 48)
	index.Size = UDim2.new(1, -24, 1, -58)
	index.BackgroundTransparency = 1
	index.BorderSizePixel = 0
	index.ScrollBarThickness = 5
	index.CanvasSize = UDim2.new()
	index.AutomaticCanvasSize = Enum.AutomaticSize.Y
	index.Parent = window
	local layout = Instance.new("UIListLayout")
	layout.Parent = index
	for order, entry in ipairs(Data.cast) do
		local rarity = Data.rarities[entry[2]]
		local row = Instance.new("Frame")
		row.LayoutOrder = order
		row.Size = UDim2.new(1, -8, 0, 46)
		row.BackgroundTransparency = 1
		row.Parent = index
		local name = text(row, "TextLabel", entry[1], 16, UDim2.new(), UDim2.new(1, -78, 0, 23))
		name.TextXAlignment = Enum.TextXAlignment.Left
		local tier = text(row, "TextLabel", rarity.name, 13, UDim2.fromOffset(0, 23), UDim2.new(1, -78, 0, 19))
		tier.TextXAlignment = Enum.TextXAlignment.Left
		tier.TextColor3 = rarity.color
		local rate = text(row, "TextLabel", string.format("+$%d/s", entry[4]), 14,
			UDim2.new(1, -78, 0, 0), UDim2.new(0, 78, 1, 0))
		rate.TextColor3 = green
		rate.TextXAlignment = Enum.TextXAlignment.Right
	end

	local function refresh()
		local price = player:GetAttribute("RebirthPrice")
		local count = player:GetAttribute("Rebirths") or 0
		confirm.Active = price ~= nil
		description.Text = string.format(
			"Required cash  %s\n\n+50%% income per rebirth\nMultiplier  %gx → %gx\n\nCash resets to $150 and your collection is cleared. Stand upgrades stay.\n\nDeliver any carried brainrot and wait for raids on your safehouse to finish.",
			price and ("$" .. price) or "Loading…", 1 + 0.5 * count, 1 + 0.5 * (count + 1))
	end

	local function hide()
		window.Visible = false
		shortcuts.Visible = true
	end

	style(window, pink, 0.18)
	for order, option in ipairs({
		{ "Rebirth", "⟳", pink, rebirth },
		{ "Index", "📘", blue, index },
	}) do
		local button = text(shortcuts, "TextButton", "", 15, UDim2.fromOffset(0, (order - 1) * 70), UDim2.fromOffset(74, 63))
		style(button, option[3], 0.18)
		text(button, "TextLabel", option[2], 34, UDim2.new(), UDim2.new(1, 0, 0, 40))
		text(button, "TextLabel", option[1], 14, UDim2.fromOffset(0, 37), UDim2.new(1, 0, 0, 21))
		button.Activated:Connect(function()
			title.Text = option[1]
			window.BackgroundColor3 = option[3]
			rebirth.Visible = option[4] == rebirth
			index.Visible = option[4] == index
			window.Visible = true
			shortcuts.Visible = false
		end)
	end

	close.Activated:Connect(hide)
	cancel.Activated:Connect(hide)
	confirm.Activated:Connect(function()
		if player:GetAttribute("RebirthPrice") then
			hide()
			ReplicatedStorage:WaitForChild("BlitzRebirth"):FireServer()
		end
	end)
	player:GetAttributeChangedSignal("RebirthPrice"):Connect(refresh)
	player:GetAttributeChangedSignal("Rebirths"):Connect(refresh)
	refresh()
end

return Menu
