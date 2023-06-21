include( "shared.lua" )

Crafting.Smelter = {}
Crafting.Smelter.CurData = {}
Crafting.Smelter.CurEnt = 0

local baseFont = "CW_HUD72"
local ammoText = "CW_HUD60"

ENT.DisplayDistance = 256

ENT.UpOffset = Vector( 0, 0, 40 )
ENT.BaseHorSize = 620
ENT.HalfBaseHorSize = ENT.BaseHorSize * 0.5
ENT.VertFontSize = 72
ENT.HalfVertFontSize = ENT.VertFontSize * 0.5

function ENT:Draw()
	self:DrawModel()

	local ply = LocalPlayer()
	if ply:GetPos():Distance( self:GetPos() ) > self.DisplayDistance then
		return
	end

	local eyeAng = EyeAngles()
	eyeAng.p = 0
	eyeAng.y = eyeAng.y - 90
	eyeAng.r = 90

	cam.Start3D2D( self:GetPos() + self.UpOffset, eyeAng, 0.05 )
		local r, g, b, a = CustomizableWeaponry.ITEM_PACKS_TOP_COLOR.r, CustomizableWeaponry.ITEM_PACKS_TOP_COLOR.g, CustomizableWeaponry.ITEM_PACKS_TOP_COLOR.b, CustomizableWeaponry.ITEM_PACKS_TOP_COLOR.a
		surface.SetDrawColor( r, g, b, a )
		surface.DrawRect( -self.HalfBaseHorSize, 0, self.BaseHorSize, self.VertFontSize )

		surface.SetDrawColor( 0, 0, 0, 150 )
		surface.DrawRect( -self.HalfBaseHorSize, self.VertFontSize, self.BaseHorSize, self.VertFontSize * 3 )

		draw.ShadowText( "Schmelzofen", baseFont, 0, self.HalfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		local activated = self:GetNWBool( "IsActivated", false )

        if activated then
            draw.ShadowText( "Angeschaltet", ammoText, 0, self.VertFontSize + self.HalfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.ShadowText( self:GetNWBool( "HasBurnMaterials", false ) and "Schmelze ..." or "Kein Brennmaterial!", ammoText, 0, self.VertFontSize * 2 + self.HalfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        else
            draw.ShadowText( "Ausgeschaltet", ammoText, 0, self.VertFontSize * 2 + self.HalfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
	cam.End3D2D()
end

function Crafting.Smelter:OpenInventory( entIndex, nextOutput )
    self:CloseMenu()

    local ply = LocalPlayer()
    if not ply:Alive() then return end

    local char = ply:GetCurrentCharacter()
    if not char then return end

    local w, h = ScrW() * 0.6, ScrH() * 0.6
    self.Frame = Crafting.UI:CreateFrame( "Schmelzofen", w, h )

    self.InventorySearchBar = vgui.Create( "DTextEntry", self.Frame )
    self.InventorySearchBar:SetSize( w * 0.3, h * 0.05 )
    self.InventorySearchBar:SetPos( w * 0.03, h * 0.17 )
    self.InventorySearchBar:SetPlaceholderText( "Inventar durchsuchen ..." )
    self.InventorySearchBar:SetUpdateOnType( true )
    function self.InventorySearchBar:OnValueChange( value )
        Crafting.Smelter.Inventory:Refresh( value )
    end
    function self.InventorySearchBar:OnGetFocus()
        self:SelectAll()
    end

    self.Inventory = vgui.Create( "EGMListView", self.Frame )
    self.Inventory:SetSize( w * 0.3, h * 0.7 )
    self.Inventory:SetPos( w * 0.03, h * 0.25 )
    self.Inventory:SetMultiSelect( false )
    self.Inventory:SetSortable( false )
    self.Inventory:SetHeaderHeight( h * 0.05 )
    self.Inventory:SetDataHeight( h * 0.05 )
    self.Inventory:AddCustomColumn( "Dein Inventar" )
    function self.Inventory:OnRowSelected( index, line )
        for _, l in pairs( Crafting.Smelter.Storage:GetLines() ) do
            l:SetSelected( false )
        end

        Crafting.Smelter.TransferButton.Text = "Einlagern"
    end
    function self.Inventory:Refresh( searchValue )
        if not searchValue then searchValue = "" end
        self:Clear()

        local items = {}

        for resource, amount in pairs( char:GetResources() ) do
            if not ( Crafting:IsResource( resource ) or Crafting:IsIngot( resource ) ) then continue end

            local itemData = Crafting:FindItemData( resource )
            if not itemData then continue end

            table.insert( items, {
                Name = itemData.PrintName or resource,
                Class = resource,
                Amount = amount
            } )
        end

        for _, itemData in SortedPairsByMemberValue( items, "Name" ) do
            if string.find( string.lower( itemData.Name ), string.lower( searchValue ) ) then
                local line = self:AddCustomLine( itemData.Amount .. "x " .. itemData.Name )
                line.itemData = itemData
            end
        end
    end
    self.Inventory:Refresh()

    self.StorageSearchBar = vgui.Create( "DTextEntry", self.Frame )
    self.StorageSearchBar:SetSize( w * 0.3, h * 0.05 )
    self.StorageSearchBar:SetPos( w - ( w * 0.03 ) - self.StorageSearchBar:GetWide(), h * 0.17 )
    self.StorageSearchBar:SetPlaceholderText( "Schmelzofen durchsuchen ..." )
    self.StorageSearchBar:SetUpdateOnType( true )
    function self.StorageSearchBar:OnValueChange( value )
        Crafting.Smelter.Storage:Refresh( value )
    end
    function self.StorageSearchBar:OnGetFocus()
        self:SelectAll()
    end

    self.Storage = vgui.Create( "EGMListView", self.Frame )
    self.Storage:SetSize( w * 0.3, h * 0.7 )
    self.Storage:SetPos( w - ( w * 0.03 ) - self.Storage:GetWide(), h * 0.25 )
    self.Storage:SetMultiSelect( false )
    self.Storage:SetSortable( false )
    self.Storage:SetHeaderHeight( h * 0.05003 )
    self.Storage:SetDataHeight( h * 0.05003 )
    self.Storage:AddCustomColumn( "Schmelzofen" )
    function self.Storage:OnRowSelected( index, line )
        for _, l in pairs( Crafting.Smelter.Inventory:GetLines() ) do
            l:SetSelected( false )
        end

        Crafting.Smelter.TransferButton.Text = "Rausholen"
    end
    function self.Storage:Refresh( searchValue )
        if not searchValue then searchValue = "" end
        self:Clear()

        local items = {}

        for resource, amount in pairs( Crafting.Smelter.CurData.Input ) do
            local itemData = Crafting:FindItemData( resource )
            if not itemData then continue end

            table.insert( items, {
                Name = itemData.PrintName or resource,
                Class = resource,
                Amount = amount
            } )
        end

        for resource, amount in pairs( Crafting.Smelter.CurData.Output ) do
            local itemData = Crafting:FindItemData( resource )
            if not itemData then continue end

            table.insert( items, {
                Name = itemData.PrintName or resource,
                Class = resource,
                Amount = amount
            } )
        end

        for _, itemData in SortedPairsByMemberValue( items, "Name" ) do
            if string.find( string.lower( itemData.Name ), string.lower( searchValue ) ) then
                local line = self:AddCustomLine( itemData.Amount .. "x " .. itemData.Name )
                line.itemData = itemData
            end
        end
    end
    self.Storage:Refresh()

    self.TransferAmount = vgui.Create( "DTextEntry", self.Frame )
    self.TransferAmount:SetSize( w * 0.1, h * 0.04 )
    self.TransferAmount:SetPos( w * 0.5 - self.TransferAmount:GetSize() * 0.5, h * 0.54 )
    self.TransferAmount:SetPlaceholderText( "Wie viel übertragen?" )
    function self.TransferAmount:OnGetFocus()
        self:SelectAll()
    end

    self.TransferButton = vgui.Create( "EGMButton", self.Frame )
    self.TransferButton:SetSize( w * 0.1, h * 0.04 )
    self.TransferButton:SetPos( w * 0.5 - self.TransferButton:GetSize() * 0.5, h * 0.6 )
    self.TransferButton:SetText( "" )
    self.TransferButton.Text = "Einlagern"
    function self.TransferButton:Paint( width, height )
        draw.RoundedBox( 5, 0, 0, width, height, GetColor( "gray", 250 ) )
        draw.SimpleText( self.Text, "DermaDefault", width / 2, height / 2, UI.ForegroundColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    function self.TransferButton:DoClick()
        local amount = tonumber( Crafting.Smelter.TransferAmount:GetValue() )
        if not amount or amount <= 0 then
            Notify:Danger( "Ungültige Anzahl!", "Deine übergebene Zahl muss eine Zahl größer 0 sein!" )
            return
        end

        if self.Text == "Einlagern" then
            local _, line = Crafting.Smelter.Inventory:GetSelectedLine()
            if IsValid( line ) and line.itemData then
                Crafting.Smelter:TransferItem( Crafting.Smelter.CurEnt, line.itemData.Class, amount, false )
            end
        elseif self.Text == "Rausholen" then
            local _, line = Crafting.Smelter.Storage:GetSelectedLine()
            if IsValid( line ) and line.itemData then
                Crafting.Smelter:TransferItem( Crafting.Smelter.CurEnt, line.itemData.Class, amount, true )
            end
        end
    end

    self.ActivateButton = vgui.Create( "EGMButton", self.Frame )
    self.ActivateButton:SetSize( w * 0.1, h * 0.04 )
    self.ActivateButton:SetPos( w * 0.5 - self.ActivateButton:GetSize() * 0.5, h * 0.8 )
    self.ActivateButton:SetText( "" )
    function self.ActivateButton:Paint( width, height )
        draw.RoundedBox( 5, 0, 0, width, height, GetColor( "gray", 250 ) )

        local ent = Entity( Crafting.Smelter.CurEnt )
        if IsValid( ent ) then
            draw.SimpleText( ent:GetNWBool( "IsActivated", false ) and "Ausschalten" or "Anschalten", "DermaDefault", width / 2, height / 2, UI.ForegroundColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        else
            draw.SimpleText( "<Fehler>", "DermaDefault", width / 2, height / 2, UI.ForegroundColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end
    function self.ActivateButton:DoClick()
        local ent = Entity( Crafting.Smelter.CurEnt )
        if not IsValid( ent ) then return end
        ent:SetActivated( not ent:GetNWBool( "IsActivated", false ) )
    end

    self.WIPLabel = vgui.Create( "DLabel", self.Frame )
    self.WIPLabel:SetPos( w * 0.03, h * 0.955 )
    self.WIPLabel:SetSize( w * 0.25555, 0 )
    self.WIPLabel:SetAutoStretchVertical( true )
    self.WIPLabel:SetFont( "EGMText8" )
    --self.WIPLabel:SetTextColor( UI.ForegroundColor )
    self.WIPLabel:SetText( "Menü Work in Progress" )

    self.CurEnt = entIndex
    self.Frame:MakePopup()
end

function Crafting.Smelter:CloseMenu()
    if IsValid( self.Frame ) then
        self.Frame:Close()
        self.CurEnt = 0
        self.CurData = {}
    end
end

function Crafting.Smelter:TransferItem( entIndex, class, amount, toPlayer )
    net.Start( "Crafting.Smelter.Transfer" )
        net.WriteUInt( entIndex, 16 )
        net.WriteString( class )
        net.WriteUInt( amount, 32 )
        net.WriteBool( toPlayer )
    net.SendToServer()
end

net.Receive( "Crafting.Smelter.UpdateInventory", function()
    if not IsValid( Crafting.Smelter.Frame ) then return end

    local selectedClass
    for _, line in pairs( Crafting.Smelter.Inventory:GetLines() ) do
        if line:IsSelected() then
            selectedClass = line.itemData.Class
        end
    end

    local searchValue = Crafting.Smelter.InventorySearchBar:GetValue()
    if not searchValue then searchValue = "" end

    Crafting.Smelter.Inventory:Refresh( searchValue )

    for _, line in pairs( Crafting.Smelter.Inventory:GetLines() ) do
        if line.itemData.Class == selectedClass then
            line:SetSelected( true )
        end
    end
end )

net.Receive( "Crafting.Smelter.OpenMenu", function()
    local entIndex = net.ReadUInt( 16 )
    Crafting.Smelter.CurData = net.ReadTable()
    local nextOutput = net.ReadUInt( 32 )
    Crafting.Smelter:OpenInventory( entIndex, nextOutput )
end )