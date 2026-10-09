-- v1.2.0

local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")

local FORCE_MULTIPLIER      = 300000
local BIKE_FORCE_MULTIPLIER = 0.3
local BUGGY_FORCE_MULTIPLIER = 0.5
local DEFAULT_FORCE_MULTIPLIER = 1

local dir = 0
local keyBindings = {
    [Enum.KeyCode.W] =  1,
    [Enum.KeyCode.S] = -1,
}

UserInputService.InputBegan:Connect(function(input)
    local d = keyBindings[input.KeyCode]
    if d then dir = d end
end)

UserInputService.InputEnded:Connect(function(input)
    if keyBindings[input.KeyCode] == dir then dir = 0 end
end)

local vehiclesFolder = workspace:FindFirstChild("Vehicles")
if not vehiclesFolder then
    vehiclesFolder = workspace.ChildAdded:Wait()
    while vehiclesFolder.Name ~= "Vehicles" do
        vehiclesFolder = workspace.ChildAdded:Wait()
    end
end

local vehicleList = {}
vehiclesFolder.ChildAdded:Connect(function(child)
    if child:IsA("Model") then table.insert(vehicleList, child) end
end)

vehiclesFolder.ChildRemoved:Connect(function(child)
    for i,v in ipairs(vehicleList) do
        if v == child then table.remove(vehicleList,i); break end
    end
end)

RunService.Heartbeat:Connect(function()
    local primaryPart, lookVec, forceForce

    for _, vehicle in ipairs(vehicleList) do
        local engine = vehicle:FindFirstChild("Engine")
        if not engine then continue end

        local force = engine:FindFirstChild("NewForce")
        if not force then
            local orig = engine:FindFirstChildWhichIsA("BodyForce") or
                         engine:FindFirstChildWhichIsA("VectorForce")
            if orig then
                force = orig:Clone()
                force.Name = "NewForce"
                force.Parent = engine
            end
        end
        if not force then continue end

        primaryPart = vehicle.PrimaryPart
        if not primaryPart then continue end
        lookVec = primaryPart.CFrame.LookVector

        local multiplier =
            (vehicle.Name:lower():find("bike") and BIKE_FORCE_MULTIPLIER) or
            (vehicle.Name:lower():find("bugg") and BUGGY_FORCE_MULTIPLIER) or
            DEFAULT_FORCE_MULTIPLIER

        forceForce = Vector3.new(lookVec.X, 0, lookVec.Z)
                      * FORCE_MULTIPLIER * dir * multiplier
        force.Force = forceForce
    end
end)
