AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

util.AddNetworkString( "Crafting.SendData" )


function ENT:HasItem( checkInput, item, amount )
    if not Crafting:FindItemData( item ) then return false end

    if checkInput and self.Data.Input[item] then
        return self.Data.Input[item] >= ( amount or 1 )
    end

    if not checkInput and self.Data.Output[item] then
        return self.Data.Output[item] >= ( amount or 1 )
    end

    return false
end

function ENT:InputHasItem( item, amount )
    return self:HasItem( true, item, amount )
end

function ENT:OutputHasItem( item, amount )
    return self:HasItem( false, item, amount )
end


function ENT:HasItems( checkInput, itemTable )
    for _, item in ipairs( itemTable or {} ) do
        if not self:HasItem( checkInput, item, 1 ) then
            return false
        end
    end

    return true
end

function ENT:InputHasItems( itemTable )
    return self:HasItems( true, itemTable )
end

function ENT:OutputHasItems( itemTable )
    return self:HasItems( false, itemTable )
end


function ENT:HasItemsAmount( checkInput, itemTable )
    for item, amount in pairs( itemTable or {} ) do
        if not self:HasItem( checkInput, item, amount or 1 ) then
            return false
        end
    end

    return true
end

function ENT:InputHasItemsAmount( itemTable )
    return self:HasItemsAmount( true, itemTable )
end

function ENT:OutputHasItemsAmount( itemTable )
    return self:HasItemsAmount( false, itemTable )
end


function ENT:InsertItem( toInput, item, amount, skipSpaceUpdate )
    return false
end

function ENT:InsertInput( item, amount, skipSpaceUpdate )
    return self:InsertItem( true, item, amount, skipSpaceUpdate )
end

function ENT:InsertOutput( item, amount, skipSpaceUpdate )
    return self:InsertItem( false, item, amount, skipSpaceUpdate )
end


function ENT:InsertItems( toInput, itemTable, skipSpaceUpdate )
    return false
end

function ENT:InsertItemsInput( itemTable, skipSpaceUpdate )
    return self:InsertItems( true, itemTable, skipSpaceUpdate )
end

function ENT:InsertItemsOutput( itemTable, skipSpaceUpdate )
    return self:InsertItems( false, itemTable, skipSpaceUpdate )
end


function ENT:RemoveItem( fromInput, item, amount, skipSpaceUpdate )
    return false
end

function ENT:RemoveInput( item, amount, skipSpaceUpdate )
    return self:RemoveItem( true, item, amount, skipSpaceUpdate )
end

function ENT:RemoveOutput( item, amount, skipSpaceUpdate )
    return self:RemoveItem( false, item, amount, skipSpaceUpdate )
end


function ENT:RemoveItems( fromInput, itemTable, skipSpaceUpdate )
    return false
end

function ENT:RemoveItemsInput( itemTable, skipSpaceUpdate )
    return self:RemoveItems( true, itemTable, skipSpaceUpdate )
end

function ENT:RemoveItemsOutput( itemTable, skipSpaceUpdate )
    return self:RemoveItems( false, itemTable, skipSpaceUpdate )
end


function ENT:UpdateSpace()
    local inputSpace = 0
    for item, amount in pairs( self.Data.Input ) do
        local itemData = Crafting:FindItemData( item )
        if amount <= 0 or not itemData then continue end
        inputSpace = inputSpace + ( itemData.Space or 1 ) * amount
    end

    local outputSpace = 0
    for item, amount in pairs( self.Data.Output ) do
        local itemData = Crafting:FindItemData( item )
        if amount <= 0 or not itemData then continue end
        outputSpace = outputSpace + ( itemData.Space or 1 ) * amount
    end

    self:SetNWInt( "InputSpace", inputSpace )
    self:SetNWInt( "OutputSpace", outputSpace )
end


function ENT:SendData()
    net.Start( "Crafting.SendData" )
        net.WriteEntity( self )
        net.WriteTable( self.Data.Input )
        net.WriteTable( self.Data.Output )
    net.Broadcast()
end