-- Server-side Admin Menu
-- Админское меню для Garry's Mod

util.AddNetworkString("AdminMenu_Open")
util.AddNetworkString("AdminMenu_Action")
util.AddNetworkString("AdminMenu_GetPlayers")
util.AddNetworkString("AdminMenu_SendPlayers")

-- Список администраторов (SteamID64)
-- Добавьте свой SteamID сюда
local admins = {
    -- Пример: ["STEAM_0:1:12345678"] = true,
    ["SUPERADMIN"] = true -- Все супер-админы имеют доступ
}

-- Проверка, является ли игрок администратором
local function IsAdmin(ply)
    if ply:IsSuperAdmin() then return true end
    return admins[ply:SteamID()] or false
end

-- Открытие меню
concommand.Add("adminmenu", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not IsAdmin(ply) then
        ply:ChatPrint("[Admin Menu] У вас нет прав доступа!")
        return
    end
    
    net.Start("AdminMenu_Open")
    net.Send(ply)
end)

-- Получение списка игроков
net.Receive("AdminMenu_GetPlayers", function(len, ply)
    if not IsAdmin(ply) then return end
    
    local players = {}
    for k, v in pairs(player.GetAll()) do
        table.insert(players, {
            name = v:Nick(),
            steamid = v:SteamID(),
            userid = v:UserID(),
            health = v:Health(),
            armor = v:Armor(),
            ping = v:Ping()
        })
    end
    
    net.Start("AdminMenu_SendPlayers")
    net.WriteTable(players)
    net.Send(ply)
end)

-- Обработка действий
net.Receive("AdminMenu_Action", function(len, ply)
    if not IsAdmin(ply) then return end
    
    local action = net.ReadString()
    local target = net.ReadString()
    local extra = net.ReadString()
    
    local targetPly = nil
    
    -- Найти целевого игрока
    if target ~= "" then
        for k, v in pairs(player.GetAll()) do
            if v:SteamID() == target then
                targetPly = v
                break
            end
        end
    end
    
    -- Выполнить действие
    if action == "kick" and IsValid(targetPly) then
        local reason = extra ~= "" and extra or "Kicked by admin"
        targetPly:Kick(reason)
        ply:ChatPrint("[Admin Menu] Игрок " .. targetPly:Nick() .. " кикнут")
        
    elseif action == "ban" and IsValid(targetPly) then
        local time = tonumber(extra) or 0
        targetPly:Ban(time, "Banned by admin")
        ply:ChatPrint("[Admin Menu] Игрок " .. targetPly:Nick() .. " забанен на " .. time .. " минут")
        
    elseif action == "slay" and IsValid(targetPly) then
        targetPly:Kill()
        ply:ChatPrint("[Admin Menu] Игрок " .. targetPly:Nick() .. " убит")
        
    elseif action == "teleport" and IsValid(targetPly) then
        targetPly:SetPos(ply:GetEyeTrace().HitPos)
        ply:ChatPrint("[Admin Menu] Игрок " .. targetPly:Nick() .. " телепортирован")
        
    elseif action == "goto" and IsValid(targetPly) then
        ply:SetPos(targetPly:GetPos())
        ply:ChatPrint("[Admin Menu] Телепортация к " .. targetPly:Nick())
        
    elseif action == "bring" and IsValid(targetPly) then
        targetPly:SetPos(ply:GetPos() + Vector(50, 0, 0))
        ply:ChatPrint("[Admin Menu] Игрок " .. targetPly:Nick() .. " телепортирован к вам")
        
    elseif action == "god" and IsValid(targetPly) then
        if targetPly:HasGodMode() then
            targetPly:GodDisable()
            ply:ChatPrint("[Admin Menu] God mode выключен для " .. targetPly:Nick())
        else
            targetPly:GodEnable()
            ply:ChatPrint("[Admin Menu] God mode включен для " .. targetPly:Nick())
        end
        
    elseif action == "noclip" and IsValid(targetPly) then
        if targetPly:GetMoveType() == MOVETYPE_NOCLIP then
            targetPly:SetMoveType(MOVETYPE_WALK)
            ply:ChatPrint("[Admin Menu] Noclip выключен для " .. targetPly:Nick())
        else
            targetPly:SetMoveType(MOVETYPE_NOCLIP)
            ply:ChatPrint("[Admin Menu] Noclip включен для " .. targetPly:Nick())
        end
        
    elseif action == "freeze" and IsValid(targetPly) then
        if targetPly:IsFlagSet(FL_FROZEN) then
            targetPly:Freeze(false)
            ply:ChatPrint("[Admin Menu] Игрок " .. targetPly:Nick() .. " разморожен")
        else
            targetPly:Freeze(true)
            ply:ChatPrint("[Admin Menu] Игрок " .. targetPly:Nick() .. " заморожен")
        end
        
    elseif action == "heal" and IsValid(targetPly) then
        targetPly:SetHealth(targetPly:GetMaxHealth())
        targetPly:SetArmor(100)
        ply:ChatPrint("[Admin Menu] Игрок " .. targetPly:Nick() .. " вылечен")
        
    elseif action == "strip" and IsValid(targetPly) then
        targetPly:StripWeapons()
        ply:ChatPrint("[Admin Menu] Оружие убрано у " .. targetPly:Nick())
        
    elseif action == "respawn" and IsValid(targetPly) then
        targetPly:Spawn()
        ply:ChatPrint("[Admin Menu] Игрок " .. targetPly:Nick() .. " возрожден")
        
    -- Серверные команды
    elseif action == "changemap" then
        if extra ~= "" then
            RunConsoleCommand("changelevel", extra)
            ply:ChatPrint("[Admin Menu] Смена карты на " .. extra)
        end
        
    elseif action == "cleanup" then
        game.CleanUpMap()
        ply:ChatPrint("[Admin Menu] Карта очищена")
        
    elseif action == "broadcast" then
        if extra ~= "" then
            for k, v in pairs(player.GetAll()) do
                v:ChatPrint("[ADMIN] " .. extra)
            end
            ply:ChatPrint("[Admin Menu] Сообщение отправлено")
        end
    end
end)

print("[Admin Menu] Loaded successfully!")
