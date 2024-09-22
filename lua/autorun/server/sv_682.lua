include("autorun/sh_pacalt.lua")

hook.Add("StartCommand", "disable-682-jump", function(Player, Command)
    -- If they are 682
    if Player:HasWeapon("scp682") then
        --Remove the ability to crouch.
        Command:RemoveKey(IN_DUCK)
    end
end)

hook.Add("PlayerHurt","682hurt",function(victim, _, _, damageTaken)
    if victim:HasWeapon("scp682") then
        local BMReduction = damageTaken*0.001
        victim:SetNWFloat("682Bodymass",math.max(victim:GetNWFloat("682Bodymass")-BMReduction,0.01))
        victim:SetMaxHealth(5000*victim:GetNWFloat("682Bodymass"))
        victim:SetModelScale(0.7+math.min(victim:GetNWFloat("682Bodymass")*0.5,0.5), 0.1)
    end
end)

hook.Add("PlayerDeath","682death",function(victim, _, _)
    if victim:HasWeapon("scp682") then
        victim:SetModelScale(1)
    end
end)

hook.Add("PlayerFootstep","682steps",function(Player, pos, foot, _, _, rec)
    if not Player:HasWeapon("scp682") then return false end

    local soundName = "scp682/footstep1.mp3"
    if foot == 1 then
        soundName = "scp682/footstep2.mp3"
    end
    EmitSound(soundName,pos,0,CHAN_AUTO,1,75,0,100,0,rec)
    return true
end)

