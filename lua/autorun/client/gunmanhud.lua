--[[
	IT'S HIGH NOON IN SPACE...
		    Again...

G U N M A N  C H R O N I C L E S
	   Heads Up Display
	    Version 2.1.3
		    11/03/19
]]--

--Font
surface.CreateFont( "Loading", {
font = "Arial Black",
size = 45,
weight = 500,
blursize = 0,
scanlines = 0,
antialias = true,
underline = false,
italic = false,
strikeout = false,
symbol = false,
rotary = false,
shadow = false,
additive = false,
outline = false})

-- ConVars
local enabled = CreateClientConVar( "gunchrn_enabled", 1, true, false )
local show_mag = CreateClientConVar( "gunchrn_showmag", 0, true, false )
local fakeloadscreen = CreateClientConVar( "gunchrn_loadscreen", 1, true, false)
local smallhud = CreateClientConVar( "gunchrn_smallhud", 0, true, false)

-- Textures
local body = "gunmanhud2/640_metalhud.png"
local body_small = "gunmanhud2/640_metalhud_small.png"
local hudpulse0 = "gunmanhud2/hudpulse0"
local hudpulse1 = "gunmanhud2/hudpulse1"
local hudpulse2 = "gunmanhud2/hudpulse2"
local hudpulse3 = "gunmanhud2/hudpulse3"
local hudpulse4 = "gunmanhud2/hudpulse4"
local armor = surface.GetTextureID("gunmanhud2/armor")
local numbers_blue = surface.GetTextureID("gunmanhud2/numbers_b")
local numbers_green = surface.GetTextureID("gunmanhud2/numbers_g")
local numbers_yellow = surface.GetTextureID("gunmanhud2/numbers_y")
local numbers_red = surface.GetTextureID("gunmanhud2/numbers_r")
local pistol = "gunmanhud2/ammo/pistol_ammo.png"
local magnum = "gunmanhud2/ammo/357_ammo.png"
local smg1 = "gunmanhud2/ammo/smg_ammo.png"
local shotgun = "gunmanhud2/ammo/shotgun_ammo.png"
local crossbow = "gunmanhud2/ammo/crossbow_ammo.png"
local ar2 = "gunmanhud2/ammo/ar2_ammo.png"
local misc = "gunmanhud2/ammo/misc_ammo.png"
local loadscreen = "gunmanhud2/loadscreen.png"

local num = {}
num["0"] = {x = 3, w = 16}
num["1"] = {x = 21, w = 16}
num["2"] = {x = 39, w = 16}
num["3"] = {x = 57, w = 16}
num["4"] = {x = 75, w = 16}
num["5"] = {x = 93, w = 16}
num["6"] = {x = 110, w = 16}
num["7"] = {x = 127, w = 16}
num["8"] = {x = 145, w = 16}
num["9"] = {x = 163, w = 16}

-- HUD Pulse functionality variables
local pos = 0
local pos2 = 0
local think = 0

-- Fake loading screen
local scn_pos = 0
local scn_think = 0
local scn_time = CurTime() + 2

local function HUD()
	local me = LocalPlayer()

	/* HEALTH AND ARMOR */

	local hp = 100
	if me:Health() >= 0 then
		hp = me:Health()
	else
		hp = 0
	end
	local ap = me:Armor()
	local hptab = string.ToTable(hp)
	local aptab = string.ToTable(ap)
	local hudpulse = ""

	if enabled:GetInt() == 1 then
		if smallhud:GetInt() == 0 then
			if hp >= 80 then
				hudpulse = hudpulse0
			elseif hp >= 50 and hp < 80 then
				hudpulse = hudpulse1
			elseif hp > 25 and hp < 50 then
				hudpulse = hudpulse2
			elseif hp > 0 and hp <= 25 then
				hudpulse = hudpulse3
			else
				hudpulse = hudpulse4
			end

			-- HUD Pulse
			if think < CurTime() then
				if pos >= 80 then
					pos = 0
				else
					pos = pos + 1
				end

				think = CurTime() + 0.0125
			end

			--128 x 32

			local size = 0
			local size2 = 0
			if (82 - (82*(pos/80))) > 42 then
				size = math.ceil(82 - (82*(pos/80))) - 1
				size2 = (82*(pos/80))
			else
				size = math.ceil((82 - (82*(pos/80))))
				size2 = (82*(pos/80)) - 1
			end

			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetTexture(surface.GetTextureID(hudpulse))
			surface.DrawTexturedRectUV(35 + pos,ScrH() - 75,size,32,0,0,((80 - pos)/128),1)
			surface.DrawTexturedRectUV(35 + pos - (80*(pos/80)),ScrH() - 75,size2,32,((80-pos)/128),0,(80/128),1)
			-- Armor bar
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetTexture(armor)
			surface.DrawTexturedRectUV(28,ScrH() - 110,95*math.Clamp(ap/100, 0, 1),25,0,0,math.Clamp(ap/100, 0, 1)*(95/128),1)

			-- Numbers
			if hp >= 10 and hp < 100 then
				for k,v in pairs(hptab) do
					surface.SetDrawColor(Color(255,255,255,255))
					if hp <= 25 then
						surface.SetTexture(numbers_red)
					else
						surface.SetTexture(numbers_blue)
					end
					surface.DrawTexturedRectUV(165 + ((num[v].w + 3)*(k-1)),ScrH() - 94,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			elseif hp >= 100 then
				for k,v in pairs(hptab) do
					surface.SetDrawColor(Color(255,255,255,255))
					surface.SetTexture(numbers_blue)
					surface.DrawTexturedRectUV(163 + ((num[v].w*(k-1))/1.17),ScrH() - 94,num[v].w/1.17,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			else
				for k,v in pairs(hptab) do
					surface.SetDrawColor(Color(255,255,255,255))
					surface.SetTexture(numbers_red)
					surface.DrawTexturedRectUV(185 + ((num[v].w + 3)*(k-1)),ScrH() - 94,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			end

			if ap >= 10 and ap < 100 then
				for k,v in pairs(aptab) do
					surface.SetDrawColor(Color(255,255,0,255))
					surface.SetTexture(numbers_green)
					surface.DrawTexturedRectUV(165 + ((num[v].w + 3)*(k-1)),ScrH() - 60,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			elseif ap >= 100 then
				for k,v in pairs(aptab) do
					surface.SetDrawColor(Color(255,255,0,255))
					surface.SetTexture(numbers_green)
					surface.DrawTexturedRectUV(163 + ((num[v].w*(k-1))/1.17),ScrH() - 60,num[v].w/1.17,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			else
				for k,v in pairs(aptab) do
					surface.SetDrawColor(Color(255,255,0,255))
					surface.SetTexture(numbers_green)
					surface.DrawTexturedRectUV(185 + ((num[v].w + 3)*(k-1)),ScrH() - 60,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			end

			-- HUD Body
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material(body))
			surface.DrawTexturedRect(0,ScrH() - 128,256,128)
		else
			-- Numbers
			if hp >= 10 and hp < 100 then
				for k,v in pairs(hptab) do
					surface.SetDrawColor(Color(255,255,255,255))
					if hp <= 25 then
						surface.SetTexture(numbers_red)
					else
						surface.SetTexture(numbers_blue)
					end
					surface.DrawTexturedRectUV(37 + ((num[v].w + 3)*(k-1)),ScrH() - 94,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			elseif hp >= 100 then
				for k,v in pairs(hptab) do
					surface.SetDrawColor(Color(255,255,255,255))
					surface.SetTexture(numbers_blue)
					surface.DrawTexturedRectUV(35 + ((num[v].w*(k-1))/1.17),ScrH() - 94,num[v].w/1.17,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			else
				for k,v in pairs(hptab) do
					surface.SetDrawColor(Color(255,255,255,255))
					surface.SetTexture(numbers_red)
					surface.DrawTexturedRectUV(57 + ((num[v].w + 3)*(k-1)),ScrH() - 94,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			end

			if ap >= 10 and ap < 100 then
				for k,v in pairs(aptab) do
					surface.SetDrawColor(Color(255,255,0,255))
					surface.SetTexture(numbers_green)
					surface.DrawTexturedRectUV(37 + ((num[v].w + 3)*(k-1)),ScrH() - 60,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			elseif ap >= 100 then
				for k,v in pairs(aptab) do
					surface.SetDrawColor(Color(255,255,0,255))
					surface.SetTexture(numbers_green)
					surface.DrawTexturedRectUV(35 + ((num[v].w*(k-1))/1.17),ScrH() - 60,num[v].w/1.17,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			else
				for k,v in pairs(aptab) do
					surface.SetDrawColor(Color(255,255,0,255))
					surface.SetTexture(numbers_green)
					surface.DrawTexturedRectUV(57 + ((num[v].w + 3)*(k-1)),ScrH() - 60,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
				end
			end

			-- Small HUD Body
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material(body_small))
			surface.DrawTexturedRect(0,ScrH() - 128,128,128)
		end


		/* AMMUNITION */
		local clip = 0
		local ammotype = 0
		local ammocount = 0
		local secondary = 0
		local showtype = "none"
		if IsValid(me:GetActiveWeapon()) then
			if hp > 0 then
				clip = me:GetActiveWeapon():Clip1()
				ammotype = me:GetActiveWeapon():GetPrimaryAmmoType()
				ammocount = me:GetAmmoCount(me:GetActiveWeapon():GetPrimaryAmmoType())
				secondary = me:GetAmmoCount(me:GetActiveWeapon():GetSecondaryAmmoType())
			else
				clip = 0
				ammotype = 0
				ammocount = 0
				secondary = 0
			end
			local ammotable = string.ToTable(clip+ammocount)
			local cliptable = string.ToTable(clip)
			local counttable = string.ToTable(ammocount)
			local sectable = string.ToTable(secondary)

			if ammotype == -1 then
				showtype = "none"
			elseif ammotype == 3 then
				showtype = pistol
			elseif ammotype == 1 then
				showtype = ar2
			elseif ammotype == 4 then
				showtype = smg1
			elseif ammotype == 7 then
				showtype = shotgun
			elseif ammotype == 6 then
				showtype = crossbow
			elseif ammotype == 5 then
				showtype = magnum
			elseif ammotype == 8 then
				showtype = "none"
			elseif ammotype == 10 then
				showtype = "none"
			else
				showtype = pistol;
			end

			if me:Alive() then
				if secondary > 0 then
					for k,v in pairs(sectable) do
						surface.SetDrawColor(Color(255,255,255,255))
						surface.SetTexture(numbers_yellow)
						surface.DrawTexturedRectUV(((ScrW() - 35) - 16*table.Count(ammotable)) + ((num[v].w + 3)*(k-1)),ScrH() - 78,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
					end
				end

        local offset = 0;
				if show_mag:GetInt() == 0 or clip <= -1 then
					if clip > -1 and ammotype != -1 then
						for k,v in pairs(ammotable) do
							surface.SetDrawColor(Color(255,255,255,255))
							surface.SetTexture(numbers_yellow)
							surface.DrawTexturedRectUV(((ScrW() - 35) - 16*table.Count(ammotable)) + ((num[v].w + 3)*(k-1)),ScrH() - 50,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
						end
					else
						if ammotype != -1 then
							for k,v in pairs(counttable) do
								surface.SetDrawColor(Color(255,255,255,255))
								surface.SetTexture(numbers_yellow)
								surface.DrawTexturedRectUV(((ScrW() - 35) - 16*table.Count(ammotable)) + ((num[v].w + 3)*(k-1)),ScrH() - 50,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
							end
						end
					end
				else
          offset = 75;

					if clip > -1 and ammotype != -1 then
						for k,v in pairs(counttable) do
							surface.SetDrawColor(Color(255,255,255,255))
							surface.SetTexture(numbers_blue)
							surface.DrawTexturedRectUV(((ScrW() - 35) - 16*table.Count(counttable)) + ((num[v].w + 3)*(k-1)),ScrH() - 50,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
						end

						for k,v in pairs(cliptable) do
							surface.SetDrawColor(Color(255,255,255,255))
							surface.SetTexture(numbers_yellow)
							surface.DrawTexturedRectUV(((ScrW() - 113) - 16*table.Count(cliptable)) + ((num[v].w + 3)*(k-1)),ScrH() - 50,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
						end

						draw.RoundedBox(2, ScrW() - 100, ScrH() - 53, 3,30,Color(0,255,255,100))
					else
						if ammotype != -1 then
							for k,v in pairs(counttable) do
								surface.SetDrawColor(Color(255,255,255,255))
								surface.SetTexture(numbers_yellow)
								surface.DrawTexturedRectUV(((ScrW() - 35) - 16*table.Count(ammotable)) + ((num[v].w + 3)*(k-1)),ScrH() - 50,num[v].w,24,1*(num[v].x/256),1*(4/32),1*((num[v].x + num[v].w)/256),1*(28/32))
							end
						end
					end
				end

        surface.SetDrawColor(255,255,255,255);
        surface.SetMaterial(Material(showtype));
        if showtype != "none" then
          if showtype == smg1 then
            surface.DrawTexturedRect(ScrW() - 150 - offset, ScrH() - 53, 50, 40);
          elseif showtype == crossbow then
            surface.DrawTexturedRect(ScrW() - 170 - offset, ScrH() - 53, 70, 40);
          elseif showtype == ar2 then
            surface.DrawTexturedRect(ScrW() - 130 - offset, ScrH() - 53, 35, 40);
          elseif showtype == misc then
            surface.DrawTexturedRect(ScrW() - 150 - offset, ScrH() - 53, 50, 40);
          else
            surface.DrawTexturedRect(ScrW() - 135 - offset, ScrH() - 53, 40, 40);
          end
        end

			end
		end


		/* FAKE LOADING SCREEN */
		if fakeloadscreen:GetInt() == 1 and scn_pos < ScrH() then
			if scn_time < CurTime() then
				if scn_think < CurTime() then
					if scn_pos < ScrH() then
						scn_pos = scn_pos + (ScrH()/50)
						scn_think = CurTime() + 0.01
					end
				end
			end
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material(loadscreen))
			surface.DrawTexturedRect(0,-scn_pos,ScrW(),ScrH())
			draw.SimpleText("Loading...", "Loading", ScrW() - 20, ScrH() - 60 - scn_pos, Color(255,255,255,255),2,0)
		end
	end
end
hook.Add("HUDPaint", "GunmanChroniclesHUD", HUD)

local tohide = {
["CHudHealth"] = true,
["CHudBattery"] = true,
["CHudAmmo"] = true,
["CHudSecondaryAmmo"] = true
}
local function HUDShouldDraw(name)
  if enabled:GetInt() == 1 then
  	if (tohide[name]) then
  		   return false;
  	end
  else
    return;
  end
end
hook.Add("HUDShouldDraw", "GunmanChroniclesHUDHide", HUDShouldDraw)

local function menu( Panel )
	Panel:ClearControls()

	Panel:AddControl( "Label" , { Text = "Gunman Chronicles HUD Settings"} )
	Panel:AddControl( "CheckBox", {
		Label = "Toggle HUD",
		Command = "gunchrn_enabled",
		}
	)
	Panel:AddControl( "CheckBox", {
		Label = "Show the magazine ammunition?",
		Command = "gunchrn_showmag",
		}
	)
	Panel:AddControl( "CheckBox", {
		Label = "Enable smaller version of the HUD",
		Command = "gunchrn_smallhud",
		}
	)
	Panel:AddControl( "CheckBox", {
		Label = "Show the custom loading screen?",
		Command = "gunchrn_loadscreen",
		}
	)
	Panel:AddControl( "Label",  { Text = "Version 2.1.3", Description = ""})
end

local function createMenu()
	spawnmenu.AddToolMenuOption( "Options", "DyaMetR", "GNCHUD2", "Gunman Chronicles HUD 2", "", "", menu )
end
hook.Add( "PopulateToolMenu", "gunmanhudmenu", createMenu )
