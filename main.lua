--[[
====================================================
 Syu Hub: FORCE MOVE EDITION
 対象: Fling Things and People (物理演算無視版)
====================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- UIリセット
if CoreGui:FindFirstChild("Syu_ForceHub") then
    CoreGui.Syu_ForceHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Syu_ForceHub"
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

-- メインフレーム
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 280) -- スマホ用に小さく
Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true -- PC用だが一部モバイルでも有効
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- タイトル
local Title = Instance.new("TextLabel", Main)
Title.Text = "Syu Hub: 強制移動版"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- 閉じるボタン
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -30, 0, 0)
Close.Text = "×"
Close.TextColor3 = Color3.new(1,0,0)
Close.BackgroundTransparency = 1
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- 開くボタン（最小化時）
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.9, -10, 0.4, 0)
OpenBtn.Text = "Open"
OpenBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    OpenBtn.Visible = true
end)
OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    OpenBtn.Visible = false
end)

-- ================= 機能ロジック =================

local Enabled = false
local Speed = 1 -- 初期速度
local Noclip = false

-- トグルボタン作成関数
local function CreateToggle(text, yPos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = text .. ": " .. (on and "ON" or "OFF")
        btn.BackgroundColor3 = on and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        callback(on)
    end)
end

-- スライダー的なボタン（速度用）
local SpeedLabel = Instance.new("TextLabel", Main)
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 40)
SpeedLabel.Text = "速度設定: " .. Speed
SpeedLabel.TextColor3 = Color3.new(1,1,1)
SpeedLabel.BackgroundTransparency = 1

local SpeedUp = Instance.new("TextButton", Main)
SpeedUp.Size = UDim2.new(0.4, 0, 0, 30)
SpeedUp.Position = UDim2.new(0.5, 5, 0, 65)
SpeedUp.Text = "上げる (+)"
SpeedUp.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", SpeedUp)

local SpeedDown = Instance.new("TextButton", Main)
SpeedDown.Size = UDim2.new(0.4, 0, 0, 30)
SpeedDown.Position = UDim2.new(0.1, -5, 0, 65)
SpeedDown.Text = "下げる (-)"
SpeedDown.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", SpeedDown)

SpeedUp.MouseButton1Click:Connect(function()
    Speed = Speed + 0.5
    SpeedLabel.Text = "速度設定: " .. Speed
end)

SpeedDown.MouseButton1Click:Connect(function()
    if Speed > 0.5 then Speed = Speed - 0.5 end
    SpeedLabel.Text = "速度設定: " .. Speed
end)

-- === 強制移動処理 (CFrame Walk) ===
-- Humanoidの速度変更ではなく、入力検知して座標ごとズラす
CreateToggle("強制移動 (CFrame)", 110, function(state)
    Enabled = state
end)

CreateToggle("壁抜け (Noclip)", 155, function(state)
    Noclip = state
end)

-- ループ処理
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    -- 強制移動ロジック
    if Enabled and hrp and hum then
        -- 入力方向（スマホのジョイスティックもMoveDirectionに反映される）
        local moveDir = hum.MoveDirection
        
        -- 入力がある時だけ移動させる
        if moveDir.Magnitude > 0 then
            -- 現在の位置 + (入力方向 * 速度)
            -- CFrame操作なので物理演算の影響を受けにくい
            hrp.CFrame = hrp.CFrame + (moveDir * Speed)
            
            -- ついでに本来の物理速度を殺して滑りを防止
            hrp.Velocity = Vector3.new(0,0,0) 
        end
    end
    
    -- 壁抜け処理
    if Noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- 診断ボタン（デバッグ用）
local DebugBtn = Instance.new("TextButton", Main)
DebugBtn.Size = UDim2.new(0.9, 0, 0, 30)
DebugBtn.Position = UDim2.new(0.05, 0, 0, 240)
DebugBtn.Text = "キャラ情報をコンソール出力"
DebugBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
Instance.new("UICorner", DebugBtn)

DebugBtn.MouseButton1Click:Connect(function()
    print("--- DEBUG START ---")
    if LP.Character then
        print("Character found: " .. LP.Character.Name)
        for _, v in pairs(LP.Character:GetChildren()) do
            print("Child: " .. v.Name .. " (" .. v.ClassName .. ")")
        end
    else
        print("Character is NIL")
    end
    print("--- DEBUG END ---")
    DebugBtn.Text = "出力完了（F9で確認）"
    task.wait(2)
    DebugBtn.Text = "キャラ情報をコンソール出力"
end)

print("Syu Hub Force Move Loaded")
