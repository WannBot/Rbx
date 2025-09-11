local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Fly Debug",
    LoadingTitle = "Fly Mobile",
    LoadingSubtitle = "Joystick + Kamera",
    KeySystem = false,
})
local Tab = Window:CreateTab("Fly", 4483362458)

-- === State ===
local flyOn = false
local flySpeed = 60
local hrp, hum, bg, bv

-- === Setup Fly ===
local function setupFly()
    local char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")

    bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp

    -- Loop Fly
    RunService.Heartbeat:Connect(function()
        if flyOn and hrp and hrp.Parent then
            bg.CFrame = workspace.CurrentCamera.CFrame
            local camCF = workspace.CurrentCamera.CFrame
            local moveDir = hum.MoveDirection -- joystick input (X,Z)

            if moveDir.Magnitude > 0 then
                -- gunakan kamera sebagai arah penuh (termasuk Y)
                local dir = (camCF.LookVector * moveDir.Z + camCF.RightVector * moveDir.X).Unit
                bv.Velocity = dir * flySpeed
            else
                bv.Velocity = Vector3.zero
            end
        elseif bv then
            bv.Velocity = Vector3.zero
        end
    end)
end

-- === UI ===
Tab:CreateToggle({
    Name = "Fly ON/OFF",
    CurrentValue = false,
    Callback = function(v)
        flyOn = v
        if flyOn then
            setupFly()
        else
            if bg then bg:Destroy() bg = nil end
            if bv then bv:Destroy() bv = nil end
        end
    end
})

Tab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "spd",
    CurrentValue = flySpeed,
    Callback = function(val)
        flySpeed = val
    end
})
