AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("config.lua")

hook.Add("StartCommand", "disable-682-crouch-jump", function(client, command)
    -- If they are 682
    if client:HasWeapon("scp682") then
        --Remove the ability to crouch & jump.
        command:RemoveKey(IN_DUCK)
        command:RemoveKey(IN_JUMP)
    end
end)

hook.Add("PlayerDeath","682-death",function(victim, _, _)
    if victim:HasWeapon("scp682") then
        victim:SetModelScale(1) -- Reset model size when player dies with 682 SWEP
    end
end)

hook.Add("PlayerFootstep","682-steps",function(client, position, foot, _, _, recipientFilter)
    if not client:HasWeapon("scp682") then return false end -- Do nothing if player doesn't have 682 SWEP
    local weapon = client:GetWeapon("scp682")

    local soundName = weapon.StepSounds[foot+1] -- +1 because Lua indexes by 1 not 0
    EmitSound(soundName,position,0,CHAN_AUTO,1,75,0,100,0,recipientFilter)
    return true -- Don't play default step sound
end)

hook.Add("PlayerHurt","682-hurt",function(victim, _, _, damageTaken)
    if victim:HasWeapon("scp682") then
        local RFReduction = damageTaken * RF_DAMAGE_PENALTY_MULT
        local weapon = victim:GetWeapon("scp682")
        weapon:ChangeBodymass(-RFReduction)
    end
end)

function DisablePickup(client,_)
    return not client:HasWeapon("scp682")
end

hook.Add("PlayerCanPickupWeapon","disable-weapon-pickup-682",DisablePickup)
hook.Add("PlayerCanPickupItem","disable-item-pickup-682",DisablePickup)

-- This function acts like a basic magnitude-based hitbox
function GetTargetsInRange(position,range)
    local targets = {}
    for _,entity in ents.Iterator() do
        if not entity:IsValid() then continue end -- Ignore null entities
        if not (entity:IsPlayer() or entity:IsNPC()) then continue end -- Only target Player/NPC entities
        if entity:Health() <= 0 then continue end -- Ignore dead entities

        local distance = entity:GetPos():Distance(position) -- Calculate their distance
        if distance <= range then -- If it is within the threshold
            table.insert(targets, entity) -- Add them to the targets table
        end
    end
    return targets -- Return the targets
end

function SWEP:ChangeBodymass(amount)
    self:SetNWFloat("RF",math.Clamp(self:GetNWFloat("RF") + amount, RF_MIN, RF_MAX))

    local owner = self:GetOwner()
    owner:SetMaxHealth(MAXHEALTH * self:GetNWFloat("RF"))
    owner:SetModelScale(MODEL_SCALE_MIN + math.min(self:GetNWFloat("RF") * (MODEL_SCALE_MAX - MODEL_SCALE_MIN), (MODEL_SCALE_MAX - MODEL_SCALE_MIN)), 0.1)
end

function SWEP:Equip()
    self:SetNWFloat("RF",1)

    local owner = self:GetOwner()
    owner:SetWalkSpeed(WALKSPEED) -- Set player speeds
    owner:SetRunSpeed(RUNSPEED)
    
    -- Removes all other weapons
    for _,weapon in pairs(owner:GetWeapons()) do
        if weapon == self then continue end -- Skip the weapon itself
        owner:StripWeapon(weapon:GetClass()) -- Remove the weapon
    end

    owner:SetModel("models/scp_682/scp_682.mdl")
    self:ChangeBodymass(0) -- Update maxhealth and model scale

    owner:SetHealth(owner:GetMaxHealth()) -- Set health to max

    -- Give the player regen
    timer.Create("682-regen-"..owner:AccountID(), RF_FREQ, -1, function()
        owner:SetHealth(math.min(owner:Health() + owner:GetMaxHealth() * RF_RATE, owner:GetMaxHealth()))
    end)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + PRIMARY_COOLDOWN)

    local owner = self:GetOwner()
    local hitboxPosition = OffsetPositionFromPlayer(owner,PRIMARY_HITBOX_OFFSET)
    local targets = GetTargetsInRange(hitboxPosition,PRIMARY_HITBOX_RANGE)

    for _,target in pairs(targets) do
        if target == owner then continue end
        target:TakeDamage(PRIMARY_DAMAGE, owner, self)
        if target:Health() <= 0 then -- Killed the target
            self:ChangeBodymass(RF_KILL_REWARD)
        end
    end

    if #targets > 0 then
        EmitSound(self.AttackSound,owner:GetPos(),0,CHAN_AUTO,0.35)
    end
end

function SWEP:SecondaryAttack()
    self:SetNextPrimaryFire(CurTime() + ROAR_SELF_STUN)
    self:SetNextSecondaryFire(CurTime() + SECONDARY_COOLDOWN)

    local owner = self:GetOwner()

    owner:Freeze(true)
    timer.Simple(ROAR_SELF_STUN, function()
        owner:Freeze(false)
    end)

    owner:DoCustomAnimEvent(PLAYERANIMEVENT_ATTACK_SECONDARY,0) -- Play roar animation

    local hitboxPosition = OffsetPositionFromPlayer(owner,SECONDARY_HITBOX_OFFSET)
    local targets = GetTargetsInRange(hitboxPosition,SECONDARY_HITBOX_RANGE)

    for _,target in pairs(targets) do
        if target == owner then continue end

        -- Stun target
        -- Right now stunning is represented by coloring them yellow
        target:SetColor(Color(255,255,0,255))

        for _,weapon in pairs(target:GetWeapons()) do
            weapon:SetNextPrimaryFire(CurTime() + ROAR_TARGET_STUN)
            weapon:SetNextSecondaryFire(CurTime() + ROAR_TARGET_STUN)
        end

        timer.Simple(ROAR_TARGET_STUN, function()
            if not target:IsValid() then return end -- Target might have died/left since they got stunned
            target:SetColor(Color(255,255,255,255))
        end)

        target:TakeDamage(SECONDARY_DAMAGE, owner, self)
        if target:Health() <= 0 then -- Killed the target
            self:ChangeBodymass(RF_KILL_REWARD)
        end
    end
end

print("SCP 682 SWEP Initialized")