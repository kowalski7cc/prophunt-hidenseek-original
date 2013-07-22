
local function CreateLeftNotify()

	local x, y = chat.GetChatBoxPos()

	g_LeftNotify = vgui.Create( "DNotify" )

	g_LeftNotify:SetPos( 32, 0 )
	g_LeftNotify:SetSize( ScrW(), y - 8 )
	g_LeftNotify:SetAlignment( 1 )
	g_LeftNotify:ParentToHUD()

end

hook.Add( "InitPostEntity", "CreateLeftNotify", CreateLeftNotify )

function GM:NotifyGMVote( name, gamemode, votesneeded )

	local dl = vgui.Create( "DLabel" )
	dl:SetFont( "FRETTA_MEDIUM_SHADOW" )
	dl:SetTextColor( Color( 255, 255, 255, 255 ) )
	dl:SetText( Format( "%s voted for %s (need %i more)", name, gamemode, votesneeded ) )
	dl:SizeToContents()
	g_LeftNotify:AddItem( dl, 5 )

end
