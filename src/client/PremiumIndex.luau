local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Data=require(RS.Shared.BrainrotData)
local Index={}
local screen
local function text(parent, value, pos, size, button)
 local label=Instance.new(button and "TextButton" or "TextLabel")
 label.Position=pos; label.Size=size; label.Text=value
 label.BackgroundColor3=Color3.fromRGB(29,40,61)
 label.TextColor3=Color3.fromRGB(235,243,255)
 label.Font=Enum.Font.GothamBold; label.TextSize=15; label.TextWrapped=true
 label.BorderSizePixel=0; label.Parent=parent
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,10); corner.Parent=label
 return label
end
function Index.open()
 if screen then screen.Enabled=not screen.Enabled; return end
 local player=Players.LocalPlayer
 local collection=player:WaitForChild("Collection")
 local templates=RS:WaitForChild("BrainrotPreviews")
 screen=Instance.new("ScreenGui"); screen.Name="PremiumIndex"; screen.ResetOnSpawn=false; screen.DisplayOrder=20; screen.Parent=player.PlayerGui
 local root=Instance.new("Frame"); root.Size=UDim2.fromScale(0.94,0.88); root.Position=UDim2.fromScale(0.03,0.06)
 root.BackgroundColor3=Color3.fromRGB(13,20,34); root.Parent=screen
 local limit=Instance.new("UISizeConstraint"); limit.MaxSize=Vector2.new(850,700); limit.Parent=root
 root.AnchorPoint=Vector2.new(0.5,0.5); root.Position=UDim2.fromScale(0.5,0.5)
 local close=text(root,"×",UDim2.new(1,-44,0,8),UDim2.fromOffset(36,36),true)
 close.Activated:Connect(function() screen.Enabled=false end)
 local progress=text(root,"HARBOR COLLECTION",UDim2.fromOffset(12,8),UDim2.new(1,-66,0,36))
 local search=Instance.new("TextBox"); search.PlaceholderText="Search creatures…"; search.Text=""; search.ClearTextOnFocus=false
 search.Position=UDim2.fromOffset(12,52); search.Size=UDim2.new(0.62,-18,0,38); search.TextSize=16
 search.BackgroundColor3=Color3.fromRGB(235,243,255); search.Parent=root
 local filter=text(root,"All rarities",UDim2.new(0.62,0,0,52),UDim2.new(0.38,-12,0,38),true)
 local grid=Instance.new("Frame"); grid.BackgroundTransparency=1; grid.Position=UDim2.fromOffset(12,98); grid.Size=UDim2.new(1,-24,1,-238); grid.Parent=root
 local details=text(root,"Select a creature to inspect it.",UDim2.new(0,12,1,-132),UDim2.new(1,-24,0,70))
 local previous=text(root,"‹ Previous",UDim2.new(0,12,1,-52),UDim2.new(0.3,0,0,40),true)
 local nextButton=text(root,"Next ›",UDim2.new(0.7,-12,1,-52),UDim2.new(0.3,0,0,40),true)
 local pageText=text(root,"",UDim2.new(0.32,0,1,-52),UDim2.new(0.36,0,0,40))
 local tier,page=0,1
 local function render()
  grid:ClearAllChildren()
  local found,visible=0,{}
  for _,char in ipairs(Data.Characters) do
   if collection:GetAttribute(char.id) then found+=1 end
   if (tier==0 or char.tier==Data.Tiers[tier]) and string.find(string.lower(char.name),string.lower(search.Text),1,true) then table.insert(visible,char) end
  end
  local pages=math.max(1,math.ceil(#visible/6)); page=math.clamp(page,1,pages)
  progress.Text="HARBOR COLLECTION   "..found.." / "..#Data.Characters.."   •   "..math.floor(found/#Data.Characters*100).."%"
  pageText.Text=page.." / "..pages
  filter.Text=tier==0 and "All rarities" or Data.Tiers[tier]
  for index=(page-1)*6+1,math.min(page*6,#visible) do
   local char=visible[index]; local slot=(index-1)%6
   local discovered=collection:GetAttribute(char.id)==true
   local card=text(grid,discovered and char.name or "Undiscovered • "..char.tier,
    UDim2.new((slot%2)*0.5,4,math.floor(slot/2)/3,4),UDim2.new(0.5,-8,1/3,-8),true)
   card.TextYAlignment=Enum.TextYAlignment.Bottom; card.TextSize=13
   local viewport=Instance.new("ViewportFrame"); viewport.Size=UDim2.new(1,-8,1,-30); viewport.Position=UDim2.fromOffset(4,2)
   viewport.BackgroundTransparency=1; viewport.Parent=card
   local camera=Instance.new("Camera"); camera.CFrame=CFrame.lookAt(Vector3.new(5,4,7),Vector3.new(0,1.8,0)); camera.Parent=viewport; viewport.CurrentCamera=camera
   local model=templates:FindFirstChild(char.id):Clone()
   if not discovered then
    for _,part in ipairs(model:GetDescendants()) do
     if part:IsA("BasePart") then part.Color=Color3.fromRGB(8,10,17); part.Material=Enum.Material.SmoothPlastic; part.Transparency=0 end
    end
    viewport.Ambient=Color3.new(0,0,0); viewport.LightColor=Color3.new(0,0,0)
   end
   model.Parent=viewport
   card.Activated:Connect(function()
    details.Text=(discovered and (char.name.." • "..char.caption) or "Unknown creature • collect it to reveal its identity")
     .."\n"..char.tier.." • $"..char.price.." • $"..char.income.."/s • "..string.format("%.3f%% base spawn chance",char.spawnChance*100)
    details.TextColor3=Data.TierColors[char.tier]
   end)
  end
 end
 previous.Activated:Connect(function() page-=1; render() end)
 nextButton.Activated:Connect(function() page+=1; render() end)
 filter.Activated:Connect(function() tier=(tier+1)%(#Data.Tiers+1); page=1; render() end)
 search:GetPropertyChangedSignal("Text"):Connect(function() page=1; render() end)
 collection.AttributeChanged:Connect(render)
 render()
end
return Index
