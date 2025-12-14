-- ライブラリのセットアップ
local Window = Library:CreateWindow({
    Title = "BedWars Helper Utils [UI Demo]",
    Accent = Color3.fromRGB(255, 100, 100), -- 赤系のアクセントカラー
    Keybind = Enum.KeyCode.RightShift
})

-- 1. Main Tab (メイン機能)
local MainTab = Window:CreateTab("Main")

MainTab:CreateSection("Character")

MainTab:CreateButton("Reset Character", function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)

MainTab:CreateToggle("Sprint Loop (Example)", false, function(state)
    -- ここに実際の機能を入れます。これはただの例です。
    print("Sprint is now:", state)
    if state then
        -- ループ処理の開始など
    end
end)

MainTab:CreateSection("Visuals")

MainTab:CreateToggle("Fullbright (Lighting)", false, function(state)
    if state then
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.FogEnd = 100000
    else
        game.Lighting.Brightness = 1
        game.Lighting.ClockTime = 12
        game.Lighting.FogEnd = 500
    end
end)

-- 2. Misc Tab (その他)
local MiscTab = Window:CreateTab("Misc")

MiscTab:CreateButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

MiscTab:CreateButton("Copy Discord Link", function()
    setclipboard("https://discord.gg/example") -- Executor環境でのみ動作
end)

-- 3. Settings Tab
local SettingsTab = Window:CreateTab("Settings")
SettingsTab:CreateSection("UI Settings")
SettingsTab:CreateButton("Unload UI", function()
    game.CoreGui:FindFirstChild("AdvancedUI"):Destroy()
end)
