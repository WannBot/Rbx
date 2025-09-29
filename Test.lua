-- ============== Auto Walk Recorder (Rayfield) ==============
-- Fitur: Record/Play, Speed, Save/Load JSON (permanen), Rename, Delete, Refresh UI, Respawn-safe
-- Catatan: butuh executor yang mendukung isfile, writefile, readfile, makefolder, isfolder.

-- Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local HttpService = game:GetService("HttpService")

-- -------- Settings & State --------
local DIR_NAME = "AutoWalk"                             -- folder khusus
local FILE_PATH = DIR_NAME .. "/AutoWalkPaths.json"     -- file save
local RECORD_INTERVAL = 0.5                             -- detik
local DEFAULT_WALKSPEED = 16

local recordedPath = {}
local savedPaths = {}       -- selalu disimpan di memory sebagai list Vector3
local recording = false
local speedMultiplier = 1.0

local player = game.Players.LocalPlayer
local character, humanoid, root

-- -------- Bind character setiap respawn --------
local function bindCharacter(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
end
bindCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(bindCharacter)

-- -------- Util: cek & siapkan filesystem executor --------
local function fsSupported()
    return (typeof(isfile) == "function" or isfile)
       and (typeof(writefile) == "function" or writefile)
       and (typeof(readfile) == "function" or readfile)
end

local function ensureFolder()
    if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
        if not isfolder(DIR_NAME) then
            local ok, err = pcall(makefolder, DIR_NAME)
            if not ok then
                Rayfield:Notify({Title="Folder Error", Content=tostring(err), Duration=5})
            end
        end
    end
end

-- -------- Encode/Decode Vector3 untuk JSON --------
local function encodePathToJSONList(pathVec3)
    local out = table.create(#pathVec3)
    for i,v in ipairs(pathVec3) do
        out[i] = {x = v.X, y = v.Y, z = v.Z}
    end
    return out
end

local function decodePathFromJSONList(jsonList)
    local out = {}
    for _,t in ipairs(jsonList) do
        if typeof(t) == "table" and t.x and t.y and t.z then
            table.insert(out, Vector3.new(t.x, t.y, t.z))
        end
    end
    return out
end

local function encodeAllSaves(tbl)
    local res = {}
    for name, path in pairs(tbl) do
        res[name] = encodePathToJSONList(path)
    end
    return res
end

local function decodeAllSaves(tbl)
    local res = {}
    for name, jsonList in pairs(tbl) do
        res[name] = decodePathFromJSONList(jsonList)
    end
    return res
end

-- -------- Save/Load File dengan pcall & notifikasi error --------
local function saveToFile()
    if not fsSupported() then
        Rayfield:Notify({Title="Save Unsupported", Content="Executor tidak mendukung writefile/readfile.", Duration=5})
        return
    end
    ensureFolder()
    local ok, err = pcall(function()
        local encoded = encodeAllSaves(savedPaths)
        writefile(FILE_PATH, HttpService:JSONEncode(encoded))
    end)
    if not ok then
        Rayfield:Notify({Title="Save Error", Content=tostring(err), Duration=6})
    end
end

local function loadFromFile()
    if not fsSupported() then return end
    if typeof(isfile) == "function" and not isfile(FILE_PATH) then return end
    local okRead, data = pcall(readfile, FILE_PATH)
    if not okRead then
        Rayfield:Notify({Title="Load Error", Content=tostring(data), Duration=6})
        return
    end
    local okJSON, decoded = pcall(function()
        return HttpService:JSONDecode(data)
    end)
    if not okJSON or typeof(decoded) ~= "table" then
        Rayfield:Notify({Title="Load Error", Content="File JSON rusak atau kosong.", Duration=6})
        return
    end
    savedPaths = decodeAllSaves(decoded)
end

loadFromFile()

-- -------- Playback utility --------
local function playPath(path)
    if not humanoid or not path or #path == 0 then return end
    local oldSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = DEFAULT_WALKSPEED * speedMultiplier
    for _,pos in ipairs(path) do
        if not humanoid or humanoid.Parent == nil then break end
        humanoid:MoveTo(pos)
        humanoid.MoveToFinished:Wait()
    end
    if humanoid then
        humanoid.WalkSpeed = oldSpeed or DEFAULT_WALKSPEED
    end
end

-- ==============================================================
--                       RAYFIELD UI
-- ==============================================================
local Window = Rayfield:CreateWindow({
    Name = "Auto Walk Recorder",
    LoadingTitle = "Recorder",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = { Enabled = false }
})

local MainTab  = Window:CreateTab("Main", 4483362458)
local SavesTab = Window:CreateTab("Saves", 4483362458)

-- Kita simpan referensi elemen UI yang dibuat agar bisa di-destroy saat refresh
local SavesUI = {}

local function clearSavesUI()
    for _,elem in ipairs(SavesUI) do
        local inst = elem and elem.Instance
        if inst and inst.Destroy then
            pcall(function() inst:Destroy() end)
        end
    end
    table.clear(SavesUI)
end

local function pushUI(obj)
    if obj then table.insert(SavesUI, obj) end
end

local function refreshSavesUI()
    clearSavesUI()
    -- build ulang
    for name, path in pairs(savedPaths) do
        local section = SavesTab:CreateSection(name); pushUI(section)

        local playBtn = SavesTab:CreateButton({
            Name = "Play "..name,
            Callback = function()
                playPath(path)
            end,
        }); pushUI(playBtn)

        local renameInput = SavesTab:CreateInput({
            Name = "Rename "..name,
            PlaceholderText = "Nama baru",
            RemoveTextAfterFocusLost = false,
            Callback = function(newName)
                if newName and newName ~= "" and savedPaths[name] then
                    -- hindari overwrite jika nama sudah ada
                    if savedPaths[newName] then
                        Rayfield:Notify({Title="Rename Gagal", Content="Nama sudah dipakai.", Duration=4})
                        return
                    end
                    savedPaths[newName] = savedPaths[name]
                    savedPaths[name] = nil
                    saveToFile()
                    refreshSavesUI()
                    Rayfield:Notify({Title="Renamed", Content=name.." → "..newName, Duration=3})
                end
            end,
        }); pushUI(renameInput)

        local delBtn = SavesTab:CreateButton({
            Name = "Delete "..name,
            Callback = function()
                savedPaths[name] = nil
                saveToFile()
                refreshSavesUI()
                Rayfield:Notify({Title="Deleted", Content=name.." dihapus", Duration=3})
            end,
        }); pushUI(delBtn)
    end
end

-- -------- Main controls --------
MainTab:CreateButton({
    Name = "Start / Stop Record",
    Callback = function()
        recording = not recording
        if recording then
            recordedPath = {}
            Rayfield:Notify({Title="Recording", Content="Mulai merekam posisi...", Duration=3})
        else
            Rayfield:Notify({Title="Stopped", Content="Rekaman selesai ("..#recordedPath.." titik)", Duration=3})
        end
    end,
})

MainTab:CreateButton({
    Name = "Play Record (Terakhir Direkam)",
    Callback = function()
        playPath(recordedPath)
    end,
})

MainTab:CreateSlider({
    Name = "Speed",
    Range = {0.5, 3},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Callback = function(val)
        speedMultiplier = val
    end
})

MainTab:CreateButton({
    Name = "Save Current Path",
    Callback = function()
        if #recordedPath == 0 then
            Rayfield:Notify({Title="Save Gagal", Content="Belum ada titik yang direkam.", Duration=4})
            return
        end
        local saveName = "Record_"..os.time()
        savedPaths[saveName] = table.clone(recordedPath)  -- clone supaya rekaman berikutnya tidak mengubah data yang sudah disave
        saveToFile()
        refreshSavesUI()
        Rayfield:Notify({Title="Saved", Content="Path tersimpan: "..saveName, Duration=4})
    end
})

-- -------- Loop rekam (posisi tiap RECORD_INTERVAL detik) --------
task.spawn(function()
    while true do
        task.wait(RECORD_INTERVAL)
        if recording and root then
            table.insert(recordedPath, root.Position)
        end
    end
end)

-- Build UI awal dari file
refreshSavesUI()

-- Info lokasi file (opsional)
MainTab:CreateButton({
    Name = "Info Lokasi File",
    Callback = function()
        local hint = "File di penyimpanan executor.\nAndroid: Android/data/<nama_app_executor>/files/"..FILE_PATH.."\nWindows: folder executor (workspace/scripts)."
        Rayfield:Notify({Title="Lokasi Save", Content=hint, Duration=8})
    end
})
