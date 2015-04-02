-- Send the required lua files to the client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_player.lua")


-- If there is a mapfile send it to the client (sometimes servers want to change settings for certain maps)
if file.Exists("../gamemodes/prop_hunt/gamemode/maps/"..game.GetMap()..".lua", "LUA") then
	AddCSLuaFile("maps/"..game.GetMap()..".lua")
end


-- Include the required lua files
include("sh_init.lua")


-- Server only constants
EXPLOITABLE_DOORS = {
	"func_door",
	"prop_door_rotating", 
	"func_door_rotating"
}
USABLE_PROP_ENTITIES = {
	"prop_physics",
	"prop_physics_multiplayer"
}


-- Send the required resources to the client
for _, taunt in pairs(HUNTER_TAUNTS) do resource.AddFile("sound/"..taunt) end
for _, taunt in pairs(PROP_TAUNTS) do resource.AddFile("sound/"..taunt) end

-- Called alot
function GM:CheckPlayerDeathRoundEnd()
	if !GAMEMODE.RoundBased || !GAMEMODE:InRound() then 
		return
	end

	local Teams = GAMEMODE:GetTeamAliveCounts()

	if table.Count(Teams) == 0 then
		GAMEMODE:RoundEndWithResult(1001, "Draw, everyone loses!")
		return
	end

	if table.Count(Teams) == 1 then
		local TeamID = table.GetFirstKey(Teams)
		GAMEMODE:RoundEndWithResult(TeamID, team.GetName(1).." win!")
		return
	end
	
end


-- Called when an entity takes damage
function EntityTakeDamage(ent, dmginfo)
    local att = dmginfo:GetAttacker()
	if GAMEMODE:InRound() && ent && ent:GetClass() != "ph_prop" && !ent:IsPlayer() && att && att:IsPlayer() && att:Team() == TEAM_HUNTERS && att:Alive() then
		att:SetHealth(att:Health() - HUNTER_FIRE_PENALTY)
		if att:Health() <= 0 then
			MsgAll(att:Name() .. " felt guilty for hurting so many innocent props and committed suicide\n")
			att:Kill()
		end
	end
end
hook.Add("EntityTakeDamage", "PH_EntityTakeDamage", EntityTakeDamage)


-- Called when player tries to pickup a weapon
function GM:PlayerCanPickupWeapon(pl, ent)
 	if pl:Team() != TEAM_HUNTERS then
		return false
	end
	
	return true
end

-- Make a variable for custom 3 combines.
local playerModels = {}
local function addModel(model)
	local t = {}
	t.model = model
	table.insert(playerModels, t)
end

-- delivered from stock Gmod's player manager
addModel("combine")
addModel("combineprison")
addModel("combineelite")
addModel("police")

function GM:PlayerSetModel(pl)
	-- set antlion gib small for Prop model. Do not change into others because this might purposed as a hitbox.
	local player_model = "models/Gibs/Antlion_gib_small_3.mdl"

	-- set 3 combine models based cl_playermodel info.
	local cl_playermodel = pl:GetInfo ( "cl_playermodel" )
	
	-- make it random selection
	local customModel = table.Random(playerModels)
	cl_playermodel = customModel.model
	
	-- translate it
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	
	-- for Hunter only
    if pl:Team() == TEAM_HUNTERS then
				player_model = modelname
    end
	
	-- Precache it
	util.PrecacheModel(player_model)
	pl:SetModel(player_model)
end
	
-- Called when a player tries to use an object
function GM:PlayerUse(pl, ent)
	if !pl:Alive() || pl:Team() == TEAM_SPECTATOR then return false end
	
	if pl:Team() == TEAM_PROPS && pl:IsOnGround() && !pl:Crouching() && table.HasValue(USABLE_PROP_ENTITIES, ent:GetClass()) && ent:GetModel() then
		if table.HasValue(BANNED_PROP_MODELS, ent:GetModel()) then
			pl:ChatPrint("That prop has been banned by the server.")
		elseif ent:GetPhysicsObject():IsValid() && pl.ph_prop:GetModel() != ent:GetModel() then
			local ent_health = math.Clamp(ent:GetPhysicsObject():GetVolume() / 250, 1, 200)
			local new_health = math.Clamp((pl.ph_prop.health / pl.ph_prop.max_health) * ent_health, 1, 200)
			local per = pl.ph_prop.health / pl.ph_prop.max_health
			pl.ph_prop.health = new_health
			
			pl.ph_prop.max_health = ent_health
			pl.ph_prop:SetModel(ent:GetModel())
			pl.ph_prop:SetSkin(ent:GetSkin())
			pl.ph_prop:SetSolid(SOLID_BSP)
			pl.ph_prop:SetPos(pl:GetPos() - Vector(0, 0, ent:OBBMins().z))
			pl.ph_prop:SetAngles(pl:GetAngles())
			
			local hullxymax = math.Round(math.Max(ent:OBBMaxs().x, ent:OBBMaxs().y))
			local hullxymin = hullxymax * -1
			local hullz = math.Round(ent:OBBMaxs().z)
			
			pl:SetHull(Vector(hullxymin, hullxymin, 0), Vector(hullxymax, hullxymax, hullz))
			pl:SetHullDuck(Vector(hullxymin, hullxymin, 0), Vector(hullxymax, hullxymax, hullz))
			pl:SetHealth(new_health)
			
			umsg.Start("SetHull", pl)
				umsg.Long(hullxymax)
				umsg.Long(hullz)
				umsg.Short(new_health)
			umsg.End()
		end
	end
	
	-- Prevent the door exploit
	if table.HasValue(EXPLOITABLE_DOORS, ent:GetClass()) && pl.last_door_time && pl.last_door_time + 1 > CurTime() then
		return false
	end
	
	pl.last_door_time = CurTime()
	return true
end

-- Called when player presses [F3]. Plays a taunt for their team
function GM:ShowSpare1(pl)
	if GAMEMODE:InRound() && pl:Alive() && (pl:Team() == TEAM_HUNTERS || pl:Team() == TEAM_PROPS) && pl.last_taunt_time + TAUNT_DELAY <= CurTime() && #PROP_TAUNTS > 1 && #HUNTER_TAUNTS > 1 then
		repeat
			if pl:Team() == TEAM_HUNTERS then
				rand_taunt = table.Random(HUNTER_TAUNTS)
			else
				rand_taunt = table.Random(PROP_TAUNTS)
			end
		until rand_taunt != pl.last_taunt
		
		pl.last_taunt_time = CurTime()
		pl.last_taunt = rand_taunt
		
		pl:EmitSound(rand_taunt, 100)
	end	
end

--[[
-- Called when the gamemode is initialized -- This does not even working since the command is blocked.
function Initialize()
	game.ConsoleCommand("mp_flashlight 1\n")
end
hook.Add("Initialize", "PH_Initialize", Initialize)
]]--

-- Called when a player leaves
function PlayerDisconnected(pl)
	pl:RemoveProp()
end
hook.Add("PlayerDisconnected", "PH_PlayerDisconnected", PlayerDisconnected)


-- Called when the players spawns
function PlayerSpawn(pl)

	local oldhands = pl:GetHands()
	if ( IsValid( oldhands ) ) then oldhands:Remove() end

	local hands = ents.Create( "gmod_hands" )
	if ( IsValid( hands ) ) then
		pl:SetHands( hands )
		hands:SetOwner( pl )

		-- Which hands should we use?
		local cl_playermodel = pl:GetInfo( "cl_playermodel" )
		local info = player_manager.TranslatePlayerHands( cl_playermodel )
		if ( info ) then
			hands:SetModel( info.model )
			hands:SetSkin( info.skin )
			hands:SetBodyGroups( info.body )
		end

		-- Attach them to the viewmodel
		local vm = pl:GetViewModel( 0 )
		hands:AttachToViewmodel( vm )

		vm:DeleteOnRemove( hands )
		pl:DeleteOnRemove( hands )

		hands:Spawn()
 	end

	pl:Blind(false)
	pl:RemoveProp()
	pl:SetColor( Color(255, 255, 255, 255))
	pl:SetRenderMode( RENDERMODE_TRANSALPHA )
	pl:UnLock()
	pl:ResetHull()
	pl.last_taunt_time = 0
	
	umsg.Start("ResetHull", pl)
	umsg.End()
	
	pl:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
end
hook.Add("PlayerSpawn", "PH_PlayerSpawn", PlayerSpawn)


-- Removes all weapons on a map
function RemoveWeaponsAndItems()
	for _, wep in pairs(ents.FindByClass("weapon_*")) do
		wep:Remove()
	end
	
	for _, item in pairs(ents.FindByClass("item_*")) do
		item:Remove()
	end
end
hook.Add("InitPostEntity", "PH_RemoveWeaponsAndItems", RemoveWeaponsAndItems)


-- Called when round ends
function RoundEnd()
	for _, pl in pairs(team.GetPlayers(TEAM_HUNTERS)) do
		pl:Blind(false)
		pl:UnLock()
	end
end
hook.Add("RoundEnd", "PH_RoundEnd", RoundEnd)


-- This is called when the round time ends (props win)
function GM:RoundTimerEnd()
	if !GAMEMODE:InRound() then
		return
	end
   
	GAMEMODE:RoundEndWithResult(TEAM_PROPS, "Props win!")
end


-- Called before start of round
function GM:OnPreRoundStart(num)
	game.CleanUpMap()
	
		if GetGlobalInt("RoundNumber") != 1 && (SWAP_TEAMS_EVERY_ROUND == 1 || ((team.GetScore(TEAM_PROPS) + team.GetScore(TEAM_HUNTERS)) > 0 || SWAP_TEAMS_POINTS_ZERO==1)) then
		for _, pl in pairs(player.GetAll()) do
				if pl:Team() == TEAM_PROPS || pl:Team() == TEAM_HUNTERS then
				if pl:Team() == TEAM_PROPS then
					pl:SetTeam(TEAM_HUNTERS)
				else
					pl:SetTeam(TEAM_PROPS)
				end
				
				pl:ChatPrint("Teams have been swapped!")

			end
		end
	end
	
	UTIL_StripAllPlayers()
	UTIL_SpawnAllPlayers()
	UTIL_FreezeAllPlayers()
end