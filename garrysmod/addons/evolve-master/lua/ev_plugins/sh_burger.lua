/*-------------------------------------------------------------------------------------------------------------------------
	Give burgers to a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Give burgers"
PLUGIN.Description = "Burgers"
PLUGIN.Author = "Robopossum"
PLUGIN.ChatCommand = "burger"
PLUGIN.Usage = "<players> <number>"
PLUGIN.Privileges = { "Burger" }

function PLUGIN:Call( ply, args )
	if ( ply:EV_HasPrivilege( "Burger" ) ) then
		local players = evolve:FindPlayer( args, ply )
                if(#args < 2) then
                     local burger = " many"
                else
		     local burger = args[ #args ]
                end
				
		evolve:Notify(evolve.colors.red, evolve:CreatePlayerList( players ), evolve.colors.white, " receives ",evolve.colors.red, burger,evolve.colors.white, "burgers!" )
	end
end


evolve:RegisterPlugin( PLUGIN )