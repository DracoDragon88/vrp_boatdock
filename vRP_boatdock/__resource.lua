resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description "Draco Boat Ducks"

dependency "vrp"

-- server scripts
server_scripts{
  "@vrp/lib/utils.lua",
  "server.lua"
}

-- client scripts
client_scripts{
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "cl_shop.lua",
  "GUI.lua",
  "cl_docks.lua"
}
