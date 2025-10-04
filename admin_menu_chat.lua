-- Команды чата для админ меню
-- Быстрый доступ к функциям через чат

AdminMenu.ChatCommands = AdminMenu.ChatCommands or {}

-- Список доступных команд
AdminMenu.ChatCommands.Commands = {
    ["!admin"] = {
        description = "Открыть админ меню",
        func = function(ply, args)
            AdminMenu:CreateMenu()
        end,
        adminOnly = true
    },

    ["!kick"] = {
        description = "Кикнуть игрока (!kick <имя> [причина])",
        func = function(ply, args)
            if #args < 1 then return "!kick <имя> [причина]" end

            local targetName = args[1]
            local reason = table.concat(args, " ", 2) or "Кикнут администратором"

            local target = AdminMenu:FindPlayerByName(targetName)
            if not IsValid(target) then
                return "Игрок не найден: " .. targetName
            end

            AdminMenu.Players:KickPlayer(target, reason)
            AdminMenu.Logging:LogPlayerAction("КИК", ply, target, reason)
            return "Игрок " .. target:Nick() .. " кикнут"
        end,
        adminOnly = true
    },

    ["!ban"] = {
        description = "Забанить игрока (!ban <имя> [время] [причина])",
        func = function(ply, args)
            if #args < 1 then return "!ban <имя> [время] [причина]" end

            local targetName = args[1]
            local banTime = tonumber(args[2]) or 0
            local reason = table.concat(args, " ", 3) or "Забанен администратором"

            local target = AdminMenu:FindPlayerByName(targetName)
            if not IsValid(target) then
                return "Игрок не найден: " .. targetName
            end

            AdminMenu.Players:BanPlayer(target, reason, banTime)
            AdminMenu.Logging:LogPlayerAction("БАН", ply, target, reason .. " (" .. banTime .. " мин)")
            return "Игрок " .. target:Nick() .. " забанен"
        end,
        adminOnly = true
    },

    ["!goto"] = {
        description = "Перейти к игроку (!goto <имя>)",
        func = function(ply, args)
            if #args < 1 then return "!goto <имя>" end

            local targetName = args[1]
            local target = AdminMenu:FindPlayerByName(targetName)
            if not IsValid(target) then
                return "Игрок не найден: " .. targetName
            end

            AdminMenu.Players:GotoPlayer(target)
            AdminMenu.Logging:LogPlayerAction("ТЕЛЕПОРТ К ИГРОКУ", ply, target)
            return "Телепортирован к " .. target:Nick()
        end,
        adminOnly = true
    },

    ["!bring"] = {
        description = "Телепортировать игрока к себе (!bring <имя>)",
        func = function(ply, args)
            if #args < 1 then return "!bring <имя>" end

            local targetName = args[1]
            local target = AdminMenu:FindPlayerByName(targetName)
            if not IsValid(target) then
                return "Игрок не найден: " .. targetName
            end

            AdminMenu.Players:BringPlayer(target)
            AdminMenu.Logging:LogPlayerAction("ТЕЛЕПОРТ К АДМИНУ", ply, target)
            return "Игрок " .. target:Nick() .. " телепортирован к вам"
        end,
        adminOnly = true
    },

    ["!slap"] = {
        description = "Шлепнуть игрока (!slap <имя> [урон])",
        func = function(ply, args)
            if #args < 1 then return "!slap <имя> [урон]" end

            local targetName = args[1]
            local damage = tonumber(args[2]) or 10

            local target = AdminMenu:FindPlayerByName(targetName)
            if not IsValid(target) then
                return "Игрок не найден: " .. targetName
            end

            AdminMenu.Players:SlapPlayer(target, damage)
            AdminMenu.Logging:LogPlayerAction("ШЛЕПОК", ply, target, damage .. " урона")
            return "Игрок " .. target:Nick() .. " получил шлепок"
        end,
        adminOnly = true
    },

    ["!freeze"] = {
        description = "Заморозить игрока (!freeze <имя>)",
        func = function(ply, args)
            if #args < 1 then return "!freeze <имя>" end

            local targetName = args[1]
            local target = AdminMenu:FindPlayerByName(targetName)
            if not IsValid(target) then
                return "Игрок не найден: " .. targetName
            end

            AdminMenu.Players:FreezePlayer(target, true)
            AdminMenu.Logging:LogPlayerAction("ЗАМОРОЗКА", ply, target)
            return "Игрок " .. target:Nick() .. " заморожен"
        end,
        adminOnly = true
    },

    ["!unfreeze"] = {
        description = "Разморозить игрока (!unfreeze <имя>)",
        func = function(ply, args)
            if #args < 1 then return "!unfreeze <имя>" end

            local targetName = args[1]
            local target = AdminMenu:FindPlayerByName(targetName)
            if not IsValid(target) then
                return "Игрок не найден: " .. targetName
            end

            AdminMenu.Players:FreezePlayer(target, false)
            AdminMenu.Logging:LogPlayerAction("РАЗМОРОЗКА", ply, target)
            return "Игрок " .. target:Nick() .. " разморожен"
        end,
        adminOnly = true
    },

    ["!god"] = {
        description = "Включить/выключить God Mode (!god <имя>)",
        func = function(ply, args)
            if #args < 1 then return "!god <имя>" end

            local targetName = args[1]
            local target = AdminMenu:FindPlayerByName(targetName)
            if not IsValid(target) then
                return "Игрок не найден: " .. targetName
            end

            AdminMenu.Players:GodMode(target, not target:HasGodMode())
            local status = target:HasGodMode() and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН"
            AdminMenu.Logging:LogPlayerAction("GOD MODE " .. status, ply, target)
            return "God Mode для " .. target:Nick() .. " " .. string.lower(status)
        end,
        adminOnly = true
    },

    ["!noclip"] = {
        description = "Включить/выключить Noclip (!noclip <имя>)",
        func = function(ply, args)
            if #args < 1 then return "!noclip <имя>" end

            local targetName = args[1]
            local target = AdminMenu:FindPlayerByName(targetName)
            if not IsValid(target) then
                return "Игрок не найден: " .. targetName
            end

            local isNoclip = target:GetMoveType() == MOVETYPE_NOCLIP
            AdminMenu.Players:Noclip(target, not isNoclip)
            local status = not isNoclip and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН"
            AdminMenu.Logging:LogPlayerAction("NOCLIP " .. status, ply, target)
            return "Noclip для " .. target:Nick() .. " " .. string.lower(status)
        end,
        adminOnly = true
    },

    ["!invisible"] = {
        description = "Включить/выключить невидимку (!invisible <имя>)",
        func = function(ply, args)
            if #args < 1 then return "!invisible <имя>" end

            local targetName = args[1]
            local target = AdminMenu:FindPlayerByName(targetName)
            if not IsValid(target) then
                return "Игрок не найден: " .. targetName
            end

            local isInvisible = target:GetNoDraw()
            AdminMenu.Players:Invisible(target, not isInvisible)
            local status = not isInvisible and "ВКЛЮЧЕНА" or "ВЫКЛЮЧЕНА"
            AdminMenu.Logging:LogPlayerAction("НЕВИДИМКА " .. status, ply, target)
            return "Невидимка для " .. target:Nick() .. " " .. string.lower(status)
        end,
        adminOnly = true
    },

    ["!map"] = {
        description = "Сменить карту (!map <название>)",
        func = function(ply, args)
            if #args < 1 then return "!map <название>" end

            local mapName = args[1]
            AdminMenu.Server:ChangeMap(mapName)
            AdminMenu.Logging:LogServerAction("СМЕНА КАРТЫ", ply, mapName)
            return "Карта сменяется на " .. mapName
        end,
        adminOnly = true
    },

    ["!restart"] = {
        description = "Перезагрузить карту",
        func = function(ply, args)
            AdminMenu.Server:RestartMap()
            AdminMenu.Logging:LogServerAction("ПЕРЕЗАГРУЗКА КАРТЫ", ply)
            return "Карта перезагружается"
        end,
        adminOnly = true
    },

    ["!spawn"] = {
        description = "Заспавнить энтити (!spawn <класс>)",
        func = function(ply, args)
            if #args < 1 then return "!spawn <класс>" end

            local entityClass = args[1]
            AdminMenu.Utilities:SpawnEntity(entityClass)
            AdminMenu.Logging:LogUtilityAction("СПАВН ЭНТИТИ", ply, entityClass)
            return "Заспавнен энтити: " .. entityClass
        end,
        adminOnly = true
    },

    ["!logs"] = {
        description = "Показать последние логи (!logs [количество])",
        func = function(ply, args)
            local count = tonumber(args[1]) or 10
            local logs = AdminMenu.Logging:GetLogs()

            -- Берем последние N логов
            local recentLogs = {}
            for i = math.max(1, #logs - count + 1), #logs do
                table.insert(recentLogs, logs[i])
            end

            -- Выводим логи
            for _, log in ipairs(recentLogs) do
                local color = AdminMenu.Config.Colors.Info
                if log.level == "ERROR" then
                    color = AdminMenu.Config.Colors.Error
                elseif log.level == "WARNING" then
                    color = AdminMenu.Config.Colors.Warning
                end

                chat.AddText(color, string.format("[%s] %s: %s", log.level, log.admin, log.message))
            end

            return "Показаны последние " .. #recentLogs .. " логов"
        end,
        adminOnly = true
    },

    ["!help"] = {
        description = "Показать список команд",
        func = function(ply, args)
            chat.AddText(Color(100, 255, 100), "=== Админ команды ===")

            for command, data in pairs(AdminMenu.ChatCommands.Commands) do
                if not data.adminOnly or (data.adminOnly and ply:IsAdmin()) then
                    chat.AddText(Color(255, 255, 100), command .. " - " .. data.description)
                end
            end

            chat.AddText(Color(100, 255, 100), "==================")
            return "Помощь показана"
        end,
        adminOnly = false
    }
}

-- Функция для поиска игрока по имени
function AdminMenu:FindPlayerByName(name)
    if not name then return nil end

    -- Сначала пытаемся найти точное совпадение
    for _, ply in ipairs(player.GetAll()) do
        if ply:Nick():lower() == name:lower() then
            return ply
        end
    end

    -- Затем частичное совпадение
    for _, ply in ipairs(player.GetAll()) do
        if string.find(ply:Nick():lower(), name:lower()) then
            return ply
        end
    end

    return nil
end

-- Обработка сообщений в чате
hook.Add("PlayerSay", "AdminMenu_ChatCommands", function(ply, text, team)
    if string.StartWith(text, "!") then
        local args = string.Explode(" ", text)
        local command = args[1]:lower()

        if AdminMenu.ChatCommands.Commands[command] then
            local cmdData = AdminMenu.ChatCommands.Commands[command]

            -- Проверка прав доступа
            if cmdData.adminOnly and not ply:IsAdmin() then
                ply:ChatPrint("У вас нет прав для использования этой команды!")
                return ""
            end

            -- Выполнение команды
            local result = cmdData.func(ply, args)
            if result then
                ply:ChatPrint(result)
            end

            return ""
        end
    end
end)

-- Автодополнение команд в чате
hook.Add("OnChatTab", "AdminMenu_ChatTab", function(text)
    local commands = {}

    for command, data in pairs(AdminMenu.ChatCommands.Commands) do
        if string.StartWith(command, text) then
            table.insert(commands, command)
        end
    end

    return commands
end)

print("Система команд чата админ меню загружена!")