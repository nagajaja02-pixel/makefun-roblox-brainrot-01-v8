local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Rules=require(RS.Shared.EventRules)
local Config=require(script.Parent.AdminConfig)
local Admin={}
function Admin.init(events)
 local whitelist={}
 for _,id in ipairs(Config.UserIds) do
  if type(id)=="number" and id>0 and id%1==0 then whitelist[id]=true end
 end
 if Config.IncludeExperienceOwner and game.CreatorType==Enum.CreatorType.User and game.CreatorId>0 then
  whitelist[game.CreatorId]=true
 end
 local command=Instance.new("RemoteEvent"); command.Name="AdminEvent"; command.Parent=RS
 local reply=Instance.new("RemoteEvent"); reply.Name="AdminEventResult"; reply.Parent=RS
 local last={}
 local function join(player) player:SetAttribute("BlitzAdmin",whitelist[player.UserId]==true) end
 Players.PlayerAdded:Connect(join)
 for _,player in ipairs(Players:GetPlayers()) do join(player) end
 Players.PlayerRemoving:Connect(function(player) last[player]=nil end)
 command.OnServerEvent:Connect(function(player,id)
  local now=os.clock()
  if not Rules.authorized(player.UserId,whitelist,id,events.isActive(),last[player] or -math.huge,now) then
   if whitelist[player.UserId] then reply:FireClient(player,"Unavailable: event active, invalid command, or cooldown.") end
   return
  end
  last[player]=now
  local ok=events.start(Rules.find(id,true))
  reply:FireClient(player,ok and "Event started." or "Another event is already active.")
 end)
end
return Admin
