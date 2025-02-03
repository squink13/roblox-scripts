-- Configuration
local world = 86
local autoProgressWorld = 80
local maxWave = 91
local rejoinInterval = 7200
local isTeleportEnabled = false
local checkVisibilityOnly = false
local autoRejoinEnabled = false
local autoProgressEnabled = false

-- Services
local player = game.Players.LocalPlayer

-- UI Elements
local gui = player:WaitForChild("PlayerGui"):WaitForChild("GUI")
local battle = gui:WaitForChild("主界面"):WaitForChild("战斗")
local levelInfo = battle:WaitForChild("关卡信息")
local textElement = levelInfo:WaitForChild("文本")

-- RemoteEvent References
local repStorage = game:GetService("ReplicatedStorage")
local teleportRemote

local function rejoinServer()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
end

local function autoRejoinLoop()
    while autoRejoinEnabled do
        wait(rejoinInterval)
        if autoRejoinEnabled then
            rejoinServer()
        end
    end
end

local function onTeleport()
    if not teleportRemote then
        teleportRemote = repStorage:WaitForChild("主公令"):WaitForChild("进入副本按钮")
    end
    teleportRemote:FireServer(world)
end

-- Continuously monitor the player's position
local function monitorTeleport()
    while isTeleportEnabled do
        local shouldTeleport = false

        if checkVisibilityOnly then
            shouldTeleport = not levelInfo.Visible
        else
            local valueText = textElement.Text
            local currentValue = valueText:match("%d+/%d+") and tonumber(valueText:match("(%d+)/%d+"))
            shouldTeleport = (currentValue and currentValue > maxWave) or not levelInfo.Visible
        end

        if shouldTeleport then
            onTeleport()
        end

        wait(0.5)
    end
end

local function autoProgressLoop()
    while autoProgressEnabled do
        local currentWorld = tonumber(player:WaitForChild("值"):WaitForChild("主线进度"):WaitForChild("世界").Value)
        if currentWorld >= autoProgressWorld then break end
        
        world = currentWorld
        onTeleport()
        
        if levelInfo.Visible then
            repeat task.wait(0.5) until not levelInfo.Visible
        end
        
        task.wait(0.5)
    end
end

-- Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Cultivation Simulator",
    DisableRayfieldPrompts = true,
    ConfigurationSaving = {Enabled = true}
})

local Tab = Window:CreateTab("Main Tab", 4483362458)

Tab:CreateInput({
    Name = "World Selector",
    CurrentValue = "",
    PlaceholderText = tostring(world),
    Flag = "WorldSelect",
    Callback = function(Text)
        local inputWorld = tonumber(Text)
        world = inputWorld or world
    end,
})

Tab:CreateToggle({
    Name = "Speed Farm",
    Flag = "FarmToggle",
    Callback = function(Value)
        isTeleportEnabled = Value
        if Value then coroutine.wrap(monitorTeleport)() end
    end,
})

Tab:CreateToggle({
    Name = "Enable Full Clears",
    Flag = "VisibilityToggle",
    Callback = function(Value)
        checkVisibilityOnly = Value
    end,
})

Tab:CreateToggle({
    Name = "Auto Progress",
    Flag = "AutoProgressToggle",
    Callback = function()
        autoProgressEnabled = Value
        if Value then coroutine.wrap(autoProgressLoop)() end
    end,
})

Tab:CreateToggle({
    Name = "Auto Rejoin",
    Flag = "AutoRejoinToggle",
    Callback = function(Value)
        autoRejoinEnabled = Value
        if Value then coroutine.wrap(autoRejoinLoop)() end
    end,
})

Tab:CreateButton({
    Name = "Rejoin Server",
    Callback = rejoinServer,
})

-- Anti-AFK
local function antiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    local function captureController()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
    
    local success, _ = pcall(function()
        for _, connection in pairs(getconnections(player.Idled)) do
            if connection.Disable then connection:Disable()
            elseif connection.Disconnect then connection:Disconnect() end
        end
    end)
    
    if not success then
        player.Idled:Connect(captureController)
    end
end

-- Initialize
antiAFK()
Rayfield:LoadConfiguration()