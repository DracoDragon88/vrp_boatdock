------ Code ------
local MySQL = module("vrp_mysql", "MySQL")
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

MySQL.createCommand("vRP/add_custom_boat","INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,vehicle_model,vehicle_plate,veh_type,marketprice) VALUES(@user_id,@vehicle,@vehicle_model,@vehicle_plate,@veh_type,@marketprice)")
MySQL.createCommand("vRP/get_user_boat", "SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("vRP/Get_Boats","SELECT * FROM vrp_user_vehicles WHERE user_id=@user_id and veh_type = 'boat'")
MySQL.createCommand("vRP/delete_boat_from_user","DELETE FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("vRP/Get_Boats_p","SELECT vehicle FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle AND vehicle_plate = @plate")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_boatdock")

-- Shop
local boatshop = module("vRP_boatdock", "cfg/anti")

function getPrice( category, model )
	for i,v in ipairs(boatshop.menu[category].buttons) do
		if v.model == model then
			return v.costs
		end
	end
	return nil 
end

RegisterServerEvent('vRP_BD:CheckMoneyForBoat')
AddEventHandler('vRP_BD:CheckMoneyForBoat', function(category, vehicle, name, price, veh_type)
	local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({user_id})
	MySQL.query("vRP/get_vehicle", {user_id = user_id, vehicle = vehicle}, function(pvehicle, affected)
		if #pvehicle > 0 then
			vRPclient.notify(player,{"You already own this boat."})
		else
			local actual_price = getPrice( category, vehicle)
			if actual_price == nil then
				vRPclient.notify(player,{"This boat is sold out"})
				return 
			end
			if actual_price ~= price then
				-- vRP.ban({player,"tried to buy "..vehicle.." to $"..price..", Actual price $"..actual_price})
				return
			end
			vRP.request({player,"Are you sure you want to buy "..name.." to $"..actual_price.."?",30,function(player,ok)
				if ok then
					if vRP.tryFullPayment({user_id,actual_price}) then
						vRP.getUserIdentity({user_id, function(identity)
							MySQL.query("vRP/add_custom_boat", {user_id = user_id, vehicle = vehicle, vehicle_model = name, vehicle_plate = "P "..identity.registration, veh_type = veh_type, marketprice = price})
						end})
						TriggerClientEvent('vRP_BD:CloseMenu', player, vehicle, veh_type, vehicle_plate)
						vRPclient.notify(player, {"Paid $"..actual_price..". We send "..name.." to your garage it should be there in 5 min."})
						CheckGarageForBoat(player, user_id)
					else
						vRPclient.notify(player, {"Not enough money."})
					end
				else
					vRPclient.notify(player,{"Purchase canceled."})
				end
			end})
		end
	end)
end)

-- Docks
RegisterServerEvent('vRP_BD:CheckDockForBoat')
AddEventHandler('vRP_BD:CheckDockForBoat', function()
	local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({user_id})
	MySQL.query("vRP/Get_Boats", {user_id = user_id}, function(data, affected)
		local boats = {}
		for _, v in ipairs(data) do
			table.insert(boats, {["vehicle_model"] = v.vehicle_model, ["vehicle_name"] = v.vehicle})
		end
		TriggerClientEvent('vRP_BD:getBoat', player, boats)
	end)
end)

RegisterServerEvent('vRP_BD:CheckForSpawnBoat')
AddEventHandler('vRP_BD:CheckForSpawnBoat', function(vehicle)
	local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({user_id})
	MySQL.query("vRP/get_user_boat", {user_id = user_id, vehicle = vehicle}, function(result, affected)
		vRP.closeMenu({player})
		TriggerClientEvent('vRP_BD:SpawnBoat', player, result[1].veh_type,vehicle, result[1].vehicle_plate, result[1].vehicle_colorprimary, result[1].vehicle_colorsecondary, result[1].vehicle_pearlescentcolor, result[1].vehicle_wheelcolor, result[1].vehicle_plateindex, result[1].vehicle_neoncolor1, result[1].vehicle_neoncolor2, result[1].vehicle_neoncolor3, result[1].vehicle_windowtint, result[1].vehicle_wheeltype, result[1].vehicle_mods0, result[1].vehicle_mods1, result[1].vehicle_mods2, result[1].vehicle_mods3, result[1].vehicle_mods4, result[1].vehicle_mods5, result[1].vehicle_mods6, result[1].vehicle_mods7, result[1].vehicle_mods8, result[1].vehicle_mods9, result[1].vehicle_mods10, result[1].vehicle_mods11, result[1].vehicle_mods12, result[1].vehicle_mods13, result[1].vehicle_mods14, result[1].vehicle_mods15, result[1].vehicle_mods16, result[1].vehicle_turbo, result[1].vehicle_tiresmoke, result[1].vehicle_xenon, result[1].vehicle_mods23, result[1].vehicle_mods24, result[1].vehicle_neon0, result[1].vehicle_neon1, result[1].vehicle_neon2, result[1].vehicle_neon3, result[1].vehicle_bulletproof, result[1].vehicle_smokecolor1, result[1].vehicle_smokecolor2, result[1].vehicle_smokecolor3, result[1].vehicle_modvariation)
	end)
end)

RegisterServerEvent('vRP_BD:CheckForBoat')
AddEventHandler('vRP_BD:CheckForBoat', function(plate,vehicle,vtype,tpLand)
	local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({user_id})
	MySQL.query("vRP/Get_Boats_p", {user_id = user_id, vehicle = vehicle, plate = plate}, function(rows, affected)
		if #rows > 0 then -- has vehicle
			TriggerClientEvent('vRP_BD:StoreBoatTrue', player, vtype, 10, tpLand)
		else
			vRPclient.notify(player,{"Not your boat"})
		end
	end)
end)

-- Sell vehicles
function CheckGarageForBoat(player, user_id)
	MySQL.query("vRP/Get_Boats", {user_id = user_id}, function(pvehicles, affected)
		local boats = {}
		for k,v in ipairs(pvehicles) do
			table.insert(boats, {["vehicle_model"] = v.vehicle, ["vehicle_name"] = v.vehicle_model})
		end
		TriggerClientEvent('vRP_BD:getBoat', player, boats)
	end)
end

RegisterServerEvent('vRP_BD:CheckForVehToSell')
AddEventHandler('vRP_BD:CheckForVehToSell', function(vehicle)
	local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({user_id})
	vRPclient.notify(player, {"Remember to put the boat in the garage before you sell, otherwise you cannot spawne a new one."})
	MySQL.query("vRP/get_user_boat", {user_id = user_id, vehicle = vehicle}, function(result, affected)
		local sellprice = math.floor(tonumber(result[1].marketprice)*0.5)
		vRP.closeMenu({player})
		vRP.request({player,"Are you sure you want to sell "..result[1].vehicle_model.." to $"..sellprice.."?",30,function(player,ok)
			if ok then
				MySQL.query("vRP/delete_boat_from_user", {user_id = user_id, vehicle = vehicle})
				-- MySQL.query("vRP/delete_user_chests", {user_id_string = 'chest:u'..user_id..'veh_'..string.lower(vehicle)})
				vRP.giveBankMoney({user_id,sellprice})

				vRPclient.notify(player, {"Your boat is now sold you got $"..sellprice.." that is transferred to your bank account."})
				CheckGarageForBoat(player, user_id)
				TriggerClientEvent('vRP_BD:playernotselling', player)
			else
				vRPclient.notify(player, {"The sale has been canceled"})
				TriggerClientEvent('vRP_BD:playernotselling', player)
			end
		end})
	end)
end)