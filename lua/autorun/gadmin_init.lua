-- GAdmin - Simple Admin Menu (RU)
-- Loads shared, client, and server modules

GAdmin = GAdmin or {}
GAdmin.Version = "0.1.0"

-- Basic configuration
GAdmin.Config = {
    DefaultRank = "user",
    MenuBind = KEY_F6, -- default key to open menu
}

local function includeShared(path)
    if SERVER then AddCSLuaFile(path) end
    include(path)
end

local function includeClient(path)
    if SERVER then AddCSLuaFile(path) return end
    include(path)
end

local function includeServer(path)
    if CLIENT then return end
    include(path)
end

-- Shared files
includeShared("gadmin/shared/net.lua")
includeShared("gadmin/shared/util.lua")

-- Server files
includeServer("gadmin/server/actions.lua")
includeServer("gadmin/server/permissions.lua")

-- Client files
includeClient("gadmin/client/menu.lua")
includeClient("gadmin/client/bind.lua")
