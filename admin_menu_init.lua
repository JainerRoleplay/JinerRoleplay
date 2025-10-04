-- Файл инициализации админ меню
-- Загружает все модули и подготавливает систему

print("Загрузка админ меню для Garry's Mod...")

-- Загрузка конфигурации
if SERVER then
    include("admin_menu_config.lua")
    AddCSLuaFile("admin_menu_config.lua")
else
    include("admin_menu_config.lua")
end

-- Загрузка модулей
local modules = {
    "admin_menu_logging.lua",
    "admin_menu_players.lua",
    "admin_menu_server.lua",
    "admin_menu_utilities.lua",
    "admin_menu_chat.lua"
}

for _, module in ipairs(modules) do
    if SERVER then
        include(module)
        AddCSLuaFile(module)
        print("Загружен серверный модуль: " .. module)
    else
        include(module)
        print("Загружен клиентский модуль: " .. module)
    end
end

-- Загрузка основного файла админ меню
if CLIENT then
    include("admin_menu.lua")
    print("Загружен основной файл админ меню")
end

-- Функция для полной перезагрузки админ меню
function AdminMenu:Reload()
    print("Перезагрузка админ меню...")

    -- Очистка старых данных
    if self.Frame and IsValid(self.Frame) then
        self.Frame:Remove()
    end

    -- Перезагрузка модулей
    for _, module in ipairs(modules) do
        if CLIENT then
            include(module)
        end
    end

    if CLIENT then
        include("admin_menu.lua")
    end

    print("Админ меню перезагружено!")
end

-- Команда для перезагрузки
concommand.Add("admin_reload", function()
    AdminMenu:Reload()
end)

-- Информация о версии
AdminMenu.Version = "1.0.0"
AdminMenu.Author = "AI Assistant"

-- Проверка на обновления (если нужно)
function AdminMenu:CheckForUpdates()
    -- Здесь можно добавить проверку обновлений
    -- Например, через HTTP запрос к серверу обновлений
    print("Проверка обновлений...")
end

-- Сообщение об успешной загрузке
hook.Add("InitPostEntity", "AdminMenu_Loaded", function()
    if CLIENT then
        chat.AddText(Color(100, 255, 100), "Админ меню версии " .. AdminMenu.Version .. " загружено!")
        chat.AddText(Color(200, 200, 200), "Используйте !admin для открытия меню или !help для списка команд")

        -- Автоматическая проверка обновлений
        timer.Simple(5, function()
            AdminMenu:CheckForUpdates()
        end)
    end
end)

print("Админ меню полностью загружено!")
print("Версия: " .. AdminMenu.Version)
print("Автор: " .. AdminMenu.Author)