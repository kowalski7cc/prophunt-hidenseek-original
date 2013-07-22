local PANEL = {}

function PANEL:Init()

	self:SetSkin( GAMEMODE.HudSkin )
	self:ParentToHUD()
	
	self.ControlCanvas = vgui.Create( "Panel", self )
	self.ControlCanvas:MakePopup()
	self.ControlCanvas:SetKeyboardInputEnabled( false )
	
	self.lblCountDown = vgui.Create( "DLabel", self.ControlCanvas )
	self.lblCountDown:SetText( "60" )
	
	self.lblActionName = vgui.Create( "DLabel", self.ControlCanvas )
	
	self.ctrlList = vgui.Create( "DPanelList", self.ControlCanvas )
	self.ctrlList:SetDrawBackground( false )
	self.ctrlList:SetSpacing( 2 )
	self.ctrlList:SetPadding( 2 )
	self.ctrlList:EnableHorizontal( true )
	self.ctrlList:EnableVerticalScrollbar()
	
	self.Peeps = {}
	
	for i =1, game.MaxPlayers() do
	
		self.Peeps[i] = vgui.Create( "DImage", self.ctrlList:GetCanvas() )
		self.Peeps[i]:SetSize( 16, 16 )
		self.Peeps[i]:SetZPos( 1000 )
		self.Peeps[i]:SetVisible( false )
		self.Peeps[i]:SetImage( "icon16/emoticon_smile.png" )
	
	end

end

function PANEL:PerformLayout()
	
	local cx, cy = chat.GetChatBoxPos()
	
	self:SetPos( 0, 0 )
	self:SetSize( ScrW(), ScrH() )
	
	self.ControlCanvas:StretchToParent( 0, 0, 0, 0 )
	self.ControlCanvas:SetWide( 550 )
	self.ControlCanvas:SetTall( cy - 30 )
	self.ControlCanvas:SetPos( 0, 30 )
	self.ControlCanvas:CenterHorizontal();
	self.ControlCanvas:SetZPos( 0 )
	
	self.lblCountDown:SetFont( "FRETTA_MEDIUM_SHADOW" )
	self.lblCountDown:AlignRight()
	self.lblCountDown:SetTextColor( color_white )
	self.lblCountDown:SetContentAlignment( 6 )
	self.lblCountDown:SetWidth( 500 )
	
	self.lblActionName:SetFont( "FRETTA_LARGE_SHADOW" )
	self.lblActionName:AlignLeft()
	self.lblActionName:SetTextColor( color_white )
	self.lblActionName:SizeToContents()
	self.lblActionName:SetWidth( 500 )
	
	self.ctrlList:StretchToParent( 0, 60, 0, 0 )

end

function PANEL:ChooseGamemode()

	self.lblActionName:SetText( "Which Gamemode Next?" )
	self.ctrlList:Clear()
	
	for name, gamemode in RandomPairs( g_PlayableGamemodes ) do
	
		local lbl = vgui.Create( "DButton", self.ctrlList )
			lbl:SetText( gamemode.label )
		
			Derma_Hook( lbl, 	"Paint", 				"Paint", 	"GamemodeButton" )
			Derma_Hook( lbl, 	"ApplySchemeSettings", 	"Scheme", 	"GamemodeButton" )
			Derma_Hook( lbl, 	"PerformLayout", 		"Layout", 	"GamemodeButton" )
			
			lbl:SetTall( 24 )
			lbl:SetWide( 240 )
			
			local desc = tostring( gamemode.description );
			if ( gamemode.author ) then desc = desc .. "\n\nBy: " .. tostring( gamemode.author ) end
			if ( gamemode.authorurl ) then desc = desc .. "\n" .. tostring( gamemode.authorurl ) end

			lbl:SetTooltip( desc )
		
		lbl.WantName = name
		lbl.NumVotes = 0
		lbl.DoClick = function() if GetGlobalFloat( "VoteEndTime", 0 ) - CurTime() <= 0 then return end RunConsoleCommand( "votegamemode", name ) end
		
		self.ctrlList:AddItem( lbl )
	
	end

end

function PANEL:ChooseMap( gamemode )

	self.lblActionName:SetText( "Which Map?" )
	self:ResetPeeps()
	self.ctrlList:Clear()
	
	local gm = g_PlayableGamemodes[ gamemode ]
	if ( !gm ) then MsgN( "GAMEMODE MISSING, COULDN'T VOTE FOR MAP ", gamemode ) return end	
	
	for id, mapname in RandomPairs( gm.maps ) do
		local lbl = vgui.Create( "DButton", self.ctrlList )
			lbl:SetText( mapname )
			
			Derma_Hook( lbl, 	"Paint", 				"Paint", 	"GamemodeButton" )
			Derma_Hook( lbl, 	"ApplySchemeSettings", 	"Scheme", 	"GamemodeButton" )
			Derma_Hook( lbl, 	"PerformLayout", 		"Layout", 	"GamemodeButton" )
			
			lbl:SetTall( 24 )
			lbl:SetWide( 240 )
			
		lbl.WantName = mapname
		lbl.NumVotes = 0
		lbl.DoClick = function() if GetGlobalFloat( "VoteEndTime", 0 ) - CurTime() <= 0 then return end RunConsoleCommand( "votemap", mapname ) end

		--[[if file.Exists("maps/"..mapname..".png", "MOD") then
			lbl:SetTall(72)

			local Image = vgui.Create("DImage", lbl)
			Image:SetImage("../maps/"..mapname..".png")
			Image:SizeToContents()
			Image:SetSize(math.min(Image:GetWide(), 64), math.min(Image:GetTall(), 64))
			Image:AlignRight(4)
			Image:CenterVertical()
		end]]
		
		self.ctrlList:AddItem( lbl )
	
	end

end

function PANEL:ResetPeeps()

	for i=1, game.MaxPlayers() do
		self.Peeps[i]:SetPos( math.random( 0, 600 ), -16 )
		self.Peeps[i]:SetVisible( false )
		self.Peeps[i].strVote = nil
	end

end

function PANEL:FindWantBar( name )

	for k, v in pairs( self.ctrlList:GetItems() ) do
		if ( v.WantName == name ) then return v end
	end

end

function PANEL:PeepThink( peep, ent )

	if ( !IsValid( ent ) ) then 
		peep:SetVisible( false )
		return
	end
	
	peep:SetTooltip( ent:Nick() )
	peep:SetMouseInputEnabled( true )
	
	if ( !peep.strVote ) then
		peep:SetVisible( true )
		peep:SetPos( math.random( 0, 600 ), -16 )
		if ( ent == LocalPlayer() ) then
			peep:SetImage( "icon16/star.png" )
		end
	end

	peep.strVote = ent:GetNWString( "Wants", "" )
	local bar = self:FindWantBar( peep.strVote ) 
	if ( IsValid( bar ) ) then
	
		bar.NumVotes = bar.NumVotes + 1
		local vCurrentPos = Vector( peep.x, peep.y, 0 )
		local vNewPos = Vector( (bar.x + bar:GetWide()) - 15 * bar.NumVotes - 4, bar.y + ( bar:GetTall() * 0.5 - 8 ), 0 )
	
		if ( !peep.CurPos || peep.CurPos != vNewPos ) then
		
			peep:MoveTo( vNewPos.x, vNewPos.y, 0.2 )
			peep.CurPos = vNewPos
			
		end
		
	end

end

function PANEL:Think()

	local Seconds = GetGlobalFloat( "VoteEndTime", 0 ) - CurTime()
	if ( Seconds < 0 ) then Seconds = 0 end
	
	self.lblCountDown:SetText( Format( "%i", Seconds ) )
	
	for k, v in pairs( self.ctrlList:GetItems() ) do
		v.NumVotes = 0
	end
	
	for i=1, game.MaxPlayers() do
		self:PeepThink( self.Peeps[i], Entity(i) )
	end

end

function PANEL:Paint()

	Derma_DrawBackgroundBlur( self )
		
	local CenterY = ScrH() / 2.0
	local CenterX = ScrW() / 2.0
	
	surface.SetDrawColor( 0, 0, 0, 200 );
	surface.DrawRect( 0, 0, ScrW(), ScrH() );
	
end

function PANEL:FlashItem( itemname )

	local bar = self:FindWantBar( itemname )
	if ( !IsValid( bar ) ) then return end
	
	timer.Simple( 0.0, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
	timer.Simple( 0.2, function() bar.bgColor = nil end )
	timer.Simple( 0.4, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
	timer.Simple( 0.6, function() bar.bgColor = nil end )
	timer.Simple( 0.8, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "hl1/fvox/blip.wav" ) end )
	timer.Simple( 1.0, function() bar.bgColor = Color( 100, 100, 100 ) end )

end

derma.DefineControl( "VoteScreen", "", PANEL, "DPanel" )
