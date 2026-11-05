-- Universal Pat 1.0 by ChloeSpacedOut

--#REGION Config

local config = {

    -- Pat delay between pats when holding the pat button, in ticks.
    patDelay = 3,

    -- If patting non-living entites is enabled.
    patNonLivingEntites = false,

    -- Only whitelisted players will be allowed to pat you if you set doWhitelist to true.
    doWhitelist = false,
    doWhitelistOnSkull = false,
    whitelist = {
        -- example whitelisted players
        -- copy UUID in the figura trust menu or on nameMC
        ["8667ba71-b85a-4004-af54-457a9734eed7"] = true, -- Steve
        ["ec561538-f3fd-461d-aff5-086b22154bce"] = true, -- Alex
    },

    -- Blacklisted players will not be able to pat you.
    blacklist = {
        -- example blacklisted players
        -- copy UUID in the figura trust menu or on nameMC
        ["f84c6a79-0a4e-45e0-879b-cd49ebd4c4e2"] = true, -- Herobrine
        ["069a79f4-44e9-4726-a5be-fca90e38aaf5"] = true, -- Notch
    },

    -- Disables pats from EVERYONE if a blacklisted player is within specified number of blocks. Set to -1 for unlimited range, set to 0 to disable.
    blacklistDisableDistance = 0,

    patControls = {
        -- Which mouse buttons can be used to pat.
        mouseButtons = {
            patOnMouseLeft = false,
            patOnMouseRight = true,
            patOnMouseMiddle = false,
            patOnMouseBack = false,
            patOnMouseForward = false,
            patOnMouse6 = false,
            patOnMouse7 = false,
            patOnMouse8 = false,
        },

        -- Which additional keys must be pressed to pat. Will be impossible to pat if all are false.
        additionalKeys = {
            patOnShift = true,
            patOnCtrl = false,
            patOnAlt = false,
            patOnSuper = false,
        },

        -- If an additional key must be pressed to pat.
        requiredAdditionalKeys = true,

        -- If all specified additional keys must be pressed to pat.
        mustPressAllAdditionalKeys = true,
    },

    -- Config for self pat, useful in debugging your own pat function.
    selfPatControls = {
        -- Which additional keys must be pressed to self pat. Will be impossible to self pat if all are false.
        additionalKeys = {
            patOnShift = false,
            patOnCtrl = true,
            patOnAlt = true,
            patOnSuper = false,
        },

        -- If all specified additional keys must be pressed to self pat.
        mustPressAllAdditionalKeys = true,
    }

}

-- USER DEFINED PAT FUNCTION.
---@param senderId string The unique ID of the sender.
function config.onPat(senderId)
    local heartSpread = 0.5
    local particleScale = 1
    local particle = "minecraft:heart"

    local pos = player:getPos()
    local randomHeartOffset = vec((math.random() - 0.5) * heartSpread, (math.random() - 0.5) * heartSpread, (math.random() - 0.5) * heartSpread)
    local petParticle = particles:newParticle(particle, pos + vec(0, player:getEyeHeight(), 0) + randomHeartOffset)
    petParticle:scale(particleScale)
end

-- Lookup table for skup patting, feel free to remove if you don't use this.
local wallHeadLookup = {
    north = vec(0, 0.25, 0.25),
    east = vec(-0.25, 0.25, 0),
    south = vec(0, 0.25, -0.25),
    west = vec(0.25, 0.25, 0)
}

-- USER DEFINED PAT FUNCTION FOR HEADS.
---@param senderId string The unique ID of the sender.
---@param pos Vector3 The position of the head.
function config.onPatSkull(senderId, pos)
    local posOffset = vec(0,0,0)
    local block = world.getBlockState(pos)
    if block and block.id and block.id == "minecraft:player_wall_head"then
        local properties = block:getProperties()
        if properties and properties.facing then
            posOffset = wallHeadLookup[properties.facing]
        end
    end

    local heartSpread = 0.4
    local particleScale = 1
    local particle = "minecraft:heart"
    local playNoteBlockSound = true

    local randomHeartOffset = vec((math.random() - 0.5) * heartSpread, (math.random() - 0.5) * heartSpread, (math.random() - 0.5) * heartSpread)
    local petParticle = particles:newParticle(particle, pos + vec(0.5, 0.5, 0.5) + randomHeartOffset + posOffset)
    petParticle:scale(particleScale)

    local entityData = block:getEntityData()
    if playNoteBlockSound and entityData and entityData["note_block_sound"] then
        sounds:playSound(entityData["note_block_sound"], pos, .5)
    end
end

-- USER DEFINED PAT FUNCTION FOR ENTITYS IN THE WORLD.
---@param entity Entity
function config.onEntityPat(entity)
    local heartSpread = 0.5
    local particleScale = 1
    local particle = "minecraft:heart"
    local playEntitySounds = true

    local pos = entity:getPos()
    local randomHeartOffset = vec((math.random() - 0.5) * heartSpread, (math.random() - 0.5) * heartSpread, (math.random() - 0.5) * heartSpread)
    local petParticle = particles:newParticle(particle, pos + vec(0, entity:getEyeHeight(), 0) + randomHeartOffset)
    petParticle:scale(particleScale)

    if playEntitySounds then
        local entityName = string.lower(entity:getName()):gsub(" ", "_")
        local variant = entity:getNbt().sound_variant
        local pitch = entity:getNbt().Age == -1 and 1.5 or 1
        if variant and variant ~= "minecraft:classic" then
            entityName = entityName .. "_" .. string.match(variant, ":(.*)")
        end
        sounds:playSound("minecraft:entity." .. entityName .. ".ambient", entity:getPos(), .5, pitch)
    end
end

--#ENDREGION

-- Do not edit the script beyond this point unless you know what you're doing!!! --

--#REGION Enums

local enums = {
    mouseButtons = {
        [0] = "patOnMouseLeft",
        [1] = "patOnMouseRight",
        [2] = "patOnMouseMiddle",
        [3] = "patOnMouseBack",
        [4] = "patOnMouseForward",
        [5] = "patOnMouse6",
        [6] = "patOnMouse7",
        [7] = "patOnMouse8",
    }
}

enums.shiftModifiers = {}
for i = 0, 15 do
    enums.shiftModifiers[i] = i % 2 == 1
end

enums.ctrlModifiers = {}
for i = 0, 15 do
    enums.ctrlModifiers[i] = math.floor(i/2) % 2 == 1
end

enums.altModifiers = {}
for i = 0, 15 do
    enums.altModifiers[i] = math.floor(i/4) % 2 == 1
end

enums.superModifiers = {}
for i = 0, 15 do
    enums.superModifiers[i] = math.floor(i/8) % 2 == 1
end

--#ENDREGION

--#REGION Pat Handler

---Safely pcall a function. Discovered by Bitslayn.
---@param func function The function to be safe pcalled.
---@param override boolean? If this pcall should be ignored. For debugging.
---@return boolean hasErrored If the function errored in the pcall.
local function safePcall(func, override)
    if override then
        func()
        return true
    end
    local v = vec(1, 2)
    local hasErrored = pcall(v.applyFunc, v, function(i)
        if i == 1 then
            func()
        end
        return i
    end)
    return hasErrored
end

---Gets the UUID of this head's owner.
---@param blockstate BlockState
---@return string?
local function getHeadOwner(blockstate)
    local blockData = blockstate:getEntityData()
    if not blockData then return end
    if not blockData.SkullOwner then return end
    if not blockData.SkullOwner.Id then return end
    return client.intUUIDToString(table.unpack(blockData.SkullOwner.Id))
end

local isPatting = nil
local punchingPlayers = {}

---@type Pat[]
local patQueue = {}

--#REGION Pat Object

---A pat object.
---@class Pat
---@field senderId string The unique ID of the pat sender.
---@field sender Entity The player who intiated the pat.
---@field pos Vector3? If this pat is for a head, the position of the head.
---@field queueTime integer The world time when this pat was first created.
---@field id integer The numeric ID of this pat.
local pat = {}
pat.__index = pat

---Creates a new pat.
---@param senderId string The unique ID of the pat sender.
---@param pos Vector3? If this pat is for a head, the position of the head.
---@return Pat
function pat:new(senderId, pos)
    self = setmetatable({}, pat)
    self.senderId = senderId
    self.sender = world.getEntity(senderId)
    self.pos = pos
    self.queueTime = world.getTime()
    self.id = #patQueue + 1
    table.insert(patQueue, self)
    return self
end

---Checks if this pat should be activated or removed.
function pat:check()
    if punchingPlayers[self.senderId] then
        punchingPlayers[self.senderId] = nil
        if self.pos then
            config.onPatSkull(self.senderId, self.pos)
        else
            config.onPat(self.senderId)
        end
        self:remove()
        return
    end
    if world.getTime() > (self.queueTime + 4) then
        self:remove()
    end
end

---Removes this pat.
function pat:remove()
    patQueue[self.id] = nil
end

--#ENDREGION

--#REGION Is Rate Limted

---Checks if a pat should be rate limited.
---@return boolean
local function isRateLimted()
    local mostRecentPat = patQueue[#patQueue]
    local worldTime = world.getTime()

    if mostRecentPat and mostRecentPat.queueTime then
        if worldTime < mostRecentPat.queueTime + 2 then
            return true
        end
    end
    return false
end

--#ENDREGION

--#REGION DoPat

---Attempt a pat.
---@param target string | Vector3 The target being pet. Either an entity UUID or a block position.
local function doPat(target)
    local target = target

    if isRateLimted() then return end

    local senderId = avatar:getUUID()
    if type(target) == "string" then
        local entity = world.getEntity(target)
        if not entity:isPlayer() then
            config.onEntityPat(entity)
            host:swingArm()
            isPatting = target
        end
        safePcall(function()
            local targetVars = world.avatarVars()[target]
            local wasSuccessful = targetVars.patpat.player(senderId)
            if wasSuccessful then
                host:swingArm()
                isPatting = target
            end
        end)
    elseif type(target) == "Vector3" then
        local targetBlock = world.getBlockState(target)
        local ownerId = getHeadOwner(targetBlock)
        safePcall(function()
            local targetVars = world.avatarVars()[ownerId]
            local wasSuccessful = targetVars.patpat.skull(senderId, target.x, target.y, target.z)
            if wasSuccessful then
                host:swingArm()
                isPatting = target
            end
        end)
    end
end

--#ENDREGION

--#REGION Tick

local function tick()
    for _, targetPlayer in pairs(world:getPlayers()) do
        local playerId = targetPlayer:getUUID()
        if targetPlayer:getSwingTime() == 1 then
            punchingPlayers[playerId] = world.getTime()
        end
    end
    local currentTime = world.getTime()
    for playerId, punchTime in pairs(punchingPlayers) do
        if currentTime > (punchTime + 4) then
            punchingPlayers[playerId] = nil
        end
    end

    for _, pat in pairs(patQueue) do
        pat:check()
    end

    if player:isLoaded() and world.getTime() % config.patDelay == 0 then
        local targetedEntity = player:getTargetedEntity()
        local targetedBlock = player:getTargetedBlock(false, 5)
        local isTargetingPetPlayer = targetedEntity and targetedEntity:getUUID() == isPatting
        local isTargetingPetSkull = targetedBlock and (tostring(targetedBlock:getPos()) == tostring(isPatting))
        if isPatting and (isTargetingPetPlayer or isTargetingPetSkull)  then
            doPat(isPatting)
        end
    end
end

function events.tick()
    tick()
end

local lastDelta = 0
function events.skull_render(delta)
    if lastDelta == delta then return end
    if lastDelta > delta and (not player:isLoaded()) then
        tick()
    end
    lastDelta = delta
end

--#ENDREGION

--#REGION Is Pat Allowed

---Validates if a pat is from the intended sender.
---@param senderId string The unique ID of the sender.
---@param skullPos Vector3? The position of the skull if it exists.
---@return boolean isValidPat If this pat was valid.
local function isPatAllowed(senderId, skullPos)
    if config.blacklist[senderId] then return false end

    local skull
    if skullPos then
        skull = world.getBlockState(skullPos)
        if not skull then return false end
        local ownerId = getHeadOwner(skull)
        if not ownerId == avatar:getUUID() then return false end
    end

    if config.blacklistDisableDistance ~= 0 then
        for username, targetPlayer in pairs(world:getPlayers()) do
            if config.blacklist[targetPlayer:getUUID()] then
                if config.blacklistDisableDistance == -1 then
                    return false
                elseif player:isLoaded() and ((targetPlayer:getPos() - player:getPos()):length() < config.blacklistDisableDistance) then
                    return false
                elseif skull and ((targetPlayer:getPos() - skull:getPos()):length() < config.blacklistDisableDistance) then
                    return false
                end
            end
        end
    end

    local pattingPlayer = world.getEntity(senderId)
    if not pattingPlayer then return false end
    local pattingPlayerPos = pattingPlayer:getPos()

    if skull then
        if config.doWhitelistOnSkull and (not config.whitelist[senderId]) then return false end
        local pos = skull:getPos()
        local distance = (pattingPlayerPos - pos):length()
        if distance > 5 then return false end

        local pattingPlayerTargetBlock = pattingPlayer:getTargetedBlock(false, 5)
        if not pattingPlayerTargetBlock then return false end
        local ownerId = getHeadOwner(pattingPlayerTargetBlock)
        if not ownerId == avatar:getUUID() then return false end
    elseif player:isLoaded() then
        if config.doWhitelist and (not config.whitelist[senderId]) then return false end
        local pos = player:getPos()
        local distance = (pattingPlayerPos - pos):length()
        if distance > 5 then return false end

        local pattingPlayerTargetEntity = pattingPlayer:getTargetedEntity(5)
        if not pattingPlayerTargetEntity then return false end
        if pattingPlayerTargetEntity:getUUID() ~= avatar:getUUID() then return false end
    else
        return false
    end

    return true
end

--#ENDREGION

--#REGION Pings

function pings.patpat(targetId)
    doPat(targetId)
end

function pings.patHead(pos)
    doPat(pos)
end

function pings.selfPat()
    local uuid = avatar:getUUID()
    config.onPat(uuid)
    host:swingArm()
end

function pings.unpat()
    isPatting = false
end

--#ENDREGION

--#ENDREGION

--#REGION Pat Functions

---Checks the caller of the current function if possible.
---@return string?
local function checkCallerUUID()
    if silly and silly.backports and silly.backports.getCaller then
        return silly.backports:getCaller()
    end
end

local patpat = {}

---Try to pat a player.
---@param senderId string The unique ID of the sender.
---@return boolean wasSuccessful If this pat was successful.
function patpat.player(senderId)
    if isRateLimted() then return false end
    local callerUUID = checkCallerUUID()
    if callerUUID and world.getEntity(callerUUID) then
        senderId = callerUUID
    end
    if not isPatAllowed(senderId) then return false end
    pat:new(senderId)
    return true
end

---Try to pat a player head.
---@param senderId string The unique ID of the sender.
---@param x number X position of the player head.
---@param y number Y position of the player head.
---@param z number Z position of the player head.
---@return boolean wasSuccessful If this pat was successful.
function patpat.skull(senderId, x, y, z)
    if isRateLimted() then return false end
    local callerUUID = checkCallerUUID()
    if callerUUID and world.getEntity(callerUUID) then
        senderId = callerUUID
    end
    local pos = vec(x, y ,z)
    if not isPatAllowed(senderId, pos) then return false end
    pat:new(senderId, pos)
    return true
end

avatar:store("patpat", patpat)

--#ENDREGION

--#REGION Pat Controller

---Check if a modifyer key is pressed, and return if any or all keys have been pressed.
---@param modKeyUsed boolean If this mod key is configured to be used.
---@param modKeyPressed boolean If this mod key is being pressed.
---@param isPressed boolean If any key is being pressed.
---@param areAllPressed boolean If all keys are being pressed.
---@return boolean isPressed If any key is being pressed.
---@return boolean areAllPressed If all keys are being pressed.
local function validateModifier(modKeyUsed, modKeyPressed, isPressed, areAllPressed)
    if modKeyUsed and modKeyPressed then
        return true, areAllPressed
    elseif modKeyUsed and (not modKeyPressed) then
        return isPressed, false
    else
        return isPressed, areAllPressed
    end
end

---Validate if modifer keys are pressed.
---@param modifiers integer The numeric id of pressed modifer keys.
---@param keyConfig table The config of these modifer keys.
---@return boolean
local function validateAllModifiers(modifiers, keyConfig)
    local additionalKeys = keyConfig.additionalKeys
    local isPressed = false
    local areAllPressed = true
    isPressed, areAllPressed = validateModifier(additionalKeys.patOnShift, enums.shiftModifiers[modifiers], isPressed, areAllPressed)
    isPressed, areAllPressed = validateModifier(additionalKeys.patOnCtrl, enums.ctrlModifiers[modifiers], isPressed, areAllPressed)
    isPressed, areAllPressed = validateModifier(additionalKeys.patOnAlt, enums.altModifiers[modifiers], isPressed, areAllPressed)
    isPressed, areAllPressed = validateModifier(additionalKeys.patOnSuper, enums.superModifiers[modifiers], isPressed, areAllPressed)

    if keyConfig.mustPressAllAdditionalKeys then
        return areAllPressed
    else
        return isPressed
    end
end


function events.mouse_press(button, state, modifiers)
    local isModKey = validateAllModifiers(modifiers, config.patControls) or (not config.patControls.requiredAdditionalKeys)
    local isSelfPatModKey = validateAllModifiers(modifiers, config.selfPatControls)
    local isMouseButton = config.patControls.mouseButtons[enums.mouseButtons[button]]
    local isMouseState = state == 1
    if isMouseState and isModKey and isMouseButton then
        local targetEntity = player:getTargetedEntity(5)
        local targetBlock = player:getTargetedBlock(true, 5)
        if targetEntity then
            local targetId = targetEntity:getUUID()
            if not targetEntity:isPlayer() and (config.patNonLivingEntites or targetEntity:isLiving()) then
                pings.patpat(targetId)
                return true
            end
            return safePcall(function()
                local targetVars = world.avatarVars()[targetId]
                if not targetVars.patpat.skull then error() end
                pings.patpat(targetId)
            end)
        elseif targetBlock and (targetBlock.id == "minecraft:player_head" or targetBlock.id == "minecraft:player_wall_head") then
            local ownerId = getHeadOwner(targetBlock)
            return safePcall(function()
                local targetVars = world.avatarVars()[ownerId]
                if not targetVars.patpat.skull then error() end
                pings.patpat(targetBlock:getPos())
            end)
        end
    elseif isSelfPatModKey and isMouseButton and isMouseState then
        pings.selfPat()
    elseif (not isMouseState) and isMouseButton then
        if isPatting then
            pings.unpat()
        end
    end
end

--#ENDREGION