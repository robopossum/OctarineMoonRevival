
if SERVER then
	AddCSLuaFile( "shared.lua" )
	resource.AddFile("materials/VGUI/ttt/icon_dart.vmt")
end

SWEP.HoldType           = "crossbow"

if CLIENT then
	SWEP.PrintName          = "Poison Dartgun"

	SWEP.Slot               = 7

	SWEP.Icon = "VGUI/ttt/icon_dart"

	SWEP.EquipMenuData = {
		type = "Weapon",
		desc = "Silent dartgun that\nslowly kills the target\nover time."
	};
end


SWEP.Base               = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_EQUIP
SWEP.WeaponID = AMMO_RIFLE
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

SWEP.IsSilent = true

SWEP.Primary.Delay          = 1.5
SWEP.Primary.Recoil         = 3
SWEP.Primary.Automatic = true
SWEP.Primary.Cone = 0.0
SWEP.Primary.ClipSize = 1
SWEP.Primary.ClipMax = 1 -- keep mirrored to ammo
SWEP.Primary.DefaultClip = 1

SWEP.StoredAmmo = 1

SWEP.AutoSpawnable      = true
SWEP.Primary.Ammo 		= "XBowBolt"
SWEP.ViewModel          = Model("models/weapons/v_crossbow.mdl")
SWEP.WorldModel         = Model("models/weapons/w_crossbow.mdl")

SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 50

SWEP.Primary.Sound = Sound( "weapons/usp/usp1.wav" )
SWEP.Primary.SoundLevel = 50

SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.IronSightsPos      = Vector( 5, -15, -2 )
SWEP.IronSightsAng      = Vector( 2.6, 1.37, 3.5 )

function SWEP:SetZoom(state)
	if CLIENT then 
		return
	else
		if state then
			self.Owner:SetFOV(20, 0.3)
		else
			self.Owner:SetFOV(0, 0.2)
		end
	end
end

function SWEP:PoisonPlayer( ply, duration )
	if( ply.Poisoned ) then
		return
	end
	
	if( ply:IsTraitor() and self.Owner:IsTraitor()) then
		return
	end
	
	--HIGHSCORE:AddScore( self.Owner, HIGHSCORE.PointsPerPoison )

	ply.Poisoned = true
	ply.DartShotOwner = self.Owner
	timer.Create( "PoisonEffect_" .. ply:Nick(), 0.6, 0, function() self:PoisonEffects( ply ) end )
	timer.Create( "PoisonEnd_" .. ply:Nick(), duration, 1, function() self:CurePlayer( ply ) end )
	ply:SetColor( Color( 128, 255, 160, 255 ) )
end

function SWEP:CurePlayer( ply )
	if( not ply or not IsValid( ply ) ) then
		return
	end
	
	ply.Poisoned = false
	ply.DartShotOwner = nil
	ply:SetColor( Color( 255, 255, 255, 255 ) )
	if( timer.Exists( "PoisonEffect_" .. ply:Nick())) then
		timer.Destroy( "PoisonEffect_" .. ply:Nick())
	end
	if( timer.Exists( "PoisonEnd_" .. ply:Nick())) then
		timer.Destroy( "PoisonEnd_" .. ply:Nick())
	end
end

function SWEP:PoisonEffects( ply )
	if( not( ply and IsValid( ply ))) then
		return
	elseif(( not ply:Alive()) or GetRoundState() ~= ROUND_ACTIVE or ( not ply.Poisoned )) then
		self:CurePlayer( ply )
		return
	else
		if ply:Health() > 1 then
			ply:SetHealth( ply:Health() - 1 )
		else
			local attacker = ply.DartShotOwner				
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( 1 )
			dmginfo:SetDamageType( DMG_POISON )
			dmginfo:SetAttacker( attacker )
			dmginfo:SetInflictor( self )
			
			ply:TakeDamageInfo( dmginfo )
			
			if( not ply:Alive()) then
				self:CurePlayer( ply )
			end
		end
	end
end

function SWEP:OnRemove()
	for k, ply in pairs(player.GetAll()) do
		self:CurePlayer( ply )
	end
end

function SWEP:Deploy()
	if self.Weapon:Clip1() == 0 then
		self:SendWeaponAnim( ACT_VM_DRAW_EMPTY ) -- this doesn't work :(
	else
		self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	end
	return true
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if not self:CanPrimaryAttack() then return end
	
	self.Weapon:SendWeaponAnim( self.PrimaryAnim )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if not worldsnd then
		self.Weapon:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
	elseif SERVER then
		WorldSound(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
	end

	local bullet = {}
	bullet.Num    = 1
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector( 0, 0, 0 )
	bullet.Tracer = 0
	bullet.Force  = 0
	bullet.Damage = 0
	if SERVER then
		bullet.Callback = function(att, trace, dmginfo)
			if trace.HitNonWorld then
				target = trace.Entity
				if( target:IsPlayer()) then
					self:PoisonPlayer( target, 120 )
				else
					if( target:GetClass() == "ttt_health_station" ) then
						target:Poison( self )
					end
					self:SpawnDart( trace )
				end
			else
				self:SpawnDart( trace )
			end
			return { damage = false, effects = false }
		end
	end
	
	self.Owner:FireBullets( bullet )
	
	self:TakePrimaryAmmo( 1 )

	local owner = self.Owner   
	if not IsValid( owner ) or owner:IsNPC() or (not owner.ViewPunch) then return end

	owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )

	self:Reload()
end

function SWEP:SpawnDart( trace )
	local dart = ents.Create( "ttt_dart" )
	local vec = self.Owner:GetAimVector()
	dart:SetPos( trace.HitPos - vec * 4 )
	local ang = vec:Angle()
	dart:SetAngles( Angle( ang.r, ang.y + 90, ang.p ) )
	dart.CanRetrieve = true
	if trace.HitNonWorld and IsValid( trace.Entity ) then
		dart:SetParent( trace.Entity )
	end
	dart:SetOwner( self.Owner )
	dart.fingerprints = { self.Owner }
    dart:SetNWBool("HasPrints", true)
	dart:Spawn()
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
    if not self.IronSightsPos then return end
    if self.Weapon:GetNextSecondaryFire() > CurTime() then return end
    
    bIronsights = not self:GetIronsights()
    
    self:SetIronsights( bIronsights )
    
    if SERVER then
		self:SetZoom(bIronsights)
    else
		self:EmitSound(self.Secondary.Sound)
    end
    
    self.Weapon:SetNextSecondaryFire( CurTime() + 0.3)
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5)
end

function SWEP:PreDrop()
    self:SetZoom(false)
    self:SetIronsights(false)
    return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
    self.Weapon:DefaultReload( ACT_VM_RELOAD );
    self:SetIronsights( false )
    self:SetZoom(false)
end


function SWEP:Holster()
    self:SetIronsights(false)
    self:SetZoom(false)
    return true
end

if CLIENT then
	local scope = surface.GetTextureID("sprites/scope")
	function SWEP:DrawHUD()
		if self:GetIronsights() then
			surface.SetDrawColor( 0, 0, 0, 255 )

			local x = ScrW() / 2.0
			local y = ScrH() / 2.0
			local scope_size = ScrH()

			-- crosshair
			local gap = 80
			local length = scope_size
			surface.DrawLine( x - length, y, x - gap, y )
			surface.DrawLine( x + length, y, x + gap, y )
			surface.DrawLine( x, y - length, x, y - gap )
			surface.DrawLine( x, y + length, x, y + gap )

			gap = 0
			length = 50
			surface.DrawLine( x - length, y, x - gap, y )
			surface.DrawLine( x + length, y, x + gap, y )
			surface.DrawLine( x, y - length, x, y - gap )
			surface.DrawLine( x, y + length, x, y + gap )


			-- cover edges
			local sh = scope_size / 2
			local w = (x - sh) + 2
			surface.DrawRect(0, 0, w, scope_size)
			surface.DrawRect(x + sh - 2, 0, w, scope_size)

			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawLine(x, y, x + 1, y + 1)

			-- scope
			surface.SetTexture(scope)
			surface.SetDrawColor(255, 255, 255, 255)

			surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
		else
			return self.BaseClass.DrawHUD(self)
		end
	end

	function SWEP:AdjustMouseSensitivity()
		return (self:GetIronsights() and 0.2) or nil
	end
end

if( SERVER )then
	local oldCorpseCreate = CORPSE.Create
	function CORPSE.Create(ply, attacker, dmginfo)
		//if not GetConVar("ttt_server_ragdolls"):GetBool() then
		//	return oldCorpseCreate( ply, attacker, dmginfo )
		//else
			local rag = oldCorpseCreate( ply, attacker, dmginfo )
			
			if( rag and dmginfo:GetDamageType() == DMG_POISON ) then
				local sample = {}
				sample.killer = attacker
				sample.killer_uid = attacker:UniqueID()
				sample.victim = ply
				sample.t      = CurTime() + 5

				rag.killer_sample = sample
			end

			return rag
		//end
	end
end
