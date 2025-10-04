-- Модуль управления сервером для админ меню
-- Содержит функции для работы с сервером

AdminMenu.Server = AdminMenu.Server or {}

function AdminMenu.Server:ChangeMap(mapName)
    if not mapName or mapName == "" then return false end

    RunConsoleCommand("changelevel", mapName)
    chat.AddText(Color(100, 255, 100), "Смена карты на: " .. mapName)
    return true
end

function AdminMenu.Server:RestartMap()
    RunConsoleCommand("ulx", "maprestart")
    chat.AddText(Color(255, 200, 100), "Карта перезагружается...")
    return true
end

function AdminMenu.Server:WipeMap()
    RunConsoleCommand("ulx", "mapwipe")
    chat.AddText(Color(255, 100, 100), "Карта очищена!")
    return true
end

function AdminMenu.Server:StopServer()
    RunConsoleCommand("ulx", "stop")
    chat.AddText(Color(255, 50, 50), "Сервер останавливается...")
    return true
end

function AdminMenu.Server:SetGravity(gravity)
    gravity = tonumber(gravity) or 600
    RunConsoleCommand("sv_gravity", tostring(gravity))
    chat.AddText(Color(150, 150, 255), "Гравитация установлена: " .. gravity)
    return true
end

function AdminMenu.Server:EnableCollisions(enable)
    local value = enable and "1" or "0"
    RunConsoleCommand("physcannon_mega_enabled", value)
    local action = enable and "включены" or "выключены"
    chat.AddText(Color(200, 255, 200), "Коллизии " .. action)
    return true
end

function AdminMenu.Server:ExecuteCommand(command)
    if not command or command == "" then return false end

    LocalPlayer():ConCommand(command)
    chat.AddText(Color(255, 255, 150), "Команда выполнена: " .. command)
    return true
end

function AdminMenu.Server:GetMapList()
    local maps = {
        "gm_construct",
        "gm_flatgrass",
        "gm_bigcity",
        "gm_genesis",
        "gm_excess_construct",
        "gm_functional_flatgrass",
        "gm_bluehills_test3",
        "gm_blackmesa_crossfire",
        "gm_carcon_ws",
        "gm_fork",
        "gm_mobenix_v3_final",
        "gm_snabbanslag_v2",
        "gm_stalk",
        "gm_test_chamber",
        "gm_underconstruct",
        "gm_valley",
        "gm_warmap",
        "ttt_67thway_v4",
        "ttt_airbus_b3",
        "ttt_apple_orchard",
        "ttt_bb_teenroom_b2",
        "ttt_chaser",
        "ttt_clue_se",
        "ttt_community_bowling",
        "ttt_community_pool",
        "ttt_crummycradle_a4",
        "ttt_darkness_revisited",
        "ttt_desperados",
        "ttt_dolls",
        "ttt_fastfood_a6",
        "ttt_frosty_v2",
        "ttt_island_2013",
        "ttt_lost_temple_v2",
        "ttt_mc_skyislands",
        "ttt_minecraft_b5",
        "ttt_minecraft_city_v3",
        "ttt_minecraft_hotel",
        "ttt_minigames",
        "ttt_mw2_terminal",
        "ttt_nuclear_power_b1",
        "ttt_office_gmod",
        "ttt_phantom_a4",
        "ttt_prison",
        "ttt_roy_the_ship",
        "ttt_skyscraper",
        "ttt_subway_a2",
        "ttt_townsquare",
        "ttt_whitehouse",
        "ttt_wintermansion"
    }
    return maps
end

function AdminMenu.Server:GetServerInfo()
    local info = {
        map = game.GetMap(),
        maxplayers = game.MaxPlayers(),
        hostname = GetHostName(),
        gamemode = engine.ActiveGamemode(),
        uptime = math.floor(SysTime()),
        players = #player.GetAll()
    }
    return info
end

function AdminMenu.Server:PrintServerInfo()
    local info = AdminMenu.Server:GetServerInfo()

    chat.AddText(Color(100, 200, 255), "=== Информация о сервере ===")
    chat.AddText(Color(255, 255, 255), "Карта: " .. info.map)
    chat.AddText(Color(255, 255, 255), "Игроков: " .. info.players .. "/" .. info.maxplayers)
    chat.AddText(Color(255, 255, 255), "Название: " .. info.hostname)
    chat.AddText(Color(255, 255, 255), "Режим игры: " .. info.gamemode)
    chat.AddText(Color(255, 255, 255), "Аптайм: " .. string.NiceTime(info.uptime))
end

function AdminMenu.Server:Cleanup()
    for _, ent in ipairs(ents.GetAll()) do
        if ent:IsNPC() or ent:IsRagdoll() or ent:GetClass() == "prop_physics" then
            ent:Remove()
        end
    end

    game.CleanUpMap()
    chat.AddText(Color(100, 255, 100), "Карта очищена от ненужных объектов!")
end

print("Модуль управления сервером загружен!")