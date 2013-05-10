if( SERVER ) then
	AddCSLuaFile( "scoreboard_override_detective.lua" )
	
	local valid_tags = 
	{
		"sb_tag_none",
		"sb_tag_friend",
		"sb_tag_susp",
		"sb_tag_avoid",
		"sb_tag_kill",
		"sb_tag_miss"
	}
	
	local function recieveDetectiveRecommendation( ply, cmd, args )
		if IsValid( ply ) and ply:IsTerror() and ply:IsActiveDetective() and ply:Alive() then
			local plId = args[ 1 ]
			local tag = args[ 2 ]
			
			if table.HasValue( valid_tags, tag ) then
				local pl = ents.GetByIndex( plId )
				if IsValid( pl ) and pl:IsPlayer() and not pl:IsActiveDetective() then
					Msg( ply:Nick() .. " has tagged " .. pl:Nick() .. " as " .. tag .. ".\n" )
					pl:SetNWString( "DetectiveTag", tag )
				end
			end
		end
	end
	concommand.Add( "ttt_detective_tag", recieveDetectiveRecommendation )
	
	local function clearTags()
		for _, ply in ipairs( player.GetAll() ) do
			ply:SetNWString( "DetectiveTag", "sb_tag_none" )
		end
	end
	hook.Add( "TTTPrepareRound", "TTTPrepareRound_ClearTags", clearTags )
end
