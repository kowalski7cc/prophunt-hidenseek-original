-- Props will not be able to become these models
BANNED_PROP_MODELS = {
	"models/props/cs_assault/dollar.mdl",
	"models/props/cs_assault/money.mdl",
	"models/props/cs_office/snowman_arm.mdl",
	"models/props/cs_office/computer_mouse.mdl",
	"models/props/cs_office/projector_remote.mdl",
	"models/props/cs_militia/reload_bullet_tray.mdl",
	"models/foodnhouseholditems/egg.mdl"
}


-- Maximum time (in minutes) for this fretta gamemode (Default: 30)
GAME_TIME = 30


-- Number of seconds hunters are blinded/locked at the beginning of the map (Default: 30)
HUNTER_BLINDLOCK_TIME = 30


-- Health points removed from hunters when they shoot  (Default: 25)
HUNTER_FIRE_PENALTY = 5


-- How much health to give back to the Hunter after killing a prop (Default: 100)
HUNTER_KILL_BONUS = 100


-- If you loose one of these will be played
-- Set blank to disable

-- // DEV HELP: why this is  not working anymore? \\ --
LOSS_SOUNDS = {
	"vo/announcer_failure.wav",
	"vo/announcer_you_failed.wav"
}

-- Sound files hunters can taunt with
-- You need at least 2 files listed here
HUNTER_TAUNTS = {

	-- Normal Taunts
	"taunts/hunters/come_to_papa.wav",
	"taunts/hunters/father.mp3",
	"taunts/hunters/fireassis.wav",
	"taunts/hunters/hitassist.wav",
	"taunts/hunters/now_what.wav",
	"taunts/hunters/you_dont_know_the_power.wav",
	"taunts/hunters/you_underestimate_the_power.wav",
	"taunts/hunters/glados-president.wav",
	"taunts/hunters/rude.mp3",
	"taunts/hunters/soul.mp3",
	"taunts/hunters/illfindyou.mp3",
	
	-- Half-Life 2
	"vo/k_lab/ba_guh.wav",

	-- Male
	"vo/npc/male01/vanswer13.wav",
	"vo/npc/male01/thehacks01.wav",
	"vo/npc/male01/runforyourlife02.wav",
	"vo/npc/male01/overhere01.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav"
}


-- Sound files props can taunt with
-- You need at least 2 files listed here
PROP_TAUNTS = {
	"taunts/boom_headshot.wav",
	"taunts/go_away_or_i_shall.wav",
	"taunts/ill_be_back.wav",
	"taunts/negative.wav",
	"taunts/doh.wav",
	"taunts/oh_yea_he_will_pay.wav",
	"taunts/ok_i_will_tell_you.wav",
	"taunts/please_come_again.wav",
	"taunts/threat_neutralized.wav",
	"taunts/what_is_wrong_with_you.wav",
	"taunts/woohoo.wav",
	"taunts/props/1.wav",
	"taunts/props/2.wav",
	"taunts/props/3.wav",
	"taunts/props/4.wav",
	"taunts/props/5.wav",
	"taunts/props/6.wav",
	"taunts/props/7.wav",
	"taunts/props/8.wav",
	"taunts/props/9.wav",
	"taunts/props/10.wav",
	"taunts/props/11.wav",
	"taunts/props/12.wav",
	"taunts/props/14.wav",
	"taunts/props/15.wav",
	"taunts/props/16.wav",
	"taunts/props/17.mp3",
	"taunts/props/18.wav",
	"taunts/props/19.wav",
	"taunts/props/20.wav",
	"taunts/props/21.wav",
	"taunts/props/22.wav",
	"taunts/props/23.wav",
	"taunts/props/24.wav",
	"taunts/props/25.wav",
	"taunts/props/26.wav",
	"taunts/props/27.wav",
	"taunts/props/28.wav",
	"taunts/props/29.wav",
	"taunts/props/30.wav",
	"taunts/props/31.mp3",
	"taunts/props/32.mp3",
	"taunts/props/33.mp3",
	"taunts/props/34.mp3",
	"taunts/props/35.mp3",
	
	-- // Half-life 2 taunts \\ --
	
	-- Citadel part
	"vo/citadel/br_ohshit.wav",
	"vo/citadel/br_youfool.wav",
	"vo/citadel/br_youneedme.wav",
	
	-- Coast part
	"vo/coast/odessa/male01/nlo_cheer01.wav",
	"vo/coast/odessa/male01/nlo_cheer02.wav",
	"vo/coast/odessa/male01/nlo_cheer03.wav",
	"vo/coast/odessa/male01/nlo_cheer04.wav",
	"vo/coast/odessa/female01/nlo_cheer01.wav",
	"vo/coast/odessa/female01/nlo_cheer02.wav",
	"vo/coast/odessa/female01/nlo_cheer03.wav",
	
	-- Gman
	"vo/gman_misc/gman_riseshine.wav",
	
	-- // General NPC Quotes \\ --
		
	-- Barney
	"vo/npc/barney/ba_damnit.wav",
	"vo/npc/barney/ba_laugh01.wav",
	"vo/npc/barney/ba_laugh02.wav",
	"vo/npc/barney/ba_laugh03.wav",
	"vo/npc/barney/ba_laugh04.wav",
	
	-- Male Citizen
	"vo/npc/male01/hacks01.wav",
	"vo/npc/male01/hacks02.wav",
	"vo/npc/male01/vanswer01.wav",
	"vo/npc/male01/question05.wav",
	"vo/npc/male01/question06.wav",
	"vo/npc/male01/answer34.wav",
	"vo/npc/male01/question30.wav",
	"vo/npc/male01/question26.wav",
	"vo/npc/male01/incoming02.wav",
	"vo/npc/male01/gethellout.wav",
	
	-- Father Grigori
	"vo/ravenholm/madlaugh04.wav",
	
	-- Fixed taunts
	"taunts/fixed/13_fix.wav",
	"taunts/fixed/bees_fix.wav",
	
	-- Additionals ==
	
	-- Moved from Hunter to Props (this supposed to be props...)
	"taunts/hunters/laugh.wav"
}


-- Seconds a player has to wait before they can taunt again (Default: 2 or 3)
TAUNT_DELAY = 2


-- Rounds played on a map (Default: 10)
ROUNDS_PER_MAP = 10


-- Time (in seconds) for each round (Default: 300)
ROUND_TIME = 300


-- Determains if players should be team swapped every round [0 = No, 1 = Yes] (Default: 1)
SWAP_TEAMS_EVERY_ROUND = 1


-- If you win, one of these will be played
-- Set blank to disable

-- // DEV HELP: why this is  not working anymore? \\ --
VICTORY_SOUNDS = {
	"vo/announcer_success.wav",
	"vo/announcer_victory.wav",
	"vo/announcer_we_succeeded.wav"
}