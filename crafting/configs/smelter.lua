-- Model of the smelter
Crafting.Config.Smelter.Model = "models/props_wasteland/laundry_washer003.mdl"

-- Consumes 1 material per smelting process, unless there is an ingot with that material as the source. 
-- In that case, "AmountProSmelt" amounts will be consumed (e.g. "ash" for "coal").
Crafting.Config.Smelter.BurnMaterials = {
    ["coal"] = true
}

-- How long should a smelting process take? (in seconds)
Crafting.Config.Smelter.BurnTime = 15

-- How much space should the smelter have in the input?
Crafting.Config.Smelter.InputSpace = 999999

-- How much space should the smelter have in the output?
Crafting.Config.Smelter.OutputSpace = 999999