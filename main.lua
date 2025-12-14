--[[
    Advanced UI Library Framework "Obsidian"
    Target Place ID: 6961824067
    Version: 1.0.0
    
    Architecture: Object-Oriented Programming (OOP)
    Features: Draggable, Minimizable, Tab System, Smooth Tweens, Component Based
    
    Note: This is a foundational framework designed for scalability.
    Safety: Clean code, no malicious functions included.
]]

--------------------------------------------------------------------------------
-- [ SERVICES ]
--------------------------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

--------------------------------------------------------------------------------
-- [ CONFIGURATION & CONSTANTS ]
--------------------------------------------------------------------------------
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TARGET_PLACE_ID = 6961824067

local COLORS = {
    Background = Color3.fromRGB(25, 25, 30),
    Header = Color3.fromRGB(35, 35, 40),
    Accent = Color3.fromRGB(0, 170, 255),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 180),
    Element = Color3.fromRGB(45, 45, 50),
    Hover = Color3.fromRGB(55, 55, 60)
}

local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

--------------------------------------------------------------------------------
-- [ UTILITY FUNCTIONS ]
--------------------------------------------------------------------------------
local Utility = {}

function Utility:Create(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    return instance
end

function Utility:AddCorner(instance, radius)
    return Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = instance
    })
end

function Utility:AddStroke(instance, color, thickness)
    return Utility:Create("UIStroke", {
        Color = color or COLORS.Accent,
        Thickness = thickness or 1,
        Transparency = 0.8,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = instance
    })
end

function Utility:EnableDragging(frame, dragHandle)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(frame, TweenInfo.new(0.1), {Position = targetPos}):Play()
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
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

--------------------------------------------------------------------------------
-- [ LIBRARY CLASS ]
--------------------------------------------------------------------------------
local Library = {}
Library.__index = Library
Library.Windows = {}

function Library.new(title)
    local self = setmetatable({}, Library)
    
    -- Create ScreenGui
    -- Note: Standard scripts use PlayerGui. Executors might use CoreGui (protected).
    local targetParent = LocalPlayer:WaitForChild("PlayerGui")
    
    self.ScreenGui = Utility:Create("ScreenGui", {
        Name = "ObsidianUI_" .. math.random(1000,9999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = targetParent
    })

    self.MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175),
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    
    Utility:AddCorner(self.MainFrame, 8)
    Utility:AddStroke(self.MainFrame, COLORS.Accent, 1)

    -- Shadow
    Utility:Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = 0,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23,23,277,277),
        Parent = self.MainFrame
    })

    -- Header
    self.Header = Utility:Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = COLORS.Header,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.Header
    })
    
    -- Hide bottom corners of header
    Utility:Create("Frame", {
        Name = "HeaderFiller",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = COLORS.Header,
        BorderSizePixel = 0,
        Parent = self.Header
    })

    -- Title
    Utility:Create("TextLabel", {
        Name = "Title",
        Text = title or "UI Framework",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextColor3 = COLORS.TextMain,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Header
    })

    -- Close / Minimize Buttons Logic
    self:CreateWindowControls()

    -- Container for Tabs
    self.TabContainer = Utility:Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 120, 1, -50),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = self.MainFrame
    })
    
    self.TabContainerLayout = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.TabContainer
    })

    -- Container for Pages (Content)
    self.PageContainer = Utility:Create("Frame", {
        Name = "PageContainer",
        Size = UDim2.new(1, -145, 1, -50),
        Position = UDim2.new(0, 140, 0, 45),
        BackgroundColor3 = COLORS.Background, -- Or slightly darker
        BackgroundTransparency = 1,
        Parent = self.MainFrame
    })

    -- Enable Dragging
    Utility:EnableDragging(self.MainFrame, self.Header)

    -- Toggle Logic
    self.IsOpen = true
    self.CurrentTab = nil

    return self
end

function Library:CreateWindowControls()
    local ControlsHolder = Utility:Create("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(1, -65, 0, 0),
        BackgroundTransparency = 1,
        Parent = self.Header
    })

    local CloseBtn = Utility:Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -25, 0.5, -12.5),
        BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        Text = "",
        AutoButtonColor = false,
        Parent = ControlsHolder
    })
    Utility:AddCorner(CloseBtn, 6)

    local MinBtn = Utility:Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -55, 0.5, -12.5),
        BackgroundColor3 = COLORS.Accent,
        Text = "",
        AutoButtonColor = false,
        Parent = ControlsHolder
    })
    Utility:AddCorner(MinBtn, 6)

    -- Events
    CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    local minimized = false
    local openSize = UDim2.new(0, 500, 0, 350)
    local minSize = UDim2.new(0, 500, 0, 40)

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(self.MainFrame, TWEEN_INFO, {Size = minSize}):Play()
            self.PageContainer.Visible = false
            self.TabContainer.Visible = false
        else
            TweenService:Create(self.MainFrame, TWEEN_INFO, {Size = openSize}):Play()
            task.wait(0.2)
            self.PageContainer.Visible = true
            self.TabContainer.Visible = true
        end
    end)
end

function Library:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

--------------------------------------------------------------------------------
-- [ TAB CLASS ]
--------------------------------------------------------------------------------
local Tab = {}
Tab.__index = Tab

function Library:AddTab(name, iconId)
    local newTab = setmetatable({}, Tab)
    newTab.Library = self
    
    -- Tab Button
    newTab.Button = Utility:Create("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = COLORS.Element,
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextColor3 = COLORS.TextDim,
        TextSize = 14,
        Parent = self.TabContainer
    })
    Utility:AddCorner(newTab.Button, 6)
    
    -- Page Frame
    newTab.Page = Utility:Create("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = COLORS.Accent,
        Visible = false,
        Parent = self.PageContainer
    })
    
    Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = newTab.Page
    })
    
    Utility:Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = newTab.Page
    })

    -- Tab Click Event
    newTab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(newTab)
    end)

    -- If first tab, select it
    if not self.CurrentTab then
        self:SelectTab(newTab)
    end

    return newTab
end

function Library:SelectTab(selectedTab)
    -- Reset all tabs
    for _, child in pairs(self.TabContainer:GetChildren()) do
        if child:IsA("TextButton") then
            TweenService:Create(child, TWEEN_INFO, {BackgroundColor3 = COLORS.Element, TextColor3 = COLORS.TextDim}):Play()
        end
    end
    for _, child in pairs(self.PageContainer:GetChildren()) do
        child.Visible = false
    end

    -- Activate selected
    TweenService:Create(selectedTab.Button, TWEEN_INFO, {BackgroundColor3 = COLORS.Accent, TextColor3 = COLORS.TextMain}):Play()
    selectedTab.Page.Visible = true
    self.CurrentTab = selectedTab
end

--------------------------------------------------------------------------------
-- [ ELEMENT CLASSES: BUTTON, TOGGLE, SLIDER ]
--------------------------------------------------------------------------------

-- 1. Button
function Tab:AddButton(text, callback)
    local callback = callback or function() end
    
    local ButtonFrame = Utility:Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = COLORS.Element,
        Text = "",
        AutoButtonColor = false,
        Parent = self.Page
    })
    Utility:AddCorner(ButtonFrame, 6)
    
    local Label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextColor3 = COLORS.TextMain,
        TextSize = 14,
        Parent = ButtonFrame
    })

    -- Animation
    ButtonFrame.MouseEnter:Connect(function()
        TweenService:Create(ButtonFrame, TWEEN_INFO, {BackgroundColor3 = COLORS.Hover}):Play()
    end)
    ButtonFrame.MouseLeave:Connect(function()
        TweenService:Create(ButtonFrame, TWEEN_INFO, {BackgroundColor3 = COLORS.Element}):Play()
    end)
    ButtonFrame.MouseButton1Click:Connect(function()
        local originalSize = ButtonFrame.Size
        -- Click effect
        TweenService:Create(ButtonFrame, TweenInfo.new(0.05), {Size = UDim2.new(originalSize.X.Scale, -2, originalSize.Y.Offset, -2)}):Play()
        task.wait(0.05)
        TweenService:Create(ButtonFrame, TweenInfo.new(0.05), {Size = originalSize}):Play()
        
        pcall(callback)
    end)
end

-- 2. Toggle
function Tab:AddToggle(text, default, callback)
    local callback = callback or function() end
    local toggled = default or false

    local ToggleFrame = Utility:Create("TextButton", {
        Name = "Toggle",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = COLORS.Element,
        Text = "",
        AutoButtonColor = false,
        Parent = self.Page
    })
    Utility:AddCorner(ToggleFrame, 6)

    Utility:Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextColor3 = COLORS.TextMain,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ToggleFrame
    })

    local SwitchBg = Utility:Create("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = toggled and COLORS.Accent or Color3.fromRGB(80,80,80),
        Parent = ToggleFrame
    })
    Utility:AddCorner(SwitchBg, 10)

    local SwitchCircle = Utility:Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Parent = SwitchBg
    })
    Utility:AddCorner(SwitchCircle, 8)

    local function update()
        local targetColor = toggled and COLORS.Accent or Color3.fromRGB(80,80,80)
        local targetPos = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        
        TweenService:Create(SwitchBg, TWEEN_INFO, {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(SwitchCircle, TWEEN_INFO, {Position = targetPos}):Play()
        
        pcall(callback, toggled)
    end

    ToggleFrame.MouseButton1Click:Connect(function()
        toggled = not toggled
        update()
    end)
end

-- 3. Slider
function Tab:AddSlider(text, min, max, default, callback)
    local callback = callback or function() end
    local dragging = false

    local SliderFrame = Utility:Create("Frame", {
        Name = "Slider",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = COLORS.Element,
        Parent = self.Page
    })
    Utility:AddCorner(SliderFrame, 6)

    Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextColor3 = COLORS.TextMain,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SliderFrame
    })

    local ValueLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -60, 0, 5),
        BackgroundTransparency = 1,
        Text = tostring(default),
        Font = Enum.Font.GothamBold,
        TextColor3 = COLORS.TextDim,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = SliderFrame
    })

    local SliderBar = Utility:Create("TextButton", { -- Button for input capture
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        Text = "",
        AutoButtonColor = false,
        Parent = SliderFrame
    })
    Utility:AddCorner(SliderBar, 3)

    local Fill = Utility:Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = COLORS.Accent,
        Parent = SliderBar
    })
    Utility:AddCorner(Fill, 3)

    local function update(input)
        local pos = UDim2.new(math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), 0, 1, 0)
        TweenService:Create(Fill, TweenInfo.new(0.1), {Size = pos}):Play()
        
        local value = math.floor(min + ((max - min) * pos.X.Scale))
        ValueLabel.Text = tostring(value)
        pcall(callback, value)
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

--------------------------------------------------------------------------------
-- [ MAIN LOGIC & IMPLEMENTATION ]
--------------------------------------------------------------------------------

local function Init()
    -- Place ID Check
    if game.PlaceId ~= TARGET_PLACE_ID then
        warn("Warning: This script is optimized for Place ID " .. TARGET_PLACE_ID .. ". Some features might not match context.")
        -- We continue anyway for demonstration purposes, but in a real restrict script, you might return here.
    end

    -- Create UI Window
    local Window = Library.new("Obsidian Control Panel")

    -- Tab 1: Main Features
    local MainTab = Window:AddTab("Main")
    
    MainTab:AddButton("Test Button (Print)", function()
        print("Button Clicked!")
    end)
    
    MainTab:AddToggle("Auto Clicker (Example)", false, function(state)
        print("Toggle State:", state)
        -- Note: Actual looping logic would go here, managed by task.spawn
    end)

    MainTab:AddSlider("WalkSpeed Modifier", 16, 100, 16, function(val)
        -- Client-side visual only for safety demo
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
             -- LocalPlayer.Character.Humanoid.WalkSpeed = val 
             -- (Commented out to prevent anti-cheat flags in some games, use with caution)
             print("Speed set to:", val)
        end
    end)

    -- Tab 2: Visuals
    local VisualTab = Window:AddTab("Visuals")
    
    VisualTab:AddToggle("UI Shadow Effect", true, function(state)
       Window.MainFrame.Shadow.Visible = state
    end)

    VisualTab:AddButton("Refresh Character", function()
        -- Safe character refresh logic usually goes here
        print("Character Refresh Request")
    end)

    -- Tab 3: Settings
    local SettingsTab = Window:AddTab("Settings")
    
    SettingsTab:AddButton("Unload UI", function()
        Window:Destroy()
    end)
    
    print("Obsidian UI Loaded Successfully")
end

-- Run
Init()
