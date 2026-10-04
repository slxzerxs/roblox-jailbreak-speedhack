-- v1.1.1
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local FORCE_MULTIPLIER = 2500000
local BIKE_FORCE_MULTIPLIER = 0.3
local BUGGY_FORCE_MULTIPLIER = 0.5
local DEFAULT_FORCE_MULTIPLIER = 1

local dir = 0

local keyBindings = {
    {Enum.KeyCode.W, 1},
    {Enum.KeyCode.S, -1},
}

local function getKeyDirection(key)
    for _, binding in ipairs(keyBindings) do
        if binding[1] == key then
            return binding[2]
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    local vehicles = workspace.Vehicles:GetChildren()
    
    for _, vehicle in ipairs(vehicles) do
        if vehicle.Name == "Heli" then
            continue
        end
        
        local engine = vehicle:FindFirstChild("Engine")
        if not engine then
            continue
        end
        
        local force = engine:FindFirstChild("NewForce")
        
        if not force then
            local originalForce = engine:FindFirstChild("BodyForce") or engine:FindFirstChild("VectorForce")
            if originalForce then
                force = originalForce:Clone()
                force.Parent = engine
                force.Name = "NewForce"
            end
        end
        
        if force then
            local forceAmount = DEFAULT_FORCE_MULTIPLIER
            
            if vehicle.Name:lower():find("bike") then
                forceAmount = BIKE_FORCE_MULTIPLIER
            elseif vehicle.Name:lower():find("bugg") then
                forceAmount = BUGGY_FORCE_MULTIPLIER
            end
            
            local seat = vehicle:FindFirstChild("Seat")
            if seat and seat:FindFirstChild("PlayerName") and seat.PlayerName.Value ~= Players.LocalPlayer.Name then
                forceAmount = 0
            end
            
            local lookVector = vehicle:GetPrimaryPartCFrame().lookVector
            force.Force = Vector3.new(
                lookVector.X * FORCE_MULTIPLIER * dir * forceAmount,
                0,
                lookVector.Z * FORCE_MULTIPLIER * dir * forceAmount
            )
        end
    end
end)

UserInputService.InputBegan:Connect(function(input)
    local direction = getKeyDirection(input.KeyCode)
    if direction then
        dir = direction
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if getKeyDirection(input.KeyCode) == dir then
        dir = 0
    end
end)
