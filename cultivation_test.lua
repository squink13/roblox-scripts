local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")

-- GUI Elements
local levelInfo = player:WaitForChild("PlayerGui"):WaitForChild("GUI"):WaitForChild("主界面"):WaitForChild("战斗"):WaitForChild("关卡信息")
local textElement = levelInfo:WaitForChild("文本")

-- Global State Variables
local isTeleportEnabled = false
local checkVisibilityOnly = false
local world = 61

-- Helper Function: Fire Teleport Event
local function onTeleport()
    local teleportEvent = replicatedStorage:FindFirstChild("事件"):FindFirstChild("公体"):FindFirstChild("兯卡"):FindFirstChild("进入特慈兯卡")
    if teleportEvent then
        teleportEvent:FireServer(world)
    end
end

-- Monitor Player Position and Perform Teleport
local function monitorTeleport()
    while isTeleportEnabled do
        if checkVisibilityOnly and not levelInfo.Visible then
            onTeleport()
        elseif not checkVisibilityOnly then
            local valueText = textElement.Text
            local currentValue = valueText and tonumber(valueText:match("(%d+)/%d+"))

            if currentValue and (currentValue > 92 or not levelInfo.Visible) then
                onTeleport()
            end
        end
        task.wait(0.5)
    end
end

-- Auto Progress Function
local function autoProgress()
    coroutine.wrap(function()
        local progressData = player:WaitForChild("值"):WaitForChild("主线进度"):WaitForChild("世界")
        local currentWorld = tonumber(progressData.Value)

        while currentWorld < 80 and isTeleportEnabled do
            world = currentWorld
            Input:Set(world)  -- Update UI
            onTeleport()

            repeat task.wait(0.5) until not levelInfo.Visible
            task.wait(0.5)

            currentWorld = tonumber(progressData.Value)
        end
    end)()
end

-- Anti-AFK Implementation
local function disableAFK()
    local GC = getconnections or get_signal_cons
    if GC then
        for _, conn in pairs(GC(player.Idled)) do
            if conn.Disable then conn:Disable() end
            if conn.Disconnect then conn:Disconnect() end
        end
    end
end

-- UI Integration with Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Cultivation Simulator",
    DisableRayfieldPrompts = true,
    ConfigurationSaving = { Enabled = true, FileName = "CultivationSimConfig" },
})

local Tab = Window:CreateTab("Main Tab", 4483362458)

local Input = Tab:CreateInput({
    Name = "World Selector",
    CurrentValue = "",
    PlaceholderText = tostring(world),
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local inputWorld = tonumber(Text)
        if inputWorld then world = inputWorld end
    end,
})

Tab:CreateToggle({
    Name = "Farm",
    CurrentValue = false,
    Callback = function(Value)
        isTeleportEnabled = Value
        if Value then coroutine.wrap(monitorTeleport)() end
    end,
})

Tab:CreateToggle({
    Name = "Full Clears",
    CurrentValue = false,
    Callback = function(Value)
        checkVisibilityOnly = Value
    end,
})

Tab:CreateToggle({
    Name = "Auto Progress",
    CurrentValue = false,
    Callback = function(Value)
        isTeleportEnabled = Value
        if Value then autoProgress() end
    end,
})

-- Initialization
disableAFK()
Rayfield:LoadConfiguration()
Input:Set(world)
