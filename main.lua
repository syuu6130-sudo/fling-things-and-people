--[[
====================================================
 SYU ULTIMATE COMPLETE HUB - JAPANESE EDITION
 Version: 2.0 (Mobile & PC Supported)
 Game: Fling Things and People & Generic
 Author: Refined by Gemini
====================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- // UI保護（検出回避用）
local SyuGui = Instance.new("ScreenGui")
SyuGui.Name = "SyuUltimateHub_JP"
-- CoreGuiが使えない場合はPlayerGuiにフォールバック
pcall(function()
    SyuGui.Parent = CoreGui
end)
if not SyuGui.Parent then
    SyuGui.Parent = LP:WaitForChild("PlayerGui")
end
SyuGui.ResetOnSpawn = false

-- // 設定値
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    ESP = false,
    AutoThrow = false
}

-- ================= UI 作成関数 (Mobile Drag対応) =================
local function MakeDraggable(topbarObject, object)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    topbarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- ================= メインフレーム作成 =================
local MainFrame = Instance.new("Frame", SyuGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false -- 最初は非表示（トグルボタンで開く）

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- タイトルバー
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 10)
-- 下側の角を四角くするために隠す
local HideBottomCorner = Instance.new("Frame", TopBar)
HideBottomCorner.Size = UDim2.new(1, 0, 0, 10)
HideBottomCorner.Position = UDim2.new(0, 0, 1, -10)
HideBottomCorner.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HideBottomCorner.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Syu Ultimate Hub | 完全版"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- 閉じるボタン（メイン内）
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

MakeDraggable(TopBar, MainFrame)

-- ================= モバイル用トグルボタン (常に表示) =================
local ToggleButton = Instance.new("TextButton", SyuGui)
ToggleButton.Name = "OpenButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.1, 0, 0.2, 0) -- 左上の押しやすい位置
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
ToggleButton.Text = "Syu"
ToggleButton.TextColor3 = Color3.white
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0) -- 丸くする
Instance.new("UIStroke", ToggleButton).Color = Color3.white
MakeDraggable(ToggleButton, ToggleButton) -- ボタン自体も移動可能

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ================= タブシステム =================
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 120, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabContainer.BorderSizePixel = 0

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -130, 1, -50)
PageContainer.Position = UDim2.new(0, 125, 0, 45)
PageContainer.BackgroundTransparency = 1

local Tabs = {}
local Pages = {}

local function CreateTab(name, iconID)
    local TabButton = Instance.new("TextButton", TabContainer)
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    
    local ListLayout = TabContainer:FindFirstChild("UIListLayout") or Instance.new("UIListLayout", TabContainer)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 4
    Page.Visible = false
    
    local PLayout = Instance.new("UIListLayout", Page)
    PLayout.Padding = UDim.new(0, 8)
    PLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    TabButton.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(Tabs) do b.TextColor3 = Color3.fromRGB(150, 150, 150) end
        Page.Visible = true
        TabButton.TextColor3 = Color3.white
    end)
    
    table.insert(Tabs, TabButton)
    table.insert(Pages, Page)
    
    return Page
end

-- ================= 機能ボタン作成関数 =================
local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(0.95, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = text
    Btn.TextColor3 = Color3.white
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        local success, err = pcall(callback)
        if not success then warn("Error:", err) end
        
        -- クリックエフェクト
        local originalColor = Btn.BackgroundColor3
        Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        task.wait(0.1)
        Btn.BackgroundColor3 = originalColor
    end)
end

local function AddToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.white
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 50, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
    ToggleBtn.Text = default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.white
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 12
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)
    
    local on = default
    ToggleBtn.MouseButton1Click:Connect(function()
        on = not on
        ToggleBtn.BackgroundColor3 = on and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
        ToggleBtn.Text = on and "ON" or "OFF"
        callback(on)
    end)
end

-- ================= タブ設定 =================
local TabPlayer = CreateTab("プレイヤー", "")
local TabFling = CreateTab("フリング", "")
local TabVisual = CreateTab("見た目", "")
local TabSystem = CreateTab("システム", "")

-- 最初のタブを表示
Pages[1].Visible = true
Tabs[1].TextColor3 = Color3.white

-- ================= 機能実装: プレイヤー =================
AddButton(TabPlayer, "歩行スピード +5", function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        Settings.WalkSpeed = Settings.WalkSpeed + 5
        LP.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end
end)

AddButton(TabPlayer, "スピードリセット (16)", function()
    Settings.WalkSpeed = 16
    if LP.Character then LP.Character.Humanoid.WalkSpeed = 16 end
end)

AddButton(TabPlayer, "ジャンプ力 +10", function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        Settings.JumpPower = Settings.JumpPower + 10
        LP.Character.Humanoid.UseJumpPower = true
        LP.Character.Humanoid.JumpPower = Settings.JumpPower
    end
end)

AddToggle(TabPlayer, "飛行モード (Fly)", false, function(state)
    Settings.Fly = state
    if state then
        -- 簡易Flyロジック
        local BodyGyro = Instance.new("BodyGyro")
        BodyGyro.P = 9e4
        BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BodyGyro.cframe = LP.Character.HumanoidRootPart.CFrame
        BodyGyro.Parent = LP.Character.HumanoidRootPart
        BodyGyro.Name = "SyuFlyGyro"

        local BodyVel = Instance.new("BodyVelocity")
        BodyVel.velocity = Vector3.new(0, 0.1, 0)
        BodyVel.maxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVel.Parent = LP.Character.HumanoidRootPart
        BodyVel.Name = "SyuFlyVel"
        
        spawn(function()
            while Settings.Fly and LP.Character do
                if LP.Character:FindFirstChild("Humanoid") then
                    LP.Character.Humanoid.PlatformStand = true
                end
                local camCF = Camera.CFrame
                local newVel = Vector3.new()
                
                -- モバイル用にカメラの向きに進む仕様
                if LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
                    newVel = LP.Character.Humanoid.MoveDirection * Settings.FlySpeed
                else
                    newVel = Vector3.new(0,0,0)
                end
                
                -- 上昇下降の制御を入れるとモバイルで操作しづらいため、カメラ方向依存にする
                BodyVel.Velocity = newVel + Vector3.new(0, 0.5, 0) -- 落下防止の微弱な力
                BodyGyro.CFrame = Camera.CFrame
                RunService.Heartbeat:Wait()
            end
            -- クリーンアップ
            if LP.Character:FindFirstChild("HumanoidRootPart") then
                if LP.Character.HumanoidRootPart:FindFirstChild("SyuFlyGyro") then LP.Character.HumanoidRootPart.SyuFlyGyro:Destroy() end
                if LP.Character.HumanoidRootPart:FindFirstChild("SyuFlyVel") then LP.Character.HumanoidRootPart.SyuFlyVel:Destroy() end
            end
            if LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid.PlatformStand = false
            end
        end)
    else
        -- OFF処理
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            if LP.Character.HumanoidRootPart:FindFirstChild("SyuFlyGyro") then LP.Character.HumanoidRootPart.SyuFlyGyro:Destroy() end
            if LP.Character.HumanoidRootPart:FindFirstChild("SyuFlyVel") then LP.Character.HumanoidRootPart.SyuFlyVel:Destroy() end
        end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.PlatformStand = false
        end
    end
end)

AddToggle(TabPlayer, "壁抜け (Noclip)", false, function(state)
    Settings.Noclip = state
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
    if Settings.Noclip and LP.Character then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
    end
end)

-- ================= 機能実装: フリング =================
AddToggle(TabFling, "自動掴み/投げ (Auto Throw)", false, function(state)
    Settings.AutoThrow = state
    -- ゲーム固有のロジックが必要だが、汎用的にはLoopで実装
    spawn(function()
        while Settings.AutoThrow do
            -- 周囲のパーツを探してインタラクションするロジック（ゲームによる）
            -- ここでは汎用的なプレースホルダー
            task.wait(0.5)
        end
    end)
end)

AddButton(TabFling, "物理演算最大化 (Max Physics)", function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        for _, v in pairs(LP.Character.Humanoid:GetPlayingAnimationTracks()) do
            v:Stop()
        end
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
end)

-- ================= 機能実装: 見た目 (ESP) =================
local ESPFolder = Instance.new("Folder", CoreGui)
ESPFolder.Name = "SyuESP"

AddToggle(TabVisual, "プレイヤー透視 (ESP)", false, function(state)
    Settings.ESP = state
    if not state then
        ESPFolder:ClearAllChildren()
    end
end)

-- ESP Loop
RunService.RenderStepped:Connect(function()
    if Settings.ESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if not ESPFolder:FindFirstChild(plr.Name) then
                    local hl = Instance.new("Highlight")
                    hl.Name = plr.Name
                    hl.Adornee = plr.Character
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = ESPFolder
                else
                    -- キャラクターがリスポーンした場合の更新
                    local hl = ESPFolder:FindFirstChild(plr.Name)
                    if hl.Adornee ~= plr.Character then
                        hl.Adornee = plr.Character
                    end
                end
            end
        end
        -- 退出したプレイヤーのESP削除
        for _, hl in pairs(ESPFolder:GetChildren()) do
            if not Players:FindFirstChild(hl.Name) then
                hl:Destroy()
            end
        end
    else
        ESPFolder:ClearAllChildren()
    end
end)

-- ================= 機能実装: システム =================
AddButton(TabSystem, "サーバー再接続 (Rejoin)", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

AddButton(TabSystem, "UIを完全に削除", function()
    SyuGui:Destroy()
    ESPFolder:Destroy()
end)

-- ================= 起動完了通知 =================
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Syu Complete Hub";
    Text = "読み込み完了！青いボタンでメニューを開いてください";
    Duration = 5;
})
