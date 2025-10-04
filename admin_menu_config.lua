-- Конфигурационный файл для админ меню
-- Здесь можно настроить различные параметры

AdminMenu.Config = AdminMenu.Config or {}

-- Основные настройки
AdminMenu.Config.Enabled = true -- Включить/выключить админ меню
AdminMenu.Config.RankRequired = "admin" -- Минимальный ранг для доступа
AdminMenu.Config.MenuTitle = "Админ Панель" -- Заголовок меню
AdminMenu.Config.MenuSize = {w = 850, h = 650} -- Размер окна

-- Цветовая схема
AdminMenu.Config.Colors = {
    Background = Color(45, 45, 45, 255),
    Header = Color(65, 65, 65, 255),
    Panel = Color(55, 55, 55, 255),
    Button = Color(75, 75, 75, 255),
    ButtonHover = Color(95, 95, 95, 255),
    ButtonPressed = Color(115, 115, 115, 255),
    Text = Color(255, 255, 255, 255),
    TextSecondary = Color(200, 200, 200, 255),
    TextDisabled = Color(150, 150, 150, 255),
    Accent = Color(100, 150, 255, 255),
    Success = Color(100, 255, 100, 255),
    Warning = Color(255, 200, 100, 255),
    Error = Color(255, 100, 100, 255),
    Info = Color(100, 200, 255, 255)
}

-- Настройки функциональности
AdminMenu.Config.Features = {
    PlayerManagement = true, -- Управление игроками
    ServerManagement = true, -- Управление сервером
    Utilities = true,        -- Утилиты
    Settings = true,         -- Настройки
    SpawnMenu = true,        -- Меню спавна
    TeleportMenu = true,     -- Меню телепортации
    BanMenu = true,          -- Меню банов
    Logs = true              -- Логи действий
}

-- Команды для ULX (если используется)
AdminMenu.Config.ULXCommands = {
    Kick = "ulx kick",
    Ban = "ulx ban",
    Teleport = "ulx teleport",
    Slap = "ulx slap",
    God = "ulx god",
    Noclip = "ulx noclip",
    Invisible = "ulx invisible",
    HP = "ulx hp",
    Ammo = "ulx ammo",
    Spawn = "ulx spawn",
    MapRestart = "ulx maprestart",
    MapWipe = "ulx mapwipe",
    Stop = "ulx stop"
}

-- Настройки спавна
AdminMenu.Config.SpawnSettings = {
    DefaultPosition = Vector(0, 0, 100), -- Позиция спавна по умолчанию
    SpawnDistance = 150,                  -- Расстояние от игрока для спавна
    MaxSpawns = 50,                      -- Максимальное количество спавнов
    CleanupTime = 300                     -- Время очистки в секундах
}

-- Настройки телепортации
AdminMenu.Config.TeleportSettings = {
    SavePositions = true,     -- Сохранять позиции
    MaxSavedPositions = 10,   -- Максимум сохраненных позиций
    TeleportDelay = 0.5       -- Задержка телепортации
}

-- Список карт для быстрого доступа
AdminMenu.Config.MapList = {
    "gm_construct",
    "gm_flatgrass",
    "gm_bigcity",
    "gm_genesis",
    "ttt_minecraft_b5",
    "ttt_67thway_v4",
    "ttt_community_pool",
    "ttt_fastfood_a6"
}

-- Настройки логирования
AdminMenu.Config.Logging = {
    Enabled = true,           -- Включить логирование
    LogFile = "admin_menu.log", -- Файл для логов
    LogActions = true,        -- Логировать действия админов
    LogChat = true,           -- Логировать чат команды
    LogLevel = 2              -- Уровень логирования (1-3)
}

-- Горячие клавиши
AdminMenu.Config.KeyBindings = {
    OpenMenu = KEY_F3,        -- Открыть меню
    QuickTeleport = KEY_F4,   -- Быстрая телепортация
    QuickSpawn = KEY_F5       -- Быстрый спавн
}

-- Настройки производительности
AdminMenu.Config.Performance = {
    UpdateInterval = 0.5,     -- Интервал обновления (секунды)
    MaxPlayersShown = 50,     -- Максимум игроков в списке
    CacheTime = 5             -- Время кеширования данных
}

-- Функция для загрузки пользовательской конфигурации
function AdminMenu.Config:LoadUserConfig()
    -- Здесь можно загрузить настройки из файла или базы данных
    -- Например, если есть файл config.txt в data папке

    if file.Exists("admin_menu_config.txt", "DATA") then
        local configData = file.Read("admin_menu_config.txt", "DATA")
        if configData then
            local userConfig = util.JSONToTable(configData)
            if userConfig then
                table.Merge(self, userConfig)
                print("Пользовательская конфигурация загружена!")
            end
        end
    end
end

-- Функция для сохранения конфигурации
function AdminMenu.Config:SaveUserConfig()
    local configData = util.TableToJSON(self, true)
    file.Write("admin_menu_config.txt", configData)
    print("Конфигурация сохранена!")
end

-- Загрузка пользовательской конфигурации при старте
hook.Add("InitPostEntity", "AdminMenu_LoadConfig", function()
    AdminMenu.Config:LoadUserConfig()
end)

print("Конфигурационный файл админ меню загружен!")