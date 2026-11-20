local Players = game:GetService("Players")
local Storage = game:GetService("ReplicatedStorage")
local Data = require(Storage.BrainrotData)
local Collection = {}
local sessions = {}
local store
local function publish(player, owned)
	for id in pairs(owned) do player:SetAttribute("Discovered_" .. id, true) end
end
function Collection.record(player, unit)
	require(script.Parent.MutationService).record(player, unit)
	for id, entry in ipairs(Data.cast) do
		if entry == unit.entry then
			local session = sessions[player]
			if session then
				session.owned[tostring(id)] = true
				player:SetAttribute("Discovered_" .. id, true)
			end
			return
		end
	end
end
local function save(player)
	local session = sessions[player]
	if not store or not session or not next(session.owned) then return end
	local snapshot = table.clone(session.owned)
	local ok = pcall(function()
		store:UpdateAsync(tostring(player.UserId), function(previous)
			local merged = type(previous) == "table" and previous or {}
			for id in pairs(snapshot) do merged[id] = true end
			return merged
		end)
	end)
	if not ok then warn("Collection save unavailable for " .. player.UserId) end
end
function Collection.start()
	local ok, result = pcall(function()
		return game:GetService("DataStoreService"):GetDataStore("BlitzCollectionV1")
	end)
	store = ok and result or nil
	local templates = Instance.new("Folder")
	templates.Name = "BlitzIndexModels"
	for id in ipairs(Data.cast) do
		local model = require(script.Parent.BrainrotModels).sculpt(templates, Data.create(id, false), CFrame.new(), nil)
		model.Name = tostring(id)
	end
	templates.Parent = Storage
	local function join(player)
		if sessions[player] then return end
		local session = {owned = {}}
		sessions[player] = session
		if store then
			local loaded, owned = pcall(function() return store:GetAsync(tostring(player.UserId)) end)
			if sessions[player] ~= session then return end
			if loaded and type(owned) == "table" then
				for id, value in pairs(owned) do
					if value == true and Data.cast[tonumber(id)] then session.owned[tostring(id)] = true end
				end
			end
		end
		publish(player, session.owned)
	end
	Players.PlayerAdded:Connect(join)
	Players.PlayerRemoving:Connect(function(player) save(player); sessions[player] = nil end)
	for _, player in ipairs(Players:GetPlayers()) do task.spawn(join, player) end
	task.spawn(function()
		while task.wait(60) do for player in pairs(sessions) do save(player) end end
	end)
	game:BindToClose(function()
		local pending = 0
		for player in pairs(sessions) do
			pending += 1
			task.spawn(function() save(player); pending -= 1 end)
		end
		local deadline = os.clock() + 25
		while pending > 0 and os.clock() < deadline do task.wait(0.1) end
	end)
end
return Collection
