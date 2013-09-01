resource.AddFile("materials/VGUI/ttt/icon_tl_turtle.vmt")

if SERVER then
   AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_tttbasegrenade"

SWEP.Kind = WEAPON_EQUIP2
SWEP.WeaponID = AMMO_MOLOTOV

SWEP.HoldType			= "grenade"

SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = true

SWEP.ViewModel			= "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel			= "models/props/de_tides/vending_turtle.mdl"
SWEP.Weight				= 5
SWEP.AutoSpawnable      = false
-- really the only difference between grenade weapons: the model and the thrown
-- ent.

if CLIENT then
   -- Path to the icon material
   	SWEP.PrintName	 = "Turtle Grenade"
	SWEP.Slot		 = 7

	//if file.Exists("materials/VGUI/ttt/icon_tl_turtle.vmt", "GAME") then
		SWEP.Icon = "VGUI/ttt/icon_tl_turtle"
	//else
	//	SWEP.Icon = "VGUI/ttt/icon_nades"
	//end
   -- Text shown in the equip menu
	SWEP.EquipMenuData = {
   
   
		type = "Weapon",
		desc = "Turtle Grenade.\n Releases several hostile turtles on detonation."
   };
    function SWEP:DrawWorldModel()
		--self:DrawModel()
		local ply = self.Owner
		local pos = self.Weapon:GetPos()
		local ang = self.Weapon:GetAngles()
		if ply:IsValid() then
			local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
			if bone then
				pos,ang = ply:GetBonePosition(bone)
			end
		else
			self.Weapon:DrawModel() --Draw the actual model when not held.
			return
		end
		if self.ModelEntity:IsValid() == false then
			self.ModelEntity = ClientsideModel(self.WorldModel)
			self.ModelEntity:SetNoDraw(true)
		end
		
		self.ModelEntity:SetModelScale(1,0)
		self.ModelEntity:SetPos(pos)
		self.ModelEntity:SetAngles(ang+Angle(0,0,180))
		self.ModelEntity:DrawModel()
	end
	function SWEP:ViewModelDrawn()
		local ply = self.Owner
		if ply:IsValid() and ply == LocalPlayer() then
			local vmodel = ply:GetViewModel()
			local idParent = vmodel:LookupBone("v_weapon.Flashbang_Parent")
			local idBase = vmodel:LookupBone("v_weapon")
			if not vmodel:IsValid() or not idParent or not idBase then return end --Ensure the model and bones are valid.
			local pos, ang = vmodel:GetBonePosition(idParent)	
			local pos1, ang1 = vmodel:GetBonePosition(idBase) --Rotations were screwy with the parent's angle; use the models baseinstead.

			if self.ModelEntity:IsValid() == false then
				self.ModelEntity = ClientsideModel(self.WorldModel)
				self.ModelEntity:SetNoDraw(true)
			end
			
			self.ModelEntity:SetModelScale(0.5,0)
			self.ModelEntity:SetPos(pos-ang1:Forward()*1.25-ang1:Up()*1.25+2.3*ang1:Right())
			self.ModelEntity:SetAngles(ang1)
			self.ModelEntity:DrawModel()
		end
	end
end

function SWEP:GetGrenadeName()
   return "ttt_turtlenade_proj"
end

--Taken from base grenade
function SWEP:Initialize()
   if self.SetWeaponHoldType then
      self:SetWeaponHoldType(self.HoldNormal)
   end

   self:SetDeploySpeed(self.DeploySpeed)

   self:SetDetTime(0)
   self:SetThrowTime(0)
   self:SetPin(false)

   self.was_thrown = false
   if CLIENT then
	self.ModelEntity = ClientsideModel(self.WorldModel)
	self.ModelEntity:SetNoDraw(true)
   end
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("use", "weapon_ttt_unarmed")
   end
   
   if CLIENT then
   self.ModelEntity:Remove()
   end
end