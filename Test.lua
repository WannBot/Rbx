-- Tambahan Tab untuk Command
local CommandTab = Window:CreateTab("Command", 4483362458)

-- Info label di tab command
CommandTab:CreateParagraph({
    Title = "Command System",
    Content = "Gunakan prefix '.' di chat. Contoh: .goto username\nPerintah tersedia: .goto <username>, .ff [on/off], .help"
})

-- Handler chat command
local PREFIX = "."

local function findPlayerByNameFragment(fragment)
    fragment = tostring(fragment):lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        local uname = plr.Name:lower()
        if uname:sub(1, #fragment) == fragment or uname:find(fragment, 1, true) then
            return plr
        end
    end
    return nil
end

local function gotoPlayer(user)
    local target = findPlayerByNameFragment(user)
    if not target or not target.Character then
        warn("[GOTO] Player tidak ditemukan: " .. user)
        return
    end
    local _, _, myHrp = getCharHum()
    local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
    if tHrp then
        myHrp.CFrame = tHrp.CFrame + Vector3.new(0,3,0)
    end
end

player.Chatted:Connect(function(msg)
    if msg:sub(1,1) ~= PREFIX then return end
    local args = {}
    for token in msg:gmatch("%S+") do table.insert(args, token) end
    local cmd = (args[1] or ""):sub(2):lower()

    if cmd == "goto" and args[2] then
        gotoPlayer(args[2])
    elseif cmd == "ff" then
        ffOn = not ffOn
        local char = player.Character
        if char then
            if ffOn then protect(char) else unprotect() end
        end
    elseif cmd == "help" then
        warn("Commands: .goto <username> | .ff [on/off] | .help")
    else
        warn("Command tidak dikenal: " .. cmd)
    end
end)
