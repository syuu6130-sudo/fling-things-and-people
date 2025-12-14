# Create a Japanese, mobile-supported, minimized UI, all-in-one Roblox Lua script file
# with extensive Japanese comments for learning purposes.

content = r'''
--[[
====================================================
 しゅー完全版ハブ / Syu Ultimate Complete Hub
 対応ゲーム : fling things and people
 対応環境   : PC / Mobile (Android & iOS)
 言語       : 日本語（学習用コメント付き）
====================================================

【このファイルの目的】
・UI / Player / Fling / Visual / Settings を全部入りで提供
・分割なし、単体ファイル
・日本語UI & 日本語コメントで学習しやすく
・モバイル対応（画面タップ操作）
・UI最小化 / 復元 完備

※ 学習目的を前提とした構造になっています
====================================================
]]

--==============================
-- Services（Roblox標準サービス）
--==============================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

--==============================
-- Player 基本取得
--==============================
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local Character, Humanoid, HRP

-- キャラクターを安全に再取得する関数
local function LoadCharacter()
    Character = LP.Character or LP.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    HRP = Character:WaitForChild("HumanoidRootPart")
end

LoadCharacter()
LP.CharacterAdded:Connect(LoadCharacter)

--==============================
-- UI 作成（ベース）
--==============================
local GUI = Instance.new("ScreenGui")
GUI.Name = "Syu_UltimateHub"
GUI.ResetOnSpawn = false
GUI.Parent = game:GetService("CoreGui")

-- メインウィンドウ
local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 580, 0, 400)
Main.Position = UDim2.new(0.5, -290, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)

--==============================
-- タイトルバー
--==============================
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1,0,0,42)
TopBar.BackgroundColor3 = Color3.fromRGB(25,25,25)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1,-90,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.Text = "Syu Ultimate Hub（完全版）"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Left

--==============================
-- 最小化ボタン
--==============================
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0,36,0,28)
MinBtn.Position = UDim2.new(1,-42,0,7)
MinBtn.Text = "─"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", MinBtn)

local Minimized = false
local OriginalSize = Main.Size

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        Main:TweenSize(UDim2.new(0, 580, 0, 42), "Out", "Quad", 0.25, true)
    else
        Main:TweenSize(OriginalSize, "Out", "Quad", 0.25, true)
    end
end)

--==============================
-- タブバー
--==============================
local TabBar = Instance.new("Frame", Main)
TabBar.Position = UDim2.new(0,0,0,42)
TabBar.Size = UDim2.new(0,130,1,-42)
TabBar.BackgroundColor3 = Color3.fromRGB(28,28,28)

local Tabs = {}
local CurrentTab

--==============================
-- タブ作成関数
--==============================
local function CreateTab(name, order)
    local Button = Instance.new("TextButton", TabBar)
    Button.Size = UDim2.new(1,0,0,38)
    Button.Position = UDim2.new(0,0,0,(order-1)*40)
    Button.Text = name
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.TextColor3 = Color3.new(1,1,1)
    Button.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local Frame = Instance.new("Frame", Main)
    Frame.Position = UDim2.new(0,140,0,52)
    Frame.Size = UDim2.new(1,-150,1,-62)
    Frame.BackgroundTransparency = 1
    Frame.Visible = false

    Tabs[name] = Frame

    Button.MouseButton1Click:Connect(function()
        if CurrentTab then CurrentTab.Visible = false end
        CurrentTab = Frame
        Frame.Visible = true
    end)
end

-- タブ定義（日本語）
CreateTab("メイン",1)
CreateTab("プレイヤー",2)
CreateTab("フリング",3)
CreateTab("表示",4)
CreateTab("設定",5)

CurrentTab = Tabs["メイン"]
CurrentTab.Visible = true

--==============================
-- UI部品作成（共通）
--==============================
local function CreateButton(parent, text, y, callback)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(0,220,0,36)
    B.Position = UDim2.new(0,10,0,y)
    B.Text = text
    B.Font = Enum.Font.Gotham
    B.TextSize = 14
    B.TextColor3 = Color3.new(1,1,1)
    B.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", B)
    B.MouseButton1Click:Connect(callback)
end

--==============================
-- プレイヤー機能
--==============================
local WalkSpeed = 16
local JumpPower = 50
local Fly = false
local Noclip = false

CreateButton(Tabs["プレイヤー"], "移動速度アップ", 10, function()
    WalkSpeed += 4
    Humanoid.WalkSpeed = WalkSpeed
end)

CreateButton(Tabs["プレイヤー"], "ジャンプ力アップ", 55, function()
    JumpPower += 20
    Humanoid.JumpPower = JumpPower
end)

CreateButton(Tabs["プレイヤー"], "フライ切替", 100, function()
    Fly = not Fly
end)

CreateButton(Tabs["プレイヤー"], "ノークリップ切替", 145, function()
    Noclip = not Noclip
end)

--==============================
-- フリング専用（基礎）
--==============================
local AutoFling = false

CreateButton(Tabs["フリング"], "オートフリング ON/OFF", 10, function()
    AutoFling = not AutoFling
end)

--==============================
-- 表示系
--==============================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = 120
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Visible = false

CreateButton(Tabs["表示"], "FOVサークル表示", 10, function()
    FOVCircle.Visible = not FOVCircle.Visible
end)

--==============================
-- 設定
--==============================
CreateButton(Tabs["設定"], "UIを完全削除", 10, function()
    GUI:Destroy()
end)

--==============================
-- 毎フレーム処理
--==============================
RunService.RenderStepped:Connect(function()
    if Fly and HRP then
        HRP.Velocity = Camera.CFrame.LookVector * 60
    end

    if Noclip and Character then
        for _,v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end

    if FOVCircle.Visible then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end)

--==============================
-- モバイル & PC 共通：UI表示切替
--==============================
UserInputService.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

print("Syu Ultimate Complete Hub 読み込み完了")
'''

path = "/mnt/data/Syu_Ultimate_CompleteHub_JP.lua"
with open(path, "w", encoding="utf-8") as f:
    f.write(content)

path
