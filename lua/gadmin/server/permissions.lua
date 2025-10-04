GAdmin = GAdmin or {}
GAdmin.Permissions = GAdmin.Permissions or {}

local PERMS = {
    kick = "admin",
    ban = "superadmin",
    goto = "admin",
    bring = "admin",
    freeze = "admin",
    unfreeze = "admin",
    slap = "admin",
}

local function rankAllows(ply, need)
    if not IsValid(ply) then return false end
    if need == "user" then return true end
    if need == "admin" then return ply:IsAdmin() or ply:IsSuperAdmin() end
    if need == "superadmin" then return ply:IsSuperAdmin() end
    return false
end

function GAdmin.Permissions.Can(ply, action)
    local need = PERMS[action]
    if not need then return false end
    return rankAllows(ply, need)
end
