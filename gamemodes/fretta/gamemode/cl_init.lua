
function surface.CreateLegacyFont(font, size, weight, antialias, additive, name, shadow, outline, blursize)
	surface.CreateFont(name, {font = font, size = size, weight = weight, antialias = antialias, additive = additive, shadow = shadow, outline = outline, blursize = blursize})
end

include( 'shared.lua' )
include( 'cl_splashscreen.lua' )
include( 'cl_selectscreen.lua' )
include( 'cl_gmchanger.lua' )
include( 'cl_help.lua' )
include( 'skin.lua' )
include( 'vgui/vgui_hudlayout.lua' )
include( 'vgui/vgui_hudelement.lua' )
include( 'vgui/vgui_hudbase.lua' )
include( 'vgui/vgui_hudcommon.lua' )
include( 'cl_hud.lua' )
include( 'cl_deathnotice.lua' )
include( 'cl_scores.lua' )
include( 'cl_notify.lua' )

language.Add( "env_laser", "Laser" )
language.Add( "env_explosion", "Explosion" )
language.Add( "func_door", "Door" )
language.Add( "func_door_rotating", "Door" )
language.Add( "trigger_hurt", "Hazard" )
language.Add( "func_rotating", "Hazard" )
language.Add( "worldspawn", "Gravity" )
language.Add( "prop_physics", "Prop" )
language.Add( "prop_physics_respawnable", "Prop" )
language.Add( "prop_physics_multiplayer", "Prop" )
language.Add( "entityflame", "Fire" )

surface.CreateLegacyFont( "Trebuchet MS", 69, 700, true, false, "FRETTA_HUGE" )
surface.CreateLegacyFont( "Trebuchet MS", 69, 700, true, false, "FRETTA_HUGE_SHADOW", true )
surface.CreateLegacyFont( "Trebuchet MS", 40, 700, true, false, "FRETTA_LARGE" )
surface.CreateLegacyFont( "Trebuchet MS", 40, 700, true, false, "FRETTA_LARGE_SHADOW", true )
surface.CreateLegacyFont( "Trebuchet MS", 19, 700, true, false, "FRETTA_MEDIUM" )
surface.CreateLegacyFont( "Trebuchet MS", 19, 700, true, false, "FRETTA_MEDIUM_SHADOW", true )
surface.CreateLegacyFont( "Trebuchet MS", 16, 700, true, false, "FRETTA_SMALL" )

surface.CreateLegacyFont( "Trebuchet MS", ScreenScale( 10 ), 700, true, false, "FRETTA_NOTIFY", true )

CreateClientConVar( "cl_spec_mode", "5", true, true )

function GM:Initialize()
	
	self.BaseClass:Initialize()
	
end

function GM:InitPostEntity()

	if ( GAMEMODE.TeamBased ) then 
		GAMEMODE:ShowTeam();
	end
	
	GAMEMODE:ShowSplash();

end

local CircleMat = Material( "SGM/playercircle" );

function GM:DrawPlayerRing( pPlayer )

	if ( !IsValid( pPlayer ) ) then return end
	if ( !pPlayer:GetNWBool( "DrawRing", false ) ) then return end
	if ( !pPlayer:Alive() ) then return end
	
	local trace = {}
	trace.start 	= pPlayer:GetPos() + Vector(0,0,50)
	trace.endpos 	= trace.start + Vector(0,0,-300)
	trace.filter 	= pPlayer
	
	local tr = util.TraceLine( trace )
	
	if not tr.HitWorld then
		tr.HitPos = pPlayer:GetPos()
	end

	local color = table.Copy( team.GetColor( pPlayer:Team() ) )
	color.a = 40;

	render.SetMaterial( CircleMat )
	render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, GAMEMODE.PlayerRingSize, GAMEMODE.PlayerRingSize, color )	

end

hook.Add( "PrePlayerDraw", "DrawPlayerRing", function( ply ) GAMEMODE:DrawPlayerRing( ply ) end ) 

function GM:HUDShouldDraw( name )

	if GAMEMODE.ScoreboardVisible then return false end
	
	// commented out until HUD elements are made
	//for k, v in pairs{"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"} do
	//	if name == v then return false end 
  	//end 
	
	if name == "CHudDamageIndicator" and not LocalPlayer():Alive() then
		return false
	end
	
	return true
	
end

function GM:OnSpawnMenuOpen()
	RunConsoleCommand( "lastinv" ); // Fretta is derived from base and has no spawn menu, so give it a use, make it lastinv.
end


function GM:PlayerBindPress( pl, bind, down )

	// Redirect binds to the spectate system
	if ( pl:IsObserver() && down ) then
	
		if ( bind == "+jump" ) then 	RunConsoleCommand( "spec_mode" )	end
		if ( bind == "+attack" ) then	RunConsoleCommand( "spec_next" )	end
		if ( bind == "+attack2" ) then	RunConsoleCommand( "spec_prev" )	end
		
	end
	
	return false	
	
end

/*---------------------------------------------------------
   Name: gamemode:GetTeamColor( ent )
---------------------------------------------------------*/
function GM:GetTeamColor( ent )

	if ( GAMEMODE.SelectColor && IsValid( ent ) ) then
	
		local clr = ent:GetNWString( "NameColor", -1 )
		if ( clr && clr != -1 && clr != "" ) then
			clr = list.Get( "PlayerColours" )[ clr ]
			if ( clr ) then return clr end
		end
	
	end

	local team = TEAM_UNASSIGNED
	if ( ent.Team and IsValid(ent) ) then team = ent:Team() end
	return GAMEMODE:GetTeamNumColor( team )

end


/*---------------------------------------------------------
   Name: ShouldDrawLocalPlayer
---------------------------------------------------------*/
function GM:ShouldDrawLocalPlayer( ply )
	return ply:CallClassFunction( "ShouldDrawLocalPlayer" )
end


/*---------------------------------------------------------
   Name: InputMouseApply
---------------------------------------------------------*/
function GM:InputMouseApply( cmd, x, y, angle )
	
	return LocalPlayer():CallClassFunction( "InputMouseApply", cmd, x, y, angle )
	
end

function GM:TeamChangeNotification( ply, oldteam, newteam )

	if( ply && ply:IsValid() ) then
		local nick = ply:Nick();
		local oldTeamColor = team.GetColor( oldteam );
		local newTeamName = team.GetName( newteam );
		local newTeamColor = team.GetColor( newteam );
		
		if( newteam == TEAM_SPECTATOR ) then
			chat.AddText( oldTeamColor, nick, color_white, " joined the ", newTeamColor, newTeamName ); 
		else
			chat.AddText( oldTeamColor, nick, color_white, " joined ", newTeamColor, newTeamName );
		end
		
		chat.PlaySound( "buttons/button15.wav" );
	end
end
net.Receive( "fretta_teamchange", function( um )  if ( GAMEMODE ) then GAMEMODE:TeamChangeNotification( net.ReadEntity(), net.ReadUInt(8), net.ReadUInt(8) ) end end )
