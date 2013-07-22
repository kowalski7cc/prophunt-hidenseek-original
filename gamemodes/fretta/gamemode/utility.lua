/*---------------------------------------------------------
   Name: UTIL_SpawnAllPlayers
   Desc: Respawn all non-spectators, providing they are allowed to spawn. 
---------------------------------------------------------*/
function UTIL_SpawnAllPlayers()

	for k,v in pairs( player.GetAll() ) do
		if ( v:CanRespawn() && v:Team() != TEAM_SPECTATOR && v:Team() != TEAM_CONNECTING ) then
			v:Spawn()
		end
	end

end

/*---------------------------------------------------------
   Name: UTIL_StripAllPlayers
   Desc: Clears all weapons and ammo from all players.
---------------------------------------------------------*/
function UTIL_StripAllPlayers()

	for k,v in pairs( player.GetAll() ) do
		if ( v:Team() != TEAM_SPECTATOR && v:Team() != TEAM_CONNECTING ) then
			v:StripWeapons()
			v:StripAmmo()
		end
	end

end

/*---------------------------------------------------------
   Name: UTIL_FreezeAllPlayers
   Desc: Freeze all non-spectators.
---------------------------------------------------------*/
function UTIL_FreezeAllPlayers()

	for k,v in pairs( player.GetAll() ) do
		if ( v:Team() != TEAM_SPECTATOR && v:Team() != TEAM_CONNECTING ) then
			v:Freeze( true )
		end
	end

end

/*---------------------------------------------------------
   Name: UTIL_UnFreezeAllPlayers
   Desc: Removes frozen flag from all players.
---------------------------------------------------------*/
function UTIL_UnFreezeAllPlayers()

	for k,v in pairs( player.GetAll() ) do
		if ( v:Team() != TEAM_SPECTATOR && v:Team() != TEAM_CONNECTING ) then
			v:Freeze( false )
		end
	end

end
