ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Crafting Base Entity"
ENT.Category = "EGM:RP"
ENT.Author = "Gial Ackbar"
ENT.Purpose = ""

ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:Initialize()
    self:SetModel( "models/props_wasteland/laundry_washer003.mdl" )

    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    self.Data = { Input = {}, Output = {} }

    if SERVER then
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )
    end

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:GetInputSpace()
    return self:GetNWInt( "InputSpace" )
end

function ENT:GetOutputSpace()
    return self:GetNWInt( "OutputSpace" )
end