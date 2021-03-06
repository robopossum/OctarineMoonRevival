/*-------------------------------------------------------------------------------------------------------------------------
	Automatic donator status
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Auto Donate"
PLUGIN.Description = "Promotes donators automatically"
PLUGIN.Author = "Metapyziks"
PLUGIN.Usage = nil
PLUGIN.Privileges = nil

function PLUGIN:UpdateDonators()
	local plys = player.GetAll()
	
	if( PLUGIN.DonatorInfo == nil or #plys > 0 ) then
		Msg( "Checking for donator updates...\n" )
		
		local rawInfo = string.Explode( ";", file.Read("donator_info.txt", "DATA") )
		
		PLUGIN.DonatorInfo = {}
		
		for k, v in ipairs( rawInfo ) do
			if( string.len( string.Trim( v ) ) > 0 ) then
				local split = string.Explode( ",", string.Trim( v ) )
				local info = {}
				info.TransIDs = { split[ 1 ] }
				info.Email	  = split[ 2 ]
				info.Amount   = tonumber( split[ 4 ] )
				local ids, ide = string.find( split[ 3 ], "STEAM_[0-5]:[0-9]:[0-9]+" )
				
				if ids ~= nil then
					info.SteamID  = string.sub( split[ 3 ], ids, ide )
				
					if( PLUGIN.DonatorInfo[ info.SteamID ] == nil ) then
						PLUGIN.DonatorInfo[ info.SteamID ] = info
					else
						PLUGIN.DonatorInfo[ info.SteamID ].Amount = PLUGIN.DonatorInfo[ info.SteamID ].Amount + info.Amount
						table.Add( PLUGIN.DonatorInfo[ info.SteamID ].TransIDs, info.TransIDs )
					end
				end
			end
		end
	end


	//local donators = http.Fetch( "http://www.robertandsherman.co.uk/omdonations/donator_info.txt", nil, nil )
	//local donators = http.Fetch( "/178.239.170.105 port 27027/orangebox/garrysmod/data/donator_info.txt", "", callback )
    //    if ( file.Exists("donator_info.txt", "DATA" ) ) then
    //         local donators = file.Read("donator_info.txt", "DATA")
    //    end
end

function PLUGIN:Initialize()
	self.UpdateDonators()
end

function FormatCurrency( amount )
	if( math.floor( amount ) == amount ) then
		return tostring( amount ) .. ".00"
	elseif( math.floor( amount * 10 ) == amount * 10 ) then
		return tostring( amount ) .. "0"
	elseif( math.floor( amount * 100 ) != amount * 100 ) then
		return tostring( math.floor( amount * 100 ) / 100 )
	else
		return tostring( amount )
	end
end

function PLUGIN:PlayerAuthed( ply, steamID, uniqueID )
	local info = self.DonatorInfo[ steamID ]
	
	if( info != nil ) then
		//if( info.Amount >= 2.5 and ply:EV_GetRank() == "guest" ) then
		//	//ply:EV_SetRank( "donator" )
		//	evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " has become a donator! Thank you for your support!" )
		//end
		evolve:Notify( evolve.colors.white, "Thank you ", evolve.colors.blue, ply:Nick(), evolve.colors.white, " for your donation of ", evolve.colors.red, FormatCurrency( info.Amount ), evolve.colors.white, " GBP!" )
	end
end

evolve:RegisterPlugin( PLUGIN )