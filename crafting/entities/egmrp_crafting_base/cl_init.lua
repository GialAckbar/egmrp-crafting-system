include( "shared.lua" )

function ENT:Draw()
    self:DrawModel()
end

--[[net.Receive( "Crafting.SendData", function()
    local entity = net.ReadEntity()
    entity.Data.Input = net.ReadTable()
    entity.Data.Output = net.ReadTable()
end )]]