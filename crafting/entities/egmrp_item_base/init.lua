AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

function ENT:Use( activator )
    local PickupFunction = Crafting.Config.PickupFunctions[self.ItemType]

    if not isfunction( PickupFunction ) then
        self:Remove()
        return
    end

    local curAmount = self:GetAmount()
    local amountToRemove = PickupFunction( nil, activator, self, self.InternalName, Crafting.Config[self.ItemType][self.InternalName], curAmount )

    if not isnumber( amountToRemove ) then
        self:Remove()
        return
    end

    local remaining = curAmount - amountToRemove

    if remaining > 0 then
        self:SetAmount( remaining )
    else
        self:Remove()
    end
end