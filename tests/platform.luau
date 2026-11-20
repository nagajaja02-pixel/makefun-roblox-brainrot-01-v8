-- Small deterministic Roblox substitutes for module behavior tests; not a renderer.
local function signal()
 local s={listeners={}}
 function s:Connect(fn) table.insert(self.listeners,fn); return {Disconnect=function() end} end
 function s:Fire(...) for _,fn in ipairs(self.listeners) do fn(...) end end
 return s
end
local Vector3={}
local vmt={}
function Vector3.new(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vmt) end
vmt.__add=function(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
vmt.__sub=function(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
vmt.__mul=function(a,b) if type(a)=="number" then a,b=b,a end; return Vector3.new(a.X*b,a.Y*b,a.Z*b) end
vmt.__index=function(a,k)
 if k=="Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end
 if k=="Unit" then return a*(1/a.Magnitude) end
 if k=="Dot" then return function(_,b) return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
end
Vector3.one=Vector3.new(1,1,1)
local Vector2={new=function(x,y) return {X=x,Y=y} end}
local Color3={}
local cmt={__index={Lerp=function(a,b,t) return Color3.new(a.R+(b.R-a.R)*t,a.G+(b.G-a.G)*t,a.B+(b.B-a.B)*t) end}}
function Color3.new(r,g,b) return setmetatable({R=r,G=g,B=b},cmt) end
function Color3.fromRGB(r,g,b) return Color3.new(r/255,g/255,b/255) end
function Color3.fromHSV(h,s,v) return Color3.new(h,s,v) end
local CFrame={}
function CFrame.new(...) return setmetatable({args={...},LookVector=Vector3.new(0,0,-1)},{__mul=function(a) return a end}) end
CFrame.Angles=CFrame.new; CFrame.lookAt=CFrame.new; CFrame.identity=CFrame.new()
local UDim={new=function(s,o) return {Scale=s,Offset=o} end}
local UDim2={new=function(a,b,c,d) return {X={Scale=a,Offset=b},Y={Scale=c,Offset=d}} end}
UDim2.fromScale=function(a,b) return UDim2.new(a,0,b,0) end
UDim2.fromOffset=function(a,b) return UDim2.new(0,a,0,b) end
local Enum=setmetatable({},{__index=function(t,k) local e=setmetatable({},{__index=function(_,v) return k.."."..v end});rawset(t,k,e);return e end})
local Instance={}
local methods={}
local imt={}
imt.__index=function(t,k)
 local v=methods[k] or t.props[k]
 if v~=nil then return v end
 for _,c in ipairs(t.children) do if c.Name==k then return c end end
end
imt.__newindex=function(t,k,v)
 if k=="Parent" then
  local old=t.props.Parent
  if old then local i=table.find(old.children,t);if i then table.remove(old.children,i) end end
  if v then table.insert(v.children,t) end
 end
 t.props[k]=v
end
function Instance.new(class)
 local t=setmetatable({props={ClassName=class,Name=class},children={},attributes={},changed={}},imt)
 for _,event in ipairs({"Activated","MouseButton1Click","Changed","AttributeChanged","OnServerEvent","OnClientEvent","CharacterAdded","MouseClick","Died"}) do t.props[event]=signal() end
 t.props.TintColor=Color3.new(1,1,1)
 if class=="IntValue" then t.props.Value=0 end
 return t
end
function methods:IsA(c) return self.ClassName==c or c=="JointInstance" and self.ClassName=="Weld" or c=="BasePart" and self.ClassName=="Part" end
function methods:GetChildren() return table.clone(self.children) end
function methods:GetDescendants()
 local out={}
 local function visit(t) for _,c in ipairs(t.children) do table.insert(out,c);visit(c) end end
 visit(self);return out
end
function methods:FindFirstChild(n) for _,c in ipairs(self.children) do if c.Name==n then return c end end end
function methods:WaitForChild(n) return assert(self:FindFirstChild(n),self.Name.." missing "..n) end
function methods:FindFirstChildOfClass(c) for _,child in ipairs(self.children) do if child.ClassName==c then return child end end end
function methods:SetAttribute(n,v) self.attributes[n]=v;self.AttributeChanged:Fire(n); if self.changed[n] then self.changed[n]:Fire(v) end end
function methods:GetAttribute(n) return self.attributes[n] end
function methods:GetAttributes() return table.clone(self.attributes) end
function methods:GetPropertyChangedSignal(n) if not self.changed[n] then self.changed[n]=signal() end;return self.changed[n] end
methods.GetAttributeChangedSignal=methods.GetPropertyChangedSignal
function methods:Destroy() self.Parent=nil;self.destroyed=true end
function methods:ClearAllChildren() for _,c in ipairs(self:GetChildren()) do c:Destroy() end end
function methods:PivotTo(cf) self.Pivot=cf end
function methods:ScaleTo(scale) self.Scale=scale end
function methods:Clone()
 local copy=Instance.new(self.ClassName)
 for k,v in pairs(self.props) do if k~="Parent" and type(v)~="function" then copy[k]=v end end
 for _,c in ipairs(self.children) do local cc=c:Clone(); cc.Parent=copy end
 return copy
end
function methods:FireServer(...) self.sent={...} end
function methods:FireClient(player,...) self.reply={player,...} end
function methods:GetServerTimeNow() return 1000 end
local tasks={}
local task={}
function task.spawn(fn,...) local co=coroutine.create(fn);table.insert(tasks,{co=co,args={...}}) end
function task.wait(n) coroutine.yield(n or 0) end
local function pump(count)
 for _=1,count do
  local batch=tasks;tasks={}
  for _,t in ipairs(batch) do
   local ok,err=coroutine.resume(t.co,table.unpack(t.args));assert(ok,err);t.args={}
   if coroutine.status(t.co)~="dead" then table.insert(tasks,t) end
  end
 end
end
local RaycastParams={new=function() return {} end}
local TweenInfo={new=function(...) return {...} end}
local services={}
local game={CreatorId=123,CreatorType=Enum.CreatorType.User}
function game:GetService(n) return assert(services[n],n) end
function game:BindToClose(fn) self.close=fn end
local workspace=Instance.new("Workspace")
local island=Instance.new("Folder");island.Name="Island";island.Parent=workspace
local RS=Instance.new("ReplicatedStorage");services.ReplicatedStorage=RS
RS.Shared={BrainrotData="Data",CombatRules="CombatRules",EventRules="EventRules"}
local player=Instance.new("Player");player.UserId=123;player.DisplayName="HarborTester";player.Parent=Instance.new("Players")
local gui=Instance.new("PlayerGui");gui.Name="PlayerGui";gui.Parent=player
player.PlayerGui=gui
local stats=Instance.new("Folder");stats.Name="leaderstats";stats.Parent=player
for _,n in ipairs({"Cash","Rebirths","Income"}) do local v=Instance.new("IntValue");v.Name=n;v.Value=0;v.Parent=stats end
local players={LocalPlayer=player,PlayerAdded=signal(),PlayerRemoving=signal()}
function players:GetPlayers() return {player} end
function players:GetNameFromUserIdAsync(id) return "Player"..id end
services.Players=players
local lighting=Instance.new("Lighting");lighting.ClockTime=16;lighting.Ambient=Color3.fromRGB(90,100,110);services.Lighting=lighting
local tween={}
function tween:Create(target,info,goals)
 return {Play=function() for k,v in pairs(goals) do target[k]=v end end}
end
services.TweenService=tween
services.Debris={AddItem=function() end}
local stores={}
services.DataStoreService={GetRequestBudgetForRequestType=function() return 100 end}
local function getStore(_,name)
 if not stores[name] then
  local s={values={},writes=0}
  function s:GetAsync(k) return self.values[k] end
  function s:SetAsync(k,v) self.values[k]=v;self.writes+=1 end
  function s:UpdateAsync(k,fn) self.values[k]=fn(self.values[k]);self.writes+=1 end
  function s:GetSortedAsync()
   local rows={};for k,v in pairs(self.values) do table.insert(rows,{key=k,value=v}) end
   table.sort(rows,function(a,b) return a.value>b.value end)
   return {GetCurrentPage=function() return rows end}
  end
  stores[name]=s
 end
 return stores[name]
end
services.DataStoreService.GetDataStore=getStore;services.DataStoreService.GetOrderedDataStore=getStore
services.HttpService={JSONEncode=function(_,v) services.LastJSON=v;return "snapshot" end}
local loaded={}
local require=function(key) return assert(loaded[key],"missing module "..tostring(key)) end
local script={Parent={BrainrotModels="Models",AdminConfig="AdminConfig"}}
local warn=function() end
