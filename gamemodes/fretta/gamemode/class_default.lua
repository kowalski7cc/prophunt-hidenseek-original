
local CLASS = {}

CLASS.DisplayName			= "Default Class"
CLASS.WalkSpeed 			= 400
CLASS.CrouchedWalkSpeed 	= 0.2
CLASS.RunSpeed				= 600
CLASS.DuckSpeed				= 0.2
CLASS.JumpPower				= 200
CLASS.PlayerModel			= "models/player.mdl"
CLASS.DrawTeamRing			= false
CLASS.DrawViewModel			= true
CLASS.CanUseFlashlight      = true
CLASS.MaxHealth				= 100
CLASS.StartHealth			= 100
CLASS.StartArmor			= 0
CLASS.RespawnTime           = 0 // 0 means use the default spawn time chosen by gamemode
CLASS.DropWeaponOnDie		= false
CLASS.TeammateNoCollide 	= true
CLASS.AvoidPlayers			= true // Automatically avoid players that we're no colliding
CLASS.Selectable			= true // When false, this disables all the team checking
CLASS.FullRotation			= false // Allow the player's model to rotate upwards, etc etc

function CLASS:Loadout( pl )

	pl:GiveAmmo( 255,	"Pistol", 		true )
	
	pl:Give( "weapon_pistol" )

end

function CLASS:OnSpawn( pl )
end

function CLASS:OnDeath( pl, attacker, dmginfo )
end

function CLASS:Think( pl )
end

function CLASS:Move( pl, mv )
end

function CLASS:OnKeyPress( pl, key )
end

function CLASS:OnKeyRelease( pl, key )
end

function CLASS:ShouldDrawLocalPlayer( pl )
	return false
end

function CLASS:CalcView( ply, origin, angles, fov )
end

player_class.Register( "Default", CLASS )

local CLASS = {}
CLASS.DisplayName			= "Spectator Class"
CLASS.DrawTeamRing			= false
CLASS.PlayerModel			= "models/player.mdl"

player_class.Register( "Spectator", CLASS )