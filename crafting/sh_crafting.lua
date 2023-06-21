function Crafting:IsResource( item )
    return istable( self.Config.Resources[item] )
end

function Crafting:IsIngot( item )
    return istable( self.Config.Ingots[item] )
end

function Crafting:IsCrafting( item )
    return istable( self.Config.Craftings[item] )
end

function Crafting:Exists( item )
    return self:IsCrafting( item ) or self:IsResource( item ) or self:IsIngot( item )
end

function Crafting:FindItemData( item )
    local resourceData = self.Config.Resources[item]
    if resourceData then return resourceData end

    local ingotData = self.Config.Ingots[item]
    if ingotData then return ingotData end

    local craftingData = self.Config.Craftings[item]
    if craftingData then return craftingData end

    return false
end


-- check for invalid resources
for ingot, ingotData in pairs( Crafting.Config.Ingots ) do
    if Crafting:IsResource( ingotData.Source ) and ingotData.Source ~= ingot then
        Crafting.SmelterRecipes[ingotData.Source] = ingot
    else
        if SERVER then print( "[CRAFTING] Invalid source material for '" .. ingotData.PrintName .. "'!" ) end
        Crafting.Config.Ingots[ingot] = nil
    end
end

-- check for invalid crafting materials
for item, itemData in pairs( Crafting.Config.Craftings ) do
    for material, _ in pairs( itemData.Recipe ) do
        if Crafting:Exists( material ) and item ~= material then continue end
        if SERVER then print( "[CRAFTING] Invalid crafting recipe for '" .. itemData.PrintName .. "'!" ) end
        Crafting.Config.Craftings[item] = nil
        break
    end
end


-- create entities for every item
local function CreateItemEntity( name, type, printName, model, color, weight, space )
    local ENT = {}

    ENT.Base = "egmrp_item_base"
    ENT.ClassName = "egmrp_" .. string.lower( type ) .. "_" .. name

    ENT.PrintName = printName or name
    ENT.Category = "EGM:RP Crafting"
    ENT.Spawnable = true

    ENT.ItemType = type
    ENT.InternalName = name

    ENT.WorldModel = model
    ENT.Color = color

    ENT.Weight = weight or 1
    ENT.Space = space or 1

    scripted_ents.Register( ENT, ENT.ClassName )
end

-- create ores for every resource with OreModel
local function CreateOreEntity( name, printName, model, color )
    local ENT = {}

    ENT.Base = "egmrp_ore_base"
    ENT.ClassName = "egmrp_" .. name .. "_ore"

    ENT.PrintName = ( printName or name ) .. " (Erz)"
    ENT.Category = "EGM:RP Crafting"
    ENT.Spawnable = true

    ENT.Resource = name

    ENT.WorldModel = model
    ENT.Color = color

    scripted_ents.Register( ENT, ENT.ClassName )
end

for resource, itemData in pairs( Crafting.Config.Resources ) do
    CreateItemEntity(
        resource, "Resources",
        itemData.PrintName,
        itemData.Model or "models/sterling/crafting_rock.mdl",
        itemData.Color,
        itemData.Weight,
        itemData.Space
    )

    if not itemData.OreModel then continue end
    CreateOreEntity( resource, itemData.PrintName, itemData.OreModel, itemData.OreColor )
end

for ingot, itemData in pairs( Crafting.Config.Ingots ) do
    CreateItemEntity(
        ingot, "Ingots",
        itemData.PrintName,
        itemData.Model or "models/sterling/crafting_metal.mdl",
        itemData.Color,
        itemData.Weight,
        itemData.Space
    )
end

for item, itemData in pairs( Crafting.Config.Craftings ) do
    CreateItemEntity(
        item, "Craftings",
        itemData.PrintName,
        itemData.Model or "models/sterling/crafting_metal.mdl",
        itemData.Color,
        itemData.Weight,
        itemData.Space
    )
end