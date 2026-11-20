local World=require(script.Parent.World)
local Service={}
function Service.build(map)
 local folder=Instance.new("Folder"); folder.Name="V9 Harbor Details"; folder.Parent=map
 local function decor(name,size,position,color,material,shape)
  local part=World.part(folder,name,size,CFrame.new(position),color,material,shape)
  part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
  return part
 end
 -- Replace the upper half-stud of the island with solid checkerboard tiles.
 -- The exposed ground stays at Y=0, below paths and decks; no overlay competes with it.
 local island=map:FindFirstChild("Harbor island")
 assert(island and island:IsA("BasePart"),"Harbor island must exist before ground details")
 island.Size=Vector3.new(island.Size.X,7.5,island.Size.Z)
 island.CFrame=CFrame.new(0,-4.25,0)
 local tile=20
 for x=-World.islandHalfX,World.islandHalfX-1,tile do
  for z=-World.islandHalfZ,World.islandHalfZ-1,tile do
   local sx=math.min(tile,World.islandHalfX-x); local sz=math.min(tile,World.islandHalfZ-z)
   local alternate=(math.floor((x+World.islandHalfX)/tile)+math.floor((z+World.islandHalfZ)/tile))%2==0
   local part=decor("Classic stud tile",Vector3.new(sx,0.5,sz),Vector3.new(x+sx/2,-0.25,z+sz/2),alternate and Color3.fromRGB(106,184,66) or Color3.fromRGB(77,150,51),Enum.Material.Plastic)
   part.CanCollide=true; part.CanQuery=true
   part.TopSurface=Enum.SurfaceType.Studs
  end
 end
 for _,part in ipairs(map:GetChildren()) do
  if part:IsA("BasePart") then
   if part.Name=="Perimeter wall" or part.Name=="Wall pilaster" then
    part.Material=Enum.Material.Ground
    part.Color=part.Name=="Wall pilaster" and Color3.fromRGB(121,85,53) or Color3.fromRGB(137,95,59)
   elseif part.Name=="Wall coping" then part.Material=Enum.Material.Grass; part.Color=Color3.fromRGB(73,143,49) end
  end
 end
 local function tree(position,index)
  decor("Earth variation",Vector3.new(7,3+(index%3),1),position+Vector3.new(0,-6,0),Color3.fromRGB(105+index%4*12,72,42),Enum.Material.Rock)
  decor("Tree trunk",Vector3.new(1.1,5,1.1),position+Vector3.new(0,2.5,0),Color3.fromRGB(106,72,42),Enum.Material.Wood)
  decor("Tree crown",Vector3.new(6,6+index%3,6),position+Vector3.new(0,6,0),Color3.fromRGB(48+index%4*8,120+index%3*14,49),Enum.Material.Grass,Enum.PartType.Ball)
 end
 local i=0
 for x=-120,120,24 do for _,z in ipairs({-99,99}) do i+=1; tree(Vector3.new(x,18.6,z),i) end end
 for z=-72,72,24 do for _,x in ipairs({-133,133}) do i+=1; tree(Vector3.new(x,18.6,z),i) end end
end
return Service
