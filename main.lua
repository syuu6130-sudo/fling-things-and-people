--[[
====================================================
 Syu Ultimate Complete Hub (JAPANESE FULL VER)
 Game Focus : Fling Things and People
 Author     : Modified by AI (Based on Syu)
 Ver        : 2.0 (Mobile & JP Support)
====================================================
]]

-- ================= サービス =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ================= キャラクター管理 =================
local Character, Humanoid, HRP

local function LoadChar()
    Character = LP.Character or LP.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    HRP = Character:WaitForChild("HumanoidRootPart")
end
LoadChar()
LP.CharacterAdded:Connect(LoadChar)

-- ================= UI ベース作成 =================
-- 多重起動防止
if CoreGui:FindFirstChild("Syu_CompleteHub") then
    CoreGui.Syu_CompleteHub:Destroy()
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "Syu_CompleteHub"
GUI.ResetOnSpawn = false
-- セキュリティの低いExecutor対策（PlayerGuiに入れる）
if pcall(function() GUI.Parent = CoreGui end) then
    GUI.Parent = CoreGui
else
    GUI.Parent = LP:WaitForChild("PlayerGui")
end

-- メインフレーム
local Main = Instance.new("Frame", GUI)
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 560, 0, 380)
Main.Position = UDim2.new(0.5, -280, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.Active = true
Main.Visible = true

-- モバイル向けドラッグ機能 (Draggableプロパティは非推奨のためカスタム実装)
local dragging, dragInput, dragStart, startPos
local function Update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
        Update(input)
    end
end)

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)

-- ================= タイトルバー =================
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,-40,0,40) -- ボタン分スペースを空ける
Title.Position = UDim2.new(0,15,0,0)
Title.Text = "Syu Hub | 完全版"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1
Title.XAlignment = Enum.TextXAlignment.Left

-- 最小化ボタン (UI内)
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0,40,0,40)
CloseBtn.Position = UDim2.new(1,-40,0,0)
CloseBtn.Text = "-"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.fromRGB(200,200,200)
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- ================= モバイル用トグルボタン =================
local ToggleFrame = Instance.new("Frame", GUI)
ToggleFrame.Size = UDim2.new(0, 50, 0, 50)
-- 画面右中央寄りに配置
ToggleFrame.Position = UDim2.new(1, -70, 0.4, 0) 
ToggleFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
ToggleFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0,10)

local ToggleBtn = Instance.new("TextButton", ToggleFrame)
ToggleBtn.Size = UDim2.new(1,0,1,0)
ToggleBtn.Text = "Syu"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- ================= タブシステム =================
local Tabs = {}
local CurrentTab

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(0,120,1,-40)
TabBar.Position = UDim2.new(0,0,0,40)
TabBar.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0,14)

local function CreateTab(name, displayName, order)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(1,-10,0,36)
    btn.Position = UDim2.new(0,5,0,(order-1)*40 + 5)
    btn.Text = displayName
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local frame = Instance.new("ScrollingFrame", Main) -- ScrollingFrameに変更して要素が多くても大丈夫に
    frame.Size = UDim2.new(1,-130,1,-50)
    frame.Position = UDim2.new(0,125,0,45)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.ScrollBarThickness = 4
    frame.BorderSizePixel = 0

    Tabs[name] = frame

    btn.MouseButton1Click:Connect(function()
        if CurrentTab then CurrentTab.Visible = false end
        CurrentTab = frame
        frame.Visible = true
    end)
end

CreateTab("Main", "メイン", 1)
CreateTab("Player", "プレイヤー", 2)
CreateTab("Fling", "フリング", 3)
CreateTab("Visual", "表示 (ESP)", 4)
CreateTab("Settings", "設定", 5)

Tabs["Main"].Visible = true
CurrentTab = Tabs["Main"]

-- ================= UI 要素作成関数 =================
local function CreateButton(parent, text, order, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0,380,0,36) -- 幅を調整
    b.Position = UDim2.new(0,10,0,(order-1)*42)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function CreateLabel(parent, text, order)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(0,380,0,20)
    l.Position = UDim2.new(0,10,0,(order-1)*42)
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextColor3 = Color3.fromRGB(255, 170, 0)
    l.BackgroundTransparency = 1
    l.XAlignment = Enum.TextXAlignment.Left
    return l
end

-- ================= メイン タブ =================
CreateLabel(Tabs["Main"], "Syu Hubへようこそ", 1)
CreateLabel(Tabs["Main"], "状態: 正常", 2)
CreateButton(Tabs["Main"], "Discordをコピー (未設定)", 3, function() 
    print("Discord link not set") 
end)

-- ================= プレイヤー タブ =================
local WalkSpeed = 16
local JumpPower = 50
local Fly = false
local Noclip = false
local InfJump = false

CreateLabel(Tabs["Player"], "移動ステータス", 1)

CreateButton(Tabs["Player"], "速度 +4 (現在: 16)", 2, function(self)
    WalkSpeed = WalkSpeed + 4
    if Humanoid then Humanoid.WalkSpeed = WalkSpeed end
end)

CreateButton(Tabs["Player"], "ジャンプ +20 (現在: 50)", 3, function(self)
    JumpPower = JumpPower + 20
    if Humanoid then Humanoid.JumpPower = JumpPower end
end)

CreateButton(Tabs["Player"], "ステータスをリセット", 4, function()
    WalkSpeed = 16
    JumpPower = 50
    if Humanoid then
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
    end
end)

CreateLabel(Tabs["Player"], "チート機能", 5)

local FlyBtn = CreateButton(Tabs["Player"], "飛行 (Fly): OFF", 6, function()
    Fly = not Fly
end)

local NoclipBtn = CreateButton(Tabs["Player"], "壁抜け (Noclip): OFF", 7, function()
    Noclip = not Noclip
end)

local InfJumpBtn = CreateButton(Tabs["Player"], "無限ジャンプ: OFF", 8, function()
    InfJump = not InfJump
end)

-- ループ処理 (ボタンのテキスト更新含む)
RunService.RenderStepped:Connect(function()
    if Tabs["Player"].Visible then
        FlyBtn.Text = "飛行 (Fly): " .. (Fly and "ON" or "OFF")
        NoclipBtn.Text = "壁抜け (Noclip): " .. (Noclip and "ON" or "OFF")
        InfJumpBtn.Text = "無限ジャンプ: " .. (InfJump and "ON" or "OFF")
    end

    if Fly and HRP then
        HRP.Velocity = Camera.CFrame.LookVector * 60
    end

    if Noclip and Character then
        for _,v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ================= フリング タブ =================
local AutoThrow = false
local AutoClick = false

CreateLabel(Tabs["Fling"], "物理演算", 1)

CreateButton(Tabs["Fling"], "最大筋力 (物理演算有効化)", 2, function()
    if Humanoid then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        -- Fling Things and People特有のラグドール解除などを試みる
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Massless = false
                v.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5) -- 重くする
            end
        end
    end
end)

CreateButton(Tabs["Fling"], "自動連打 (掴み用): OFF", 3, function(btn)
    AutoClick = not AutoClick
    btn.Text = "自動連打 (掴み用): " .. (AutoClick and "ON" or "OFF")
end)

-- オートクリックのロジック
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoClick then
            mouse1click() -- 多くのExecutorで動作する関数
        end
    end
end)

-- ================= 表示 (Visual) タブ =================
-- Mobile対応のため、Drawing APIではなくHighlightを使用
local ESP_Enabled = false
local ESP_Holder = Instance.new("Folder", CoreGui)
ESP_Holder.Name = "Syu_ESP_Holder"

local function UpdateESP()
    ESP_Holder:ClearAllChildren()
    if not ESP_Enabled then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = plr.Character
            highlight.Parent = ESP_Holder
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            
            -- 名前表示（BillboardGui）
            local bg = Instance.new("BillboardGui", ESP_Holder)
            bg.Adornee = plr.Character.Head
            bg.Size = UDim2.new(0,100,0,50)
            bg.StudsOffset = Vector3.new(0, 3, 0)
            bg.AlwaysOnTop = true
            
            local name = Instance.new("TextLabel", bg)
            name.Size = UDim2.new(1,0,1,0)
            name.BackgroundTransparency = 1
            name.Text = plr.Name
            name.TextColor3 = Color3.new(1,1,1)
            name.TextStrokeTransparency = 0
            name.Font = Enum.Font.GothamBold
            name.TextSize = 14
        end
    end
end

CreateButton(Tabs["Visual"], "プレイヤーESP (透視): OFF", 1, function(btn)
    ESP_Enabled = not ESP_Enabled
    btn.Text = "プレイヤーESP (透視): " .. (ESP_Enabled and "ON" or "OFF")
    if not ESP_Enabled then ESP_Holder:ClearAllChildren() end
end)

-- 定期的にESPを更新（プレイヤーの出入りに対応）
task.spawn(function()
    while true do
        task.wait(1)
        if ESP_Enabled then UpdateESP() end
    end
end)

-- FOV設定
local ShowFOV = false
local FOVCircle = nil
-- Drawing APIが使えるか確認
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Radius = 120
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255,255,255)
    FOVCircle.Visible = false
    
    CreateButton(Tabs["Visual"], "FOV円を表示: OFF", 2, function(btn)
        ShowFOV = not ShowFOV
        FOVCircle.Visible = ShowFOV
        btn.Text = "FOV円を表示: " .. (ShowFOV and "ON" or "OFF")
    end)
    
    RunService.RenderStepped:Connect(function()
        if ShowFOV and FOVCircle then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        end
    end)
else
    CreateLabel(Tabs["Visual"], "※お使いの環境ではFOV円は非対応です", 2)
end

-- ================= 設定 タブ =================
CreateButton(Tabs["Settings"], "UIを完全に削除", 1, function()
    GUI:Destroy()
    if FOVCircle then FOVCircle:Remove() end
    ESP_Holder:Destroy()
end)

CreateLabel(Tabs["Settings"], "キーバインド: 右Shift", 3)
CreateLabel(Tabs["Settings"], "または画面右のボタン", 4)

-- ================= キーバインド処理 =================
UserInputService.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

print("Syu Ultimate Complete Hub (JP/Mobile) Loaded")
