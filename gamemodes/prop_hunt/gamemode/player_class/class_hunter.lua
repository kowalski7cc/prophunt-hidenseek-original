-- Create new class
local CLASS = {}


-- Some settings for the class
CLASS.DisplayName			= "Hunter"
CLASS.WalkSpeed 			= 230
CLASS.CrouchedWalkSpeed 	= 0.2
CLASS.RunSpeed				= 250
CLASS.DuckSpeed				= 0.2
CLASS.DrawTeamRing			= false


-- Called by spawn and sets loadout
function CLASS:Loadout(pl)
    pl:GiveAmmo(64, "Buckshot")
    pl:GiveAmmo(255, "SMG1")
    pl:GiveAmmo(12, "357")
    
    pl:Give("weapon_crowbar")
    pl:Give("weapon_shotgun")
    pl:Give("weapon_smg1")
	pl:Give("item_ar2_grenade")
    pl:Give("weapon_357")
	
	local cl_defaultweapon = pl:GetInfo("cl_defaultweapon") 
 	 
 	if pl:HasWeapon(cl_defaultweapon) then 
 		pl:SelectWeapon(cl_defaultweapon)
 	end 
end


-- Called when player spawns with this class
function CLASS:OnSpawn(pl)
	local unlock_time = math.Clamp(HUNTER_BLINDLOCK_TIME - (CurTime() - GetGlobalFloat("RoundStartTime", 0)), 0, HUNTER_BLINDLOCK_TIME)
	
	--function MyLockFunc()
	--function MyUnlockFunc()
	
	local unblindfunc = function()
		--MyUnblindFunc(pl.Blind(false))
		pl:Blind(false)
	end
	local lockfunc = function()
		--MyLockFunc(pl.Lock())
		pl.Lock(pl)
	end
	local unlockfunc = function()
		--MyUnlockFunc(pl.UnLock())
		pl.UnLock(pl)
	end
	
	if unlock_time > 2 then
		pl:Blind(true)
		
		timer.Simple(unlock_time, unblindfunc)
		
		timer.Simple(2, lockfunc)
		timer.Simple(unlock_time, unlockfunc)
	end
end


-- Called when a player dies with this class
function CLASS:OnDeath(pl, attacker, dmginfo)
	pl:CreateRagdoll()
	pl:UnLock()
end


-- Register
player_class.Register("Hunter", CLASS)
