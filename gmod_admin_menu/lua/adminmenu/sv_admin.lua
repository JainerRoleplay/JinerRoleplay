util.AddNetworkString("adminmenu_request_players")
util.AddNetworkString("adminmenu_send_players")
util.AddNetworkString("adminmenu_perform_action")

local function canActOnTarget(admin, target)
  if not IsValid(target) or not target:IsPlayer() then return false, "Цель не игрок" end
  if target == admin then return true end
  if target:IsSuperAdmin() and not admin:IsSuperAdmin() then
    return false, "Нельзя действовать на суперадмина"
  end
  return true
end

net.Receive("adminmenu_request_players", function(_, ply)
  if not AdminMenu or not AdminMenu.CanUse(ply) then return end

  local players = player.GetAll()
  net.Start("adminmenu_send_players")
  net.WriteUInt(#players, 8)
  for _, v in ipairs(players) do
    net.WriteUInt(v:EntIndex(), 16)
    net.WriteString(v:Nick() or "")
    net.WriteString(v:SteamID64() or "")
    net.WriteString(team.GetName(v:Team()) or "")
    net.WriteUInt(math.Clamp(v:Health() or 0, 0, 255), 8)
    net.WriteBool(v:IsAdmin())
  end
  net.Send(ply)
end)

local ACTIONS = {}

ACTIONS.kick = function(admin, target, arg)
  local ok, err = canActOnTarget(admin, target)
  if not ok then return false, err end
  local reason = tostring(arg or "Kicked by admin")
  target:Kick(reason)
  return true, "Кикнут: " .. (target:Nick() or "?")
end

ACTIONS.slay = function(admin, target)
  local ok, err = canActOnTarget(admin, target)
  if not ok then return false, err end
  if target:Alive() then target:Kill() end
  return true, "Убит: " .. (target:Nick() or "?")
end

ACTIONS.freeze = function(admin, target)
  local ok, err = canActOnTarget(admin, target)
  if not ok then return false, err end
  target:Freeze(true)
  return true, "Заморожен: " .. (target:Nick() or "?")
end

ACTIONS.unfreeze = function(admin, target)
  local ok, err = canActOnTarget(admin, target)
  if not ok then return false, err end
  target:Freeze(false)
  return true, "Разморожен: " .. (target:Nick() or "?")
end

local function findSafePosNear(origin, forward)
  origin = origin or Vector(0,0,0)
  forward = (forward and forward:GetNormalized()) or Vector(1,0,0)
  local offsets = { 40, 60, 80, 100 }
  for _, d in ipairs(offsets) do
    local pos = origin + forward * d + Vector(0,0,5)
    local tr = util.TraceHull({
      start = pos,
      endpos = pos,
      mins = Vector(-16, -16, 0),
      maxs = Vector(16, 16, 72),
      mask = MASK_PLAYERSOLID
    })
    if not tr.Hit then return pos end
  end
  return origin + Vector(0,0,5)
end

ACTIONS.bring = function(admin, target)
  local ok, err = canActOnTarget(admin, target)
  if not ok then return false, err end
  local pos = findSafePosNear(admin:GetPos(), admin:GetForward())
  target:SetPos(pos)
  return true, "Телепортирован к вам: " .. (target:Nick() or "?")
end

ACTIONS.goto = function(admin, target)
  local ok, err = canActOnTarget(admin, target)
  if not ok then return false, err end
  local pos = findSafePosNear(target:GetPos(), target:GetForward())
  admin:SetPos(pos)
  return true, "Телепортированы к: " .. (target:Nick() or "?")
end

net.Receive("adminmenu_perform_action", function(_, ply)
  if not AdminMenu or not AdminMenu.CanUse(ply) then return end
  local action = net.ReadString() or ""
  local entIndex = net.ReadUInt(16)
  local hasArg = net.ReadBool()
  local arg = hasArg and net.ReadString() or nil

  local target = Entity(entIndex)
  if not IsValid(target) or not target:IsPlayer() then
    if IsValid(ply) then ply:ChatPrint("[AdminMenu] Неверная цель") end
    return
  end

  local fn = ACTIONS[action]
  if not fn then
    if IsValid(ply) then ply:ChatPrint("[AdminMenu] Неизвестное действие: " .. tostring(action)) end
    return
  end

  local ok, msg = fn(ply, target, arg)
  if IsValid(ply) and msg then
    ply:ChatPrint("[AdminMenu] " .. msg)
  end
end)
