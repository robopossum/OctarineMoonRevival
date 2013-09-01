/*----------------------------------------
	Force Vote
----------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Force Vote"
PLUGIN.Description = "Force vote to change the map!"
PLUGIN.Author = "Robopossum"
PLUGIN.ChatCommand = "forcevote"
PLUGIN.Privileges = { "Force Vote" }

function PLUGIN:Call(ply, args)
	if( ply:EV_HasPrivilege("Force Vote") ) then
                evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has forced a map vote." )
                evolve:Notify( evolve.colors.red, "Map vote will happen at the end of this round." ) 
		overrideVote()
	end	
end

evolve:RegisterPlugin( PLUGIN )