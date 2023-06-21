AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

util.AddNetworkString( "Crafting.Smelter.SetActivated" )
util.AddNetworkString( "Crafting.Smelter.Transfer" )
util.AddNetworkString( "Crafting.Smelter.OpenMenu" )
util.AddNetworkString( "Crafting.Smelter.UpdateInventory" )

function ENT:Use( ply )
    net.Start( "Crafting.Smelter.OpenMenu" )
        net.WriteUInt( self:EntIndex(), 16 )
        net.WriteTable( self.Data )
        net.WriteUInt( self.NextOutput or 0, 32 )
    net.Send( ply )

    self:EmitSound( "doors/door1_move.wav", 100, math.random( 75, 100 ) )
end


function ENT:Think()
    if not self:HasBurnMaterials() or not self:IsActivated() then
        self.NextOutput = CurTime() + ( Crafting.Config.Smelter.BurnTime or 1 )
        return
    end

    if CurTime() < self.NextOutput then return end

    local oldInputSpace = self:GetInputSpace()
    local oldOutputSpace = self:GetOutputSpace()

    local inputSpace = oldInputSpace
    local outputSpace = oldOutputSpace
    local maxOutputSpace = Crafting.Config.Smelter.OutputSpace or 100

    for resource, amount in pairs( self.Data.Input ) do
        -- No need to continue if the output space is full anyway
        if outputSpace >= maxOutputSpace then break end

        local resourceData = Crafting.Config.Resources[resource]
        if not resourceData or amount <= 0 then continue end

        local ingot = Crafting.SmelterRecipes[resource]
        local resourceSpace = resourceData.Space or 1

        if not ingot then
            if Crafting.Config.Smelter.BurnMaterials[resource] then
                self:RemoveInput( resource, 1, true )
                inputSpace = inputSpace - resourceSpace
            end
            continue
        end

        local ingotData = Crafting.Config.Ingots[ingot]
        if not ingotData then continue end

        local ingotSpace = ingotData.Space or 1
        local amountToProduce = math.min( amount, ingotData.AmountProSmelt or 1 )
        local neededOutputSpace = outputSpace + ingotSpace * amountToProduce

        if neededOutputSpace > maxOutputSpace then
            local cancelProduction = true

            while amountToProduce > 1 and cancelProduction do
                amountToProduce = amountToProduce - 1
                neededOutputSpace = neededOutputSpace - ingotSpace
                cancelProduction = neededOutputSpace > maxOutputSpace
            end

            if cancelProduction then continue end
        end

        self:RemoveInput( resource, amountToProduce, true )
        self:InsertOutput( ingot, amountToProduce, true )
        inputSpace = inputSpace - resourceSpace * amountToProduce
        outputSpace = neededOutputSpace
    end

    if inputSpace ~= oldInputSpace then
        self:SetNWInt( "InputSpace", inputSpace )
    end

    if outputSpace ~= oldOutputSpace then
        self:SetNWInt( "OutputSpace", outputSpace )
    end

    --PrintTable( self.Data )
    --print( "InputSpace: " .. inputSpace )
    --print( "OutputSpace: " .. outputSpace )

    self:SendData()

    self.NextOutput = CurTime() + ( Crafting.Config.Smelter.BurnTime or 1 )
end


function ENT:InsertItem( toInput, item, amount, skipSpaceUpdate )
    local key, container, itemData, curSpace, maxSpace
    amount = amount or 1

    if toInput then
        key = "InputSpace"
        container = self.Data.Input
        itemData = Crafting.Config.Resources[item]
        curSpace = self:GetInputSpace()
        maxSpace = Crafting.Config.Smelter.InputSpace or 100
        if not ( Crafting.SmelterRecipes[item] or Crafting.Config.Smelter.BurnMaterials[item] ) then
            return false
        end
    else
        key = "OutputSpace"
        container = self.Data.Output
        itemData = Crafting.Config.Ingots[item]
        curSpace = self:GetOutputSpace()
        maxSpace = Crafting.Config.Smelter.OutputSpace or 100
    end

    if not itemData then return false end

    if not skipSpaceUpdate then
        local space = curSpace + ( itemData.Space or 1 ) * amount
        if space > maxSpace then return false end

        self:SetNWInt( key, space )
    end

    container[item] = ( container[item] or 0 ) + amount

    if toInput and Crafting.Config.Smelter.BurnMaterials[item] and not self:HasBurnMaterials() then
        self:SetNWBool( "HasBurnMaterials", true )
    end

    return true
end


function ENT:RemoveItem( fromInput, item, amount, skipSpaceUpdate )
    local key, container, itemData, curSpace

    if fromInput then
        key = "InputSpace"
        container = self.Data.Input
        itemData = Crafting.Config.Resources[item]
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

    if fromInput and Crafting.Config.Smelter.BurnMaterials[item] and rest <= 0 then
        self:CheckBurnMaterials()
    end

    return true
end


function ENT:CheckBurnMaterials()
    for resource, amount in pairs( self.Data.Input ) do
        if Crafting.Config.Smelter.BurnMaterials[resource] and amount > 0 then
            if not self:HasBurnMaterials() then
                self:SetNWBool( "HasBurnMaterials", true )
            end
            return true
        end
    end

    if self:HasBurnMaterials() then
        self:SetNWBool( "HasBurnMaterials", false )
    end
    return false
end


function ENT:UpdateSpace()
    local inputSpace = 0
    for resource, amount in pairs( self.Data.Input ) do
        if amount <= 0 or not Crafting.Config.Resources[resource] then continue end
        inputSpace = inputSpace + ( Crafting.Config.Resources[resource].Space or 1 ) * amount
    end

    local outputSpace = 0
    for ingot, amount in pairs( self.Data.Output ) do
        if amount <= 0 or not Crafting.Config.Ingots[ingot] then continue end
        outputSpace = outputSpace + ( Crafting.Config.Ingots[ingot].Space or 1 ) * amount
    end

    self:SetNWInt( "InputSpace", inputSpace )
    self:SetNWInt( "OutputSpace", outputSpace )
end


net.Receive( "Crafting.Smelter.SetActivated", function()
    local activate = net.ReadBool()
    local smelter = net.ReadEntity()

    if not IsValid( smelter ) then return end

    smelter:SetActivated( activate )
end )


net.Receive( "Crafting.Smelter.Transfer", function( len, ply )
    local entIndex = net.ReadUInt( 16 )
    local class = net.ReadString()
    local amount = net.ReadUInt( 32 )
    local toPlayer = net.ReadBool()

    local ent = Entity( entIndex )
    if not IsValid( ent ) then return end

    local char = ply:GetCurrentCharacter()
    if not char then return end

    local container = ent.Data.Input
    local fromInput = true

    if Crafting:IsIngot( class ) then
        container = ent.Data.Output
        fromInput = false
    end

    if toPlayer then
        if not container[class] or container[class] < amount then
            Notify:Danger( ply, "Ungültige Anzahl!", "Du versuchst mehr Items rauszuholen, als im Ofen vorhanden ist!" )
            return
        end

        local success = char:GiveResource( class, amount )

        if not success then
            Notify:Danger( ply, "Nicht genug Platz!", "Du kannst dieses Item nicht rausholen, weil du nicht genug Platz hast!" )
            return
        end

        ent:RemoveItem( fromInput, class, amount )
    else
        local inventory = char:GetResources()

        if not inventory[class] or inventory[class] < amount then
            Notify:Danger( ply, "Einlagern fehlgeschlagen!", "Du hast versucht mehr Items einzulagern, als du im Inventar hast!" )
            return
        end

        local success = ent:InsertItem( fromInput, class, amount )

        if not success then
            Notify:Danger( ply, "Nicht genug Platz!", "Du kannst dieses Item nicht einlagern, weil im Ofen kein Platz mehr dafür ist!" )
            return
        end

        char:RemoveResource( class, amount )
    end

    ent:SendData()

    net.Start( "Crafting.Smelter.UpdateInventory" )
    net.Send( ply )
end )