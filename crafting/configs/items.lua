---- Resources ----

Crafting.Config.Resources["dirt"] = {
    PrintName = "Erde",
    AllowedSurfaces = { "dirt", "grass" },
    AmountProHit = 5,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 0.1,
    Space = 0.1
}

Crafting.Config.Resources["coal"] = {
    PrintName = "Kohle",
    AmountProHit = 5,
    Model = "models/sterling/crafting_rock.mdl",
    Color = Color( 72, 72, 72, 255 ),
    OreModel = "models/brickscrafting/rock.mdl",
    OreColor = Color( 0, 0, 0, 255 ),
    Weight = 0.1,
    Space = 0.1
}

Crafting.Config.Resources["copper"] = {
    PrintName = "Kupfer",
    AmountProHit = 5,
    Model = "models/sterling/crafting_rock.mdl",
    Color = Color( 184, 115, 51, 255 ),
    OreModel = "models/brickscrafting/rock.mdl",
    OreColor = Color( 184, 115, 51, 255 ),
    Weight = 0.1,
    Space = 0.1
}

Crafting.Config.Resources["iron"] = {
    PrintName = "Eisen",
    AmountProHit = 5,
    Model = "models/sterling/crafting_rock.mdl",
    Color = Color( 182, 182, 182, 255 ),
    OreModel = "models/brickscrafting/rock.mdl",
    OreColor = Color( 109, 109, 109, 255 ),
    Weight = 0.1,
    Space = 0.1
}

Crafting.Config.Resources["netanium"] = {
    PrintName = "Netanium",
    AmountProHit = 5,
    Model = "models/sterling/crafting_rock.mdl",
    Color = Color( 152, 216, 253, 255 ),
    OreModel = "models/brickscrafting/rock.mdl",
    OreColor = Color( 91, 193, 253, 255 ),
    Weight = 0.1,
    Space = 0.1
}


-- Function, which adds the resource to your inventory.
-- If you use your own inventory system, you need to adapt the function to your system.
-- Returning a number will remove that amount from the entity (if number >= amountInEntity => entity will be removed)
-- Not returning a number will remove the entity too. Return 0 if nothing should happen.
function Crafting.Config.PickupFunctions:Resources( ply, ent, resource, resourceData, amountInEntity )
    local char = ply:GetCurrentCharacter()
    if not char then return 0 end

    local space = char:GetInventorySpace()
    local maxSpace = char:GetInventoryMaxSpace()
    local itemSpace = resourceData.Space or CInventory.DefaultSlotsPerResource

    local amountToAdd = 0

    for i = 1, amountInEntity do
        space = space + itemSpace
        if space <= maxSpace then
            amountToAdd = amountToAdd + 1
        end
    end

    if amountToAdd == 0 then
        Notify:Danger( ply, "Nicht genug Platz", "Du hast nicht genug Platz im Inventar, um etwas aufzuheben!" )
        return 0
    end

    char:GiveResource( resource, amountToAdd )
    return amountToAdd
end


---- Ingots ----

Crafting.Config.Ingots["ash"] = {
    PrintName = "Asche",
    Source = "coal",
    AmountProSmelt = 10,
    Model = "models/generic/ir_trashbags_01.mdl",
    Weight = 0.01,
    Space = 0.01
}

Crafting.Config.Ingots["copper_ingot"] = {
    PrintName = "Kupferbarren",
    Source = "copper",
    AmountProSmelt = 15,
    Model = "models/sterling/crafting_metal.mdl",
    Color = Color( 184, 115, 51, 255 ),
    Weight = 0.01,
    Space = 0.01
}

Crafting.Config.Ingots["steel_ingot"] = {
    PrintName = "Stahlbarren",
    Source = "iron",
    AmountProSmelt = 10,
    Model = "models/sterling/crafting_metal.mdl",
    Weight = 0.01,
    Space = 0.01
}

Crafting.Config.Ingots["netanium_ingot"] = {
    PrintName = "Netaniumbarren",
    Source = "netanium",
    AmountProSmelt = 5,
    Model = "models/sterling/crafting_metal.mdl",
    Color = Color( 91, 193, 253, 255 ),
    Weight = 0.01,
    Space = 0.01
}


-- Same as with the resources, but for ingots.
function Crafting.Config.PickupFunctions:Ingots( ply, ent, ingot, ingotData, amountInEntity )
    local char = ply:GetCurrentCharacter()
    if not char then return 0 end

    local space = char:GetInventorySpace()
    local maxSpace = char:GetInventoryMaxSpace()
    local itemSpace = ingotData.Space or CInventory.DefaultSlotsPerResource

    local amountToAdd = 0

    for i = 1, amountInEntity do
        space = space + itemSpace
        if space <= maxSpace then
            amountToAdd = amountToAdd + 1
        end
    end

    if amountToAdd == 0 then
        Notify:Danger( ply, "Nicht genug Platz", "Du hast nicht genug Platz im Inventar, um etwas aufzuheben!" )
        return 0
    end

    char:GiveResource( ingot, amountToAdd )
    return amountToAdd
end


---- Craftings ----

--[[Crafting.Config.Craftings["earthbag"] = {
    PrintName = "Erdsack",
    Recipe = { ["dirt"] = 10 },
    CraftAmount = 1,
    CraftTime = 3,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 3,
    Space = 1
}]]

Crafting.Config.Craftings["copper_plate"] = {
    PrintName = "Kupferplatte",
    Recipe = { ["copper_ingot"] = 10 },
    CraftAmount = 1,
    CraftTime = 1,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 2,
    Space = 2
}

Crafting.Config.Craftings["copper_wire"] = {
    PrintName = "Kupferdraht",
    Recipe = { ["copper_plate"] = 1 },
    CraftAmount = 10,
    CraftTime = 1,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 0.2,
    Space = 0.2
}

Crafting.Config.Craftings["steel_plate"] = {
    PrintName = "Stahlplatten",
    Recipe = { ["steel_ingot"] = 5 },
    CraftAmount = 1,
    CraftTime = 1,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["track_parts"] = {
    PrintName = "Ketten Bauteile",
    Recipe = { ["netanium_plates"] = 10, ["bolt"] = 50 },
    CraftAmount = 1,
    CraftTime = 1,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 5,
    Space = 5
}

Crafting.Config.Craftings["cannon_parts"] = {
    PrintName = "Kanonen Bauteile",
    Recipe = { ["steel_ingot"] = 100 },
    CraftAmount = 1,
    CraftTime = 1,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 5,
    Space = 5
}

Crafting.Config.Craftings["gun_parts"] = {
    PrintName = "Geschütz Bauteile",
    Recipe = { ["steel_ingot"] = 50 },
    CraftAmount = 1,
    CraftTime = 1,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["turret_parts"] = {
    PrintName = "Turm Bauteile",
    Recipe = { ["steel_plate"] = 15, ["bolt"] = 100 },
    CraftAmount = 1,
    CraftTime = 1,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 6,
    Space = 6
}

Crafting.Config.Craftings["netanium_plates"] = {
    PrintName = "Netaniumplatten",
    Recipe = { ["netanium_ingot"] = 5 },
    CraftAmount = 1,
    CraftTime = 1,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 4,
    Space = 4
}

Crafting.Config.Craftings["bracket"] = {
    PrintName = "Halterungen",
    Recipe = { ["steel_ingot"] = 1 },
    CraftAmount = 3,
    CraftTime = 1,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 0.1,
    Space = 0.1
}

Crafting.Config.Craftings["bolt"] = {
    PrintName = "Bolzen",
    Recipe = { ["steel_ingot"] = 1 },
    CraftAmount = 5,
    CraftTime = 1,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 0.1,
    Space = 0.1
}

Crafting.Config.Craftings["electronic_parts"] = {
    PrintName = "Elektronikbauteile",
    Recipe = { ["copper_plate"] = 20, ["copper_wire"] = 100, ["netanium_ingot"] = 5},
    CraftAmount = 10,
    CraftTime = 1,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 0.2,
    Space = 0.2
}

Crafting.Config.Craftings["rotors"] = {
    PrintName = "Rotoren Bauteile",
    Recipe = { ["steel_plate"] = 15, ["copper_wire"] = 50, ["bracket"] = 20, ["bolt"] = 30  },
    CraftAmount = 1,
    CraftTime = 1,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 7,
    Space = 7
}

Crafting.Config.Craftings["motors"] = {
    PrintName = "Motoren Bauteile",
    Recipe = { ["steel_plate"] = 20, ["copper_wire"] = 40, ["bracket"] = 30, ["bolt"] = 100 },
    CraftAmount = 1,
    CraftTime = 1,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 8,
    Space = 8
}

Crafting.Config.Craftings["aimingcomputer"] = {
    PrintName = "Zielcomputer",
    Recipe = { ["electronic_parts"] = 100, ["netanium_plates"] = 5, ["bracket"] = 30  },
    CraftAmount = 1,
    CraftTime = 1,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 5,
    Space = 5
}

Crafting.Config.Craftings["mrap_parts"] = {
    PrintName = "MRAP Bauteil",
    Recipe = { ["steel_plate"] = 50, ["motors"] = 1, ["bolt"] = 50, ["gun_parts"] = 2 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["armored_transporter_parts"] = {
    PrintName = "Gepanzerter Transporter Bauteil",
    Recipe = { ["steel_plate"] = 100, ["motors"] = 1, ["bolt"] = 75, ["gun_parts"] = 2},
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["light_wheeled_tank"] = {
    PrintName = "Radpanzer Bauteil",
    Recipe = { ["steel_plate"] = 150, ["motors"] = 1, ["bolt"] = 100, ["gun_parts"] = 3, ["cannon_parts"] = 1, ["turret_parts"] = 1 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["flak_tank"] = {
    PrintName = "Flakpanzer Bauteil",
    Recipe = { ["steel_plate"] = 200, ["motors"] = 1, ["bolt"] = 300, ["gun_parts"] = 10, ["turret_parts"] = 1, ["track_parts"] = 1, ["aimingcomputer"] = 1 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["light_tank"] = {
    PrintName = "Leichter Panzer Bauteil",
    Recipe = { ["steel_plate"] = 175, ["motors"] = 1, ["bolt"] = 150, ["gun_parts"] = 5, ["turret_parts"] = 1, ["cannon_parts"] = 1, ["track_parts"] = 1 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["armored_tank"] = {
    PrintName = "Verstärkter Panzer Bauteil",
    Recipe = { ["steel_plate"] = 200, ["motors"] = 1, ["bolt"] = 175, ["gun_parts"] = 8, ["turret_parts"] = 1, ["cannon_parts"] = 1, ["track_parts"] = 1 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["heavy_tank"] = {
    PrintName = "Schwerer Panzer Bauteil",
    Recipe = { ["netanium_plates"] = 100, ["steel_plate"] = 250, ["motors"] = 1, ["bolt"] = 200, ["gun_parts"] = 8, ["turret_parts"] = 2, ["cannon_parts"] = 2, ["track_parts"] = 2 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["heavy_tank_mk2"] = {
    PrintName = "Schwerer Panzer MK.2 Bauteil",
    Recipe = { ["netanium_plates"] = 125, ["steel_plate"] = 300, ["motors"] = 1, ["bolt"] = 250, ["gun_parts"] = 8, ["turret_parts"] = 2, ["cannon_parts"] = 2, ["track_parts"] = 2 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["tank_destroyer"] = {
    PrintName = "Jagdpanzer Bauteil",
    Recipe = { ["netanium_plates"] = 50, ["steel_plate"] = 200, ["motors"] = 1, ["bolt"] = 175, ["cannon_parts"] = 4, ["track_parts"] = 2 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["light_flak"] = {
    PrintName = "Leichte Flak Bauteil",
    Recipe = { ["bolt"] = 200, ["gun_parts"] = 10, ["steel_plate"] = 50, ["bracket"] = 100 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["heavy_flak"] = {
    PrintName = "Schwere Flak Bauteil",
    Recipe = { ["bolt"] = 300, ["gun_parts"] = 20, ["steel_plate"] = 100, ["bracket"] = 200  },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["light_mg"] = {
    PrintName = "Leichtes MG Bauteil",
    Recipe = { ["bolt"] = 100, ["gun_parts"] = 5, ["steel_plate"] = 30, ["bracket"] = 50 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["heavy_mg"] = {
    PrintName = "Schweres MG Bauteil",
    Recipe = { ["bolt"] = 200, ["gun_parts"] = 10, ["steel_plate"] = 80, ["bracket"] = 100 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["mortar"] = {
    PrintName = "Mörser Bauteil",
    Recipe = { ["bolt"] = 250, ["gun_parts"] = 15, ["steel_plate"] = 100, ["bracket"] = 125 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["anti_tank_spike"] = {
    PrintName = "Tschechien Igel Bauteil",
    Recipe = { ["steel_ingot"] = 150 },
    CraftAmount = 5,
    CraftTime = 3,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 1,
    Space = 1
}

Crafting.Config.Craftings["light_cannon"] = {
    PrintName = "Leichte Panzerabwehr Bauteil",
    Recipe = { ["bolt"] = 125, ["cannon_parts"] = 10, ["steel_plate"] = 75, ["bracket"] = 100 },
    CraftAmount = 10,
    CraftTime = 3,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["heavy_cannon"] = {
    PrintName = "Schwere Panzerabwehr Bauteil",
    Recipe = { ["bolt"] = 200, ["cannon_parts"] = 30, ["steel_plate"] = 100, ["bracket"] = 150 },
    CraftAmount = 10,
    CraftTime = 3,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 5,
    Space = 5
}

Crafting.Config.Craftings["transport_helicopter"] = {
    PrintName = "Transport Helikopter Bauteil",
    Recipe = { ["bolt"] = 200, ["gun_parts"] = 30, ["steel_plate"] = 75, ["bracket"] = 175, ["rotors"] = 6, },
    CraftAmount = 10,
    CraftTime = 3,
    Model = "models/props_trenches/sandbag01.mdl",
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["light_helicopter"] = {
    PrintName = "Leichter Kampfhelikopter Bauteil",
    Recipe = { ["netanium_plates"] = 75, ["steel_plate"] = 150, ["rotors"] = 4, ["bolt"] = 125, ["gun_parts"] = 20 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

Crafting.Config.Craftings["heavy_helicopter"] = {
    PrintName = "Schwerer Kampfhelikopter Bauteil",
    Recipe = { ["netanium_plates"] = 150, ["steel_plate"] = 200, ["rotors"] = 8, ["bolt"] = 200, ["gun_parts"] = 30 },
    CraftAmount = 10,
    CraftTime = 5,
    Model = "models/props_debris/metal_panel02a.mdl",
    Color = Color( 255, 145, 90, 255 ),
    Weight = 3,
    Space = 3
}

-- Same as with the resources, but for the craftable items.
function Crafting.Config.PickupFunctions:Craftings( ply, ent, item, itemData, amountInEntity )
    local char = ply:GetCurrentCharacter()
    if not char then return 0 end

    local space = char:GetInventorySpace()
    local maxSpace = char:GetInventoryMaxSpace()
    local itemSpace = itemData.Space or CInventory.DefaultSlotsPerResource

    local amountToAdd = 0

    for i = 1, amountInEntity do
        space = space + itemSpace
        if space <= maxSpace then
            amountToAdd = amountToAdd + 1
        end
    end

    if amountToAdd == 0 then
        Notify:Danger( ply, "Nicht genug Platz", "Du hast nicht genug Platz im Inventar, um etwas aufzuheben!" )
        return 0
    end

    char:GiveResource( item, amountToAdd )
    return amountToAdd
end