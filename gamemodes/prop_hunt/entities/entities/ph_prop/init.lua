-- Send required files to client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")


-- Include needed files
include("shared.lua")


-- Called when the entity initializes
function ENT:Initialize()
	self:SetModel("models/player/Kleiner.mdl")
	self.health = 100
end 


-- Called when we take damge
function ENT:OnTakeDamage(dmg)
	local pl = self:GetOwner()
	local attacker = dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()

	-- Health
	if pl && pl:IsValid() && pl:Alive() && pl:IsPlayer() && attacker:IsPlayer() && dmg:GetDamage() > 0 then
		self.health = self.health - dmg:GetDamage()
		pl:SetHealth(self.health)
		
		if self.health <= 0 then
			pl:KillSilent()
			
			if inflictor && inflictor == attacker && inflictor:IsPlayer() then
				inflictor = inflictor:GetActiveWeapon()
				if !inflictor || inflictor == NULL then inflictor = attacker end
			end
			
			net.Start( "PlayerKilledByPlayer" )
		
			net.WriteEntity( pl )
			net.WriteString( inflictor:GetClass() )
			net.WriteEntity( attacker )
		
			net.Broadcast()

	
			MsgAll(attacker:Name() .. " found and killed " .. pl:Name() .. "\n") 
			
			attacker:AddFrags(1)
			pl:AddDeaths(1)
			attacker:SetHealth(math.Clamp(attacker:Health() + GetConVar("HUNTER_KILL_BONUS"):GetInt(), 1, 100))
			
			pl:RemoveProp()
		end
	end
end
