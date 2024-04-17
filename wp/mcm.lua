local json = require("json")

local mod = RegisterMod("Winston says Hi MCM", 1)

local function getTableIndex(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            return i
        end
    end

    return 0
end

local choices = {
    "Hi There",
    "Greetings",
    "All",
}

mod.name = "Winston says Hi"
mod.settings = {
    voiceline = choices[1],
    oncePerRoom = true,
    volume = 5
}

---Load saved config data
function mod:Load()
    if not mod:HasData() then
        return
    end

    local jsonString = mod:LoadData()
    mod.settings = json.decode(jsonString)
end

---Save config data
function mod:Save()
    local jsonString = json.encode(mod.settings)
    mod:SaveData(jsonString)
end

---Configure the mod menu
function mod:ConfigMenuInit()
    if ModConfigMenu == nil then
        return
    end

    -- Reset if reloading
    ModConfigMenu.RemoveCategory(mod.name)

    -- Load data
    mod:Load()

    -- Main Category
    ModConfigMenu.UpdateCategory(
        mod.name,
        {
            Info = {
                "Settings for the mod that allows Winston to speak",
                "This is truly a Mattman moment"
            }
        }
    )

    -- Setting for when to play sfx
    ModConfigMenu.AddSetting(
        mod.name,
        nil,
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return getTableIndex(choices, mod.settings.voiceline)
            end,
            Minimum = 1,
            Maximum = #choices,
            Display = function()
                return "Voiceline to use: " .. mod.settings.voiceline
            end,
            OnChange = function(n)
                mod.settings.voiceline = choices[n]
            end,
            -- Text in the "Info" section will automatically word-wrap, unlike in the main section above
            Info = { "Which voiceline to play when Winston appears. 'All' plays a sound at random" }
        }
    )

    -- Setting for when to play sfx
    ModConfigMenu.AddSetting(
        mod.name,
        nil,
        {
            Type = ModConfigMenu.OptionType.BOOLEAN,
            CurrentSetting = function()
                return mod.settings.oncePerRoom
            end,
            Display = function()
                return "Only play once: " .. (mod.settings.oncePerRoom and "on" or "off")
            end,
            OnChange = function (b)
                mod.settings.oncePerRoom = b
                mod:Save()
            end,
            Info = {
                "Play the sound only the first time you enter a room with",
                "Monkey Paw (Off = Play every time you enter the room)"
            }
        }
    )
    -- Setting for sfx volume
    ModConfigMenu.AddSetting(
        mod.name,
        nil,
        {
            Type = ModConfigMenu.OptionType.SCROLL,
            CurrentSetting = function()
                return mod.settings.volume
            end,
            Display = function()
                return "Volume: $scroll" .. mod.settings.volume
            end,
            OnChange = function (n)
                mod.settings.volume = n
                mod:Save()
            end,
            Info = {
                "Volume the sound will play at"
            }
        }
    )
end

-- Init the config menu
mod:ConfigMenuInit()

return mod