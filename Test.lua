-- di dalam MainTab setelah login
local Humanoid = getHumanoid()
local GodModeEnabled = false
local heartbeatConn, healthConn = nil, nil

MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodModeToggle",
    Callback = function(state)
        GodModeEnabled = state
        if state then
            ------------------------------------------------------
            -- Aktifkan God Mode
            ------------------------------------------------------
            local char = Player.Character or Player.CharacterAdded:Wait()
            Humanoid = char:WaitForChild("Humanoid")

            -- Max Health
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = Humanoid.MaxHealth

            -- ForceField (tidak terlihat)
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = char

            -- Heartbeat check
            heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
                if Humanoid then
                    Humanoid.MaxHealth = math.huge
                    Humanoid.Health = Humanoid.MaxHealth
                    Humanoid.PlatformStand = false -- anti ragdoll jatuh
                end
            end)

            -- HealthChanged listener
            healthConn = Humanoid.HealthChanged:Connect(function()
                if Humanoid and GodModeEnabled then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end)

            -- Tool damage / touched parts
            char.DescendantAdded:Connect(function(obj)
                if GodModeEnabled and obj:IsA("TouchTransmitter") then
                    local part = obj.Parent
                    if part and part:IsA("BasePart") then
                        part.CanTouch = false
                    end
                end
            end)

            -- Terrain anti water/lava/fire
            workspace.Terrain.ChildAdded:Connect(function(child)
                if GodModeEnabled and (child.Name:lower():find("lava") or child.Name:lower():find("fire") or child.Name:lower():find("water")) then
                    child:Destroy()
                end
            end)

        else
            ------------------------------------------------------
            -- Nonaktifkan God Mode
            ------------------------------------------------------
            if heartbeatConn then heartbeatConn:Disconnect() heartbeatConn = nil end
            if healthConn then healthConn:Disconnect() healthConn = nil end

            local char = Player.Character
            if char then
                local ff = char:FindFirstChildOfClass("ForceField")
                if ff then ff:Destroy() end
                if Humanoid then
                    Humanoid.MaxHealth = 100
                    Humanoid.Health = 100
                end
            end
        end
    end
})
