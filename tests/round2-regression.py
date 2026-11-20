"""Execute all catalog sculpts with minimal Roblox mocks; no rendering claims."""
from pathlib import Path
import subprocess, tempfile, re
root=Path(__file__).resolve().parents[1]
data=(root/'src/ReplicatedStorage/BrainrotData.lua').read_text()
models=(root/'src/ServerScriptService/BlitzServer/BrainrotModels.lua').read_text()
old=subprocess.check_output(['git','show','HEAD:src/ReplicatedStorage/BrainrotData.lua'],text=True)
rows=lambda s: re.findall(r'^\s*\{ ".*$',s,re.M)
assert rows(data)[:13]==rows(old)[:13], 'legacy catalog changed'
assert data.split('Data.cast =')[0]==old.split('Data.cast =')[0], 'rarity odds changed'
prelude='''
local count=0
local function check(v,msg) assert(v,msg); count+=1 end
local color={}; color.__index=color
function color:Lerp() return self end
local Color3={fromRGB=function() return setmetatable({},color) end}
local v={}; v.__index=v
local Vector3={new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},v) end}
local cf={}; cf.__index=cf
function cf:__mul(other) return self end
function cf:ToObjectSpace(other) return other end
local CFrame={new=function() return setmetatable({},cf) end,Angles=function() return setmetatable({},cf) end}
local Enum={PartType={Ball=1,Cylinder=2},Material={Neon=1}}
local Instance={new=function() return {FindFirstChildWhichIsA=function(self) return self.parts[1] end,PivotTo=function() end} end}
local World={ink=Color3.fromRGB(),white=Color3.fromRGB(),gold=Color3.fromRGB()}
function World.part(parent,name,size,frame,color)
 check(size.X>0 and size.Y>0 and size.Z>0,"positive primitive size")
 local part={Name=name,Size=size,CFrame=frame,Color=color}
 parent.parts=parent.parts or {}; table.insert(parent.parts,part); return part
end
local MutationService={decorate=function() end}
local Specs={Gold={multiplier=2},Diamond={multiplier=3}}
local script={Parent={World=World,MutationService=MutationService,MutationData=Specs}}
local require=function(x) return x end
'''
body=prelude+'\nlocal Data=(function()\n'+data+'\nend)()\nlocal Models=(function()\n'+models+'\nend)()\n'+'''
check(#Data.cast==30,"thirty characters")
local names={}; local tiers={0,0,0,0,0}
for id,entry in ipairs(Data.cast) do
 check(not names[entry[1]],"unique names"); names[entry[1]]=true
 tiers[entry[2]]+=1
 for _,mutation in ipairs({"","Gold","Diamond"}) do
  local unit=Data.create(id,false); Data.mutate(unit,mutation)
  local model=Models.sculpt({},unit,CFrame.new())
  check(model.PrimaryPart~=nil and #model.parts>=12,"complete sculpt")
 end
end
for tier=1,5 do check(tiers[tier]>=5,"populated tier") end
for _,a in ipairs(Data.cast) do for _,b in ipairs(Data.cast) do
 if a[2]<b[2] then check(a[3]<b[3] and a[4]<b[4],"rarity economy ordering") end
end end
print("PASS round 2: "..count.." assertions, 90 model builds (mock), 30 entries, all tiers and legacy catalog")
'''
with tempfile.NamedTemporaryFile('w',suffix='.luau',delete=False) as f:
 f.write(body); path=Path(f.name)
try: subprocess.run(['/home/hatch/.local/bin/luau',str(path)],check=True)
finally: path.unlink()
