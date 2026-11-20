local Storage=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local Players=game:GetService("Players")
local Data=require(Storage.BrainrotData)
local Definitions=require(Storage.BlitzEvents)
local World=require(script.Parent.World)
local Money=require(script.Parent.MoneyService)
local Service={}
local active, nextAt, remote, conveyor, states
local normal={"Meteor","Gold","Thunder","Rainbow","Lucky"}
local function announce(message,kind)
 remote:FireAllClients(message,kind or "event")
end
local function snapshot(instance,properties)
 local saved={}
 for _,property in ipairs(properties) do saved[property]=instance[property] end
 return function() if instance.Parent then for property,value in pairs(saved) do instance[property]=value end end end
end
function Service.stop(reason)
 if not active then return false end
 local event=active; active=nil
 Data.eventMutation=nil; Data.eventChance=nil
 for _,restore in ipairs(event.restore) do restore() end
 event.effects:Destroy()
 workspace:SetAttribute("BlitzEvent",nil); workspace:SetAttribute("BlitzEventEnds",nil)
 nextAt=workspace:GetServerTimeNow()+240
 workspace:SetAttribute("BlitzNextEvent",nextAt)
 for player,state in pairs(states) do
  if state.ready and event.participants[player] then
   state.cash+=event.definition.reward; Money.publish(state)
   remote:FireClient(player,"Event reward: $"..event.definition.reward,"reward")
  end
 end
 announce(event.definition.title.." finished"..(reason and (" • "..reason) or "")..". Weather restored.")
 return true
end
function Service.startEvent(id)
 local definition=Definitions[id]
 if not definition then return false,"Unknown event ID" end
 if active then return false,"Stop the current event first" end
 local effects=Instance.new("Folder"); effects.Name="BlitzEventEffects"; effects.Parent=workspace
 local event={id=id,definition=definition,effects=effects,restore={},participants={},ends=workspace:GetServerTimeNow()+definition.duration}
 active=event
 table.insert(event.restore,snapshot(Lighting,{"ClockTime","Brightness","Ambient","OutdoorAmbient","FogColor","FogStart","FogEnd"}))
 local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
 if atmosphere then
  table.insert(event.restore,snapshot(atmosphere,{"Color","Decay","Density","Haze","Glare"}))
  atmosphere.Color=definition.color; atmosphere.Decay=definition.color:Lerp(Color3.new(0,0,0),0.4)
  atmosphere.Density=0.3; atmosphere.Haze=2; atmosphere.Glare=0.4
 end
 local clouds=workspace.Terrain:FindFirstChildOfClass("Clouds")
 if clouds then
  table.insert(event.restore,snapshot(clouds,{"Color","Cover","Density"}))
  clouds.Color=definition.color; clouds.Cover=id=="Thunder" and 0.95 or 0.5; clouds.Density=0.8
 end
 Lighting.ClockTime=definition.clock; Lighting.Brightness=2
 Lighting.Ambient=definition.color:Lerp(Color3.new(0.1,0.1,0.1),0.6)
 Lighting.OutdoorAmbient=definition.color; Lighting.FogColor=definition.color; Lighting.FogStart=180; Lighting.FogEnd=650
 local correction=Instance.new("ColorCorrectionEffect"); correction.TintColor=definition.color:Lerp(Color3.new(1,1,1),0.8); correction.Saturation=0.18; correction.Parent=Lighting
 table.insert(event.restore,function() correction:Destroy() end)
 -- Preserve all previous music volume and restore exactly on completion.
 for _,sound in ipairs(game:GetService("SoundService"):GetDescendants()) do
  if sound:IsA("Sound") and sound.Playing then table.insert(event.restore,snapshot(sound,{"Volume"})); sound.Volume*=0.3 end
 end
 local music=Instance.new("Sound"); music.Name="EventMusic"; music.SoundId="rbxasset://sounds/electronicpingshort.wav"
 music.Looped=false; music.PlaybackSpeed=definition.pitch; music.Volume=0.12; music.Parent=effects
 -- A short original pitched motif uses a bundled Roblox sound, avoiding unlicensed external audio IDs.
 local motifs={Meteor={0,3,7,3},Gold={0,4,7,12},Thunder={0,1,7,1},Rainbow={0,4,7,9},Lucky={0,7,4,12},Money={0,4,12,7},Giant={0,-5,0,3},Disco={0,7,10,7},Cosmic={0,3,6,10},Secret={0,7,12,16}}
 task.spawn(function()
  local beat=1
  while active==event do
   local motif=motifs[id]
   music.PlaybackSpeed=definition.pitch*2^(motif[beat]/12); music:Play()
   beat=beat%#motif+1; task.wait(id=="Disco" and 0.3 or 0.55)
  end
 end)
 Data.eventMutation=definition.mutation; Data.eventChance=id=="Lucky" and 0.7 or 0.4
 workspace:SetAttribute("BlitzEvent",id); workspace:SetAttribute("BlitzEventEnds",event.ends)
 announce(definition.title.." started! Special "..definition.mutation.." brainrots on the conveyor.")
 task.spawn(function()
  local pulse=0
  while active==event do
   if workspace:GetServerTimeNow()>=event.ends then Service.stop(); break end
   pulse+=1
   for player,state in pairs(states) do if state.ready then event.participants[player]=true end end
   local unit=Data.mutate(Data.create(id=="Secret" and math.random(12,13) or math.random(#Data.cast),false),definition.mutation)
   conveyor:spawnOffer(World.importCenter,unit,id=="Giant" and 1.65 or nil)
   task.wait(math.max(0.05,math.min(id=="Secret" and 3 or 8,event.ends-workspace:GetServerTimeNow())))
  end
 end)
 return true,definition.title.." started"
end
function Service.start(map, allStates, belt)
 states=allStates; conveyor=belt
 remote=Instance.new("RemoteEvent"); remote.Name="BlitzNotice"; remote.Parent=Storage
 nextAt=workspace:GetServerTimeNow()+180; workspace:SetAttribute("BlitzNextEvent",nextAt)
 task.spawn(function()
  while task.wait(1) do
   if not active and workspace:GetServerTimeNow()>=nextAt then Service.startEvent(normal[math.random(#normal)]) end
  end
 end)
 return Service
end
return Service
