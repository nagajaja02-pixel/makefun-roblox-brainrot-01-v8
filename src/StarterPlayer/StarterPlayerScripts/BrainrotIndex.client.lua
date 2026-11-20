local Players = game:GetService("Players")
local Storage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Data = require(Storage:WaitForChild("BrainrotData"))
local templates = Storage:WaitForChild("BlitzIndexModels")
local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotIndex"
gui.ResetOnSpawn = false
gui.DisplayOrder = 30
gui.Parent = player:WaitForChild("PlayerGui")
local function text(class, parent, content, size, position)
	local item = Instance.new(class)
	item.Size, item.Position = size, position or UDim2.new()
	item.BackgroundColor3 = Color3.fromRGB(30, 43, 64)
	item.TextColor3 = Color3.fromRGB(240, 247, 255)
	item.Font = Enum.Font.GothamBold
	item.TextSize = 14
	item.Text = content
	item.Parent = parent
	return item
end
local toggle = Instance.new("BindableEvent")
toggle.Name = "Toggle"
toggle.Parent = gui
local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(1, -20, 0.85, 0)
panel.BackgroundColor3 = Color3.fromRGB(17, 25, 40)
panel.Visible = false
panel.Parent = gui
panel.Active = true
gui:SetAttribute("IsOpen", false)
panel:GetPropertyChangedSignal("Visible"):Connect(function()
 gui:SetAttribute("IsOpen", panel.Visible)
end)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(960, 740)
limit.Parent = panel
local progress = text("TextLabel", panel, "COLLECTION", UDim2.new(1, -62, 0, 36))
local close = text("TextButton", panel, "X", UDim2.fromOffset(42, 36), UDim2.new(1, -42, 0, 0))
local search = text("TextBox", panel, "", UDim2.new(1, -16, 0, 36), UDim2.fromOffset(8, 42))
search.PlaceholderText = "Search collected characters..."
search.ClearTextOnFocus = false
local filters = Instance.new("ScrollingFrame")
filters.Size = UDim2.new(1, -16, 0, 42)
filters.Position = UDim2.fromOffset(8, 84)
filters.BackgroundTransparency = 1
filters.AutomaticCanvasSize = Enum.AutomaticSize.X
filters.CanvasSize = UDim2.new()
filters.ScrollBarThickness = 3
filters.Parent = panel
local row = Instance.new("UIListLayout")
row.FillDirection = Enum.FillDirection.Horizontal
row.Padding = UDim.new(0, 5)
row.Parent = filters
local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(8, 132)
list.Size = UDim2.new(1, -16, 1, -140)
list.BackgroundTransparency = 1
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.ScrollBarThickness = 6
list.Parent = panel
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list
local selected = 0
local sections, cards, grids, buttons = {}, {}, {}, {}
for tier, rarity in ipairs(Data.rarities) do
	local section = Instance.new("Frame")
	section.BackgroundTransparency = 1
	section.Size = UDim2.new(1, -8, 0, 100)
	section.LayoutOrder = tier
	section.Parent = list
	sections[tier] = section
	local heading = text("TextLabel", section, rarity.name, UDim2.new(1, 0, 0, 28))
	heading.TextColor3 = rarity.color
	local body = Instance.new("Frame")
	body.Position = UDim2.fromOffset(0, 34)
	body.Size = UDim2.new(1, 0, 0, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.BackgroundTransparency = 1
	body.Parent = section
	local grid = Instance.new("UIGridLayout")
	grid.CellPadding = UDim2.fromOffset(8, 8)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = body
	grids[tier] = grid
	grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		section.Size = UDim2.new(1, -8, 0, 34 + grid.AbsoluteContentSize.Y)
	end)
	local ids = {}
	for id, entry in ipairs(Data.cast) do if entry[2] == tier then table.insert(ids, id) end end
	table.sort(ids, function(a, b) return Data.cast[a][3] < Data.cast[b][3] end)
	for order, id in ipairs(ids) do
		local card = Instance.new("Frame")
		card.Name = "Entry" .. id
		card.LayoutOrder = order
		card.BackgroundColor3 = Color3.fromRGB(30, 43, 64)
		card.Parent = body
		local view = Instance.new("ViewportFrame")
		view.Size = UDim2.new(1, 0, 0, 130)
		view.BackgroundTransparency = 1
		view.Parent = card
		local world = Instance.new("WorldModel")
		world.Parent = view
		local camera = Instance.new("Camera")
		camera.Parent = view
		view.CurrentCamera = camera
		local name = text("TextLabel", card, "???", UDim2.new(1, -8, 0, 38), UDim2.fromOffset(4, 130))
		name.TextWrapped = true
		local detail = text("TextLabel", card, "Not discovered", UDim2.new(1, -8, 0, 46), UDim2.fromOffset(4, 168))
		detail.TextWrapped = true
		detail.TextSize = 12
		cards[id] = {frame = card, view = view, world = world, camera = camera, name = name, detail = detail}
	end
end
local function resize()
	local width = math.max(100, list.AbsoluteSize.X - 8)
	local columns = math.max(1, math.floor((width + 8) / 168))
	for _, grid in ipairs(grids) do grid.CellSize = UDim2.fromOffset(math.floor((width - (columns - 1) * 8) / columns), 308) end
end
local function refresh()
	local count = 0
	local visible = {}
	local query = string.lower(search.Text)
	for id, entry in ipairs(Data.cast) do
		local owned = player:GetAttribute("Discovered_" .. id) == true
		if owned then count += 1 end
		local card = cards[id]
		if card.owned ~= owned then
			card.owned = owned
			card.world:ClearAllChildren()
			local model = templates:WaitForChild(tostring(id)):Clone()
			model.Parent = card.world
			if not owned then
				for _, part in ipairs(model:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Color = Color3.fromRGB(8, 9, 12)
						part.Material = Enum.Material.SmoothPlastic
					end
				end
			end
			local frame, size = model:GetBoundingBox()
			local distance = math.max(size.X, size.Y, size.Z) * 1.85
			card.camera.CFrame = CFrame.lookAt(frame.Position + Vector3.new(distance * 0.25, distance * 0.15, -distance), frame.Position)
			card.name.Text = owned and entry[1] or "???"
			card.detail.Text = owned and string.format("$%d • +$%d/s\n%s", entry[3], entry[4], Data.rarities[entry[2]].name) or "Not discovered"
		end
		if owned then
			local mutations = {}
			for _, mutation in ipairs({"Gold","Diamond","Rainbow","Electric","Poison","Cosmic","Celestial"}) do
				if player:GetAttribute("Mutation_"..id.."_"..mutation) then
					local spec = Data.mutations[mutation]
					table.insert(mutations, mutation.." x"..spec.multiplier.." • "..spec.effect)
				end
			end
			card.detail.Text = string.format("$%d • +$%d/s • %s",entry[3],entry[4],Data.rarities[entry[2]].name)
				.. (#mutations > 0 and ("\n"..table.concat(mutations,"\n")) or "\nNo mutations discovered")
			local height = math.max(46, 28 + #mutations * 15)
			card.detail.Size = UDim2.new(1,-8,0,height)
		end
		-- Search only revealed names, so searching cannot disclose locked identities.
		local matches = query == "" or (owned and string.find(string.lower(entry[1]), query, 1, true) ~= nil)
		card.frame.Visible = (selected == 0 or selected == entry[2]) and matches
		if card.frame.Visible then visible[entry[2]] = true end
	end
	for tier, section in ipairs(sections) do section.Visible = visible[tier] == true end
	for tier, button in pairs(buttons) do
		button.BackgroundColor3 = tier == selected and Color3.fromRGB(54, 110, 104) or Color3.fromRGB(30, 43, 64)
	end
	progress.Text = string.format("COLLECTION  %d / %d", count, #Data.cast)
	resize()
end
for tier = 0, #Data.rarities do
	local button = text("TextButton", filters, tier == 0 and "All" or Data.rarities[tier].name, UDim2.fromOffset(96, 36))
	buttons[tier] = button
	button.Activated:Connect(function() selected = tier; refresh() end)
end
for id in ipairs(Data.cast) do player:GetAttributeChangedSignal("Discovered_" .. id):Connect(refresh) end
player.AttributeChanged:Connect(function(name) if name:sub(1,9) == "Mutation_" then refresh() end end)
search:GetPropertyChangedSignal("Text"):Connect(refresh)
list:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
toggle.Event:Connect(function() panel.Visible = not panel.Visible; if panel.Visible then refresh() end end)
close.Activated:Connect(function() panel.Visible = false end)
refresh()
