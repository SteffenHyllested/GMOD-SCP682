game.AddParticles( "particles/warp_circle.pcf" )
PrecacheParticleSystem( "warp_circle" )

SWEP.PrintName = "SCP 682"
SWEP.Author = "Steffen Hyllested Pedersen"
SWEP.Instructions = "Left Click to Attack\nRight Click to Roar"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false 
SWEP.Primary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.UseHands = false
SWEP.AttackSound = Sound( "scp682/roar4.mp3" )
SWEP.StepSounds = { Sound( "scp682/footstep1.mp3" ), Sound( "scp682/footstep2.mp3" ) }
SWEP.RoarSound = Sound( "scp682/roar5.mp3" )

hook.Add( "DoAnimationEvent", "682-attack-anim", function( client, event ) -- Thank you homonovus for the help
    local weapon = client:GetActiveWeapon()
    -- Add a check to see if it is the correct weapon
    if weapon:IsValid() and event == PLAYERANIMEVENT_ATTACK_SECONDARY then -- Ensure it is the correct animation we are overriding
        client:AddVCDSequenceToGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD, client:LookupSequence( "attack1" ), 0, true ) -- Add the roar gesture to the player

        if CLIENT then
            timer.Simple( 0.75, function()
                client:EmitSound( weapon.RoarSound )
                weapon:PlayRoarEffect() -- Play the roar effect on the
            end )
        end

        return ACT_INVALID -- Don't send activity to weapon
    end
end )

hook.Add( "StartCommand", "disable-682-crouch-jump", function(client, command)
    -- If they are 682
    if client:HasWeapon( "scp682" ) then
        --Remove the ability to crouch & jump.
        command:RemoveKey( IN_DUCK )
        command:RemoveKey( IN_JUMP )
    end
end )

hook.Add( "PlayerFootstep", "682-steps", function( client, position, foot, _, _, recipientFilter )
    if not client:HasWeapon( "scp682" ) then return false end -- Do nothing if player doesn't have 682 SWEP
    local weapon = client:GetWeapon( "scp682" )

    local soundName = weapon.StepSounds[ foot + 1 ] -- +1 because Lua indexes by 1 not 0
    EmitSound( soundName, position, 0, CHAN_AUTO, 1, 75, 0, 100, 0, recipientFilter )
    return true -- Don't play default step sound
end )

function OffsetPositionFromPlayer( client, distance )
    local position = client:GetPos()
    local direction = client:GetAngles():Forward()
    direction.z = 0 -- Ignore the z axis
    direction = direction:GetNormalized() -- Normalize the vector

    return position + direction * distance
end

function SWEP:Initialize()
    self:SetHoldType( "melee" ) -- Necessary for animations to play
end

function SWEP:PlayRoarEffect()
    local owner = self:GetOwner()
    local position = OffsetPositionFromPlayer( owner, 140 )
    local offset = position - owner:GetPos() + Vector( 0, 0, 30 )
    local particles = CreateParticleSystem( owner, "warp_circle", PATTACH_ABSORIGIN, 0, offset )
    timer.Simple( 2, function()
        if not particles:IsValid() then return end
        particles:StopEmission()
    end )
end