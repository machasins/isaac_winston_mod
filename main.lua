local mod = RegisterMod("Winston's Paw", 1)
local game = Game()

local config = include("wp.mcm")

local sfx = SFXManager()

-- SFX --
local sfxHiThere = Isaac.GetSoundIdByName("macha_hiThere")

local WINSTON_ID = TrinketType.TRINKET_MONKEY_PAW -- ID for Winston

mod.defaultVolume = 6 -- Hi There Volume
mod.sfxStartDelay = 30 -- Delay before voice should start
mod.sfxAppearDelay = 45 -- Delay to account for spawn animation
mod.sfxQueue = {} -- The queue of sfx to be played
mod.roomsSfxPlayed = {} -- Rooms the sfx has been played in
mod.currentRoom = game:GetLevel():GetCurrentRoomDesc().SafeGridIndex -- The current room

---Check for Winston within the room and play the sound if it's found
function mod:CheckForWinston()
    -- Config volume
    local volumeMod = (config.settings.volume) / 5

    -- Check for Winston in the room
    local trinketCount = Isaac.CountEntities(nil, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, WINSTON_ID)
    -- How many Winston were in the room when last entered
    local previous = mod.roomsSfxPlayed[mod.currentRoom]

    -- Proceed if the room previously has no Winston but now has Winston
    -- OR if the number of Winston has increased since last entered
    if (previous == nil and trinketCount > 0) or (previous ~= nil and trinketCount > previous) then
        -- Get all Winstons
        local trinkets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, WINSTON_ID, true)
        -- Check if any Winstons are currently appearing
        local doDelay = false
        for _, t in pairs(trinkets) do
            doDelay = t:GetSprite():GetAnimation() == "Appear" or doDelay
        end
        -- Keep track of new number of Winstons in the room
        mod.roomsSfxPlayed[mod.currentRoom] = trinketCount
        -- Get current time, in frames
        local currentFrame = Isaac.GetFrameCount()
        -- Queue the Hi There sfx
        mod.sfxQueue[1] = { currentFrame + mod.sfxStartDelay + (doDelay and mod.sfxAppearDelay or 0),
            function() sfx:Play(sfxHiThere, mod.defaultVolume * volumeMod, 2, false, 1, 0) end }
    end

    if previous ~= nil and trinketCount < previous then
        mod.roomsSfxPlayed[mod.currentRoom] = trinketCount
    end
end

---Play queued sounds after a delay
function mod:PlaySFX()
    -- Get the current time, in frames
    local currentFrame = Isaac.GetFrameCount()
    -- Loop through the queue
    for i, s in pairs(mod.sfxQueue) do
        -- If the effect exists and the time to play it is here,
        if s ~= nil and currentFrame >= s[1] then
            -- Call the callback to play the sfx
            s[2]()
            -- Remove sfx from queue
            mod.sfxQueue[i] = nil
        end
    end
end

---Get room number when entering new room
function mod:OnNewRoom()
    -- Config for playing every time you enter a room
    if not config.settings.oncePerRoom then
        -- If config not set, disregard what was in the previous room
        mod.roomsSfxPlayed[mod.currentRoom] = nil
    end
    -- Get the new room number
    mod.currentRoom = game:GetLevel():GetCurrentRoomDesc().SafeGridIndex
end

---Clear any room data from a previous floor
function mod:OnNewLevel()
    mod.roomsSfxPlayed = {}
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.PlaySFX)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.CheckForWinston)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.OnNewRoom)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.OnNewLevel)