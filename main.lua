import os

# The optimized Lua script content (The Force Move/CFrame version that actually works on mobile/physics games)
lua_content = r'''--[[
====================================================
 Syu Ultimate Complete Hub (Mobile/Physics Fix)
 Ver: 3.0 Force Move Edition
====================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= UI RESET & SETUP =================
if CoreGui:FindFirstChild("Syu_Complete_Hub") then
    CoreGui.Syu_Complete_Hub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Syu_Complete_Hub"
ScreenGui.ResetOnSpawn = false

-- Executor Safety Check
if pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LP:WaitForChild("PlayerGui")
end

-- ================= MAIN UI FRAME =================
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 500, 0, 320) -- Compact for Mobile
Main.Position = UDim2.new(0.5, -250, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = true

-- Mobile Draggable Logic
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Title Bar
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Syu Hub | 完全版 (強制移動)"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.XAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Text = "-"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Mobile Toggle Button (Right Side)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(1, -60, 0.4, 0)
ToggleBtn.Text = "Syu"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ================= TAB SYSTEM =================
local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(0, 110, 1, -50)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.BackgroundTransparency = 1

local ContentContainer = Instance.new("Frame", Main)
ContentContainer.Size = UDim2.new(1, -135, 1, -50)
ContentContainer.Position = UDim2.new(0, 125, 0, 45)
ContentContainer.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, (#Tabs * 38))
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local page = Instance.new("ScrollingFrame", ContentContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Page.Visible = false end
        page.Visible = true
    end)
    
    table.insert(Tabs, {Btn = btn, Page = page})
    return page
end

local TabMain = CreateTab("メイン")
local TabMove = CreateTab("移動 (強)")
local TabVis = CreateTab("表示")
local TabSet = CreateTab("設定")

Tabs[1].Page.Visible = true

-- ================= WIDGET HELPER =================
local function CreateBtn(parent, text, order, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Position = UDim2.new(0, 5, 0, (order-1)*40)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function CreateToggleBtn(parent, text, order, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Position = UDim2.new(0, 5, 0, (order-1)*40)
    b.Text = text .. ": OFF"
    b.Font = Enum.Font.Gotham
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    
    local on = false
    b.MouseButton1Click:Connect(function()
        on = not on
        b.Text = text .. ": " .. (on and "ON" or "OFF")
        b.BackgroundColor3 = on and Color3.fromRGB(0, 160, 60) or Color3.fromRGB(50, 50, 50)
        callback(on)
    end)
    return b
end

-- ================= FEATURES =================

-- [Main Tab]
CreateBtn(TabMain, "UI完全削除", 1, function() ScreenGui:Destroy() end)
CreateBtn(TabMain, "キャラクターリセット", 2, function() 
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.Health = 0
    end
end)

-- [Movement Tab] - The Core Logic
local CFrameWalk = false
local WalkSpeed = 1.0
local Noclip = false

CreateToggleBtn(TabMove, "強制移動 (物理無視)", 1, function(state)
    CFrameWalk = state
end)

CreateBtn(TabMove, "速度UP (+0.5)", 2, function()
    WalkSpeed = WalkSpeed + 0.5
end)
CreateBtn(TabMove, "速度DOWN (-0.5)", 3, function()
    if WalkSpeed > 0.5 then WalkSpeed = WalkSpeed - 0.5 end
end)

CreateToggleBtn(TabMove, "壁抜け (Noclip)", 4, function(state)
    Noclip = state
end)

-- Main Loop for Movement
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    -- CFrame Walk Logic
    if CFrameWalk and hrp and hum then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (moveDir * WalkSpeed)
            hrp.Velocity = Vector3.new(0,0,0) -- Cancel physics
        end
    end
    
    -- Noclip Logic
    if Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- [Visual Tab]
local ESP_Enabled = false
local ESP_Folder = Instance.new("Folder", ScreenGui)

local function UpdateESP()
    ESP_Folder:ClearAllChildren()
    if not ESP_Enabled then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hl = Instance.new("Highlight")
            hl.Adornee = plr.Character
            hl.Parent = ESP_Folder
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
        end
    end
end

CreateToggleBtn(TabVis, "プレイヤーESP", 1, function(state)
    ESP_Enabled = state
    UpdateESP()
end)

task.spawn(function()
    while task.wait(2) do
        if ESP_Enabled then UpdateESP() end
    end
end)

-- [Settings Tab]
local Info = Instance.new("TextLabel", TabSet)
Info.Size = UDim2.new(1, -10, 0, 100)
Info.BackgroundTransparency = 1
Info.Text = "Syu Hub\nForce Move Edition\n\n物理演算ゲーム専用\nMobile & PC Supported"
Info.TextColor3 = Color3.new(1,1,1)
Info.Font = Enum.Font.Gotham

print("Syu Hub Loaded")
'''

# Save to file
path = "/mnt/data/Syu_Complete_Hub_Force_Fixed.lua"
with open(path, "w", encoding="utf-8") as f:
    f.write(lua_content)

path
