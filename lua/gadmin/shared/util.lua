GAdmin = GAdmin or {}
GAdmin.Util = GAdmin.Util or {}

function GAdmin.Util.SafeNick(ply)
    if not IsValid(ply) then return "<invalid>" end
    local n = ply:Nick() or "<unnamed>"
    return string.sub(n:gsub("%c", " "), 1, 32)
end

function GAdmin.Util.CanTarget(admin, target)
    if not IsValid(admin) or not IsValid(target) then return false end
    if admin == target then return true end
    -- Simple fallback using IsAdmin/IsSuperAdmin
    if admin:IsSuperAdmin() then return true end
    if admin:IsAdmin() and not target:IsAdmin() then return true end
    return false
end
