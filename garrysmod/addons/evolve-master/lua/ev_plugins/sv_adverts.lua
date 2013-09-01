/*-------------------------------------------------------------------------------------------------------------------------
	Annoying chat adverts
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Adverts"
PLUGIN.Description = "Annoying chat adverts"
PLUGIN.Author = "Metapyziks"
PLUGIN.Usage = nil
PLUGIN.Privileges = nil

PLUGIN.Adverts = { }
PLUGIN.Shankverts = { }
PLUGIN.Raptorverts = { }
PLUGIN.IntervalConvar = CreateConVar("ev_advert_interval", "60")

function PLUGIN:BroadcastChatAdverts()
	if not #self.Adverts then return end
	if( #self.Adverts > 0 and #player.GetAll() > 0 ) then
		evolve:Notify( evolve.colors.red, string.Trim( table.Random( self.Adverts )))
	end

	//timer.Adjust( "EV_ChatAdverts", self.IntervalConvar:GetInt(), 0, function() PLUGIN.BroadcastChatAdverts(PLUGIN) end)
end

function PLUGIN:BroadcastShankverts()
	if not #self.Shankverts then return end
	if( #self.Shankverts > 0 and #player.GetAll() > 0 ) then
		evolve:Notify( evolve.colors.red, string.Trim( table.Random( self.Shankverts )))
	end
end

function PLUGIN:BroadcastRaptorverts()
	if not #self.Raptorverts then return end
	if( #self.Raptorverts > 0 and #player.GetAll() > 0 ) then
		evolve:Notify( evolve.colors.red, string.Trim( table.Random( self.Raptorverts )))
	end
end

function CheckMode() 
	print("Checking Mode")
	if( GetConVarNumber( "ttt_knifemode_enabled" ) == 1) then
		if(timer.Exists("EV_ChatAdverts")) then
			timer.Destroy("EV_ChatAdverts")
		end
		if(timer.Exists("EV_Raptorverts")) then
			timer.Destroy("EV_Raptorverts")
		end
		timer.Create( "EV_Shankverts", PLUGIN.IntervalConvar:GetInt(), 0, function() PLUGIN.BroadcastShankverts(PLUGIN) end)	
	elseif ( GetConVarNumber( "ttt_raptormode_enabled" ) == 1) then
		if(timer.Exists("EV_ChatAdverts")) then
			timer.Destroy("EV_ChatAdverts")
		end
		if(timer.Exists("EV_Shankverts")) then
			timer.Destroy("EV_Shankverts")
		end
		timer.Create( "EV_Raptorverts", PLUGIN.IntervalConvar:GetInt(), 0, function() PLUGIN.BroadcastRaptorverts(PLUGIN) end)
	else	
		if(timer.Exists("EV_Shankverts")) then
			timer.Destroy("EV_Shankverts")
		end
		if(timer.Exists("EV_Raptorverts")) then
			timer.Destroy("EV_Raptorverts")
		end
		timer.Create( "EV_ChatAdverts", PLUGIN.IntervalConvar:GetInt(), 0, function() PLUGIN.BroadcastChatAdverts(PLUGIN) end)
	end	
end


timer.Create( "EV_ChatAdverts", PLUGIN.IntervalConvar:GetInt(), 0, function() PLUGIN.BroadcastChatAdverts(PLUGIN) end)

if( file.Exists( "ev_chatadverts.txt", "DATA" )) then
	PLUGIN.Adverts = string.Explode( "\n", file.Read( "ev_chatadverts.txt", "DATA" ))
	for i=1, table.Count(PLUGIN.Adverts) do
		PLUGIN.Adverts[i] = string.Trim(PLUGIN.Adverts[i])
	end	
else
	print( "No Advert File Found" )
end

if( file.Exists( "ev_shankverts.txt", "DATA" )) then
	PLUGIN.Shankverts = string.Explode( "\n", file.Read( "ev_shankverts.txt", "DATA" ))
	for i=1, table.Count(PLUGIN.Shankverts) do
		PLUGIN.Shankverts[i] = string.Trim(PLUGIN.Shankverts[i])
	end	
else
	print( "No Shankvert File Found" )
end

if( file.Exists( "ev_raptorverts.txt", "DATA" )) then
	PLUGIN.Raptorverts = string.Explode( "\n", file.Read( "ev_raptorverts.txt", "DATA" ))
	for i=1, table.Count(PLUGIN.Raptorverts) do
		PLUGIN.Raptorverts[i] = string.Trim(PLUGIN.Raptorverts[i])
	end	
else
	print( "No Raptorvert File Found" )
end

evolve:RegisterPlugin( PLUGIN )