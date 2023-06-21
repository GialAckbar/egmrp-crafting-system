ENT.Base = "egmrp_crafting_base"

ENT.PrintName = "Schmelzer"
ENT.Spawnable = true

function ENT:Initialize()
    if util.IsValidModel( Crafting.Config.Smelter.Model ) then
        self:SetModel( Crafting.Config.Smelter.Model )
    else
        self:SetModel( "models/props_wasteland/laundry_washer003.mdl" )
    end

    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    self.Data = { Input = {}, Output = {}, Smelter = true }

    if SERVER then
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )

        self:SetNWBool( "IsActivated", self.Data.Activated )

        self.NextOutput = 0
        self.Data.Activated = false
    end

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:SetActivated( activate )
    if not isbool( activate ) then
        activate = true
    end

    if activate == self:IsActivated() then return end

    if SERVER then
        self.Data.Activated = activate
        self:SetNWBool( "IsActivated", activate )
    end

    if CLIENT then
        net.Start( "Crafting.Smelter.SetActivated" )
            net.WriteBool( activate )
            net.WriteEntity( self )
        net.SendToServer()
    end
end

function ENT:HasBurnMaterials()
    return self:GetNWBool( "HasBurnMaterials" )
end

function ENT:IsActivated()
    return self:GetNWBool( "IsActivated" )
end