-- Networking channels for GAdmin
if SERVER then
    util.AddNetworkString("gadmin_request_action")
    util.AddNetworkString("gadmin_action_result")
    util.AddNetworkString("gadmin_request_players")
    util.AddNetworkString("gadmin_players_list")
end

GAdmin = GAdmin or {}
GAdmin.Net = GAdmin.Net or {}

function GAdmin.Net.SendAction(action, target, args)
    net.Start("gadmin_request_action")
        net.WriteString(action)
        net.WriteEntity(target or NULL)
        net.WriteTable(args or {})
    net.SendToServer()
end

function GAdmin.Net.RequestPlayers()
    net.Start("gadmin_request_players")
    net.SendToServer()
end
