local Players=game:GetService("Players")
local Storage=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local player=Players.LocalPlayer
local Events=require(Storage:WaitForChild("BlitzEvents"))
local gui=Instance.new("ScreenGui"); gui.Name="BlitzV9"; gui.ResetOnSpawn=false; gui.DisplayOrder=15; gui.Parent=player:WaitForChild("PlayerGui")
local gold=Color3.fromRGB(242,207,120)
local function element(class,parent,text,size,pos)
 local item=Instance.new(class); item.Size=size; item.Position=pos or UDim2.new(); item.BackgroundColor3=Color3.fromRGB(20,29,46)
 if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then item.Text=text; item.TextColor3=Color3.fromRGB(239,244,255); item.Font=Enum.Font.GothamBold; item.TextSize=14; item.TextWrapped=true end
 item.Parent=parent
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,10); corner.Parent=item
 return item
end
local function window(title)
 local panel=element("Frame",gui,nil,UDim2.new(0.92,0,0.76,0),UDim2.fromScale(0.5,0.5)); panel.AnchorPoint=Vector2.new(0.5,0.5); panel.Visible=false
 local limit=Instance.new("UISizeConstraint"); limit.MaxSize=Vector2.new(700,580); limit.Parent=panel
 local edge=Instance.new("UIStroke"); edge.Color=gold; edge.Transparency=0.25; edge.Parent=panel
 element("TextLabel",panel,title,UDim2.new(1,-54,0,42)).TextColor3=gold
 element("TextButton",panel,"×",UDim2.fromOffset(40,36),UDim2.new(1,-44,0,3)).Activated:Connect(function() panel.Visible=false end)
 return panel
end
local function scroll(panel,y)
 local list=element("ScrollingFrame",panel,nil,UDim2.new(1,-16,1,-y-8),UDim2.fromOffset(8,y))
 list.CanvasSize=UDim2.new(); list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.ScrollBarThickness=4
 local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,6); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Parent=list
 return list
end
local notice=element("TextLabel",gui,"",UDim2.new(0.7,0,0,54),UDim2.new(0.5,0,0,58)); notice.AnchorPoint=Vector2.new(0.5,0); notice.Visible=false
local queue={}; local showing=false
local function toast(message,kind)
 if #queue>=6 then table.remove(queue,1) end
 table.insert(queue,{message,kind})
 if showing then return end
 showing=true
 task.spawn(function()
  while #queue>0 do
   local item=table.remove(queue,1); notice.Text=item[1]; notice.TextColor3=item[2]=="warning" and Color3.fromRGB(255,141,112) or gold; notice.Visible=true
   task.wait(4); notice.Visible=false; task.wait(0.15)
  end
  showing=false
 end)
end
Storage:WaitForChild("BlitzNotice").OnClientEvent:Connect(toast)
-- Base alerts have a separate queue from ordinary feedback.
Storage:WaitForChild("BlitzFeedback").OnClientEvent:Connect(function(message,kind)
 if type(message)=="string" and (message:find("BASE ALERT",1,true) or message:find(" grabbed ",1,true) or message:find(" was stolen",1,true)) then toast(message,"warning") end
end)
local board=window("LIVE • HARBOR LEADERBOARD")
local boardToggle=element("TextButton",gui,"RANKS",UDim2.fromOffset(78,36),UDim2.new(1,-88,0,8))
boardToggle.Activated:Connect(function() board.Visible=not board.Visible end)
local tabs=element("Frame",board,nil,UDim2.new(1,-16,0,38),UDim2.fromOffset(8,46))
local ranking="Cash"; local rows=scroll(board,92); local avatars={}
local function refreshBoard()
 if not board.Visible then return end
 for _,child in ipairs(rows:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
 local all=Players:GetPlayers()
 table.sort(all,function(a,b)
  local av,bv=a:GetAttribute(ranking) or 0,b:GetAttribute(ranking) or 0
  return av>bv or av==bv and a.UserId<b.UserId
 end)
 for place,entry in ipairs(all) do
  local row=element("Frame",rows,nil,UDim2.new(1,-6,0,62)); row.LayoutOrder=place
  local position=element("TextLabel",row,"#"..place,UDim2.fromOffset(36,56)); position.TextColor3=place<=3 and gold or Color3.new(1,1,1)
  local avatar=element("ImageLabel",row,nil,UDim2.fromOffset(42,42),UDim2.fromOffset(38,9)); avatar.Image=avatars[entry.UserId] or ""
  if not avatars[entry.UserId] then task.spawn(function()
   local ok,url=pcall(function() return Players:GetUserThumbnailAsync(entry.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
   if ok then avatars[entry.UserId]=url; if avatar.Parent then avatar.Image=url end end
  end) end
  local label=element("TextLabel",row,entry.DisplayName.."\n@"..entry.Name,UDim2.new(0.57,-80,1,0),UDim2.fromOffset(84,0)); label.TextSize=12
  local stats=element("TextLabel",row,string.format("$%.0f • %d steals\n%d rebirths",entry:GetAttribute("Cash") or 0,entry:GetAttribute("Steals") or 0,entry:GetAttribute("Rebirths") or 0),UDim2.new(0.43,-4,1,0),UDim2.fromScale(0.57,0)); stats.TextSize=11; stats.TextColor3=gold
 end
end
for i,stat in ipairs({"Cash","Steals","Rebirths"}) do
 element("TextButton",tabs,stat,UDim2.new(1/3,-4,1,0),UDim2.new((i-1)/3,0,0,0)).Activated:Connect(function() ranking=stat; refreshBoard() end)
end
board:GetPropertyChangedSignal("Visible"):Connect(refreshBoard)
task.spawn(function() while task.wait(3) do refreshBoard() end end)
local gear=window("GEAR SHOP")
local gearList=scroll(gear,46)
local gearRemote=Storage:WaitForChild("BlitzGear")
local catalog=require(Storage.GearData)
-- Real primitive sculpts, rendered locally without image assets.
local function gearIcon(parent,id)
 local view=Instance.new("ViewportFrame"); view.Name=id.." Icon"; view.Size=UDim2.fromOffset(68,80); view.Position=UDim2.fromOffset(6,3); view.BackgroundTransparency=1; view.Parent=parent
 view.Ambient=Color3.fromRGB(190,200,220); view.LightColor=Color3.new(1,1,1); view.LightDirection=Vector3.new(-1,-1,-2)
 local world=Instance.new("WorldModel"); world.Parent=view
 local camera=Instance.new("Camera"); camera.CFrame=CFrame.lookAt(Vector3.new(0,1.2,7),Vector3.new(0,0.2,0)); camera.FieldOfView=38; camera.Parent=view; view.CurrentCamera=camera
 local function piece(name,size,pos,color,shape,angle)
  local part=Instance.new("Part"); part.Name=name; part.Anchored=true; part.CanCollide=false; part.Size=size; part.CFrame=CFrame.new(pos)*CFrame.Angles(0,0,angle or 0); part.Color=color; part.Shape=shape or Enum.PartType.Block; part.Parent=world
 end
 local skin=Color3.fromRGB(255,194,125); local steel=Color3.fromRGB(155,182,208)
 if id=="Slap" then
  piece("Palm",Vector3.new(1.25,1.3,0.35),Vector3.new(0,-0.1,0),skin)
  piece("Cuff",Vector3.new(1,0.45,0.45),Vector3.new(0,-0.95,0),gold)
  for finger=1,4 do piece("Finger",Vector3.new(0.25,0.85+(finger%3)*0.12,0.3),Vector3.new(-0.48+(finger-1)*0.32,0.9,0),skin,Enum.PartType.Ball) end
  piece("Thumb",Vector3.new(0.4,1,0.35),Vector3.new(-0.84,0.05,0),skin,Enum.PartType.Ball,-0.55)
 elseif id=="SpeedCoil" then
  local blue=Color3.fromRGB(70,200,255)
  for step=0,63 do
   local angle=step*math.pi/8
   local nextAngle=(step+1)*math.pi/8
   local a=Vector3.new(math.cos(angle)*0.72,-1.05+step*0.034,math.sin(angle)*0.72)
   local b=Vector3.new(math.cos(nextAngle)*0.72,-1.05+(step+1)*0.034,math.sin(nextAngle)*0.72)
   local rod=Instance.new("Part"); rod.Name="Coil winding"; rod.Size=Vector3.new(0.14,0.14,(b-a).Magnitude+0.04); rod.CFrame=CFrame.lookAt((a+b)/2,b); rod.Anchored=true; rod.CanCollide=false; rod.Color=blue; rod.Material=Enum.Material.Metal; rod.Parent=world
  end
  for _,y in ipairs({-1.2,1.25}) do piece("Grip",Vector3.new(1.6,0.28,0.55),Vector3.new(0,y,0),steel) end
 else
  piece("Trap plate",Vector3.new(2.3,0.22,1.6),Vector3.new(0,-0.5,0),steel)
  piece("Pressure trigger",Vector3.new(0.7,0.16,0.7),Vector3.new(0,-0.3,-0.2),gold)
  for _,side in ipairs({-1,1}) do
   piece("Open jaw",Vector3.new(0.2,1.1,1.5),Vector3.new(side*1,-0.05,0),steel,nil,side*-0.3)
   for tooth=1,4 do piece("Jaw tooth",Vector3.new(0.35,0.32,0.17),Vector3.new(side*0.85,0.55,-0.6+(tooth-1)*0.4),Color3.fromRGB(235,240,250),nil,side*0.5) end
  end
 end
end
for order,id in ipairs({"Slap","SpeedCoil","Trap"}) do
 local spec=catalog[id]
 local row=element("Frame",gearList,nil,UDim2.new(1,-6,0,146)); row.LayoutOrder=order
 gearIcon(row,id)
 element("TextLabel",row,id.." • $"..spec.price.."\n"..spec.description,UDim2.new(1,-86,0,85),UDim2.fromOffset(80,0)).TextSize=13
 element("TextButton",row,"BUY • $"..spec.price,UDim2.new(1,-12,0,42),UDim2.fromOffset(6,94)).Activated:Connect(function() gearRemote:FireServer("buy",id) end)
end
gearRemote.OnClientEvent:Connect(function(action)
 if action=="open" then gear.Visible=true end
end)
if player.UserId==7445776793 then
 local admin=window("BLITZ • ADMIN CONTROL")
 element("TextButton",gui,"ADMIN",UDim2.fromOffset(78,36),UDim2.new(1,-88,0,107)).Activated:Connect(function() admin.Visible=not admin.Visible end)
 local list=scroll(admin,46)
 local input=element("TextBox",list,"",UDim2.new(1,-8,0,44)); input.PlaceholderText="Command, e.g. money me 5000"; input.ClearTextOnFocus=false
 local remote=Storage:WaitForChild("BlitzAdmin")
 element("TextButton",list,"RUN COMMAND",UDim2.new(1,-8,0,40)).Activated:Connect(function() remote:FireServer(input.Text) end)
 element("TextLabel",list,"Chat: /blitz <command>\nspawn <1-30> [Mutation] • mutate <player> <stand> <Mutation>\nmoney <player> <amount> • speed <player> <8-100>\ntp <player> <destination> • bring <player>\nkick <player> <reason> • announce <message>\nPlayer: username, UserId, unique prefix, or me.",UDim2.new(1,-8,0,160)).TextSize=12
 for id,definition in pairs(Events) do
  element("TextButton",list,(definition.admin and "ADMIN • " or "EVENT • ")..definition.title,UDim2.new(1,-8,0,38)).Activated:Connect(function() remote:FireServer("start "..id) end)
 end
 element("TextButton",list,"STOP CURRENT EVENT",UDim2.new(1,-8,0,40)).Activated:Connect(function() remote:FireServer("stop") end)
end

-- Read the published state as well as changes so script startup order is irrelevant.
local index=player.PlayerGui:WaitForChild("BrainrotIndex")
local ranksWasOpen=false
local indexWasOpen=false
local function syncIndex()
 local opened=index:GetAttribute("IsOpen")==true
 if opened and not indexWasOpen then ranksWasOpen=board.Visible end
 boardToggle.Visible=not opened
 boardToggle.Interactable=not opened
 if opened then board.Visible=false
 elseif indexWasOpen then board.Visible=ranksWasOpen end
 indexWasOpen=opened
end
index:GetAttributeChangedSignal("IsOpen"):Connect(syncIndex)
syncIndex()
