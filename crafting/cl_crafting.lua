function Crafting.UI:CreateFrame( title, w, h )
    title = title or ""
    w = w or ScrW() * 0.5
    h = h or ScrH() * 0.5

    local frame = vgui.Create( "DFrame" )
    frame:SetSize( w, h )
    frame:Center()
    frame:SetTitle( "" )
    frame:ShowCloseButton( false )
    function frame:Paint( width, height )
        draw.RoundedBox( 0, 0, 0, width, height, GetColor( "darkgray", 230 ) )
        self:DrawOutlinedRect()
    end

    local titlePanel = vgui.Create( "DPanel", frame )
    titlePanel:SetPos( w * 0.1, h * 0.01 )
    titlePanel:SetSize( w * 0.8, h * 0.12 )
    function titlePanel:Paint( width, height )
        draw.RoundedBox( 0, w * 0.05, 0, width - w * 0.05 * 2, height, UI.BackgroundColor2 )
        surface.SetDrawColor( UI.BackgroundColor2 )
        draw.NoTexture()

        surface.DrawPoly( {
            { x = 0, y = 0 },
            { x = w * 0.051, y = 0 },
            { x = w * 0.051, y = height }
        } )

        surface.DrawPoly( {
            { x = width - w * 0.051, y = 0 },
            { x = width, y = 0 },
            { x = width - w * 0.051, y = height }
        } )

        draw.DrawText( title, "EGMText16", width / 2, height * 0.2, UI.ForegroundColor, TEXT_ALIGN_CENTER )
    end

    local closeBtn = vgui.Create( "EGMCloseButton", frame )
    closeBtn:SetPanel( frame )
    closeBtn:SetPos( w * 0.94, h * 0.01 )
    closeBtn:SetSize( h * 0.07, h * 0.07 )

    return frame
end

net.Receive( "Crafting.SendData", function()
    local ent = net.ReadEntity()
    local input = net.ReadTable()
    local output = net.ReadTable()

    if IsValid( Crafting.Smelter.Frame ) then
        if not IsValid( ent ) or Crafting.Smelter.CurEnt ~= ent:EntIndex() then return end

        Crafting.Smelter.CurData = { Input = input, Output = output, Activated = Crafting.Smelter.CurData.Activated }

        local selectedClass
        for _, line in pairs( Crafting.Smelter.Storage:GetLines() ) do
            if line:IsSelected() then
                selectedClass = line.itemData.Class
            end
        end

        local searchValue = Crafting.Smelter.StorageSearchBar:GetValue()
        if not searchValue then searchValue = "" end

        Crafting.Smelter.Storage:Refresh( searchValue )

        for _, line in pairs( Crafting.Smelter.Storage:GetLines() ) do
            if line.itemData.Class == selectedClass then
                line:SetSelected( true )
            end
        end
    elseif IsValid( Crafting.Workbench.Frame ) then
        if not IsValid( ent ) or Crafting.Workbench.CurEnt ~= ent:EntIndex() then return end

        Crafting.Workbench.CurData = { Input = input, Output = output }

        local selectedClass
        for _, line in pairs( Crafting.Workbench.Storage:GetLines() ) do
            if line:IsSelected() then
                selectedClass = line.itemData.Class
            end
        end

        local searchValue = Crafting.Workbench.StorageSearchBar:GetValue()
        if not searchValue then searchValue = "" end

        Crafting.Workbench.Storage:Refresh( searchValue )

        for _, line in pairs( Crafting.Workbench.Storage:GetLines() ) do
            if line.itemData.Class == selectedClass then
                line:SetSelected( true )
            end
        end
    end
end )