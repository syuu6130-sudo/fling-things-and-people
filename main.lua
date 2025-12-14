--[[
====================================================
 SYU HUB - FIXED VERSION (Mobile Force Display)
====================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // UIの作成と親の設定（修正ポイント）
local SyuGui = Instance.new("ScreenGui")
SyuGui.Name = "SyuUltimateHub_Fixed"
SyuGui.ResetOnSpawn = false
SyuGui.DisplayOrder = 9999 -- 他のUIより最前面に表示
SyuGui.IgnoreGuiInset = true -- ノッチや上のバーを無視

-- 強制的にPlayerGuiに入れる（CoreGuiだとスマホで映らないことがあるため）
local function ParentUI()
    local target = LP:FindFirstChild("PlayerGui")
    if target then
        SyuGui.Parent = target
    else
        -- まだ読み込まれていない場合は待つ
        SyuGui.Parent = LP:WaitForChild("PlayerGui")
    end
end
ParentUI()

-- ================= 設定値 =================
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    Noclip = false,
    ESP = false
}

-- ================= ドラッグ機能関数 =================
local function MakeDraggable(uiObject)
    local dragging, dragInput, dragStart, startPos

    uiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = uiObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    uiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            uiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ================= メインボタン (常時表示) =================
local ToggleBtn = Instance.new("TextButton", SyuGui)
ToggleBtn.Name = "SyuToggle"
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
-- 位置を少し中央寄りに変更（画面外に行かないように）
ToggleBtn.Position = UDim2.new(0.15, 0, 0.25, 0) 
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Color3.white
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ToggleBtn).Color = Color3.white
Instance.new("UIStroke", ToggleBtn).Thickness = 2
MakeDraggable(ToggleBtn)

-- ================= メインフレーム =================
local MainFrame = Instance.new("Frame", SyuGui)
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false -- ボタンで開く
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
MakeDraggable(MainFrame)

-- ボタンの機能
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- タイトル
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Syu Hub | 修正版"
Title.TextColor3 = Color3.white
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- 閉じるボタン
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 20
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- ================= 機能リスト (スクロール) =================
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ボタン作成関数
local function CreateBtn(text, func)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(func)
end

-- ================= 機能追加 =================

CreateBtn("スピード +5 (Speed Up)", function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = LP.Character.Humanoid.WalkSpeed + 5
    end
end)

CreateBtn("ジャンプ力 +10 (Jump Up)", function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.UseJumpPower = true
        LP.Character.Humanoid.JumpPower = LP.Character.Humanoid.JumpPower + 10
    end
end)

CreateBtn("飛行モード切替 (Toggle Fly)", function()
    Settings.Fly = not Settings.Fly
    if Settings.Fly then
        local bv = Instance.new("BodyVelocity", LP.Character.HumanoidRootPart)
        bv.Name = "SyuFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        spawn(function()
            while Settings.Fly and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") do
                local cam = Workspace.CurrentCamera.CFrame
                bv.Velocity = cam.LookVector * 50
                RunService.Heartbeat:Wait()
            end
            if LP.Character.HumanoidRootPart:FindFirstChild("SyuFly") then
                LP.Character.HumanoidRootPart.SyuFly:Destroy()
            end
        end)
    else
        if LP.Character.HumanoidRootPart:FindFirstChild("SyuFly") then
            LP.Character.HumanoidRootPart.SyuFly:Destroy()
        end
    end
end)

CreateBtn("壁抜け切替 (Toggle Noclip)", function()
    Settings.Noclip = not Settings.Noclip
end)

CreateBtn("ESP (透視) ON/OFF", function()
    Settings.ESP = not Settings.ESP
    if not Settings.ESP then
        -- OFF処理
        for _, v in pairs(CoreGui:GetChildren()) do
            if v.Name == "SyuHighlight" then v:Destroy() end
        end
    end
end)

CreateBtn("UIを削除 (Destroy UI)", function()
    SyuGui:Destroy()
end)

-- ループ処理
RunService.Stepped:Connect(function()
    -- Noclip
    if Settings.Noclip and LP.Character then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    
    -- ESP
    if Settings.ESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character and not plr.Character:FindFirstChild("SyuHighlight") then
                local hl = Instance.new("Highlight", CoreGui) -- ESPだけCoreGuiに入れてみる（描画優先のため）
                hl.Name = "SyuHighlight"
                hl.Adornee = plr.Character
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.white
            end
        end
    end
end)

-- 起動通知
print("Syu Hub Fixed Loaded!")
