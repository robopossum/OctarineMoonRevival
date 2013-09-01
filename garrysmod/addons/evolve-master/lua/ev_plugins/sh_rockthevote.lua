/*-------------------------------------------------------------------------------------------------------------------------
	Rock the Vote
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Rock the Vote"
PLUGIN.Description = "Rock the vote to change the map!"
PLUGIN.Author = "Robopossum"
PLUGIN.ChatCommand = "rtv"
PLUGIN.Privileges = { "Rock the Vote" }



if SERVER then
	function PLUGIN:Call( ply, args )
		voterequested(ply)
        end
end

evolve:RegisterPlugin( PLUGIN )