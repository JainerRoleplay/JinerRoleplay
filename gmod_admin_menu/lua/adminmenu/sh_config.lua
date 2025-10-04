AdminMenu = AdminMenu or {}

AdminMenu.Config = AdminMenu.Config or {
  -- If true, only superadmins can use the menu; otherwise admins can too
  UseSuperAdminOnly = false,
  -- Chat command to open the menu on client
  OpenChatCommand = "!admin"
}

-- Permission check; override via hook "AdminMenuCanUse(ply)" to customize
function AdminMenu.CanUse(ply)
  if not IsValid(ply) or not ply:IsPlayer() then return false end
  local hookResult = hook.Run("AdminMenuCanUse", ply)
  if hookResult ~= nil then return hookResult and true or false end
  if AdminMenu.Config.UseSuperAdminOnly then
    return ply:IsSuperAdmin()
  end
  return ply:IsAdmin()
end
