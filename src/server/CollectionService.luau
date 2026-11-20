-- Discovery is additive and stored separately from cash, stands and rebirths.
local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local Collection = {}
local state = {}
local store = DSS:GetDataStore("BlitzCollectionV1")
local function join(player)
 local folder = Instance.new("Folder")
 folder.Name = "Collection"
 folder.Parent = player
 local record = {ids={}, loaded=false, dirty=false, folder=folder}
 state[player] = record
 task.spawn(function()
  for attempt=1,3 do
   local ok, saved = pcall(function() return store:GetAsync(tostring(player.UserId)) end)
   if ok then
    for id, value in pairs(type(saved)=="table" and saved or {}) do
     if value == true then record.ids[id]=true; folder:SetAttribute(id,true) end
    end
    record.loaded=true
    return
   end
   task.wait(attempt*5)
  end
 end)
end
function Collection.discover(player, id)
 local record=state[player]
 if not record or record.ids[id] then return end
 record.ids[id]=true
 record.dirty=true
 record.folder:SetAttribute(id,true)
end
local function save(player)
 local record=state[player]
 if not record or not record.dirty then return end
 -- UpdateAsync unions IDs even if the initial read failed; never erase discoveries.
 local ids=table.clone(record.ids)
 local ok=pcall(function()
  store:UpdateAsync(tostring(player.UserId), function(old)
   local merged=type(old)=="table" and old or {}
   for id in pairs(ids) do merged[id]=true end
   return merged
  end)
 end)
 if ok then
  record.dirty=false
  for id in pairs(record.ids) do if not ids[id] then record.dirty=true end end
 end
end
function Collection.init()
 Players.PlayerAdded:Connect(join)
 for _,player in ipairs(Players:GetPlayers()) do join(player) end
 Players.PlayerRemoving:Connect(function(player) save(player); state[player]=nil end)
 game:BindToClose(function() for player in pairs(state) do save(player) end end)
 task.spawn(function()
  while true do
   task.wait(90)
   for player in pairs(state) do save(player); task.wait(0.2) end
  end
 end)
end
return Collection
