local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Fly Debug",
    LoadingTitle = "Fly Controller",
    LoadingSubtitle = "Mobile Friendly",
    KeySystem = false,
})
local Tab = Window:CreateTab("Fly", 4483362458)

-- === State ===
local flyOn = false
local flySpeed = 50
local hrp, bg, bv
local control = {F=0,B=0,L=0,R=0,U=0,D=0}

-- === Input Handler ===
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then control.F = 1 end
    if input.KeyCode == Enum.KeyCode.S then control.B = -1 end
    if input.KeyCode == Enum.KeyCode.A then control.L = -1 end
    if input.KeyCode == Enum.KeyCode.D then control.R = 1 end
    if input.KeyCode == Enum.KeyCode.Space then control.U = 1 end
    if input.KeyCode == Enum.KeyCode.LeftControl then control.D = -1 end
end)
UIS.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.W then control.F = 0 end
    if input.KeyCode == Enum.KeyCode.S then control.B = 0 end
    if input.KeyCode == Enum.KeyCode.A then control.L = 0 end
    if input.KeyCode == Enum.KeyCode.D then control.R = 0 end
    if input.KeyCode == Enum.KeyCode.Space then control.U = 0 end
    if input.KeyCode == Enum.KeyCode.LeftControl then control.D = 0 end
end)

-- === Fly System ===
local function startFly()
    local char = player.Character or player.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")

    -- Buat BodyGyro & BodyVelocity
    bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Parent = hrp

    -- Loop Fly
    RunService.Heartbeat:Connect(function()
        if flyOn and hrp and hrp.Parent then
            bg.CFrame = workspace.CurrentCamera.CFrame
            local moveDir = Vector3.new(control.L+control.R, control.U+control.D, control.F+control.B)
            if moveDir.Magnitude > 0 then
                local vel = (
                    workspace.CurrentCamera.CFrame.LookVector * (control.F+control.B)
                    + workspace.CurrentCamera.CFrame.RightVector * (control.L+control.R)
                    + Vector3.new(0, control.U+control.D, 0)
                ).Unit * flySpeed
                bv.Velocity = vel
            else
                bv.Velocity = Vector3.zero
            end
        elseif bv then
            bv.Velocity = Vector3.zero
        end
    end)
end

-- === UI Toggle & Slider ===
Tab:CreateToggle({
    Name = "Fly ON/OFF",
    CurrentValue = false,
    Callback = function(v)
        flyOn = v
        if flyOn then
            startFly()
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
    CurrentValue = 50,
    Callback = function(val)
        flySpeed = val
    end
})
