
if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile("sound/Wooo.wav")
end

if CLIENT then
   SWEP.PrintName = "Melon Cannon"
   SWEP.Slot      = 8 
   SWEP.ViewModelFOV  = 57
   SWEP.ViewModelFlip = false
end


SWEP.Base = "weapon_tttbase"
SWEP.Author = "Robopossum"
SWEP.HoldType			= "ar2"

SWEP.Primary.Delay       = 0.08
SWEP.Primary.Recoil      = 1.9
SWEP.Primary.Automatic   = false
SWEP.Primary.Damage      = 0
SWEP.Primary.Cone        = 0.0
SWEP.Primary.Ammo        = "none"
SWEP.Primary.ClipSize    = -1
SWEP.Primary.ClipMax     = -1
SWEP.Primary.DefaultClip = -1
local ShootSound = Sound( "Wooo.wav" )

SWEP.ViewModel  = "models/weapons/v_RPG.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.Kind = ROLE

SWEP.AutoSpawnable = false

SWEP.CanBuy = {  }

SWEP.InLoadoutFor = nil

SWEP.LimitedStock = false

SWEP.AllowDrop = true

SWEP.IsSilent = false

SWEP.NoSights = true

function SWEP:throw_attack (model_file)

	self:EmitSound( ShootSound )

	if ( CLIENT ) then return end

	local ent = ents.Create( "prop_physics" )

	if (  !IsValid( ent ) ) then return end

	ent:SetModel( model_file )
 
	ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 ) )
	ent:SetAngles( self.Owner:EyeAngles() )
	ent:Spawn()
 
	local phys = ent:GetPhysicsObject()
	if (  !IsValid( phys ) ) then ent:Remove() return end

	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 30000 
	velocity = velocity + ( VectorRand() * 10 )
	phys:ApplyForceCenter( velocity )

end

function SWEP:PrimaryAttack()
	self:throw_attack ("models/props_junk/watermelon01.mdl");
end


