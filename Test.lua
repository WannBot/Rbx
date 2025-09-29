-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local HttpService = game:GetService("HttpService")

-- Konfigurasi file
local DIR_NAME = "AutoWalk"
local FILE_PATH = DIR_NAME.."/AutoWalkPaths.json"

-- Data
local recordedPath = {}
local savedPaths = {}
local recording = false
local speedMultiplier = 1.0

local player = game.Players.LocalPlayer
local character, humanoid, root

-- Bind ulang setiap respawn
local function bindCharacter(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
end
bindCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(bindCharacter)

-- Encode/decode Vector3 + jump flag
local function encodePath(path)
    local out = {}
    for _,step in ipairs(path) do
        table.insert(out, {x=step.pos.X, y=step.pos.Y, z=step.pos.Z, jump=step.jump})
    end
    return out
end

local function decodePath(tbl)
    local out = {}
    for _,step in ipairs(tbl) do
        if step.x and step.y and step.z then
            table.insert(out, {pos=Vector3.new(step.x, step.y, step.z), jump=step.jump})
        end
    end
    return out
end

-- Save/load file
local function saveToFile()
    local encoded = {}
    for name,path in pairs(savedPaths) do
        encoded[name] = encodePath(path)
    end
    writefile(FILE_PATH, HttpService:JSONEncode(encoded))
end

local function loadFromFile()
    if not isfile(FILE_PATH) then return end
    local decoded = HttpService:JSONDecode(readfile(FILE_PATH))
    local result = {}
    for name,path in pairs(decoded) do
        result[name] = decodePath(path)
    end
    savedPaths = result
end
loadFromFile()

-- Playback
local function playPath(path)
    if not humanoid or not path or #path == 0 then return end
    local oldSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = 16 * speedMultiplier
    for _,step in ipairs(path) do
        if step.jump then humanoid.Jump = true end
        humanoid:MoveTo(step.pos)
        humanoid.MoveToFinished:Wait()
    end
    humanoid.WalkSpeed = oldSpeed
end

-- ============== RAYFIELD UI ==============
local Window = Rayfield:CreateWindow({Name="Auto Walk Recorder"})
local MainTab = Window:CreateTab("Main")
local SavesTab = Window:CreateTab("Saves")

-- Manajemen UI Saves
local SavesUI = {}
local function clearSavesUI()
    for _,elem in ipairs(SavesUI) do
        if elem.Instance and elem.Instance.Destroy then
            elem.Instance:Destroy()
        end
    end
    table.clear(SavesUI)
end
local function pushUI(obj)
    if obj then table.insert(SavesUI, obj) end
end

local function refreshSavesUI()
    clearSavesUI()
    for name,path in pairs(savedPaths) do
        local sec = SavesTab:CreateSection(name); pushUI(sec)

        pushUI(SavesTab:CreateButton({
            Name="Play "..name,
            Callback=function() playPath(path) end
        }))

        pushUI(SavesTab:CreateInput({
            Name="Rename "..name,
            PlaceholderText="Nama baru",
            RemoveTextAfterFocusLost=false,
            Callback=function(newName)
                if newName~="" and not savedPaths[newName] then
                    savedPaths[newName]=path
                    savedPaths[name]=nil
                    saveToFile()
                    refreshSavesUI()
                end
            end
        }))

        pushUI(SavesTab:CreateButton({
            Name="Delete "..name,
            Callback=function()
                savedPaths[name]=nil
                saveToFile()
                refreshSavesUI()
            end
        }))
    end
end

-- Tombol utama
MainTab:CreateButton({
    Name="Start / Stop Record",
    Callback=function()
        recording=not recording
        if recording then
            recordedPath={}
            Rayfield:Notify({Title="Recording", Content="Mulai merekam...", Duration=3})
        else
            Rayfield:Notify({Title="Stopped", Content="Rekaman berhenti ("..#recordedPath.." titik)", Duration=3})
        end
    end
})

MainTab:CreateButton({
    Name="Play Record (Terakhir)",
    Callback=function() playPath(recordedPath) end
})

MainTab:CreateSlider({
    Name="Speed",
    Range={0.5,3},
    Increment=0.1,
    Suffix="x",
    CurrentValue=1,
    Callback=function(v) speedMultiplier=v end
})

MainTab:CreateButton({
    Name="Save Current Path",
    Callback=function()
        if #recordedPath==0 then return end
        local saveName="Record_"..os.time()
        savedPaths[saveName]=table.clone(recordedPath)
        saveToFile()
        refreshSavesUI()
        Rayfield:Notify({Title="Saved", Content="Path tersimpan: "..saveName, Duration=3})
    end
})

-- Rekam posisi + jump tiap 0.5 detik
task.spawn(function()
    while true do
        task.wait(0.5)
        if recording and root and humanoid then
            table.insert(recordedPath,{
                pos=root.Position,
                jump=(humanoid:GetState()==Enum.HumanoidStateType.Jumping)
            })
        end
    end
end)

-- Bangun ulang daftar save dari file
refreshSavesUI()
