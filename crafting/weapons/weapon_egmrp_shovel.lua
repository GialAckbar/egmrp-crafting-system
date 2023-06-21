SWEP.PrintName = "Schaufel"
SWEP.Author = "Gial Ackbar"
SWEP.Spawnable = true
SWEP.Adminspawnable = false
SWEP.Category = "EGM:RP"

SWEP.Primary.Clipsize =	-1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo =	""

SWEP.Secondary.Clipsize =	-1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo =	""

SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_shovel.mdl"
SWEP.WorldModel = "models/weapons/w_shovel.mdl"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false

SWEP.Sound = Sound( "weapons/shovel/shovel_fire.wav" )

SWEP.Primary.Delay = 1.2
SWEP.Primary.Damage = 30

SWEP.Secondary.Delay = 1
SWEP.Secondary.Damage = 20

function SWEP:Initialize()
    self:SetWeaponHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime() + 0.5 )
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_3 )

    timer.Simple( 0.4, function()
        local ply = self:GetOwner()

        local trace = util.TraceLine( {
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + ( ply:GetAimVector() * 105 ),
            filter = ply,
            mask = MASK_SHOT
        } )

        self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
        self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

        if trace.Hit then
            self:EmitSound( Sound( "weapons/shovel/shovel_stab.wav" ), 100, math.random( 90, 110 ) )

            self:FireBullets( {
                Num = 1,
                Src = ply:GetShootPos(),
                Dir = ply:GetAimVector(),
                Spread = Vector( 0, 0, 0 ),
                Tracer = 0,
                Force = 1000,
                Damage = self.Primary.Damage
            } )

            if SERVER and trace.SurfaceProps then
                local targetSurfaceName = util.GetSurfacePropName( trace.SurfaceProps )
                local targetResource

                for resource, data in pairs( Crafting.Config.Resources ) do
                    if not data.AllowedSurfaces then continue end

                    for _, surfaceName in ipairs( data.AllowedSurfaces ) do
                        if surfaceName == targetSurfaceName then
                            targetResource = resource
                            break
                        end
                    end

                    if targetResource then break end
                end

                if not targetResource then
                    Notify:Danger( ply, "Ungültiger Boden!", "Du kannst die Schaufel nur auf Erde benutzen!" )
                else
                    local char = ply:GetCurrentCharacter()
                    if char and isfunction( Crafting.Config.PickupFunctions.Resources ) then
                        Crafting.Config.PickupFunctions:Resources( ply, nil, targetResource, Crafting.Config.Resources[targetResource], math.random( 4, 6 ) )
                    end
                end
            end
        else
            self:EmitSound( self.Sound, 100, math.random( 80, 110 ) )
        end

        self:SetAnimation( PLAYER_ATTACK1 )

        if not ply:IsNPC() then
            ply:ViewPunch( Angle( -2, -2, 0 ) )
        end
    end )
end

function SWEP:SecondaryAttack()
    local ply = self:GetOwner()

    self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
    ply:SetAnimation( PLAYER_ATTACK1 )

    if not ply:IsNPC() then
        ply:ViewPunch( Angle( -2, -2, 0 ) )
    end

    local trace = util.TraceLine( {
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + ( ply:GetAimVector() * 105 ),
        filter = ply,
        mask = MASK_SHOT
    } )

    if trace.Hit then
        self:EmitSound( Sound( "weapons/shovel/shovel_hit" .. math.random( 2, 3 ) .. ".wav" ), 100, math.random( 80, 120 ) )

        ply:FireBullets( {
            Num = 1,
            Src = ply:GetShootPos(),
            Dir = ply:GetAimVector(),
            Spread = Vector( 0, 0, 0 ),
            Tracer = 0,
            Force = 40,
            Damage = self.Secondary.Damage
        } )

        local hitNum = math.random( 1, 2 )
        if hitNum == 1 then
            self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_4 )
        elseif hitNum == 2 then
            self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_5 )
        end
    else
        local missNum = math.random( 1, 2 )
        self:EmitSound( self.Sound, 100, math.random( 80, 120 ) )
        if missNum == 1 then
            self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )
        elseif missNum == 2 then
            self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_2 )
        end
    end
end

function SWEP:Reload()
    return false
end

function SWEP:OnRemove()
    return true
end

function SWEP:Holster()
    return true
end