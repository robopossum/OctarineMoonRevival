

local PLUGIN = {}
PLUGIN.Title = "Knife Mode"
PLUGIN.Description = "Low Gravity Knife Deathmatch"
PLUGIN.Author = "Robopossum"
PLUGIN.ChatCommand = "knifemode"
PLUGIN.Usage = "[1/0]"
PLUGIN.Privileges = { "Knife Mode" }

PLUGIN.EnabledConVar = CreateConVar( "ttt_knifemode_enabled", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY } )

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Knife Mode" ) ) then
		if SERVER then
			local wasenabled = self.EnabledConVar:GetBool()
			if #args == 0 or ( args[ 1 ] == "1" ) ~= wasenabled then
				local enabled = not wasenabled
				if enabled then
					RunConsoleCommand( "ttt_knifemode_enabled", 1 )
					RunConsoleCommand( "sv_gravity", 40 )
					RunConsoleCommand( "ttt_karma", 0 )
					timer.Simple( 1, function() 
						CheckMode()
						evolve:Notify( evolve.colors.red, "Low Gravity Knife Fight is enabled!" )
						evolve:Notify( evolve.colors.red, "Prepare for shank-verts!" )
					end )	
				else
					RunConsoleCommand( "ttt_knifemode_enabled", 0 )
					RunConsoleCommand( "sv_gravity", 600 )
					RunConsoleCommand( "ttt_karma", 1 )
					timer.Simple( 1, function() 
						CheckMode()
						evolve:Notify( evolve.colors.red, "Low Gravity Knife Fight is disabled!" )
						evolve:Notify( evolve.colors.red, "Shank-verts have ceased." )
					end )	
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
			evolve:Notify( evolve.colors.red, "Get ready to shank at the start of this round!" )
		end
	end
	hook.Add( "TTTPrepareRound", "TTTPrepareRound_KnifeMode", prepareRound )
	
	local function roundStart()
		if PLUGIN.EnabledConVar:GetBool() then
			timer.Simple(0.5, function()
				for _, ply in ipairs( player.GetAll() ) do
						ply:StripWeapons()
				end
			end )
			timer.Create("GiveKnife", 5, 0, function()
				for _, ply in ipairs( player.GetAll() ) do
					if ply:Alive() and ply:IsTerror() then
						ply:Give("weapon_ttt_knife")
					end	
				end
			end	)
			evolve:Notify( evolve.colors.red, "Knife Fight!!!!!!" )
		end
	end
	hook.Add( "TTTBeginRound", "TTTBeginRound_KnifeMode", roundStart )
	
	local function roundEnd()
		timer.Destroy("GiveKnife")
	end
	hook.Add( "TTTEndRound", "TTTEndRound_KnifeMode", roundEnd )
	
end

evolve:RegisterPlugin( PLUGIN )