local RS = game:GetService("ReplicatedStorage")
local Http = game:GetService("HttpService")
local Tween = game:GetService("TweenService")
local data = RS:WaitForChild("GlobalRanks")
local function refresh()
	local ok, decoded = pcall(Http.JSONDecode, Http, data.Value)
	if not ok then return end
	for metric, snapshot in pairs(decoded) do
		local board = workspace:WaitForChild("Island"):FindFirstChild("Leaderboard" .. metric)
		if not board then continue end
		local old = board:FindFirstChild("RanksUI")
		if old then old:Destroy() end
		local gui = Instance.new("SurfaceGui")
		gui.Name = "RanksUI"
		gui.CanvasSize = Vector2.new(690, 480)
		gui.Face = Enum.NormalId.Front
		gui.Parent = board
		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1,0,0,55)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.TextSize = 26
		title.TextColor3 = Color3.fromRGB(100,240,220)
		title.Text = string.upper(metric) .. (snapshot.global and " • WORLD TOP 8" or " • SERVER / OFFLINE")
		title.Parent = gui
		for rank, row in ipairs(snapshot.rows) do
			if rank > 8 then break end
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1,-90,0,46)
			label.Position = UDim2.fromOffset(80, 55 + (rank-1)*51)
			label.BackgroundColor3 = Color3.fromRGB(27,42,62)
			label.TextColor3 = Color3.new(1,1,1)
			label.Font = Enum.Font.GothamMedium
			label.TextSize = 22
			label.Text = "#" .. rank .. "   " .. row.name .. "   •   " .. row.value
			label.TextTransparency = 1
			label.Parent = gui
			local avatar = Instance.new("ImageLabel")
			avatar.Size = UDim2.fromOffset(44,44)
			avatar.Position = UDim2.fromOffset(22, 55 + (rank-1)*51)
			avatar.BackgroundTransparency = 1
			avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. row.id .. "&w=150&h=150"
			avatar.Parent = gui
			Tween:Create(label,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,rank*0.035),{TextTransparency=0}):Play()
		end
	end
end
data.Changed:Connect(refresh)
refresh()
