--!strict
--[[
    ユニバーサルカスタムGUIシステム - 単一巨大スクリプト
    機能: ドラッグ, アニメーション, 最小化, タブ切り替え, 動的コンポーネント, Place IDチェック
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 設定 ------------------------------------------------------------------------
local TARGET_PLACE_ID: number = 6961824067
local TWEEN_DURATION: number = 0.3
local MINIMIZED_SIZE: UDim2 = UDim2.new(0, 300, 0, 30) -- 最小化時のサイズ (例: ヘッダーのみ)
local EXPANDED_SIZE: UDim2 = UDim2.new(0, 400, 0, 600)  -- 展開時のサイズ

-- UI要素の参照 (スクリプトの親から取得することを推奨)
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGui = PlayerGui:WaitForChild("ScreenGui") -- 適切なScreenGui名に修正してください

-- メイン要素
local MainFrame: GuiObject = ScreenGui:WaitForChild("MainFrame")
local DragHandle: GuiObject = MainFrame:WaitForChild("DragHandle")
local ToggleMinimizeButton: GuiObject = MainFrame:WaitForChild("ToggleMinimizeButton")
local ComponentParent: GuiObject = MainFrame:WaitForChild("ComponentParent") -- 動的コンポーネントを配置する場所

-- タブ要素 (実際の構造に合わせて調整してください)
local TabButtons = {
    Tab1 = MainFrame:WaitForChild("TabHeader"):WaitForChild("Tab1Button"),
    Tab2 = MainFrame:WaitForChild("TabHeader"):WaitForChild("Tab2Button"),
}
local ContentFrames = {
    Tab1 = MainFrame:WaitForChild("ContentFrame"):WaitForChild("Tab1Content"),
    Tab2 = MainFrame:WaitForChild("ContentFrame"):WaitForChild("Tab2Content"),
}

-- グローバル状態 --------------------------------------------------------------
local isMinimized: boolean = false
local currentActiveTab: string = "Tab1"

-- **1. Place IDチェック** ----------------------------------------------------

if game.PlaceId ~= TARGET_PLACE_ID then
    warn("UI System disabled: Incorrect Place ID. Expected: " .. TARGET_PLACE_ID .. ", Found: " .. game.PlaceId)
    -- GUI全体を非表示または破棄
    ScreenGui.Enabled = false
    script:Destroy() 
    return
end

print("UI System initialized for Target Place ID: " .. TARGET_PLACE_ID)

-- **2. 滑らかなアニメーション関数 (TweenService)** ----------------------------

--- UI要素にTweenアニメーションを適用する
local function tweenUI(instance: GuiObject, properties: table, duration: number?, style: Enum.EasingStyle?, direction: Enum.EasingDirection?)
    local info = TweenInfo.new(
        duration or TWEEN_DURATION, 
        style or Enum.EasingStyle.Quad, 
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

-- **3. 完全なドラッグ＆ドロップシステム** ------------------------------------

local isDragging: boolean = false
local dragStartPosition: Vector2 = Vector2.new(0, 0)
local frameInitialPosition: UDim2 = MainFrame.Position

local function setupDragSystem()
    DragHandle.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartPosition = UserInputService:GetMouseLocation()
            frameInitialPosition = MainFrame.Position

            -- フレームを最前面に移動
            MainFrame.ZIndex = 10 
        end
    end)

    DragHandle.InputEnded:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            MainFrame.ZIndex = 1 -- 通常のZIndexに戻す
        end
    end)
    
    -- RunService:RenderSteppedを使用して正確な追従を実現
    RunService.RenderStepped:Connect(function()
        if isDragging then
            local currentPosition = UserInputService:GetMouseLocation()
            local delta = currentPosition - dragStartPosition -- 移動量 (Vector2)

            local newX = frameInitialPosition.X.Offset + delta.X
            local newY = frameInitialPosition.Y.Offset + delta.Y
            
            -- オフセット値を境界内にクランプする (任意)
            -- newX = math.clamp(newX, 0, workspace.CurrentCamera.ViewportSize.X - MainFrame.AbsoluteSize.X)
            -- newY = math.clamp(newY, 0, workspace.CurrentCamera.ViewportSize.Y - MainFrame.AbsoluteSize.Y)

            MainFrame.Position = UDim2.new(
                frameInitialPosition.X.Scale, newX, 
                frameInitialPosition.Y.Scale, newY
            )
        end
    end)
end


-- **4. 最小化・展開機能（UIの状態管理）** ------------------------------------

local function toggleMinimize()
    isMinimized = not isMinimized
    
    local targetSize = isMinimized and MINIMIZED_SIZE or EXPANDED_SIZE
    
    -- メインフレームのサイズ変更アニメーション
    tweenUI(MainFrame, {Size = targetSize}, 0.5, Enum.EasingStyle.Quart)
    
    -- コンテンツのフェードアウト/イン (ContentFrameはMainFrameの子で、タブコンテンツの親とする)
    local ContentFrame = MainFrame:FindFirstChild("ContentFrame") 
    if ContentFrame then
        local targetTransparency = isMinimized and 1 or 0
        -- ContentFrame全体をフェードアウト/イン
        tweenUI(ContentFrame, {BackgroundTransparency = targetTransparency}, 0.5)

        -- 内容物の可視性制御（サイズがゼロになる前にContentFrameのVisibleを切り替える方が安全）
        -- ContentFrame.Visible = not isMinimized -- (Visibleを切るとTweenが途切れるため、Transparencyで制御推奨)
    end
end

ToggleMinimizeButton.MouseButton1Click:Connect(toggleMinimize)


-- **5. タブ切り替えシステム** ------------------------------------------------

local function switchTab(tabName: string)
    if currentActiveTab == tabName then return end

    -- コンテンツの切り替えとアニメーション
    for name, frame in pairs(ContentFrames) do
        local isTarget = (name == tabName)
        
        -- 現在のタブを非表示にし、ターゲットタブを表示
        if frame:IsA("GuiObject") then
            -- フェードアウト/インアニメーション
            local targetTransparency = isTarget and 0 or 1
            tweenUI(frame, {BackgroundTransparency = targetTransparency}, 0.2)
            
            -- Visibleはアニメーション後に切り替えるか、LayoutOrderなどで制御
            if not isTarget then
                -- ターゲットでないならすぐに非表示 (またはアニメーション後に非表示)
                frame.Visible = false
            else
                frame.Visible = true
            end
        end
    end
    
    -- ボタンのハイライト (スタイル変更)
    for name, button in pairs(TabButtons) do
        if button:IsA("TextButton") then
            local isTarget = (name == tabName)
            local targetColor = isTarget and Color3.new(0.3, 0.5, 0.9) or Color3.new(0.2, 0.2, 0.2)
            tweenUI(button, {BackgroundColor3 = targetColor}, 0.2)
        end
    end
    
    currentActiveTab = tabName
end

-- タブボタンにイベントを設定
for tabName, button in pairs(TabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end

-- 初期タブを設定
if next(TabButtons) then
    switchTab(next(TabButtons))
end


-- **6. 動的な要素生成（ボタン、トグル、スライダーのクラス化）** ----------------

-- 最小限のコンポーネントジェネレーターとして実装
local ComponentGenerator = {}

--- 基本ボタンの生成
function ComponentGenerator.createButton(parent: GuiObject, text: string, callback: (button: TextButton) -> ())
    local button = Instance.new("TextButton")
    button.Name = "DynamicButton"
    button.Text = text
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    button.Font = Enum.Font.SourceSans
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 18
    button.Parent = parent
    
    button.MouseButton1Click:Connect(function()
        -- クリックアニメーション
        tweenUI(button, {BackgroundTransparency = 0.5}, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        tweenUI(button, {BackgroundTransparency = 0}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        callback(button)
    end)
    
    return button
end

--- トグルボタンの生成
function ComponentGenerator.createToggle(parent: GuiObject, text: string, initialValue: boolean, callback: (newValue: boolean) -> ())
    local state = initialValue
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Parent = frame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Text = state and "ON" or "OFF"
    toggleButton.Size = UDim2.new(0.2, 0, 1, 0)
    toggleButton.BackgroundColor3 = state and Color3.new(0.1, 0.5, 0.1) or Color3.new(0.5, 0.1, 0.1)
    toggleButton.Position = UDim2.new(0.8, 0, 0, 0)
    toggleButton.Parent = frame
    
    local function updateToggle(newValue: boolean)
        state = newValue
        toggleButton.Text = state and "ON" or "OFF"
        local targetColor = state and Color3.new(0.1, 0.7, 0.1) or Color3.new(0.7, 0.1, 0.1)
        tweenUI(toggleButton, {BackgroundColor3 = targetColor}, 0.2)
        callback(state)
    end

    toggleButton.MouseButton1Click:Connect(function()
        updateToggle(not state)
    end)
    
    return frame
end

-- 初期化と実行 ------------------------------------------------------------------

-- 1. ドラッグシステムのセットアップ
setupDragSystem()

-- 2. 動的コンポーネントの生成例 (Tab1Content内にGrid/List Layoutが必要です)
ComponentGenerator.createButton(ContentFrames.Tab1, "実行ボタン", function(btn)
    print("ボタンがクリックされました！")
end)

ComponentGenerator.createToggle(ContentFrames.Tab1, "機能を有効化", false, function(newValue)
    print("トグル状態が変更されました: " .. tostring(newValue))
end)

-- MainFrameを初期の展開サイズに設定
MainFrame.Size = EXPANDED_SIZE

print("UI System Ready.")
