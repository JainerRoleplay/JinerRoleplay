-- Client-side Admin Menu
-- Клиентская часть админ меню

include("vgui/admin_menu.lua")

-- Открытие меню
net.Receive("AdminMenu_Open", function()
    if IsValid(AdminMenuFrame) then
        AdminMenuFrame:Remove()
    end
    
    OpenAdminMenu()
end)

-- Получение списка игроков
net.Receive("AdminMenu_SendPlayers", function()
    local players = net.ReadTable()
    
    if IsValid(AdminMenuFrame) and IsValid(AdminMenuFrame.PlayerList) then
        AdminMenuFrame:UpdatePlayerList(players)
    end
end)

-- Консольная команда для открытия меню
concommand.Add("adminmenu_open", function()
    RunConsoleCommand("adminmenu")
end)

print("[Admin Menu Client] Loaded successfully!")
