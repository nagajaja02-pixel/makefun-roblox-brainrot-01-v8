-- Cosmetic effects run locally at 10 Hz. At most 18 weather parts and nearby mutation highlights.
local Storage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Tags=game:GetService("CollectionService")
local Run=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Events=require(Storage:WaitForChild("BlitzEvents"))
local Specs=require(Storage:WaitForChild("MutationData"))
local player=Players.LocalPlayer
local folder=Instance.new("Folder"); folder.Name="LocalEventWeather"; folder.Parent=workspace
local pool={}; local current; local clock=0; local pulse=0
local mutationModels={}
local function register(model) mutationModels[model]=true end
for _,model in ipairs(Tags:GetTagged("BlitzMutation")) do register(model) end
Tags:GetInstanceAddedSignal("BlitzMutation"):Connect(register)
Tags:GetInstanceRemovedSignal("BlitzMutation"):Connect(function(model) mutationModels[model]=nil end)
local function reset(id)
 folder:ClearAllChildren(); table.clear(pool); current=id
 local definition=id and Events[id]; if not definition then return end
 for i=1,18 do
  local part=Instance.new("Part"); part.Name=definition.weather; part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
  part.Material=Enum.Material.Neon; part.Color=definition.color
  part.Shape=(id=="Meteor" or id=="Cosmic" or id=="Giant") and Enum.PartType.Ball or Enum.PartType.Block
  part.Size=id=="Meteor" and Vector3.new(1,1,1) or id=="Money" and Vector3.new(1.2,0.08,0.7) or id=="Thunder" and Vector3.new(0.07,2,0.07) or Vector3.new(0.3,0.3,0.3)
  part.Transparency=0.15; part.Parent=folder
  pool[i]={part=part,x=math.random(-65,65),z=math.random(-50,50),height=math.random(6,40)}
 end
 if id=="Rainbow" then
  for band=1,7 do
   for step=0,12 do
    local angle=step/12*math.pi
    local part=Instance.new("Part"); part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
    part.Size=Vector3.new(7,0.8,1); part.Material=Enum.Material.Neon; part.Color=Color3.fromHSV(band/7,0.8,1)
    part.CFrame=CFrame.new(math.cos(angle)*(34+band),22+math.sin(angle)*(34+band),-65)*CFrame.Angles(0,0,angle+math.pi/2); part.Parent=folder
   end
  end
 end
end
workspace:GetAttributeChangedSignal("BlitzEvent"):Connect(function() reset(workspace:GetAttribute("BlitzEvent")) end)
reset(workspace:GetAttribute("BlitzEvent"))
Run.Heartbeat:Connect(function(dt)
 clock+=dt; if clock<0.1 then return end
 local elapsed=clock; clock=0; pulse+=elapsed
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not root then return end
 local definition=current and Events[current]
 if definition then
  for i,item in ipairs(pool) do
   local speed=current=="Meteor" and 24 or current=="Thunder" and 40 or 7
   item.height-=elapsed*speed; if item.height<1 then item.height=40 end
   item.part.CFrame=CFrame.new(root.Position+Vector3.new(item.x,item.height,item.z))*CFrame.Angles(pulse+i,pulse*0.3,0)
   if current=="Disco" or current=="Rainbow" then item.part.Color=Color3.fromHSV((pulse*0.15+i/18)%1,0.8,1) end
  end
  if current=="Thunder" and math.random()<0.025 then
   local flash=Instance.new("ColorCorrectionEffect"); flash.Brightness=0.35; flash.Parent=game:GetService("Lighting"); Debris:AddItem(flash,0.12)
  end
 end
 for model in pairs(mutationModels) do
  local pivot=model.PrimaryPart; local spec=Specs[model:GetAttribute("Mutation")]
  local near=pivot and (pivot.Position-root.Position).Magnitude<85
  local aura=model:FindFirstChild("MutationAura")
  if aura and spec then
   aura.Enabled=near
   if near then
    local wave=math.sin(pulse*spec.speed*3)
    aura.FillTransparency=0.78+wave*0.12
    local color=spec==Specs.Rainbow and Color3.fromHSV(pulse*0.2%1,0.8,1) or spec.color
    aura.FillColor=color; aura.OutlineColor=color
    local attachment=pivot:FindFirstChild("MutationParticles")
    if attachment then
     local angle=pulse*spec.speed
     attachment.Position=Vector3.new(math.cos(angle)*(spec==Specs.Cosmic and 2 or 0.8),spec==Specs.Celestial and 3 or math.sin(angle),math.sin(angle))
     local emitter=attachment:FindFirstChildOfClass("ParticleEmitter")
     if emitter then emitter.Color=ColorSequence.new(color); emitter.Enabled=true end
    end
   end
  end
  if pivot then
   local attachment=pivot:FindFirstChild("MutationParticles"); local emitter=attachment and attachment:FindFirstChildOfClass("ParticleEmitter")
   if emitter then emitter.Enabled=near end
  end
 end
end)
