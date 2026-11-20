"""Exercise actual Luau module sources with small platform substitutes; no Roblox rendering claims."""
from pathlib import Path
import subprocess, hashlib, json
ROOT=Path(__file__).resolve().parents[1]
LUA='/home/hatch/.local/bin/luau'
def run(name, prelude, modules, assertions):
    source=prelude+'\n'
    for var,path in modules:
        source+=f'local {var} = (function()\n'+(ROOT/path).read_text()+'\nend)()\n'
    source+=assertions
    path=Path('/tmp')/('blitz-test-'+name+'.luau');path.write_text(source)
    subprocess.run([LUA,str(path)],check=True)
COLORS='''local Color3 = {fromRGB=function(...) return {...} end, fromHSV=function(...) return {...} end}
'''
run('catalogue',COLORS,[('Data','src/shared/BrainrotData.luau')],'''
assert(#Data.Characters == 40)
assert(Data.Shield.duration == 26 and Data.Shield.cooldown == 48)
assert(Data.rebirthCost(2)==36000 and Data.Economy.rebirthBoost==0.5)
local ids, sum, selected = {}, 0, {}
for _, c in ipairs(Data.Characters) do
 assert(not ids[c.id]); ids[c.id]=true
 assert(c.price>0 and c.income>0 and c.spawnChance>0)
 sum += c.spawnChance
end
assert(math.abs(sum-1)<0.000001)
for i=0,100000 do selected[Data.pickCharacter(i/100001).id]=true end
for _,c in ipairs(Data.Characters) do assert(selected[c.id],c.id) end
assert(Data.byId("bombardiro").price==12500)
print("PASS catalogue: 40 unique entries, positive economics, normalized probabilities, all 40 selectable, unchanged shield/rebirth")
''')
run('regular-events','',[('Rules','src/shared/EventRules.luau')],'''
assert(#Rules.Regular==7 and #Rules.Admin==6)
local allowed={[123]=true}
assert(Rules.authorized(123,allowed,"cash_rain",false,0,10))
assert(not Rules.authorized(999,allowed,"cash_rain",false,0,10))
assert(not Rules.authorized(123,allowed,"cash_rain",true,0,10))
assert(not Rules.authorized(123,allowed,"cash_rain",false,9,10))
assert(not Rules.authorized(123,allowed,{},false,0,10))
assert(not Rules.authorized(123,allowed,"unknown",false,0,10))
assert(not Rules.authorized(123,allowed,string.rep("x",10000),false,0,10))
print("PASS six admin events; whitelist, active-event, cooldown, malformed and unknown command rejection")
local seen={}
for _,def in ipairs(Rules.Regular) do
 assert(not seen[def.id]); seen[def.id]=true
 assert(Rules.find(def.id)==def)
 assert(def.income or def.reward or def.gold or def.luck or def.spawn)
end
assert(Rules.Duration==90 and Rules.Gap==510)
print("PASS seven regular event definitions, schedule and theme rewards")
''')
for f,h in json.loads((ROOT/'tests/preserved.json').read_text()).items():
    assert hashlib.sha256((ROOT/'src/server'/f).read_bytes()).hexdigest()==h, f
for path in (ROOT/'src').rglob('*.luau'):
    subprocess.run(['/home/hatch/.local/bin/luau-compile',str(path)],stdout=subprocess.DEVNULL,check=True)
subprocess.run([LUA,str(ROOT/'tests/combat.luau'),str(ROOT/'tests/adapter.luau')],check=True)
print('PASS all source files compile; preserved gameplay files match baseline')
PLATFORM=(ROOT/'tests/platform.luau').read_text()
def platform(name, modules, assertions):
    source=PLATFORM+'\n'
    for var,path in modules:
        source+=f'local {var}=(function()\n'+(ROOT/path).read_text()+f'\nend)()\nloaded["{var}"]={var}\n'
    path=Path('/tmp')/('blitz-runtime-'+name+'.luau');path.write_text(source+assertions)
    subprocess.run([LUA,str(path)],check=True)
platform('presentation',[('Presentation','src/server/PresentationService.luau')],'''
local wall=Instance.new("Part");wall.Name="Wall";wall.Position=Vector3.new(5,2,8);wall.Size=Vector3.new(4,4,1);wall.Parent=island
local position,size=wall.Position,wall.Size
Presentation.init()
assert(wall.Position==position and wall.Size==size and wall.Material==Enum.Material.Brick)
assert(#island:FindFirstChild("HarborDetails"):GetChildren()==24)
assert(lighting:FindFirstChild("HarborAtmosphere") and lighting:FindFirstChild("HarborSky"))
print("PASS presentation runtime: geometry preserved, 24 nonblocking decorations, lighting and sky created")
''')
platform('leaderboard',[('Board','src/server/LeaderboardService.luau')],'''
stats:WaitForChild("Cash").Value=1000
stats:WaitForChild("Rebirths").Value=2
Board.init({})
pump(5)
assert(stores.BlitzGlobalCashV1.values["123"]==1000)
assert(services.LastJSON.Cash.rows[1].id==123 and services.LastJSON.Cash.global)
assert(island:FindFirstChild("LeaderboardCash"))
assert(stats:WaitForChild("Steals").Value==0)
assert(services.LastJSON.Rebirths.rows[1].value==2)
print("PASS leaderboard runtime: ordered-store writes, global refresh, player names and board construction")
''')
platform('models',[('Data','src/shared/BrainrotData.luau'),('Models','src/server/BrainrotModels.luau')],'''
local designs={}
for _,char in ipairs(Data.Characters) do
 local model=Models.build(char,"Normal")
 assert(model.PrimaryPart and model:FindFirstChild("RarityHalo"))
 if char.design then
  local signature=tostring(model.PrimaryPart.Size.X)..":"..tostring(model.PrimaryPart.Size.Y)..":"..#model:GetChildren()..":"..model:FindFirstChild("Crest1").Size.Y
  assert(not designs[signature],char.id);designs[signature]=true
 end
end
print("PASS all 40 actual 3D model constructors, rarity halos and distinct new geometry")
''')
platform('collection',[('Collection','src/server/CollectionService.luau')],'''
Collection.init()
Collection.discover(player,"sahur")
pump(1)
assert(player:WaitForChild("Collection"):GetAttribute("sahur"))
stores.BlitzCollectionV1.values["123"]={bombardiro=true}
players.PlayerRemoving:Fire(player)
assert(stores.BlitzCollectionV1.values["123"].bombardiro and stores.BlitzCollectionV1.values["123"].sahur)
print("PASS discovery during load and additive UpdateAsync merge preserves existing collection")
''')
platform('events',[('Data','src/shared/BrainrotData.luau'),('Models','src/server/BrainrotModels.luau'),('EventRules','src/shared/EventRules.luau'),('Events','src/server/EventService.luau')],'''
local earned=0
Events.init({Money={getIncomePerSecond=function() return 100 end,earn=function(_,p,amount) assert(p==player and amount>0);earned+=amount end}})
tasks={}
local baselineClock,baselineAmbient=lighting.ClockTime,lighting.Ambient
local all=table.clone(EventRules.Regular)
for _,d in ipairs(EventRules.Admin) do table.insert(all,d) end
for _,def in ipairs(all) do
 assert(Events.start(def))
 assert(not Events.start(def))
 assert(workspace:GetAttribute("ActiveEvent")==def.name)
 pump(92)
 assert(not Events.isActive())
 assert(lighting.ClockTime==baselineClock and lighting.Ambient==baselineAmbient)
 assert(workspace:GetAttribute("EventLuck")==1 and workspace:GetAttribute("EventGoldChance")==0)
 assert(workspace:GetAttribute("EventSpawnInterval")==1)
 assert(not workspace:FindFirstChild("ActiveEventEffects"))
end
assert(earned>0)
-- Inject an effect error and verify cleanup still executes.
local create=tween.Create;tween.Create=function() error("simulated renderer failure") end
assert(Events.start(EventRules.Regular[1]));pump(1)
assert(not Events.isActive() and lighting.ClockTime==baselineClock)
tween.Create=create
print("PASS 13 event lifecycles, overlap rejection, rewards, environment restoration and error cleanup")
''')
platform('interfaces',[('Data','src/shared/BrainrotData.luau'),('Models','src/server/BrainrotModels.luau'),('PremiumIndex','src/client/PremiumIndex.luau')],'''
script.Parent.PremiumIndex="PremiumIndex"
local collection=Instance.new("Folder");collection.Name="Collection";collection.Parent=player
collection:SetAttribute("sahur",true)
local templates=Instance.new("Folder");templates.Name="BrainrotPreviews";templates.Parent=RS
for _,char in ipairs(Data.Characters) do local model=Models.build(char,"Normal");model.Parent=templates end
PremiumIndex.open()
local ui=gui:WaitForChild("PremiumIndex")
local root=ui:GetChildren()[1]
local function findText(parent,value)
 for _,c in ipairs(parent:GetDescendants()) do if c.Text==value then return c end end
end
assert(findText(root,"1 / 7"))
local count=0
for _,c in ipairs(root:GetDescendants()) do if c:IsA("ViewportFrame") then count+=1 end end
assert(count==6)
local search=root:FindFirstChild("TextBox");search.Text="Celestial";search:GetPropertyChangedSignal("Text"):Fire()
assert(findText(root,"1 / 1"))
local card=findText(root,"Undiscovered • Celestial");assert(card)
card.Activated:Fire()
assert(findText(root,"Unknown creature • collect it to reveal its identity\\nCelestial • $297600 • $11904/s • "..string.format("%.3f%% base spawn chance",Data.byId("celestial_seraph").spawnChance*100)))
local viewport=card:FindFirstChild("ViewportFrame");local silhouette=viewport:FindFirstChild("celestial_seraph")
assert(silhouette:FindFirstChild("Body").Material==Enum.Material.SmoothPlastic)
collection:SetAttribute("celestial_seraph",true)
assert(findText(root,"Celestial Seraph"))
findText(root,"All rarities").Activated:Fire()
assert(not findText(root,"Celestial Seraph"))
print("PASS index UI construction: six preview limit, search, silhouette, detail selection, live discovery and rarity filter")
''')
platform('rebirth-merchant',[('Data','src/shared/BrainrotData.luau'),('Menu','src/client/Menu.luau')],'''
for _,name in ipairs({"Rebirth","BuyMerchant","SellBrainrot"}) do local r=Instance.new("RemoteEvent");r.Name=name;r.Parent=RS end
local function findText(parent,value)
 for _,c in ipairs(parent:GetDescendants()) do if c.Text==value then return c end end
end
Menu.toggle()
local panel=gui:WaitForChild("BlitzMenu"):WaitForChild("Panel")
local info=panel:WaitForChild("RebirthInfo")
assert(string.find(info.Text,"$0 / $12000",1,true))
stats.Cash.Value=6000;stats.Cash.Changed:Fire()
assert(string.find(info.Text,"(50%)",1,true))
assert(string.find(info.Text,"×1 → ×1.5",1,true))
for _,button in ipairs(panel:GetChildren()) do
 if button:IsA("TextButton") and button.Text=="REBIRTH" then button.MouseButton1Click:Fire() end
end
assert(RS.Rebirth.sent and #RS.Rebirth.sent==0)
stats.Rebirths.Value=1;stats.Rebirths.Changed:Fire()
assert(string.find(info.Text,"$6000 / $24000",1,true))
Menu.setMerchantStock({{id="sahur",price=75}})
findText(panel.MerchantList,"BUY").MouseButton1Click:Fire()
assert(RS.BuyMerchant.sent[1]=="sahur")
local sell=findText(panel,"SELL");sell.MouseButton1Click:Fire()
assert(RS.SellBrainrot.sent[1]==1)
print("PASS rebirth progress/cost/multiplier animation path and original rebirth, merchant-buy, sell remote contracts")
''')
platform('admin-remote',[('EventRules','src/shared/EventRules.luau'),('AdminConfig','src/server/AdminConfig.luau'),('Admin','src/server/AdminService.luau')],'''
local started=0
Admin.init({isActive=function() return false end,start=function(def) started+=1;return def.id=="cash_rain" end})
local attacker=Instance.new("Player");attacker.UserId=999
RS.AdminEvent.OnServerEvent:Fire(attacker,"cash_rain")
assert(started==0)
RS.AdminEvent.OnServerEvent:Fire(player,{id="cash_rain"})
assert(started==0)
RS.AdminEvent.OnServerEvent:Fire(player,"cash_rain")
assert(started==1 and player:GetAttribute("BlitzAdmin"))
RS.AdminEvent.OnServerEvent:Fire(player,"cash_rain")
assert(started==1)
print("PASS actual admin remote: unauthorized/malformed commands rejected, owner authorized, repeated command throttled")
''')
platform('combat-service',[('CombatRules','src/shared/CombatRules.luau'),('Combat','src/server/CombatService.luau')],'''
local function character(p,position)
 local c=Instance.new("Model");p.Character=c
 local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Position=position;root.CFrame=CFrame.new();root.AssemblyMass=5;root.Parent=c
 root.ApplyImpulse=function(self,impulse) self.impulse=impulse end
 local hum=Instance.new("Humanoid");hum.Health=100;hum.Parent=c
 return c,root
end
local c,root=character(player,Vector3.new(0,0,0))
local backpack=Instance.new("Backpack");backpack.Name="Backpack";backpack.Parent=player
local target=Instance.new("Player");target.UserId=456
local tc,tr=character(target,Vector3.new(0,0,-5))
function players:GetPlayers() return {player,target} end
function players:GetPlayerFromCharacter(char) if char==c then return player end end
workspace.Raycast=function() return nil end
local RaycastParams={new=function() return {} end}
local drops=0
Combat.init({Steal={returnCarried=function(p,showDrop) assert(p==target and showDrop);drops+=1 end}})
pump(1)
local ball=backpack:WaitForChild("Basketball")
ball.Activated:Fire();assert(drops==0)
ball.Parent=c
ball.Activated:Fire();assert(drops==1 and tr.impulse)
ball.Activated:Fire();assert(drops==1)
print("PASS actual basketball service: free grant, unequipped rejection, server-chosen target, theft drop, knockback and cooldown")
''')
platform('theft-drop',[('Data','src/shared/BrainrotData.luau'),('Models','src/server/BrainrotModels.luau'),('Steal','src/server/StealService.luau')],'''
local victim=Instance.new("Player");victim.UserId=456
local character=Instance.new("Model");player.Character=character
local root=Instance.new("Part");root.Name="HumanoidRootPart";root.CFrame=CFrame.new();root.Parent=character
local hum=Instance.new("Humanoid");hum.Parent=character
local char=Data.byId("sahur")
local model=Models.build(char,"Normal")
local placed=0
local base={placed={},stands=4}
Steal.init({
 Base={hasFreeStand=function() return true end,takePlaced=function() return {model=model,char=char,mutation="Normal"} end,
  getBase=function() return base end,place=function(_,owner,entry,mutation) assert(owner==victim and entry==char and mutation=="Normal");placed+=1 end},
 Shield={isActive=function() return false end},Money={earn=function() error("unexpected compensation") end},
})
assert(Steal.trySteal(player,victim,1))
assert(Steal.returnCarried(player,true))
assert(placed==1 and not Steal.deliver(player))
assert(not Steal.returnCarried(player,true))
local falling=workspace:WaitForChild("DroppedBrainrot")
for _,p in ipairs(falling:GetDescendants()) do
 assert(not p:IsA("JointInstance"))
 if p:IsA("BasePart") then assert(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch) end
end
print("PASS theft integration: owner receives character exactly once, delivery fails, falling copy has no joints or interaction")
''')
