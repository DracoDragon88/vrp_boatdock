vRP = Proxy.getInterface("vRP")

local boatshop = {
	opened = false,
	title = "Boat dealer",
	currentmenu = "main",
	lastmenu = nil,
	currentpos = nil,
	selectedbutton = 0,
	marker = { r = 0, g = 155, b = 255, a = 200, type = 1 },
	menu = {
		x = 0.9,
		y = 0.08,
		width = 0.2,
		height = 0.04,
		buttons = 10,
		from = 1,
		to = 10,
		scale = 0.4,
		font = 0,
		["main"] = {
			title = "CATEGORIES",
			name = "main",
			buttons = {
				{name = "Pneumatic", description = ""},
				{name = "Sails", description = ""},
				{name = "Jetski", description = ""},
				{name = "Submersible", description = ""},
				{name = "Trawler", description = ""},
				{name = "Vedette", description = ""}
			}
		},
		["Pneumatic"] = {
			title = "Pneumatic",
			name = "Pneumatic",
			buttons = {
				{name = "Dinghy 2Seat", costs = 20000, description = {}, model = "dinghy2"},
				{name = "Dinghy 4Seat", costs = 25000, description = {}, model = "dinghy"},
				{name = "Dinghy", costs = 20000, description = {}, model = "dinghy3"},
				{name = "Dinghy Yacht", costs = 200000, description = {}, model = "dinghy4"}
			}
		},
		["Sails"] = {
			title = "Sails",
			name = "Sails",
			buttons = {
				{name = "Marquis", costs = 200000, description = {}, model = "marquis"}
			}
		},
		["Jetski"] = {
			title = "Jetski",
			name = "Jetski",
			buttons = {
				{name = "Seashark", costs = 5000, description = {}, model = "seashark"},
				-- {name = "Seashark Lifeguard", costs = 5000, description = {}, model = "seashark2"},
				{name = "Seashark Yacht", costs = 5000, description = {}, model = "seashark3"}
			}
		},
		["Submersible"] = {
			title = "Submersible",
			name = "Submersible",
			buttons = {
				{name = "Kraken", costs = 500000, description = {}, model = "submersible2"},
				{name = "Submersible", costs = 665000, description = {}, model = "submersible"}
			}
		},
		["Trawler"] = {
			title = "Trawler",
			name = "Trawler",
			buttons = {
				{name = "Tug", costs = 160000, description = {}, model = "tug"}
			}
		},
		["Vedette"] = {
			title = "Vedette",
			name = "Vedette",
			buttons = {
				{name = "Speeder", costs = 8000, description = {}, model = "speeder"},
				{name = "Speeder2", costs = 8000, description = {}, model = "speeder2"},
				{name = "Toro", costs = 20000, description = {}, model = "toro"},
				{name = "Toro Yacht", costs = 210000, description = {}, model = "toro2"},
				-- {name = "Police", costs = 21000, description = {}, model = "predator"},
				{name = "Tropic", costs = 22000, description = {}, model = "tropic"},
				{name = "Tropic Yacht", costs = 220000, description = {}, model = "tropic2"},
				{name = "Jetmax", costs = 75000, description = {}, model = "jetmax"},
				{name = "Suntrap", costs = 249000, description = {}, model = "suntrap"},
				{name = "Squalo", costs = 715000, description = {}, model = "squalo"}
			}
		}
	}
}

local fakeboat = {model = '', car = nil}
local boatshop_locations = {
	{entering = {-863.096,-1324.389,1.605}, inside = {-871.091,-1351.19,-1.000,190.000}, outside = {-871.091,-1351.19,0.000,190.000}}
}
local boatshop_blips ={}
local inrangeofboatshop = false
local currentlocation = nil
local boughtboat = false
local boat_price = 0
local backlock = false
local firstspawn = 0

--[[Functions]]--
function deleteVehiclePedIsIn()
  local v = GetVehiclePedIsIn(GetPlayerPed(-1),false)
  SetVehicleHasBeenOwnedByPlayer(v,false)
  Citizen.InvokeNative(0xAD738C3085FE7E11, v, false, true) -- set not as mission entity
  SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(v))
  Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(v))
end

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end

function IsPlayerInRangeOfboatshop()
	return inrangeofboatshop
end

function f(n)
	return n + 0.0001
end

function try(f, catch_f)
	local status, exception = pcall(f)
	if not status then
	catch_f(exception)
	end
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function OpenCreator()
	boughtboat = false
	local ped = GetPlayerPed(-1)
	local pos = currentlocation.pos.inside
	FreezeEntityPosition(ped,true)
	SetEntityVisible(ped,false)
	-- local g = Citizen.InvokeNative(0xC906A7DAB05C8D2B,pos[1],pos[2],pos[3],Citizen.PointerValueFloat(),0)
	SetEntityCoords(ped,pos[1],pos[2],pos[3]+2)
	SetEntityHeading(ped,pos[4])
	boatshop.currentmenu = "main"
	boatshop.opened = true
	boatshop.selectedbutton = 0

	TriggerEvent('draco:seatBeltAlarmToggle',false)
end

function CloseCreator(name, boat, vehicle_plate)
	Citizen.CreateThread(function()
		local ped = GetPlayerPed(-1)
		local pos = currentlocation.pos.entering
		if not boughtboat then
			vRP.teleport({pos[1],pos[2],pos[3]})
			FreezeEntityPosition(ped,false)
			SetEntityVisible(ped,true)
		else
			deleteVehiclePedIsIn()
			vRP.teleport({pos[1],pos[2],pos[3]})

			SetEntityVisible(ped,true)
			FreezeEntityPosition(ped,false)
		end
		boatshop.opened = false
		boatshop.menu.from = 1
		boatshop.menu.to = 10
		TriggerEvent('draco:seatBeltAlarmToggle',true)
	end)
end

function drawMenuButton(button,x,y,selected)
	local menu = boatshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(menu.scale, menu.scale)
	if selected then
		SetTextColour(0, 0, 0, 255)
	else
		SetTextColour(255, 255, 255, 255)
	end
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(button.name)
	if selected then
		DrawRect(x,y,menu.width,menu.height,255,255,255,255)
	else
		DrawRect(x,y,menu.width,menu.height,0,0,0,150)
	end
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)
end

function drawMenuInfo(text)
	local menu = boatshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(0.45, 0.45)
	SetTextColour(255, 255, 255, 255)
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawRect(0.675, 0.95,0.65,0.050,0,0,0,150)
	DrawText(0.365, 0.934)
end

function drawMenuRight(txt,x,y,selected)
	local menu = boatshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(menu.scale, menu.scale)
	SetTextRightJustify(1)
	if selected then
		SetTextColour(0, 0, 0, 255)
	else
		SetTextColour(255, 255, 255, 255)
	end
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawText(x + menu.width/2 - 0.03, y - menu.height/2 + 0.0028)
end

function drawMenuTitle(txt,x,y)
	local menu = boatshop.menu
	SetTextFont(2)
	SetTextProportional(0)
	SetTextScale(0.5, 0.5)
	SetTextColour(255, 255, 255, 255)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawRect(x,y,menu.width,menu.height,0,0,0,150)
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)
end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function Notify(text)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function round(num, idp)
	if idp and idp>0 then
		local mult = 10^idp
		return math.floor(num * mult + 0.5) / mult
	end
	return math.floor(num + 0.5)
end

function ButtonSelected(button)
	local this = boatshop.currentmenu
	local btn = button.name
	if this == "main" then
		if btn == "Pneumatic" then
			OpenMenu('Pneumatic')
		elseif btn == "Sails" then
			OpenMenu('Sails')
		elseif btn == "Jetski" then
			OpenMenu('Jetski')
		elseif btn == "Submersible" then
			OpenMenu('Submersible')
		elseif btn == "Trawler" then
			OpenMenu('Trawler')
		elseif btn == "Vedette" then
			OpenMenu('Vedette')
		end
	elseif this == "Pneumatic" or this == "Sails" or this == "Jetski" or this == "Submersible" or this == "Trawler" or this == "Vedette" then
		TriggerServerEvent('vRP_BD:CheckMoneyForBoat',this,button.model,button.name,button.costs,"boat")
	end
end

function OpenMenu(menu)
	fakeboat = {model = '', car = nil}
	boatshop.lastmenu = boatshop.currentmenu
	if menu == "Pneumatic" then
		boatshop.lastmenu = "main"
	elseif menu == "Sails"  then
		boatshop.lastmenu = "main"
	elseif menu == "Jetski"  then
		boatshop.lastmenu = "main"
	elseif menu == "Submersible"  then
		boatshop.lastmenu = "main"
	elseif menu == "Trawler" then
		boatshop.lastmenu = "main"
	elseif menu == "Vedette" then
		boatshop.lastmenu = "main"
	end
	boatshop.menu.from = 1
	boatshop.menu.to = 10
	boatshop.selectedbutton = 0
	boatshop.currentmenu = menu
end

function Back()
	if backlock then
		return
	end
	backlock = true
	if boatshop.currentmenu == "main" then
		CloseCreator()
	elseif boatshop.currentmenu == "Pneumatic" or boatshop.currentmenu == "Sails" or boatshop.currentmenu == "Jetski" or boatshop.currentmenu == "Submersible" or boatshop.currentmenu == "Trawler" or boatshop.currentmenu == "Vedette" then
		if DoesEntityExist(fakeboat.car) then
			Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(fakeboat.car))
		end
		fakeboat = {model = '', car = nil}
		OpenMenu(boatshop.lastmenu)
	else
		OpenMenu(boatshop.lastmenu)
	end

end

function stringstarts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

--[[Citizen]]--
Citizen.CreateThread(function()
	for station,pos in pairs(boatshop_locations) do
		local loc = pos
		pos = pos.entering
		local blip = AddBlipForCoord(pos[1],pos[2],pos[3])
		-- 60 58 137
		SetBlipSprite(blip,410)
		SetBlipColour(blip, 3)
		SetBlipScale(blip, 1.0)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Boat dealer')
		EndTextCommandSetBlipName(blip)
		SetBlipAsShortRange(blip,true)
		SetBlipAsMissionCreatorBlip(blip,true)
		table.insert(boatshop_blips, {blip = blip, pos = loc})
	end
	while #boatshop_blips > 0 do
		Citizen.Wait(0)
		local inrange = false
		for i,b in ipairs(boatshop_blips) do
			DrawMarker(35,b.pos.entering[1],b.pos.entering[2],b.pos.entering[3],0,0,0,0,0,0,1.5001,1.5001,1.5001,0,155,255,200,0,0,0,1)
			DrawMarker(29,b.pos.entering[1],b.pos.entering[2],b.pos.entering[3]+1.1,0,0,0,0,0,0,0.7001,0.7001,0.7001,0,155,255,200,0,0,0,1)
			if IsPlayerWantedLevelGreater(GetPlayerIndex(),0) == false and boatshop.opened == false and IsPedInAnyVehicle(GetPlayerPed(-1), true) == false and  GetDistanceBetweenCoords(b.pos.entering[1],b.pos.entering[2],b.pos.entering[3],GetEntityCoords(GetPlayerPed(-1))) < 2 then
				drawTxt('Hit ~g~Enter~s~ to open Boat dealer',0,1,0.5,0.8,0.6,255,255,255,255)
				currentlocation = b
				inrange = true
			end
		end
		inrangeofboatshop = inrange
	end
end)

Citizen.CreateThread(function()
	local last_dir
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(1,201) and IsPlayerInRangeOfboatshop() then
			if boatshop.opened then
				CloseCreator()
			else
				OpenCreator()
			end
		end
		if boatshop.opened then
			local ped = GetPlayerPed(-1)
			local menu = boatshop.menu[boatshop.currentmenu]
			drawTxt(boatshop.title,1,1,boatshop.menu.x,boatshop.menu.y,1.0, 255,255,255,255)
			drawMenuTitle(menu.title, boatshop.menu.x,boatshop.menu.y + 0.08)
			drawTxt(boatshop.selectedbutton.."/"..tablelength(menu.buttons),0,0,boatshop.menu.x + boatshop.menu.width/2 - 0.0385,boatshop.menu.y + 0.067,0.4, 255,255,255,255)
			local y = boatshop.menu.y + 0.12
			buttoncount = tablelength(menu.buttons)
			local selected = false

			for i,button in pairs(menu.buttons) do
				if i >= boatshop.menu.from and i <= boatshop.menu.to then

					if i == boatshop.selectedbutton then
						selected = true
					else
						selected = false
					end
					drawMenuButton(button,boatshop.menu.x,y,selected)
					if button.costs ~= nil then
						if boatshop.currentmenu == "Pneumatic" or boatshop.currentmenu == "Sails" or boatshop.currentmenu == "Jetski" or boatshop.currentmenu == "Submersible" or boatshop.currentmenu == "Trawler" or boatshop.currentmenu == "Vedette" then
							drawMenuRight(button.costs..",-",boatshop.menu.x,y,selected)
						else
							drawMenuRight(button,boatshop.menu.x,y,selected)
						end
					end
					y = y + 0.04
					if boatshop.currentmenu == "Pneumatic" or boatshop.currentmenu == "Sails" or boatshop.currentmenu == "Jetski" or boatshop.currentmenu == "Submersible" or boatshop.currentmenu == "Trawler" or boatshop.currentmenu == "Vedette" then
						if selected then
							if fakeboat.model ~= button.model then
								if DoesEntityExist(fakeboat.car) then
									Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(fakeboat.car))
								end
								local pos = currentlocation.pos.inside
								local hash = GetHashKey(button.model)
								RequestModel(hash)
								local timer = 0
								while not HasModelLoaded(hash) and timer < 150 do
									Citizen.Wait(0)
									drawTxt("~b~Loading...",0,1,0.5,0.5,1.5,255,255,255,255)
									RequestModel(hash)
									timer = timer + 1
								end
								if timer < 150 then
									local az = pos[3]
									if button.model == "seashark" or button.model == "seashark2" or button.model == "seashark3" then
										az = az+0.8
									end
									local veh = CreateVehicle(hash,pos[1],pos[2],az,pos[4],false,false)
									while not DoesEntityExist(veh) do
										Citizen.Wait(0)
										drawTxt("~b~Loading...",0,1,0.5,0.5,1.5,255,255,255,255)
									end
									FreezeEntityPosition(veh,true)
									SetEntityInvincible(veh,true)
									SetVehicleDoorsLocked(veh,4)
									--SetEntityCollision(veh,false,false)
									TaskWarpPedIntoVehicle(ped,veh,-1)
									for i = 0,24 do
										SetVehicleModKit(veh,0)
										RemoveVehicleMod(veh,i)
									end
									fakeboat = { model = button.model, car = veh}
								else
									timer = 0
									while timer < 50 do
										Citizen.Wait(1)
										drawTxt("Failed!",0,1,0.5,0.5,1.5,255,0,0,255)
										timer = timer + 1
									end
									if last_dir then
										if boatshop.selectedbutton < buttoncount then
											boatshop.selectedbutton = boatshop.selectedbutton +1
											if buttoncount > 10 and boatshop.selectedbutton > boatshop.menu.to then
												boatshop.menu.to = boatshop.menu.to + 1
												boatshop.menu.from = boatshop.menu.from + 1
											end
										else
											last_dir = false
											boatshop.selectedbutton = boatshop.selectedbutton -1
											if buttoncount > 10 and boatshop.selectedbutton < boatshop.menu.from then
												boatshop.menu.from = boatshop.menu.from -1
												boatshop.menu.to = boatshop.menu.to - 1
											end
										end
									else
										if boatshop.selectedbutton > 1 then
											boatshop.selectedbutton = boatshop.selectedbutton -1
											if buttoncount > 10 and boatshop.selectedbutton < boatshop.menu.from then
												boatshop.menu.from = boatshop.menu.from -1
												boatshop.menu.to = boatshop.menu.to - 1
											end
										else
											last_dir = true
											boatshop.selectedbutton = boatshop.selectedbutton +1
											if buttoncount > 10 and boatshop.selectedbutton > boatshop.menu.to then
												boatshop.menu.to = boatshop.menu.to + 1
												boatshop.menu.from = boatshop.menu.from + 1
											end
										end
									end
								end
							end
						end
					end
					if selected and IsControlJustPressed(1,201) then
						ButtonSelected(button)
					end
				end
			end
			if IsControlJustPressed(1,202) then
				Back()
			end
			if IsControlJustReleased(1,202) then
				backlock = false
			end
			if IsControlJustPressed(1,188) then
				if boatshop.selectedbutton > 1 then
					boatshop.selectedbutton = boatshop.selectedbutton -1
					if buttoncount > 10 and boatshop.selectedbutton < boatshop.menu.from then
						boatshop.menu.from = boatshop.menu.from -1
						boatshop.menu.to = boatshop.menu.to - 1
					end
				end
			end
			if IsControlJustPressed(1,187)then
				if boatshop.selectedbutton < buttoncount then
					boatshop.selectedbutton = boatshop.selectedbutton +1
					if buttoncount > 10 and boatshop.selectedbutton > boatshop.menu.to then
						boatshop.menu.to = boatshop.menu.to + 1
						boatshop.menu.from = boatshop.menu.from + 1
					end
				end
			end
		end
	end
end)

--[[Events]]--
RegisterNetEvent('vRP_BD:CloseMenu')
AddEventHandler('vRP_BD:CloseMenu', function(name, boat, vehicle_plate)
	boughtboat = true	
	CloseCreator(name, boat, vehicle_plate)
end)