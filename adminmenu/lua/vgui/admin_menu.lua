-- VGUI Admin Menu
-- Графический интерфейс админ меню

AdminMenuFrame = nil

function OpenAdminMenu()
    -- Создание основного окна
    local frame = vgui.Create("DFrame")
    frame:SetSize(900, 600)
    frame:Center()
    frame:SetTitle("Admin Menu - Админское Меню")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    AdminMenuFrame = frame
    
    -- Цветовая схема
    local colorPrimary = Color(41, 128, 185)
    local colorSecondary = Color(52, 73, 94)
    local colorBackground = Color(236, 240, 241)
    local colorDanger = Color(231, 76, 60)
    local colorSuccess = Color(46, 204, 113)
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colorBackground)
        draw.RoundedBox(0, 0, 0, w, 30, colorPrimary)
    end
    
    -- Боковая панель с категориями
    local sidebar = vgui.Create("DPanel", frame)
    sidebar:Dock(LEFT)
    sidebar:SetWide(200)
    sidebar.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, colorSecondary)
    end
    
    -- Основная панель
    local mainPanel = vgui.Create("DPanel", frame)
    mainPanel:Dock(FILL)
    mainPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255))
    end
    
    -- Текущая открытая панель
    local currentPanel = nil
    
    -- Функция для переключения панелей
    local function ShowPanel(panel)
        if IsValid(currentPanel) then
            currentPanel:Remove()
        end
        currentPanel = panel
        panel:SetParent(mainPanel)
        panel:Dock(FILL)
    end
    
    -- Кнопки категорий
    local function CreateCategoryButton(text, icon, clickFunc)
        local btn = vgui.Create("DButton", sidebar)
        btn:Dock(TOP)
        btn:DockMargin(5, 5, 5, 0)
        btn:SetTall(40)
        btn:SetText("")
        
        btn.Paint = function(self, w, h)
            local col = self:IsHovered() and colorPrimary or Color(44, 62, 80)
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText(text, "DermaDefault", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        btn.DoClick = clickFunc
        
        return btn
    end
    
    -- Панель управления игроками
    local function CreatePlayerPanel()
        local panel = vgui.Create("DPanel")
        panel.Paint = function(self, w, h) end
        
        -- Заголовок
        local header = vgui.Create("DLabel", panel)
        header:Dock(TOP)
        header:SetTall(40)
        header:SetText("Управление Игроками")
        header:SetFont("DermaLarge")
        header:SetContentAlignment(5)
        
        -- Кнопка обновления
        local refreshBtn = vgui.Create("DButton", panel)
        refreshBtn:Dock(TOP)
        refreshBtn:DockMargin(10, 5, 10, 5)
        refreshBtn:SetTall(30)
        refreshBtn:SetText("Обновить список игроков")
        refreshBtn.DoClick = function()
            net.Start("AdminMenu_GetPlayers")
            net.SendToServer()
        end
        
        -- Список игроков
        local playerList = vgui.Create("DListView", panel)
        playerList:Dock(FILL)
        playerList:DockMargin(10, 5, 10, 5)
        playerList:SetMultiSelect(false)
        playerList:AddColumn("Имя")
        playerList:AddColumn("SteamID")
        playerList:AddColumn("Здоровье")
        playerList:AddColumn("Броня")
        playerList:AddColumn("Пинг")
        
        frame.PlayerList = playerList
        
        -- Панель действий
        local actionPanel = vgui.Create("DPanel", panel)
        actionPanel:Dock(BOTTOM)
        actionPanel:SetTall(120)
        actionPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, colorBackground)
        end
        
        local actionLabel = vgui.Create("DLabel", actionPanel)
        actionLabel:Dock(TOP)
        actionLabel:SetTall(20)
        actionLabel:SetText("Действия с игроком:")
        actionLabel:DockMargin(5, 5, 5, 5)
        
        -- Функция отправки действия
        local function SendAction(action, extra)
            local selected = playerList:GetSelectedLine()
            if not selected then
                chat.AddText(Color(255, 0, 0), "[Admin Menu] Выберите игрока!")
                return
            end
            
            local line = playerList:GetLine(selected)
            local steamid = line:GetColumnText(2)
            
            net.Start("AdminMenu_Action")
            net.WriteString(action)
            net.WriteString(steamid)
            net.WriteString(extra or "")
            net.SendToServer()
        end
        
        -- Кнопки действий
        local btnContainer = vgui.Create("DPanel", actionPanel)
        btnContainer:Dock(FILL)
        btnContainer:DockMargin(5, 0, 5, 5)
        btnContainer.Paint = function() end
        
        local buttons = {
            {text = "Кикнуть", color = colorDanger, action = "kick"},
            {text = "Забанить", color = colorDanger, action = "ban"},
            {text = "Убить", color = colorDanger, action = "slay"},
            {text = "ТП к игроку", color = colorPrimary, action = "goto"},
            {text = "ТП к себе", color = colorPrimary, action = "bring"},
            {text = "Телепорт", color = colorPrimary, action = "teleport"},
            {text = "God Mode", color = colorSuccess, action = "god"},
            {text = "Noclip", color = colorSuccess, action = "noclip"},
            {text = "Заморозить", color = colorPrimary, action = "freeze"},
            {text = "Вылечить", color = colorSuccess, action = "heal"},
            {text = "Забрать оружие", color = colorDanger, action = "strip"},
            {text = "Возродить", color = colorSuccess, action = "respawn"},
        }
        
        local btnWidth = 110
        local btnHeight = 30
        local spacing = 5
        local x, y = 0, 0
        
        for i, btn in ipairs(buttons) do
            local button = vgui.Create("DButton", btnContainer)
            button:SetPos(x, y)
            button:SetSize(btnWidth, btnHeight)
            button:SetText(btn.text)
            
            button.Paint = function(self, w, h)
                local col = self:IsHovered() and Color(btn.color.r + 20, btn.color.g + 20, btn.color.b + 20) or btn.color
                draw.RoundedBox(4, 0, 0, w, h, col)
            end
            button.DoClick = function()
                if btn.action == "ban" then
                    Derma_StringRequest(
                        "Забанить игрока",
                        "Введите время бана (в минутах, 0 = навсегда):",
                        "0",
                        function(text) SendAction(btn.action, text) end
                    )
                elseif btn.action == "kick" then
                    Derma_StringRequest(
                        "Кикнуть игрока",
                        "Введите причину кика:",
                        "Kicked by admin",
                        function(text) SendAction(btn.action, text) end
                    )
                else
                    SendAction(btn.action)
                end
            end
            
            x = x + btnWidth + spacing
            if x + btnWidth > btnContainer:GetWide() then
                x = 0
                y = y + btnHeight + spacing
            end
        end
        
        -- Автоматическое обновление списка
        net.Start("AdminMenu_GetPlayers")
        net.SendToServer()
        
        return panel
    end
    
    -- Обновление списка игроков
    frame.UpdatePlayerList = function(self, players)
        if not IsValid(self.PlayerList) then return end
        
        self.PlayerList:Clear()
        
        for k, ply in pairs(players) do
            self.PlayerList:AddLine(
                ply.name,
                ply.steamid,
                ply.health,
                ply.armor,
                ply.ping
            )
        end
    end
    
    -- Панель сервера
    local function CreateServerPanel()
        local panel = vgui.Create("DPanel")
        panel.Paint = function(self, w, h) end
        
        local header = vgui.Create("DLabel", panel)
        header:Dock(TOP)
        header:SetTall(40)
        header:SetText("Управление Сервером")
        header:SetFont("DermaLarge")
        header:SetContentAlignment(5)
        
        -- Очистка карты
        local cleanupBtn = vgui.Create("DButton", panel)
        cleanupBtn:Dock(TOP)
        cleanupBtn:DockMargin(10, 10, 10, 5)
        cleanupBtn:SetTall(40)
        cleanupBtn:SetText("Очистить карту")
        cleanupBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(colorSuccess.r + 20, colorSuccess.g + 20, colorSuccess.b + 20) or colorSuccess
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        cleanupBtn.DoClick = function()
            net.Start("AdminMenu_Action")
            net.WriteString("cleanup")
            net.WriteString("")
            net.WriteString("")
            net.SendToServer()
        end
        
        -- Смена карты
        local mapBtn = vgui.Create("DButton", panel)
        mapBtn:Dock(TOP)
        mapBtn:DockMargin(10, 5, 10, 5)
        mapBtn:SetTall(40)
        mapBtn:SetText("Сменить карту")
        mapBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(colorPrimary.r + 20, colorPrimary.g + 20, colorPrimary.b + 20) or colorPrimary
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        mapBtn.DoClick = function()
            Derma_StringRequest(
                "Смена карты",
                "Введите название карты:",
                "gm_flatgrass",
                function(text)
                    net.Start("AdminMenu_Action")
                    net.WriteString("changemap")
                    net.WriteString("")
                    net.WriteString(text)
                    net.SendToServer()
                end
            )
        end
        
        -- Оповещение
        local broadcastBtn = vgui.Create("DButton", panel)
        broadcastBtn:Dock(TOP)
        broadcastBtn:DockMargin(10, 5, 10, 5)
        broadcastBtn:SetTall(40)
        broadcastBtn:SetText("Отправить оповещение")
        broadcastBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(colorPrimary.r + 20, colorPrimary.g + 20, colorPrimary.b + 20) or colorPrimary
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        broadcastBtn.DoClick = function()
            Derma_StringRequest(
                "Оповещение",
                "Введите сообщение для всех игроков:",
                "",
                function(text)
                    net.Start("AdminMenu_Action")
                    net.WriteString("broadcast")
                    net.WriteString("")
                    net.WriteString(text)
                    net.SendToServer()
                end
            )
        end
        
        -- Информация о сервере
        local infoPanel = vgui.Create("DPanel", panel)
        infoPanel:Dock(TOP)
        infoPanel:DockMargin(10, 20, 10, 5)
        infoPanel:SetTall(200)
        infoPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, colorBackground)
            
            local yPos = 10
            draw.SimpleText("Информация о сервере", "DermaDefaultBold", w/2, yPos, Color(0, 0, 0), TEXT_ALIGN_CENTER)
            yPos = yPos + 30
            
            draw.SimpleText("Карта: " .. game.GetMap(), "DermaDefault", 10, yPos, Color(0, 0, 0))
            yPos = yPos + 20
            
            draw.SimpleText("Игроки: " .. #player.GetAll() .. "/" .. game.MaxPlayers(), "DermaDefault", 10, yPos, Color(0, 0, 0))
            yPos = yPos + 20
            
            draw.SimpleText("Хостнейм: " .. GetHostName(), "DermaDefault", 10, yPos, Color(0, 0, 0))
            yPos = yPos + 20
            
            draw.SimpleText("Игровой режим: " .. engine.ActiveGamemode(), "DermaDefault", 10, yPos, Color(0, 0, 0))
        end
        
        return panel
    end
    
    -- Создание кнопок меню
    CreateCategoryButton("👥 Игроки", "icon16/group.png", function()
        ShowPanel(CreatePlayerPanel())
    end)
    
    CreateCategoryButton("🖥️ Сервер", "icon16/server.png", function()
        ShowPanel(CreateServerPanel())
    end)
    
    -- Показать панель игроков по умолчанию
    ShowPanel(CreatePlayerPanel())
end
