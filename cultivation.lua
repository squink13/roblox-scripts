local player = game.Players.LocalPlayer
repeat wait() until player.Character
local character = player.Character
local humanoidRootPart = character.HumanoidRootPart
local forwardDirection
local defaultAngle = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)

local gui = player:WaitForChild("PlayerGui"):WaitForChild("GUI")
local mainInterface = gui:WaitForChild("主界面")
local battle = mainInterface:WaitForChild("战斗")
local levelInfo = battle:WaitForChild("关卡信息")
local textElement = levelInfo:WaitForChild("文本")

-- Variables to control the loop dynamically
local isTeleportEnabled = false
local checkVisibilityOnly = false
local monsterClears = false
local world = 61
local teleportRunning = false
local autoProgressRunning = false

local lastTeleportTime = 0
local teleportCooldown = 2 -- Cooldown between teleports

-- Store the forward direction when the script executes
local function storeForwardDirection()
    local camera = game.Workspace.CurrentCamera
    if camera then
        local lookVector = camera.CFrame.LookVector
        forwardDirection = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
    end
end

-- Function to run when significant movement is detected
local function onTeleport()
    local currentTime = os.clock()
    if currentTime - lastTeleportTime < teleportCooldown then
        return -- Skip if cooldown hasn't expired
    end
    lastTeleportTime = currentTime

    local args = {
        [1] = world
    }

    game:GetService("ReplicatedStorage"):FindFirstChild("\228\186\139\228\187\182")
        :FindFirstChild("\229\133\172\231\148\168")
        :FindFirstChild("\229\133\179\229\141\161")
        :FindFirstChild("\232\191\155\229\133\165\228\184\150\231\149\140\229\133\179\229\141\161")
        :FireServer(unpack(args))

    if monsterClears and forwardDirection then
        task.wait(0.8)
        if player and character then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + forwardDirection * 46 + Vector3.new(0, 2, 0)
        end
    end
end

-- Continuously monitor the player's position
local function monitorTeleport()
    if teleportRunning then return end
    teleportRunning = true

    while isTeleportEnabled do
        if checkVisibilityOnly then
            if not levelInfo.Visible then
                onTeleport()
            end
        else
            local valueText = textElement.Text
            if valueText and valueText:match("%d+/%d+") then
                local currentValue = tonumber(valueText:match("%d+/%d+"):match("(%d+)/%d+"))
                if currentValue and (currentValue > 91 or not levelInfo.Visible) then
                    onTeleport()
                end
            elseif not levelInfo.Visible then
                onTeleport()
            end
        end
        task.wait(1) -- Reduced loop frequency
    end
    teleportRunning = false
end

-- Auto Progress Logic
local function autoProgress()
    if autoProgressRunning then return end
    autoProgressRunning = true

    coroutine.wrap(function()
        local currentWorld = tonumber(player:WaitForChild("值"):WaitForChild("主线进度"):WaitForChild("世界").Value)
        print("Starting from World:", currentWorld)

        while currentWorld < 80 and isTeleportEnabled do
            world = currentWorld
            Input:Set(world)
            onTeleport()

            if levelInfo then
                repeat
                    task.wait(1) -- Reduced frequency
                until not levelInfo.Visible
            end

            task.wait(1)
            currentWorld = tonumber(player:WaitForChild("值"):WaitForChild("主线进度"):WaitForChild("世界").Value)
        end
        print("Auto Progress Completed")
    end)()
    autoProgressRunning = false
end

-- Rayfield Integration
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Cultivation Simulator",
    DisableRayfieldPrompts = true,
    ConfigurationSaving = {
        Enabled = true,
        FileName = CFileName
    },
})

local Tab = Window:CreateTab("Main Tab", 4483362458)

local Input = Tab:CreateInput({
    Name = "World Selector",
    CurrentValue = "",
    PlaceholderText = world,
    RemoveTextAfterFocusLost = false,
    Flag = "WorldSelect",
    Callback = function(Text)
        local inputWorld = tonumber(Text)
        if inputWorld then
            world = inputWorld
            print("Selected World ID updated to:", world)
        else
            warn("Invalid world ID entered. Please enter a valid number.")
        end
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Speed Farm",
    CurrentValue = false,
    Flag = "FarmToggle",
    Callback = function(Value)
        isTeleportEnabled = Value
        if isTeleportEnabled then
            coroutine.wrap(monitorTeleport)()
        end
    end,
})

local AutoProgressToggle = Tab:CreateToggle({
    Name = "Auto Progress",
    CurrentValue = false,
    Flag = "AutoProgressToggle",
    Callback = function(Value)
        isTeleportEnabled = Value
        autoProgress()
    end,
})

-- Anti-AFK
local idleConnection
local VirtualUser = cloneref(game:GetService("VirtualUser"))
if idleConnection then
    idleConnection:Disconnect()
end
idleConnection = player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

storeForwardDirection()
Rayfield:LoadConfiguration()
Input:Set(world)
