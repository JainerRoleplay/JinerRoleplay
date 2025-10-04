-- Примеры использования админ меню
-- Этот файл демонстрирует различные возможности админ меню

if CLIENT then
    -- Пример кастомизации интерфейса
    hook.Add("AdminMenuCreated", "CustomAdminMenu", function()
        -- Здесь можно добавить кастомные элементы в интерфейс
        print("Админ меню создано!")
    end)

    -- Пример добавления кастомной кнопки
    hook.Add("AdminMenuAddTabs", "AddCustomTab", function(propertySheet)
        local customPanel = vgui.Create("DPanel")
        customPanel:SetBackgroundColor(Color(50, 50, 50, 255))

        local customButton = vgui.Create("DButton", customPanel)
        customButton:SetText("Кастомная функция")
        customButton:SetPos(10, 10)
        customButton:SetSize(200, 30)
        customButton.DoClick = function()
            chat.AddText(Color(255, 100, 255), "Кастомная функция выполнена!")
        end

        propertySheet:AddSheet("Кастом", customPanel, "icon16/star.png")
    end)

    -- Пример добавления кастомной команды чата
    AdminMenu.ChatCommands.Commands["!custom"] = {
        description = "Кастомная команда",
        func = function(ply, args)
            chat.AddText(Color(255, 100, 255), "Кастомная команда выполнена игроком: " .. ply:Nick())
            return "Команда выполнена!"
        end,
        adminOnly = false
    }
end

-- Пример серверных хуков для логирования
if SERVER then
    -- Логирование подключений игроков
    hook.Add("PlayerInitialSpawn", "LogPlayerJoin", function(ply)
        AdminMenu.Logging:Log("INFO", "Игрок подключился: " .. ply:Nick(), nil, ply)
    end)

    -- Логирование отключений игроков
    hook.Add("PlayerDisconnected", "LogPlayerLeave", function(ply)
        AdminMenu.Logging:Log("INFO", "Игрок отключился: " .. ply:Nick(), nil, ply)
    end)

    -- Логирование смертей игроков
    hook.Add("PlayerDeath", "LogPlayerDeath", function(victim, inflictor, attacker)
        local weapon = "world"
        if IsValid(attacker) and attacker:IsPlayer() then
            weapon = attacker:GetActiveWeapon():GetClass()
        end

        AdminMenu.Logging:Log("WARNING", "Игрок убит: " .. victim:Nick() .. " оружием " .. weapon, attacker, victim)
    end)
end

-- Пример автоматической очистки карты каждые 10 минут
if SERVER then
    timer.Create("AutoCleanup", 600, 0, function()
        AdminMenu.Server:Cleanup()
        AdminMenu.Logging:LogServerAction("АВТОМАТИЧЕСКАЯ ОЧИСТКА КАРТЫ")
    end)
end

-- Пример добавления новых энтити в список спавна
AdminMenu.Utilities.CommonEntities = AdminMenu.Utilities.CommonEntities or {}
table.insert(AdminMenu.Utilities.CommonEntities, "npc_helicopter")
table.insert(AdminMenu.Utilities.CommonEntities, "npc_combinegunship")
table.insert(AdminMenu.Utilities.CommonEntities, "npc_strider")
table.insert(AdminMenu.Utilities.CommonEntities, "npc_antlionguard")

-- Пример добавления новых пропов
AdminMenu.Utilities.CommonProps = AdminMenu.Utilities.CommonProps or {}
table.insert(AdminMenu.Utilities.CommonProps, "models/props_vehicles/truck001a.mdl")
table.insert(AdminMenu.Utilities.CommonProps, "models/props_vehicles/ambulance.mdl")
table.insert(AdminMenu.Utilities.CommonProps, "models/props_vehicles/firetruck.mdl")

-- Пример кастомной функции телепортации
function AdminMenu:TeleportToRandomLocation(ply)
    local randomSpots = {
        Vector(0, 0, 100),
        Vector(1000, 0, 100),
        Vector(0, 1000, 100),
        Vector(-1000, 0, 100),
        Vector(0, -1000, 100),
        Vector(1000, 1000, 100),
        Vector(-1000, -1000, 100),
        Vector(1000, -1000, 100),
        Vector(-1000, 1000, 100)
    }

    local randomPos = randomSpots[math.random(#randomSpots)]
    ply:SetPos(randomPos)

    chat.AddText(Color(255, 150, 100), "Телепортация в случайное место!")
    AdminMenu.Logging:LogUtilityAction("СЛУЧАЙНАЯ ТЕЛЕПОРТАЦИЯ", ply)
end

-- Добавление команды для случайной телепортации
AdminMenu.ChatCommands.Commands["!randomteleport"] = {
    description = "Телепортация в случайное место",
    func = function(ply, args)
        AdminMenu:TeleportToRandomLocation(ply)
        return "Телепортирован в случайное место!"
    end,
    adminOnly = false
}

-- Пример кастомного события
function AdminMenu:CreateCustomEvent()
    for _, ply in ipairs(player.GetAll()) do
        ply:ChatPrint("Внимание! Специальное событие начинается!")
        ply:EmitSound("ambient/alarms/klaxon1.wav")

        -- Даем всем игрокам оружие
        timer.Simple(2, function()
            AdminMenu.Utilities:GiveWeapon("weapon_shotgun", 50)
        end)
    end

    AdminMenu.Logging:LogServerAction("КАСТОМНОЕ СОБЫТИЕ ЗАПУЩЕНО")
end

-- Команда для запуска кастомного события
AdminMenu.ChatCommands.Commands["!event"] = {
    description = "Запустить специальное событие",
    func = function(ply, args)
        AdminMenu:CreateCustomEvent()
        return "Специальное событие запущено!"
    end,
    adminOnly = true
}

print("Файл примеров использования загружен!")