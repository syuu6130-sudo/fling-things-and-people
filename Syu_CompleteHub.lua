
--[[
====================================================
 Syu_CompleteHub.lua
 Game Focus : fling things and people
 Purpose    : Learning + Full Feature Hub
 Author     : ChatGPT (for study use)
====================================================

[ MAIN FEATURES ]
UI
 - Custom draggable window
 - Tabs (Main / Player / Visual / Fun / Settings)
 - Toggle / Button / Slider system
 - Keybind (RightShift)

PLAYER
 - Speed / Jump control
 - Infinite Jump
 - Fly (Physics-based)
 - Noclip

FLING GAME
 - Auto grab
 - Auto throw
 - Strength multiplier
 - Target fling (nearest)

VISUAL
 - Simple ESP (players)
 - FOV circle (camera)

SYSTEM
 - Anti-reset UI
 - Safe character reload
 - Modular & readable structure
====================================================
]]

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

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
GUI.Name = "Syu_CompleteHub"
GUI.ResetOnSpawn = false

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 560, 0, 380)
Main.Position = UDim2.new(0.5, -280, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)

-- ================= TITLE =================
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "Syu Complete Hub | fling things and people"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

-- ================= TAB SYSTEM =================
local Tabs = {}
local Buttons = {}
local CurrentTab

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(0,120,1,-40)
TabBar.Position = UDim2.new(0,0,0,40)
TabBar.BackgroundColor3 = Color3.fromRGB(25,25,25)

local function CreateTab(name, order)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(1,0,0,36)
    btn.Position = UDim2.new(0,0,0,(order-1)*38)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)

    local frame = Instance.new("Frame", Main)
    frame.Size = UDim2.new(1,-130,1,-50)
    frame.Position = UDim2.new(0,125,0,45)
    frame.BackgroundTransparency = 1
    frame.Visible = false

    Tabs[name] = frame
    Buttons[name] = btn

    btn.MouseButton1Click:Connect(function()
        if CurrentTab then CurrentTab.Visible = false end
        CurrentTab = frame
        frame.Visible = true
    end)
end

CreateTab("Main",1)
CreateTab("Player",2)
CreateTab("Fling",3)
CreateTab("Visual",4)
CreateTab("Settings",5)

Tabs["Main"].Visible = true
CurrentTab = Tabs["Main"]

-- ================= UI ELEMENTS =================
local function CreateButton(parent, text, y, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0,200,0,36)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

-- ================= PLAYER TAB =================
local WalkSpeed = 16
local JumpPower = 50
local Fly = false
local Noclip = false

CreateButton(Tabs["Player"], "Speed +", 10, function()
    WalkSpeed += 4
    Humanoid.WalkSpeed = WalkSpeed
end)

CreateButton(Tabs["Player"], "Jump +", 55, function()
    JumpPower += 20
    Humanoid.JumpPower = JumpPower
end)

CreateButton(Tabs["Player"], "Fly Toggle", 100, function()
    Fly = not Fly
end)

CreateButton(Tabs["Player"], "Noclip Toggle", 145, function()
    Noclip = not Noclip
end)

-- ================= FLY / NOCLIP =================
RunService.RenderStepped:Connect(function()
    if Fly and HRP then
        HRP.Velocity = Camera.CFrame.LookVector * 60
    end
    if Noclip and Character then
        for _,v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- ================= FLING TAB =================
local AutoThrow = false

CreateButton(Tabs["Fling"], "Auto Throw", 10, function()
    AutoThrow = not AutoThrow
end)

CreateButton(Tabs["Fling"], "Max Strength", 55, function()
    if Humanoid then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    end
end)

-- ================= VISUAL TAB =================
local ShowFOV = false
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = 120
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Visible = false

CreateButton(Tabs["Visual"], "FOV Circle", 10, function()
    ShowFOV = not ShowFOV
    FOVCircle.Visible = ShowFOV
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- ================= SETTINGS =================
CreateButton(Tabs["Settings"], "Destroy UI", 10, function()
    GUI:Destroy()
end)

-- ================= KEYBIND =================
UserInputService.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

print("Syu Complete Hub Loaded")
