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
		local players = evolve:FindPlayer( args[1], nil, nil, true )
		
		if ( players[1] ) then			
			local achievement = table.concat( args, " ", 2 )
			
			if ( #achievement > 0 ) then
				for _, pl in ipairs( players ) do
					evolve:Notify( team.GetColor( pl:Team() ), pl:Nick(), color_white, " receives ", Color( 255, 201, 0, 255 ), achievement , color_white, " burgers!")
				end
			else
				evolve:Notify( ply, evolve.colors.red, "No achievement specified." )
			end
		else
			evolve:Notify( ply, evolve.colors.red, evolve.constants.noplayersnoimmunity )
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end


evolve:RegisterPlugin( PLUGIN )