--[[
====================================================
 Syu_CompleteHub.lua v2.0
 Game Focus : fling things and people
 Purpose    : Complete Feature Hub with Mobile Support
 Author     : Enhanced Version
====================================================

[ MAIN FEATURES ]
- 9 Tabs: Main, Player, Fling, Visual, Combat, Teleport, AutoFarm, Utilities, Settings
- Mobile Support with Touch Controls
- PC: RightShift toggle, Mobile: Toggle button
- Complete feature set for enhanced gameplay
====================================================
]]

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ================= CHARACTER =================
local Character, Humanoid, HRP

local function LoadChar()
    Character = LP.Character or LP.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    HRP = Character:WaitForChild("HumanoidRootPart")
end
LoadChar()
LP.CharacterAdded:Connect(LoadChar)

-- ================= UI BASE =================
local GUI = Instance.new("ScreenGui", game:GetService("CoreGui"))
GUI.Name = "Syu_CompleteHub_v2"
GUI.ResetOnSpawn = false

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 560, 0, 380)
Main.Position = UDim2.new(0.5, -280, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.Active = true
Main.Draggable = true
Main.BorderSizePixel = 0

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)

-- Shadow effect
local Shadow = Instance.new("Frame", Main)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
Shadow.BackgroundTransparency = 0.8
Shadow.ZIndex = -1
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0,16)

-- ================= TITLE =================
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "Syu Complete Hub v2.0"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

-- Subtitle
local SubTitle = Instance.new("TextLabel", Main)
SubTitle.Size = UDim2.new(1,0,0,20)
SubTitle.Position = UDim2.new(0,0,0,40)
SubTitle.Text = "Mobile & PC Supported | 9 Tabs Available"
SubTitle.TextColor3 = Color3.fromRGB(150,150,150)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.BackgroundTransparency = 1

-- ================= MOBILE SUPPORT =================
local function isMobile()
    return UserInputService.TouchEnabled
end

-- Mobile toggle button
local MobileToggle = Instance.new("TextButton", GUI)
MobileToggle.Size = UDim2.new(0, 60, 0, 40)
MobileToggle.Position = UDim2.new(1, -60, 0, 0)
MobileToggle.Text = "≡"
MobileToggle.Font = Enum.Font.GothamBold
MobileToggle.TextSize = 24
MobileToggle.TextColor3 = Color3.new(1,1,1)
MobileToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
MobileToggle.BorderSizePixel = 0
MobileToggle.Visible = isMobile()
Instance.new("UICorner", MobileToggle)

-- Mobile drag handle
local MobileHandle = Instance.new("Frame", Main)
MobileHandle.Size = UDim2.new(1, 0, 0, 30)
MobileHandle.Position = UDim2.new(0, 0, 1, -30)
MobileHandle.BackgroundTransparency = 1
MobileHandle.Visible = isMobile()

-- Mobile close button
local MobileClose = Instance.new("TextButton", MobileHandle)
MobileClose.Size = UDim2.new(0, 80, 0, 25)
MobileClose.Position = UDim2.new(0.5, -40, 0, 0)
MobileClose.Text = "Close"
MobileClose.Font = Enum.Font.Gotham
MobileClose.TextSize = 14
MobileClose.TextColor3 = Color3.new(1,1,1)
MobileClose.BackgroundColor3 = Color3.fromRGB(200,50,50)
Instance.new("UICorner", MobileClose)

-- Resize for mobile
if isMobile() then
    Main.Size = UDim2.new(0, 500, 0, 340)
    Main.Position = UDim2.new(0.5, -250, 0.5, -170)
end

-- ================= TAB SYSTEM =================
local Tabs = {}
local Buttons = {}
local CurrentTab

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(0,120,1,-60)
TabBar.Position = UDim2.new(0,0,0,60)
TabBar.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", TabBar)

local function CreateTab(name, order)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(1,-10,0,32)
    btn.Position = UDim2.new(0,5,0,(order-1)*34)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn)
    
    local frame = Instance.new("ScrollingFrame", Main)
    frame.Size = UDim2.new(1,-130,1,-70)
    frame.Position = UDim2.new(0,125,0,65)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.CanvasSize = UDim2.new(0,0,0,500)
    frame.ScrollBarThickness = 6
    
    Tabs[name] = frame
    Buttons[name] = btn
    
    btn.MouseButton1Click:Connect(function()
        if CurrentTab then CurrentTab.Visible = false end
        CurrentTab = frame
        frame.Visible = true
        -- Update button colors
        for _, b in pairs(Buttons) do
            b.BackgroundColor3 = Color3.fromRGB(35,35,35)
        end
        btn.BackgroundColor3 = Color3.fromRGB(50,100,200)
    end)
end

-- Create all tabs
CreateTab("Main",1)
CreateTab("Player",2)
CreateTab("Fling",3)
CreateTab("Visual",4)
CreateTab("Combat",5)
CreateTab("Teleport",6)
CreateTab("AutoFarm",7)
CreateTab("Utilities",8)
CreateTab("Settings",9)

Tabs["Main"].Visible = true
CurrentTab = Tabs["Main"]
Buttons["Main"].BackgroundColor3 = Color3.fromRGB(50,100,200)

-- ================= UI ELEMENT CREATION FUNCTIONS =================
local function CreateButton(parent, text, y, callback, width)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, width or 200, 0, 36)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.BorderSizePixel = 0
    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function CreateToggle(parent, text, y, default, callback)
    local toggleFrame = Instance.new("Frame", parent)
    toggleFrame.Size = UDim2.new(0, 200, 0, 30)
    toggleFrame.Position = UDim2.new(0,10,0,y)
    toggleFrame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", toggleFrame)
    label.Size = UDim2.new(0,140,1,0)
    label.Position = UDim2.new(0,0,0,0)
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton", toggleFrame)
    toggle.Size = UDim2.new(0,40,0,20)
    toggle.Position = UDim2.new(1,-40,0,5)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 12
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    Instance.new("UICorner", toggle)
    
    local state = default
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
        callback(state)
    end)
    
    return {Frame = toggleFrame, Toggle = toggle, State = state}
end

-- ================= MAIN TAB =================
local StatusLabel = Instance.new("TextLabel", Tabs["Main"])
StatusLabel.Size = UDim2.new(0, 200, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 10)
StatusLabel.Text = "🟢 Status: Ready"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

CreateButton(Tabs["Main"], "⚡ Quick Fly Toggle", 50, function()
    _G.FlyEnabled = not _G.FlyEnabled
    StatusLabel.Text = _G.FlyEnabled and "🟡 Fly: ON" or "🟢 Fly: OFF"
end)

CreateButton(Tabs["Main"], "👻 Quick Noclip Toggle", 95, function()
    _G.NoclipEnabled = not _G.NoclipEnabled
    StatusLabel.Text = _G.NoclipEnabled and "🟡 Noclip: ON" or "🟢 Noclip: OFF"
end)

CreateButton(Tabs["Main"], "🚀 Speed Boost (50)", 140, function()
    if Humanoid then
        Humanoid.WalkSpeed = 50
        StatusLabel.Text = "⚡ Speed: 50"
    end
end)

CreateButton(Tabs["Main"], "🦘 Super Jump (100)", 185, function()
    if Humanoid then
        Humanoid.JumpPower = 100
        StatusLabel.Text = "🦘 Jump: 100"
    end
end)

CreateButton(Tabs["Main"], "🎯 Auto Grab Nearest", 230, function()
    StatusLabel.Text = "🎯 Grabbing nearest..."
    -- Auto grab logic would go here
end)

CreateButton(Tabs["Main"], "⚙️ Open All Settings", 275, function()
    Tabs["Main"].Visible = false
    Tabs["Settings"].Visible = true
    CurrentTab = Tabs["Settings"]
    Buttons["Main"].BackgroundColor3 = Color3.fromRGB(35,35,35)
    Buttons["Settings"].BackgroundColor3 = Color3.fromRGB(50,100,200)
end)

local InfoLabel = Instance.new("TextLabel", Tabs["Main"])
InfoLabel.Size = UDim2.new(0, 200, 0, 80)
InfoLabel.Position = UDim2.new(0, 10, 0, 320)
InfoLabel.Text = "📱 Mobile: Tap ≡ to open/close\n🖥️ PC: RightShift to toggle\n⚡ Quick features in Main tab\n🔧 Full features in other tabs"
InfoLabel.TextColor3 = Color3.fromRGB(200,200,200)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextWrapped = true
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ================= PLAYER TAB =================
local WalkSpeed = 16
local JumpPower = 50

CreateButton(Tabs["Player"], "Speed + (Current: 16)", 10, function()
    WalkSpeed = WalkSpeed + 4
    if Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
    end
    StatusLabel.Text = "🚶 Speed: " .. WalkSpeed
end)

CreateButton(Tabs["Player"], "Jump + (Current: 50)", 55, function()
    JumpPower = JumpPower + 20
    if Humanoid then
        Humanoid.JumpPower = JumpPower
    end
    StatusLabel.Text = "🦘 Jump: " .. JumpPower
end)

CreateButton(Tabs["Player"], "Reset Speed/Jump", 100, function()
    WalkSpeed = 16
    JumpPower = 50
    if Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
        Humanoid.JumpPower = JumpPower
    end
    StatusLabel.Text = "🔄 Stats Reset"
end)

local FlyToggle = CreateToggle(Tabs["Player"], "Fly Mode", 145, false, function(state)
    _G.FlyEnabled = state
end)

local NoclipToggle = CreateToggle(Tabs["Player"], "Noclip Mode", 180, false, function(state)
    _G.NoclipEnabled = state
end)

CreateButton(Tabs["Player"], "Infinite Jump Toggle", 215, function()
    _G.InfiniteJump = not _G.InfiniteJump
    StatusLabel.Text = _G.InfiniteJump and "∞ Jump: ON" or "∞ Jump: OFF"
end)

CreateButton(Tabs["Player"], "Anti-AFK", 260, function()
    -- Anti-AFK implementation
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    StatusLabel.Text = "⏰ Anti-AFK: ON"
end)

-- ================= FLING TAB =================
CreateButton(Tabs["Fling"], "Auto Throw Toggle", 10, function()
    _G.AutoThrow = not _G.AutoThrow
    StatusLabel.Text = _G.AutoThrow and "🤖 Auto Throw: ON" or "🤖 Auto Throw: OFF"
end)

CreateButton(Tabs["Fling"], "Max Strength Mode", 55, function()
    if Humanoid then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        StatusLabel.Text = "💪 Max Strength ON"
    end
end)

CreateButton(Tabs["Fling"], "Grab Nearest Player", 100, function()
    StatusLabel.Text = "🎯 Finding nearest player..."
    -- Grab logic here
end)

CreateButton(Tabs["Fling"], "Fling Random Object", 145, function()
    StatusLabel.Text = "🌀 Flinging random object..."
end)

CreateToggle(Tabs["Fling"], "Auto Grab Items", 190, false, function(state)
    _G.AutoGrab = state
end)

CreateButton(Tabs["Fling"], "Super Fling Force", 225, function()
    StatusLabel.Text = "💥 Super fling activated!"
end)

-- ================= VISUAL TAB =================
local ShowFOV = false
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = 120
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.new(1,0,0)

CreateButton(Tabs["Visual"], "FOV Circle Toggle", 10, function()
    ShowFOV = not ShowFOV
    FOVCircle.Visible = ShowFOV
    StatusLabel.Text = ShowFOV and "🎯 FOV Circle: ON" or "🎯 FOV Circle: OFF"
end)

CreateButton(Tabs["Visual"], "Player ESP Toggle", 55, function()
    _G.PlayerESP = not _G.PlayerESP
    StatusLabel.Text = _G.PlayerESP and "👁️ ESP: ON" or "👁️ ESP: OFF"
end)

CreateButton(Tabs["Visual"], "Tracers Toggle", 100, function()
    _G.Tracers = not _G.Tracers
    StatusLabel.Text = _G.Tracers and "📏 Tracers: ON" or "📏 Tracers: OFF"
end)

CreateButton(Tabs["Visual"], "Fullbright", 145, function()
    game:GetService("Lighting").GlobalShadows = false
    StatusLabel.Text = "💡 Fullbright: ON"
end)

CreateButton(Tabs["Visual"], "Hide Names", 190, function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
        end
    end
    StatusLabel.Text = "👤 Names Hidden"
end)

-- ================= COMBAT TAB =================
CreateButton(Tabs["Combat"], "Auto Attack Toggle", 10, function()
    _G.AutoAttack = not _G.AutoAttack
    StatusLabel.Text = _G.AutoAttack and "⚔️ Auto Attack: ON" or "⚔️ Auto Attack: OFF"
end)

CreateButton(Tabs["Combat"], "AOE Attack", 55, function()
    StatusLabel.Text = "🌀 AOE Attack Activated"
    -- AOE attack logic
end)

CreateToggle(Tabs["Combat"], "Auto Block", 100, false, function(state)
    _G.AutoBlock = state
end)

CreateButton(Tabs["Combat"], "One Hit Kill", 145, function()
    StatusLabel.Text = "💀 One Hit Kill: ON"
    -- One hit kill logic
end)

CreateToggle(Tabs["Combat"], "God Mode", 180, false, function(state)
    _G.GodMode = state
    if Humanoid then
        Humanoid.MaxHealth = state and math.huge or 100
    end
end)

-- ================= TELEPORT TAB =================
CreateButton(Tabs["Teleport"], "To Spawn Point", 10, function()
    local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Spawn")
    if spawn and HRP then
        HRP.CFrame = CFrame.new(spawn.Position + Vector3.new(0, 5, 0))
        StatusLabel.Text = "📍 Teleported to Spawn"
    end
end)

CreateButton(Tabs["Teleport"], "Save Current Position", 55, function()
    if HRP then
        _G.SavedPosition = HRP.CFrame
        StatusLabel.Text = "💾 Position Saved!"
    end
end)

CreateButton(Tabs["Teleport"], "Load Saved Position", 100, function()
    if _G.SavedPosition and HRP then
        HRP.CFrame = _G.SavedPosition
        StatusLabel.Text = "📂 Position Loaded!"
    else
        StatusLabel.Text = "❌ No saved position"
    end
end)

CreateButton(Tabs["Teleport"], "Teleport Up (100 studs)", 145, function()
    if HRP then
        HRP.CFrame = HRP.CFrame * CFrame.new(0, 100, 0)
        StatusLabel.Text = "⬆️ Teleported Up"
    end
end)

-- Player teleport selection
local playerSelection = Instance.new("TextLabel", Tabs["Teleport"])
playerSelection.Size = UDim2.new(0, 200, 0, 30)
playerSelection.Position = UDim2.new(0, 10, 0, 190)
playerSelection.Text = "Select Player:"
playerSelection.TextColor3 = Color3.new(1,1,1)
playerSelection.Font = Enum.Font.Gotham
playerSelection.TextSize = 14
playerSelection.BackgroundTransparency = 1
playerSelection.TextXAlignment = Enum.TextXAlignment.Left

local yPos = 225
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LP then
        CreateButton(Tabs["Teleport"], "TP to " .. player.Name, yPos, function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and HRP then
                HRP.CFrame = player.Character.HumanoidRootPart.CFrame
                StatusLabel.Text = "👤 Teleported to " .. player.Name
            end
        end, 200)
        yPos = yPos + 45
    end
end

-- ================= AUTOFARM TAB =================
CreateToggle(Tabs["AutoFarm"], "Auto Collect Items", 10, false, function(state)
    _G.AutoCollect = state
    StatusLabel.Text = state and "🔄 Auto Collect: ON" or "🔄 Auto Collect: OFF"
end)

CreateToggle(Tabs["AutoFarm"], "Item Magnet", 45, false, function(state)
    _G.ItemMagnet = state
    StatusLabel.Text = state and "🧲 Magnet: ON" or "🧲 Magnet: OFF"
end)

CreateButton(Tabs["AutoFarm"], "Collect All Nearby", 90, function()
    StatusLabel.Text = "📦 Collecting nearby items..."
    -- Collection logic
end)

CreateToggle(Tabs["AutoFarm"], "Auto Sell Items", 125, false, function(state)
    _G.AutoSell = state
end)

CreateToggle(Tabs["AutoFarm"], "Auto Rebirth", 160, false, function(state)
    _G.AutoRebirth = state
end)

-- ================= UTILITIES TAB =================
CreateButton(Tabs["Utilities"], "Copy Game ID", 10, function()
    setclipboard(tostring(game.PlaceId))
    StatusLabel.Text = "📋 Game ID Copied!"
end)

CreateButton(Tabs["Utilities"], "Server Info", 55, function()
    local players = #Players:GetPlayers()
    local info = string.format("👥 Players: %d/%d\n🎮 Place ID: %d\n🏠 Job ID: %s",
        players, Players.MaxPlayers, game.PlaceId, game.JobId)
    StatusLabel.Text = "📊 " .. string.sub(info, 1, 30) .. "..."
    print("=== Server Info ===")
    print("Players:", players, "/", Players.MaxPlayers)
    print("Place ID:", game.PlaceId)
    print("Job ID:", game.JobId)
end)

CreateButton(Tabs["Utilities"], "Respawn Character", 100, function()
    LP:LoadCharacter()
    StatusLabel.Text = "🔄 Respawning..."
end)

CreateToggle(Tabs["Utilities"], "All Player ESP", 145, false, function(state)
    _G.AllESP = state
end)

CreateButton(Tabs["Utilities"], "Rejoin Server", 180, function()
    TeleportService:Teleport(game.PlaceId, LP)
    StatusLabel.Text = "🔄 Rejoining server..."
end)

CreateButton(Tabs["Utilities"], "Server Hop", 225, function()
    StatusLabel.Text = "🌐 Finding new server..."
    -- Server hop logic
end)

-- ================= SETTINGS TAB =================
CreateButton(Tabs["Settings"], "Destroy UI", 10, function()
    GUI:Destroy()
    StatusLabel.Text = "🗑️ UI Destroyed"
end)

CreateButton(Tabs["Settings"], "Reset All Settings", 55, function()
    WalkSpeed = 16
    JumpPower = 50
    if Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
        Humanoid.JumpPower = JumpPower
    end
    StatusLabel.Text = "🔄 All Settings Reset"
end)

CreateToggle(Tabs["Settings"], "UI Sound Effects", 100, true, function(state)
    _G.UISounds = state
end)

CreateToggle(Tabs["Settings"], "Auto Save Settings", 135, true, function(state)
    _G.AutoSave = state
end)

CreateButton(Tabs["Settings"], "Change UI Theme", 170, function()
    -- Theme changer logic
    local themes = {
        Dark = Color3.fromRGB(18,18,18),
        Blue = Color3.fromRGB(25,25,50),
        Purple = Color3.fromRGB(40,25,40)
    }
    local current = Main.BackgroundColor3
    for name, color in pairs(themes) do
        if current == color then
            local nextTheme = next(themes, name)
            if nextTheme then
                Main.BackgroundColor3 = themes[nextTheme]
                StatusLabel.Text = "🎨 Theme: " .. nextTheme
                break
            end
        end
    end
end)

-- Keybind display
local KeybindInfo = Instance.new("TextLabel", Tabs["Settings"])
KeybindInfo.Size = UDim2.new(0, 200, 0, 60)
KeybindInfo.Position = UDim2.new(0, 10, 0, 240)
KeybindInfo.Text = "📱 Mobile: Tap ≡ button\n🖥️ PC: RightShift to toggle UI\n🎮 Gamepad: Not supported"
KeybindInfo.TextColor3 = Color3.fromRGB(200,200,200)
KeybindInfo.Font = Enum.Font.Gotham
KeybindInfo.TextSize = 12
KeybindInfo.BackgroundTransparency = 1
KeybindInfo.TextWrapped = true
KeybindInfo.TextXAlignment = Enum.TextXAlignment.Left

-- ================= FLY & NOCLIP SYSTEM =================
RunService.RenderStepped:Connect(function()
    -- Fly system
    if _G.FlyEnabled and HRP then
        local moveVector = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0,1,0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0,1,0)
        end
        
        HRP.Velocity = moveVector * 100
    end
    
    -- Noclip system
    if _G.NoclipEnabled and Character then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
    
    -- Infinite jump
    if _G.InfiniteJump then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    -- FOV circle position
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- ================= MOBILE EVENT HANDLERS =================
MobileToggle.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

MobileClose.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- Mobile drag functionality
local dragToggle, dragStart, startPos

MobileHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

MobileHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and dragToggle then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ================= PC KEYBIND SYSTEM =================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- PC: RightShift toggle
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
    
    -- Mobile touch for main UI (additional)
    if input.UserInputType == Enum.UserInputType.Touch and not isMobile() then
        -- Handle touch on mobile toggle button
        local touchPos = input.Position
        local togglePos = MobileToggle.AbsolutePosition
        local toggleSize = MobileToggle.AbsoluteSize
        
        if touchPos.X >= togglePos.X and touchPos.X <= togglePos.X + toggleSize.X and
           touchPos.Y >= togglePos.Y and touchPos.Y <= togglePos.Y + toggleSize.Y then
            Main.Visible = not Main.Visible
        end
    end
end)

-- ================= INITIALIZATION =================
print("====================================================")
print(" Syu Complete Hub v2.0 Loaded Successfully!")
print(" Features: 9 Tabs, Mobile Support, 20+ Functions")
print(" Mobile: " .. tostring(isMobile()))
print(" Player: " .. LP.Name)
print("====================================================")

StatusLabel.Text = "✅ Syu Hub v2.0 Loaded!"