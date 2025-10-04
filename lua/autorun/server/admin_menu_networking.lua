-- Advanced Admin Menu - Сетевые функции сервера
-- Обработка запросов от клиентов

if SERVER then
    -- Сетевые сообщения уже объявлены в GUI файле
    
    -- Выполнение команды от клиента
    net.Receive("AdminMenu_ExecuteCommand", function(len, ply)
        local command = net.ReadString()
        local args = net.ReadTable()
        
        -- Проверяем права доступа
        if not AdminMenu:HasAccess(ply, command) then
            ply:ChatPrint("[Admin Menu] У вас нет прав на выполнение этой команды")
            return
        end
        
        -- Выполняем команду
        local success, result = AdminMenu:ExecuteCommand(ply, command, args)
        
        if success then
            ply:ChatPrint("[Admin Menu] " .. (result or "Команда выполнена"))
        else
            ply:ChatPrint("[Admin Menu] Ошибка: " .. (result or "Неизвестная ошибка"))
        end
    end)
    
    -- Запрос списка игроков
    net.Receive("AdminMenu_GetPlayerList", function(len, ply)
        if not AdminMenu:HasAccess(ply, "admin") then return end
        
        local playerData = {}
        for _, p in ipairs(player.GetAll()) do
            table.insert(playerData, {
                nick = p:Nick(),
                steamid = p:SteamID(),
                steamid64 = p:SteamID64(),
                ping = p:Ping(),
                admin = AdminMenu:GetPlayerAdmin(p)
            })
        end
        
        net.Start("AdminMenu_SendPlayerList")
        net.WriteTable(playerData)
        net.Send(ply)
    end)
    
    -- Запрос списка банов
    net.Receive("AdminMenu_GetBanList", function(len, ply)
        if not AdminMenu:HasAccess(ply, "admin") then return end
        
        local bans = AdminMenu:GetBans()
        
        net.Start("AdminMenu_SendBanList")
        net.WriteTable(bans)
        net.Send(ply)
    end)
    
    -- Дополнительные сетевые функции
    util.AddNetworkString("AdminMenu_SendPlayerList")
    util.AddNetworkString("AdminMenu_SendBanList")
    util.AddNetworkString("AdminMenu_NotifyAction")
    
    -- Уведомление о действии
    function AdminMenu:NotifyAction(message, recipient)
        net.Start("AdminMenu_NotifyAction")
        net.WriteString(message)
        if recipient then
            net.Send(recipient)
        else
            net.Broadcast()
        end
    end
end

if CLIENT then
    -- Получение списка игроков
    net.Receive("AdminMenu_SendPlayerList", function()
        local playerData = net.ReadTable()
        
        if IsValid(AdminMenu.GUI.MainFrame) then
            local playersPanel = AdminMenu.GUI.MainFrame:GetChildren()[1]:GetActiveTab():GetPanel()
            if playersPanel and playersPanel.PlayerList then
                playersPanel.PlayerList:Clear()
                
                for _, data in ipairs(playerData) do
                    local line = playersPanel.PlayerList:AddLine(data.nick, data.steamid, data.ping)
                    line.PlayerData = data
                    
                    -- Цветовая кодировка админов
                    if data.admin then
                        local adminLevel = AdminMenu.Config and AdminMenu.Config.AdminLevels[data.admin.group]
                        if adminLevel then
                            line:SetTextColor(adminLevel.Color or Color(255, 255, 255))
                        end
                    end
                end
            end
        end
    end)
    
    -- Получение списка банов
    net.Receive("AdminMenu_SendBanList", function()
        local bans = net.ReadTable()
        
        if IsValid(AdminMenu.GUI.MainFrame) then
            local tabs = AdminMenu.GUI.MainFrame:GetChildren()[1]
            for i = 1, tabs:GetNumTabs() do
                local tab = tabs:GetItems()[i]
                if tab.Tab:GetText() == "Баны" then
                    local bansPanel = tab.Panel
                    if bansPanel and bansPanel.BanList then
                        bansPanel.BanList:Clear()
                        
                        for _, ban in ipairs(bans) do
                            local timeLeft = ban.unban_at - os.time()
                            local duration = string.format("%d мин", math.floor(timeLeft / 60))
                            
                            bansPanel.BanList:AddLine(
                                ban.nick,
                                ban.steamid,
                                ban.reason,
                                duration,
                                ban.banned_by
                            )
                        end
                    end
                    break
                end
            end
        end
    end)
    
    -- Уведомления о действиях
    net.Receive("AdminMenu_NotifyAction", function()
        local message = net.ReadString()
        chat.AddText(Color(100, 200, 255), "[Admin Menu] ", Color(255, 255, 255), message)
    end)
end

print("[Admin Menu] Сетевые функции загружены")