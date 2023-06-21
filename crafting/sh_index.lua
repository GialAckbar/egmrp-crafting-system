Crafting = Crafting or {}
--Crafting.SpawnedEntities = Crafting.SpawnedEntities or {}

Crafting.UI = {}
Crafting.Config = {}
Crafting.Config.Smelter = {}
Crafting.Config.Workbench = {}
Crafting.Config.Resources = {}
Crafting.Config.Ingots = {}
Crafting.Config.Craftings = {}
Crafting.Config.PickupFunctions = {}
Crafting.Config.SmelterLocations = {}
Crafting.Config.WorkbenchLocations = {}
Crafting.Config.OreLocations = {}
Crafting.SmelterRecipes = {}


local mainpath = GAMEMODE.FolderName .. "/gamemode/modules/crafting"
local configs = file.Find( mainpath .. "/configs/*.lua", "LUA" )

for _, fileName in pairs( configs ) do
    if SERVER then AddCSLuaFile( mainpath .. "/configs/" .. fileName ) end
    include( mainpath .. "/configs/" .. fileName )
end

if SERVER then
    AddCSLuaFile( "sh_crafting.lua" )
    AddCSLuaFile( "cl_crafting.lua" )

    include( "sh_crafting.lua" )
    include( "sv_crafting.lua" )
    include( "sv_hooks.lua" )
    include( "sv_sql.lua" )
end

if CLIENT then
    include( "sh_crafting.lua" )
    include( "cl_crafting.lua" )
end