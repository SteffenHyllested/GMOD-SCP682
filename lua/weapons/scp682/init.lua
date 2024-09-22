AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local WALKSPEED = 240
local RUNSPEED = 360
local MAXHEALTH = 5000 -- Note: max health is multiplied by RF

local PRIMARY_HITBOX_RANGE = 60
local PRIMARY_HITBOX_OFFSET = 100 -- Note: this will offset the hitbox to the front of the player
local PRIMARY_COOLDOWN = 0.4
local PRIMARY_DAMAGE = 35

local SECONDARY_HITBOX_RANGE = 350
local SECONDARY_HITBOX_OFFSET = 0
local SECONDARY_COOLDOWN = 15
local SECONDARY_DAMAGE = 0

local ROAR_SELF_STUN = 2
local ROAR_TARGET_STUN = 5

local RF_KILL_REWARD = 0.05 -- Regenerative force gained on kill
local RF_DAMAGE_PENALTY_MULT = 0.001 -- How much Regenerative force is lost per damage taken
local RF_MAX = 3.00
local RF_MIN = 0.01
local RF_FREQ = 2 -- How frequently 682 regens
local RF_RATE = 0.015 -- How much (percentwise) 682 regens

local MODEL_SCALE_MIN = 0.7
local MODEL_SCALE_MAX = 1.2

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

-- Use for offsetting hitboxes from the player
function OffsetPositionFromPlayer(client,distance)
    local position = client:GetPos()
    local direction = client:GetAngles():Forward()
    direction.z = 0 -- Ignore the z axis
    direction = direction:GetNormalized() -- Normalize the vector

    return position + direction * distance
end

function SWEP:ChangeBodymass(amount)
    self:SetNWFloat("RF",math.Clamp(self:GetNWFloat("RF") + amount, RF_MIN, RF_MAX))

    local owner = self:GetOwner()
    owner:SetMaxHealth(MAXHEALTH * self:GetNWFloat("RF"))
    owner:SetModelScale(MODEL_SCALE_MIN + math.min(self:GetNWFloat("RF") * (MODEL_SCALE_MAX - MODEL_SCALE_MIN), (MODEL_SCALE_MAX - MODEL_SCALE_MIN)), 0.1)
end

function SWEP:Equip()
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

    owner:SetWalkSpeed(10) -- Slow player
    owner:SetRunSpeed(15)
    timer.Simple(ROAR_SELF_STUN, function()
        owner:SetWalkSpeed(WALKSPEED) -- Reset speed
        owner:SetRunSpeed(RUNSPEED)
    end)

    owner:DoCustomAnimEvent(PLAYERANIMEVENT_ATTACK_SECONDARY,0) -- Play roar animation

    local hitboxPosition = OffsetPositionFromPlayer(owner,SECONDARY_HITBOX_OFFSET)
    local targets = GetTargetsInRange(hitboxPosition,SECONDARY_HITBOX_RANGE)

    for _,target in pairs(targets) do
        if target == owner then continue end

        -- Stun target
        -- Right now stunning is represented by coloring them yellow
        target:SetColor(Color(255,255,0,255))
        timer.Simple(ROAR_TARGET_STUN, function()
            if not target:IsValid() then return end -- Target might have died/left since they got stunned
            target:SetColor(Color(255,255,255,255))
        end)

        target:TakeDamage(SECONDARY_DAMAGE, owner, self)
        if target:Health() <= 0 then -- Killed the target
            self:ChangeBodymass(RF_KILL_REWARD)
        end
    end

    self:EmitSound(self.RoarSound)
end

print("SCP 682 SWEP Initialized")