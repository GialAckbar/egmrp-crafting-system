AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

util.AddNetworkString( "Crafting.Workbench.OpenMenu" )
util.AddNetworkString( "Crafting.Workbench.Transfer" )
util.AddNetworkString( "Crafting.Workbench.UpdateInventory" )
util.AddNetworkString( "Crafting.Workbench.BuildItem" )

function ENT:Use( ply )
    net.Start( "Crafting.Workbench.OpenMenu" )
        net.WriteUInt( self:EntIndex(), 16 )
        net.WriteTable( self.Data )
    net.Send( ply )

    self:EmitSound( "doors/door1_move.wav", 100, math.random( 75, 100 ) )
end


function ENT:ApplyCraftingHits( amount )
    local item = self:GetSelectedRecipe()

    if not Crafting.Config.Craftings[item] then return false end
    if not self:InputHasItemsAmount( Crafting.Config.Craftings[item].Recipe ) then return false end

    local newCraftingProgress = self:GetCraftingProgress() + ( amount or 1 )

    if newCraftingProgress < ( Crafting.Config.Craftings[item].CraftTime or 3 ) then
        self.Data.CraftingProgress = newCraftingProgress
        self:SetNWInt( "CraftingProgress", newCraftingProgress )
        return true
    end

    --local success = self:InsertOutput( item, Crafting.Config.Craftings[item].CraftAmount or 1 )
    local success = self:InsertInput( item, Crafting.Config.Craftings[item].CraftAmount or 1 )
    if not success then return false end

    self:RemoveItemsInput( Crafting.Config.Craftings[item].Recipe )

    self.Data.CraftingProgress = 0
    self:SetNWInt( "CraftingProgress", 0 )

    self:SendData()

    return true
end


function ENT:SelectCraftingRecipe( item )
    if not Crafting.Config.Craftings[item] then return false end
    if self:GetSelectedRecipe() == item then return end

    self.Data.SelectedRecipe = item
    self.Data.CraftingProgress = 0

    self:SetNWString( "SelectedRecipe", item )
    self:SetNWInt( "CraftingProgress", 0 )

    return true
end


function ENT:InsertItem( toInput, item, amount, skipSpaceUpdate )
    local key, container, itemData, curSpace, maxSpace
    amount = amount or 1

    if toInput then
        key = "InputSpace"
        container = self.Data.Input
        itemData = Crafting:FindItemData( item )
        curSpace = self:GetInputSpace()
        maxSpace = Crafting.Config.Workbench.InputSpace or 100
    else
        key = "OutputSpace"
        container = self.Data.Output
        itemData = Crafting.Config.Craftings[item]
        curSpace = self:GetOutputSpace()
        maxSpace = Crafting.Config.Workbench.OutputSpace or 100
    end

    if not itemData then return false end

    if not skipSpaceUpdate then
        local space = curSpace + ( itemData.Space or 1 ) * amount
        if space > maxSpace then return false end

        self:SetNWInt( key, space )
    end

    container[item] = ( container[item] or 0 ) + amount

    return true
end


function ENT:RemoveItem( fromInput, item, amount, skipSpaceUpdate )
    local key, container, itemData, curSpace

    if fromInput then
        key = "InputSpace"
        container = self.Data.Input
        itemData = Crafting:FindItemData( item )
        curSpace = self:GetInputSpace()
    else
        key = "OutputSpace"
        container = self.Data.Output
        itemData = Crafting.Config.Ingots[item]
        curSpace = self:GetOutputSpace()
    end

    if not itemData or not container[item] then return false end

    amount = amount or container[item]
    local rest = container[item] - amount

    if rest > 0 then
        container[item] = rest
    else
        container[item] = nil
    end

    if not skipSpaceUpdate then
        self:SetNWInt( key, curSpace - ( itemData.Space or 1 ) * amount )
    end

    return true
end


function ENT:RemoveItems( fromInput, itemTable, skipSpaceUpdate )
    for item, amount in pairs( itemTable or {} ) do
        self:RemoveItem( fromInput, item, amount or 1, skipSpaceUpdate )
    end
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
        if amount <= 0 or not Crafting.Config.Craftings[item] then continue end
        outputSpace = outputSpace + ( Crafting.Config.Craftings[item].Space or 1 ) * amount
    end

    self:SetNWInt( "InputSpace", inputSpace )
    self:SetNWInt( "OutputSpace", outputSpace )
end


net.Receive( "Crafting.Workbench.Transfer", function( len, ply )
    local entIndex = net.ReadUInt( 16 )
    local class = net.ReadString()
    local amount = net.ReadUInt( 32 )
    local toPlayer = net.ReadBool()

    local ent = Entity( entIndex )
    if not IsValid( ent ) then return end

    local char = ply:GetCurrentCharacter()
    if not char then return end

    local container = ent.Data.Input

    if toPlayer then
        if not container[class] or container[class] < amount then
            Notify:Danger( ply, "Ungültige Anzahl!", "Du versuchst mehr Items rauszuholen, als in der Werkbank vorhanden sind!" )
            return
        end

        local success = char:GiveResource( class, amount )

        if not success then
            Notify:Danger( ply, "Nicht genug Platz!", "Du kannst dieses Item nicht rausholen, weil du nicht genug Platz hast!" )
            return
        end

        ent:RemoveItem( true, class, amount )
    else
        local inventory = char:GetResources()

        if not inventory[class] or inventory[class] < amount then
            Notify:Danger( ply, "Einlagern fehlgeschlagen!", "Du hast versucht mehr Items einzulagern, als du im Inventar hast!" )
            return
        end

        local success = ent:InsertItem( true, class, amount )

        if not success then
            Notify:Danger( ply, "Nicht genug Platz!", "Du kannst dieses Item nicht einlagern, weil in der Werkbank kein Platz mehr ist!" )
            return
        end

        char:RemoveResource( class, amount )
    end

    ent:SendData()

    net.Start( "Crafting.Workbench.UpdateInventory" )
    net.Send( ply )
end )

net.Receive( "Crafting.Workbench.BuildItem", function( len, ply )
    local entIndex = net.ReadUInt( 16 )
    local item = net.ReadString()

    local ent = Entity( entIndex )
    if not IsValid( ent ) then return end

    if not ent:InputHasItemsAmount( Crafting.Config.Craftings[item].Recipe ) then
        Notify:Danger( ply, "Fehler beim Craften!", "Es ist ein unerwarteter Fehler beim Craften geschehen!" )
    end

    local success = ent:InsertInput( item, Crafting.Config.Craftings[item].CraftAmount or 1 )
    if not success then return end

    ent:RemoveItemsInput( Crafting.Config.Craftings[item].Recipe )

    ent:SendData()
end )