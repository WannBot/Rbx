-- Final Robust Debug / GodMode + Magnet + Movement (Rayfield)
-- Paste ke executor dan run.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- safe load Rayfield (fallback minimal UI if fail)
local Rayfield
local success, rf = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if success and rf then
    Rayfield = rf
else
    warn("Rayfield load failed, creating minimal fallback UI (text output).")
end

-- minimal UI fallback (console prints) if Rayfield not available
local Window, MainTab, StatusLabel
if Rayfield then
    Window = Rayfield:CreateWindow({
        Name = "Debug Menu (Robust)",
        LoadingTitle = "Init",
        LoadingSubtitle = "Robust God+Magnet",
        KeySystem = false,
    })
    MainTab = Window:CreateTab("Main", 4483362458)
    StatusLabel = MainTab:CreateParagraph({Title="Status", Content="Initializing..."})
else
    print("[DebugMenu] Rayfield unavailable. UI disabled; using console logs.")
end

-- state
local state = {
    god = false,
    magnet = false,
    magnetRange = 1000,
    walkSpeed = 16,
    jumpPower = 50,
    ff = nil, -- forcefield instance
}

-- helpers to update UI status
local function updateStatus()
    local text = ("God:%s | Magnet:%s (%.0f) | Speed:%.0f | Jump:%.0f")
        :format(tostring(state.god), tostring(state.magnet), state.magnetRange, state.walkSpeed, state.jumpPower)
    if StatusLabel then
        StatusLabel:Update({Title="Status", Content = text})
    else
        print("[DebugMenu Status] "..text)
    end
end

-- ensure character/humanoid available
local function waitForChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hrp then hrp = char:WaitForChild("HumanoidRootPart", 5) end
    if not hum then hum = char:WaitForChild("Humanoid", 5) end
    return char, hum, hrp
end

-- store current connections to cleanup / rebind
local conns = {}
local function clearConns()
    for _, c in ipairs(conns) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        elseif c and type(c) == "function" then
            -- ignore
        end
    end
    conns = {}
end

-- create invisible forcefield if not present
local function ensureForceField(char)
    if not char then return end
    if state.ff and state.ff.Parent == char then return end
    if state.ff and state.ff.Parent then
        pcall(function() state.ff:Destroy() end)
    end
    local ok, ff = pcall(function()
        local f = Instance.new("ForceField")
        f.Visible = false
        f.Parent = char
        return f
    end)
    if ok then state.ff = ff end
end

-- try to patch TakeDamage (may or may not work depending on environment)
local function tryPatchTakeDamage(hum)
    if not hum then return end
    pcall(function()
        -- some exploit environments allow rebinding methods on instances
        hum.TakeDamage = function() end
    end)
end

-- lock health hard: sets MaxHealth, Health each frame and on changed
local function bindGod(hum, char)
    -- cleanup previous if any
    clearConns()

    -- immediate actions
    pcall(function()
        hum.MaxHealth = math.huge
        hum.Health = hum.MaxHealth
    end)
    ensureForceField(char)
    tryPatchTakeDamage(hum)

    -- disable some dangerous states (but avoid disabling Physics which may freeze)
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) -- safe attempt
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        -- do NOT disable Physics here (causes freeze on many maps)
    end)

    -- HealthChanged listener (fast reaction)
    local hc = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if state.god then
            -- immediate restore
            pcall(function()
                if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
                hum.Health = hum.MaxHealth
            end)
        end
    end)
    table.insert(conns, hc)

    -- also listen to HealthChanged event (some games use that)
    local ev
    if hum.HealthChanged then
        ev = hum.HealthChanged:Connect(function(hp)
            if state.god then
                pcall(function()
                    if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
                    hum.Health = hum.MaxHealth
                end)
            end
        end)
        table.insert(conns, ev)
    end

    -- heartbeat brute lock (frame rate)
    local hb = RunService.Heartbeat:Connect(function()
        if not state.god then return end
        if not hum or not hum.Parent then return end
        -- enforce Infinity MaxHealth & Health
        pcall(function()
            if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
            if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
            -- small anti-fall assistance: if falling very fast, zero vertical velocity a bit
            local hrp = hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.AssemblyLinearVelocity
                if vel and vel.Y < -200 then
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, -40, vel.Z)
                end
            end
        end)
    end)
    table.insert(conns, hb)

    -- prevent joins destroyed: monitor BreakJoints maybe
    local cj = hum.AncestryChanged:Connect(function()
        if not hum.Parent and state.god then
            -- attempt immediate respawn hack (best-effort)
            pcall(function() player:LoadCharacter() end)
        end
    end)
    table.insert(conns, cj)
end

-- disable god bindings / cleanup
local function unbindGod()
    clearConns()
    if state.ff and state.ff.Parent then
        pcall(function() state.ff:Destroy() end)
        state.ff = nil
    end
end

-- Magnet collect: pull HitBox parts in folder workspace.LEGO%/GoldStuds
local function magnetLoop()
    local ok, err = pcall(function()
        local lego = workspace:FindFirstChild("LEGO%")
        if not lego then return end
        local gold = lego:FindFirstChild("GoldStuds")
        if not gold then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, model in ipairs(gold:GetChildren()) do
            local hitbox = model:FindFirstChild("HitBox")
            if hitbox and hitbox:IsA("BasePart") then
                local dist = (hitbox.Position - hrp.Position).Magnitude
                if dist <= state.magnetRange then
                    -- move toward HRP gently
                    pcall(function()
                        hitbox.CFrame = hrp.CFrame + Vector3.new(0, -2, 0)
                    end)
                end
            end
        end
    end)
    if not ok then
        warn("[Magnet] error: "..tostring(err))
    end
end

-- safe recurring runner
local runnerConnection
runnerConnection = RunService.Heartbeat:Connect(function()
    -- magnet
    if state.magnet then
        pcall(magnetLoop)
    end
    -- ensure movement values applied each frame
    if player.Character and player.Character.Parent then
        local hum = player.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then
            if hum.WalkSpeed ~= state.walkSpeed then
                pcall(function() hum.WalkSpeed = state.walkSpeed end)
            end
            if hum.JumpPower ~= state.jumpPower then
                pcall(function() hum.JumpPower = state.jumpPower end)
            end
        end
    end
end)

-- main toggles (and UI wiring)
if Rayfield then
    -- GOD toggle
    MainTab:CreateToggle({
        Name = "Absolute Hardcore God",
        CurrentValue = false,
        Callback = function(val)
            state.god = val
            updateStatus()
            if state.god then
                -- rebind on current char
                local ok, char, hum, hrp = pcall(waitForChar)
                if ok and hum and char then
                    bindGod(hum, char)
                else
                    -- wait for character then bind
                    player.CharacterAdded:Connect(function(c)
                        pcall(function()
                            local _, h = waitForChar()
                            if state.god then bindGod(h, c) end
                        end)
                    end)
                end
            else
                unbindGod()
            end
        end,
    })

    -- Magnet toggle + range
    MainTab:CreateToggle({
        Name = "Magnet Collect",
        CurrentValue = state.magnet,
        Callback = function(v)
            state.magnet = v
            updateStatus()
        end
    })
    MainTab:CreateSlider({
        Name = "Magnet Range",
        Range = {100, 3000},
        Increment = 50,
        Suffix = "stud",
        CurrentValue = state.magnetRange,
        Callback = function(val)
            state.magnetRange = val
            updateStatus()
        end
    })

    -- Speed / Jump
    MainTab:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 300},
        Increment = 1,
        CurrentValue = state.walkSpeed,
        Callback = function(v)
            state.walkSpeed = v
            updateStatus()
        end
    })
    MainTab:CreateSlider({
        Name = "JumpPower",
        Range = {50, 500},
        Increment = 5,
        CurrentValue = state.jumpPower,
        Callback = function(v)
            state.jumpPower = v
            updateStatus()
        end
    })

    -- status paragraph already created
    updateStatus()
else
    -- fallback simple console commands
    print("UI unavailable. Use these commands to toggle in console:")
    print("set god: setGod(true/false)  -- enable / disable")
    print("set magnet: setMagnet(true/false)")
    print("set magnetRange: setMagnetRange(number)")
    -- expose simple functions
    _G.setGod = function(b)
        state.god = b and true or false
        if state.god then
            local ok, char, hum = pcall(waitForChar)
            if ok and hum then bindGod(hum, char) end
        else
            unbindGod()
        end
        updateStatus()
    end
    _G.setMagnet = function(b)
        state.magnet = b and true or false
        updateStatus()
    end
    _G.setMagnetRange = function(n)
        state.magnetRange = tonumber(n) or state.magnetRange
        updateStatus()
    end
    updateStatus()
end

-- ensure rebind on respawn if god active
player.CharacterAdded:Connect(function(char)
    task.delay(0.15, function()
        if state.god then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if not hum then hum = char:WaitForChild("Humanoid", 5) end
            if hum then
                -- cleanup previous and rebind to new hum
                unbindGod()
                bindGod(hum, char)
            end
        end
    end)
end)

-- final log
print("[DebugMenu] initialized. Use UI to toggle features. If feature seems inactive, check executor output for errors.")
