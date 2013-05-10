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
		startVoteMaybe()
	end	
end

evolve:RegisterPlugin( PLUGIN )