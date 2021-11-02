local RCONManager = class('RCONManager')

function RCONManager:__init()
    if g_Prints then
        print("Initialising RCONManager")
    end
    self:RegisterVars()
    self:RegisterEvents()
end

function RCONManager:RegisterVars()
    if g_Prints then
        print("Registering Vars")
    end

    self.m_PlayerName = PlayerManager:GetLocalPlayer().name
    self.m_PlayerIsAdmin = false

    self.m_RCONCommands = {
        admin = {
            password = {"admin.password", "<password>"},
            say = {"admin.say", "<message, players>"},
            yell = {"admin.yell", "<message, duration, players>"},
            kick = {"admin.kickPlayer", "<soldier name, reason>"},
            move = {"admin.movePlayer", "<name, teamID, squadID, forceKill>"},
            kill = {"admin.killPlayer", "<name>"},
            ban = {"banList.add", "<id-type, id, timeout, reason>"},
            banRemove = {"banList.remove", "<id-type, id>"},
            banClear = {"banList.clear", "Clears the Banlist"},
            banList = {"banList.list", "Lists all banned players"},
            temporaryAdminAdd = {"temporaryAdmin.add", "<name>"},
            temporaryAdminRemove = {"temporaryAdmin.remove", "<name>"},
            listRCONAdmins = {"temporaryAdmin.list", " "}
        },
        maps = {
            add = {"mapList.add", "<map, gamemode, rounds, offset>"},
            remove = {"mapList.remove", "<index>"},
            clear = {"mapList.clear", "- Clears the maplist"},
            list = {"mapList.list", "<startIndex>"},
            nextMap = {"mapList.setNextMapIndex", "<index>"},
            getMaps = {"mapList.getMapIndices", " - Get indices for current & next map"},
            getRounds = {"mapList.getRounds", " - Get current round and number of rounds"},
            endRound = {"mapList.endRound", "<teamID> - End Current round, declaring the specified team as winners"},
            runNext = {"mapList.runNextRound", " - Run the next round"},
            restartRound = {"mapList.restartRound", " - Restart the current round"}
        },
        vars = {
            serverName = {"vars.serverName", "<name>"},
            password = {"vars.gamePassword", "<password>"},
            roundStartPlayerCount = {"vars.roundStartPlayerCount", "<numPlayers>"},
            roundRestartPlayerCount = {"vars.roundRestartPlayerCount", "<numPlayers>"},
            preRound = {"vars.roundLockdownCountdown", "<time> - Set duration of pre-round"},
            serverMessage = {"vars.serverMessage", "<message>"},
            friendlyfire = {"vars.friendlyFire", "<true/false>"},
            maxPlayers = {"vars.maxPlayers", "<numPlayers>"},
            serverDesc = {"vars.serverDescription", "<description>"},
            killCam = {"vars.killCam", "<true/false>"},
            miniMap = {"vars.miniMap", "<true/false>"},
            hud = {"vars.hud", "<true/false>"},
            crossHair = {"vars.crossHair", "<true/false>"},
            Spotting = {"vars.3dSpotting", "<true/false>"},
            miniMapSpotting = {"vars.miniMapSpotting", "<true/false>"},
            nameTag = {"vars.nameTag", "<true/false>"},
            thirdPersonCam = {"vars.3pCam", "<true/false>"},
            regenerateHealth = {"vars.regenerateHealth", "<true/false>"},
            teamKillCountForKick = {"vars.teamKillCountForKick", "<count>"},
            teamKillValueForKick = {"vars.teamKillValueForKick", "<count>"},
            teamKillKillValueIncrease = {"vars.teamKillKillValueIncrease", "<count>"},
            teamKillKillValueDecreasePerSecond = {"vars.teamKillKillValueDecreasePerSecond", "<count>"},
            teamKillKickForBan = {"vars.teamKillKickForBan", "<count>"},
            idleTimeout = {"vars.idleTimeout", "<time>"},
            idleBanRounds = {"vars.idleBanRounds", "<true/false>"},
            vehicleSpawnAllowed = {"vars.vehicleSpawnAllowed", "<true/false>"},
            vehicleSpawnDelay = {"vars.vehicleSpawnDelay", "<percentage modifier>"},
            soldierHealth = {"vars.soldierHealth", "<percentage modifier>"},
            playerRespawnTime = {"vars.playerRespawnTime", "<percentage modifier>"},
            playerManDownTime = {"vars.playerManDownTime", "<percentage modifier>"},
            bulletDamage = {"vars.bulletDamage", "<percentage modifier>"},
            gameModeCounter = {"vars.gameModeCounter", "<integer> - Set Ticket Scale"},
            onlySquadLeaderSpawn = {"vars.onlySquadLeaderSpawn", "<true/false>"},
            unlockMode = {"vars.unlockMode", "<mode>"}
        },
        vu = {
            ColorCorrectionEnabled = {"vu.ColorCorrectionEnabled", "<true/false>"},
            DesertingAllowed = {"vu.DesertingAllowed", "true/false"},
            DestructionEnabled = {"vu.DestructionEnabled", "true/false"},
            FadeInAll = {"vu.FadeInAll", "- Fade in all Players"},
            FadeOutAll = {"vu.FadeOutAll", "- Fade out all Players"},
            FrequencyMode = {"vu.FrequencyMode", " - return frequency of server"},
            HighPerformanceReplication = {"vu.HighPerformanceReplication", "<true/false>"},
            ServerBanner = {"vu.ServerBanner", "<.jpg link>"},
            SetTeamTicketCount = {"vu.SetTeamTicketCount", "<team, amount>"},
            SpectatorCount = {"vu.SpectatorCount", " - return spec count"},
            SquadSize = {"vu.SquadSize", "<size>"},
            SunFlareEnabled = {"vu.SunFlareEnabled", "<true/false>"},
            SuppressionMultiplier = {"vu.SuppressionMultiplier", "<float>"},
            TimeScale = {"vu.TimeScale", "<float>"},
            VehicleDisablingEnabled = {"vu.VehicleDisablingEnabled", "<true/false>"},
            Fps = {"vu.Fps", " - return server fps"},
            FpsMa = {"vu.FpsMa", " - return 30-second moving average of the server FPS"},
        }
    }
end

function RCONManager:RegisterEvents()
    Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy)
end

function RCONManager:OnLevelLoaded()
    self:RegisterCommands()
end

function RCONManager:OnLevelDestroy()
    collectgarbage("collect")
end

function RCONManager:CheckIfAdmin()
    -- Check if admin
    for _, l_Admin in pairs(g_ADMINS) do
        if string.find(string.lower(l_Admin), string.lower(self.m_PlayerName)) then
            self.m_PlayerIsAdmin = true
            return
        end
    end
    self.m_PlayerIsAdmin = false
    print("You are not an Admin! OMEGALUL - Try simping more")
end

function RCONManager:RegisterCommands()
    for l_Group, l_Commands in pairs(self.m_RCONCommands) do
        for l_CommandKey, l_Command in pairs(l_Commands) do

            if g_Prints then
                print("*Registering Command: " .. tostring(l_Command[1]) .. " " .. tostring(l_Command[2]))
            end

            if l_Command[1] == "temporaryAdmin.add" then
                Console:Register(l_Command[1], l_Command[2], function(p_Args)
                    self:CheckIfAdmin()
                    if self.m_PlayerIsAdmin then
                        table.insert(g_ADMINS, p_Args[1])
                    end
                end)
            elseif l_Command[1] == "temporaryAdmin.remove" then
                Console:Register(l_Command[1], l_Command[2], function(p_Args)
                    self:CheckIfAdmin()
                    if self.m_PlayerIsAdmin then
                        local s_FoundAdmin = false
                        for l_Index, l_Name in pairs(g_ADMINS) do
                            if string.find(string.lower(l_Name), string.lower(p_Args[1])) then
                                print(l_Name .. " removed from list.")
                                g_ADMINS[l_Index] = nil
                                s_FoundAdmin = true
                                break
                            end
                        end
                        if s_FoundAdmin == false then
                            print("No Admin with this name found")
                        end
                    end
                end)
            elseif l_Command[1] == "temporaryAdmin.list" then
                Console:Register(l_Command[1], l_Command[2], function(p_Args)
                    self:CheckIfAdmin()
                    if self.m_PlayerIsAdmin then
                        print(g_ADMINS)
                    end
                end)
            else
                Console:Register(l_Command[1], l_Command[2], function(p_Args)
                    self:CheckIfAdmin()
                    if self.m_PlayerIsAdmin then
                        NetEvents:Send("RCONManager:SendToServer", l_Command[1], p_Args)
                    end
                end)
            end
        end
    end
end

-- Singleton.
if g_RCONManager == nil then
	g_RCONManager = RCONManager()
end

return g_RCONManager