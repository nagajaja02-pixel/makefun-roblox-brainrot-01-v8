local Players = game:GetService("Players")
local Data = require(game.ReplicatedStorage.BrainrotData)
local Specs = Data.mutations
local Service = {}
local profiles, store = {}, nil
function Service.decorate(model, unit)
 local spec = Specs[unit.mutation]
 if not spec then return end
 model:SetAttribute("Mutation", unit.mutation)
 for _, part in ipairs(model:GetChildren()) do
  if part:IsA("BasePart") and not part.Name:find("Eye") and part.Name ~= "Pupil" then part.Color = spec.color; part.Material = spec.material end
 end
 local aura = Instance.new("Highlight")
 aura.Name = "MutationAura"; aura.FillColor = spec.color; aura.OutlineColor = spec.color
 aura.FillTransparency = 0.85; aura.OutlineTransparency = 0.35; aura.DepthMode = Enum.HighlightDepthMode.Occluded; aura.Parent = model
 local anchor = Instance.new("Attachment"); anchor.Name = "MutationParticles"; anchor.Parent = model.PrimaryPart
 local emitter = Instance.new("ParticleEmitter")
 emitter.Color = ColorSequence.new(spec.color); emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
 emitter.Rate = spec.rate; emitter.Lifetime = NumberRange.new(0.6,1.2); emitter.Speed = NumberRange.new(spec.speed, spec.speed*2)
 emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.12),NumberSequenceKeypoint.new(0.5,0.3),NumberSequenceKeypoint.new(1,0)})
 emitter.Transparency = NumberSequence.new(0.2,1); emitter.SpreadAngle = Vector2.new(100,100)
 emitter.RotSpeed = NumberRange.new(-spec.speed*70,spec.speed*70); emitter.LightEmission=0.7
 emitter.Acceleration = unit.mutation == "Poison" and Vector3.new(0,3,0) or Vector3.new(0,0.4,0)
 emitter.Parent = anchor
 model:AddTag("BlitzMutation")
end
function Service.record(player, unit)
 if not Specs[unit.mutation] then return end
 for id, entry in ipairs(Data.cast) do
  if entry == unit.entry then
   local key = id .. "_" .. unit.mutation
   local profile = profiles[player]
   if profile then profile.discoveries[key] = true end
   player:SetAttribute("Mutation_" .. key, true)
   return
  end
 end
end
function Service.start(states, onRaid)
 local ok, result = pcall(function() return game:GetService("DataStoreService"):GetDataStore("BlitzV9Profiles") end)
 store = ok and result or nil
 local function save(player)
  local profile, state = profiles[player], states[player]
  if not profile or not profile.loaded or not store or not state then return end
  -- Serialize autosave, leave and shutdown writes; a late autosave must not overwrite a newer inventory.
  while profile.saving do task.wait(0.1) end
  if profiles[player] ~= profile or states[player] ~= state then return end
  profile.saving=true
  -- Keep mutation discoveries forever. Store installed mutated units independently of old cash economy.
  local units = {}
  if state then for index, slot in pairs(state.slots) do
   if Specs[slot.unit.mutation] then
    for id, entry in ipairs(Data.cast) do if entry == slot.unit.entry then table.insert(units,{id=id, mutation=slot.unit.mutation, slot=index}) end end
   end
  end end
  local discoveries = table.clone(profile.discoveries)
  local success = pcall(function() store:UpdateAsync(tostring(player.UserId),function(old)
   old = type(old)=="table" and old or {}
   old.discoveries = type(old.discoveries)=="table" and old.discoveries or {}
   for key in pairs(discoveries) do old.discoveries[key]=true end
   old.level=state and state.level or 1; old.units=units; old.steals=state and (state.steals or 0) or profile.steals or 0
   return old
  end) end)
  profile.saving=false
  if not success then warn("V9 profile save failed: " .. player.UserId) end
 end
 local function join(player)
  if profiles[player] then return end
  local profile={discoveries={}}; profiles[player]=profile
  local success, saved = false,nil
  if store then
   for attempt=1,3 do
    success,saved=pcall(function() return store:GetAsync(tostring(player.UserId)) end)
    if success or player.Parent~=Players then break end
    task.wait(attempt)
   end
  end
  player:SetAttribute("MutationStorageAvailable",store~=nil and success)
  if not store or not success then warn("Mutation persistence unavailable for "..player.UserId.."; old saved data will not be overwritten.") end
  if profiles[player] ~= profile then return end
  if success and type(saved)=="table" then
   for key,value in pairs(saved.discoveries or {}) do
    if type(key)=="string" and value==true then profile.discoveries[key]=true; player:SetAttribute("Mutation_"..key,true) end
   end
   profile.steals=tonumber(saved.steals) or 0
  end
  while player.Parent==Players and (not states[player] or not states[player].ready) do task.wait(0.2) end
  local state=states[player]; if not state or player.Parent~=Players then return end
  if success and type(saved)=="table" then state.level=math.clamp(tonumber(saved.level) or 1,1,3); require(script.Parent.BaseService).refreshStands(state) end
  state.steals=(state.steals or 0)+(profile.steals or 0); player:SetAttribute("Steals",state.steals)
  if success and type(saved)=="table" then
   for _, item in ipairs(type(saved.units)=="table" and saved.units or {}) do
    if type(item)=="table" and Data.cast[item.id] and Specs[item.mutation] then
     local index=require(script.Parent.BaseService).freeSlot(state)
     if index then
      local unit=Data.mutate(Data.create(item.id,false),item.mutation)
      require(script.Parent.BaseService).parkUnit(state,index,{unit=unit},onRaid)
      require(script.Parent.CollectionService).record(player,unit)
     end
    end
   end
  end
  profile.loaded=not store or success
  state.savingRebirth=false
 end
 Players.PlayerAdded:Connect(function(player) task.spawn(join,player) end)
 -- Called by bootstrap BEFORE clearing slots on removal.
 Service.save = save
 for _,player in ipairs(Players:GetPlayers()) do task.spawn(join,player) end
 task.spawn(function() while task.wait(60) do for player in pairs(profiles) do save(player) end end end)
 Players.PlayerRemoving:Connect(function(player) task.delay(1,function() profiles[player]=nil end) end)
 game:BindToClose(function()
  local pending=0
  for player in pairs(profiles) do pending+=1; task.spawn(function() save(player); pending-=1 end) end
  local deadline=os.clock()+25
  while pending>0 and os.clock()<deadline do task.wait(0.1) end
 end)
end
return Service
