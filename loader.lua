-- Loader for WannBot/Rbx — pulls rbx.lua and runs it
local BASE = "https://raw.githubusercontent.com/WannBot/Rbx/refs/heads/main/"

local ok, src = pcall(function()
    return game:HttpGet(BASE .. "feature.lua")  -- <== ganti target ke rbx.lua
end)
if not ok then
    warn("[Loader] Failed to fetch feature.lua:", src)
    return
end

local f, err = loadstring(src)
if not f then
    warn("[Loader] Compile error:", err)
    return
end

return f()
