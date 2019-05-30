local blipsEnable = true

local boatdocks = {
	-- {name="Dock",blip={blip_id,blip_color},onLand={x,y,z},onWater={x,y,z,h}}
	{name="Vespucci Dock", blip={356, 3}, onLand={-789.810, -1451.862, 1.595}, onWater={-824.089, -1461.917, 0.000, 175.976}},
	{name="Chumash Dock", blip={356, 3}, onLand={-3426.479, 954.065, 8.347}, onWater={-3448.723,937.484,0.000,358.566}},
	{name="Port Dock", blip={356, 3}, onLand={108.144, -3333.015, 5.999}, onWater={91.269, -3347.041, 0.000, 189.705}},
	{name="Paleto Dock", blip={356, 3}, onLand={-277.554, 6636.413, 7.486}, onWater={-335.690, 6689.711, 0.000, 70.659}},
	{name="El Gordo Dock", blip={356, 3}, onLand={3865.915, 4463.701, 2.739}, onWater={3878.549, 4472.920, 0.000, 258.159}},
	{name="Alamo Sea NE Dock", blip={356, 3}, onLand={1299.765,4219.014,33.908}, onWater={1333.417, 4217.460, 30.320, 264.249}},
	{name="Alamo Sea NV Dock", blip={356, 3}, onLand={713.530,4094.194,34.727}, onWater={714.536, 4080.325, 30.318, 286.749}}
}

lang_string = {
	menu0 = "~g~E~s~ to store boat",
	menu1 = "Marina",
	menu2 = "Get a boat",
	menu3 = "Close",
	menu4 = "Boats",
	menu5 = "Back",
	menu6 = "Get",
	menu7 = "~g~E~s~ to open menu",
	menu8 = "~g~E~s~ to sell the boat at 50% of the purchase price",
	menu9 = "Sell boat",
	state1 = "Out",
	state2 = "In",
	text1 = "No boat present",
	text2 = "The area is crowded",
	text3 = "This boat is already out",
	text4 = "Boat out",
	text5 = "It's not your boat",
	text6 = "Boat stored",
	text7 = "Boat bought, good wind",
	text8 = "Insufficient funds",
	text9 = "Boat sold"
}

--[[GarageStoff]]--
local playerisselling = false
vehicles = {}

--[[Local/Global]]--
BOATS = {}

dockSelected = {x=nil, y=nil, z=nil}

function MenuDock(name)
	MenuTitle = name or lang_string.menu1
	ClearMenu()
	-- Menu.addButton(lang_string.menu0,"StoreBoad",nil)
	Menu.addButton(lang_string.menu2,"ListBoad",MenuTitle)
	Menu.addButton(lang_string.menu3,"CloseMenu",nil) 
end

function StoreBoad()
	Citizen.CreateThread(function()
		local caissei = GetClosestVehicle(dockSelected.x, dockSelected.y, dockSelected.z, 3.000, 0, 12294)
		SetEntityAsMissionEntity(caissei, true, true)
		local plate = GetVehicleNumberPlateText(caissei)
		if IsThisModelABoat(GetEntityModel(caissei)) then
			local vtype = "boat"
			if DoesEntityExist(caissei) then
				TriggerServerEvent('vRP_BD:CheckForBoat',plate, vehicles[vtype][3], vtype)
			else
				drawNotification(lang_string.text1)
			end
		end
	end)
	CloseMenu()
end

function ListBoad(main)
	MenuTitle = lang_string.menu4
	ClearMenu()
	for ind, value in pairs(BOATS) do
		Menu.addButton(tostring(value.vehicle_name), "OptionMenu", value.vehicle_model,main,value.vehicle_name)
	end
	Menu.addButton(lang_string.menu5,"MenuDock",main)
end

function OptionMenu(boatID,main,Bname)
	MenuTitle = Bname or "Options"
	ClearMenu()
	Menu.addButton(lang_string.menu6, "SpawnBoad", boatID)
	Menu.addButton(lang_string.menu9, "SellBoad", boatID) --sell to vender
	Menu.addButton(lang_string.menu5, "ListBoad", main)
end

function SpawnBoad(boatID)
	TriggerServerEvent('vRP_BD:CheckForSpawnBoat', boatID)
	CloseMenu()
end

function SellBoad(boatID)
	playerisselling = true
	TriggerServerEvent('vRP_BD:CheckForVehToSell', boatID)
	CloseMenu()
end

---Generic Fonction
function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function CloseMenu()
	Menu.hidden = true
	TriggerServerEvent("vRP_BD:CheckDockForBoat")
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

--[[Docks for spawn boats]]--
Citizen.CreateThread(function()
	if blipsEnable then
		for k,v in pairs(boatdocks) do
			local blip = AddBlipForCoord(v.onLand[1],v.onLand[2],v.onLand[3])
			SetBlipSprite(blip, v.blip[1])
			SetBlipColour(blip, v.blip[2])
			SetBlipScale(blip, 0.7)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.name)
			EndTextCommandSetBlipName(blip)
			SetBlipAsShortRange(blip,true)
			SetBlipAsMissionCreatorBlip(blip,true)
		end
	end
	while true do
		Citizen.Wait(0)
		for i,b in ipairs(boatdocks) do
			local playerPed = GetPlayerPed(-1)
			if playerPed then
				local playerPos = GetEntityCoords(playerPed, true)
				if GetDistanceBetweenCoords(playerPos, b.onLand[1],b.onLand[2],b.onLand[3], true) < 50 then
					DrawMarker(35,b.onLand[1],b.onLand[2],b.onLand[3],0,0,0,0,0,0,1.3001,1.3001,1.3001,0,155,255,200,0,0,0,1)
					if GetDistanceBetweenCoords(b.onLand[1],b.onLand[2],b.onLand[3], playerPos) < 1.5 and IsPedInAnyVehicle(playerPed, true) == false then
						drawTxt(lang_string.menu7,0,1,0.5,0.8,0.6,255,255,255,255)
						if IsControlJustPressed(1, 86) then
							if playerisselling == false then
								dockSelected.x = b.onWater[1]
								dockSelected.y = b.onWater[2]
								dockSelected.z = b.onWater[3]
								dockSelected.axe = b.onWater[4]
								MenuDock(b.name)
								Menu.hidden = not Menu.hidden 
							else
								vRP.notify({"You are about to sell a boat."})
							end
						end
						Menu.renderGUI() 
					end
				end
				if IsPedInAnyBoat(playerPed, true) and GetDistanceBetweenCoords(playerPos, b.onWater[1],b.onWater[2],b.onWater[3], true) < 100 then
					DrawMarker(35,b.onWater[1],b.onWater[2],b.onWater[3]+3,0,0,0,0,0,0,2.5001,2.5001,2.5001,255,155,0,200,0,0,0,1)
					local caissei = GetVehiclePedIsIn(playerPed,false)
					if GetDistanceBetweenCoords(b.onWater[1],b.onWater[2],b.onWater[3], playerPos) < 10 and GetPedInVehicleSeat(caissei, -1) == playerPed then
						drawTxt(lang_string.menu0,0,1,0.5,0.8,0.6,255,255,255,255)
						if IsControlJustPressed(1, 86) then
 							-- local caissei = GetVehiclePedIsIn(GetPlayerPed(-1),false)
							SetEntityAsMissionEntity(caissei, true, true)
							local plate = GetVehicleNumberPlateText(caissei)
							if IsThisModelABoat(GetEntityModel(caissei)) then
								local vtype = "boat"
								if DoesEntityExist(caissei) and vehicles[vtype] ~= nil then
									TriggerServerEvent('vRP_BD:CheckForBoat',plate, vehicles[vtype][2], vtype, b.onLand)
								else
									drawNotification(lang_string.text1)
								end
							end
						end
					end
				end
			end
		end
	end
end)

--[[Events]]--
RegisterNetEvent('vRP_BD:getBoat')
AddEventHandler("vRP_BD:getBoat", function(THEBOATS)
    BOATS = {}
    BOATS = THEBOATS
end)

AddEventHandler("playerSpawned", function()
	TriggerServerEvent("vRP_BD:CheckDockForBoat")
end)

RegisterNetEvent('vRP_BD:SpawnBoat')
AddEventHandler('vRP_BD:SpawnBoat', function(vtype, name, vehicle_plate, vehicle_colorprimary, vehicle_colorsecondary, vehicle_pearlescentcolor, vehicle_wheelcolor, vehicle_plateindex, vehicle_neoncolor1, vehicle_neoncolor2, vehicle_neoncolor3, vehicle_windowtint, vehicle_wheeltype, vehicle_mods0, vehicle_mods1, vehicle_mods2, vehicle_mods3, vehicle_mods4, vehicle_mods5, vehicle_mods6, vehicle_mods7, vehicle_mods8, vehicle_mods9, vehicle_mods10, vehicle_mods11, vehicle_mods12, vehicle_mods13, vehicle_mods14, vehicle_mods15, vehicle_mods16, vehicle_turbo, vehicle_tiresmoke, vehicle_xenon, vehicle_mods23, vehicle_mods24, vehicle_neon0, vehicle_neon1, vehicle_neon2, vehicle_neon3, vehicle_bulletproof, vehicle_smokecolor1, vehicle_smokecolor2, vehicle_smokecolor3, vehicle_modvariation)
	local vehicle = vehicles[vtype]
	if vehicle and not IsVehicleDriveable(vehicle[3]) then -- precheck if vehicle is undriveable
		-- despawn vehicle
		SetVehicleHasBeenOwnedByPlayer(vehicle[3],false)
		Citizen.InvokeNative(0xAD738C3085FE7E11, vehicle[3], false, true) -- set not as mission entity
		SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicle[3]))
		Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle[3]))
		TriggerEvent("vrp_garages:setVehicle", vtype, nil)
	end

	vehicle = vehicles[vtype]
	if vehicle == nil then
		-- load vehicle model
		local mhash = GetHashKey(name)

		local i = 0
		while not HasModelLoaded(mhash) and i < 10000 do
			RequestModel(mhash)
			Citizen.Wait(10)
			i = i+1
		end

		-- spawn car
		if HasModelLoaded(mhash) then 
			local nveh = CreateVehicle(mhash, dockSelected.x, dockSelected.y, dockSelected.z, dockSelected.axe, true, true)
			SetVehicleOnGroundProperly(nveh)
			SetEntityInvincible(nveh,false)

			SetVehicleNumberPlateText(nveh, "P " .. vRP.getRegistrationNumber({}))
			Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) -- set as mission entity
			SetVehicleHasBeenOwnedByPlayer(nveh,true)
			SetPedIntoVehicle(GetPlayerPed(-1),nveh,-1) -- put player inside

			vehicle_migration = false
			if not vehicle_migration then
				local nid = NetworkGetNetworkIdFromEntity(nveh)
				SetNetworkIdCanMigrate(nid,false)
			end

			TriggerEvent("vrp_garages:setVehicle", vtype, {vtype,name,nveh,vehicle_plate})

			SetModelAsNoLongerNeeded(mhash)
		end
	else
		vRP.notify({"You can onlt have one "..vtype.." out at the time."})
	end
end)

RegisterNetEvent('vRP_BD:StoreBoatTrue')
AddEventHandler('vRP_BD:StoreBoatTrue', function(vtype,max_range,tpLand)
	local vehicle = vehicles[vtype]
	if vehicle then
		local x,y,z = table.unpack(GetEntityCoords(vehicle[3],true))
		local px,py,pz = vRP.getPosition()

		if GetDistanceBetweenCoords(x,y,z,px,py,pz,true) < max_range then -- check distance with the vehicule
			vRP.teleport({tpLand[1],tpLand[2],tpLand[3]})
			-- remove vehicle
			SetVehicleHasBeenOwnedByPlayer(vehicle[3],false)
			Citizen.InvokeNative(0xAD738C3085FE7E11, vehicle[3], false, true) -- set not as mission entity
			SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicle[3]))
			Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle[3]))
			local i = 0
			while DoesEntityExist(vehicle[3]) and i < 100 do
				SetEntityAsMissionEntity(vehicle[3], true, true)
				DeleteVehicle(vehicle[3])
				Citizen.Wait(10)
				i = i+1
			end
			TriggerEvent("vrp_garages:setVehicle", vtype, nil)
			vRP.notify({"Vehicle stored."})
		else
			vRP.notify({"Too far away from the boat."})
		end
	else
		vRP.notify({"You do not have a personal vehicle out."})
	end
end)

RegisterNetEvent('vrp_garages:setVehicle')
AddEventHandler('vrp_garages:setVehicle', function(vtype, vehicle)
	vehicles[vtype] = vehicle
end)

RegisterNetEvent('vRP_BD:playernotselling')
AddEventHandler("vRP_BD:playernotselling", function()
	playerisselling = false
end)