local PLUGIN = {}
PLUGIN.Title = "Crowbar Crab Mode"
PLUGIN.Description = "Traitors fight the crowbar crabs."
PLUGIN.Author = "Robopossum"
PLUGIN.ChatCommand = "crabmode"
PLUGIN.Usage = "[1/0]"
PLUGIN.Privileges = { "Crab Mode" }

PLUGIN.EnabledConVar = CreateConVar( "ttt_crabmode_enabled", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY } )

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Crab Mode" ) ) then
		if SERVER then
			local wasenabled = self.EnabledConVar:GetBool()
			if #args == 0 or ( args[ 1 ] == "1" ) ~= wasenabled then
				local enabled = not wasenabled
				if enabled then
					RunConsoleCommand( "ttt_crabmode_enabled", 1 )
					evolve:Notify( evolve.colors.red, "Crowbar Crab Survival mode has been enabled!" )
				else
					RunConsoleCommand( "ttt_crabmode_enabled", 0 )
					evolve:Notify( evolve.colors.red, "Crowbar Crab Survival mode has been disabled!" )
				end
			end
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

if SERVER then
	local function prepareRound()
		if PLUGIN.EnabledConVar:GetBool() then
			timer.Simple(0.5, function()
				for _, wep in ipairs( ents.FindByClass( "weapon_*" ) ) do
					wep:Remove()
				end
				for _, ammo in ipairs( ents.FindByClass( "item_*" ) ) do
					ammo:Remove()
				end
				for _, ply in ipairs( player.GetAll() ) do
					ply:StripWeapons()
				end
			end )
			evolve:Notify( evolve.colors.red, "Crab" )
			timer.Simple( 29, function()
				for _, ply in ipairs( player.GetAll() ) do
					if ply:Alive() then
						ply:Kill()
					end	
				end
			end )
		end
	end
	hook.Add( "TTTPrepareRound", "TTTPrepareRound_CrabMode", prepareRound )
	
	local function roundStart()
		if PLUGIN.EnabledConVar:GetBool() then
			timer.Simple(0.5, function()
				for _, ply in ipairs( player.GetAll() ) do
					if ply:Alive() and ply:IsTerror() then
						ply:StripWeapons()
					end	
				end
				for _, ply in ipairs( player.GetAll() ) do
					if ply:Alive() and ply:IsTerror() and ply:IsActiveTraitor() then
						ply:Give("weapon_zm_improvised")
					end	
				end
			end )
			evolve:Notify( evolve.colors.red, "Crab People!" )
		end
	end
	hook.Add( "TTTBeginRound", "TTTBeginRound_CrabMode", roundStart )
	
	local function roundEnd()
		if PLUGIN.EnabledConVar:GetBool() then
			for _, ply in ipairs( player.GetAll() ) do
				if ply:IsValid() then
					ply:ConCommand("-duck")
				end	
			end	
		end	
	end
	hook.Add("TTTEndRound", "TTTEndRound_CrabMode", roundEnd)
end	
	

evolve:RegisterPlugin( PLUGIN )