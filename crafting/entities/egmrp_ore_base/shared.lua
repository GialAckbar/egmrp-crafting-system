ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Ore-Base"
ENT.Author = "Gial Ackbar"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = true

ENT.WorldModel = "models/brickscrafting/rock.mdl"

ENT.MaxHits = 2500
ENT.Resource = "iron"

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "RemainingHits" )
    self:NetworkVar( "Int", 1, "Stage" )

    if SERVER then
        self:SetRemainingHits( self.MaxHits )
        self:SetStage( 0 )
    end
end