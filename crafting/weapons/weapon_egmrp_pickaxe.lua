SWEP.PrintName = "Spitzhacke"
SWEP.Author = "Gial Ackbar"
SWEP.Spawnable = true
SWEP.Adminspawnable = false
SWEP.Category = "EGM:RP"

SWEP.Primary.Clipsize =	-1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo =	""

SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = ""

SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/sterling/c_crafting_pickaxe.mdl"
SWEP.WorldModel = "models/sterling/w_crafting_pickaxe.mdl"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false

SWEP.Sound = Sound( "physics/wood/wood_box_impact_hard3.wav" )

SWEP.Damage = 30
SWEP.Distance = 90
SWEP.Delay = 1

function SWEP:Initialize()
    self:SendWeaponAnim( ACT_VM_HOLSTER )
    self:SetHoldType( self.HoldType )
end

function SWEP:DoHitEffects()
    local ply = self:GetOwner()
    local trace = ply:GetEyeTraceNoCursor()

    if ( ( ( trace.Hit or trace.HitWorld ) and ply:GetShootPos():Distance( trace.HitPos ) <= self.Distance ) and IsValid( trace.Entity ) and trace.Entity.Resource ) then
        self:SendWeaponAnim( ACT_VM_HITCENTER )
        self:EmitSound( "physics/concrete/rock_impact_hard5.wav" )

        local bullet = {
            Num = 1,
            Src = ply:GetShootPos(),
            Dir = ply:GetAimVector(),
            Spread = Vector( 0, 0, 0 ),
            Tracer = 0,
            Force = 3,
            Damage = 0
        }

        ply:DoAttackEvent()
        ply:FireBullets( bullet )
    else
        self:SendWeaponAnim( ACT_VM_MISSCENTER )
        self:EmitSound( "npc/vort/claw_swing2.wav" )
    end
end

function SWEP:DoAnimations( idle )
    if not idle then
        self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
    end
end


function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime() + self.Delay )
    self:DoAnimations()
    self:DoHitEffects()

    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )

    if SERVER then
        local ply = self:GetOwner()

        if ply.LagCompensation then
            ply:LagCompensation( true )
        end

        local trace = ply:GetEyeTraceNoCursor()
        local ent = trace.Entity
        local char = ply:GetCurrentCharacter()

        if char and ply:GetShootPos():Distance( trace.HitPos ) <= self.Distance and IsValid( ent )
        and ent.Resource and isfunction( Crafting.Config.PickupFunctions.Resources ) then
            Crafting.Config.PickupFunctions:Resources( ply, ent, ent.Resource, Crafting.Config.Resources[ent.Resource], math.random( 4, 6 ) )
            ent:Hit()
        end

        if self:GetOwner().LagCompensation then
            self:GetOwner():LagCompensation( false )
        end
    end
end


function SWEP:SecondaryAttack() end