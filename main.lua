--[[
====================================================
 Syu Ultimate Complete Hub (Fix Ver)
 修正版: モバイル完全対応・強制適用モード搭載
====================================================
]]

-- サービス
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer

-- UIの重複削除
if CoreGui:FindFirstChild("Syu_CompleteHub") then
    CoreGui.Syu_CompleteHub:Destroy()
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "Syu_CompleteHub"
GUI.ResetOnSpawn = false

-- Executorごとの親設定（エラー回避）
pcall(function()
    GUI.Parent = CoreGui
end)
if not GUI.Parent then
    GUI.Parent = LP:WaitForChild("PlayerGui")
end

-- ================= UIデザイン =================
local Main = Instance.new("Frame", GUI)
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 500, 0, 350) -- 少しコンパクトに
Main.Position = UDim2.new(0.5, -250, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- ドラッグ機能（モバイル対応）
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

-- タイトルバー
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Syu Hub | 修正版 v2.1"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.XAlignment = Enum.TextXAlignment.Left

-- 最小化ボタン
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Text = "-"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- 開閉ボタン（画面右側）
local ToggleBtn = Instance.new("TextButton", GUI)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(1, -60, 0.4, 0)
ToggleBtn.Text = "Open"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ================= タブ機能 =================
local TabButtons = Instance.new("ScrollingFrame", Main)
TabButtons.Size = UDim2.new(0, 120, 1, -50)
TabButtons.Position = UDim2.new(0, 10, 0, 45)
TabButtons.BackgroundTransparency = 1
TabButtons.ScrollBarThickness = 2

local ContentArea = Instance.new("Frame", Main)
ContentArea.Size = UDim2.new(1, -145, 1, -50)
ContentArea.Position = UDim2.new(0, 140, 0, 45)
ContentArea.BackgroundTransparency = 1

local Tabs = {}
local CurrentTab = nil

local function CreateTab(name)
    -- タブボタン
    local btn = Instance.new("TextButton", TabButtons)
    btn.Size = UDim2.new(1, -5, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, (#Tabs * 40))
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    -- 中身のページ
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 4
    
    Tabs[#Tabs + 1] = {Button = btn, Page = page}
    
    btn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do tab.Page.Visible = false end
        page.Visible = true
    end)
    
    return page
end

local MainTab = CreateTab("メイン")
local PlayerTab = CreateTab("プレイヤー")
local VisualTab = CreateTab("表示 (ESP)")
local SettingsTab = CreateTab("設定")

Tabs[1].Page.Visible = true -- 最初のタブを表示

-- ================= 機能実装 =================

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    local layoutOrder = #parent:GetChildren()
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, layoutOrder * 40)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        -- エラーで止まらないようにpcallで囲む
        local success, err = pcall(callback)
        if not success then
            btn.Text = "エラー!"
            task.wait(1)
            btn.Text = text
            warn("Button Error: " .. err)
        end
    end)
    return btn
end

-- --- プレイヤー機能 ---
local SpeedEnabled = false
local SpeedVal = 25
local JumpEnabled = false
local JumpVal = 80
local FlyEnabled = false
local NoclipEnabled = false

-- スピード
AddButton(PlayerTab, "速度UP (Loop): OFF", function()
    SpeedEnabled = not SpeedEnabled
end).Name = "SpeedBtn"

-- ジャンプ
AddButton(PlayerTab, "ジャンプ力UP: OFF", function()
    JumpEnabled = not JumpEnabled
end).Name = "JumpBtn"

-- フライ
AddButton(PlayerTab, "飛行 (Fly): OFF", function()
    FlyEnabled = not FlyEnabled
end).Name = "FlyBtn"

-- 壁抜け
AddButton(PlayerTab, "壁抜け (Noclip): OFF", function()
    NoclipEnabled = not NoclipEnabled
end).Name = "NoclipBtn"

-- ループ処理（最強の適用方法）
RunService.RenderStepped:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    -- ボタンの表示更新
    if PlayerTab:FindFirstChild("SpeedBtn") then
        PlayerTab.SpeedBtn.Text = "速度UP (Loop): " .. (SpeedEnabled and "ON" or "OFF")
    end
    if PlayerTab:FindFirstChild("JumpBtn") then
        PlayerTab.JumpBtn.Text = "ジャンプ力UP: " .. (JumpEnabled and "ON" or "OFF")
    end
    if PlayerTab:FindFirstChild("FlyBtn") then
        PlayerTab.FlyBtn.Text = "飛行 (Fly): " .. (FlyEnabled and "ON" or "OFF")
    end
    if PlayerTab:FindFirstChild("NoclipBtn") then
        PlayerTab.NoclipBtn.Text = "壁抜け (Noclip): " .. (NoclipEnabled and "ON" or "OFF")
    end

    -- 機能実行
    if hum and hrp then
        if SpeedEnabled then
            hum.WalkSpeed = SpeedVal
        end
        
        if JumpEnabled then
            hum.JumpPower = JumpVal
        end

        if FlyEnabled then
            -- 落下を防ぐ
            local bv = hrp:FindFirstChild("SyuFly")
            if not bv then
                bv = Instance.new("BodyVelocity", hrp)
                bv.Name = "SyuFly"
                bv.MaxForce = Vector3.new(100000, 100000, 100000)
            end
            bv.Velocity = Camera.CFrame.LookVector * 50
        else
            if hrp:FindFirstChild("SyuFly") then
                hrp.SyuFly:Destroy()
            end
        end

        if NoclipEnabled then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end
end)

-- --- メイン/フリング機能 ---
AddButton(MainTab, "リセット (再読み込み)", function()
    local char = LP.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = 0
    end
end)

AddButton(MainTab, "力強化 (Physics)", function()
    local char = LP.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
            end
        end
    end
end)

-- --- ESP機能 (軽量版) ---
local ESP_Holder = Instance.new("Folder", CoreGui)
local ESP_On = false

local function RefreshESP()
    ESP_Holder:ClearAllChildren()
    if not ESP_On then return end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local h = Instance.new("Highlight")
            h.Parent = ESP_Holder
            h.Adornee = v.Character
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.5
        end
    end
end

AddButton(VisualTab, "プレイヤーESP: OFF", function()
    ESP_On = not ESP_On
    RefreshESP()
end).Name = "EspBtn"

task.spawn(function()
    while task.wait(1) do
        if VisualTab:FindFirstChild("EspBtn") then
             VisualTab.EspBtn.Text = "プレイヤーESP: " .. (ESP_On and "ON" or "OFF")
        end
        if ESP_On then RefreshESP() end
    end
end)

-- --- 設定 ---
AddButton(SettingsTab, "UIを削除", function()
    GUI:Destroy()
    ESP_Holder:Destroy()
end)

print("Syu Hub Fixed Loaded")
