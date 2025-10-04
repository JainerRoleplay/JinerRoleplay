-- Advanced Admin Menu - Консольные команды
-- Команды для управления админкой через консоль

-- Команда для выдачи админки
concommand.Add("admin_setadmin", function(ply, cmd, args)
    if IsValid(ply) and not AdminMenu:HasAccess(ply, "admin") then
        ply:ChatPrint("[Admin Menu] У вас нет прав на использование этой команды")
        return
    end
    
    if #args < 2 then
        local msg = "Использование: admin_setadmin <steamid/nick> <группа>\nДоступные группы: superadmin, admin, moderator, helper"
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. msg)
        else
            print("[Admin Menu] " .. msg)
        end
        return
    end
    
    local target = AdminMenu:FindPlayer(args[1])
    local group = args[2]
    
    if not target then
        local msg = "Игрок не найден: " .. args[1]
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. msg)
        else
            print("[Admin Menu] " .. msg)
        end
        return
    end
    
    if not AdminMenu.Config.AdminLevels[group] then
        local msg = "Неизвестная группа: " .. group
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. msg)
        else
            print("[Admin Menu] " .. msg)
        end
        return
    end
    
    AdminMenu:SetPlayerAdmin(target, group, ply)
    
    local msg = string.format("Игроку %s выдана группа %s", target:Nick(), group)
    if IsValid(ply) then
        ply:ChatPrint("[Admin Menu] " .. msg)
    else
        print("[Admin Menu] " .. msg)
    end
end)

-- Команда для удаления админки
concommand.Add("admin_removeadmin", function(ply, cmd, args)
    if IsValid(ply) and not AdminMenu:HasAccess(ply, "admin") then
        ply:ChatPrint("[Admin Menu] У вас нет прав на использование этой команды")
        return
    end
    
    if #args < 1 then
        local msg = "Использование: admin_removeadmin <steamid/nick>"
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. msg)
        else
            print("[Admin Menu] " .. msg)
        end
        return
    end
    
    local target = AdminMenu:FindPlayer(args[1])
    
    if not target then
        local msg = "Игрок не найден: " .. args[1]
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. msg)
        else
            print("[Admin Menu] " .. msg)
        end
        return
    end
    
    AdminMenu:RemovePlayerAdmin(target, ply)
    
    local msg = string.format("У игрока %s убраны админ права", target:Nick())
    if IsValid(ply) then
        ply:ChatPrint("[Admin Menu] " .. msg)
    else
        print("[Admin Menu] " .. msg)
    end
end)

-- Команда для просмотра админов
concommand.Add("admin_listadmins", function(ply, cmd, args)
    if IsValid(ply) and not AdminMenu:HasAccess(ply, "admin") then
        ply:ChatPrint("[Admin Menu] У вас нет прав на использование этой команды")
        return
    end
    
    local admins = {}
    for steamid, data in pairs(AdminMenu.Players) do
        table.insert(admins, data)
    end
    
    if #admins == 0 then
        local msg = "Админов не найдено"
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. msg)
        else
            print("[Admin Menu] " .. msg)
        end
        return
    end
    
    local msg = "=== СПИСОК АДМИНОВ ==="
    if IsValid(ply) then
        ply:ChatPrint("[Admin Menu] " .. msg)
    else
        print("[Admin Menu] " .. msg)
    end
    
    for _, admin in ipairs(admins) do
        local levelData = AdminMenu.Config.AdminLevels[admin.group]
        local levelName = levelData and levelData.Name or admin.group
        local status = "Оффлайн"
        
        -- Проверяем онлайн статус
        for _, p in ipairs(player.GetAll()) do
            if p:SteamID64() == admin.steamid then
                status = "Онлайн"
                break
            end
        end
        
        local adminMsg = string.format("%s (%s) - %s [%s]", admin.name, admin.steamid, levelName, status)
        
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. adminMsg)
        else
            print("[Admin Menu] " .. adminMsg)
        end
    end
end)

-- Команда для просмотра банов
concommand.Add("admin_listbans", function(ply, cmd, args)
    if IsValid(ply) and not AdminMenu:HasAccess(ply, "admin") then
        ply:ChatPrint("[Admin Menu] У вас нет прав на использование этой команды")
        return
    end
    
    local bans = AdminMenu:GetBans()
    
    if #bans == 0 then
        local msg = "Активных банов нет"
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. msg)
        else
            print("[Admin Menu] " .. msg)
        end
        return
    end
    
    local msg = "=== СПИСОК БАНОВ ==="
    if IsValid(ply) then
        ply:ChatPrint("[Admin Menu] " .. msg)
    else
        print("[Admin Menu] " .. msg)
    end
    
    for _, ban in ipairs(bans) do
        local timeLeft = ban.unban_at - os.time()
        local hoursLeft = math.floor(timeLeft / 3600)
        local minutesLeft = math.floor((timeLeft % 3600) / 60)
        
        local banMsg = string.format("%s (%s) - %s - Осталось: %dч %dм - Банил: %s", 
            ban.nick, ban.steamid, ban.reason, hoursLeft, minutesLeft, ban.banned_by)
        
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. banMsg)
        else
            print("[Admin Menu] " .. banMsg)
        end
    end
end)

-- Команда для разбана
concommand.Add("admin_unban", function(ply, cmd, args)
    if IsValid(ply) and not AdminMenu:HasAccess(ply, "unban") then
        ply:ChatPrint("[Admin Menu] У вас нет прав на использование этой команды")
        return
    end
    
    if #args < 1 then
        local msg = "Использование: admin_unban <steamid>"
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. msg)
        else
            print("[Admin Menu] " .. msg)
        end
        return
    end
    
    local steamid = args[1]
    local success = AdminMenu:UnbanPlayer(steamid, ply)
    
    if success then
        AdminMenu:LogAction(ply, "UNBAN", steamid, "")
        local msg = "Игрок с SteamID " .. steamid .. " разбанен"
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. msg)
        else
            print("[Admin Menu] " .. msg)
        end
    else
        local msg = "Бан не найден для SteamID: " .. steamid
        if IsValid(ply) then
            ply:ChatPrint("[Admin Menu] " .. msg)
        else
            print("[Admin Menu] " .. msg)
        end
    end
end)

-- Команда для перезагрузки конфигурации
concommand.Add("admin_reload", function(ply, cmd, args)
    if IsValid(ply) and not AdminMenu:HasAccess(ply, "admin") then
        ply:ChatPrint("[Admin Menu] У вас нет прав на использование этой команды")
        return
    end
    
    AdminMenu:LoadConfig()
    AdminMenu:LoadAdmins()
    
    local msg = "Конфигурация админ меню перезагружена"
    if IsValid(ply) then
        ply:ChatPrint("[Admin Menu] " .. msg)
    else
        print("[Admin Menu] " .. msg)
    end
end)

-- Команда для сохранения конфигурации
concommand.Add("admin_save", function(ply, cmd, args)
    if IsValid(ply) and not AdminMenu:HasAccess(ply, "admin") then
        ply:ChatPrint("[Admin Menu] У вас нет прав на использование этой команды")
        return
    end
    
    AdminMenu:SaveConfig()
    AdminMenu:SaveAdmins()
    AdminMenu:SaveBans()
    
    local msg = "Данные админ меню сохранены"
    if IsValid(ply) then
        ply:ChatPrint("[Admin Menu] " .. msg)
    else
        print("[Admin Menu] " .. msg)
    end
end)

-- Автодополнение для команд
local function AdminAutoComplete(cmd, args)
    local suggestions = {}
    
    -- Автодополнение имен игроков
    if cmd == "admin_setadmin" or cmd == "admin_removeadmin" then
        if #args == 1 then
            local partial = string.lower(args[1])
            for _, ply in ipairs(player.GetAll()) do
                local name = string.lower(ply:Nick())
                if string.find(name, partial, 1, true) then
                    table.insert(suggestions, cmd .. " \"" .. ply:Nick() .. "\"")
                end
            end
        elseif cmd == "admin_setadmin" and #args == 2 then
            -- Автодополнение групп
            local partial = string.lower(args[2])
            for group, _ in pairs(AdminMenu.Config.AdminLevels) do
                if string.find(string.lower(group), partial, 1, true) then
                    table.insert(suggestions, cmd .. " \"" .. args[1] .. "\" " .. group)
                end
            end
        end
    end
    
    return suggestions
end

-- Регистрируем автодополнение
if CLIENT then
    for _, cmd in ipairs({"admin_setadmin", "admin_removeadmin", "admin_listadmins", "admin_listbans", "admin_unban", "admin_reload", "admin_save"}) do
        concommand.Add(cmd, function() end, AdminAutoComplete)
    end
end

print("[Admin Menu] Консольные команды загружены")