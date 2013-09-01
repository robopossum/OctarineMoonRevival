if SERVER then
	AddCSLuaFile( "shared.lua" )
end

	SWEP.HoldType			= "pistol"

if CLIENT then
	SWEP.PrintName			= "Spiderman's Gun"		
	SWEP.Slot				= 6
	SWEP.Icon = "EDIT ME" //Edit the image to anything you wish.
end

SWEP.CanBuy = {  }
SWEP.LimitedStock = true
SWEP.AllowDrop = true
SWEP.AutoSpawnable = false

SWEP.EquipMenuData = {
   type = "Spidermans Gun",
   desc = "Zip through the skys as Spiderman would!"
};

SWEP.AmmoEnt			= "item_ammo_pistol_ttt"
SWEP.Kind				= WEAPON_EQUIP1
SWEP.Base				= "weapon_tttbase"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

local sndPowerUp		= Sound("rope_hit.wav")
local sndPowerDown		= Sound ("shoot_rope.wav")
local sndTooFar			= Sound ("to_far.wav")

SWEP.IronSightsPos		= Vector( 6.05, -5, 2.4 )
SWEP.IronSightsAng		= Vector( 2.2, -0.1, 0 )

function SWEP:Initialize()

	nextshottime = CurTime()
	
end

function SWEP:Think()

	if (!self.Owner || self.Owner == NULL) then return end
	
	if ( self.Owner:KeyPressed( IN_ATTACK ) ) then
	
		self:StartAttack()
		
	elseif ( self.Owner:KeyDown( IN_ATTACK ) && inRange ) then
	
		self:UpdateAttack()
		
	elseif ( self.Owner:KeyReleased( IN_ATTACK ) && inRange ) then
	
		self:EndAttack( true )
	
	end
	
	if ( self.Owner:KeyPressed( IN_ATTACK2 ) ) then
	
		self:Attack2()
		
	end

end

function SWEP:DoTrace( endpos )
	local trace = {}
		trace.start = self.Owner:GetShootPos()
		trace.endpos = trace.start + (self.Owner:GetAimVector() * 14096)
		if(endpos) then trace.endpos = (endpos - self.Tr.HitNormal * 7) end
		trace.filter = { self.Owner, self.Weapon }
		
	self.Tr = nil
	self.Tr = util.TraceLine( trace )
end

function SWEP:StartAttack()
	local gunPos = self.Owner:GetShootPos()
	local disTrace = self.Owner:GetEyeTrace()
	local hitPos = disTrace.HitPos
	
	local x = (gunPos.x - hitPos.x)^2;
	local y = (gunPos.y - hitPos.y)^2;
	local z = (gunPos.z - hitPos.z)^2;
	local distance = math.sqrt(x + y + z);
	
	local distanceCvar = GetConVarNumber("rope_distance")
	inRange = false
	if distance <= distanceCvar then
		inRange = true						//100
	end
	
	if inRange then
		if (SERVER) then
			
			if (!self.Beam) then
				self.Beam = ents.Create( "rope" )
					self.Beam:SetPos( self.Owner:GetShootPos() )
				self.Beam:Spawn()
			end
			
			self.Beam:SetParent( self.Owner )
			self.Beam:SetOwner( self.Owner )
		
		end
		
		self:DoTrace()
		self.speed = 10000
		self.startTime = CurTime()
		self.endTime = CurTime() + self.speed
		self.dt = -1
		
		if (SERVER && self.Beam) then
			self.Beam:GetTable():SetEndPos( self.Tr.HitPos )
		end
		
		self:UpdateAttack()
		
		self.Weapon:EmitSound( sndPowerDown )
	else
		self.Weapon:EmitSound( sndTooFar )
	end
end

function SWEP:UpdateAttack()

	self.Owner:LagCompensation( true )
	
	if (!endpos) then endpos = self.Tr.HitPos end
	
	if (SERVER && self.Beam) then
		self.Beam:GetTable():SetEndPos( endpos )
	end

	lastpos = endpos
	
	
			if ( self.Tr.Entity:IsValid() ) then
			
					endpos = self.Tr.Entity:GetPos()
					if ( SERVER ) then
					self.Beam:GetTable():SetEndPos( endpos )
					end
			
			end
			
			local vVel = (endpos - self.Owner:GetPos())
			local Distance = endpos:Distance(self.Owner:GetPos())
			
			local et = (self.startTime + (Distance/self.speed))
			if(self.dt != 0) then
				self.dt = (et - CurTime()) / (et - self.startTime)
			end
			if(self.dt < 0) then
				self.Weapon:EmitSound( sndPowerUp )
				self.dt = 0
			end
			
			if(self.dt == 0) then
			zVel = self.Owner:GetVelocity().z
			vVel = vVel:GetNormalized()*(math.Clamp(Distance,0,7))
			end
				if( SERVER ) then
				local gravity = GetConVarNumber("sv_Gravity")
				vVel:Add(Vector(0,0,(gravity/100)*1.5))
				if(zVel < 0) then
					vVel:Sub(Vector(0,0,zVel/100))
			end							//prob
				self.Owner:SetVelocity(vVel)
			end
	
	endpos = nil
	
	self.Owner:LagCompensation( false )
	
end

function SWEP:EndAttack( shutdownsound )
	
	if ( shutdownsound ) then
		self.Weapon:EmitSound( sndPowerDown )
	end
	
	if ( CLIENT ) then return end
	if ( !self.Beam ) then return end
	
	self.Beam:Remove()
	self.Beam = nil
	
end

function SWEP:Attack2()
			

	if (CLIENT) then return end
		local CF = self.Owner:GetFOV()
		if CF == 90 then
			self.Owner:SetFOV(30,.3)
		elseif CF == 30 then
			self.Owner:SetFOV(90,.3)
	end
end

function SWEP:Holster()
	self:EndAttack( false )
	return true
end

function SWEP:OnRemove()
	self:EndAttack( false )
	return true
end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end