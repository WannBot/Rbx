-- teleport_tab2.lua — Tab Teleport ke-2 (koordinat TERPISAH dari Tab 1)

return function(args)
    local Window     = args.Window
    local getCharHum = args.getCharHum

    -- Konfigurasi Tab 2 (ubah sesukamu)
    local TAB_TITLE      = "Teleport Lokasi 2"
    local OFFSET_Y       = 3
    local DEFAULT_DELAY  = 2
    local POINTS = {
        -- Ganti koordinat khusus Tab 2 di sini:
        Vector3.new(-524.1, 58.6, -163.9),
        Vector3.new(-1083.9, 254.6, -523.5),
        Vector3.new(-1384.3, 399.0, -711.1),
        Vector3.new(-1635.5, 672.7, -1213.5),
        Vector3.new(-2445.9, 1133.2, -1939.4),
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
            Name = ("TP2 %d"):format(i),
            Callback = function() teleportTo(i) end,
        })
    end

    Tab:CreateSection("Auto Loop")
    Tab:CreateToggle({
        Name = "Aktifkan Auto Loop (Tab 2)",
        CurrentValue = false,
        Flag = "AutoLoop2",
        Callback = function(on) if on then startLoop() else stopLoop() end end,
    })
    Tab:CreateSlider({
        Name = "Delay Teleport (detik) [Tab 2]",
        Range = {0.1, 30},
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = DEFAULT_DELAY,
        Flag = "DelayTP2",
        Callback = function(val) currentDelay = clampDelay(val) end,
    })
end
