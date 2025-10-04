-- Advanced Admin Menu - Хотки и бинды
-- Система горячих клавиш для быстрого доступа к функциям

AdminMenu.Hotkeys = AdminMenu.Hotkeys or {}

if CLIENT then
    -- Переменные для хоткеев
    AdminMenu.Hotkeys.MenuKey = KEY_F4
    AdminMenu.Hotkeys.QuickCommands = {
        [KEY_F5] = "noclip", -- Быстрый ноклип
        [KEY_F6] = "god",    -- Быстрый режим бога
    }
    
    -- Загрузка настроек клавиш из конфига
    function AdminMenu:LoadHotkeys()
        -- Получаем настройку клавиши меню
        local menuKeyName = self.Config and self.Config.Settings and self.Config.Settings.MenuKey or "F4"
        self.Hotkeys.MenuKey = _G["KEY_" .. string.upper(menuKeyName)] or KEY_F4
    end
    
    -- Обработчик нажатий клавиш
    hook.Add("PlayerButtonDown", "AdminMenu_Hotkeys", function(ply, button)
        if ply ~= LocalPlayer() then return end
        
        -- Открытие меню
        if button == AdminMenu.Hotkeys.MenuKey then
            -- Проверяем права через сервер
            net.Start("AdminMenu_CheckAccess")
            net.SendToServer()
            return
        end
        
        -- Быстрые команды
        local quickCommand = AdminMenu.Hotkeys.QuickCommands[button]
        if quickCommand then
            AdminMenu:ExecuteCommand(quickCommand, {})
        end
    end)
    
    -- Сетевая проверка доступа
    net.Receive("AdminMenu_HasAccess", function()
        local hasAccess = net.ReadBool()
        if hasAccess then
            AdminMenu:OpenMainMenu()
        else
            chat.AddText(Color(255, 100, 100), "[Admin Menu] У вас нет доступа к админ меню")
        end
    end)
    
    -- GUI для настройки хоткеев
    function AdminMenu:OpenHotkeySettings()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Настройка горячих клавиш")
        frame:SetSize(400, 300)
        frame:Center()
        frame:MakePopup()
        
        local yPos = 30
        
        -- Настройка клавиши меню
        local menuLabel = vgui.Create("DLabel", frame)
        menuLabel:SetText("Клавиша меню:")
        menuLabel:SetPos(20, yPos)
        menuLabel:SizeToContents()
        
        local menuBinder = vgui.Create("DBinder", frame)
        menuBinder:SetPos(150, yPos)
        menuBinder:SetSize(100, 20)
        menuBinder:SetValue(AdminMenu.Hotkeys.MenuKey)
        
        menuBinder.OnChange = function(self, keyCode)
            AdminMenu.Hotkeys.MenuKey = keyCode
            -- Сохраняем настройку
            file.Write("admin_menu/client_hotkeys.txt", util.TableToJSON({MenuKey = keyCode}))
        end
        
        yPos = yPos + 40
        
        -- Настройка быстрых команд
        local quickLabel = vgui.Create("DLabel", frame)
        quickLabel:SetText("Быстрые команды:")
        quickLabel:SetPos(20, yPos)
        quickLabel:SetFont("DermaDefaultBold")
        quickLabel:SizeToContents()
        
        yPos = yPos + 30
        
        local quickCommands = {
            {"Ноклип", "noclip"},
            {"Режим бога", "god"}
        }
        
        for i, cmd in ipairs(quickCommands) do
            local cmdLabel = vgui.Create("DLabel", frame)
            cmdLabel:SetText(cmd[1] .. ":")
            cmdLabel:SetPos(20, yPos)
            cmdLabel:SizeToContents()
            
            local cmdBinder = vgui.Create("DBinder", frame)
            cmdBinder:SetPos(150, yPos)
            cmdBinder:SetSize(100, 20)
            
            -- Находим текущую привязку
            for key, command in pairs(AdminMenu.Hotkeys.QuickCommands) do
                if command == cmd[2] then
                    cmdBinder:SetValue(key)
                    break
                end
            end
            
            cmdBinder.OnChange = function(self, keyCode)
                -- Убираем старую привязку
                for key, command in pairs(AdminMenu.Hotkeys.QuickCommands) do
                    if command == cmd[2] then
                        AdminMenu.Hotkeys.QuickCommands[key] = nil
                        break
                    end
                end
                
                -- Добавляем новую
                AdminMenu.Hotkeys.QuickCommands[keyCode] = cmd[2]
                
                -- Сохраняем
                file.Write("admin_menu/client_hotkeys.txt", util.TableToJSON({
                    MenuKey = AdminMenu.Hotkeys.MenuKey,
                    QuickCommands = AdminMenu.Hotkeys.QuickCommands
                }))
            end
            
            yPos = yPos + 30
        end
        
        -- Кнопка сброса
        local resetBtn = vgui.Create("DButton", frame)
        resetBtn:SetText("Сбросить к умолчаниям")
        resetBtn:SetPos(20, frame:GetTall() - 60)
        resetBtn:SetSize(150, 25)
        resetBtn.DoClick = function()
            AdminMenu.Hotkeys.MenuKey = KEY_F4
            AdminMenu.Hotkeys.QuickCommands = {
                [KEY_F5] = "noclip",
                [KEY_F6] = "god"
            }
            
            file.Write("admin_menu/client_hotkeys.txt", util.TableToJSON({
                MenuKey = AdminMenu.Hotkeys.MenuKey,
                QuickCommands = AdminMenu.Hotkeys.QuickCommands
            }))
            
            frame:Close()
        end
    end
    
    -- Загрузка сохраненных хоткеев
    function AdminMenu:LoadSavedHotkeys()
        if file.Exists("admin_menu/client_hotkeys.txt", "DATA") then
            local content = file.Read("admin_menu/client_hotkeys.txt", "DATA")
            local data = util.JSONToTable(content)
            
            if data then
                if data.MenuKey then
                    self.Hotkeys.MenuKey = data.MenuKey
                end
                if data.QuickCommands then
                    self.Hotkeys.QuickCommands = data.QuickCommands
                end
            end
        end
    end
    
    -- Загружаем при старте
    hook.Add("InitPostEntity", "AdminMenu_LoadHotkeys", function()
        AdminMenu:LoadSavedHotkeys()
    end)
    
    -- Команда для открытия настроек хоткеев
    concommand.Add("admin_hotkey_settings", function()
        AdminMenu:OpenHotkeySettings()
    end)
end

if SERVER then
    -- Сетевые сообщения
    util.AddNetworkString("AdminMenu_CheckAccess")
    util.AddNetworkString("AdminMenu_HasAccess")
    
    -- Проверка доступа к меню
    net.Receive("AdminMenu_CheckAccess", function(len, ply)
        local hasAccess = AdminMenu:HasAccess(ply, "admin")
        
        net.Start("AdminMenu_HasAccess")
        net.WriteBool(hasAccess)
        net.Send(ply)
    end)
end

print("[Admin Menu] Система хоткеев загружена")