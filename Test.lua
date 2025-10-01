-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

-- Buat Window
local Window = Rayfield:CreateWindow({
   Name = "Rayfield Example Window",
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by Sirius",
   Theme = "Default",
   ShowText = "Rayfield",
   ToggleUIKeybind = "K",
})

-- Buat Tab Settings
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Mapping Theme Name ke Identifier
local Themes = {
   ["Default"] = "Default",
   ["Amber Glow"] = "AmberGlow",
   ["Amethyst"] = "Amethyst",
   ["Bloom"] = "Bloom",
   ["Dark Blue"] = "DarkBlue",
   ["Green"] = "Green",
   ["Light"] = "Light",
   ["Ocean"] = "Ocean",
   ["Serenity"] = "Serenity"
}

-- Dropdown Pilihan Theme
SettingsTab:CreateDropdown({
   Name = "Theme",
   Options = {"Default","Amber Glow","Amethyst","Bloom","Dark Blue","Green","Light","Ocean","Serenity"},
   CurrentOption = "Default",
   Flag = "ThemeDropdown",
   Callback = function(option)
      local themeId = Themes[option]
      if themeId then
         Window:ModifyTheme(themeId)
         Rayfield:Notify({
            Title = "Theme Changed",
            Content = "Now using theme: " .. option,
            Duration = 6.5,
            Image = 4483362458
         })
      end
   end
})

-- Button: SetVisibility(false)
SettingsTab:CreateButton({
   Name = "Hide UI",
   Callback = function()
      Rayfield:SetVisibility(false)
      Rayfield:Notify({
         Title = "UI Hidden",
         Content = "Rayfield interface is now hidden",
         Duration = 4,
         Image = 4483362458
      })
   end
})

-- Button: SetVisibility(true)
SettingsTab:CreateButton({
   Name = "Show UI",
   Callback = function()
      Rayfield:SetVisibility(true)
      Rayfield:Notify({
         Title = "UI Shown",
         Content = "Rayfield interface is now visible",
         Duration = 4,
         Image = 4483362458
      })
   end
})

-- Button: IsVisible()
SettingsTab:CreateButton({
   Name = "Check UI Visible?",
   Callback = function()
      local visible = Rayfield:IsVisible()
      Rayfield:Notify({
         Title = "UI Visibility",
         Content = visible and "UI is currently visible" or "UI is currently hidden",
         Duration = 4,
         Image = 4483362458
      })
   end
})

-- Button: Destroy UI
SettingsTab:CreateButton({
   Name = "Destroy UI",
   Callback = function()
      Rayfield:Destroy()
   end
})
