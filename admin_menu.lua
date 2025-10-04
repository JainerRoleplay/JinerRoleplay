-- Админ меню для Garry's Mod
-- Создано для управления сервером и игроками

AdminMenu = AdminMenu or {}
AdminMenu.Config = AdminMenu.Config or {}

-- Конфигурация админ меню
AdminMenu.Config.RankRequired = "admin" -- Минимальный ранг для доступа
AdminMenu.Config.MenuTitle = "Админ Меню"
AdminMenu.Config.MenuSize = {w = 800, h = 600}

-- Цвета для интерфейса
AdminMenu.Config.Colors = {
    Background = Color(40, 40, 40, 255),
    Header = Color(60, 60, 60, 255),
    Button = Color(70, 70, 70, 255),
    ButtonHover = Color(90, 90, 90, 255),
    Text = Color(255, 255, 255, 255),
    TextSecondary = Color(200, 200, 200, 255),
    Accent = Color(100, 150, 255, 255)
}

-- Создание админ меню
function AdminMenu:CreateMenu()
    if not LocalPlayer():IsAdmin() and not AdminMenu:CheckAccess() then
        chat.AddText(Color(255, 0, 0), "У вас нет доступа к админ меню!")
        return
    end

    if IsValid(self.Frame) then
        self.Frame:Remove()
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(AdminMenu.Config.MenuSize.w, AdminMenu.Config.MenuSize.h)
    frame:Center()
    frame:SetTitle(AdminMenu.Config.MenuTitle)
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:SetBackgroundColor(AdminMenu.Config.Colors.Background)

    -- Создание панели вкладок
    local propertySheet = vgui.Create("DPropertySheet", frame)
    propertySheet:Dock(FILL)
    propertySheet:DockMargin(5, 5, 5, 5)

    -- Добавление вкладок
    self:AddPlayerTab(propertySheet)
    self:AddServerTab(propertySheet)
    self:AddUtilityTab(propertySheet)
    self:AddSettingsTab(propertySheet)

    self.Frame = frame
end

-- Проверка доступа к админ меню
function AdminMenu:CheckAccess()
    -- Здесь можно добавить дополнительную логику проверки доступа
    -- Например, проверка пользовательских групп или рангов
    return true
end

-- Вкладка управления игроками
function AdminMenu:AddPlayerTab(propertySheet)
    local playerPanel = vgui.Create("DPanel")
    playerPanel:SetBackgroundColor(AdminMenu.Config.Colors.Background)

    local playerList = vgui.Create("DListView", playerPanel)
    playerList:Dock(FILL)
    playerList:DockMargin(5, 5, 5, 5)
    playerList:SetMultiSelect(false)
    playerList:AddColumn("Игрок"):SetWide(150)
    playerList:AddColumn("SteamID"):SetWide(150)
    playerList:AddColumn("Пинг"):SetWide(80)
    playerList:AddColumn("Ранг"):SetWide(100)

    -- Заполнение списка игроков
    for _, ply in ipairs(player.GetAll()) do
        playerList:AddLine(
            ply:Nick(),
            ply:SteamID(),
            ply:Ping(),
            ply:GetUserGroup() or "user"
        )
    end

    -- Кнопки действий с игроками
    local buttonPanel = vgui.Create("DPanel", playerPanel)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(5, 5, 5, 5)
    buttonPanel:SetTall(100)
    buttonPanel:SetBackgroundColor(AdminMenu.Config.Colors.Header)

    local kickBtn = AdminMenu:CreateButton(buttonPanel, "Кикнуть", 0, 0, 100, 30, function()
        local selected = playerList:GetSelectedLine()
        if selected then
            local ply = player.GetAll()[selected]
            if IsValid(ply) then
                RunConsoleCommand("ulx", "kick", ply:Nick())
            end
        end
    end)

    local banBtn = AdminMenu:CreateButton(buttonPanel, "Забанить", 110, 0, 100, 30, function()
        local selected = playerList:GetSelectedLine()
        if selected then
            local ply = player.GetAll()[selected]
            if IsValid(ply) then
                Derma_StringRequest("Бан", "Введите причину бана:", "", function(reason)
                    RunConsoleCommand("ulx", "ban", ply:SteamID(), "0", reason)
                end)
            end
        end
    end)

    local teleportBtn = AdminMenu:CreateButton(buttonPanel, "Телепорт ко мне", 220, 0, 120, 30, function()
        local selected = playerList:GetSelectedLine()
        if selected then
            local ply = player.GetAll()[selected]
            if IsValid(ply) then
                RunConsoleCommand("ulx", "teleport", ply:Nick(), LocalPlayer():Nick())
            end
        end
    end)

    local gotoBtn = AdminMenu:CreateButton(buttonPanel, "Перейти к игроку", 350, 0, 130, 30, function()
        local selected = playerList:GetSelectedLine()
        if selected then
            local ply = player.GetAll()[selected]
            if IsValid(ply) then
                RunConsoleCommand("ulx", "teleport", LocalPlayer():Nick(), ply:Nick())
            end
        end
    end)

    local slapBtn = AdminMenu:CreateButton(buttonPanel, "Шлепнуть", 0, 40, 100, 30, function()
        local selected = playerList:GetSelectedLine()
        if selected then
            local ply = player.GetAll()[selected]
            if IsValid(ply) then
                RunConsoleCommand("ulx", "slap", ply:Nick(), "10")
            end
        end
    end)

    local freezeBtn = AdminMenu:CreateButton(buttonPanel, "Заморозить", 110, 40, 100, 30, function()
        local selected = playerList:GetSelectedLine()
        if selected then
            local ply = player.GetAll()[selected]
            if IsValid(ply) then
                ply:Freeze(true)
                chat.AddText(Color(0, 255, 0), "Игрок заморожен: " .. ply:Nick())
            end
        end
    end)

    local unfreezeBtn = AdminMenu:CreateButton(buttonPanel, "Разморозить", 220, 40, 100, 30, function()
        local selected = playerList:GetSelectedLine()
        if selected then
            local ply = player.GetAll()[selected]
            if IsValid(ply) then
                ply:Freeze(false)
                chat.AddText(Color(0, 255, 0), "Игрок разморожен: " .. ply:Nick())
            end
        end
    end)

    propertySheet:AddSheet("Игроки", playerPanel, "icon16/user.png")
end

-- Вкладка управления сервером
function AdminMenu:AddServerTab(propertySheet)
    local serverPanel = vgui.Create("DPanel")
    serverPanel:SetBackgroundColor(AdminMenu.Config.Colors.Background)

    local scrollPanel = vgui.Create("DScrollPanel", serverPanel)
    scrollPanel:Dock(FILL)

    -- Команды сервера
    local commands = {
        {"Изменить карту", "changemap", "gm_construct"},
        {"Очистить карту", "ulx", "mapwipe"},
        {"Перезагрузить карту", "ulx", "maprestart"},
        {"Остановить сервер", "ulx", "stop"},
        {"Включить гравитацию", "sv_gravity", "600"},
        {"Выключить гравитацию", "sv_gravity", "0"},
        {"Включить коллизии", "physcannon_mega_enabled", "1"},
        {"Выключить коллизии", "physcannon_mega_enabled", "0"}
    }

    local y = 0
    for _, cmd in ipairs(commands) do
        local btn = AdminMenu:CreateButton(scrollPanel, cmd[1], 10, y, 200, 30, function()
            if cmd[2] == "changemap" then
                RunConsoleCommand("changelevel", cmd[3])
            else
                RunConsoleCommand(cmd[2], cmd[3])
            end
        end)
        y = y + 40
    end

    -- Поле для кастомных команд
    local commandLabel = vgui.Create("DLabel", scrollPanel)
    commandLabel:SetText("Кастомная команда:")
    commandLabel:SetPos(220, 10)
    commandLabel:SetColor(AdminMenu.Config.Colors.Text)
    commandLabel:SizeToContents()

    local commandEntry = vgui.Create("DTextEntry", scrollPanel)
    commandEntry:SetPos(220, 30)
    commandEntry:SetSize(200, 25)
    commandEntry:SetPlaceholderText("Введите команду...")

    local executeBtn = AdminMenu:CreateButton(scrollPanel, "Выполнить", 430, 25, 80, 35, function()
        local command = commandEntry:GetValue()
        if command and command != "" then
            LocalPlayer():ConCommand(command)
            commandEntry:SetValue("")
        end
    end)

    propertySheet:AddSheet("Сервер", serverPanel, "icon16/server.png")
end

-- Вкладка утилит
function AdminMenu:AddUtilityTab(propertySheet)
    local utilityPanel = vgui.Create("DPanel")
    utilityPanel:SetBackgroundColor(AdminMenu.Config.Colors.Background)

    local scrollPanel = vgui.Create("DScrollPanel", utilityPanel)
    scrollPanel:Dock(FILL)

    -- Утилиты
    local utilities = {
        {"God Mode", function()
            RunConsoleCommand("ulx", "god", LocalPlayer():Nick())
        end},
        {"Noclip", function()
            RunConsoleCommand("ulx", "noclip", LocalPlayer():Nick())
        end},
        {"Невидимка", function()
            RunConsoleCommand("ulx", "invisible", LocalPlayer():Nick())
        end},
        {"Супер скорость", function()
            RunConsoleCommand("ulx", "hp", LocalPlayer():Nick(), "1000")
        end},
        {"Бесконечные патроны", function()
            RunConsoleCommand("ulx", "ammo", LocalPlayer():Nick(), "999999")
        end}
    }

    local y = 0
    for _, util in ipairs(utilities) do
        local btn = AdminMenu:CreateButton(scrollPanel, util[1], 10, y, 200, 30, util[2])
        y = y + 40
    end

    -- Спавн меню
    local spawnLabel = vgui.Create("DLabel", scrollPanel)
    spawnLabel:SetText("Спавн NPC/Entity:")
    spawnLabel:SetPos(220, 10)
    spawnLabel:SetColor(AdminMenu.Config.Colors.Text)
    spawnLabel:SizeToContents()

    local spawnEntry = vgui.Create("DTextEntry", scrollPanel)
    spawnEntry:SetPos(220, 30)
    spawnEntry:SetSize(200, 25)
    spawnEntry:SetPlaceholderText("Название NPC/Entity...")

    local spawnBtn = AdminMenu:CreateButton(scrollPanel, "Спавн", 430, 25, 80, 35, function()
        local entity = spawnEntry:GetValue()
        if entity and entity != "" then
            RunConsoleCommand("ulx", "spawn", entity)
            spawnEntry:SetValue("")
        end
    end)

    propertySheet:AddSheet("Утилиты", utilityPanel, "icon16/wrench.png")
end

-- Вкладка настроек
function AdminMenu:AddSettingsTab(propertySheet)
    local settingsPanel = vgui.Create("DPanel")
    settingsPanel:SetBackgroundColor(AdminMenu.Config.Colors.Background)

    local scrollPanel = vgui.Create("DScrollPanel", settingsPanel)
    scrollPanel:Dock(FILL)

    -- Настройки сервера
    local settings = {
        {"sv_cheats", "1"},
        {"sv_gravity", "600"},
        {"sv_airaccelerate", "10"},
        {"sv_alltalk", "1"},
        {"sv_voiceenable", "1"}
    }

    local y = 0
    for _, setting in ipairs(settings) do
        local label = vgui.Create("DLabel", scrollPanel)
        label:SetText(setting[1] .. ":")
        label:SetPos(10, y + 5)
        label:SetColor(AdminMenu.Config.Colors.Text)
        label:SizeToContents()

        local entry = vgui.Create("DTextEntry", scrollPanel)
        entry:SetPos(150, y)
        entry:SetSize(100, 25)
        entry:SetValue(setting[2])

        local applyBtn = AdminMenu:CreateButton(scrollPanel, "Применить", 260, y, 80, 25, function()
            RunConsoleCommand(setting[1], entry:GetValue())
        end)

        y = y + 35
    end

    propertySheet:AddSheet("Настройки", settingsPanel, "icon16/cog.png")
end

-- Функция создания кнопки
function AdminMenu:CreateButton(parent, text, x, y, w, h, onClick)
    local button = vgui.Create("DButton", parent)
    button:SetText(text)
    button:SetPos(x, y)
    button:SetSize(w, h)
    button:SetColor(AdminMenu.Config.Colors.Text)
    button.Paint = function(self, w, h)
        local col = self:IsHovered() and AdminMenu.Config.Colors.ButtonHover or AdminMenu.Config.Colors.Button
        draw.RoundedBox(4, 0, 0, w, h, col)
    end

    button.DoClick = onClick
    return button
end

-- Команда для открытия админ меню
concommand.Add("admin_menu", function()
    AdminMenu:CreateMenu()
end)

-- Автоматическая загрузка при подключении к серверу
hook.Add("InitPostEntity", "AdminMenu_Load", function()
    if LocalPlayer():IsAdmin() or AdminMenu:CheckAccess() then
        chat.AddText(Color(0, 255, 0), "Админ меню доступно! Используйте команду: admin_menu")
    end
end)

print("Админ меню загружено успешно!")