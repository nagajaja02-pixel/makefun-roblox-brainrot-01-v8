local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local Http = game:GetService("HttpService")
local Board = {}
local stores, loaded, names, snapshots = {}, {}, {}, {}
local metrics = {"Cash", "Steals", "Rebirths"}
local function budget(kind)
	return DSS:GetRequestBudgetForRequestType(kind) > 0
end
function Board.init(services)
	local output = Instance.new("StringValue")
	output.Name = "GlobalRanks"
	output.Value = "{}"
	output.Parent = game:GetService("ReplicatedStorage")
	for i, metric in ipairs(metrics) do
		local ok, store = pcall(function() return DSS:GetOrderedDataStore("BlitzGlobal" .. metric .. "V1") end)
		if ok then stores[metric] = store end
		local p = Instance.new("Part")
		p.Name = "Leaderboard" .. metric
		p.Size = Vector3.new(23, 16, 0.5)
		p.Position = Vector3.new((i - 2) * 25, 13, 88)
		p.Anchored = true
		p.CanCollide = false
		p.Material = Enum.Material.Metal
		p.Color = Color3.fromRGB(17, 27, 43)
		p.Parent = workspace.Island
	end
	local function join(player)
		local stats = player:WaitForChild("leaderstats")
		local steals = stats:FindFirstChild("Steals") or Instance.new("IntValue")
		steals.Name = "Steals"
		steals.Parent = stats
		local store = stores.Steals
		if not store then return end
		local ok, value = pcall(function() return store:GetAsync(tostring(player.UserId)) end)
		if player.Parent and ok then
			-- Preserve steals earned while the load yielded.
			steals.Value += tonumber(value) or 0
			loaded[player] = true
		end
	end
	local function save(player)
		local stats = player:FindFirstChild("leaderstats")
		if not stats then return end
		for _, metric in ipairs(metrics) do
			local value = stats:FindFirstChild(metric)
			local store = stores[metric]
			if value and store and (metric ~= "Steals" or loaded[player]) and budget(Enum.DataStoreRequestType.SetIncrementSortedAsync) then
				local amount = math.max(0, math.floor(value.Value))
				pcall(function()
					if metric == "Steals" or metric == "Rebirths" then
						store:UpdateAsync(tostring(player.UserId), function(old) return math.max(old or 0, amount) end)
					else store:SetAsync(tostring(player.UserId), amount) end
				end)
			end
		end
	end
	local function refresh()
		for _, metric in ipairs(metrics) do
			local rows = {}
			local store = stores[metric]
			local ok, page = pcall(function()
				if not store or not budget(Enum.DataStoreRequestType.GetSortedAsync) then error("budget") end
				return store:GetSortedAsync(false, 8):GetCurrentPage()
			end)
			if ok then
				for rank, entry in ipairs(page) do
					local id = tonumber(entry.key)
					if not id then continue end
					local cached = names[id]
					if not cached or os.clock() - cached.time > 600 then
						local named, name = pcall(Players.GetNameFromUserIdAsync, Players, id)
						cached = {name = named and name or ("Player " .. id), time = os.clock()}
						names[id] = cached
					end
					table.insert(rows, {id = id, name = cached.name, value = entry.value, rank = rank})
				end
				snapshots[metric] = {rows = rows, global = true}
			elseif not snapshots[metric] or not snapshots[metric].global then
				for _, player in ipairs(Players:GetPlayers()) do
					local stats = player:FindFirstChild("leaderstats")
					local v = stats and stats:FindFirstChild(metric)
					if v then table.insert(rows, {id = player.UserId, name = player.DisplayName, value = v.Value}) end
				end
				table.sort(rows, function(a,b) return a.value > b.value end)
				snapshots[metric] = {rows = rows, global = false}
			end
		end
		output.Value = Http:JSONEncode(snapshots)
		for id, cached in pairs(names) do if os.clock() - cached.time > 1200 then names[id] = nil end end
	end
	Players.PlayerAdded:Connect(join)
	for _, player in ipairs(Players:GetPlayers()) do task.spawn(join, player) end
	Players.PlayerRemoving:Connect(function(player) save(player); loaded[player] = nil end)
	game:BindToClose(function() for _, player in ipairs(Players:GetPlayers()) do save(player) end end)
	task.spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do save(player); task.wait(0.25) end
			refresh()
			task.wait(120)
		end
	end)
end
return Board
