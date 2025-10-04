GAdmin = GAdmin or {}

local function getDefaultKey()
    if GAdmin and GAdmin.Config and GAdmin.Config.MenuBind then
        return GAdmin.Config.MenuBind
    end
    return KEY_F6
end

local BIND = CreateClientConVar("gadmin_menu_key", tostring(getDefaultKey()), true, false, "Key code to open GAdmin menu")

hook.Add("PlayerButtonDown", "GAdmin_OpenMenu_Key", function(ply, button)
    if not IsFirstTimePredicted() then return end
    if ply ~= LocalPlayer() then return end
    if button ~= tonumber(BIND:GetString()) then return end
    if not IsValid(LocalPlayer()) then return end
    if vgui and vgui.Create and GAdmin.OpenMenu then
        GAdmin.OpenMenu()
    end
end)
