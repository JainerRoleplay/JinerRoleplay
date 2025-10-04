AdminMenu = AdminMenu or {}

if SERVER then
  AddCSLuaFile("adminmenu/sh_config.lua")
  AddCSLuaFile("adminmenu/cl_menu.lua")
  include("adminmenu/sh_config.lua")
  include("adminmenu/sv_admin.lua")
else -- CLIENT
  include("adminmenu/sh_config.lua")
  include("adminmenu/cl_menu.lua")
end

if SERVER then
  print("[AdminMenu] Loaded server components")
else
  print("[AdminMenu] Loaded client components")
end
