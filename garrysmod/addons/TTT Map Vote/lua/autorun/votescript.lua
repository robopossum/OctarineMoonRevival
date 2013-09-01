--Amount of players who have to request a vote, 1=all, 0.5=half of everyone
local votereqperc= 0.5
--Voting time
local votetime   = 20

--Checks if gamemode is terrortown
if GetConVarString("gamemode") == "terrortown" then
--Server side
if SERVER then

	local votestarted = false
	local voteoverride = false
	local votestartrequests={} 
	
	local currentvotes={}
	local playerlist={}

	util.AddNetworkString("serverWantsAVote")
	util.AddNetworkString("userChangedVote")
	util.AddNetworkString("broadcastUserVoteChange")
	util.AddNetworkString("thePoolIsClosedAndSoIsVoting")
	util.AddNetworkString("playerWantsToStartVote")
	
	print("TTT Map Vote has loaded onto the server")
	
	local maps ={}

	local maps = string.Explode("\n",file.Read("mapcycle.txt","GAME"))
	for i=1,table.Count(maps) do
			maps[i] = string.Trim(maps[i])
	end
	table.remove(maps)
	
	if not table.HasValue(maps,game.GetMap()) then
		table.insert(maps, 1, game.GetMap())
	end
	
	local curmap=table.remove(maps,table.KeyFromValue(maps, game.GetMap()))
	table.insert(maps, curmap)
	
	net.Receive("userChangedVote",function(len, ply)
		local mapID=net.ReadInt(16)
		playerlist[ply:UniqueID()]=mapID
		net.Start("broadcastUserVoteChange")	
		net.WriteInt(mapID,16)
		net.WriteString(ply:UniqueID())	
		net.Broadcast()
	end)	
	
	
	function votingEnded()
		for k,v in pairs(playerlist) do
			currentvotes[v]=currentvotes[v]+1
		end
		
		local currmap=1
		local maxvotes=0
		
		for i=1,table.Count(maps) do
			if currentvotes[i]>maxvotes then
				maxvotes=currentvotes[i]
				currmap=i
			end
		end
	
		print("Winning map is "..maps[currmap])
		
		for _, v in pairs(player.GetAll()) do
			v:ChatPrint( "Winning map is "..maps[currmap].."! Switching to it in a few seconds." )
		end
		
		timer.Simple(5,function() RunConsoleCommand("changelevel", maps[currmap]) end)
		
		net.Start("thePoolIsClosedAndSoIsVoting")
		net.Broadcast()
	
		votestarted=false

	end
	
	
	local voteover=false
	
	function startVoteMaybe()
		if GetGlobalInt("ttt_rounds_left") == 1 or voteoverride then 
			if voteover == false then
				voteoverride = false
				print("Sending vote request")
				votestarted=true
				net.Start("serverWantsAVote")
				for i=1,table.Count(maps) do
					currentvotes[i]=0
				end
				net.WriteTable(maps)
				net.Broadcast()	
				timer.Simple(votetime, function() votingEnded() end )
				voteover=true
				return true
			end
		end
		return false
	end
	hook.Add( "TTTEndRound", "roundStartThingy",startVoteMaybe)

	function voterequested(ply)
			if voteoverride == false then
		
				if votestartrequests[ply:UniqueID()] == 1 then
					return ""
				end
				
				votestartrequests[ply:UniqueID()] = 1
				local playercount=table.Count(player:GetAll())
				playercount=math.floor(playercount*votereqperc)
				
				if playercount < 1 then
					playercount = 1
				end
				
				local votes=0
				
				for k,v in pairs(player:GetAll()) do
					if votestartrequests[v:UniqueID()] == 1 then
						votes=votes+1
					end
				end
				
				if votes >= playercount then
					voteoverride=true
				end
				
				net.Start("playerWantsToStartVote")
				net.WriteString(ply:GetName())
				net.WriteInt(playercount,16)
				net.WriteInt(votes,16)
				net.Broadcast()
				
				return ""
			end
		return strText
        end

        function overrideVote(ply)
              voteoverride = true
        end 
	end
end

--Client Side
if CLIENT then
	util.PrecacheSound("UI/buttonclick.wav")
	
	local cl_mapvote = nil
	local votebuttons = {}
	local avatars = {}
	
	local playerlists = {}
	
	local currentvotes= {}
	local oldvotes	  = {}
	
	local playerVelX={}
	local playerVelY={}
	local playerPosX={}
	local playerPosY={}
			
	
	local listopened=false
	
	local btnW=400
	local btnH=20
	local spacing=3
	
	--Update loop
	function thinking()
		if cl_mapvote != nil and listopened then
			gui.EnableScreenClicker(true)
			cl_mapvote:MoveToFront()
			for k,v in pairs(player.GetAll()) do
				local id = v:UniqueID()
				if avatars[id] != nil and currentvotes[id]!=0 then
					local position = 1
					for k,v in pairs(playerlists[currentvotes[id]]) do
						if v == id then
							position = k
						end
					end
					
					local x = playerPosX[id]
					local y = playerPosY[id]
					
					local vx = playerVelX[id]
					local vy = playerVelY[id]
					
					local x2,y2 = votebuttons[currentvotes[id]]:GetPos()
					
					x2 = x2+btnW-(btnH*(position))
					
					local speed = 0.01
					
					local dx = (x2-x)
					local dy = (y2-y)
						
					local dist = math.sqrt(dx*dx + dy*dy)
					
					
					if dist > 0 then
						dx=dx/dist
						dy=dy/dist
					end
					
					vx= (vx+dx)*0.98
					vy= (vy+dy)*0.98
					
					
					if dist < 0.8 then
						vx= vx*0.1
						vy= vy*0.1
						local vdist= math.sqrt(vx*vx + vy*vy)
						if vdist < 1 then
						
							vx = 0
							vy = 0
							
							x=x2
							y=y2
						end
					
					end
					
					
						
					--[[if math.abs(dx) <= 1.0 then 
						x=x2
					end
					if math.abs(dy) <= 1.0 then
						y=y2
					end
					]]--
					
					x = x + vx
					y = y + vy
					
					
					playerPosX[id] = x
					playerPosY[id] = y
					playerVelX[id] = vx
					playerVelY[id] = vy
				
					avatars[id]:SetPos(x,y)
				end
			end
		end
	end
	
	hook.Add("Think", "updateloop", thinking)
		
	--Will display how many votes there are for starting a vote and stuff.
	net.Receive("playerWantsToStartVote",  function()
		local votename=net.ReadString()
		local playercount=net.ReadInt(16)
		local votecount=net.ReadInt(16)
		if votecount < playercount then 
			chat.AddText(
				"",
				Color(100,244,0,255),
				votename,
				" wants to start a map vote! Type say !rtv if you too want to vote.\n",
				Color(100,200,0,255),
				"Votes: "..votecount.."/"..playercount
			)
		else
			chat.AddText(
				Color(0,255,0,255),
				votename.." voted, and filled the voting quota!\nMap vote will begin at the end of this round, yep."
			)
		end
		surface.PlaySound("UI/buttonclick.wav")
		chat.PlaySound()
	end)
	
	--When a user has changed what map they want
	net.Receive("broadcastUserVoteChange", function()
		if listopened then
			local map=net.ReadInt(16)
			local user=net.ReadString()	
			
			if currentvotes[user] != map then
				
				if currentvotes[user] != nil and currentvotes[user] != 0 then
					local position = 1
					for k,v in pairs(playerlists[currentvotes[user]]) do
						if v == id then
							position = k
						end
					end
					table.remove(playerlists[currentvotes[user]],position)
				end
				
				table.insert(playerlists[map], user)
				
				--oldvotes[user]=currentvotes[user]
				
				currentvotes[user]=map
			end
		end
	end)
	
	--Closes the voting window
	function closeVotingWindow()
		if cl_mapvote != nil and listopened then
			listopened=false
			cl_mapvote:AlphaTo(0,0.5,0)
			timer.Simple(0.5,function()
				cl_mapvote:Remove()
				cl_mapvote=nil
				gui.EnableScreenClicker(false)
			end)
		end
	end
	
	
	net.Receive("thePoolIsClosedAndSoIsVoting", function()
		closeVotingWindow()
	end)

	
	
	net.Receive("serverWantsAVote",function()
		if listopened then
			return false
		end
		
		listopened=true
		
		avatars={}
		playerlists={}
	
		
		cl_mapvote = vgui.Create("DPanel")
		cl_mapvote:SetWide(cl_mapvote:GetParent():GetWide())
		cl_mapvote:SetTall(cl_mapvote:GetParent():GetTall())
		cl_mapvote:Center()
		cl_mapvote:SetAlpha(0)
		gui.EnableScreenClicker(true)
		cl_mapvote:AlphaTo(255,1,0)
		
		cl_mapvote.Paint = function()
			surface.SetDrawColor(100,100,100,200)
			if cl_mapvote != nil then
				surface.DrawRect(0,0,cl_mapvote:GetWide(), cl_mapvote:GetTall())
			end
		end
		
		cl_mapvote.label = vgui.Create("DLabel",cl_mapvote)
		cl_mapvote.label:SetPos(20,20)
		cl_mapvote.label:SetText("Vote for the next map")
		cl_mapvote.label:SizeToContents()
		cl_mapvote.label:SetColor(Color(255,0,0,255))		
		
	--	List for people who haven't voted
		
		local unvotedPlayers=vgui.Create("DPanelList", cl_mapvote)
		unvotedPlayers:SetSize(btnH,cl_mapvote:GetTall()-20)
		unvotedPlayers:SetPos(10,10)	
		for k,v in pairs(player.GetAll()) do
		
			local x = math.random()*300
			local y = math.random()*600
			
			local playerIcon=vgui.Create("AvatarImage",cl_mapvote)
			playerIcon:SetSize(btnH,btnH)
			playerIcon:SetPlayer(v,32)
			avatars[v:UniqueID()]=playerIcon
			
			local id=v:UniqueID()
			
			playerVelX[id]=0
			playerVelY[id]=0
			playerPosX[id]=x
			playerPosY[id]=y
			
			playerIcon:SetPos(x,y)
			currentvotes[v:UniqueID()]=0
			
			
		--	unvotedPlayers:AddItem(playerIcon)
		end	
		
		local maps=net.ReadTable()
		
		for i = 1,table.Count(maps) do
			local btnoverlay = vgui.Create("DButton", cl_mapvote)
			btnoverlay.Paint= function()
			
			end	
			local btn = vgui.Create("DPanel",cl_mapvote)
			btn.Paint = function()
				local x,y= btn:GetPos()
				--surface.SetDrawColor
				draw.RoundedBox(4,0,0,btn:GetWide(),btn:GetTall(),Color(88,106,255,255))
			
			end
			btnoverlay:Center();
			btnoverlay:AlignTop(math.floor((i-1)*0.5)*(btnH+spacing)+btnH)
			
			btnoverlay:AlignLeft(cl_mapvote:GetWide()*0.5+ ((i+1)%2-1)*(btnW+spacing))	
			
			btn:AlignTop(math.floor((i-1)*0.5)*(btnH+spacing)+btnH)
            btn:AlignLeft(cl_mapvote:GetWide()*0.5+ ((i+1)%2-1)*(btnW+spacing))
			btnoverlay:SetText("")
			
			btn.mapName=maps[i]
			btn.label=vgui.Create("DLabel", btn);
			
			btn.label:SetText(maps[i])
			btn.label:SizeToContents()
			btn.label:SetColor(Color(255,242,237,255))
			btn.label:Center();
			
			
			btn.label:AlignLeft(10)
			btnoverlay:SetSize(btnW,btnH)
			btn:SetSize(btnW,btnH)
			btn:MoveToBack()
			btnoverlay:MoveToFront()

			votebuttons[i]=btn

			btnoverlay.DoClick = function()
				surface.PlaySound("UI/buttonclick.wav")
				net.Start("userChangedVote")
				net.WriteInt(i,16)
				net.SendToServer()
			end
			playerlists[i]={}
			
		end
		
		local closebtn= vgui.Create("DButton", cl_mapvote)
		closebtn:SetWide((btnW+spacing)*2)
		closebtn:Center()
		closebtn:AlignBottom(20)
		closebtn:SetText("Done voting? Then click here ya scroob")
		closebtn.DoClick = function()
			closeVotingWindow()
		end	
	end )
end