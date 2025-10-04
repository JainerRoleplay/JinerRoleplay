-- Advanced Admin Menu - Команды администратора
-- Система команд для управления сервером

AdminMenu.Commands = AdminMenu.Commands or {}

-- Регистрация команды
function AdminMenu:RegisterCommand(name, func, access_level, description)
    self.Commands[name] = {
        func = func,
        access = access_level,
        description = description or "Нет описания"
    }
end

-- Выполнение команды
function AdminMenu:ExecuteCommand(admin, command, args)
    local cmd = self.Commands[command]
    if not cmd then return false, "Команда не найдена" end
    
    if not self:HasAccess(admin, command) then
        return false, "Недостаточно прав"
    end
    
    local success, result = pcall(cmd.func, admin, args)
    if not success then
        return false, "Ошибка выполнения: " .. result
    end
    
    return true, result
end

-- ============ КОМАНДЫ ============

-- Кик игрока
AdminMenu:RegisterCommand("kick", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target)
    if not target then return "Игрок не найден" end
    
    local reason = args.reason or "Кик администратором"
    
    AdminMenu:LogAction(admin, "KICK", target, reason)
    
    target:Kick(reason)
    
    AdminMenu:BroadcastAction(admin:Nick() .. " кикнул " .. target:Nick() .. " (" .. reason .. ")")
    
    return "Игрок " .. target:Nick() .. " кикнут"
end, "kick", "Кикнуть игрока")

-- Бан игрока
AdminMenu:RegisterCommand("ban", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target)
    if not target then return "Игрок не найден" end
    
    local duration = tonumber(args.duration) or AdminMenu.Config.Settings.BanDuration.default
    local reason = args.reason or "Бан администратором"
    
    AdminMenu:LogAction(admin, "BAN", target, reason .. " (" .. duration .. " мин)")
    
    AdminMenu:BanPlayer(target, duration, reason, admin)
    
    return string.format("Игрок %s забанен на %d минут", target:Nick(), duration)
end, "ban", "Забанить игрока")

-- Разбан игрока
AdminMenu:RegisterCommand("unban", function(admin, args)
    local steamid = args.steamid
    if not steamid then return "SteamID не указан" end
    
    local success = AdminMenu:UnbanPlayer(steamid, admin)
    if success then
        AdminMenu:LogAction(admin, "UNBAN", steamid, "")
        return "Игрок разбанен"
    else
        return "Ошибка разбана"
    end
end, "unban", "Разбанить игрока")

-- Телепортация к игроку
AdminMenu:RegisterCommand("goto", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target)
    if not target then return "Игрок не найден" end
    
    admin:SetPos(target:GetPos())
    admin:SetAngles(target:GetAngles())
    
    AdminMenu:LogAction(admin, "GOTO", target, "")
    
    return "Телепортация к " .. target:Nick()
end, "teleport", "Телепортироваться к игроку")

-- Телепортация игрока к себе
AdminMenu:RegisterCommand("bring", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target)
    if not target then return "Игрок не найден" end
    
    target:SetPos(admin:GetPos())
    target:SetAngles(admin:GetAngles())
    
    AdminMenu:LogAction(admin, "BRING", target, "")
    
    return target:Nick() .. " телепортирован к вам"
end, "teleport", "Телепортировать игрока к себе")

-- Телепортация игрока
AdminMenu:RegisterCommand("teleport", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target)
    if not target then return "Игрок не найден" end
    
    local pos = Vector(args.x or 0, args.y or 0, args.z or 0)
    target:SetPos(pos)
    
    AdminMenu:LogAction(admin, "TELEPORT", target, string.format("%.0f %.0f %.0f", pos.x, pos.y, pos.z))
    
    return target:Nick() .. " телепортирован"
end, "teleport", "Телепортировать игрока")

-- Заморозка игрока
AdminMenu:RegisterCommand("freeze", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target)
    if not target then return "Игрок не найден" end
    
    target:Freeze(true)
    target:ChatPrint("[Admin Menu] Вы заморожены администратором " .. admin:Nick())
    
    AdminMenu:LogAction(admin, "FREEZE", target, "")
    
    return target:Nick() .. " заморожен"
end, "freeze", "Заморозить игрока")

-- Разморозка игрока
AdminMenu:RegisterCommand("unfreeze", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target)
    if not target then return "Игрок не найден" end
    
    target:Freeze(false)
    target:ChatPrint("[Admin Menu] Вы разморожены администратором " .. admin:Nick())
    
    AdminMenu:LogAction(admin, "UNFREEZE", target, "")
    
    return target:Nick() .. " разморожен"
end, "unfreeze", "Разморозить игрока")

-- Мут игрока
AdminMenu:RegisterCommand("mute", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target)
    if not target then return "Игрок не найден" end
    
    local duration = tonumber(args.duration) or 60 -- минуты
    
    AdminMenu:MutePlayer(target, duration, admin)
    
    AdminMenu:LogAction(admin, "MUTE", target, duration .. " мин")
    
    return string.format("%s замучен на %d минут", target:Nick(), duration)
end, "mute", "Замутить игрока")

-- Размут игрока
AdminMenu:RegisterCommand("unmute", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target)
    if not target then return "Игрок не найден" end
    
    AdminMenu:UnmutePlayer(target, admin)
    
    AdminMenu:LogAction(admin, "UNMUTE", target, "")
    
    return target:Nick() .. " размучен"
end, "unmute", "Размутить игрока")

-- Бессмертие
AdminMenu:RegisterCommand("god", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target) or admin
    
    local godMode = not target:HasGodMode()
    target:GodEnable(godMode)
    
    local status = godMode and "включен" or "выключен"
    
    AdminMenu:LogAction(admin, "GOD", target, status)
    
    return "Режим бога " .. status .. " для " .. target:Nick()
end, "god", "Переключить режим бога")

-- Ноклип
AdminMenu:RegisterCommand("noclip", function(admin, args)
    local target = AdminMenu:FindPlayer(args.target) or admin
    
    if target:GetMoveType() == MOVETYPE_NOCLIP then
        target:SetMoveType(MOVETYPE_WALK)
        AdminMenu:LogAction(admin, "NOCLIP", target, "выключен")
        return "Ноклип выключен для " .. target:Nick()
    else
        target:SetMoveType(MOVETYPE_NOCLIP)
        AdminMenu:LogAction(admin, "NOCLIP", target, "включен")
        return "Ноклип включен для " .. target:Nick()
    end
end, "noclip", "Переключить ноклип")

-- Очистка чата
AdminMenu:RegisterCommand("clearchat", function(admin, args)
    for i = 1, 50 do
        AdminMenu:BroadcastMessage("")
    end
    
    AdminMenu:BroadcastMessage("[Admin Menu] Чат очищен администратором " .. admin:Nick())
    AdminMenu:LogAction(admin, "CLEARCHAT", "", "")
    
    return "Чат очищен"
end, "admin", "Очистить чат")

-- Перезагрузка карты
AdminMenu:RegisterCommand("changemap", function(admin, args)
    local mapname = args.map
    if not mapname then return "Название карты не указано" end
    
    AdminMenu:LogAction(admin, "CHANGEMAP", "", mapname)
    AdminMenu:BroadcastMessage("[Admin Menu] Смена карты на " .. mapname .. " через 10 секунд!")
    
    timer.Simple(10, function()
        RunConsoleCommand("changelevel", mapname)
    end)
    
    return "Смена карты на " .. mapname
end, "admin", "Сменить карту")

-- Выдать деньги (DarkRP)
if DarkRP then
    AdminMenu:RegisterCommand("givemoney", function(admin, args)
        local target = AdminMenu:FindPlayer(args.target)
        if not target then return "Игрок не найден" end
        
        local amount = tonumber(args.amount) or 0
        if amount <= 0 then return "Неверная сумма" end
        
        target:addMoney(amount)
        
        AdminMenu:LogAction(admin, "GIVEMONEY", target, DarkRP.formatMoney(amount))
        
        return string.format("Выдано %s игроку %s", DarkRP.formatMoney(amount), target:Nick())
    end, "admin", "Выдать деньги игроку")
end

-- ============ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ============

-- Поиск игрока
function AdminMenu:FindPlayer(identifier)
    if not identifier then return nil end
    
    -- Поиск по SteamID
    if string.match(identifier, "STEAM_") then
        for _, ply in ipairs(player.GetAll()) do
            if ply:SteamID() == identifier then
                return ply
            end
        end
        return nil
    end
    
    -- Поиск по части имени
    local matches = {}
    local lowerName = string.lower(identifier)
    
    for _, ply in ipairs(player.GetAll()) do
        local plyName = string.lower(ply:Nick())
        if string.find(plyName, lowerName, 1, true) then
            table.insert(matches, ply)
        end
    end
    
    if #matches == 1 then
        return matches[1]
    elseif #matches > 1 then
        -- Точное совпадение
        for _, ply in ipairs(matches) do
            if string.lower(ply:Nick()) == lowerName then
                return ply
            end
        end
    end
    
    return nil
end

-- Рассылка сообщения всем админам
function AdminMenu:BroadcastAction(message)
    if not self.Config.Settings.NotifyPlayers then return end
    
    for _, ply in ipairs(player.GetAll()) do
        if self:HasAccess(ply, "admin") then
            ply:ChatPrint("[Admin Menu] " .. message)
        end
    end
end

-- Рассылка сообщения всем
function AdminMenu:BroadcastMessage(message)
    for _, ply in ipairs(player.GetAll()) do
        ply:ChatPrint(message)
    end
end

print("[Admin Menu] Команды загружены")