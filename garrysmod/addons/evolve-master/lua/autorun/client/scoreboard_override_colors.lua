if( CLIENT ) then
	function OverrideScoreboard()
		local namecolor = {
			default = Color(255, 255, 255, 255),
			admin = Color(220, 180, 0, 255),
			dev = Color(195, 0, 180, 255)
		};

		function GAMEMODE:TTTScoreboardColorForPlayer(ply)
			if not IsValid(ply) then return namecolor.default end
			
			if ply:SteamID() == "STEAM_0:1:35909215" then
				return namecolor.dev
			end	
			
			if( evolve ) then
				if( evolve.ranks ) then
					if( ply:EV_GetRank() == "owner") then 
						return Color( 247, 233, 27, 255)
					elseif ( ply:EV_GetRank() == "veteran" ) then
						return Color( 255, 145, 0, 255)
					elseif ( ply:EV_GetRank() == "admin" ) then
						return Color( 40, 72, 252, 255)
					elseif ( ply:EV_GetRank() == "moderator" ) then
						return Color( 40, 182, 252, 255)
					elseif ( ply:EV_GetRank() == "highestdonator" ) then
						return Color( 17, 186, 70, 255)
					elseif ( ply:EV_GetRank() == "higherdonator" ) then
						return Color( 69, 245, 74, 255)
					elseif ( ply:EV_GetRank() == "donator" ) then
						return Color( 182, 255, 158, 255)						
					end	
				end
			end
			return namecolor.default
		end
	end

	timer.Simple( 1.0, OverrideScoreboard )
end
