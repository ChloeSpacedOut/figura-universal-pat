local config = {

    patDelay = 3,
    patNonLivingEntites = false,

    -- Whitelisted players will be allowed to pat you if you set doWhitelist to true.
    doWhitelist = false,
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

        -- Which additional keys must be pressed to pat.
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
        -- Which additional keys must be pressed to self pat.
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

-- USER DEFINED PAT FUNCTION
function config.onPat(senderId)
    local pos = player:getPos()
    particles:newParticle("minecraft:heart", pos + vec(0, player:getEyeHeight() + .2, 0))
end

-- USER DEFINED PAT FUNCTION
function config.onPatSkull(senderId, pos)
    particles:newParticle("minecraft:heart", pos + vec(0.5, 0.7, 0.5))
end

-- USER DEFINED PAT FUNCTION FOR ENTITYS IN THE WORLD
---comment
---@param entity Entity
function config.onEntityPat(entity)
    local pos = entity:getPos()
    particles:newParticle("minecraft:heart", pos + vec(0, entity:getEyeHeight() + .2, 0))
    
    local entityName = string.lower(entity:getName()):gsub(" ", "_")
    local variant = entity:getNbt().sound_variant
    local pitch = entity:getNbt().Age == -1 and 1.5 or 1
    if variant and variant ~= "minecraft:classic" then
        entityName = entityName .. "_" .. string.match(variant, ":(.*)")
    end
    sounds:playSound("minecraft:entity." .. entityName .. ".ambient", entity:getPos(), .5, pitch)
end

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

local isPatting = nil

local function safePcall(func, override)
    if override then
        func()
        return true
    end
    local v = vec(1, 2)
    local ok = pcall(v.applyFunc, v, function(i)
        if i == 1 then
            func()
        end
        return i
    end)
    return ok
end

local punchingPlayers = {}
local patQueue = {}

local pat = {}
pat.__index = pat

function pat:new(senderId, pos)
    self = setmetatable({}, pat)
    self.senderId = senderId
    self.sender = world.getEntity(senderId)
    self.pos = pos
    self.queueTime = world.getTime()
    self.id = #patQueue + 1
    table.insert(patQueue, self)
end

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

function pat:remove()
    patQueue[self.id] = nil
end

local function doPat(target)
    local senderId = avatar:getUUID()
    if type(target) == "string" then
        local entity = world.getEntity(target)
        if not entity:isPlayer() then
            config.onEntityPat(entity)
            host:swingArm()
            isPatting = target
        end
        local targetVars = world.avatarVars()[target]
        if not targetVars then return end
        if not targetVars.patpat then return end
        if not targetVars.patpat.player then return end
        safePcall(function()
            local wasSuccessful = targetVars.patpat.player(senderId)
            if wasSuccessful then
                host:swingArm()
                isPatting = target
            end
        end, true)
    elseif type(target) == "Vector3" then
        local targetBlock = world.getBlockState(target)
        local blockData = targetBlock:getEntityData()
        if not blockData then return end
        if not blockData.SkullOwner then return end
        if not blockData.SkullOwner.Id then return end
        local ownerId = client.intUUIDToString(table.unpack(blockData.SkullOwner.Id))
        local targetVars = world.avatarVars()[ownerId]
        if not targetVars then return end
        if not targetVars.patpat then return end
        if not targetVars.patpat.skull then return end
        safePcall(function()
            local wasSuccessful = targetVars.patpat.skull(senderId, target.x, target.y, target.z)
            if wasSuccessful then
                host:swingArm()
                isPatting = target
            end
        end, true)
    end


end

function events.tick()
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

    if world.getTime() % config.patDelay == 0 then
        local targetedEntity = player:getTargetedEntity()
        local targetedBlock = player:getTargetedBlock(false, 5)
        local isTargetingPetPlayer = targetedEntity and targetedEntity:getUUID() == isPatting
        local isTargetingPetSkull = targetedBlock and (tostring(targetedBlock:getPos()) == tostring(isPatting))
        if isPatting and (isTargetingPetPlayer or isTargetingPetSkull)  then
            doPat(isPatting)
        end
    end
end

local patpat = {}


local function patValidator(senderId, skullPos)
    if config.doWhitelist and (not config.whitelist[senderId]) then return false end
    if config.blacklist[senderId] then return false end

    local skull
    if skullPos then
        skull = world.getBlockState(skullPos)
        if not skull then return false end
        local blockData = skull:getEntityData()
        if not blockData then return false end
        if not blockData.SkullOwner then return false end
        if not blockData.SkullOwner.Id then return false end
        local ownerId = client.intUUIDToString(table.unpack(blockData.SkullOwner.Id))
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
        local pos = skull:getPos()
        local distance = (pattingPlayerPos - pos):length()
        if distance > 5 then return false end

        local pattingPlayerTargetBlock = pattingPlayer:getTargetedBlock(false, 5)
        if not pattingPlayerTargetBlock then return false end
        local blockData = pattingPlayerTargetBlock:getEntityData()
        if not blockData then return false end
        if not blockData.SkullOwner then return false end
        if not blockData.SkullOwner.Id then return false end
        local ownerId = client.intUUIDToString(table.unpack(blockData.SkullOwner.Id))
        if not ownerId == avatar:getUUID() then return false end
    elseif player:isLoaded() then
        local pos = player:getPos()
        local distance = (pattingPlayerPos - pos):length()
        if distance > 5 then return false end

        local pattingPlayerTargetEntity = pattingPlayer:getTargetedEntity(5)
        if not pattingPlayerTargetEntity then return false end
        if not pattingPlayerTargetEntity:getUUID() == avatar:getUUID() then return false end
    else
        return false
    end

    return true
end

function patpat.player(senderId)
    local isAllowed = patValidator(senderId)
    if not isAllowed then return false end
    pat:new(senderId)
    return true
end

function patpat.skull(senderId, x, y, z)
    local pos = vec(x, y ,z)
    local isAllowed = patValidator(senderId, pos)
    if not isAllowed then return false end
    pat:new(senderId, pos)
    return true
end


avatar:store("patpat", patpat)

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

local function validateModifier(modKeyUsed, modKeyPressed, isPressed, areAllPressed)
    if modKeyUsed and modKeyPressed then
        return true, areAllPressed
    elseif modKeyUsed and (not modKeyPressed) then
        return isPressed, false
    else
        return isPressed, areAllPressed
    end
end

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
            local targetVars = world.avatarVars()[targetId]
            if not targetVars then return end
            if not targetVars.patpat then return end
            if not targetVars.patpat.player then return end
            pings.patpat(targetId)
            return true
        elseif targetBlock and targetBlock.id == "minecraft:player_head" then
            local blockData = targetBlock:getEntityData()
            if not blockData then return end
            if not blockData.SkullOwner then return end
            if not blockData.SkullOwner.Id then return end
            local ownerId = client.intUUIDToString(table.unpack(blockData.SkullOwner.Id))
            local targetVars = world.avatarVars()[ownerId]
            if not targetVars then return end
            if not targetVars.patpat then return end
            if not targetVars.patpat.skull then return end
            pings.patpat(targetBlock:getPos())
            return true
        end
    elseif isSelfPatModKey and isMouseButton and isMouseState then
        pings.selfPat()
    elseif (not isMouseState) and isMouseButton then
        if isPatting then
            pings.unpat()
        end
    end


end