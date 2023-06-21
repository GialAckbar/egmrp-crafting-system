include( "shared.lua" )

Crafting.Workbench = {}
Crafting.Workbench.CurData = {}
Crafting.Workbench.CurEnt = 0

function Crafting.Workbench:OpenInventory( entIndex )
    self:CloseMenu()

    local ply = LocalPlayer()
    if not ply:Alive() then return end

    local char = ply:GetCurrentCharacter()
    if not char then return end

    local w, h = ScrW() * 0.6, ScrH() * 0.6
    self.Frame = Crafting.UI:CreateFrame( "Werkbank", w, h )

    self.InventorySearchBar = vgui.Create( "DTextEntry", self.Frame )
    self.InventorySearchBar:SetSize( w * 0.3, h * 0.05 )
    self.InventorySearchBar:SetPos( w * 0.03, h * 0.17 )
    self.InventorySearchBar:SetPlaceholderText( "Inventar durchsuchen ..." )
    self.InventorySearchBar:SetUpdateOnType( true )
    function self.InventorySearchBar:OnValueChange( value )
        Crafting.Workbench.Inventory:Refresh( value )
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
        for _, l in pairs( Crafting.Workbench.Storage:GetLines() ) do
            l:SetSelected( false )
        end

        Crafting.Workbench.TransferButton.Text = "Einlagern"
    end
    function self.Inventory:Refresh( searchValue )
        if not searchValue then searchValue = "" end
        self:Clear()

        local items = {}

        for resource, amount in pairs( char:GetResources() ) do
            if not Crafting:Exists( resource ) then continue end

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
    self.StorageSearchBar:SetPlaceholderText( "Werkbank durchsuchen ..." )
    self.StorageSearchBar:SetUpdateOnType( true )
    function self.StorageSearchBar:OnValueChange( value )
        Crafting.Workbench.Storage:Refresh( value )
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
    self.Storage:AddCustomColumn( "Werkbank" )
    function self.Storage:OnRowSelected( index, line )
        for _, l in pairs( Crafting.Workbench.Inventory:GetLines() ) do
            l:SetSelected( false )
        end

        Crafting.Workbench.TransferButton.Text = "Rausholen"
    end
    function self.Storage:Refresh( searchValue )
        if not searchValue then searchValue = "" end
        self:Clear()

        local items = {}

        for resource, amount in pairs( Crafting.Workbench.CurData.Input ) do
            local itemData = Crafting:FindItemData( resource )
            if not itemData then continue end

            table.insert( items, {
                Name = itemData.PrintName or resource,
                Class = resource,
                Amount = amount
            } )
        end

        --[[for resource, amount in pairs( Crafting.Workbench.CurData.Output ) do
            local itemData = Crafting:FindItemData( resource )
            if not itemData then continue end

            table.insert( items, {
                Name = itemData.PrintName or resource,
                Class = resource,
                Amount = amount
            } )
        end]]

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
    self.TransferAmount:SetPos( w * 0.5 - self.TransferAmount:GetSize() * 0.5, h * 0.8 )
    self.TransferAmount:SetPlaceholderText( "Wie viel übertragen?" )
    function self.TransferAmount:OnGetFocus()
        self:SelectAll()
    end

    self.TransferButton = vgui.Create( "EGMButton", self.Frame )
    self.TransferButton:SetSize( w * 0.1, h * 0.04 )
    self.TransferButton:SetPos( w * 0.5 - self.TransferButton:GetSize() * 0.5, h * 0.86 )
    self.TransferButton:SetText( "" )
    self.TransferButton.Text = "Einlagern"
    function self.TransferButton:Paint( width, height )
        draw.RoundedBox( 5, 0, 0, width, height, GetColor( "gray", 250 ) )
        draw.SimpleText( self.Text, "DermaDefault", width / 2, height / 2, UI.ForegroundColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    function self.TransferButton:DoClick()
        local amount = tonumber( Crafting.Workbench.TransferAmount:GetValue() )
        if not amount or amount <= 0 then
            Notify:Danger( "Ungültige Anzahl!", "Deine übergebene Zahl muss eine Zahl größer 0 sein!" )
            return
        end

        if self.Text == "Einlagern" then
            local _, line = Crafting.Workbench.Inventory:GetSelectedLine()
            if IsValid( line ) and line.itemData then
                Crafting.Workbench:TransferItem( Crafting.Workbench.CurEnt, line.itemData.Class, amount, false )
            end
        elseif self.Text == "Rausholen" then
            local _, line = Crafting.Workbench.Storage:GetSelectedLine()
            if IsValid( line ) and line.itemData then
                Crafting.Workbench:TransferItem( Crafting.Workbench.CurEnt, line.itemData.Class, amount, true )
            end
        end
    end

    self.RecipeSearchBar = vgui.Create( "DTextEntry", self.Frame )
    self.RecipeSearchBar:SetSize( w * 0.26, h * 0.05 )
    self.RecipeSearchBar:SetPos( w * 0.5 - self.RecipeSearchBar:GetWide() * 0.5, h * 0.17 )
    self.RecipeSearchBar:SetPlaceholderText( "Rezepte durchsuchen ..." )
    self.RecipeSearchBar:SetUpdateOnType( true )
    function self.RecipeSearchBar:OnValueChange( value )
        Crafting.Workbench.Recipes:Refresh( value )
    end
    function self.RecipeSearchBar:OnGetFocus()
        self:SelectAll()
    end

    self.Recipes = vgui.Create( "EGMListView", self.Frame )
    self.Recipes:SetSize( w * 0.26, h * 0.3 )
    self.Recipes:SetPos( w * 0.5 - self.Recipes:GetWide() * 0.5, h * 0.25 )
    self.Recipes:SetMultiSelect( false )
    self.Recipes:SetSortable( false )
    self.Recipes:SetHeaderHeight( h * 0.05 )
    self.Recipes:SetDataHeight( h * 0.05 )
    self.Recipes:AddCustomColumn( "Crafting-Rezepte" )
    function self.Recipes:OnRowSelected( index, line )
        local text = ""

        for recipe, amount in pairs( line.itemData.Recipe ) do
            local itemData = Crafting:FindItemData( recipe )
            text = text .. amount .. "x " .. itemData.PrintName .. ", "
        end

        Crafting.Workbench.CraftingMaterials:SetText( "Rezept: " .. string.sub( text, 1, #text - 2 ) )
        Crafting.Workbench.CraftButton.CraftTime = line.itemData.CraftTime
        Crafting.Workbench.CraftButton.Text = "Craften (" .. line.itemData.CraftTime .. ")"
    end
    function self.Recipes:Refresh( searchValue )
        if not searchValue then searchValue = "" end
        self:Clear()

        local items = {}

        for resource, data in pairs( Crafting.Config.Craftings or {} ) do
            table.insert( items, {
                Name = data.PrintName or resource,
                Class = resource,
                CraftAmount = data.CraftAmount,
                Recipe = data.Recipe,
                CraftTime = data.CraftTime
            } )
        end

        for _, itemData in SortedPairsByMemberValue( items, "Name" ) do
            if string.find( string.lower( itemData.Name ), string.lower( searchValue ) ) then
                local line = self:AddCustomLine( itemData.CraftAmount .. "x " .. itemData.Name )
                line.itemData = itemData
            end
        end

        if #self:GetLines() > 0 then
            self:SelectFirstItem()
        else
            Crafting.Workbench.CraftingMaterials:SetText( "" )
        end
    end

    self.CraftingMaterials = vgui.Create( "DLabel", self.Frame )
    self.CraftingMaterials:SetSize( w, 0 )
    self.CraftingMaterials:SetPos( w * 0.5 - self.CraftingMaterials:GetWide() * 0.5, h * 0.57 )
    self.CraftingMaterials:SetAutoStretchVertical( true )
    self.CraftingMaterials:SetFont( "EGMText6" )
    self.CraftingMaterials:SetTextColor( UI.ForegroundColor )
    self.CraftingMaterials:SetText( "" )
    self.CraftingMaterials:SetContentAlignment( 5 )

    self.CraftButton = vgui.Create( "EGMButton", self.Frame )
    self.CraftButton:SetSize( w * 0.1, h * 0.04 )
    self.CraftButton:SetPos( w * 0.5 - self.TransferButton:GetSize() * 0.5, h * 0.63 )
    self.CraftButton:SetText( "" )
    self.CraftButton.Text = "Craften"
    function self.CraftButton:Paint( width, height )
        draw.RoundedBox( 5, 0, 0, width, height, GetColor( "gray", 250 ) )
        draw.SimpleText( self.Text, "DermaDefault", width / 2, height / 2, UI.ForegroundColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    function self.CraftButton:DoClick()
        local _, line = Crafting.Workbench.Recipes:GetSelectedLine()
        if not IsValid( line ) or not line.itemData then return end

        for neededResource, neededAmount in pairs( line.itemData.Recipe ) do
            local hasResource = false
            for resource, amount in pairs( Crafting.Workbench.CurData.Input ) do
                if neededResource == resource and amount >= neededAmount then
                    hasResource = true
                    break
                end
            end
            if not hasResource then
                Notify:Danger( "Fehlende Ressourcen!", "Es befinden sich nicht genug Ressourcen zum Craften in der Werkbank!" )
                return
            end
        end

        self.CraftTime = ( self.CraftTime or 1 ) - 1

        if self.CraftTime > 0 then
            self.Text = "Craften (" .. self.CraftTime .. ")"
            return
        end

        net.Start( "Crafting.Workbench.BuildItem" )
            net.WriteUInt( Crafting.Workbench.CurEnt, 16 )
            net.WriteString( line.itemData.Class )
        net.SendToServer()

        self.CraftTime = line.itemData.CraftTime
        self.Text = "Craften (" .. self.CraftTime .. ")"
    end

    self.Recipes:Refresh()

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

function Crafting.Workbench:CloseMenu()
    if IsValid( self.Frame ) then
        self.Frame:Close()
        self.CurEnt = 0
        self.CurData = {}
    end
end

function Crafting.Workbench:TransferItem( entIndex, class, amount, toPlayer )
    net.Start( "Crafting.Workbench.Transfer" )
        net.WriteUInt( entIndex, 16 )
        net.WriteString( class )
        net.WriteUInt( amount, 32 )
        net.WriteBool( toPlayer )
    net.SendToServer()
end

net.Receive( "Crafting.Workbench.UpdateInventory", function()
    if not IsValid( Crafting.Workbench.Frame ) then return end

    local selectedClass
    for _, line in pairs( Crafting.Workbench.Inventory:GetLines() ) do
        if line:IsSelected() then
            selectedClass = line.itemData.Class
        end
    end

    local searchValue = Crafting.Workbench.InventorySearchBar:GetValue()
    if not searchValue then searchValue = "" end

    Crafting.Workbench.Inventory:Refresh( searchValue )

    for _, line in pairs( Crafting.Workbench.Inventory:GetLines() ) do
        if line.itemData.Class == selectedClass then
            line:SetSelected( true )
        end
    end
end )

net.Receive( "Crafting.Workbench.OpenMenu", function()
    local entIndex = net.ReadUInt( 16 )
    Crafting.Workbench.CurData = net.ReadTable()
    Crafting.Workbench:OpenInventory( entIndex )
end )