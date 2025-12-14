--[[
 Syu Hub Lite (Emergency Version)
 UIが絶対に出るように設計された軽量版
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- 1. 古いUIがあれば消す（多重起動防止）
pcall(function()
    if LP.PlayerGui:FindFirstChild("SyuLite") then
        LP.PlayerGui.SyuLite:Destroy()
    end
end)

-- 2. UI作成 (CoreGuiではなくPlayerGuiに入れる＝一番安定する)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SyuLite"
ScreenGui.Parent = LP:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- 3. 開閉ボタン（画面右側・指で押しやすい位置）
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Position = UDim2.new(1, -80, 0.4, 0) -- 画面右端
ToggleBtn.Text = "開く"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

-- 4. メイン画面
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 200, 0, 150)
Main.Position = UDim2.new(0.5, -100, 0.5, -75) -- 画面ど真ん中
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Visible = false -- 最初は隠しておく
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- タイトル
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "Syu Lite (強制移動)"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

-- 5. 機能: 強制移動 (CFrame Walk)
local Speed = 1
local Enabled = false

-- ON/OFFボタン
local WalkBtn = Instance.new("TextButton", Main)
WalkBtn.Size = UDim2.new(0.8, 0, 0, 40)
WalkBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
WalkBtn.Text = "強制移動: OFF"
WalkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
WalkBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", WalkBtn)

WalkBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    WalkBtn.Text = "強制移動: " .. (Enabled and "ON" or "OFF")
    WalkBtn.BackgroundColor3 = Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
end)

-- 速度変更ボタン
local SpeedBtn = Instance.new("TextButton", Main)
SpeedBtn.Size = UDim2.new(0.8, 0, 0, 30)
SpeedBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
SpeedBtn.Text = "速度変更 (現在: 1)"
SpeedBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SpeedBtn)

SpeedBtn.MouseButton1Click:Connect(function()
    Speed = Speed + 0.5
    if Speed > 3 then Speed = 1 end -- 3を超えたら1に戻る
    SpeedBtn.Text = "速度変更 (現在: " .. Speed .. ")"
end)

-- 6. 開閉処理
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    ToggleBtn.Text = Main.Visible and "閉じる" or "開く"
end)

-- 7. 移動ロジック (ループ処理)
RunService.Heartbeat:Connect(function()
    if not Enabled then return end
    
    local char = LP.Character
    if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        local hum = char.Humanoid
        local hrp = char.HumanoidRootPart
        
        -- スマホのスティック入力を検知
        if hum.MoveDirection.Magnitude > 0 then
            -- 物理演算を無視して座標を書き換える
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * Speed)
            hrp.Velocity = Vector3.new(0,0,0) -- 滑り防止
        end
    end
end)

-- 読み込み完了通知
local Notify = Instance.new("Message", workspace)
Notify.Text = "Syu Lite Loaded! Look at the right side."
task.wait(2)
Notify:Destroy()
