//Thanks Blasteh for the fix!

/*
        Start of the death message stuff.
*/
 
include( 'vgui/vgui_gamenotice.lua' )
 
local function CreateDeathNotify()
 
        local x, y = ScrW(), ScrH()
 
        g_DeathNotify = vgui.Create( "DNotify" )
       
        g_DeathNotify:SetPos( 0, 25 )
        g_DeathNotify:SetSize( x - ( 25 ), y )
        g_DeathNotify:SetAlignment( 9 )
        g_DeathNotify:SetSkin( GAMEMODE.HudSkin )
        g_DeathNotify:SetLife( 4 )
        g_DeathNotify:ParentToHUD()
 
end
 
hook.Add( "InitPostEntity", "CreateDeathNotify", CreateDeathNotify )
--[[
local function RecvPlayerKilledByPlayer( message )
 
        local victim    = message:ReadEntity();
        local inflictor = message:ReadString();
        local attacker  = message:ReadEntity();
       
        GAMEMODE:AddDeathNotice( victim, inflictor, attacker ) 
 
 
end
 
usermessage.Hook( "PlayerKilledByPlayer", RecvPlayerKilledByPlayer )
--]]
 
local function RecvPlayerKilledByPlayer()
 
        local victim    = net.ReadEntity();
        local inflictor = net.ReadString();
        local attacker  = net.ReadEntity();
 
       
        if ( !IsValid( attacker ) ) then return end
        if ( !IsValid( victim ) ) then return end
                       
        GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team() )
 
end
       
net.Receive( "PlayerKilledByPlayer", RecvPlayerKilledByPlayer )
 
--[[
local function RecvPlayerKilledSelf( message )
 
        local victim    = message:ReadEntity();                
        GAMEMODE:AddPlayerAction( victim, GAMEMODE.SuicideString );
 
end
       
usermessage.Hook( "PlayerKilledSelf", RecvPlayerKilledSelf )
--]]
local function RecvPlayerKilledSelf()
 
        local victim    = net.ReadEntity();
        if ( !IsValid( victim ) ) then return end
        GAMEMODE:AddDeathNotice( victim:Name(), victim:Team(), "suicide", victim:Name(), victim:Team() )
 
end
       
net.Receive( "PlayerKilledSelf", RecvPlayerKilledSelf )
--[[
local function RecvPlayerKilled( message )
 
        local victim    = message:ReadEntity();
        local inflictor = message:ReadString();
        local attacker  = "#" .. message:ReadString();
                       
        GAMEMODE:AddDeathNotice( victim, inflictor, attacker )
 
end
       
usermessage.Hook( "PlayerKilled", RecvPlayerKilled )
--]]
 
local function RecvPlayerKilled()
 
        local victim    = net.ReadEntity();
        if ( !IsValid( victim ) ) then return end
        local inflictor = net.ReadString();
        local attacker  = "#" .. net.ReadString();
                       
        GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim:Name(), victim:Team() )
 
end
       
net.Receive( "PlayerKilled", RecvPlayerKilled )
--[[
local function RecvPlayerKilledNPC( message )
 
        local victim    = "#" .. message:ReadString();
        local inflictor = message:ReadString();
        local attacker  = message:ReadEntity();
                       
        GAMEMODE:AddDeathNotice( victim, inflictor, attacker )
 
end
       
usermessage.Hook( "PlayerKilledNPC", RecvPlayerKilledNPC )
--]]
 
local function RecvPlayerKilledNPC()
 
        local victimtype = net.ReadString();
        local victim    = "#" .. victimtype;
        local inflictor = net.ReadString();
        local attacker  = net.ReadEntity();
 
        --
        -- For some reason the killer isn't known to us, so don't proceed.
        --
        if ( !IsValid( attacker ) ) then return end
                       
        GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim, -1 )
       
        local bIsLocalPlayer = (IsValid(attacker) && attacker == LocalPlayer())
       
        local bIsEnemy = IsEnemyEntityName( victimtype )
        local bIsFriend = IsFriendEntityName( victimtype )
       
        if ( bIsLocalPlayer && bIsEnemy ) then
                achievements.IncBaddies();
        end
       
        if ( bIsLocalPlayer && bIsFriend ) then
                achievements.IncGoodies();
        end
       
        if ( bIsLocalPlayer && (!bIsFriend && !bIsEnemy) ) then
                achievements.IncBystander();
        end
 
end
       
net.Receive( "PlayerKilledNPC", RecvPlayerKilledNPC )
 
--[[
local function RecvNPCKilledNPC( message )
 
        local victim    = "#" .. message:ReadString();
        local inflictor = message:ReadString();
        local attacker  = "#" .. message:ReadString();
               
        GAMEMODE:AddDeathNotice( victim, inflictor, attacker )
 
end
 
usermessage.Hook( "NPCKilledNPC", RecvNPCKilledNPC )
--]]
 
local function RecvNPCKilledNPC()
 
        local victim    = "#" .. net.ReadString();
        local inflictor = net.ReadString();
        local attacker  = "#" .. net.ReadString();
                       
        GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim, -1 )
 
end
       
net.Receive( "NPCKilledNPC", RecvNPCKilledNPC )
 
/*---------------------------------------------------------
   Name: gamemode:AddDeathNotice( Victim, Weapon, Attacker )
   Desc: Adds an death notice entry
---------------------------------------------------------*/
--function GM:AddDeathNotice( victim, inflictor, attacker )
function GM:AddDeathNotice( Attacker, team1, Inflictor, Victim , team2 )
 
        if ( !IsValid( g_DeathNotify ) ) then return end
 
        local pnl = vgui.Create( "GameNotice", g_DeathNotify )
        local color1
        local color2
       
        //Deprecated: MsgAll("Victim: "..Victim.." Attacker: "..Attacker.."\n")
       
        if ( team1 == -1 ) then color1 = table.Copy( NPC_Color )
        else color1 = table.Copy( team.GetColor( team1 ) ) end
       
        if ( team2 == -1 ) then color2 = table.Copy( NPC_Color )
        else color2 = table.Copy( team.GetColor( team2 ) ) end
       
        if Victim == Attacker then
                pnl:AddIcon( "suicide" )
                pnl:AddText( Attacker, color1)
        else
                pnl:AddText( Attacker, color1)
                pnl:AddIcon( Inflictor )
                pnl:AddText( Victim, color2 )
        end
       
       
        g_DeathNotify:AddItem( pnl )
 
end
 
function GM:AddPlayerAction( ... )
       
        if ( !IsValid( g_DeathNotify ) ) then return end
 
        local pnl = vgui.Create( "GameNotice", g_DeathNotify )
 
        for k, v in ipairs({...}) do
                pnl:AddText( v )
        end
       
        // The rest of the arguments should be re-thought.
        // Just create the notify and add them instead of trying to fit everything into this function!???
       
        g_DeathNotify:AddItem( pnl )
       
end
