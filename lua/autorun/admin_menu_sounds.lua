-- Advanced Admin Menu - Звуки и эффекты
-- Звуковые уведомления для админских действий

AdminMenu.Sounds = AdminMenu.Sounds or {}

-- Таблица звуков
AdminMenu.Sounds.List = {
    kick = "buttons/button10.wav",
    ban = "buttons/button11.wav", 
    teleport = "ambient/levels/labs/teleport_mechanism_windup4.wav",
    freeze = "ambient/levels/citadel/weapon_disintegrate2.wav",
    unfreeze = "ambient/levels/citadel/weapon_disintegrate4.wav",
    admin_join = "ambient/alarms/klaxon1.wav",
    notification = "buttons/lightswitch2.wav",
    error = "buttons/button2.wav",
    success = "buttons/button3.wav"
}

-- Воспроизведение звука
function AdminMenu:PlaySound(soundName, target, excludeAdmin)
    if not self.Config.Settings.EnableSounds then return end
    
    local soundFile = self.Sounds.List[soundName]
    if not soundFile then return end
    
    if SERVER then
        if target and IsValid(target) then
            -- Звук для конкретного игрока
            target:EmitSound(soundFile, 75, 100)
        elseif excludeAdmin then
            -- Звук для всех кроме админа
            for _, ply in ipairs(player.GetAll()) do
                if ply ~= excludeAdmin then
                    ply:EmitSound(soundFile, 75, 100)
                end
            end
        else
            -- Звук для всех админов
            for _, ply in ipairs(player.GetAll()) do
                if self:HasAccess(ply, "admin") then
                    ply:EmitSound(soundFile, 75, 100)
                end
            end
        end
    else
        -- Клиент
        surface.PlaySound(soundFile)
    end
end

-- Хуки для автоматического воспроизведения звуков
if SERVER then
    -- Звук при входе админа
    hook.Add("PlayerInitialSpawn", "AdminMenu_AdminJoinSound", function(ply)
        timer.Simple(3, function()
            if IsValid(ply) and AdminMenu:GetPlayerAdmin(ply) then
                AdminMenu:PlaySound("admin_join")
            end
        end)
    end)
    
    -- Переопределяем функции команд для добавления звуков
    local originalExecuteCommand = AdminMenu.ExecuteCommand
    function AdminMenu:ExecuteCommand(admin, command, args)
        local success, result = originalExecuteCommand(self, admin, command, args)
        
        if success then
            -- Воспроизводим соответствующий звук
            if self.Sounds.List[command] then
                self:PlaySound(command)
            else
                self:PlaySound("success")
            end
        else
            self:PlaySound("error", admin)
        end
        
        return success, result
    end
end

print("[Admin Menu] Звуковая система загружена")