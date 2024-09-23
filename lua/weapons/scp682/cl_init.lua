include("shared.lua")

local MainFontData = {font = "Arial",size = 24,weight = 500,blursize = 0,scanlines = 0,antialias = true,underline = false,italic = false,strikeout = false,symbol = false,rotary = false,shadow = false,additive = false,outline = false,}
local LargeMainFontData = {font = "Arial",size = 48,weight = 1000,blursize = 0,scanlines = 0,antialias = true,underline = false,italic = false,strikeout = false,symbol = false,rotary = false,shadow = false,additive = false,outline = false,}

surface.CreateFont("MainFont", MainFontData)
surface.CreateFont("LargeMainFont",LargeMainFontData)

hook.Add("HUDPaint", "draw-682-hud", function()
    local Client = LocalPlayer()
    if Client:HasWeapon("scp682") then -- If we have the 682 SWEP
        local weapon = Client:GetWeapon("scp682")
        local Width, Height = ScrW(), ScrH()
        local BoxWidth, BoxHeight = 300, 100
        draw.RoundedBox(15, Width/2 - BoxWidth/2, 50, BoxWidth, BoxHeight, Color(0,0,0,100))
        draw.SimpleTextOutlined("SCP 682 Regenerative Force", "MainFont", Width/2, 55, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
        draw.SimpleTextOutlined(tostring(math.floor(weapon:GetNWFloat("RF")*100)).."%", "LargeMainFont", Width/2, 90, Color( 255, 100, 100, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
    end
end)

hook.Add("PlayerFootstep","682-steps",function(client, position, foot, _, _, recipientFilter)
    if not client:HasWeapon("scp682") then return false end -- Do nothing if player doesn't have 682 SWEP
    local weapon = client:GetWeapon("scp682")

    local soundName = weapon.StepSounds[foot+1] -- +1 because Lua indexes by 1 not 0
    EmitSound(soundName,position,0,CHAN_AUTO,1,75,0,100,0,recipientFilter)
    return true -- Don't play default step sound
end)

function SWEP:PlayRoarEffect()
    local owner = self:GetOwner()
    local position = OffsetPositionFromPlayer(owner,140)
    local offset = position - owner:GetPos() + Vector(0,0,30)
    local particles = CreateParticleSystem(owner, "warp_circle", PATTACH_ABSORIGIN, 0, offset)
    timer.Simple(2, function()
        if not particles:IsValid() then return end
        particles:StopEmission()
    end)
end

function SWEP:PrimaryAttack() end -- This is just to stop the client from playing an annoying clicking sound when playing 682