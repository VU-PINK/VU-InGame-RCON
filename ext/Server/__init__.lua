local RCONManagerServer = class('RCONManagerServer')

function RCONManagerServer:__init()
    if g_Prints then
        print("Initialising RCONManagerServer")
    end
    self:RegisterEvents()
end

function RCONManagerServer:RegisterEvents()
    if g_Prints then
        print("Registering Events")
    end
    NetEvents:Subscribe("RCONManager:SendToServer", self, self.OnCommandReceived)
end

function RCONManagerServer:OnCommandReceived(p_Player, p_Command, p_Args)
    if g_Prints then
        print("Received Command: " .. p_Command .. "from " .. p_Player.name)
    end
    
    local s_ServerReturn = RCON:SendCommand(p_Command, p_Args)

    if s_ServerReturn ~= nil then
        RCONManagerServer:CheckFollowUp(p_Player, p_Command, s_ServerReturn)
    end
end

function RCONManagerServer:CheckFollowUp(p_Player, p_Command, p_ServerReturn)
    if g_Prints then
        print("Checking Follow Up Command: " .. p_Command .. "from " .. p_Player.name)
    end

    if p_Command == "banList.add" or p_Command == "baneList.remove" then
        RCON:SendCommand("banList.save")
    elseif p_Command == "mapList.add" or p_Command == "mapList.remove" then
        RCON:SendCommand("mapList.save")
    else
        for _, l_Return in pairs(p_ServerReturn) do
            if p_ServerReturn ~= "OK" then
                ChatManager:SendMessage("Set " .. p_Command .. " to " .. l_Return, p_Player)
            end
        end
    end
end

-- Singleton.
if g_RCONManagerServer == nil then
	g_RCONManagerServer = RCONManagerServer()
end

return g_RCONManagerServer