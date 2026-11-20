local player=game:GetService("Players").LocalPlayer
local screen=Instance.new("ScreenGui"); screen.Name="HarborEvents"; screen.ResetOnSpawn=false; screen.Parent=player:WaitForChild("PlayerGui")
local banner=Instance.new("TextLabel")
banner.Size=UDim2.new(0.86,0,0,60); banner.AnchorPoint=Vector2.new(0.5,1); banner.Position=UDim2.fromScale(0.5,0.98)
banner.BackgroundColor3=Color3.fromRGB(22,30,52); banner.BackgroundTransparency=0.15
banner.TextColor3=Color3.fromRGB(200,235,255); banner.TextSize=16; banner.TextWrapped=true; banner.Font=Enum.Font.GothamBold
banner.Parent=screen
local corner=Instance.new("UICorner"); corner.Parent=banner
while true do
 local name=workspace:GetAttribute("ActiveEvent")
 banner.Visible=type(name)=="string" and name~=""
 if banner.Visible then
  local remaining=math.max(0,math.ceil((workspace:GetAttribute("EventEndsAt") or 0)-workspace:GetServerTimeNow()))
  banner.Text=name.." • "..remaining.."s\n"..(workspace:GetAttribute("EventNote") or "")
 end
 task.wait(1)
end
