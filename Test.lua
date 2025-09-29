-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local HttpService = game:GetService("HttpService")

-- Data
local recordedPath = {}
local savedPaths = {}
local recording = false
local playback = false
local speedMultiplier = 1.0
local fileName = "AutoWalkPaths.json"

local player = game.Players.LocalPlayer
local character, humanoid, root

-- Fungsi untuk update character setiap respawn
local function bindCharacter(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
end
bindCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(bindCharacter)

-- Load file jika ada
if isfile(fileName) then
    local data = readfile(fileName)
    savedPaths = HttpService:JSONDecode(data)
end

-- Fungsi encode/decode Vector3
local function encodePath(path)
    local out = {}
    for _,v in ipairs(path) do
        table.insert(out, {x = v.X, y = v.Y, z = v.Z})
    end
    return out
end

local function decodePath(path)
    local out = {}
    for _,v in ipairs(path) do
        if typeof(v) == "table" and v.x and v.y and v.z then
            table.insert(out, Vector3.new(v.x, v.y, v.z))
        end
    end
    return out
end

-- Save file
local function saveToFile()
    local encoded = {}
    for name, path in pairs(savedPaths) do
        encoded[name] = encodePath(path)
    end
    writefile(fileName, HttpService:JSONEncode(encoded))
end

-- Load file decode
local function loadFromFile()
    if not isfile(fileName) then return end
    local data = readfile(fileName)
    local decoded = HttpService:JSONDecode(data)
    local result = {}
    for name, path in pairs(decoded) do
        result[name] = decodePath(path)
    end
    savedPaths = result
end

loadFromFile()

-- Fungsi main playback
local function playPath(path)
    if not path or #path == 0 or not humanoid then return end
    humanoid.WalkSpeed = 16 * speedMultiplier
    for _,pos in ipairs(path) do
        humanoid:MoveTo(pos)
        humanoid.MoveToFinished:Wait()
    end
    humanoid.WalkSpeed = 16
end

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Auto Walk Recorder",
    LoadingTitle = "Recorder",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = false,
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local SavesTab = Window:CreateTab("Saves", 4483362458)

-- Refresh UI
local function refreshSavesUI()
    for _, element in ipairs(SavesTab.Elements) do
        if element.Instance and element.Instance.Destroy then
            element.Instance:Destroy()
        end
    end
    SavesTab.Elements = {}

    for name, path in pairs(savedPaths) do
        local section = SavesTab:CreateSection(name)

        SavesTab:CreateButton({
            Name = "Play "..name,
            Callback = function()
                playPath(path)
            end,
        })

        SavesTab:CreateInput({
            Name = "Rename "..name,
            PlaceholderText = "Nama baru",
            RemoveTextAfterFocusLost = false,
            Callback = function(newName)
                if newName ~= "" and savedPaths[name] then
                    savedPaths[newName] = savedPaths[name]
                    savedPaths[name] = nil
                    saveToFile()
                    refreshSavesUI()
                end
            end,
        })

        SavesTab:CreateButton({
            Name = "Delete "..name,
            Callback = function()
                savedPaths[name] = nil
                saveToFile()
                refreshSavesUI()
            end,
        })
    end
end

-- Tombol Record
MainTab:CreateButton({
    Name = "Start/Stop Record",
    Callback = function()
        recording = not recording
        if recording then
            recordedPath = {}
            Rayfield:Notify({
                Title = "Recording",
                Content = "Mulai merekam...",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Stopped",
                Content = "Rekaman selesai ("..#recordedPath.." titik)",
                Duration = 3
            })
        end
    end,
})

-- Playback record terakhir
MainTab:CreateButton({
    Name = "Play Record",
    Callback = function()
        playPath(recordedPath)
    end,
})

-- Speed slider
MainTab:CreateSlider({
    Name = "Speed",
    Range = {0.5, 3},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Callback = function(Value)
        speedMultiplier = Value
    end,
})

-- Save record permanen
MainTab:CreateButton({
    Name = "Save Current Path",
    Callback = function()
        if #recordedPath == 0 then return end
        local saveName = "Record_"..os.time()
        savedPaths[saveName] = table.clone(recordedPath)
        saveToFile()
        refreshSavesUI()
        Rayfield:Notify({
            Title = "Saved",
            Content = "Path tersimpan: "..saveName,
            Duration = 3
        })
    end,
})

-- Rekam posisi tiap 0.5 detik
task.spawn(function()
    while true do
        task.wait(0.5)
        if recording and root then
            table.insert(recordedPath, root.Position)
        end
    end
end)

-- Build ulang UI dari file
refreshSavesUI()
