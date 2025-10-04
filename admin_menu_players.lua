-- Модуль управления игроками для админ меню
-- Содержит функции для работы с игроками

AdminMenu.Players = AdminMenu.Players or {}

function AdminMenu.Players:GetPlayerList()
    local players = {}
    for _, ply in ipairs(player.GetAll()) do
        table.insert(players, {
            name = ply:Nick(),
            steamid = ply:SteamID(),
            ping = ply:Ping(),
            rank = ply:GetUserGroup() or "user",
            entity = ply,
            team = ply:Team() or 0
        })
    end
    return players
end

function AdminMenu.Players:KickPlayer(ply, reason)
    if not IsValid(ply) then return false end

    reason = reason or "Кикнут администратором"
    ply:Kick(reason)

    chat.AddText(Color(255, 100, 100), "Игрок " .. ply:Nick() .. " был кикнут. Причина: " .. reason)
    return true
end

function AdminMenu.Players:BanPlayer(ply, reason, duration)
    if not IsValid(ply) then return false end

    duration = duration or 0 -- 0 = перманентный бан
    reason = reason or "Забанен администратором"

    RunConsoleCommand("ulx", "ban", ply:SteamID(), duration, reason)

    chat.AddText(Color(255, 50, 50), "Игрок " .. ply:Nick() .. " был забанен на " .. duration .. " минут. Причина: " .. reason)
    return true
end

function AdminMenu.Players:TeleportPlayer(ply, target)
    if not IsValid(ply) or not IsValid(target) then return false end

    ply:SetPos(target:GetPos())
    chat.AddText(Color(100, 255, 100), ply:Nick() .. " телепортирован к " .. target:Nick())
    return true
end

function AdminMenu.Players:FreezePlayer(ply, freeze)
    if not IsValid(ply) then return false end

    ply:Freeze(freeze)
    local action = freeze and "заморожен" or "разморожен"
    chat.AddText(Color(100, 200, 255), ply:Nick() .. " " .. action)
    return true
end

function AdminMenu.Players:SlapPlayer(ply, damage)
    if not IsValid(ply) then return false end

    damage = damage or 10

    local vel = ply:GetVelocity()
    vel.z = vel.z + 300
    ply:SetVelocity(vel)

    ply:TakeDamage(damage, LocalPlayer(), LocalPlayer())

    chat.AddText(Color(255, 150, 100), ply:Nick() .. " получил шлепок (" .. damage .. " урона)")
    return true
end

function AdminMenu.Players:GodMode(ply, enable)
    if not IsValid(ply) then return false end

    ply:GodEnable(enable)
    local action = enable and "включен" or "выключен"
    chat.AddText(Color(255, 255, 100), "God Mode для " .. ply:Nick() .. " " .. action)
    return true
end

function AdminMenu.Players:Noclip(ply, enable)
    if not IsValid(ply) then return false end

    ply:SetMoveType(enable and MOVETYPE_NOCLIP or MOVETYPE_WALK)
    local action = enable and "включен" or "выключен"
    chat.AddText(Color(150, 150, 255), "Noclip для " .. ply:Nick() .. " " .. action)
    return true
end

function AdminMenu.Players:Invisible(ply, enable)
    if not IsValid(ply) then return false end

    ply:SetNoDraw(enable)
    ply:DrawShadow(not enable)

    local action = enable and "включена" or "выключена"
    chat.AddText(Color(200, 200, 200), "Невидимка для " .. ply:Nick() .. " " .. action)
    return true
end

function AdminMenu.Players:BringPlayer(ply)
    if not IsValid(ply) then return false end

    ply:SetPos(LocalPlayer():GetPos() + Vector(50, 0, 0))
    chat.AddText(Color(100, 255, 150), ply:Nick() .. " телепортирован к вам")
    return true
end

function AdminMenu.Players:GotoPlayer(ply)
    if not IsValid(ply) then return false end

    LocalPlayer():SetPos(ply:GetPos() + Vector(0, 50, 0))
    chat.AddText(Color(100, 255, 150), "Вы телепортированы к " .. ply:Nick())
    return true
end

print("Модуль управления игроками загружен!")