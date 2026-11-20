"""Run actual Luau modules with small deterministic Roblox API mocks. No Studio claims."""
from pathlib import Path
import subprocess, tempfile
root=Path(__file__).resolve().parents[1]
def source(path): return (root/'src'/path).read_text()
prelude='''
local checks=0
local function check(value,message) assert(value,message); checks+=1 end
local color={}; color.__index=color
function color:Lerp(other,alpha) return self end
local Color3={new=function(...) return setmetatable({},color) end,fromRGB=function(...) return setmetatable({},color) end}
local Enum={Material={Metal=1,Glass=2,SmoothPlastic=3,Neon=4,CorrodedMetal=5,ForceField=6},ChatVersion={LegacyChatService=1}}
local function signal() return {Connect=function(self,fn) self.handler=fn end} end
local instances={}
local Instance={new=function(class)
 local object={ClassName=class,OnServerEvent=signal(),Triggered=signal(),Play=function() end,Destroy=function(self) self.Parent=nil end}
 function object:FireAllClients(...) self.last={...} end
 function object:FireClient(...) self.client={...} end
 table.insert(instances,object); return object
end}
local tasks={}
local task={spawn=function(fn) table.insert(tasks,coroutine.create(fn)) end,wait=function() coroutine.yield() end}
local now=1000
local workspace={attributes={},Terrain={FindFirstChildOfClass=function() return nil end}}
function workspace:GetServerTimeNow() return now end
function workspace:SetAttribute(key,value) self.attributes[key]=value end
local Lighting={Parent=true,ClockTime=10.5,Brightness=3.5,Ambient=Color3.new(),OutdoorAmbient=Color3.new(),FogColor=Color3.new(),FogStart=0,FogEnd=10000,FindFirstChildOfClass=function() return nil end}
local Players={PlayerAdded=signal(),PlayerRemoving=signal(),GetPlayers=function() return {} end}
local Storage={}
local TextChat={ChatVersion=2}
local SoundService={GetDescendants=function() return {} end}
local game={GetService=function(self,id) return ({ReplicatedStorage=Storage,Lighting=Lighting,Players=Players,TextChatService=TextChat,SoundService=SoundService})[id] end}
local function warn(...) end
'''
parts=[prelude,'local Specs=(function()\n'+source('ReplicatedStorage/MutationData.lua')+'\nend)()', 'local script={Parent={MutationData=Specs}}\nlocal require=function(value) return value end', 'local Data=(function()\n'+source('ReplicatedStorage/BrainrotData.lua')+'\nend)()', 'Storage.BrainrotData=Data', 'local Definitions=(function()\n'+source('ReplicatedStorage/BlitzEvents.lua')+'\nend)()\nStorage.BlitzEvents=Definitions']
parts.append('''
for id,entry in ipairs(Data.cast) do
 local unit=Data.create(id,false)
 check(unit.rate==entry[4] and unit.mutation=="","unmutated income")
 for name,spec in pairs(Specs) do
  Data.mutate(unit,name)
  check(unit.rate==entry[4]*spec.multiplier,"mutation income")
  check(unit.price==math.floor(entry[3]*(1+(spec.multiplier-1)*0.35)),"mutation price")
 end
 Data.mutate(unit,""); check(unit.rate==entry[4],"mutation reset")
end
check(not pcall(function() Data.mutate(Data.create(1,false),"Invalid") end),"reject unknown mutation")
for i=1,10000 do local unit=Data.randomOffer(); check(unit~=nil and (unit.mutation=="" or Specs[unit.mutation]),"valid offer") end
local normal,admin=0,0
for _,definition in pairs(Definitions) do if definition.admin then admin+=1 else normal+=1 end end
check(normal==5 and admin==5,"event counts")
local World={importCenter=-120,importCurtain=-110,aliveRoot=function() return nil end}
local Money={publish=function() end}
script={Parent={World=World,MoneyService=Money}}
''')
parts.append('local Events=(function()\n'+source('ServerScriptService/BlitzServer/EventService.lua')+'\nend)()')
parts.append('''
local player={}; local state={ready=true,cash=0}; local states={[player]=state}
local spawned=0
Events.start({},states,{spawnOffer=function(self,x,unit,scale) spawned+=1; check(Specs[unit.mutation]~=nil,"special spawn") end})
check(not Events.startEvent("Missing"),"reject invalid event")
for id,definition in pairs(Definitions) do
 check(Events.startEvent(id),"start event")
 check(workspace.attributes.BlitzEvent==id and Data.eventMutation==definition.mutation,"event state")
 check(not Events.startEvent("Gold"),"no overlapping events")
 local co=tasks[#tasks]; check(coroutine.resume(co),"event spawn loop")
 local before=state.cash
 check(Events.stop(),"stop event")
 check(state.cash==before+definition.reward,"participant reward")
 check(Lighting.ClockTime==10.5 and Lighting.Brightness==3.5 and Lighting.FogEnd==10000,"restore lighting")
 check(Data.eventMutation==nil and workspace.attributes.BlitzEvent==nil,"clear event state")
end
check(spawned==10,"all event specials")
local adminPlayer={UserId=7445776793,Name="Owner"}
local ordinary={UserId=123,Name="Guest"}
states[adminPlayer]={ready=true,cash=10}; states[ordinary]={ready=true,cash=10}
local belt={spawnOffer=function() spawned+=1 end}
script.Parent.BaseService={}
''')
parts.append('local Admin=(function()\n'+source('ServerScriptService/BlitzServer/AdminService.lua')+'\nend)()')
parts.append('''
Admin.start(states,belt,Events,function() end,function() end)
local remote
for _,instance in ipairs(instances) do if instance.Name=="BlitzAdmin" then remote=instance end end
remote.OnServerEvent.handler(ordinary,"money me 5000")
check(states[ordinary].cash==10,"reject ordinary player remote")
remote.OnServerEvent.handler(adminPlayer,"money me 5000")
check(states[adminPlayer].cash==5010,"authorized money")
check(checks>10300,"expected checks executed")
print("PASS: "..checks.." assertions; data, event lifecycle/restoration/rewards, admin authorization")
''')
parts.append('''
local persisted={level=3,steals=7,discoveries={["13_Gold"]=true},units={{id=13,mutation="Gold",slot=8}}}
local writes=0
local store={GetAsync=function() return persisted end,UpdateAsync=function(self,key,callback) persisted=callback(persisted); writes+=1 end}
game.ReplicatedStorage=Storage
local originalService=game.GetService
function game:GetService(id) if id=="DataStoreService" then return {GetDataStore=function() return store end} end; return originalService(self,id) end
function game:BindToClose(fn) end
local owner={UserId=777,Parent=Players,attributes={}}
function owner:SetAttribute(name,value) self.attributes[name]=value end
Players.GetPlayers=function() return {owner} end
local profileState={player=owner,ready=true,level=1,slots={},steals=0,savingRebirth=true}
local profileStates={[owner]=profileState}
script={Parent={BaseService={freeSlot=function(state) for i=1,8 do if not state.slots[i] then return i end end end,refreshStands=function() end,parkUnit=function(state,index,slot) state.slots[index]=slot end},CollectionService={record=function() end}}}
local oldSpawn=task.spawn
function task.spawn(fn,...) local args={...}; table.insert(tasks,coroutine.create(function() fn(table.unpack(args)) end)) end
''')
parts.append('local Mutations=(function()\n'+source('ServerScriptService/BlitzServer/MutationService.lua')+'\nend)()')
parts.append('''
local taskIndex=#tasks+1
Mutations.start(profileStates,function() end)
check(coroutine.resume(tasks[taskIndex]),"load mutation profile")
check(profileState.level==3 and profileState.steals==7,"restore level and steals")
check(profileState.slots[1].unit.mutation=="Gold" and profileState.slots[1].unit.entry==Data.cast[13],"restore owned mutation inventory")
check(owner.attributes.Mutation_13_Gold==true and profileState.savingRebirth==false,"restore discovery and release join lock")
Mutations.record(owner,Data.mutate(Data.create(1,false),"Celestial"))
Mutations.save(owner)
check(writes==1 and persisted.discoveries["1_Celestial"] and persisted.discoveries["13_Gold"],"merge persistent mutation discoveries")
check(#persisted.units==1 and persisted.units[1].id==13,"save installed mutation")
profileState.slots={}; Mutations.save(owner)
check(#persisted.units==0 and persisted.discoveries["1_Celestial"],"clearing inventory retains discovery history")
profileStates[owner]=nil; Mutations.save(owner)
check(writes==2,"never erase storage after state removal")
print("PASS: mutation profile restore, save, discovery merge, inventory removal and join lock")
''')
with tempfile.NamedTemporaryFile('w',suffix='.luau',delete=False) as f:
 f.write('\n'.join(parts)); path=f.name
try:
 subprocess.run(['/home/hatch/.local/bin/luau',path],check=True)
finally: Path(path).unlink()
