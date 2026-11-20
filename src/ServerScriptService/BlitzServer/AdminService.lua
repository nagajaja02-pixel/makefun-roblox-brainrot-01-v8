local Players=game:GetService("Players")
local Storage=game:GetService("ReplicatedStorage")
local TextChat=game:GetService("TextChatService")
local Data=require(Storage.BrainrotData)
local World=require(script.Parent.World)
local Money=require(script.Parent.MoneyService)
local Base=require(script.Parent.BaseService)
local Service={}
local ADMIN=7445776793
function Service.start(states,conveyor,events,onRaid,notify)
 local remote=Instance.new("RemoteEvent"); remote.Name="BlitzAdmin"; remote.Parent=Storage
 local cooldown={}
 local function target(text,actor)
  if text=="me" then return actor end
  local matches={}
  for _,player in ipairs(Players:GetPlayers()) do
   if tostring(player.UserId)==text or player.Name:lower()==(text or ""):lower() then return player end
   if text and #text>0 and player.Name:lower():sub(1,#text)==text:lower() then table.insert(matches,player) end
  end
  if #matches==1 then return matches[1] end
 end
 local function run(player,line)
  if player.UserId~=ADMIN then return end
  if type(line)~="string" or #line>400 or os.clock()<(cooldown[player] or 0) then return end
  cooldown[player]=os.clock()+0.35
  local args=string.split(line," ")
  local command=string.lower(table.remove(args,1) or ""):gsub("^/blitz$","")
  if command=="" then command=string.lower(table.remove(args,1) or "") end
  local function number(value,min,max)
   local n=tonumber(value); if n and n==n and n>=min and n<=max then return n end
  end
  local function execute()
   if command=="start" then local ok,msg=events.startEvent(args[1]); return msg or tostring(ok)
   elseif command=="stop" then return events.stop("Admin stopped event") and "Event stopped" or "No active event"
   elseif command=="announce" then
    local message=table.concat(args," "); if #message==0 then return "Message required" end
    -- Filter custom messages before broadcasting to other players.
    local filtered=game:GetService("TextService"):FilterStringAsync(message,player.UserId):GetNonChatStringForBroadcastAsync()
    Storage.BlitzNotice:FireAllClients(filtered,"admin"); return "Announcement sent"
   elseif command=="spawn" then
    local id=number(args[1],1,#Data.cast); if not id or id%1~=0 then return "Use spawn <cast ID> [mutation]" end
    local mutation=args[2] or ""; if mutation~="" and not Data.mutations[mutation] then return "Unknown mutation (case sensitive)" end
    conveyor:spawnOffer(World.importCurtain+8,Data.mutate(Data.create(id,false),mutation)); return "Spawned on conveyor"
   end
   local selected=target(args[1],player)
   if not selected then return "Player missing or ambiguous" end
   local state=states[selected]
   if command=="kick" then
    local reason=table.concat(args," ",2); if reason=="" then return "Kick reason required" end
    selected:Kick(reason); return "Player kicked"
   end
   if not state or not state.ready or state.savingRebirth then return "Player not ready" end
   if command=="money" then
    local amount=number(args[2],1,1000000000); if not amount then return "Amount must be 1..1000000000" end
    state.cash+=math.floor(amount); Money.publish(state); return "Cash granted"
   elseif command=="speed" then
    local speed=number(args[2],8,100); local root=World.aliveRoot(selected)
    if speed and root then selected:SetAttribute("AdminSpeed",speed); root.Parent:FindFirstChildOfClass("Humanoid").WalkSpeed=speed; return "Speed changed" end
   elseif command=="tp" or command=="bring" then
    local destination=command=="bring" and player or target(args[2],player)
    local moving=command=="bring" and selected or selected
    local root=destination and World.aliveRoot(destination)
    if root and World.aliveRoot(moving) then moving.Character:PivotTo(root.CFrame*CFrame.new(3,0,0)); return "Teleported" end
   elseif command=="mutate" then
    local index=number(args[2],1,8); local mutation=args[3]; local slot=index and state.slots[index]
    if slot and not slot.inTransit and Data.mutations[mutation] then
     if slot.model then slot.model:Destroy() end
     Data.mutate(slot.unit,mutation); Base.parkUnit(state,index,slot,onRaid)
     require(script.Parent.CollectionService).record(selected,slot.unit); Money.publish(state); return "Mutation changed"
    end
    return "Use mutate <player> <stand 1..8> <mutation>"
   end
   return "Invalid command or arguments"
  end
  local ok,message=pcall(execute)
  notify(player,ok and message or "Command failed; check server log.",ok and "success" or "warning")
  if not ok then warn("Admin command error: "..tostring(message)) end
 end
 remote.OnServerEvent:Connect(run)
 local command=Instance.new("TextChatCommand"); command.Name="BlitzAdminCommand"; command.PrimaryAlias="/blitz"; command.Parent=TextChat
 command.Triggered:Connect(function(source,line) local player=Players:GetPlayerByUserId(source.UserId); if player then run(player,line) end end)
 local function join(player)
  if player.UserId==ADMIN and TextChat.ChatVersion==Enum.ChatVersion.LegacyChatService then player.Chatted:Connect(function(line) if line:sub(1,7)=="/blitz " then run(player,line) end end) end
 end
 Players.PlayerAdded:Connect(join); Players.PlayerRemoving:Connect(function(player) cooldown[player]=nil end)
 for _,player in ipairs(Players:GetPlayers()) do join(player) end
end
return Service
