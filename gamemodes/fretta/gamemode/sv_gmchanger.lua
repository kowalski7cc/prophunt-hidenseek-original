--[[
	sv_gmchanger.lua - Gamemode Changer (server side)
	-----------------------------------------------------
	Most of the internal stuff for the votes is here and contains stuff you really don't
	want to override.
]]

local g_PlayableGamemodes = {}

fretta_votesneeded = CreateConVar( "fretta_votesneeded", "0.75", { FCVAR_ARCHIVE } )
fretta_votetime = CreateConVar( "fretta_votetime", "20", { FCVAR_ARCHIVE } )
fretta_votegraceperiod = CreateConVar( "fretta_votegraceperiod", "30", { FCVAR_ARCHIVE } )


local function SendAvailableGamemodes( ply )

	net.Start("PlayableGamemodes")
		net.WriteTable(g_PlayableGamemodes)
	net.Send(ply)
	
end

function GetRandomGamemodeName()
	local choose = table.Random( g_PlayableGamemodes )
	if choose then return choose.key end

	return GAMEMODE.FolderName
end

function GetRandomGamemodeMap( gm )
	local gmtab = g_PlayableGamemodes[ gm or GAMEMODE.FolderName ]
	if gmtab then
		return table.Random( gmtab.maps )
	end

	return game.GetMap()
end

function GetNumberOfGamemodeMaps( gm )
	local gmtab = g_PlayableGamemodes[ gm or GAMEMODE.FolderName ]
	if gmtab then
		return table.Count( gmtab.maps )
	end

	return 0
end

hook.Add( "PlayerInitialSpawn", "SendAvailableGamemodes", SendAvailableGamemodes ) 


local AllMaps = file.Find( "maps/*.bsp", "GAME" )
for key, map in pairs( AllMaps ) do
	AllMaps[ key ] = string.gsub( map, ".bsp", "" )
end

local GameModes = engine.GetGamemodes()

for _, gm in pairs( engine.GetGamemodes() ) do

	local info = file.Read( "gamemodes/"..gm.name.."/"..gm.name..".txt", "GAME" )
	if ( info ) then
	
		local info = util.KeyValuesToTable( info )
		
		if ( info.selectable == 1 ) then
		
			g_PlayableGamemodes[ gm.name ] = {}
			g_PlayableGamemodes[ gm.name ].key = gm.name
			g_PlayableGamemodes[ gm.name ].name = gm.title
			g_PlayableGamemodes[ gm.name ].label = info.title
			g_PlayableGamemodes[ gm.name ].description = info.description
			g_PlayableGamemodes[ gm.name ].author = info.author_name
			g_PlayableGamemodes[ gm.name ].authorurl = info.author_url
			
			g_PlayableGamemodes[ gm.name ].maps = {}
		
			if ( info.fretta_maps ) then
				for _, mapname in pairs( AllMaps ) do
					mapname = string.lower(mapname)
					for _, p in pairs( info.fretta_maps ) do
						if ( string.sub( mapname, 1, #p ) == p ) then
							table.insert( g_PlayableGamemodes[ gm.name ].maps, mapname )
						end
					end
				end
			else
				g_PlayableGamemodes[ gm.name ].maps = AllMaps
			end
			
			if ( info.fretta_maps_disallow ) then
				for key, mapname in pairs( g_PlayableGamemodes[ gm.name ].maps ) do
					mapname = string.lower(mapname)
					for _, p in pairs( info.fretta_maps_disallow ) do
						if ( string.sub( mapname, 1, #p ) == p ) then
							g_PlayableGamemodes[ gm.name ].maps[ key ] = nil
						end
					end
				end
			end

		end
		
	end
	
end

GameModes = nil

function GM:IsValidGamemode( gamemode, map )

	if ( g_PlayableGamemodes[ gamemode ] == nil ) then return false end
	
	if ( map == nil ) then return true end
	
	for _, mapname in pairs( g_PlayableGamemodes[ gamemode ].maps ) do
		if ( mapname == map ) then return true end
	end
	
	return false
	
end

local gVotes = {}

function GM:VotePlayGamemode( ply, gamemode )
	
	if ( !gamemode ) then return end
	if ( GAMEMODE.WinningGamemode ) then return end
	if ( !GAMEMODE:InGamemodeVote() ) then return end
	if ( !GAMEMODE:IsValidGamemode( gamemode ) ) then return end
	
	ply:SetNWString( "Wants", gamemode )
	
end

concommand.Add( "votegamemode", function( pl, cmd, args ) GAMEMODE:VotePlayGamemode( pl, args[1] ) end )

function GM:VotePlayMap( ply, map )
	
	if ( !map ) then return end
	if ( !GAMEMODE.WinningGamemode ) then return end
	if ( !GAMEMODE:InGamemodeVote() ) then return end
	if ( !GAMEMODE:IsValidGamemode( GAMEMODE.WinningGamemode, map ) ) then return end
	
	ply:SetNWString( "Wants", map )
	
end

concommand.Add( "votemap", function( pl, cmd, args ) GAMEMODE:VotePlayMap( pl, args[1] ) end )

function GM:GetFractionOfPlayersThatWantChange()

	local Humans = player.GetHumans()
	local NumHumans = #Humans
	local WantsChange = 0
	
	for k, player in pairs( Humans ) do
	
		if ( player:GetNWBool( "WantsVote" ) ) then
			WantsChange = WantsChange + 1
		end
		
		-- Don't count players that aren't connected yet
		if ( !player:IsConnected() ) then
			NumHumans = NumHumans - 1
		end
	
	end
	
	local fraction = WantsChange / NumHumans
	
	return fraction, NumHumans, WantsChange

end

function GM:GetVotesNeededForChange()

	local Fraction, NumHumans, WantsChange = GAMEMODE:GetFractionOfPlayersThatWantChange()
	local FractionNeeded = fretta_votesneeded:GetFloat()
	
	local VotesNeeded = math.ceil( FractionNeeded * NumHumans )
	
	return VotesNeeded - WantsChange

end

function GM:CountVotesForChange()

	if ( CurTime() >= GetConVarNumber( "fretta_votegraceperiod" ) ) then -- can't vote too early on
	
		if ( GAMEMODE:InGamemodeVote() ) then return end

		fraction = GAMEMODE:GetFractionOfPlayersThatWantChange()
		
		if ( fraction > fretta_votesneeded:GetFloat() ) then
			GAMEMODE:StartGamemodeVote()
			return false
		end
		
	end

	return true
end

function GM:VoteForChange( ply )

	if ( GetConVarNumber( "fretta_voting" ) == 0 ) then return end
	if ( ply:GetNWBool( "WantsVote" ) ) then return end
	
	ply:SetNWBool( "WantsVote", true )
	
	local VotesNeeded = GAMEMODE:GetVotesNeededForChange()
	local NeedTxt = "" 
	if ( VotesNeeded > 0 ) then NeedTxt = ", Color( 80, 255, 50 ), [[ (need "..VotesNeeded.." more) ]] " end
	
	if ( CurTime() < GetConVarNumber( "fretta_votegraceperiod" ) ) then -- can't vote too early on
		local timediff = math.Round( GetConVarNumber( "fretta_votegraceperiod" ) - CurTime() );
		BroadcastLua( "chat.AddText( Entity("..ply:EntIndex().."), Color( 255, 255, 255 ), [[ voted to change the gamemode]] )" )
	else
		BroadcastLua( "chat.AddText( Entity("..ply:EntIndex().."), Color( 255, 255, 255 ), [[ voted to change the gamemode]] "..NeedTxt.." )" )
	end
	
	Msg( ply:Nick() .. " voted to change the gamemode\n" )
	
	timer.Simple( 5, function() GAMEMODE:CountVotesForChange() end )

end

concommand.Add( "VoteForChange", function( pl, cmd, args ) GAMEMODE:VoteForChange( pl ) end )
timer.Create( "VoteForChangeThink", 10, 0, function() if ( GAMEMODE ) then GAMEMODE.CountVotesForChange( GAMEMODE ) end end )


function GM:ClearPlayerWants()

	for k, ply in pairs( player.GetAll() ) do
		ply:SetNWString( "Wants", "" )
	end
	
end


function GM:StartGamemodeVote()

	if( !GAMEMODE.m_bVotingStarted ) then
		SetGlobalBool( "InGamemodeVote", true )

		if ( fretta_voting:GetBool() ) then
			if #g_PlayableGamemodes >= 2 then
				GAMEMODE:ClearPlayerWants()
				BroadcastLua( "GAMEMODE:ShowGamemodeChooser()" )
				timer.Simple( fretta_votetime:GetFloat(), function() GAMEMODE:FinishGamemodeVote() end )
				SetGlobalFloat( "VoteEndTime", CurTime() + fretta_votetime:GetFloat() )
			else
				GAMEMODE.WinningGamemode = GAMEMODE:WorkOutWinningGamemode()
				GAMEMODE:StartMapVote()
			end
		else
			GAMEMODE.WinningGamemode = GAMEMODE.FolderName
			GAMEMODE:StartMapVote()
		end
		
		GAMEMODE.m_bVotingStarted = true;
	end
end

function GM:StartMapVote()
	
	-- If there's only one map, let the 'random map' thing choose it
	if ( GetNumberOfGamemodeMaps( GAMEMODE.WinningGamemode ) == 1 ) then
		return GAMEMODE:FinishMapVote( true )
	end		
		
	BroadcastLua( "GAMEMODE:ShowMapChooserForGamemode( \""..GAMEMODE.WinningGamemode.."\" )" );	
	timer.Simple( fretta_votetime:GetFloat(), function() GAMEMODE:FinishMapVote() end )
	SetGlobalFloat( "VoteEndTime", CurTime() + fretta_votetime:GetFloat() )

end

function GM:GetWinningWant()

	local Votes = {}
	
	for k, ply in pairs( player.GetAll() ) do
	
		local want = ply:GetNWString( "Wants", nil )
		if ( want && want != "" ) then
			Votes[ want ] = Votes[ want ] or 0
			Votes[ want ] = Votes[ want ] + 1			
		end
		
	end
	
	return table.GetWinningKey( Votes )
	
end

function GM:WorkOutWinningGamemode()

	if ( GAMEMODE.WinningGamemode ) then return GAMEMODE.WinningGamemode end
	
	-- Gamemode Voting disabled, return current gamemode
	if ( !fretta_voting:GetBool() ) then
		return GAMEMODE.FolderName
	end

	local winner = GAMEMODE:GetWinningWant()
	if ( !winner ) then return GetRandomGamemodeName() end
	
	return winner
	
end

function GM:GetWinningMap( WinningGamemode )

	if ( GAMEMODE.WinningMap ) then return GAMEMODE.WinningMap end

	local winner = GAMEMODE:GetWinningWant()
	if ( !winner ) then return GetRandomGamemodeMap( GAMEMODE.WinningGamemode ) end
	
	return winner
	
end

function GM:FinishGamemodeVote()
	
	GAMEMODE.WinningGamemode = GAMEMODE:WorkOutWinningGamemode()
	GAMEMODE:ClearPlayerWants()
	
	-- Send bink bink notification
	BroadcastLua( "GAMEMODE:GamemodeWon( '"..GAMEMODE.WinningGamemode.."' )" );

	-- Start map vote..
	timer.Simple( 2, function() GAMEMODE:StartMapVote() end )
	
end

function GM:FinishMapVote()
	
	GAMEMODE.WinningMap = GAMEMODE:GetWinningMap()
	GAMEMODE:ClearPlayerWants()
	
	-- Send bink bink notification
	BroadcastLua( "GAMEMODE:ChangingGamemode( '"..GAMEMODE.WinningGamemode.."', '"..GAMEMODE.WinningMap.."' )" );

	-- Start map vote?
	timer.Simple( 3, function() GAMEMODE:ChangeGamemode() end )
	
end

function GM:ChangeGamemode()
	
	local gm = GAMEMODE:WorkOutWinningGamemode()
	local mp = GAMEMODE:GetWinningMap()
	
	RunConsoleCommand( "gamemode", gm )
	RunConsoleCommand( "changelevel", mp )
	
end