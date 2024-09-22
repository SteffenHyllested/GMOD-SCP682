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