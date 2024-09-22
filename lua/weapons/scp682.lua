SWEP.PrintName = "SCP 682"
SWEP.Author = "Steffen Hyllested Pedersen"
SWEP.Instructions = "Left Click to Attack\nRight Click to Roar"

SWEP.Spawnable = false
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false 
SWEP.Primary.Ammo = "Pistol"

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
SWEP.RoarSound = Sound("scp682/roar5.mp3")
SWEP.NextSecondaryFire = 0

function SWEP:Initialize()
    self:SetHoldType("normal") -- Necessary for animations for some reason
end

function SWEP:Equip()
    local SWEPPlayer = self:GetOwner()
    SWEPPlayer:SetWalkSpeed(240) -- Set player speeds
    SWEPPlayer:SetRunSpeed(360)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.4)
    
    -- Hitboxes are simple magnitude checks since idk how to to volumetric hitboxes in glua
    local HitboxSize = 60
    local HitboxDistance = 100

    local SWEPPlayer = self:GetOwner()
    local PlayerPosition = SWEPPlayer:GetPos()
    local ModelLookVector = SWEPPlayer:GetAngles():Forward()
    ModelLookVector.z = 0
    ModelLookVector = ModelLookVector:GetNormalized()

    local HitboxPosition = PlayerPosition + ModelLookVector*HitboxDistance

    local Hit = false

    for _,Ent in ents.Iterator() do
        if not (Ent:IsPlayer() or Ent:IsNPC()) then continue end -- Only able to attack Players/NPCs ( NPCs included cause I have no friends :( )
        if Ent == SWEPPlayer then continue end
        if Ent:Health() <= 0 then continue end
        local Dist = Ent:GetPos():Distance(HitboxPosition)
        if Dist <= HitboxSize then
            Hit = true
            Ent:TakeDamage(35, SWEPPlayer, SWEPPlayer)
            if Ent:Health() <= 0 then
                SWEPPlayer:SetNWFloat("682Bodymass", math.min(SWEPPlayer:GetNWFloat("682Bodymass")+0.05,3))
                SWEPPlayer:SetMaxHealth(5000*SWEPPlayer:GetNWFloat("682Bodymass"))
                SWEPPlayer:SetModelScale(0.7+math.min(SWEPPlayer:GetNWFloat("682Bodymass")*0.5,0.5), 0.1)
            end
        end
    end

    if Hit then
        EmitSound(self.AttackSound,self:GetPos(),0,CHAN_AUTO,0.35)
    end
end

function SWEP:SecondaryAttack()
    if CurTime() < self.NextSecondaryFire then return end
    self:SetNextPrimaryFire(CurTime() + 2)
    self:SetNextSecondaryFire(CurTime() + 2) -- 15 sec M2 cooldown

    local HitboxSize = 350 -- tree fiddy

    local SWEPPlayer = self:GetOwner()
    local HitboxPosition = SWEPPlayer:GetPos()

    SWEPPlayer:SetWalkSpeed(10) -- Slow player
    SWEPPlayer:SetRunSpeed(15)
    --SWEPPlayer:SetAnimation(5) -- Idk why this doesn't work
    local id = SWEPPlayer:AddGesture(64)

    timer.Simple(2, function() -- Wait 2 seconds
        SWEPPlayer:SetWalkSpeed(240) -- Set speed back to normal
        SWEPPlayer:SetRunSpeed(360)
    end)

    for _,Ent in ents.Iterator() do
        if not (Ent:IsPlayer() or Ent:IsNPC()) then continue end -- Only able to attack Players/NPCs ( NPCs included cause I have no friends :( )
        if Ent == SWEPPlayer then continue end -- DNC about the player themselves
        if Ent:Health() <= 0 then continue end -- DNC about dead people
        local Dist = Ent:GetPos():Distance(HitboxPosition)
        if Dist <= HitboxSize then -- Distance check
            Ent:SetColor(Color(255,255,0,255)) -- Make them yellow
            if Ent:IsPlayer() then
                Ent:SetWalkSpeed(10) -- Slow players (For some reason you can't do this to NPCs?)
                Ent:SetRunSpeed(15)
            end

            timer.Simple(5, function() -- Wait 5 seconds
                if not Ent:IsValid() then return end
                Ent:SetColor(Color(255,255,255,255)) -- Return to normal color
                if Ent:IsPlayer() then
                    Ent:SetWalkSpeed(160) -- Set speed back to normal
                    Ent:SetRunSpeed(240)
                end
            end)

            -- Temporarily disable their weapons
            local Weapons = Ent:GetWeapons()
            for _,Weapon in pairs(Weapons) do
                -- This should work for players (can't test have no friends)
                -- I can't seem to figure out how to disable the guns for NPCs
                -- Yes, this means against NPCs, the roar just turns them yellow. (Temporarily)
                Weapon:SetNextPrimaryFire(CurTime() + 5)
                Weapon:SetNextSecondaryFire(CurTime() + 5)
                print("Disabled "..Weapon:GetPrintName())
            end
        end
    end

    self:EmitSound(self.RoarSound)
end