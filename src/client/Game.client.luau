-- Game.client: the client entry point. It builds the HUD (cash, income,
-- rebirths), the shield and menu buttons, the tsunami warning banner, and
-- a short camera sweep over the island when the player first spawns.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Menu = require(script.Parent.Menu)
local CarryPose = require(script.Parent.CarryPose)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- The HUD: a top bar with the numbers that matter.
local screen = Instance.new("ScreenGui")
screen.Name = "BlitzHUD"
screen.ResetOnSpawn = false
screen.Parent = playerGui

local bar = Instance.new("Frame")
bar.Name = "TopBar"
bar.Size = UDim2.new(1, 0, 0, 56)
bar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
bar.BackgroundTransparency = 0.15
bar.BorderSizePixel = 0
bar.Parent = screen

local function statLabel(name, x, text, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(0, 170, 1, 0)
	label.Position = UDim2.new(0, x, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = bar
	return label
end

local cashLabel = statLabel("Cash", 12, "Cash: $0", Color3.fromRGB(255, 220, 90))
local incomeLabel = statLabel("Income", 190, "Income: $0/s", Color3.fromRGB(120, 230, 120))
local rebirthLabel = statLabel("Rebirths", 368, "Rebirths: 0", Color3.fromRGB(160, 200, 255))

-- The shield button: raises the shield, then shows its cooldown.
local shieldButton = Instance.new("TextButton")
shieldButton.Name = "ShieldButton"
shieldButton.Size = UDim2.new(0, 150, 0, 40)
shieldButton.Position = UDim2.new(1, -330, 0, 8)
shieldButton.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
shieldButton.Text = "SHIELD"
shieldButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shieldButton.TextScaled = true
shieldButton.Font = Enum.Font.GothamBold
shieldButton.Parent = bar

-- The menu button: opens rebirth and the character index.
local menuButton = Instance.new("TextButton")
menuButton.Name = "MenuButton"
menuButton.Size = UDim2.new(0, 150, 0, 40)
menuButton.Position = UDim2.new(1, -170, 0, 8)
menuButton.BackgroundColor3 = Color3.fromRGB(90, 60, 160)
menuButton.Text = "MENU"
menuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
menuButton.TextScaled = true
menuButton.Font = Enum.Font.GothamBold
menuButton.Parent = bar

-- The tsunami banner: hidden until a wave is announced.
local banner = Instance.new("TextLabel")
banner.Name = "WaveBanner"
banner.Size = UDim2.new(0, 520, 0, 64)
banner.Position = UDim2.new(0.5, -260, 0, 70)
banner.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
banner.BackgroundTransparency = 0.2
banner.Text = ""
banner.TextColor3 = Color3.fromRGB(255, 255, 255)
banner.TextScaled = true
banner.Font = Enum.Font.GothamBold
banner.Visible = false
banner.Parent = screen

-- Keep the numbers in step with the server's leaderstats.
local function bindStats()
	local stats = player:WaitForChild("leaderstats")
	local cashValue = stats:WaitForChild("Cash")
	local incomeValue = stats:WaitForChild("Income")
	local rebirthValue = stats:WaitForChild("Rebirths")
	local function refresh()
		cashLabel.Text = "Cash: $" .. tostring(cashValue.Value)
		incomeLabel.Text = "Income: $" .. tostring(incomeValue.Value) .. "/s"
		rebirthLabel.Text = "Rebirths: " .. tostring(rebirthValue.Value)
	end
	cashValue.Changed:Connect(refresh)
	incomeValue.Changed:Connect(refresh)
	rebirthValue.Changed:Connect(refresh)
	refresh()
end

-- The shield button: fire the raise remote, then count the full cycle
-- (twenty-six seconds up, forty-eight cooling down) on the button itself.
local shieldCooling = false
local function onShield()
	if shieldCooling then
		return
	end
	local remote = ReplicatedStorage:WaitForChild("RaiseShield")
	remote:FireServer()
	shieldCooling = true
	task.spawn(function()
		for left = 74, 1, -1 do
			shieldButton.Text = "SHIELD " .. tostring(left) .. "s"
			task.wait(1)
		end
		shieldButton.Text = "SHIELD"
		shieldCooling = false
	end)
end
shieldButton.MouseButton1Click:Connect(onShield)

-- The menu button and the B key both toggle the menu.
menuButton.MouseButton1Click:Connect(function()
	Menu.toggle()
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.B then
		Menu.toggle()
	elseif input.KeyCode == Enum.KeyCode.F then
		onShield()
	end
end)

-- The tsunami remote drives the warning banner.
local tsunami = ReplicatedStorage:WaitForChild("Tsunami")
tsunami.OnClientEvent:Connect(function(kind, seconds)
	if kind == "warn" then
		banner.Visible = true
		banner.Text = "TSUNAMI IN " .. tostring(seconds) .. "s - GET TO HIGH GROUND!"
		task.spawn(function()
			for left = seconds, 1, -1 do
				if not banner.Visible then
					return
				end
				banner.Text = "TSUNAMI IN " .. tostring(left) .. "s - GET TO HIGH GROUND!"
				task.wait(1)
			end
		end)
	elseif kind == "sweep" then
		banner.Visible = true
		banner.Text = "WAVE! STAY HIGH!"
	elseif kind == "clear" then
		banner.Visible = false
		banner.Text = ""
	end
end)

-- The merchant stock is handed to the menu whenever it turns over.
local merchantStock = ReplicatedStorage:WaitForChild("MerchantStock")
merchantStock.OnClientEvent:Connect(function(payload)
	Menu.setMerchantStock(payload)
end)

-- The carry pose: arms up whenever the player is carrying a brainrot.
CarryPose.watch(player)

-- A short camera sweep over the island on first spawn, then the normal
-- camera takes over. Any failure leaves the default camera alone.
local function introCamera()
	local camera = workspace.CurrentCamera
	if camera == nil then
		return
	end
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")
	local ok = pcall(function()
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.new(0, 90, 120) * CFrame.lookAt(Vector3.new(0, 90, 120), Vector3.new(0, 0, 0))
		local tween = TweenService:Create(camera, TweenInfo.new(2.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(root.Position + Vector3.new(0, 14, 22), root.Position),
		})
		tween:Play()
		tween.Completed:Wait()
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = character:FindFirstChildOfClass("Humanoid")
	end)
	if not ok then
		camera.CameraType = Enum.CameraType.Custom
	end
end

bindStats()
task.spawn(introCamera)
