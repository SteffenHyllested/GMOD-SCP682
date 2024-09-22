game.AddParticles("particles/warp_circle.pcf")
PrecacheParticleSystem("warp_circle")

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
SWEP.AttackSound = Sound("scp682/roar4.mp3")
SWEP.StepSounds = {Sound("scp682/footstep1.mp3"),Sound("scp682/footstep2.mp3")}
SWEP.RoarSound = Sound("scp682/roar5.mp3")

hook.Add("DoAnimationEvent", "682-attack-anim", function(client,event) -- Thank you homonovus for the help
    local weapon = client:GetActiveWeapon()
    -- Add a check to see if it is the correct weapon
    if weapon:IsValid() and event == PLAYERANIMEVENT_ATTACK_SECONDARY then -- Ensure it is the correct animation we are overriding
        client:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, client:LookupSequence("attack1"), 0, true) -- Add the roar gesture to the player

        if CLIENT then
            timer.Simple(0.75,function()
                client:EmitSound(weapon.RoarSound)
                weapon:PlayRoarEffect() -- Play the roar effect on the
            end)
        end

        return ACT_INVALID -- Don't send activity to weapon
    end
end)

function OffsetPositionFromPlayer(client,distance)
    local position = client:GetPos()
    local direction = client:GetAngles():Forward()
    direction.z = 0 -- Ignore the z axis
    direction = direction:GetNormalized() -- Normalize the vector

    return position + direction * distance
end

function SWEP:Initialize()
    self:SetHoldType("melee") -- Necessary for animations to play
end