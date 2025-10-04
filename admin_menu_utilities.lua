-- Модуль утилит для админ меню
-- Содержит различные полезные функции

AdminMenu.Utilities = AdminMenu.Utilities or {}

function AdminMenu.Utilities:SpawnEntity(entityClass, position, angles)
    if not entityClass or entityClass == "" then return false end

    position = position or LocalPlayer():GetPos() + Vector(0, 0, 50)
    angles = angles or Angle(0, 0, 0)

    local entity = ents.Create(entityClass)
    if not IsValid(entity) then return false end

    entity:SetPos(position)
    entity:SetAngles(angles)
    entity:Spawn()
    entity:Activate()

    chat.AddText(Color(100, 255, 100), "Создан энтити: " .. entityClass)
    return entity
end

function AdminMenu.Utilities:SpawnNPC(npcClass, position, equipment)
    if not npcClass or npcClass == "" then return false end

    position = position or LocalPlayer():GetPos() + Vector(0, 0, 50)
    equipment = equipment or {}

    local npc = ents.Create(npcClass)
    if not IsValid(npc) then return false end

    npc:SetPos(position)
    npc:Spawn()
    npc:Activate()

    -- Экипировка NPC
    if equipment.weapon then
        npc:Give(equipment.weapon)
    end

    if equipment.model then
        npc:SetModel(equipment.model)
    end

    chat.AddText(Color(100, 255, 150), "Создан NPC: " .. npcClass)
    return npc
end

function AdminMenu.Utilities:CreateProp(model, position, frozen)
    if not model or model == "" then return false end

    position = position or LocalPlayer():GetPos() + Vector(0, 0, 50)
    frozen = frozen or false

    local prop = ents.Create("prop_physics")
    if not IsValid(prop) then return false end

    prop:SetModel(model)
    prop:SetPos(position)
    prop:Spawn()
    prop:Activate()

    if frozen then
        local phys = prop:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end

    chat.AddText(Color(150, 255, 100), "Создан проп: " .. model)
    return prop
end

function AdminMenu.Utilities:GiveWeapon(weaponClass, ammo)
    if not weaponClass or weaponClass == "" then return false end

    ammo = ammo or 999

    LocalPlayer():Give(weaponClass)
    LocalPlayer():GiveAmmo(ammo, weaponClass)

    chat.AddText(Color(255, 150, 100), "Получено оружие: " .. weaponClass)
    return true
end

function AdminMenu.Utilities:GodMode(enable)
    LocalPlayer():GodEnable(enable)
    local action = enable and "включен" or "выключен"
    chat.AddText(Color(255, 255, 100), "God Mode " .. action)
    return true
end

function AdminPlayer():Noclip(enable)
    LocalPlayer():SetMoveType(enable and MOVETYPE_NOCLIP or MOVETYPE_WALK)
    local action = enable and "включен" or "выключен"
    chat.AddText(Color(150, 150, 255), "Noclip " .. action)
    return true
end

function AdminMenu.Utilities:Invisible(enable)
    LocalPlayer():SetNoDraw(enable)
    LocalPlayer():DrawShadow(not enable)

    local action = enable and "включена" or "выключена"
    chat.AddText(Color(200, 200, 200), "Невидимка " .. action)
    return true
end

function AdminMenu.Utilities:SpeedBoost(boost)
    boost = tonumber(boost) or 2

    local ply = LocalPlayer()
    local vel = ply:GetVelocity()
    ply:SetVelocity(vel * boost)

    chat.AddText(Color(255, 100, 255), "Скорость увеличена в " .. boost .. " раз")
    return true
end

function AdminMenu.Utilities:HealPlayer(ply, amount)
    ply = ply or LocalPlayer()
    amount = amount or 100

    ply:SetHealth(math.min(ply:Health() + amount, ply:GetMaxHealth()))

    chat.AddText(Color(100, 255, 100), ply:Nick() .. " вылечен на " .. amount .. " HP")
    return true
end

function AdminMenu.Utilities:TeleportToPosition(x, y, z)
    local position = Vector(tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0)
    LocalPlayer():SetPos(position)

    chat.AddText(Color(100, 255, 200), "Телепортация на позицию: " .. tostring(position))
    return true
end

function AdminMenu.Utilities:CreateExplosion(position, damage, radius)
    position = position or LocalPlayer():GetPos()
    damage = damage or 100
    radius = radius or 300

    local explosion = ents.Create("env_explosion")
    explosion:SetPos(position)
    explosion:Spawn()
    explosion:SetKeyValue("iMagnitude", tostring(damage))
    explosion:SetKeyValue("iRadiusOverride", tostring(radius))
    explosion:Fire("Explode", 0, 0)

    chat.AddText(Color(255, 100, 100), "Создан взрыв в позиции: " .. tostring(position))
    return true
end

function AdminMenu.Utilities:GetCommonEntities()
    local entities = {
        -- NPC
        "npc_citizen",
        "npc_combine_s",
        "npc_metropolice",
        "npc_zombie",
        "npc_headcrab",
        "npc_antlion",
        "npc_barnacle",
        "npc_manhack",
        "npc_rollermine",
        "npc_turret_floor",

        -- Пропы
        "prop_physics",
        "prop_dynamic",

        -- Другое
        "item_healthkit",
        "item_healthvial",
        "item_battery",
        "weapon_crowbar",
        "weapon_pistol",
        "weapon_smg1",
        "weapon_ar2",
        "weapon_shotgun",
        "weapon_crossbow",
        "weapon_rpg"
    }
    return entities
end

function AdminMenu.Utilities:GetCommonProps()
    local props = {
        "models/props_c17/oildrum001.mdl",
        "models/props_c17/concrete_barrier001a.mdl",
        "models/props_c17/gravestone003a.mdl",
        "models/props_c17/gravestone004a.mdl",
        "models/props_combine/breen_tube.mdl",
        "models/props_combine/breen_window.mdl",
        "models/props_combine/combine_door01.mdl",
        "models/props_junk/sawblade.mdl",
        "models/props_junk/trafficcone001a.mdl",
        "models/props_wasteland/barricade001a.mdl",
        "models/props_wasteland/barricade002a.mdl",
        "models/props_wasteland/medcabinet001a.mdl"
    }
    return props
end

print("Модуль утилит загружен!")