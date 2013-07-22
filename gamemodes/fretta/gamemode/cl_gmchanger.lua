include( "vgui/vgui_vote.lua" )


g_PlayableGamemodes = {}
g_bGotGamemodesTable = false

function RcvPlayableGamemodes( length ) 
      
	g_PlayableGamemodes = net.ReadTable()
	g_bGotGamemodesTable = true
	 
 end 
 
net.Receive( "PlayableGamemodes", RcvPlayableGamemodes ); 

local GMChooser = nil 
local function GetVoteScreen()

	if ( IsValid( GMChooser ) ) then return GMChooser end
	
	GMChooser = vgui.Create( "VoteScreen" )
	return GMChooser

end
 

function GM:ShowGamemodeChooser()

	local votescreen = GetVoteScreen()
	votescreen:ChooseGamemode()

end

function GM:GamemodeWon( mode )

	local votescreen = GetVoteScreen()
	votescreen:FlashItem( mode )

end

function GM:ChangingGamemode( mode, map )

	local votescreen = GetVoteScreen()
	votescreen:FlashItem( map )

end

function GM:ShowMapChooserForGamemode( gmname )

	local votescreen = GetVoteScreen()
	votescreen:ChooseMap( gmname )

end


local ClassChooser = nil 
cl_classsuicide = CreateConVar( "cl_classsuicide", "0", { FCVAR_ARCHIVE } )

function GM:ShowClassChooser( TEAMID )

	if ( !GAMEMODE.SelectClass ) then return end
	if ( ClassChooser ) then ClassChooser:Remove() end

	ClassChooser = vgui.CreateFromTable( vgui_Splash )
	ClassChooser:SetHeaderText( "Choose Class" )
	ClassChooser:SetHoverText( "What class do you want to be?" );

	Classes = team.GetClass( TEAMID )
	for k, v in SortedPairs( Classes ) do
		
		local displayname = v
		local Class = player_class.Get( v )
		if ( Class && Class.DisplayName ) then
			displayname = Class.DisplayName
		end
		
		local description = "Click to spawn as " .. displayname
		
		if( Class and Class.Description ) then
			description = Class.Description
		end
		
		local func = function() if( cl_classsuicide:GetBool() ) then RunConsoleCommand( "kill" ) end RunConsoleCommand( "changeclass", k ) end
		local btn = ClassChooser:AddSelectButton( displayname, func, description )
		btn.m_colBackground = team.GetColor( TEAMID )
		
	end
	
	ClassChooser:AddCancelButton()
	ClassChooser:MakePopup()
	ClassChooser:NoFadeIn()

end
