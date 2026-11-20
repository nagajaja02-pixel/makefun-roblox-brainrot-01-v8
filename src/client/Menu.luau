-- Menu: the rebirth menu, the character index, the merchant stall and the
-- sell grid, all in one panel the player opens with the MENU button or B.
-- The index reads the shared character data; rebirth and selling go to the
-- server through remotes, which validate everything.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotData = require(ReplicatedStorage.Shared.BrainrotData)

local Menu = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local panel = nil
local merchantList = nil
local merchantStock = {}

-- A section heading inside the panel.
local function heading(parent, text, y)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 30)
	label.Position = UDim2.new(0, 10, 0, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 220, 90)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

-- A button row: a label on the left, a button on the right.
local function rowButton(parent, text, buttonText, y, onClick)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, 34)
	label.Position = UDim2.new(0, 10, 0, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(240, 240, 240)
	label.TextScaled = true
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 120, 0, 34)
	button.Position = UDim2.new(1, -130, 0, y)
	button.BackgroundColor3 = Color3.fromRGB(60, 140, 90)
	button.Text = buttonText
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
	button.MouseButton1Click:Connect(onClick)
	return button
end

-- Build the panel once. Sections: rebirth, merchant, character index,
-- and the sell grid.
local function buildPanel()
	local screen = Instance.new("ScreenGui")
	screen.Name = "BlitzMenu"
	screen.ResetOnSpawn = false
	screen.Parent = playerGui

	panel = Instance.new("ScrollingFrame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0.94, 0, 0.86, 0)
	local sizeLimit = Instance.new("UISizeConstraint")
	sizeLimit.MaxSize = Vector2.new(460, 620)
	sizeLimit.Parent = panel
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.CanvasSize = UDim2.new(0, 0, 0, 0)
	panel.ScrollBarThickness = 6
	panel.Parent = screen

	local y = 10
	heading(panel, "REBIRTH", y)
	y += 34
	local rebirthLabel = Instance.new("TextLabel")
	rebirthLabel.Name = "RebirthInfo"
	rebirthLabel.Size = UDim2.new(1, -20, 0, 74)
	rebirthLabel.Position = UDim2.new(0, 10, 0, y)
	rebirthLabel.BackgroundTransparency = 1
	rebirthLabel.Text = ""
	rebirthLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	rebirthLabel.TextScaled = true
	rebirthLabel.Font = Enum.Font.Gotham
	rebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
	rebirthLabel.Parent = panel
    rebirthLabel.TextWrapped = true
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 10)
    track.Position = UDim2.fromOffset(10, y + 78)
    track.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
    track.BorderSizePixel = 0
    track.Parent = panel
    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = Color3.fromRGB(130, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    y += 96
	rowButton(panel, "Rebirth: +50% income forever", "REBIRTH", y, function()
		ReplicatedStorage:WaitForChild("Rebirth"):FireServer()
	end)
	y += 44

	heading(panel, "MERCHANT", y)
	y += 34
	merchantList = Instance.new("Frame")
	merchantList.Name = "MerchantList"
	merchantList.Size = UDim2.new(1, -20, 0, 120)
	merchantList.Position = UDim2.new(0, 10, 0, y)
	merchantList.BackgroundTransparency = 1
	merchantList.Parent = panel
	y += 130

	heading(panel, "CHARACTER INDEX", y)
	y += 34
	rowButton(panel, "Discover the harbor collection", "OPEN INDEX", y, function()
        require(script.Parent.PremiumIndex).open()
    end)
    y += 40
	y += 8

	heading(panel, "SELL (your stands)", y)
	y += 34
	for stand = 1, 8 do
		rowButton(panel, "Stand " .. tostring(stand) .. " - sell for half price", "SELL", y, function()
			ReplicatedStorage:WaitForChild("SellBrainrot"):FireServer(stand)
		end)
		y += 38
	end

	panel.CanvasSize = UDim2.new(0, 0, 0, y + 10)

	-- Keep the rebirth line honest: it shows the next cost from the
	-- player's current rebirth count.
	local stats = player:WaitForChild("leaderstats")
	local rebirthsValue = stats:WaitForChild("Rebirths")
	local cashValue = stats:WaitForChild("Cash")
	local function refreshRebirth()
		local count = rebirthsValue.Value
		local cost = BrainrotData.rebirthCost(count)
        local ratio = math.clamp(cashValue.Value / cost, 0, 1)
        rebirthLabel.Text = "Rebirth " .. count .. " • $" .. cashValue.Value .. " / $" .. cost .. " (" .. math.floor(ratio * 100) .. "%)"
            .. "\nIncome: ×" .. (1 + count * BrainrotData.Economy.rebirthBoost) .. " → ×" .. (1 + (count + 1) * BrainrotData.Economy.rebirthBoost)
            .. "\nSpend the required cash to gain +0.5× base income permanently."
        game:GetService("TweenService"):Create(fill, TweenInfo.new(0.35), {Size = UDim2.fromScale(ratio, 1)}):Play()
	end
	rebirthsValue.Changed:Connect(function()
        refreshRebirth()
        rebirthLabel.TextColor3 = Color3.fromRGB(255, 224, 110)
        game:GetService("TweenService"):Create(rebirthLabel, TweenInfo.new(0.9), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
    end)
    cashValue.Changed:Connect(refreshRebirth)
	refreshRebirth()
end

-- Refresh the merchant rows from the latest stock.
local function refreshMerchant()
	if merchantList == nil then
		return
	end
	for _, child in ipairs(merchantList:GetChildren()) do
		child:Destroy()
	end
	local y = 0
	for _, entry in ipairs(merchantStock) do
		local char = BrainrotData.byId(entry.id)
		if char ~= nil then
			rowButton(merchantList, char.name .. "  •  $" .. tostring(entry.price), "BUY", y, function()
				ReplicatedStorage:WaitForChild("BuyMerchant"):FireServer(entry.id)
			end)
			y += 38
		end
	end
end

-- The server turns the merchant stock over; the menu shows the new one.
function Menu.setMerchantStock(payload)
	merchantStock = payload or {}
	refreshMerchant()
end

-- Show or hide the panel.
function Menu.toggle()
	if panel == nil then
		buildPanel()
	end
	panel.Visible = not panel.Visible
end

return Menu
