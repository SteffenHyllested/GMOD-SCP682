AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local PhysObj = self:GetPhysicsObject()

    if PhysObj:IsValid() then
        PhysObj:Wake()
    end
end

function ENT:Use(Activator, Caller, UseType, Integer)
    self:Remove()
    Activator:RemoveAllItems()
    Activator:Give("scp682")
    Activator:SetModel("models/scp_682/scp_682.mdl")
    Activator:SetJumpPower(0)
    Activator:SetNWFloat("682Bodymass",1)
    Activator:SetMaxHealth(5000*Activator:GetNWFloat("682Bodymass"))
    Activator:SetHealth(5000*Activator:GetNWFloat("682Bodymass"))
    Activator:SetModelScale(0.7+math.min(Activator:GetNWFloat("682Bodymass")*0.5,0.5), 0.1)

    function Activator:IsJumpLegal()
        return false
    end

    timer.Create("682-regen-"..Activator:AccountID(), 2, -1, function()
        Activator:SetHealth(math.min(Activator:Health() + Activator:GetMaxHealth()*0.015,Activator:GetMaxHealth()))
    end)
end