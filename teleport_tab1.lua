-- teleport_tab1.lua — Tab Teleport ke-1 (punya koordinat sendiri)

return function(args)
    local Window     = args.Window
    local getCharHum = args.getCharHum

    -- Konfigurasi Tab 1
    local TAB_TITLE      = "Teleport Lokasi 1"
    local OFFSET_Y       = 3
    local DEFAULT_DELAY  = 2
    local POINTS = {
        Vector3.new(388, 310, -185),
        Vector3.new(99, 412, 615),
        Vector3.new(10, 601, 998),
        Vector3.new(871, 865, 583),
        Vector3.new(1622, 1080, 157),
        Vector3.new(2969, 1528, 708),
        Vector3.new(1803, 1982, 2169),
    }

    local function teleportTo(i)
        if i < 1 or i > #POINTS then return end
        local _,_,hrp = getCharHum()
        hrp.CFrame = CFrame.new(POINTS[i] + Vector3.new(0, OFFSET_Y, 0))
    end

    local currentDelay, autoLoop, loopThread = DEFAULT_DELAY, false, nil
    local function clampDelay(x)
        if type(x) ~= "number" or x <= 0 then return DEFAULT_DELAY end
        if x < 0.1 then x = 0.1 end
        if x > 30 then x = 30 end
        return x
    end
    local function startLoop()
        if autoLoop then return end
        autoLoop = true
        loopThread = coroutine.create(function()
            while autoLoop do
                for i = 1, #POINTS do
                    if not autoLoop then break end
                    teleportTo(i)
                    task.wait(currentDelay)
                end
            end
        end)
        coroutine.resume(loopThread)
    end
    local function stopLoop() autoLoop = false end

    local Tab = Window:CreateTab(TAB_TITLE, "map-pin")

    Tab:CreateSection("Manual Teleport")
    for i = 1, #POINTS do
        Tab:CreateButton({
            Name = ("TP1 %d"):format(i),
            Callback = function() teleportTo(i) end,
        })
    end

    Tab:CreateSection("Auto Loop")
    Tab:CreateToggle({
        Name = "Aktifkan Auto Loop (Tab 1)",
        CurrentValue = false,
        Flag = "AutoLoop1",
        Callback = function(on) if on then startLoop() else stopLoop() end end,
    })
    Tab:CreateSlider({
        Name = "Delay Teleport (detik) [Tab 1]",
        Range = {0.1, 30},
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = DEFAULT_DELAY,
        Flag = "DelayTP1",
        Callback = function(val) currentDelay = clampDelay(val) end,
    })
end
