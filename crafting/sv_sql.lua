function Crafting:LoadEntityData()
    self.DBCache = {}
    SQL:Query( "SELECT * FROM `crafting_entities`", function( success, query )
        if not success then
            print( "[CRAFTING] Error while reading from the DB" )
            return
        end

        for _, row in ipairs( query[1].data ) do
            local config_id = row.config_id
            local data = util.JSONToTable( row.data )

            if not config_id or not data then continue end
            self.DBCache[config_id] = data
        end

        self:SpawnEverything()
    end )
end

function Crafting:SaveEntityData()
    local sqlString = ""
    local success = true

    for config_id, data in pairs( self.DBCache ) do
        local json = util.TableToJSON( data )
        sqlString = sqlString .. "INSERT INTO `crafting_entities` VALUES (" .. config_id .. ", '" .. json .. "') ON DUPLICATE KEY UPDATE `data` = '" .. json .. "';"
    end

    if sqlString == "" then return end

    SQL:Query( sqlString, function( querySuccess )
        if querySuccess then return end
        print( "[CRAFTING] Error while saving the entities" )
        success = false
    end )

    return success
end


if timer.Exists( "Crafting.SaveData" ) then
    timer.Remove( "Crafting.SaveData" )
end

timer.Create( "Crafting.SaveData", 60, 0, function()
    Crafting:SaveEntityData()
end )