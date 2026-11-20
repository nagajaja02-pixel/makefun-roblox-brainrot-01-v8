local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Rules=require(RS.Shared.EventRules)
local Events={}
local active=nil
local services
local function setModifiers(def)
 workspace:SetAttribute("EventLuck",def and def.luck or 1)
 workspace:SetAttribute("EventGoldChance",def and def.gold or 0)
 workspace:SetAttribute("EventSpawnInterval",def and def.spawn or 1)
end
local function visual(def, folder, sequence)
 -- At most twelve transient parts. No damage, physics, textures or external assets.
 local color=Color3.fromRGB(table.unpack(def.color))
 if def.effect=="giant" then
  local giant=folder:FindFirstChild("HarborGiant")
  if not giant then
   local Data=require(RS.Shared.BrainrotData)
   giant=require(script.Parent.BrainrotModels).build(Data.byId("celestial_seraph"),"Gold")
   giant.Name="HarborGiant"; giant:ScaleTo(4)
   for _,child in ipairs(giant:GetDescendants()) do
    if child:IsA("BillboardGui") then child:Destroy() end
   end
   giant.Parent=folder
  end
  giant:PivotTo(CFrame.new(math.sin(sequence/10)*55,4,80)*CFrame.Angles(0,sequence/10,0))
 end
 for i=1,4 do
  local p=Instance.new("Part")
  p.Name=def.effect
  p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.CastShadow=false
  p.Material=Enum.Material.Neon; p.Color=color; p.Transparency=0.25
  local x=((sequence*29+i*53)%250)-125
  local z=(i%2==0) and 78 or -78
  local size=def.effect=="bolt" and Vector3.new(0.4,24,0.4) or Vector3.new(1.6,1.6,1.6)
  if def.effect=="rainbow" then p.Color=Color3.fromHSV((sequence+i)/12%1,0.65,1) end
  if def.effect=="visitor" then size=Vector3.new(3,4,2) end
  p.Size=size; p.Position=Vector3.new(x,32,z); p.Parent=folder
  local destination=Vector3.new(x+8,5,z)
  Tween:Create(p,TweenInfo.new(2.8),{Position=destination,Transparency=1,Orientation=Vector3.new(45,90,0)}):Play()
  Debris:AddItem(p,3)
 end
end
function Events.isActive() return active~=nil end
function Events.start(def)
 if active or not def then return false end
 local folder=Instance.new("Folder"); folder.Name="ActiveEventEffects"; folder.Parent=workspace
 local grade=Lighting:FindFirstChild("HarborGrade")
 local atmosphere=Lighting:FindFirstChild("HarborAtmosphere")
 local baseline={clock=Lighting.ClockTime, ambient=Lighting.Ambient, tint=grade and grade.TintColor, density=atmosphere and atmosphere.Density}
 active=def
 local color=Color3.fromRGB(table.unpack(def.color))
 Lighting.ClockTime=def.clock; Lighting.Ambient=color:Lerp(baseline.ambient,0.6)
 if grade then grade.TintColor=color:Lerp(Color3.new(1,1,1),0.72) end
 if atmosphere then atmosphere.Density=0.3 end
 setModifiers(def)
 workspace:SetAttribute("ActiveEvent",def.name)
 workspace:SetAttribute("EventNote",def.note)
 workspace:SetAttribute("EventEndsAt",workspace:GetServerTimeNow()+Rules.Duration)
 task.spawn(function()
  local ok,err=xpcall(function()
   for step=1,Rules.Duration do
    if step%3==1 then visual(def,folder,step) end
    task.wait(1)
    -- Bonus earnings use the original service; base income and rebirth math stay intact.
    if def.income then
     for _,player in ipairs(Players:GetPlayers()) do
      local bonus=math.floor(services.Money:getIncomePerSecond(player)*(def.income-1))
      if bonus>0 then services.Money:earn(player,bonus) end
     end
    end
   end
   if def.reward then
    for _,player in ipairs(Players:GetPlayers()) do services.Money:earn(player,def.reward) end
   end
  end,debug.traceback)
  -- Always restore every field touched, including on an interrupted effect failure.
  folder:Destroy()
  Lighting.ClockTime=baseline.clock; Lighting.Ambient=baseline.ambient
  if grade then grade.TintColor=baseline.tint end
  if atmosphere then atmosphere.Density=baseline.density end
  setModifiers(nil)
  workspace:SetAttribute("ActiveEvent",""); workspace:SetAttribute("EventNote",""); workspace:SetAttribute("EventEndsAt",0)
  active=nil
  if not ok then warn("Event ended safely: "..tostring(err)) end
 end)
 return true
end
function Events.init(deps)
 services=deps
 setModifiers(nil)
 task.spawn(function()
  local index=1
  task.wait(120)
  while true do
   if not active then
    Events.start(Rules.Regular[index]); index=index%#Rules.Regular+1
    task.wait(Rules.Duration+Rules.Gap)
   else task.wait(5) end
  end
 end)
end
return Events
