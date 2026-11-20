local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local Rules=require(RS.Shared.EventRules)
local screen
local function mount()
 if screen or player:GetAttribute("BlitzAdmin")~=true then return end
 screen=Instance.new("ScreenGui"); screen.Name="BlitzAdmin"; screen.ResetOnSpawn=false; screen.Parent=player:WaitForChild("PlayerGui")
 local open=Instance.new("TextButton"); open.Text="ADMIN"; open.Size=UDim2.fromOffset(84,36); open.Position=UDim2.new(1,-96,0,154); open.Parent=screen
 local panel=Instance.new("ScrollingFrame"); panel.Size=UDim2.fromScale(0.84,0.7); panel.Position=UDim2.fromScale(0.08,0.18)
 panel.BackgroundColor3=Color3.fromRGB(18,23,38); panel.Visible=false; panel.CanvasSize=UDim2.fromOffset(0,420); panel.Parent=screen
 local status=Instance.new("TextLabel"); status.Size=UDim2.new(1,-20,0,60); status.Position=UDim2.fromOffset(10,8)
 status.Text="ADMIN EVENTS • 90 seconds\nCommands are checked by the server."; status.TextWrapped=true; status.TextColor3=Color3.new(1,1,1); status.BackgroundTransparency=1; status.Parent=panel
 for index,def in ipairs(Rules.Admin) do
  local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-24,0,48); b.Position=UDim2.fromOffset(12,72+(index-1)*56)
  b.Text=def.name; b.Font=Enum.Font.GothamBold; b.TextSize=17; b.BackgroundColor3=Color3.fromRGB(table.unpack(def.color)); b.Parent=panel
  b.Activated:Connect(function() RS:WaitForChild("AdminEvent"):FireServer(def.id) end)
 end
 open.Activated:Connect(function() panel.Visible=not panel.Visible end)
 RS:WaitForChild("AdminEventResult").OnClientEvent:Connect(function(message) status.Text=message end)
end
player:GetAttributeChangedSignal("BlitzAdmin"):Connect(mount)
mount()
