local player = game.Players.LocalPlayer

local gui = player:WaitForChild("PlayerGui"):WaitForChild("GUI")
local mainInterface = gui:WaitForChild("主界面")
local battle = mainInterface:WaitForChild("战斗")
local levelInfo = battle:WaitForChild("关卡信息")
local textElement = levelInfo:WaitForChild("文本")

-- Variable to control the loop dynamically
local isTeleportEnabled = false
local world = 61

-- Function to run when significant movement is detected
local function onTeleport()
    -- print("Teleported to world", world)
    -- Call the function to re-enter the world
    local args = {
        [1] = world -- Replace this with the world ID or parameter you need
    }

    game:GetService("ReplicatedStorage"):FindFirstChild("\228\186\139\228\187\182")
        :FindFirstChild("\229\133\172\231\148\168")
        :FindFirstChild("\229\133\179\229\141\161")
        :FindFirstChild("\232\191\155\229\133\165\228\184\150\231\149\140\229\133\179\229\141\161")
        :FireServer(unpack(args))
end

-- Continuously monitor the player's position
local function monitorTeleport()
    onTeleport()
    while isTeleportEnabled do
        -- Extract the current value from textElement.Text
        local valueText = textElement.Text
        if valueText and valueText:match("%d+/%d+") then
            local currentValue = tonumber(valueText:match("%d+/%d+"):match("(%d+)/%d+"))
            
            -- Check if the current value is 100
            if currentValue and (currentValue > 95 or not levelInfo.Visible) then
                onTeleport()
            end
        elseif not levelInfo.Visible then
            onTeleport()
        end
        
        wait(0.2) -- Check every 0.5 seconds
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
    PlaceholderText = "61",
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
        -- Update the global control variable
        isTeleportEnabled = Value

        -- Start or stop the monitoring loop
        if isTeleportEnabled then
            coroutine.wrap(monitorTeleport)()
        end
    end,
})

-- anti afk
local GC = getconnections or get_signal_cons
if GC then
    print("Player Idle Disabled")
    for i,v in pairs(GC(player.Idled)) do
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

Rayfield:LoadConfiguration()