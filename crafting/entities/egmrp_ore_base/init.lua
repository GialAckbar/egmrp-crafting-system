AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetModel( self.WorldModel )

	if self.Color then
		self:SetColor( self.Color )
	end

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:EnableMotion( false )
		phys:Wake()
	end
end

local Stages = {}
Stages[1] = { 90, 0.95 }
Stages[2] = { 80, 0.9 }
Stages[3] = { 70, 0.85 }
Stages[4] = { 60, 0.8 }
Stages[5] = { 50, 0.75 }
Stages[6] = { 40, 0.7 }
Stages[7] = { 30, 0.65 }
Stages[8] = { 20, 0.625 }
Stages[9] = { 10, 0.6 }

function ENT:Hit()
	self:SetRemainingHits( self:GetRemainingHits() - 1 )

	if self:GetRemainingHits() <= 0 then
		local class = self:GetClass()
		local pos = self:GetPos()
		local ang = self:GetAngles()
		timer.Simple( math.random( 300, 480 ), function()
			local newOre = ents.Create( class )
			newOre:SetPos( pos )
			newOre:SetAngles( ang )
			newOre:Spawn()
		end )
		self:Remove()
		return
	end

	for k, v in pairs( Stages ) do
		if self:GetStage() < k then
			if self:GetRemainingHits() / self.MaxHits * 100 <= v[1] then
				self:SetStage( k )
				self:SetModelScale( v[2] )
			else
				break
			end
		end
	end
end