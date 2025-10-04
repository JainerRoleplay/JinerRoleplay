-- Advanced Admin Menu - Server Core
-- Автор: AI Assistant
-- Версия: 1.0

AdminMenu = AdminMenu or {}
AdminMenu.Version = "1.0"
AdminMenu.Players = AdminMenu.Players or {}
AdminMenu.Config = AdminMenu.Config or {}

-- Конфигурация по умолчанию
AdminMenu.Config = {
    -- Уровни администраторов
    AdminLevels = {
        superadmin = {
            Name = "Супер Администратор",
            Level = 100,
            Color = Color(255, 0, 0),
            Commands = "*" -- Все команды
        },
        admin = {
            Name = "Администратор",
            Level = 50,
            Color = Color(255, 128, 0),
            Commands = {
                "kick", "ban", "unban", "teleport", "bring", "goto",
                "freeze", "unfreeze", "mute", "unmute", "noclip", "god"
            }
        },
        moderator = {
            Name = "Модератор", 
            Level = 25,
            Color = Color(0, 255, 0),
            Commands = {
                "kick", "teleport", "bring", "freeze", "unfreeze", "mute", "unmute"
            }
        },
        helper = {
            Name = "Помощник",
            Level = 10,
            Color = Color(0, 128, 255),
            Commands = {
                "teleport", "bring", "freeze", "unfreeze"
            }
        }
    },
    
    -- Настройки
    Settings = {
        LogActions = true,
        NotifyPlayers = true,
        SaveBans = true,
        BanDuration = {
            default = 60, -- минуты
            max = 10080 -- неделя
        }
    }
}

-- Загрузка конфигурации
function AdminMenu:LoadConfig()
    local configFile = "admin_menu/config.json"
    if file.Exists(configFile, "DATA") then
        local content = file.Read(configFile, "DATA")
        local config = util.JSONToTable(content)
        if config then
            table.Merge(self.Config, config)
        end
    else
        self:SaveConfig()
    end
end

-- Сохранение конфигурации
function AdminMenu:SaveConfig()
    local configFile = "admin_menu/config.json"
    local json = util.TableToJSON(self.Config, true)
    file.Write(configFile, json)
end

-- Проверка уровня доступа
function AdminMenu:HasAccess(ply, command)
    if not IsValid(ply) then return true end
    
    local adminData = self:GetPlayerAdmin(ply)
    if not adminData then return false end
    
    local level = self.Config.AdminLevels[adminData.group]
    if not level then return false end
    
    if level.Commands == "*" then return true end
    
    return table.HasValue(level.Commands, command)
end

-- Получение админ данных игрока
function AdminMenu:GetPlayerAdmin(ply)
    return self.Players[ply:SteamID64()] or nil
end

-- Установка админ прав
function AdminMenu:SetPlayerAdmin(ply, group, grantor)
    local steamid = ply:SteamID64()
    
    self.Players[steamid] = {
        steamid = steamid,
        name = ply:Nick(),
        group = group,
        granted_by = grantor and grantor:Nick() or "Console",
        granted_at = os.time()
    }
    
    self:SaveAdmins()
    self:NotifyAdminChange(ply, group, true, grantor)
end

-- Удаление админ прав
function AdminMenu:RemovePlayerAdmin(ply, remover)
    local steamid = ply:SteamID64()
    local oldGroup = self.Players[steamid] and self.Players[steamid].group
    
    self.Players[steamid] = nil
    self:SaveAdmins()
    self:NotifyAdminChange(ply, oldGroup, false, remover)
end

-- Загрузка админов
function AdminMenu:LoadAdmins()
    local adminFile = "admin_menu/admins.json"
    if file.Exists(adminFile, "DATA") then
        local content = file.Read(adminFile, "DATA")
        local admins = util.JSONToTable(content)
        if admins then
            self.Players = admins
        end
    end
end

-- Сохранение админов
function AdminMenu:SaveAdmins()
    local adminFile = "admin_menu/admins.json"
    local json = util.TableToJSON(self.Players, true)
    file.Write(adminFile, json)
end

-- Уведомление об изменении админ статуса
function AdminMenu:NotifyAdminChange(ply, group, granted, changer)
    if not self.Config.Settings.NotifyPlayers then return end
    
    local message
    if granted then
        local levelData = self.Config.AdminLevels[group]
        message = string.format("%s получил права '%s'", ply:Nick(), levelData.Name)
    else
        message = string.format("У %s забрали админ права", ply:Nick())
    end
    
    if changer and IsValid(changer) then
        message = message .. string.format(" (выдал: %s)", changer:Nick())
    end
    
    for _, v in ipairs(player.GetAll()) do
        if self:HasAccess(v, "admin") then
            v:ChatPrint("[Admin Menu] " .. message)
        end
    end
end

-- Логирование действий
function AdminMenu:LogAction(admin, action, target, reason)
    if not self.Config.Settings.LogActions then return end
    
    local logFile = "admin_menu/logs/" .. os.date("%Y-%m-%d") .. ".txt"
    local timestamp = os.date("[%H:%M:%S]")
    local adminName = IsValid(admin) and admin:Nick() or "Console"
    local targetName = IsValid(target) and target:Nick() or tostring(target)
    
    local logEntry = string.format("%s %s (%s) %s %s", 
        timestamp, adminName, admin:SteamID(), action, targetName)
    
    if reason and reason ~= "" then
        logEntry = logEntry .. " - Причина: " .. reason
    end
    
    logEntry = logEntry .. "\n"
    
    file.Append(logFile, logEntry)
end

-- Инициализация
function AdminMenu:Initialize()
    print("[Admin Menu] Инициализация...")
    
    -- Создание папок
    if not file.IsDir("admin_menu", "DATA") then
        file.CreateDir("admin_menu")
    end
    if not file.IsDir("admin_menu/logs", "DATA") then
        file.CreateDir("admin_menu/logs")
    end
    
    self:LoadConfig()
    self:LoadAdmins()
    
    print("[Admin Menu] Загружено админов: " .. table.Count(self.Players))
    print("[Admin Menu] Версия: " .. self.Version)
end

-- Хуки
hook.Add("PlayerInitialSpawn", "AdminMenu_PlayerSpawn", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            local adminData = AdminMenu:GetPlayerAdmin(ply)
            if adminData then
                local level = AdminMenu.Config.AdminLevels[adminData.group]
                if level then
                    ply:ChatPrint("[Admin Menu] Вы вошли как " .. level.Name)
                end
            end
        end
    end)
end)

-- Команды чата
hook.Add("PlayerSay", "AdminMenu_ChatCommands", function(ply, text, team)
    local args = string.Split(text, " ")
    local cmd = string.lower(args[1])
    
    -- Команда !admin
    if cmd == "!admin" or cmd == "/admin" then
        if AdminMenu:HasAccess(ply, "admin") then
            net.Start("AdminMenu_OpenMenu")
            net.Send(ply)
        else
            ply:ChatPrint("[Admin Menu] У вас нет доступа к админ меню")
        end
        return ""
    end
end)

-- Запуск при загрузке
AdminMenu:Initialize()

print("[Admin Menu] Серверная часть загружена")