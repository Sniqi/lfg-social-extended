-- Sniqi // 07-2020
local AddonName, LFGSE = ...
local L = LFGSE.L

-------------------
--- Libraries  ----
-------------------

local AceGUI = LibStub("AceGUI-3.0")
local db

function LFGSE:GetDB()
    return db
end

-------------------
--- Constants  ----
-------------------

--db.RIOScorelowerThreshold_Color = string.format("|c%02x%02x%02x%02x", a*255, r*255, g*255, b*255)
-------------------------
--- Saved Variables  ----
-------------------------

local defaultSavedVars = {
        global = {
        showBlacklisted = true,
        showRIOscore = true,
        showPreviousRIOscore = true,
        RIOScorelowerThreshold = 0,
        RIOScoreupperThreshold = 0,
        RIOScorelowerThreshold_Color = { ["r"] = 0.56, ["g"] = 0.56, ["b"] = 0.56, ["a"] = 1.0},
        RIOScoremiddleThreshold_Color = { ["r"] = 0.20, ["g"] = 0.80, ["b"] = 0.0, ["a"] = 1.0},
        RIOScoreupperThreshold_Color = { ["r"] = 0.00, ["g"] = 1.00, ["b"] = 0.78, ["a"] = 1.0},
        --language = LFGSE:GetLocaleIndex(),
    },
}

do
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(self, event, ...)
        return LFGSE[event](self,...)
    end)

    function LFGSE.ADDON_LOADED(self, addon)
        if addon == "LFGSocialExtended" then

            db = LibStub("AceDB-3.0"):New("LFGSocialExtendedDB", defaultSavedVars).global
            --register AddOn Options
            LFGSE:RegisterOptions()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end
end

---------------------------
--- Interface Options  ----
---------------------------

function LFGSE:RegisterOptions()

    LFGSE.blizzardOptionsMenuTable = {
        name = "LFG Social Extended",
        type = 'group',
        args = {
            header_raiderIOaddonDisabled = {
                type = 'description',
                name = "|cffff6817Please install/activate the addon|r |cff17d4ffRaider.IO Mythic Plus and Raid Progress|r |cffff6817to get access to it's specific features settings.|r",
                hidden = function() return LFGSE:RIO_Addon_Enabled() end,
                fontSize = "medium",
                order = 1,
            },
            header_visibilityOptions = {
                type = 'header',
                name = "Visibility Options",
                order = 10,
            },
            toggle_showBlacklisted = {
                type = 'toggle',
                name = "Show Blacklisted Contacts",
                desc = "Shows/hides if a player is blacklisted within the LFG Tool",
                get = function() return db.showBlacklisted end,
                set = function(_, newValue) db.showBlacklisted = newValue end,
                width = "full",
                order = 20,
            },
            toggle_showRIOscore = {
                type = 'toggle',
                name = "Show RIO Score of current Season",
                desc = "Shows/hides the RIO Score of the current Season within the LFG Tool",
                disabled = function() return not LFGSE:RIO_Addon_Enabled() end,
                get = function() return db.showRIOscore end,
                set = function(_, newValue) db.showRIOscore = newValue end,
                width = 1.75,
                order = 21,
            },
            toggle_showPreviousRIOscore = {
                type = 'toggle',
                name = "Show RIO Score of previous Season",
                desc = "Shows/hides the RIO Score of the previous Season within the LFG Tool",
                disabled = function() return not LFGSE:RIO_Addon_Enabled() end,
                get = function() return db.showPreviousRIOscore end,
                set = function(_, newValue) db.showPreviousRIOscore = newValue end,
                width = 1.75,
                order = 22,
            },
            header_RIOOptions = {
                type = 'header',
                name = "Raider.IO Options",
                order = 30,
            },
            range_RIOScorelowerThreshold = {
                type = 'range',
                name = "RIO Score Lower Threshold",
                desc = "Sets the lower threshhold of RIO score. All scores equal or lower use the specified color.",
                disabled = function() return not LFGSE:RIO_Addon_Enabled() end,
                min = 0,
                max = db.RIOScoreupperThreshold - 1,
                step = 1,
                bigStep = 50,
                get = function() return db.RIOScorelowerThreshold end,
                set = function(_, newValue) db.RIOScorelowerThreshold = newValue
                    LFGSE.blizzardOptionsMenuTable.args.range_RIOScoreupperThreshold.min = db.RIOScorelowerThreshold
                end,
                width = 1.75,
                order = 40,
            },
            range_RIOScoreupperThreshold = {
                type = 'range',
                name = "RIO Score Upper Threshold",
                desc = "Sets the upper threshhold of RIO score. All scores equal or higher use the specified color.",
                disabled = function() return not LFGSE:RIO_Addon_Enabled() end,
                min = db.RIOScorelowerThreshold,
                max = 5000,
                step = 1,
                bigStep = 50,
                get = function() return db.RIOScoreupperThreshold end,
                set = function(_, newValue) db.RIOScoreupperThreshold = newValue
                    LFGSE.blizzardOptionsMenuTable.args.range_RIOScorelowerThreshold.max = db.RIOScoreupperThreshold - 1
                end,
                width = 1.75,
                order = 41,
            },
            header_RIOOptionsColor = {
                type = 'header',
                name = "Raider.IO Color Options",
                order = 50,
            },
            color_RIOScorelowerThreshold = {
                type = 'color',
                name = "RIO Score Lower Threshold Color",
                desc = "Sets the lower threshhold color. All scores equal or higher use the specified color.",
                disabled = function() return not LFGSE:RIO_Addon_Enabled() end,
                hasAlpha = false,
                get = function() return db.RIOScorelowerThreshold_Color.r,
                db.RIOScorelowerThreshold_Color.g,
                db.RIOScorelowerThreshold_Color.b,
                db.RIOScorelowerThreshold_Color.a end,
                set = function(_, r, g, b, a) db.RIOScorelowerThreshold_Color.r = r
                    db.RIOScorelowerThreshold_Color.g = g
                    db.RIOScorelowerThreshold_Color.b = b
                    db.RIOScorelowerThreshold_Color.a = a
                end,
                width = 1.75,
                order = 61,
            },
            color_RIOScoremiddleThreshold_Color = {
                type = 'color',
                name = "RIO Score Middle Threshold Color",
                desc = "Sets the middle threshhold color. All scores in between of the lower and upper threshold use the specified color.",
                disabled = function() return not LFGSE:RIO_Addon_Enabled() end,
                hasAlpha = false,
                get = function() return db.RIOScoremiddleThreshold_Color.r,
                db.RIOScoremiddleThreshold_Color.g,
                db.RIOScoremiddleThreshold_Color.b,
                db.RIOScoremiddleThreshold_Color.a end,
                set = function(_, r, g, b, a) db.RIOScoremiddleThreshold_Color.r = r
                    db.RIOScoremiddleThreshold_Color.g = g
                    db.RIOScoremiddleThreshold_Color.b = b
                    db.RIOScoremiddleThreshold_Color.a = a
                end,
                width = 1.75,
                order = 62,
            },
            color_RIOScoreupperThreshold = {
                type = 'color',
                name = "RIO Score Upper Threshold Color",
                desc = "Sets the upper threshhold color. All scores equal or higher use the specified color.",
                disabled = function() return not LFGSE:RIO_Addon_Enabled() end,
                hasAlpha = false,
                get = function() return db.RIOScoreupperThreshold_Color.r,
                                        db.RIOScoreupperThreshold_Color.g,
                                        db.RIOScoreupperThreshold_Color.b,
                                        db.RIOScoreupperThreshold_Color.a end,
                set = function(_, r, g, b, a) db.RIOScoreupperThreshold_Color.r = r
                                        db.RIOScoreupperThreshold_Color.g = g
                                        db.RIOScoreupperThreshold_Color.b = b
                                        db.RIOScoreupperThreshold_Color.a = a end,
                width = 1.75,
                order = 63,
            },
            execute_RIOScoreColorsDefault = {
                type = 'execute',
                name = "Default Threshold Colors",
                desc = "Reset the RIO threshold colors to their default values.",
                disabled = function() return not LFGSE:RIO_Addon_Enabled() end,
                func = function()
                    db.RIOScorelowerThreshold_Color.r = defaultSavedVars.global.RIOScorelowerThreshold_Color.r
                    db.RIOScorelowerThreshold_Color.g = defaultSavedVars.global.RIOScorelowerThreshold_Color.g
                    db.RIOScorelowerThreshold_Color.b = defaultSavedVars.global.RIOScorelowerThreshold_Color.b
                    db.RIOScorelowerThreshold_Color.a = defaultSavedVars.global.RIOScorelowerThreshold_Color.a

                    db.RIOScoremiddleThreshold_Color.r = defaultSavedVars.global.RIOScoremiddleThreshold_Color.r
                    db.RIOScoremiddleThreshold_Color.g = defaultSavedVars.global.RIOScoremiddleThreshold_Color.g
                    db.RIOScoremiddleThreshold_Color.b = defaultSavedVars.global.RIOScoremiddleThreshold_Color.b
                    db.RIOScoremiddleThreshold_Color.a = defaultSavedVars.global.RIOScoremiddleThreshold_Color.a

                    db.RIOScoreupperThreshold_Color.r = defaultSavedVars.global.RIOScoreupperThreshold_Color.r
                    db.RIOScoreupperThreshold_Color.g = defaultSavedVars.global.RIOScoreupperThreshold_Color.g
                    db.RIOScoreupperThreshold_Color.b = defaultSavedVars.global.RIOScoreupperThreshold_Color.b
                    db.RIOScoreupperThreshold_Color.a = defaultSavedVars.global.RIOScoreupperThreshold_Color.a

                    return true
                end,
                width = 1.25,
                order = 64,
            },
        }
    }
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("LFGSocialExtended", LFGSE.blizzardOptionsMenuTable)
    self.blizzardOptionsMenu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("LFGSocialExtended", "LFGSocialExtended")
end




local blacklist = { "Visnart-Eonar", "Pisux-TwistingNether", "Tsourdini-Silvermoon", "Caseys-Norgannon", "Xeraxo", "Dromma-Ghostlands", "Ocago-Kael'thas", "Dhboubou-Medivh", "Fiasco-Trollbane", "Zazabi-Silvermoon", "Foudyfofo-FestungderStürme", "Ketarine-FestungderStürme", "Satturn-Hyjal", "Tayraan-Shattrath", "Rummelsnuff-Outland", "Ommadawn-Outland", "Чипшотина-Азурегос", "Revoke-Auchindoun", "Danjor-Ravencrest", "Electrastar-Illidan", "Redrius-Stormrage", "Remnance-Stormrage", "Зиккуратстер-Гордунни", "Gwynblêidd-Silvermoon", "Candywrath-Silvermoon", "Lïllukka-Ravencrest", "Madúrko-Blackmoore", "Enmâh-Blackmoore", "Firehard-Blackmoore", "Gööfster", "Zeldeen-Kazzak", "Erimus-Kazzak", "Cheboksary-Kazzak", "Amagüestu-Uldum", "Jlofromblock-TarrenMill", "Excuteqtzxy-Baelgun", "Kätarinä-Drak'thul", "Sajande-Blackmoore", "Láetha-Blackmoore", "Märillië-Nemesis", "Eniotnah-MarécagedeZangar", "Ashburner-Ravencrest", "Coldrider-Blade'sEdge", "Jibbit-Alleria", "Valneria-Silvermoon", "Wirnan-DunModr", "Lûcîfer-Argent Dawn", "Vardenf-Hyjal", "Psyçhö-Ravencrest", "Nèwbie-Ravencrest", "Drahziel-DunModr", "Rebeka-DunModr", "Patximba-ColinasPardas", "Teosoul-Chromaggus", "Athènaiè-Elune", "Redmonkey-Arathor", "Frenetiic-Archimonde", "Wuacavi-Pozzodell'Eternità", "Methyc-Ravencrest", "Lolicica-Ravencrest", "Platex-TheMaelstrom", "Mightyarrow-TheMaelstrom", "Algon-Khaz'goroth", "Springfields-TheMaelstrom", "Lidià-Krasus", "Mêrlê-Lordaeron", "Joypopping-Silvermoon", "Sugenshu-Silvermoon", "Kacicek-Drak'thul", "Tranxën-MarécagedeZangar", "Hogzi-Arathor", "Strakko-BurningBlade" }

local LFG_DUNGEON_CATEGORY_ID = 2 -- can check with C_LFGList.GetCategoryInfo(categoryID)
local LFG_MAX_ENTRY_NAME_LEN = 25 -- can check manually (+5 for title without voice icon)

--------------------
--- LFG Enlist  ----
--------------------

LFGSE.UpdateApplicant = function(button, id)
    if afterIlvl then
        button.InviteButton:SetWidth(50);
        button.InviteButton:SetText("Invite");
    end
end

LFGSE.UpdateApplicantMember = function(member, appID, memberIdx, status, pendingStatus)
    local fullname, _ = C_LFGList.GetApplicantMemberInfo(appID, memberIdx)

    local blacklisted = false

    for i,name in pairs(blacklist) do
        if name == fullname then
            blacklisted = true
            break
        end
    end

    if blacklisted then
        member.Name:SetText( ("|c%s%s|r%s"):format("ffff0000", "BLACKLISTED ", member.Name:GetText()) )
    end
end

hooksecurefunc("LFGListApplicationViewer_UpdateApplicant", LFGSE.UpdateApplicant)
hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", LFGSE.UpdateApplicantMember)

--------------------
--- LFG Search  ----
--------------------

LFGSE.SearchEntry_Update = function(group)
    local result = C_LFGList.GetSearchResultInfo(group.resultID)

    --- Blacklist
    if db.showBlacklisted then

        local blacklisted = false

        for i,name in pairs(blacklist) do
            if name == result.leaderName then
                blacklisted = true
                break
            end
        end

        if blacklisted then
            group.Name:SetText( ("|c%s%s|r%s"):format("ffff0000", "BLACKLISTED ", group.Name:GetText()) )
            return
        end

    end

    --- RIO Score

    if LFGSE:RIO_Addon_Enabled() and  db.showRIOscore then

        local categoryID = select(3, C_LFGList.GetActivityInfo(result.activityID))
        if categoryID == LFG_DUNGEON_CATEGORY_ID then

            local currentRio = LFGSE.GetPlayerRIO_CurrentSeason(result.leaderName)
            local previousRio = LFGSE.GetPlayerRIO_PreviousSeason(result.leaderName)

            local displayString = "%s | %s"

            local scoreString

            if currentRio == "0" and previousRio == "0" then
                scoreString = "---"
            elseif currentRio == "0" and previousRio ~= "0" then
                scoreString = "(" .. previousRio .. ")"
            else
                scoreString = currentRio
            end

            local color = "ffffffff"

            if currentRio == nil or previousRio == nil then
                color = LFGSE.convertColorToHex(db.RIOScorelowerThreshold_Color)
            elseif tonumber(currentRio) > db.RIOScorelowerThreshold and tonumber(currentRio) < db.RIOScoreupperThreshold then
                color = LFGSE.convertColorToHex(db.RIOScoremiddleThreshold_Color)
            elseif tonumber(currentRio) <= db.RIOScorelowerThreshold then
                color = LFGSE.convertColorToHex(db.RIOScorelowerThreshold_Color)
            elseif tonumber(currentRio) >= db.RIOScoreupperThreshold then
                color = LFGSE.convertColorToHex(db.RIOScoreupperThreshold_Color)
            else
                color = LFGSE.convertColorToHex(db.RIOScorelowerThreshold_Color)
            end

            group.Name:SetText(string.format(displayString, ("|c%s%s|r"):format(color, scoreString), group.Name:GetText()))
        end
    end

end

hooksecurefunc("LFGListSearchEntry_Update", LFGSE.SearchEntry_Update)

---------------------------------
--- raider.IO API functions  ----
---------------------------------

local rioShort = false
local rioFormat = "%.1fk"

local rioSeparator = " | "

LFGSE.GetPlayerRIOProfile = function(fullname)
    local profile = RaiderIO.GetPlayerProfile(0, fullname)
    if profile == nil then return end

    profile = profile[1]
    if profile == nil then return end

    return profile
end
LFGSE.RIO_String = function(score, short)
    if rioShort then score = score / 1000 end
    return string.format(rioShort and rioFormat or "%d", score)
end

LFGSE.GetPlayerRIO_CurrentSeason = function(fullname)
    local profile = LFGSE.GetPlayerRIOProfile(fullname)

    local score

    if profile then
        score = profile.profile.mplusCurrent.score
    end

    return LFGSE.RIO_String(score)
end

LFGSE.GetPlayerRIO_PreviousSeason = function(fullname)
    local profile = LFGSE.GetPlayerRIOProfile(fullname)

    local score

    if profile then
        score = profile.profile.mplusPrevious.score
    end

    return LFGSE.RIO_String(score)
end

--------------------------
--- Helper functions  ----
--------------------------

function LFGSE:RIO_Addon_Enabled()
    if RaiderIO == nil then
        return false
    else
        return true
    end
end

function LFGSE.convertColorToHex(decimalColor)
    local alpha = string.format("%x", decimalColor.a * 255)
    local red = string.format("%x", decimalColor.r * 255)
    local green = string.format("%x", decimalColor.g * 255)
    local blue = string.format("%x", decimalColor.b * 255)

    local colorTable = {alpha, red, green, blue}

    for i=1,4 do
        if colorTable[i] == "0" then
            colorTable[i] = "00"
        end
    end

    return colorTable[1] ..colorTable[2] ..colorTable[3] ..colorTable[4]
end