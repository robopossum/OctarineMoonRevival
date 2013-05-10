/*-------------------------------------------------------------------------------------------------------------------------
	Rocket a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Rocket"
PLUGIN.Description = "Rocket a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "rocket"
PLUGIN.Usage = "[players]"
PLUGIN.Privileges = { "Rocket", "Rocket Self" }

function PLUGIN:Explode( ply )
	local explosive = ents.Create( "env_explosion" )
	explosive:SetPos( ply:GetPos() )
	explosive:SetOwner( ply )
	explosive:Spawn()
	explosive:SetKeyValue( "iMagnitude", "1" )
	explosive:Fire( "Explode", 0, 0 )
	explosive:EmitSound( "ambient/explosions/explode_4.wav", 500, 500 )
	
	ply:StopParticles()
	ply:Kill()
end

function PLUGIN:Call( ply, args )
	local players = evolve:FindPlayer( args, ply )
	if ( ply:EV_HasPrivilege( "Rocket" ) or ( #players == 1 and ply == players[ 1 ] and ply:Alive() and ply:EV_HasPrivilege( "Rocket Self" ))) then
		
		for _, pl in ipairs( players ) do
			pl:SetMoveType( MOVETYPE_WALK )
			pl:SetVelocity( Vector( 0, 0, 4000 ) )
			ParticleEffectAttach( "rockettrail", PATTACH_ABSORIGIN_FOLLOW, pl, 0 )
			
			timer.Simple( 1, function() PLUGIN.Explode(PLUGIN, pl) end)
                      //timer.Simple( 1, PLUGIN.Explode, PLUGIN, pl )
		end
		
		if ( #players > 0 ) then
			evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " gave ", evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " Pshooooooes." )
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayers )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "rocket", unpack( players ) )
	else
		return "Rocket", evolve.category.punishment
	end
end

evolve:RegisterPlugin( PLUGIN )