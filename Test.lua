local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Fly Debug",
    LoadingTitle = "Fly Freecam Style",
    LoadingSubtitle = "Mobile Joystick + Kamera",
    KeySystem = false,
})
local Tab = Window:CreateTab("Fly", 4483362458)

-- === State ===
local flyOn = false
local flySpeed = 60
local hrp, bg, bv
local moveForward = 0

-- === Fungsi Setup ===
local function setupFly()
    local char = player.Character or player.CharacterAdded:Wait()
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

    -- Loop fly
    RunService.Heartbeat:Connect(function()
        if flyOn and hrp and hrp.Parent then
            bg.CFrame = workspace.CurrentCamera.CFrame
            local camCF = workspace.CurrentCamera.CFrame
            if moveForward ~= 0 then
                bv.Velocity = camCF.LookVector * (flySpeed * moveForward)
            else
                bv.Velocity = Vector3.zero
            end
        elseif bv then
            bv.Velocity = Vector3.zero
        end
    end)
end

-- === Input (Analog W/S) ===
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then
        moveForward = 1
    elseif input.KeyCode == Enum.KeyCode.S then
        moveForward = -1
    end
end)
UIS.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
        moveForward = 0
    end
end)

-- === UI Control ===
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
