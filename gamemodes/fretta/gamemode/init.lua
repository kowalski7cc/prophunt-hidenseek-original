/*
	init.lua - Server Component
	-----------------------------------------------------
	The entire server side bit of Fretta starts here.
*/

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( 'skin.lua' )
AddCSLuaFile( 'player_class.lua' )
AddCSLuaFile( 'class_default.lua' )
AddCSLuaFile( 'cl_splashscreen.lua' )
AddCSLuaFile( 'cl_selectscreen.lua' )
AddCSLuaFile( 'cl_gmchanger.lua' )
AddCSLuaFile( 'cl_help.lua' )
AddCSLuaFile( 'player_extension.lua' )
AddCSLuaFile( 'vgui/vgui_hudlayout.lua' )
AddCSLuaFile( 'vgui/vgui_hudelement.lua' )
AddCSLuaFile( 'vgui/vgui_hudbase.lua' )
AddCSLuaFile( 'vgui/vgui_hudcommon.lua' )
AddCSLuaFile( 'vgui/vgui_gamenotice.lua' )
AddCSLuaFile( 'vgui/vgui_scoreboard.lua' )
AddCSLuaFile( 'vgui/vgui_scoreboard_team.lua' )
AddCSLuaFile( 'vgui/vgui_scoreboard_small.lua' )
AddCSLuaFile( 'vgui/vgui_vote.lua' )
AddCSLuaFile( 'cl_hud.lua' )
AddCSLuaFile( 'cl_deathnotice.lua' )
AddCSLuaFile( 'cl_scores.lua' )
AddCSLuaFile( 'cl_notify.lua' )
AddCSLuaFile( 'player_colours.lua' )

include( "shared.lua" )
include( "sv_gmchanger.lua" )
include( "sv_spectator.lua" )
include( "round_controller.lua" )
include( "utility.lua" )

GM.ReconnectedPlayers = {}

function GM:Initialize()

	util.AddNetworkString("PlayableGamemodes")
	util.AddNetworkString("RoundAddedTime")
	util.AddNetworkString("PlayableGamemodes")
	util.AddNetworkString("fretta_teamchange")

	-- If we're round based, wait 3 seconds before the first round starts
	if ( GAMEMODE.RoundBased ) then
		timer.Simple( 3, function() GAMEMODE:StartRoundBasedGame() end )
	end
	
	if ( GAMEMODE.AutomaticTeamBalance ) then
		timer.Create( "CheckTeamBalance", 30, 0, function() GAMEMODE:CheckTeamBalance() end )
	end
	
end

function GM:Think()

	self.BaseClass:Think()
	
	for k,v in pairs( player.GetAll() ) do
	
		local Class = v:GetPlayerClass()
		if ( !Class ) then return end
		
		v:CallClassFunction( "Think" )
		
	end

	// Game time related
	if( !GAMEMODE.IsEndOfGame && ( !GAMEMODE.RoundBased || ( GAMEMODE.RoundBased && GAMEMODE:CanEndRoundBasedGame() ) ) && CurTime() >= GAMEMODE.GetTimeLimit() ) then
		GAMEMODE:EndOfGame( true )
	end
	
end

/*---------------------------------------------------------
   Name: gamemode:CanPlayerSuicide( Player ply )
   Desc: Is the player allowed to commit suicide?
---------------------------------------------------------*/
function GM:CanPlayerSuicide( ply )

	if( ply:Team() == TEAM_UNASSIGNED || ply:Team() == TEAM_SPECTATOR ) then
		return false // no suicide in spectator mode
	end

	return !GAMEMODE.NoPlayerSuicide
	
end 

/*---------------------------------------------------------
   Name: gamemode:PlayerSwitchFlashlight( Player ply, Bool on )
   Desc: Can we turn our flashlight on or off?
---------------------------------------------------------*/
function GM:PlayerSwitchFlashlight( ply, on ) 

	if ( ply:Team() == TEAM_SPECTATOR || ply:Team() == TEAM_UNASSIGNED || ply:Team() == TEAM_CONNECTING ) then
		return not on
	end

	return ply:CanUseFlashlight()
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn( Player ply )
   Desc: Our very first spawn in the game.
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( pl )

	pl:SetTeam( TEAM_UNASSIGNED )
	pl:SetPlayerClass( "Spectator" )
	pl.m_bFirstSpawn = true
	pl:UpdateNameColor()
	
	GAMEMODE:CheckPlayerReconnected( pl )

end

function GM:CheckPlayerReconnected( pl )

	if table.HasValue( GAMEMODE.ReconnectedPlayers, pl:UniqueID() ) then
		GAMEMODE:PlayerReconnected( pl )
	end

end

/*---------------------------------------------------------
   Name: gamemode:PlayerReconnected( Player ply )
   Desc: Called if the player has appeared to have reconnected.
---------------------------------------------------------*/
function GM:PlayerReconnected( pl )

	// Use this hook to do stuff when a player rejoins and has been in the server previously

end

function GM:PlayerDisconnected( pl )

	table.insert( GAMEMODE.ReconnectedPlayers, pl:UniqueID() )

	self.BaseClass:PlayerDisconnected( pl )

end  

function GM:ShowHelp( pl )

	pl:SendLua( "GAMEMODE:ShowHelp()" )
	
end


function GM:PlayerSpawn( pl ) 

	pl:UpdateNameColor()

	// The player never spawns straight into the game in Fretta
	// They spawn as a spectator first (during the splash screen and team picking screens)
	if ( pl.m_bFirstSpawn ) then
	
		pl.m_bFirstSpawn = nil
		
		if ( pl:IsBot() ) then
		
			GAMEMODE:AutoTeam( pl )
			
			// The bot doesn't send back the 'seen splash' command, so fake it.
			if ( !GAMEMODE.TeamBased && !GAMEMODE.NoAutomaticSpawning ) then
				pl:Spawn()
			end
	
		else
		
			pl:StripWeapons()
			GAMEMODE:PlayerSpawnAsSpectator( pl )
			
			// Follow a random player until we join a team
			if ( #player.GetAll() > 1 ) then
				pl:Spectate( OBS_MODE_CHASE )
				pl:SpectateEntity( table.Random( player.GetAll() ) )
			end
			
		end
	
		return
		
	end
		
	pl:CheckPlayerClassOnSpawn()
		
	if ( GAMEMODE.TeamBased && ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) ) then

		GAMEMODE:PlayerSpawnAsSpectator( pl )
		return
	
	end
	
	// Stop observer mode
	pl:UnSpectate()

	// Call item loadout function
	hook.Call( "PlayerLoadout", GAMEMODE, pl )
	
	// Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )
	
	// Call class function
	pl:OnSpawn()
	
end


function GM:PlayerLoadout( pl )

	pl:CheckPlayerClassOnSpawn()

	pl:OnLoadout()
	
	// Switch to prefered weapon if they have it
	local cl_defaultweapon = pl:GetInfo( "cl_defaultweapon" )
	
	if ( pl:HasWeapon( cl_defaultweapon )  ) then
		pl:SelectWeapon( cl_defaultweapon ) 
	end
	
end


function GM:PlayerSetModel( pl )

	pl:OnPlayerModel()
	
end


function GM:AutoTeam( pl )

	if ( !GAMEMODE.AllowAutoTeam ) then return end
	if ( !GAMEMODE.TeamBased ) then return end
	
	GAMEMODE:PlayerRequestTeam( pl, team.BestAutoJoinTeam() )

end

concommand.Add( "autoteam", function( pl, cmd, args ) hook.Call( "AutoTeam", GAMEMODE, pl ) end )


function GM:PlayerRequestClass( ply, class, disablemessage )
	
	local Classes = team.GetClass( ply:Team() )
	if (!Classes) then return end
	
	local RequestedClass = Classes[ class ]
	if (!RequestedClass) then return end
	
	if ( ply:Alive() && SERVER ) then
	
		if ( ply.m_SpawnAsClass && ply.m_SpawnAsClass == RequestedClass ) then return end
	
		ply.m_SpawnAsClass = RequestedClass
		
		if ( !disablemessage ) then
			ply:ChatPrint( "Your class will change to '".. player_class.GetClassName( RequestedClass ) .. "' when you respawn" )
		end
		
	else
		self:PlayerJoinClass( ply, RequestedClass )
		ply.m_SpawnAsClass = nil
	end
	
end

concommand.Add( "changeclass", function( pl, cmd, args ) hook.Call( "PlayerRequestClass", GAMEMODE, pl, tonumber(args[1]) ) end )


local function SeenSplash( ply )

	if ( ply.m_bSeenSplashScreen ) then return end
	ply.m_bSeenSplashScreen = true
	
	if ( !GAMEMODE.TeamBased && !GAMEMODE.NoAutomaticSpawning ) then
		ply:KillSilent()
	end
	
end

concommand.Add( "seensplash", SeenSplash )


function GM:PlayerJoinTeam( ply, teamid )
	
	local iOldTeam = ply:Team()
	
	if ( ply:Alive() ) then
		if ( iOldTeam == TEAM_SPECTATOR || (iOldTeam == TEAM_UNASSIGNED && GAMEMODE.TeamBased) ) then
			ply:KillSilent()
		else
			ply:Kill()
		end
	end
	
	ply:SetTeam( teamid )
	ply.LastTeamSwitch = RealTime()
	
	local Classes = team.GetClass( teamid )
	
	
	// Needs to choose class
	if ( Classes && #Classes > 1 ) then
	
		if ( ply:IsBot() || !GAMEMODE.SelectClass ) then
	
			GAMEMODE:PlayerRequestClass( ply, math.random( 1, #Classes ) )
	
		else

			ply.m_fnCallAfterClassChoose = function() 
												ply.DeathTime = CurTime()
												GAMEMODE:OnPlayerChangedTeam( ply, iOldTeam, teamid ) 
												ply:EnableRespawn() 
											end

			ply:SendLua( "GAMEMODE:ShowClassChooser( ".. teamid .." )" )
			ply:DisableRespawn()
			ply:SetRandomClass() // put the player in a VALID class in case they don't choose and get spawned
			return
					
		end
		
	end
	
	// No class, use default
	if ( !Classes || #Classes == 0 ) then
		ply:SetPlayerClass( "Default" )
	end
	
	// Only one class, use that
	if ( Classes && #Classes == 1 ) then
		GAMEMODE:PlayerRequestClass( ply, 1 )
	end
	
	gamemode.Call("OnPlayerChangedTeam", ply, iOldTeam, teamid )
	
end

function GM:PlayerJoinClass( ply, classname )

	ply.m_SpawnAsClass = nil
	ply:SetPlayerClass( classname )
	
	if ( ply.m_fnCallAfterClassChoose ) then
	
		ply.m_fnCallAfterClassChoose()
		ply.m_fnCallAfterClassChoose = nil
		
	end

end

function GM:OnPlayerChangedTeam( ply, oldteam, newteam )

	// Here's an immediate respawn thing by default. If you want to 
	// re-create something more like CS or some shit you could probably
	// change to a spectator or something while dead.
	if ( newteam == TEAM_SPECTATOR ) then
	
		// If we changed to spectator mode, respawn where we are
		local Pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos( Pos )
		
	elseif ( oldteam == TEAM_SPECTATOR ) then
	
		// If we're changing from spectator, join the game
		if ( !GAMEMODE.NoAutomaticSpawning ) then
			ply:Spawn()
		end
	
	elseif ( oldteam ~= TEAM_SPECTATOR ) then

		ply.LastTeamChange = CurTime()

	else
	
		// If we're straight up changing teams just hang
		//  around until we're ready to respawn onto the 
		//  team that we chose
		
	end
	
	//PrintMessage( HUD_PRINTTALK, Format( "%s joined '%s'", ply:Nick(), team.GetName( newteam ) ) )
	
	// Send net msg for team change
 
    net.Start( "fretta_teamchange" )
		net.WriteEntity( ply )
		net.WriteUInt( oldteam, 8 )
		net.WriteUInt( newteam, 8 )
    net.Broadcast()
	
end

function GM:CheckTeamBalance()

	local highest

	for id, tm in pairs( team.GetAllTeams() ) do
		if ( id > 0 && id < 1000 && team.Joinable( id ) ) then
			if ( !highest || team.NumPlayers( id ) > team.NumPlayers( highest ) ) then
			
				highest = id
			
			end
		end
	end

	if not highest then return end

	for id, tm in pairs( team.GetAllTeams() ) do
		if ( id ~= highest and id > 0 && id < 1000 && team.Joinable( id ) ) then
			if team.NumPlayers( id ) < team.NumPlayers( highest ) then
				while team.NumPlayers( id ) < team.NumPlayers( highest ) - 1 do
				
					local ply, reason = GAMEMODE:FindLeastCommittedPlayerOnTeam( highest )

					ply:Kill()
					ply:SetTeam( id )

					// Todo: Notify player 'you have been swapped'
					// This is a placeholder
					PrintMessage(HUD_PRINTTALK, ply:Name().." has been changed to "..team.GetName( id ).." for team balance. ("..reason..")" )
					
				end
			end
		end
	end
	
end

function GM:FindLeastCommittedPlayerOnTeam( teamid )

	local worst
	local worstteamswapper

	for k,v in pairs( team.GetPlayers( teamid ) ) do

		if ( v.LastTeamChange && CurTime() < v.LastTeamChange + 180 && (!worstteamswapper || worstteamswapper.LastTeamChange < v.LastTeamChange) ) then
			worstteamswapper = v
		end

		if ( !worst || v:Frags() < worst:Frags() ) then
			worst = v
		end

	end
	
	if worstteamswapper then
		return worstteamswapper, "They changed teams recently"
	end

	return worst, "Least points on their team"
	
end

function GM:OnEndOfGame(bGamemodeVote)

	for k,v in pairs( player.GetAll() ) do

		v:Freeze(true)
		v:ConCommand( "+showscores" )
		
	end
	
end

// Override OnEndOfGame to do any other stuff. like winning music.
function GM:EndOfGame( bGamemodeVote )

	if GAMEMODE.IsEndOfGame then return end

	GAMEMODE.IsEndOfGame = true
	SetGlobalBool( "IsEndOfGame", true );
	
	gamemode.Call("OnEndOfGame", bGamemodeVote);
	
	if ( bGamemodeVote ) then
	
		MsgN( "Starting gamemode voting..." )
		PrintMessage( HUD_PRINTTALK, "Starting gamemode voting..." );
		timer.Simple( GAMEMODE.VotingDelay, function() GAMEMODE:StartGamemodeVote() end )
		
	end

end

function GM:GetWinningFraction()
	if ( !GAMEMODE.GMVoteResults ) then return end
	return GAMEMODE.GMVoteResults.Fraction
end

function GM:PlayerShouldTakeDamage( ply, attacker )

	if ( GAMEMODE.NoPlayerSelfDamage && IsValid( attacker ) && ply == attacker ) then return false end
	if ( GAMEMODE.NoPlayerDamage ) then return false end
	
	if ( GAMEMODE.NoPlayerTeamDamage && IsValid( attacker ) ) then
		if ( attacker.Team && ply:Team() == attacker:Team() && ply != attacker ) then return false end
	end
	
	if ( IsValid( attacker ) && attacker:IsPlayer() && GAMEMODE.NoPlayerPlayerDamage ) then return false end
	if ( IsValid( attacker ) && !attacker:IsPlayer() && GAMEMODE.NoNonPlayerPlayerDamage ) then return false end
	
	return true

end


function GM:PlayerDeathThink( pl )

	pl.DeathTime = pl.DeathTime or CurTime()
	local timeDead = CurTime() - pl.DeathTime
	
	// If we're in deathcam mode, promote to a generic spectator mode
	if ( GAMEMODE.DeathLingerTime > 0 && timeDead > GAMEMODE.DeathLingerTime && ( pl:GetObserverMode() == OBS_MODE_FREEZECAM || pl:GetObserverMode() == OBS_MODE_DEATHCAM ) ) then
		GAMEMODE:BecomeObserver( pl )
	end
	
	// If we're in a round based game, player NEVER spawns in death think
	if ( GAMEMODE.NoAutomaticSpawning ) then return end
	
	// The gamemode is holding the player from respawning.
	// Probably because they have to choose a class..
	if ( !pl:CanRespawn() ) then return end

	// Don't respawn yet - wait for minimum time...
	if ( GAMEMODE.MinimumDeathLength ) then 
	
		pl:SetNWFloat( "RespawnTime", pl.DeathTime + GAMEMODE.MinimumDeathLength )
		
		if ( timeDead < pl:GetRespawnTime() ) then
			return
		end
		
	end

	// Force respawn
	if ( pl:GetRespawnTime() != 0 && GAMEMODE.MaximumDeathLength != 0 && timeDead > GAMEMODE.MaximumDeathLength ) then
		pl:Spawn()
		return
	end

	// We're between min and max death length, player can press a key to spawn.
	if ( pl:KeyPressed( IN_ATTACK ) || pl:KeyPressed( IN_ATTACK2 ) || pl:KeyPressed( IN_JUMP ) ) then
		pl:Spawn()
	end
	
end

function GM:GetFallDamage( ply, flFallSpeed )
	
	if ( GAMEMODE.RealisticFallDamage ) then
		return flFallSpeed / 8
	end
	
	return 10
	
end

function GM:PostPlayerDeath( ply )

	// Note, this gets called AFTER DoPlayerDeath.. AND it gets called
	// for KillSilent too. So if Freezecam isn't set by DoPlayerDeath, we
	// pick up the slack by setting DEATHCAM here.
	
	if ( ply:GetObserverMode() == OBS_MODE_NONE ) then
		ply:Spectate( OBS_MODE_DEATHCAM )
	end	
	
	ply:OnDeath()

end

function GM:DoPlayerDeath( ply, attacker, dmginfo )

	ply:CallClassFunction( "OnDeath", attacker, dmginfo )
	ply:CreateRagdoll()
	ply:AddDeaths( 1 )
	
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
	
		if ( attacker == ply ) then
		
			if ( GAMEMODE.TakeFragOnSuicide ) then
			
				attacker:AddFrags( -1 )
				
				if ( GAMEMODE.TeamBased && GAMEMODE.AddFragsToTeamScore ) then
					team.AddScore( attacker:Team(), -1 )
				end
			
			end
			
		else
		
			attacker:AddFrags( 1 )
			
			if ( GAMEMODE.TeamBased && GAMEMODE.AddFragsToTeamScore ) then
				team.AddScore( attacker:Team(), 1 )
			end
			
		end
		
	end
	
	if ( GAMEMODE.EnableFreezeCam && IsValid( attacker ) && attacker != ply ) then
	
		ply:SpectateEntity( attacker )
		ply:Spectate( OBS_MODE_FREEZECAM )
		
	end
	
end

function GM:StartSpectating( ply )

	if ( !GAMEMODE:PlayerCanJoinTeam( ply ) ) then return end
	
	ply:StripWeapons();
	GAMEMODE:PlayerJoinTeam( ply, TEAM_SPECTATOR )
	GAMEMODE:BecomeObserver( ply )

end


function GM:EndSpectating( ply )

	if ( !GAMEMODE:PlayerCanJoinTeam( ply ) ) then return end

	GAMEMODE:PlayerJoinTeam( ply, TEAM_UNASSIGNED )
	
	ply:KillSilent()

end

/*---------------------------------------------------------
   Name: gamemode:PlayerRequestTeam()
		Player wants to change team
---------------------------------------------------------*/
function GM:PlayerRequestTeam( ply, teamid )

	if ( !GAMEMODE.TeamBased && GAMEMODE.AllowSpectating ) then
	
		if ( teamid == TEAM_SPECTATOR ) then
			GAMEMODE:StartSpectating( ply )
		else
			GAMEMODE:EndSpectating( ply )
		end
	
		return
	
	end
	
	return self.BaseClass:PlayerRequestTeam( ply, teamid )

end

local function TimeLeft( ply )

	local tl = GAMEMODE:GetGameTimeLeft()
	if ( tl == -1 ) then return end
	
	local Time = util.ToMinutesSeconds( tl )
	
	if ( IsValid( ply ) ) then
		ply:PrintMessage( HUD_PRINTCONSOLE, Time )
	else
		MsgN( Time )
	end
	
end

concommand.Add( "timeleft", TimeLeft )