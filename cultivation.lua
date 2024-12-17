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

-- Store the forward direction when the script executes
local function storeForwardDirection()
    local camera = game.Workspace.CurrentCamera
    if camera then
        local lookVector = camera.CFrame.LookVector
        -- Ignore the Y (up/down) component to focus on horizontal movement
        forwardDirection = Vector3.new(lookVector.X, 0, lookVector.Z).Unit -- Normalize the vector
    end
end

-- Function to run when significant movement is detected
local function onTeleport()
    local args = {
        [1] = world -- Replace this with the world ID or parameter you need
    }

    -- Fire the server with initial teleport
    game:GetService("ReplicatedStorage"):FindFirstChild("\228\186\139\228\187\182")
        :FindFirstChild("\229\133\172\231\148\168")
        :FindFirstChild("\229\133\179\229\141\161")
        :FindFirstChild("\232\191\155\229\133\165\228\184\150\231\149\140\229\133\179\229\141\161")
        :FireServer(unpack(args))

    task.wait(0.8)

    -- Move the player in the stored forward direction
    if forwardDirection then
        if player and character then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + forwardDirection * 46 + Vector3.new(0, 2, 0)
        end
    else
        warn("Forward direction not stored.")
    end
end

-- Continuously monitor the player's position
local function monitorTeleport()
    while isTeleportEnabled do
        if checkVisibilityOnly then
            -- Only teleport if the text element is not visible
            if not levelInfo.Visible then
                onTeleport()
            elseif monsterClears then
                local args = {
                    [1] = 1,
                    [2] = character,
                    [3] = defaultAngle
                }

                game:GetService("ReplicatedStorage"):FindFirstChild("\228\186\139\228\187\182")
                    :FindFirstChild("\229\133\172\231\148\168")
                    :FindFirstChild("\230\138\128\232\131\189")
                    :FindFirstChild("\228\189\191\231\148\168\230\138\128\232\131\189")
                    :FireServer(unpack(args))
            end
        else
            -- Normal teleport logic
            local valueText = textElement.Text
            if valueText and valueText:match("%d+/%d+") then
                local currentValue = tonumber(valueText:match("%d+/%d+"):match("(%d+)/%d+"))

                if currentValue and (currentValue > 91 or not levelInfo.Visible) then
                    onTeleport()
                elseif monsterClears then
                    local args = {
                        [1] = 1,
                        [2] = character,
                        [3] = defaultAngle
                    }

                    game:GetService("ReplicatedStorage"):FindFirstChild("\228\186\139\228\187\182")
                        :FindFirstChild("\229\133\172\231\148\168")
                        :FindFirstChild("\230\138\128\232\131\189")
                        :FindFirstChild("\228\189\191\231\148\168\230\138\128\232\131\189")
                        :FireServer(unpack(args))
                end
            elseif not levelInfo.Visible then
                onTeleport()
            end
        end

        wait(0.5)
    end
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
    Flag = "FarmToggle", -- Unique identifier for saving configurations
    Callback = function(Value)
        isTeleportEnabled = Value
        if isTeleportEnabled then
            coroutine.wrap(monitorTeleport)()
        end
    end,
})

local VisibilityToggle = Tab:CreateToggle({
    Name = "Enable Full Clears",
    CurrentValue = false,
    Flag = "VisibilityToggle", -- Unique identifier for saving configurations
    Callback = function(Value)
        checkVisibilityOnly = Value
        print("Check Visibility Only mode:", checkVisibilityOnly)
    end,
})

local MonsterClearsToggle = Tab:CreateToggle({
    Name = "Enable Speed Monster Clears",
    CurrentValue = false,
    Flag = "MonsterClearsToggle", -- Unique identifier for saving configurations
    Callback = function(Value)
        monsterClears = Value
        print("Monster clear mode:", monsterClears)
    end,
})

local AutoProgressToggle = Tab:CreateToggle({
    Name = "Auto Progress",
    CurrentValue = false,
    Flag = "AutoProgressToggle",
    Callback = function()
        print("Auto Progress Started")
        
        coroutine.wrap(function()
            local currentWorld = tonumber(player:WaitForChild("值"):WaitForChild("主线进度"):WaitForChild("世界").Value)
            print("Starting from World:", currentWorld)

            while currentWorld < 80 or Value do
                world = currentWorld
                Input:Set(world)


                onTeleport() -- Perform teleport to the current world
                
                if levelInfo then
                    repeat
                        wait(0.5)
                    until not levelInfo.Visible
                end

                wait(0.5)
                currentWorld = tonumber(player:WaitForChild("值"):WaitForChild("主线进度"):WaitForChild("世界").Value)
            end

            print("Auto Progress Completed")
        end)()
    end,
})

-- anti afk
local GC = getconnections or get_signal_cons
if GC then
    print("Player Idle Disabled")
    for i, v in pairs(GC(player.Idled)) do
        if v["Disable"] then
            v["Disable"](v)
        elseif v["Disconnect"] then
            v["Disconnect"](v)
        end
    end
else
    print("Clicked button")
    local VirtualUser = cloneref(game:GetService("VirtualUser"))
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

storeForwardDirection()

Rayfield:LoadConfiguration()
Input:Set(world)