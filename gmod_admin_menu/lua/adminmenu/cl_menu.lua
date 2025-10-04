AdminMenu = AdminMenu or {}

local function requestPlayers()
  net.Start("adminmenu_request_players")
  net.SendToServer()
end

local playerListView
local frame

local function sendAction(action, entIndex, arg)
  if not action or not entIndex then return end
  net.Start("adminmenu_perform_action")
  net.WriteString(action)
  net.WriteUInt(entIndex, 16)
  if arg ~= nil then
    net.WriteBool(true)
    net.WriteString(tostring(arg))
  else
    net.WriteBool(false)
  end
  net.SendToServer()
end

local function getSelectedEntIndex()
  if not IsValid(playerListView) then return nil end
  local line = playerListView:GetSelectedLine()
  if not line then return nil end
  local row = playerListView:GetLine(line)
  if not row then return nil end
  return row.PlayerEntIndex
end

function AdminMenu.Open()
  if IsValid(frame) then frame:MakePopup() return end

  frame = vgui.Create("DFrame")
  frame:SetTitle("Админ Меню")
  frame:SetSize(760, 460)
  frame:Center()
  frame:MakePopup()

  playerListView = vgui.Create("DListView", frame)
  playerListView:Dock(LEFT)
  playerListView:SetWide(520)
  playerListView:AddColumn("Имя"):SetFixedWidth(200)
  playerListView:AddColumn("SteamID64"):SetFixedWidth(160)
  playerListView:AddColumn("Команда"):SetFixedWidth(100)
  playerListView:AddColumn("HP"):SetFixedWidth(40)
  playerListView:AddColumn("Админ")

  local rightPanel = vgui.Create("DPanel", frame)
  rightPanel:Dock(FILL)
  rightPanel:DockMargin(8, 0, 0, 0)

  local function addButton(text, onclick)
    local btn = vgui.Create("DButton", rightPanel)
    btn:SetText(text)
    btn:Dock(TOP)
    btn:DockMargin(0, 0, 0, 6)
    btn:SetTall(34)
    btn.DoClick = onclick
    return btn
  end

  addButton("Обновить", function()
    requestPlayers()
  end)

  addButton("Кикнуть", function()
    local entIndex = getSelectedEntIndex()
    if not entIndex then return end
    Derma_StringRequest("Кикнуть игрока", "Причина кика:", "", function(reason)
      sendAction("kick", entIndex, reason or "Kicked by admin")
    end)
  end)

  addButton("Убить", function()
    local entIndex = getSelectedEntIndex()
    if not entIndex then return end
    sendAction("slay", entIndex)
  end)

  addButton("Заморозить", function()
    local entIndex = getSelectedEntIndex()
    if not entIndex then return end
    sendAction("freeze", entIndex)
  end)

  addButton("Разморозить", function()
    local entIndex = getSelectedEntIndex()
    if not entIndex then return end
    sendAction("unfreeze", entIndex)
  end)

  addButton("Телепорт ко мне", function()
    local entIndex = getSelectedEntIndex()
    if not entIndex then return end
    sendAction("bring", entIndex)
  end)

  addButton("Телепорт к игроку", function()
    local entIndex = getSelectedEntIndex()
    if not entIndex then return end
    sendAction("goto", entIndex)
  end)

  -- Initial population
  requestPlayers()
end

net.Receive("adminmenu_send_players", function()
  if not IsValid(playerListView) then return end
  playerListView:Clear()
  local count = net.ReadUInt(8)
  for i = 1, count do
    local entIndex = net.ReadUInt(16)
    local nick = net.ReadString()
    local sid64 = net.ReadString()
    local teamName = net.ReadString()
    local hp = net.ReadUInt(8)
    local isAdmin = net.ReadBool()

    local line = playerListView:AddLine(nick, sid64, teamName, tostring(hp), isAdmin and "Да" or "Нет")
    line.PlayerEntIndex = entIndex
  end
end)

concommand.Add("admin_menu", function()
  AdminMenu.Open()
end)

hook.Add("OnPlayerChat", "AdminMenu_OpenChatCommand", function(ply, text)
  if ply ~= LocalPlayer() then return end
  if not AdminMenu or not AdminMenu.Config then return end
  local cmd = tostring(AdminMenu.Config.OpenChatCommand or "!admin"):lower()
  if tostring(text or ""):lower() == cmd then
    timer.Simple(0, function()
      AdminMenu.Open()
    end)
    return true -- suppress in chat
  end
end)
