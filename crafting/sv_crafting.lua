function Crafting:SpawnSmelters()
    local map = game.GetMap()
    if not Crafting.Config.SmelterLocations[map] then return end

    for _, smelterData in ipairs( Crafting.Config.SmelterLocations[map] ) do
        local smelter = ents.Create( "egmrp_smelter" )
        smelter:SetPos( smelterData.Position )
        smelter:SetAngles( smelterData.Angle )
        smelter:Spawn()
        local phys = smelter:GetPhysicsObject()
        if phys then phys:EnableMotion( false ) end
        timer.Simple( 0, function()
            local configID = smelterData.ConfigID
            self.DBCache[configID] = self.DBCache[configID] or table.Copy( smelter.Data )

            if not self.DBCache[configID].Smelter then
                print( "[CRAFTING] ConfigID " .. configID .. " does not contain data for a smelter. Resetting ConfigID " .. configID .. " ..." )
                self.DBCache[configID] = table.Copy( smelter.Data )
            end

            smelter.ConfigID = configID
            smelter.Data = self.DBCache[configID]

            smelter:SetActivated( smelter.Data.Activated )
            smelter:CheckBurnMaterials()
            smelter:UpdateSpace()
        end )
    end
end

function Crafting:SpawnWorkbenches()
    local map = game.GetMap()
    if not Crafting.Config.WorkbenchLocations[map] then return end

    for _, workbenchData in ipairs( Crafting.Config.WorkbenchLocations[map] ) do
        local workbench = ents.Create( "egmrp_workbench" )
        workbench:SetPos( workbenchData.Position )
        workbench:SetAngles( workbenchData.Angle )
        workbench:Spawn()
        local phys = workbench:GetPhysicsObject()
        if phys then phys:EnableMotion( false ) end
        timer.Simple( 0, function()
            local configID = workbenchData.ConfigID
            self.DBCache[configID] = self.DBCache[configID] or table.Copy( workbench.Data )

            if not self.DBCache[configID].Workbench then
                print( "[CRAFTING] ConfigID " .. configID .. " does not contain data for a workbench. Resetting ConfigID " .. configID .. " ..." )
                self.DBCache[configID] = table.Copy( workbench.Data )
            end

            workbench.ConfigID = configID
            workbench.Data = self.DBCache[configID]

            workbench:UpdateSpace()
        end )
    end
end

function Crafting:SpawnOres()
    local map = game.GetMap()
    if not Crafting.Config.OreLocations[map] then return end
    for _, oreData in ipairs( Crafting.Config.OreLocations[map] ) do
        if not oreData.Resource or not scripted_ents.GetStored( "egmrp_" .. oreData.Resource .. "_ore" ) then continue end
        local ore = ents.Create( "egmrp_" .. oreData.Resource .. "_ore" )
        ore:SetPos( oreData.Position )
        ore:SetAngles( oreData.Angle )
        ore:Spawn()
    end
end

function Crafting:SpawnEverything()
    self:SpawnSmelters()
    self:SpawnWorkbenches()
    self:SpawnOres()
end