ENT.Base = "egmrp_crafting_base"

ENT.PrintName = "Werkbank"
ENT.Spawnable = true

function ENT:Initialize()
    if util.IsValidModel( Crafting.Config.Workbench.Model ) then
        self:SetModel( Crafting.Config.Workbench.Model )
    else
        self:SetModel( "models/props_c17/FurnitureTable002a.mdl" )
    end

    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    self.Data = { Input = {}, Output = {}, Workbench = true }

    if SERVER then
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )

        self.Data.SelectedRecipe = ""
        self.Data.CraftingProgress = 0

        self:SetNWString( "SelectedRecipe", self.Data.SelectedRecipe )
        self:SetNWInt( "CraftingProgress", self.Data.CraftingProgress )
    end

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end


function ENT:GetSelectedRecipe()
    return self:GetNWString( "SelectedRecipe", "" )
end


function ENT:GetCraftingProgress()
    return self:GetNWInt( "CraftingProgress", 0 )
end