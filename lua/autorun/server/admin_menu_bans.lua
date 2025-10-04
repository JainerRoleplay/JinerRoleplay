-- Advanced Admin Menu - Система банов
-- Управление банами игроков

AdminMenu.Bans = AdminMenu.Bans or {}

-- Загрузка банов
function AdminMenu:LoadBans()
    local banFile = "admin_menu/bans.json"
    if file.Exists(banFile, "DATA") then
        local content = file.Read(banFile, "DATA")
        local bans = util.JSONToTable(content)
        if bans then
            self.Bans = bans
        end
    end
end

-- Сохранение банов
function AdminMenu:SaveBans()
    if not self.Config.Settings.SaveBans then return end
    
    local banFile = "admin_menu/bans.json"
    local json = util.TableToJSON(self.Bans, true)
    file.Write(banFile, json)
end

-- Бан игрока
function AdminMenu:BanPlayer(ply, duration, reason, admin)
    local steamid = ply:SteamID()
    local steamid64 = ply:SteamID64()
    local nick = ply:Nick()
    local ip = ply:IPAddress()
    
    local banData = {
        steamid = steamid,
        steamid64 = steamid64,
        nick = nick,
        ip = ip,
        reason = reason,
        duration = duration, -- в минутах
        banned_at = os.time(),
        unban_at = os.time() + (duration * 60),
        banned_by = IsValid(admin) and admin:Nick() or "Console",
        admin_steamid = IsValid(admin) and admin:SteamID() or "CONSOLE"
    }
    
    self.Bans[steamid] = banData
    self:SaveBans()
    
    -- Кикаем игрока
    local banMessage = string.format("Вы забанены!\nПричина: %s\nДлительность: %d минут\nАдминистратор: %s", 
        reason, duration, banData.banned_by)
    
    ply:Kick(banMessage)
    
    -- Уведомляем админов
    self:BroadcastAction(string.format("%s забанил %s на %d минут (%s)", 
        banData.banned_by, nick, duration, reason))
end

-- Разбан игрока
function AdminMenu:UnbanPlayer(steamid, admin)
    if not self.Bans[steamid] then
        return false
    end
    
    local banData = self.Bans[steamid]
    self.Bans[steamid] = nil
    self:SaveBans()
    
    -- Уведомляем админов
    local adminName = IsValid(admin) and admin:Nick() or "Console"
    self:BroadcastAction(string.format("%s разбанил %s", adminName, banData.nick))
    
    return true
end

-- Проверка бана при входе
function AdminMenu:CheckPlayerBan(steamid, nick, ip)
    local banData = self.Bans[steamid]
    if not banData then return nil end
    
    -- Проверяем, не истек ли бан
    if os.time() >= banData.unban_at then
        self.Bans[steamid] = nil
        self:SaveBans()
        return nil
    end
    
    local timeLeft = banData.unban_at - os.time()
    local hoursLeft = math.floor(timeLeft / 3600)
    local minutesLeft = math.floor((timeLeft % 3600) / 60)
    
    local banMessage = string.format([[Вы забанены на сервере!

Причина: %s
Администратор: %s
Забанен: %s
Разбан через: %d ч. %d мин.]], 
        banData.reason, 
        banData.banned_by,
        os.date("%d.%m.%Y %H:%M", banData.banned_at),
        hoursLeft, minutesLeft)
    
    return banMessage
end

-- Получение списка банов
function AdminMenu:GetBans()
    local activeBans = {}
    local currentTime = os.time()
    
    for steamid, banData in pairs(self.Bans) do
        if currentTime < banData.unban_at then
            table.insert(activeBans, banData)
        else
            -- Удаляем истекшие баны
            self.Bans[steamid] = nil
        end
    end
    
    self:SaveBans()
    return activeBans
end

-- Мут система
AdminMenu.Mutes = AdminMenu.Mutes or {}

-- Мут игрока
function AdminMenu:MutePlayer(ply, duration, admin)
    local steamid = ply:SteamID()
    
    local muteData = {
        steamid = steamid,
        nick = ply:Nick(),
        duration = duration,
        muted_at = os.time(),
        unmute_at = os.time() + (duration * 60),
        muted_by = IsValid(admin) and admin:Nick() or "Console"
    }
    
    self.Mutes[steamid] = muteData
    
    ply:ChatPrint(string.format("[Admin Menu] Вы замучены на %d минут. Причина: мут администратором", duration))
    
    -- Отправляем клиенту информацию о муте
    net.Start("AdminMenu_PlayerMuted")
    net.WriteUInt(duration * 60, 32) -- в секундах
    net.Send(ply)
end

-- Размут игрока
function AdminMenu:UnmutePlayer(ply, admin)
    local steamid = ply:SteamID()
    
    if not self.Mutes[steamid] then
        return false
    end
    
    self.Mutes[steamid] = nil
    
    ply:ChatPrint("[Admin Menu] Вы размучены администратором")
    
    net.Start("AdminMenu_PlayerUnmuted")
    net.Send(ply)
    
    return true
end

-- Проверка мута
function AdminMenu:IsPlayerMuted(ply)
    local steamid = ply:SteamID()
    local muteData = self.Mutes[steamid]
    
    if not muteData then return false end
    
    if os.time() >= muteData.unmute_at then
        self.Mutes[steamid] = nil
        return false
    end
    
    return true
end

-- Хуки для системы банов
hook.Add("CheckPassword", "AdminMenu_BanCheck", function(steamID64, ipAddress, svPassword, clPassword, name)
    local steamid = util.SteamIDFrom64(steamID64)
    local banMessage = AdminMenu:CheckPlayerBan(steamid, name, ipAddress)
    
    if banMessage then
        return false, banMessage
    end
end)

-- Хук для блокировки чата замученных игроков
hook.Add("PlayerSay", "AdminMenu_MuteCheck", function(ply, text, team)
    if AdminMenu:IsPlayerMuted(ply) then
        ply:ChatPrint("[Admin Menu] Вы не можете писать в чат - вы замучены")
        return ""
    end
end)

-- Загрузка банов при старте
AdminMenu:LoadBans()

print("[Admin Menu] Система банов загружена")