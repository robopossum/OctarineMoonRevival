

local PLUGIN = {}
PLUGIN.Title = "Raptor Mode"
PLUGIN.Description = "Traitors are the hunters, Innocents are the raptors"
PLUGIN.Author = "Robopossum"
PLUGIN.ChatCommand = "raptormode"
PLUGIN.Usage = "[1/0]"
PLUGIN.Privileges = { "Raptor Mode" }

PLUGIN.EnabledConVar = CreateConVar( "ttt_raptormode_enabled", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY } )

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Raptor Mode" ) ) then
		if SERVER then
			local wasenabled = self.EnabledConVar:GetBool()
			if #args == 0 or ( args[ 1 ] == "1" ) ~= wasenabled then
				local enabled = not wasenabled
				if enabled then
					RunConsoleCommand( "ttt_raptormode_enabled", 1 )
					timer.Simple( 1, function() 
						CheckMode()
						evolve:Notify( evolve.colors.red, "Raptor mode has been enabled!" )
						evolve:Notify( evolve.colors.red, "Prepare for Raptor-verts!" )
					end )	
				else
					RunConsoleCommand( "ttt_raptormode_enabled", 0 )
					timer.Simple( 1, function() 
						CheckMode()
						removeWalk()
						evolve:Notify( evolve.colors.red, "Raptor mode has been disabled!" )
						evolve:Notify( evolve.colors.red, "Raptor-verts have ceased!" )
					end )	
				end
			end
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

if SERVER then

	Walkers = {}

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
			evolve:Notify( evolve.colors.red, "Get ready to raptor!" )
		end
	end
	hook.Add( "TTTPrepareRound", "TTTPrepareRound_RaptorMode", prepareRound )
	
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
						ply:Give("weapon_zm_shotgun")
						ply:SetAmmo(30, "Buckshot")
						ply:ConCommand("+walk")
						table.insert( Walkers, ply)
					end	
				end
				for _, ply in ipairs( player.GetAll() ) do
					if ply:Alive() and ply:IsTerror() and not ply:IsActiveTraitor() then
						ply:Give("weapon_zm_improvised")
					end	
				end
			end )
			evolve:Notify( evolve.colors.red, "Jurassic Park Mutherhubbards!" )
		end
	end
	hook.Add( "TTTBeginRound", "TTTBeginRound_RaptorMode", roundStart )

	local function roundEnd()
		if PLUGIN.EnabledConVar:GetBool() then
			for _, ply in ipairs( Walkers ) do
				if ply:IsValid() then
					ply:ConCommand("-walk")
				end	
			end	
		end	
	end
	hook.Add("TTTEndRound", "TTTEndRound_RaptorMode", roundEnd)
	
	local function removeWalk( )
		for _, ply in ipairs ( player.GetAll() ) do
			ply:ConCommand("-walk")
		end	
	end	
	
end

evolve:RegisterPlugin( PLUGIN )	