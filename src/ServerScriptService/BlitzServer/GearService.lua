local Players=game:GetService("Players")
local Storage=game:GetService("ReplicatedStorage")
local Debris=game:GetService("Debris")
local World=require(script.Parent.World)
local Money=require(script.Parent.MoneyService)
local Steal=require(script.Parent.StealService)
local Catalog=require(Storage.GearData)
local Service={}
function Service.start(map,states,onRaid,notify)
 local shop=Instance.new("Model"); shop.Name="Gear Shop"; shop.Parent=map
 local function part(name,size,x,y,z,color)
  return World.part(shop,name,size,CFrame.new(-42,y,-17)*CFrame.Angles(0,math.pi,0)*CFrame.new(x,0,z),color,Enum.Material.WoodPlanks)
 end
 part("Deck",Vector3.new(17,0.3,9),0,0.15,0,World.steel)
 part("Roof",Vector3.new(18,0.6,10),0,7,0,World.aqua)
 for _,x in ipairs({-7.5,7.5}) do part("Post",Vector3.new(0.6,7,0.6),x,3.5,3,World.gold) end
 local sign=part("Gear fascia",Vector3.new(16,1.7,0.3),0,7.8,-4.5,World.ink)
 World.surfaceSign(sign,"GEAR SHOP",World.aqua)
 local terminal=part("Counter",Vector3.new(16,2.5,2),0,1.4,-2.5,World.steel)
 for index,id in ipairs({"Slap","SpeedCoil","Trap"}) do
  local display=part(id.." display",Vector3.new(1.8,1.5,0.8),(index-2)*5,3.4,-2.5,id=="Slap" and Color3.fromRGB(255,190,125) or World.aqua)
  display.Material=Enum.Material.Neon
  World.sign(display,id.." • $"..Catalog[id].price,World.white,150,32,Vector3.new(0,1.5,0),32)
 end
 local remote=Instance.new("RemoteEvent"); remote.Name="BlitzGear"; remote.Parent=Storage
 local cooldown, trapCount = {},{}
 local function has(player,id)
  return (player.Character and player.Character:FindFirstChild(id)) or (player:FindFirstChildOfClass("Backpack") and player.Backpack:FindFirstChild(id))
 end
 local function give(player,id)
  local tool=Instance.new("Tool"); tool.Name=id; tool.ToolTip=Catalog[id].description; tool.CanBeDropped=false
  local handle=Instance.new("Part"); handle.Name="Handle"; handle.Size=id=="Slap" and Vector3.new(1.8,2.2,0.4) or Vector3.new(1,1,1)
  handle.Color=id=="Slap" and Color3.fromRGB(255,190,125) or id=="Trap" and World.steel or World.aqua
  handle.Material=Enum.Material.Neon; handle.Massless=true; handle.CanCollide=false; handle.Parent=tool
  if id=="Slap" then
   for finger=1,4 do
    local part=Instance.new("Part"); part.Name="Finger"; part.Size=Vector3.new(0.34,1,0.4)
    part.CFrame=handle.CFrame*CFrame.new((finger-2.5)*0.42,1.4,0); part.Color=handle.Color
    part.Massless=true; part.CanCollide=false; part.Parent=tool
    local weld=Instance.new("WeldConstraint"); weld.Part0=handle; weld.Part1=part; weld.Parent=part
   end
  elseif id=="SpeedCoil" then
   for step=1,12 do
    local angle=step*math.pi/3
    local part=Instance.new("Part"); part.Name="Coil"; part.Size=Vector3.new(0.22,0.22,0.8)
    part.CFrame=handle.CFrame*CFrame.new(math.cos(angle)*0.65,(step-6)*0.16,math.sin(angle)*0.65)*CFrame.Angles(0,-angle,0)
    part.Color=handle.Color; part.Material=Enum.Material.Neon; part.Massless=true; part.CanCollide=false; part.Parent=tool
    local weld=Instance.new("WeldConstraint"); weld.Part0=handle; weld.Part1=part; weld.Parent=part
   end
  end
  local ready=0
  local function restoreSpeed()
   local character=player.Character; local hum=character and character:FindFirstChildOfClass("Humanoid")
   if hum and not character:GetAttribute("GearFrozen") then hum.WalkSpeed=player:GetAttribute("AdminSpeed") or 16 end
  end
  if id=="SpeedCoil" then
   tool.Equipped:Connect(function()
    local root=World.aliveRoot(player)
    if root and not root.Parent:GetAttribute("GearFrozen") then root.Parent:FindFirstChildOfClass("Humanoid").WalkSpeed=math.max(28,player:GetAttribute("AdminSpeed") or 16) end
   end)
   tool.Unequipped:Connect(restoreSpeed)
  else
   tool.Activated:Connect(function()
    local root=World.aliveRoot(player); local state=states[player]
    if not root or tool.Parent~=player.Character or not state or not state.ready or state.savingRebirth or os.clock()<ready then return end
    ready=os.clock()+1.5
    if id=="Slap" then
     for target,victim in pairs(states) do
      local other=World.aliveRoot(target)
      if target~=player and other and victim.carry and victim.ready and not victim.savingRebirth then
       local delta=other.Position-root.Position
       if delta.Magnitude>0.1 and delta.Magnitude<=7 and root.CFrame.LookVector:Dot(delta.Unit)>0.25 then
        local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={player.Character,target.Character}; params.RespectCanCollide=true
        if not workspace:Raycast(root.Position,delta,params) then
         Steal.returnRaid(victim,states,onRaid,notify)
         other:SetNetworkOwner(nil); other.AssemblyLinearVelocity=delta.Unit*85+Vector3.new(0,35,0)
         task.delay(0.4,function() if other.Parent then other:SetNetworkOwnershipAuto() end end)
         notify(target,"Slapped! Your cargo was returned.","warning"); break
        end
       end
      end
     end
    elseif id=="Trap" then
     if (trapCount[player] or 0)>=2 then notify(player,"Maximum two active traps.","warning"); return end
     local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={player.Character}
     local hit=workspace:Raycast(root.Position+root.CFrame.LookVector*3,Vector3.new(0,-8,0),params)
     if not hit or hit.Normal.Y<0.8 then return end
     local trap=World.part(map,"Freeze Trap",Vector3.new(4,0.22,4),CFrame.new(hit.Position+Vector3.new(0,0.15,0)),World.aqua,Enum.Material.Neon)
     trap.CanCollide=false; trapCount[player]=(trapCount[player] or 0)+1
     trap.Destroying:Connect(function() trapCount[player]=math.max(0,(trapCount[player] or 1)-1) end)
     local used=false
     trap.Touched:Connect(function(part)
      if used then return end
      local character=part:FindFirstAncestorOfClass("Model"); local target=character and Players:GetPlayerFromCharacter(character)
      local victim=target and states[target]; local other=target and World.aliveRoot(target)
      if not other or target==player or not victim or not victim.ready or victim.savingRebirth or (other.Position-trap.Position).Magnitude>7 or character:GetAttribute("GearFrozen") then return end
      used=true; character:SetAttribute("GearFrozen",true)
      local hum=character:FindFirstChildOfClass("Humanoid"); local speed,jump,power=hum.WalkSpeed,hum.JumpHeight,hum.JumpPower
      hum.WalkSpeed=0; hum.JumpHeight=0; hum.JumpPower=0
      other:SetNetworkOwner(nil); local anchored=other.Anchored; other.Anchored=true
      notify(target,"Frozen by a trap for 3 seconds!","warning")
      task.delay(3,function()
       if hum.Parent and other.Parent then
        character:SetAttribute("GearFrozen",nil); other.Anchored=anchored
        hum.WalkSpeed=target:GetAttribute("AdminSpeed") or (character:FindFirstChild("SpeedCoil") and 28 or speed)
        hum.JumpHeight=jump; hum.JumpPower=power
        if not anchored then other:SetNetworkOwnershipAuto() end
       end
      end)
      trap:Destroy()
     end)
     Debris:AddItem(trap,45); tool:Destroy()
    end
   end)
  end
  tool.Parent=player:FindFirstChildOfClass("Backpack")
 end
 local function buy(player,id)
  local state=states[player]; local spec=Catalog[id]
  if not player:FindFirstChildOfClass("Backpack") or not spec or not state or not state.ready or state.savingRebirth or not World.aliveRoot(player) or not World.near(player,terminal) or has(player,id) then return end
  if id=="Trap" and (trapCount[player] or 0)>=2 then return end
  if not Money.spend(state,spec.price) then notify(player,"Not enough cash.","warning"); return end
  give(player,id); Money.publish(state); notify(player,"Bought "..id.." for $"..spec.price,"success")
 end
 -- A fixed, anchored R6-style shopkeeper faces the aisle (+Z in world space).
 local keeper=Instance.new("Model"); keeper.Name="Gear Shopkeeper"; keeper.Parent=shop
 local function body(name,size,x,y,z,color)
  local piece=part(name,size,x,y,z,color); piece.Parent=keeper
  piece.Material=Enum.Material.SmoothPlastic; piece.CanCollide=false
  return piece
 end
 local skin=Color3.fromRGB(238,187,139)
 body("Torso",Vector3.new(2,2,1),0,3.3,0.7,World.aqua)
 body("Apron",Vector3.new(1.6,1.7,0.12),0,3.2,0.14,World.white)
 local head=body("Head",Vector3.new(1.4,1.4,1.4),0,5,0.7,skin)
 local face=Instance.new("Decal"); face.Name="Smile"; face.Face=Enum.NormalId.Front
 face.Texture="rbxasset://textures/face.png"; face.Parent=head
 body("Left Arm",Vector3.new(0.8,2,0.8),-1.45,3.3,0.7,skin)
 body("Right Arm",Vector3.new(0.8,2,0.8),1.45,3.3,0.7,skin)
 for _,x in ipairs({-0.5,0.5}) do body("Leg",Vector3.new(0.85,2,0.85),x,1.3,0.7,World.ink) end
 body("Vendor hat brim",Vector3.new(2.2,0.18,2),0,5.78,0.7,World.gold)
 body("Vendor hat crown",Vector3.new(1.5,0.65,1.4),0,6.15,0.7,World.aqua)
 World.sign(head,"GEAR SELLER",World.gold,150,30,Vector3.new(0,1.8,0),25)
 local prompt=World.prompt(head,"Open Shop","Gear Seller",0.2)
 prompt.Triggered:Connect(function(player)
  local state=states[player]
  if state and state.ready and not state.savingRebirth and World.near(player,terminal) and World.near(player,head) then remote:FireClient(player,"open") end
 end)
 remote.OnServerEvent:Connect(function(player,action,id)
  if action~="buy" or type(id)~="string" or not Catalog[id] or not World.near(player,terminal) or os.clock()<(cooldown[player] or 0) then return end
  cooldown[player]=os.clock()+0.35
  buy(player,id)
 end)
 Players.PlayerRemoving:Connect(function(player) cooldown[player]=nil end)
end
return Service
