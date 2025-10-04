GAdmin = GAdmin or {}

local function buildPlayerList(panel)
    panel:Clear()
    local list = vgui.Create("DListView", panel)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("Игроки")

    list.PlayerEnts = {}

    function list:Populate(ids, nicks)
        self:Clear()
        self.PlayerEnts = {}
        if not ids or not nicks then return end
        for i = 1, #ids do
            local ent = Entity(ids[i])
            local nick = nicks[i] or (IsValid(ent) and ent:Nick()) or ("#" .. tostring(ids[i]))
            local line = self:AddLine(nick)
            line.EntIndex = ids[i]
            self.PlayerEnts[ids[i]] = ent
        end
    end

    function list:GetSelectedPlayer()
        local line = self:GetSelectedLine() and self:GetLine(self:GetSelectedLine())
        if not line then return nil end
        local ent = Entity(line.EntIndex or -1)
        if not IsValid(ent) then return nil end
        return ent
    end

    return list
end

local function addActionButtons(container, getTarget)
    local function ensureTargetOrNotify()
        local target = getTarget()
        if not IsValid(target) then
            notification.AddLegacy("Выберите игрока", NOTIFY_ERROR, 3)
            surface.PlaySound("buttons/button10.wav")
            return nil
        end
        return target
    end

    local function addButton(text, onClick)
        local btn = vgui.Create("DButton", container)
        btn:SetText(text)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 6)
        btn.DoClick = function()
            local target = ensureTargetOrNotify()
            if not target then return end
            onClick(target)
        end
        return btn
    end

    addButton("Кикнуть", function(target)
        Derma_StringRequest("Кик", "Причина", "Админ кик", function(reason)
            GAdmin.Net.SendAction("kick", target, { reason = reason or "" })
        end)
    end)

    addButton("Бан...", function(target)
        Derma_StringRequest("Бан", "Минуты (например, 60)", "60", function(minStr)
            local minutes = tonumber(minStr) or 60
            Derma_StringRequest("Бан", "Причина", "Админ бан", function(reason)
                GAdmin.Net.SendAction("ban", target, { minutes = minutes, reason = reason or "" })
            end)
        end)
    end)

    addButton("Телепорт к", function(target)
        GAdmin.Net.SendAction("goto", target, {})
    end)

    addButton("Телепорт сюда", function(target)
        GAdmin.Net.SendAction("bring", target, {})
    end)

    addButton("Заморозить", function(target)
        GAdmin.Net.SendAction("freeze", target, {})
    end)

    addButton("Разморозить", function(target)
        GAdmin.Net.SendAction("unfreeze", target, {})
    end)

    addButton("Шлепнуть", function(target)
        GAdmin.Net.SendAction("slap", target, {})
    end)
end

function GAdmin.OpenMenu()
    if IsValid(GAdmin.MenuFrame) then
        GAdmin.MenuFrame:MakePopup()
        return
    end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("GAdmin - Админ меню")
    frame:SetSize(600, 400)
    frame:Center()
    frame:MakePopup()
    GAdmin.MenuFrame = frame

    local left = vgui.Create("DPanel", frame)
    left:Dock(LEFT)
    left:SetWide(300)
    left:DockMargin(8, 8, 4, 8)

    local right = vgui.Create("DPanel", frame)
    right:Dock(FILL)
    right:DockMargin(4, 8, 8, 8)

    local list = buildPlayerList(left)

    local refresh = vgui.Create("DButton", left)
    refresh:Dock(BOTTOM)
    refresh:SetText("Обновить список")
    refresh:DockMargin(0, 6, 0, 0)
    refresh.DoClick = function()
        GAdmin.Net.RequestPlayers()
    end

    addActionButtons(right, function()
        return list:GetSelectedPlayer()
    end)

    net.Receive("gadmin_players_list", function()
        local data = net.ReadTable() or {}
        local ids = data.ids or {}
        local nicks = data.nicks or {}
        list:Populate(ids, nicks)
    end)

    net.Receive("gadmin_action_result", function()
        local ok = net.ReadBool()
        local msg = net.ReadString() or ""
        if ok then
            notification.AddLegacy(msg, NOTIFY_GENERIC, 3)
            surface.PlaySound("buttons/button14.wav")
        else
            notification.AddLegacy(msg, NOTIFY_ERROR, 3)
            surface.PlaySound("buttons/button10.wav")
        end
    end)

    -- initial fetch
    GAdmin.Net.RequestPlayers()
end
