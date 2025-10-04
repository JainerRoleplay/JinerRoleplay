-- Система логирования для админ меню
-- Отслеживает действия администраторов

AdminMenu.Logging = AdminMenu.Logging or {}

-- Лог уровни
AdminMenu.Logging.Levels = {
    INFO = 1,
    WARNING = 2,
    ERROR = 3,
    CRITICAL = 4
}

-- Буфер логов
AdminMenu.Logging.LogBuffer = AdminMenu.Logging.LogBuffer or {}
AdminMenu.Logging.MaxBufferSize = 1000

function AdminMenu.Logging:Log(level, message, admin, target)
    if not AdminMenu.Config.Logging.Enabled then return end

    local logLevel = AdminMenu.Logging.Levels[level] or AdminMenu.Logging.Levels.INFO
    if logLevel < AdminMenu.Config.Logging.LogLevel then return end

    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local adminName = IsValid(admin) and admin:Nick() or "CONSOLE"
    local targetName = IsValid(target) and target:Nick() or "N/A"

    local logEntry = {
        timestamp = timestamp,
        level = level,
        message = message,
        admin = adminName,
        target = targetName,
        adminSteamID = IsValid(admin) and admin:SteamID() or "CONSOLE",
        targetSteamID = IsValid(target) and target:SteamID() or "N/A"
    }

    -- Добавление в буфер
    table.insert(AdminMenu.Logging.LogBuffer, logEntry)

    -- Ограничение размера буфера
    if #AdminMenu.Logging.LogBuffer > AdminMenu.Logging.MaxBufferSize then
        table.remove(AdminMenu.Logging.LogBuffer, 1)
    end

    -- Вывод в консоль
    print(string.format("[%s] [%s] %s -> %s: %s", timestamp, level, adminName, targetName, message))

    -- Сохранение в файл
    self:SaveToFile(logEntry)

    -- Отправка в чат (если настроено)
    if AdminMenu.Config.Logging.LogChat and level == "INFO" then
        chat.AddText(Color(100, 200, 255), "[LOG] ", Color(255, 255, 255), message)
    end
end

function AdminMenu.Logging:SaveToFile(logEntry)
    if not AdminMenu.Config.Logging.LogFile then return end

    local logPath = "admin_logs/" .. AdminMenu.Config.Logging.LogFile
    local logData = string.format("[%s] [%s] %s -> %s: %s\n",
        logEntry.timestamp,
        logEntry.level,
        logEntry.admin,
        logEntry.target,
        logEntry.message
    )

    file.Append(logPath, logData)
end

function AdminMenu.Logging:GetLogs(filter)
    local logs = {}

    for _, logEntry in ipairs(AdminMenu.Logging.LogBuffer) do
        if not filter or self:MatchesFilter(logEntry, filter) then
            table.insert(logs, logEntry)
        end
    end

    return logs
end

function AdminMenu.Logging:MatchesFilter(logEntry, filter)
    if not filter then return true end

    if filter.level and string.lower(logEntry.level) != string.lower(filter.level) then
        return false
    end

    if filter.admin and not string.find(string.lower(logEntry.admin), string.lower(filter.admin)) then
        return false
    end

    if filter.target and not string.find(string.lower(logEntry.target), string.lower(filter.target)) then
        return false
    end

    if filter.message and not string.find(string.lower(logEntry.message), string.lower(filter.message)) then
        return false
    end

    if filter.steamid and logEntry.adminSteamID != filter.steamid and logEntry.targetSteamID != filter.steamid then
        return false
    end

    return true
end

function AdminMenu.Logging:ClearLogs()
    AdminMenu.Logging.LogBuffer = {}
    chat.AddText(Color(255, 200, 100), "Логи очищены!")
end

function AdminMenu.Logging:ExportLogs()
    local logs = self:GetLogs()
    local exportData = util.TableToJSON(logs, true)

    local filename = "admin_logs_export_" .. os.date("%Y%m%d_%H%M%S") .. ".json"
    file.Write(filename, exportData)

    chat.AddText(Color(100, 255, 100), "Логи экспортированы в: " .. filename)
    return filename
end

-- Хуки для автоматического логирования действий
hook.Add("PlayerKicked", "AdminMenu_LogKick", function(target, kicker, reason)
    AdminMenu.Logging:Log("WARNING", "Игрок кикнут: " .. (reason or "Без причины"), kicker, target)
end)

hook.Add("PlayerBanned", "AdminMenu_LogBan", function(target, banTime, reason)
    AdminMenu.Logging:Log("ERROR", "Игрок забанен на " .. banTime .. " мин: " .. (reason or "Без причины"), nil, target)
end)

-- Функции для логирования специфичных действий админ меню
function AdminMenu.Logging:LogPlayerAction(action, admin, target, details)
    local message = string.format("Действие игрока: %s", action)
    if details then
        message = message .. " (" .. details .. ")"
    end

    self:Log("INFO", message, admin, target)
end

function AdminMenu.Logging:LogServerAction(action, admin, details)
    local message = string.format("Действие сервера: %s", action)
    if details then
        message = message .. " (" .. details .. ")"
    end

    self:Log("INFO", message, admin)
end

function AdminMenu.Logging:LogUtilityAction(action, admin, details)
    local message = string.format("Утилита: %s", action)
    if details then
        message = message .. " (" .. details .. ")"
    end

    self:Log("INFO", message, admin)
end

-- Создание директории для логов при загрузке
hook.Add("InitPostEntity", "AdminMenu_CreateLogDir", function()
    if not file.Exists("admin_logs", "DATA") then
        file.CreateDir("admin_logs")
    end
end)

print("Система логирования админ меню загружена!")