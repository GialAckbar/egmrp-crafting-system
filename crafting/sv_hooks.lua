hook.Add( "SQL.Ready", "Crafting.SpawnOres", function()
    if Crafting.CacheInitialized then return end
    Crafting:LoadEntityData()
    Crafting.CacheInitialized = true
end )

hook.Add( "PostCleanupMap", "Crafting.SpawnOres", function()
    Crafting:SpawnEverything()
end )

hook.Add( "ShutDown", "Crafting.SaveOnShutdown", function()
    Crafting:SaveEntityData()
end )

hook.Add( "SQL.CreateTables", "Crafting.CreateSQLTable", function()
    SQL:CreateTableIfNotExists( "crafting_entities", {
        { name = "config_id", definition = "INT PRIMARY KEY" },
        { name = "data", definition = "TEXT NOT NULL" }
    } )
end )