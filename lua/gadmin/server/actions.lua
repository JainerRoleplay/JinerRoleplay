GAdmin = GAdmin or {}
GAdmin.Actions = GAdmin.Actions or {}

local function sendResult(ply, ok, msg)
    net.Start("gadmin_action_result")
        net.WriteBool(ok)
        net.WriteString(msg or "")
    net.Send(ply)
end

local function handleKick(admin, target, args)
    if not IsValid(target) then return false, "Игрок не найден" end
    if not GAdmin.Util.CanTarget(admin, target) then return false, "Недостаточно прав" end
    local reason = tostring(args.reason or "Kicked by admin")
    target:Kick(reason)
    return true, "Игрок кикнут: " .. GAdmin.Util.SafeNick(target)
end

local function handleBan(admin, target, args)
    if not IsValid(target) then return false, "Игрок не найден" end
    if not GAdmin.Util.CanTarget(admin, target) then return false, "Недостаточно прав" end
    local minutes = tonumber(args.minutes or 60) or 60
    local reason = tostring(args.reason or "Banned by admin")
    if target.AddBan then
        target:AddBan(minutes, reason)
        target:Kick("Вы забанены: " .. reason)
        return true, "Игрок забанен: " .. GAdmin.Util.SafeNick(target)
    end
    -- Fallback if no ban system
    target:Kick("Бан (симуляция) на " .. minutes .. " мин: " .. reason)
    return true, "Игрок кикнут (бан симулирован)"
end

local function handleGoto(admin, target)
    if not IsValid(target) then return false, "Игрок не найден" end
    if not GAdmin.Util.CanTarget(admin, target) then return false, "Недостаточно прав" end
    admin:SetPos(target:GetPos() + Vector(0, 0, 10))
    return true, "Телепорт к " .. GAdmin.Util.SafeNick(target)
end

local function handleBring(admin, target)
    if not IsValid(target) then return false, "Игрок не найден" end
    if not GAdmin.Util.CanTarget(admin, target) then return false, "Недостаточно прав" end
    target:SetPos(admin:GetPos() + admin:GetForward() * 30)
    return true, "Телепортировал " .. GAdmin.Util.SafeNick(target)
end

local function handleFreeze(admin, target)
    if not IsValid(target) then return false, "Игрок не найден" end
    if not GAdmin.Util.CanTarget(admin, target) then return false, "Недостаточно прав" end
    target:Freeze(true)
    return true, "Заморозил " .. GAdmin.Util.SafeNick(target)
end

local function handleUnfreeze(admin, target)
    if not IsValid(target) then return false, "Игрок не найден" end
    if not GAdmin.Util.CanTarget(admin, target) then return false, "Недостаточно прав" end
    target:Freeze(false)
    return true, "Разморозил " .. GAdmin.Util.SafeNick(target)
end

local function handleSlap(admin, target)
    if not IsValid(target) then return false, "Игрок не найден" end
    if not GAdmin.Util.CanTarget(admin, target) then return false, "Недостаточно прав" end
    if target.SetVelocity then
        target:SetVelocity(Vector(0,0,300))
    end
    target:EmitSound("physics/body/body_medium_impact_hard1.wav")
    return true, "Шлёпнул " .. GAdmin.Util.SafeNick(target)
end

local ACTION_MAP = {
    kick = handleKick,
    ban = handleBan,
    goto = handleGoto,
    bring = handleBring,
    freeze = handleFreeze,
    unfreeze = handleUnfreeze,
    slap = handleSlap,
}

net.Receive("gadmin_request_action", function(_, admin)
    if not IsValid(admin) then return end
    local action = net.ReadString()
    local target = net.ReadEntity()
    local args = net.ReadTable() or {}

    if not GAdmin.Permissions.Can(admin, action) then
        sendResult(admin, false, "Нет прав на действие: " .. action)
        return
    end

    local handler = ACTION_MAP[action]
    if not handler then
        sendResult(admin, false, "Неизвестное действие: " .. tostring(action))
        return
    end

    local ok, msg = handler(admin, target, args)
    sendResult(admin, ok, msg)
end)

net.Receive("gadmin_request_players", function(_, admin)
    if not IsValid(admin) then return end
    local list = {}
    for _, ply in ipairs(player.GetAll()) do
        list[#list+1] = {
            sid = ply:SteamID() or "",
            nick = GAdmin.Util.SafeNick(ply),
            ent = ply -- entity cannot be net tabled to client directly; we'll send IDs
        }
    end
    -- We will send as separate arrays: entity indices and names
    net.Start("gadmin_players_list")
        local ids, nicks = {}, {}
        for _, ply in ipairs(player.GetAll()) do
            ids[#ids+1] = ply:EntIndex()
            nicks[#nicks+1] = GAdmin.Util.SafeNick(ply)
        end
        net.WriteTable({ids = ids, nicks = nicks})
    net.Send(admin)
end)
