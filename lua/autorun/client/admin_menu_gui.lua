-- Advanced Admin Menu - Клиентская часть
-- GUI и интерфейс админ меню

AdminMenu = AdminMenu or {}
AdminMenu.GUI = AdminMenu.GUI or {}

-- Сетевые сообщения
if SERVER then
    util.AddNetworkString("AdminMenu_OpenMenu")
    util.AddNetworkString("AdminMenu_ExecuteCommand")
    util.AddNetworkString("AdminMenu_GetPlayerList")
    util.AddNetworkString("AdminMenu_GetBanList")
    util.AddNetworkString("AdminMenu_PlayerMuted")
    util.AddNetworkString("AdminMenu_PlayerUnmuted")
end

if CLIENT then
    -- Локализация
    AdminMenu.Language = {
        ["menu_title"] = "Админ Меню",
        ["players"] = "Игроки",
        ["bans"] = "Баны", 
        ["settings"] = "Настройки",
        ["logs"] = "Логи",
        ["kick"] = "Кикнуть",
        ["ban"] = "Забанить",
        ["teleport"] = "ТП к игроку",
        ["bring"] = "Притащить",
        ["freeze"] = "Заморозить",
        ["unfreeze"] = "Разморозить",
        ["mute"] = "Замутить",
        ["unmute"] = "Размутить",
        ["god"] = "Режим Бога",
        ["noclip"] = "Ноклип",
        ["reason"] = "Причина",
        ["duration"] = "Длительность (мин)",
        ["execute"] = "Выполнить",
        ["close"] = "Закрыть",
        ["refresh"] = "Обновить",
        ["player_name"] = "Имя игрока",
        ["steamid"] = "SteamID",
        ["actions"] = "Действия",
        ["ban_reason"] = "Причина бана",
        ["ban_duration"] = "Длительность",
        ["banned_by"] = "Забанил",
        ["ban_date"] = "Дата бана",
        ["unban"] = "Разбанить"
    }
    
    -- Получение перевода
    function AdminMenu:GetPhrase(key)
        return self.Language[key] or key
    end
    
    -- Главное меню
    function AdminMenu:OpenMainMenu()
        if IsValid(self.GUI.MainFrame) then
            self.GUI.MainFrame:Remove()
        end
        
        -- Главное окно
        local frame = vgui.Create("DFrame")
        frame:SetTitle(self:GetPhrase("menu_title"))
        frame:SetSize(900, 600)
        frame:Center()
        frame:SetDeleteOnClose(true)
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)
        frame:MakePopup()
        
        self.GUI.MainFrame = frame
        
        -- Стиль окна
        frame.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 35, 240))
            draw.RoundedBox(8, 2, 2, w-4, h-4, Color(45, 45, 45, 200))
            
            -- Заголовок
            draw.RoundedBoxEx(8, 4, 4, w-8, 25, Color(25, 25, 25, 200), true, true, false, false)
        end
        
        -- Панель вкладок
        local tabs = vgui.Create("DPropertySheet", frame)
        tabs:SetPos(10, 35)
        tabs:SetSize(frame:GetWide() - 20, frame:GetTall() - 45)
        
        -- Стиль вкладок
        tabs.Paint = function() end
        
        -- Вкладка "Игроки"
        local playersPanel = self:CreatePlayersPanel()
        tabs:AddSheet(self:GetPhrase("players"), playersPanel, "icon16/user.png")
        
        -- Вкладка "Баны"
        local bansPanel = self:CreateBansPanel()
        tabs:AddSheet(self:GetPhrase("bans"), bansPanel, "icon16/exclamation.png")
        
        -- Вкладка "Настройки"
        local settingsPanel = self:CreateSettingsPanel()
        tabs:AddSheet(self:GetPhrase("settings"), settingsPanel, "icon16/cog.png")
        
        -- Вкладка "Логи"
        local logsPanel = self:CreateLogsPanel()
        tabs:AddSheet(self:GetPhrase("logs"), logsPanel, "icon16/page_white_text.png")
    end
    
    -- Панель игроков
    function AdminMenu:CreatePlayersPanel()
        local panel = vgui.Create("DPanel")
        panel.Paint = function() end
        
        -- Список игроков
        local playerList = vgui.Create("DListView", panel)
        playerList:SetPos(10, 10)
        playerList:SetSize(500, panel:GetTall() - 20)
        playerList:SetMultiSelect(false)
        
        playerList:AddColumn(self:GetPhrase("player_name"))
        playerList:AddColumn(self:GetPhrase("steamid"))
        playerList:AddColumn("Пинг")
        
        -- Стиль списка
        playerList.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 25, 150))
        end
        
        -- Панель команд
        local commandPanel = vgui.Create("DPanel", panel)
        commandPanel:SetPos(520, 10)
        commandPanel:SetSize(panel:GetWide() - 530, panel:GetTall() - 20)
        commandPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 25, 150))
        end
        
        -- Заголовок команд
        local commandTitle = vgui.Create("DLabel", commandPanel)
        commandTitle:SetText(self:GetPhrase("actions"))
        commandTitle:SetPos(10, 10)
        commandTitle:SetFont("DermaDefaultBold")
        commandTitle:SizeToContents()
        
        local yPos = 40
        
        -- Кнопки команд
        local commands = {
            {self:GetPhrase("kick"), "kick", Color(255, 100, 100)},
            {self:GetPhrase("ban"), "ban", Color(255, 50, 50)},
            {self:GetPhrase("teleport"), "goto", Color(100, 150, 255)},
            {self:GetPhrase("bring"), "bring", Color(100, 200, 100)},
            {self:GetPhrase("freeze"), "freeze", Color(150, 150, 255)},
            {self:GetPhrase("unfreeze"), "unfreeze", Color(200, 255, 150)},
            {self:GetPhrase("mute"), "mute", Color(255, 200, 100)},
            {self:GetPhrase("unmute"), "unmute", Color(200, 255, 200)},
            {self:GetPhrase("god"), "god", Color(255, 255, 100)},
            {self:GetPhrase("noclip"), "noclip", Color(200, 200, 255)}
        }
        
        for _, cmd in ipairs(commands) do
            local btn = vgui.Create("DButton", commandPanel)
            btn:SetText(cmd[1])
            btn:SetPos(10, yPos)
            btn:SetSize(commandPanel:GetWide() - 20, 25)
            
            btn.Paint = function(s, w, h)
                local col = s:IsHovered() and Color(cmd[3].r + 20, cmd[3].g + 20, cmd[3].b + 20) or cmd[3]
                draw.RoundedBox(4, 0, 0, w, h, col)
            end
            
            btn.DoClick = function()
                local selected = playerList:GetSelectedLine()
                if selected then
                    local line = playerList:GetLine(selected)
                    local playerName = line:GetColumnText(1)
                    self:ExecutePlayerCommand(cmd[2], playerName)
                else
                    chat.AddText(Color(255, 100, 100), "[Admin Menu] Выберите игрока")
                end
            end
            
            yPos = yPos + 30
        end
        
        -- Поля ввода для команд с параметрами
        yPos = yPos + 10
        
        -- Поле причины
        local reasonLabel = vgui.Create("DLabel", commandPanel)
        reasonLabel:SetText(self:GetPhrase("reason") .. ":")
        reasonLabel:SetPos(10, yPos)
        reasonLabel:SizeToContents()
        
        local reasonEntry = vgui.Create("DTextEntry", commandPanel)
        reasonEntry:SetPos(10, yPos + 20)
        reasonEntry:SetSize(commandPanel:GetWide() - 20, 20)
        reasonEntry:SetPlaceholderText("Введите причину...")
        
        yPos = yPos + 50
        
        -- Поле длительности
        local durationLabel = vgui.Create("DLabel", commandPanel)
        durationLabel:SetText(self:GetPhrase("duration") .. ":")
        durationLabel:SetPos(10, yPos)
        durationLabel:SizeToContents()
        
        local durationEntry = vgui.Create("DTextEntry", commandPanel)
        durationEntry:SetPos(10, yPos + 20)
        durationEntry:SetSize(commandPanel:GetWide() - 20, 20)
        durationEntry:SetPlaceholderText("60")
        durationEntry:SetNumeric(true)
        
        -- Сохраняем ссылки для доступа к полям
        panel.PlayerList = playerList
        panel.ReasonEntry = reasonEntry
        panel.DurationEntry = durationEntry
        
        -- Обновление списка игроков
        function panel:RefreshPlayers()
            playerList:Clear()
            for _, ply in ipairs(player.GetAll()) do
                local line = playerList:AddLine(ply:Nick(), ply:SteamID(), ply:Ping())
                line.Player = ply
            end
        end
        
        -- Кнопка обновления
        local refreshBtn = vgui.Create("DButton", panel)
        refreshBtn:SetText(self:GetPhrase("refresh"))
        refreshBtn:SetPos(10, panel:GetTall() - 35)
        refreshBtn:SetSize(100, 25)
        refreshBtn.DoClick = function()
            panel:RefreshPlayers()
        end
        
        -- Первоначальное заполнение
        panel:RefreshPlayers()
        
        return panel
    end
    
    -- Панель банов
    function AdminMenu:CreateBansPanel()
        local panel = vgui.Create("DPanel")
        panel.Paint = function() end
        
        -- Список банов
        local banList = vgui.Create("DListView", panel)
        banList:SetPos(10, 10)
        banList:SetSize(panel:GetWide() - 20, panel:GetTall() - 60)
        banList:SetMultiSelect(false)
        
        banList:AddColumn(self:GetPhrase("player_name"))
        banList:AddColumn(self:GetPhrase("steamid"))
        banList:AddColumn(self:GetPhrase("ban_reason"))
        banList:AddColumn(self:GetPhrase("ban_duration"))
        banList:AddColumn(self:GetPhrase("banned_by"))
        
        banList.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 25, 150))
        end
        
        -- Кнопка разбана
        local unbanBtn = vgui.Create("DButton", panel)
        unbanBtn:SetText(self:GetPhrase("unban"))
        unbanBtn:SetPos(10, panel:GetTall() - 40)
        unbanBtn:SetSize(100, 25)
        unbanBtn.Paint = function(s, w, h)
            local col = s:IsHovered() and Color(120, 255, 120) or Color(100, 200, 100)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        
        unbanBtn.DoClick = function()
            local selected = banList:GetSelectedLine()
            if selected then
                local line = banList:GetLine(selected)
                local steamid = line:GetColumnText(2)
                self:ExecuteCommand("unban", {steamid = steamid})
            else
                chat.AddText(Color(255, 100, 100), "[Admin Menu] Выберите бан для удаления")
            end
        end
        
        -- Кнопка обновления
        local refreshBtn = vgui.Create("DButton", panel)
        refreshBtn:SetText(self:GetPhrase("refresh"))
        refreshBtn:SetPos(120, panel:GetTall() - 40)
        refreshBtn:SetSize(100, 25)
        refreshBtn.DoClick = function()
            net.Start("AdminMenu_GetBanList")
            net.SendToServer()
        end
        
        panel.BanList = banList
        
        return panel
    end
    
    -- Панель настроек
    function AdminMenu:CreateSettingsPanel()
        local panel = vgui.Create("DPanel")
        panel.Paint = function() end
        
        local yPos = 20
        
        -- Заголовок
        local title = vgui.Create("DLabel", panel)
        title:SetText("Настройки Админ Меню")
        title:SetPos(20, yPos)
        title:SetFont("DermaLarge")
        title:SizeToContents()
        
        yPos = yPos + 40
        
        -- Быстрые команды
        local quickLabel = vgui.Create("DLabel", panel)
        quickLabel:SetText("Быстрые команды:")
        quickLabel:SetPos(20, yPos)
        quickLabel:SetFont("DermaDefaultBold")
        quickLabel:SizeToContents()
        
        yPos = yPos + 30
        
        local quickCommands = {
            {"Очистить чат", function() AdminMenu:ExecuteCommand("clearchat", {}) end},
            {"Перезапустить раунд", function() RunConsoleCommand("mp_restartgame", "1") end},
            {"Показать FPS всех игроков", function() RunConsoleCommand("net_graph", "1") end}
        }
        
        for _, cmd in ipairs(quickCommands) do
            local btn = vgui.Create("DButton", panel)
            btn:SetText(cmd[1])
            btn:SetPos(20, yPos)
            btn:SetSize(200, 25)
            btn.DoClick = cmd[2]
            
            btn.Paint = function(s, w, h)
                local col = s:IsHovered() and Color(80, 80, 80) or Color(60, 60, 60)
                draw.RoundedBox(4, 0, 0, w, h, col)
            end
            
            yPos = yPos + 30
        end
        
        return panel
    end
    
    -- Панель логов
    function AdminMenu:CreateLogsPanel()
        local panel = vgui.Create("DPanel")
        panel.Paint = function() end
        
        -- Список логов
        local logText = vgui.Create("DTextEntry", panel)
        logText:SetPos(10, 10)
        logText:SetSize(panel:GetWide() - 20, panel:GetTall() - 50)
        logText:SetMultiline(true)
        logText:SetEditable(false)
        logText:SetText("Логи будут отображаться здесь...")
        
        -- Кнопка обновления
        local refreshBtn = vgui.Create("DButton", panel)
        refreshBtn:SetText("Загрузить логи")
        refreshBtn:SetPos(10, panel:GetTall() - 35)
        refreshBtn:SetSize(100, 25)
        
        return panel
    end
    
    -- Выполнение команды для игрока
    function AdminMenu:ExecutePlayerCommand(command, playerName)
        local args = {target = playerName}
        
        -- Получаем дополнительные параметры из полей
        if IsValid(self.GUI.MainFrame) then
            local playersPanel = self.GUI.MainFrame:GetChildren()[1]:GetActiveTab():GetPanel()
            
            if IsValid(playersPanel.ReasonEntry) and playersPanel.ReasonEntry:GetValue() ~= "" then
                args.reason = playersPanel.ReasonEntry:GetValue()
            end
            
            if IsValid(playersPanel.DurationEntry) and playersPanel.DurationEntry:GetValue() ~= "" then
                args.duration = tonumber(playersPanel.DurationEntry:GetValue()) or 60
            end
        end
        
        self:ExecuteCommand(command, args)
    end
    
    -- Выполнение команды
    function AdminMenu:ExecuteCommand(command, args)
        net.Start("AdminMenu_ExecuteCommand")
        net.WriteString(command)
        net.WriteTable(args or {})
        net.SendToServer()
    end
    
    -- Сетевые функции
    net.Receive("AdminMenu_OpenMenu", function()
        AdminMenu:OpenMainMenu()
    end)
    
    net.Receive("AdminMenu_PlayerMuted", function()
        local duration = net.ReadUInt(32)
        chat.AddText(Color(255, 100, 100), "[Admin Menu] Вы замучены на " .. math.floor(duration / 60) .. " минут")
    end)
    
    net.Receive("AdminMenu_PlayerUnmuted", function()
        chat.AddText(Color(100, 255, 100), "[Admin Menu] Вы размучены")
    end)
    
    print("[Admin Menu] Клиентская часть загружена")
end