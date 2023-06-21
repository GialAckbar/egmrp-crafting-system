ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Item Base Entity"
ENT.Category = "EGM:RP Crafting"
ENT.Author = "Gial Ackbar"
ENT.Purpose = ""

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.Editable = true

ENT.Weight = 1
ENT.Space = 1

function ENT:Initialize()
    self:SetModel( self.WorldModel or "models/props_junk/PopCan01a.mdl" )

    if self.Color then
        self:SetColor( self.Color )
    end

    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    if SERVER then
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )
    end

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "Amount", { KeyName = "amount", Edit = { type = "Int", order = 1, min = 1, max = 1000 } } )
    if SERVER then self:SetAmount( 1 ) end
end