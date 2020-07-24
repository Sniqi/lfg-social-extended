-- Sniqi // 07-2020
local addonName, LFGSE = ...
local L = LFGSE.L

-------------------
--- Libraries  ----
-------------------

--local AceGUI = LibStub("AceGUI-3.0")

-------------------
--- Constants  ----
-------------------

local db

function LFGSE:GetDB()
    return db
end

local LFG_DUNGEON_CATEGORY_ID = 2 -- can check with C_LFGList.GetCategoryInfo(categoryID)

--Chat Message colors
local COLOR_SUCCESS = "ffff99f7"
local COLOR_ERROR = "ffff8d36"

--local blacklist = { "Visnart-Eonar", "Pisux-TwistingNether", "Tsourdini-Silvermoon", "Caseys-Norgannon", "Xeraxo", "Dromma-Ghostlands", "Ocago-Kael'thas", "Dhboubou-Medivh", "Fiasco-Trollbane", "Zazabi-Silvermoon", "Foudyfofo-FestungderStürme", "Ketarine-FestungderStürme", "Satturn-Hyjal", "Tayraan-Shattrath", "Rummelsnuff-Outland", "Ommadawn-Outland", "Чипшотина-Азурегос", "Revoke-Auchindoun", "Danjor-Ravencrest", "Electrastar-Illidan", "Redrius-Stormrage", "Remnance-Stormrage", "Зиккуратстер-Гордунни", "Gwynblêidd-Silvermoon", "Candywrath-Silvermoon", "Lïllukka-Ravencrest", "Madúrko-Blackmoore", "Enmâh-Blackmoore", "Firehard-Blackmoore", "Gööfster", "Zeldeen-Kazzak", "Erimus-Kazzak", "Cheboksary-Kazzak", "Amagüestu-Uldum", "Jlofromblock-TarrenMill", "Excuteqtzxy-Baelgun", "Kätarinä-Drak'thul", "Sajande-Blackmoore", "Láetha-Blackmoore", "Märillië-Nemesis", "Eniotnah-MarécagedeZangar", "Ashburner-Ravencrest", "Coldrider-Blade'sEdge", "Jibbit-Alleria", "Valneria-Silvermoon", "Wirnan-DunModr", "Lûcîfer-Argent Dawn", "Vardenf-Hyjal", "Psyçhö-Ravencrest", "Nèwbie-Ravencrest", "Drahziel-DunModr", "Rebeka-DunModr", "Patximba-ColinasPardas", "Teosoul-Chromaggus", "Athènaiè-Elune", "Redmonkey-Arathor", "Frenetiic-Archimonde", "Wuacavi-Pozzodell'Eternità", "Methyc-Ravencrest", "Lolicica-Ravencrest", "Platex-TheMaelstrom", "Mightyarrow-TheMaelstrom", "Algon-Khaz'goroth", "Springfields-TheMaelstrom", "Lidià-Krasus", "Mêrlê-Lordaeron", "Joypopping-Silvermoon", "Sugenshu-Silvermoon", "Kacicek-Drak'thul", "Tranxën-MarécagedeZangar", "Hogzi-Arathor", "Strakko-BurningBlade" }

-------------------------
--- Saved Variables  ----
-------------------------

local defaultSavedVars = {
        global = {
            blacklist = {},
            showBlacklisted = true,
            showRIOscore = true,
            showPreviousRIOscore = true,
            showButtonAddToBlacklist = true,
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
                name = "|cffff6817Please install/activate the addon|r |cff17d4ffRaider.IO Mythic Plus and Raid Progress|r |cffff6817to get access to it's specific settings.|r",
                hidden = function() return not RaiderIO == nil end,
                fontSize = "medium",
                order = 1,
            },
            header_visibilityOptions = {
                type = 'header',
                name = "LFG Visibility Options",
                order = 10,
            },
            toggle_showBlacklisted = {
                type = 'toggle',
                name = "Show Blacklisted Contacts",
                desc = "Shows/hides if a player is blacklisted within the LFG Tool.",
                get = function() return db.showBlacklisted end,
                set = function(_, newValue) db.showBlacklisted = newValue end,
                width = "full",
                order = 20,
            },
            toggle_showRIOscore = {
                type = 'toggle',
                name = "Show RIO Score of current Season",
                desc = "Shows/hides the RIO Score of the current Season within the LFG Tool.",
                disabled = function() return RaiderIO == nil end,
                get = function() return db.showRIOscore end,
                set = function(_, newValue) db.showRIOscore = newValue end,
                width = 1.75,
                order = 21,
            },
            toggle_showPreviousRIOscore = {
                type = 'toggle',
                name = "Show RIO Score of previous Season",
                desc = "Shows/hides the RIO Score of the previous Season within the LFG Tool.",
                disabled = function() return RaiderIO == nil end,
                get = function() return db.showPreviousRIOscore end,
                set = function(_, newValue) db.showPreviousRIOscore = newValue end,
                width = 1.75,
                order = 22,
            },
            header_ContextMenuOptions = {
                type = 'header',
                name = "Context Menu Options",
                order = 25,
            },
            toggle_showButtonAddToBlacklist = {
                type = 'toggle',
                name = "Add to Blacklist",
                desc = "Shows/hides a button in the context menu (right click) to quickly add a player to the blacklist.",
                get = function() return db.showButtonAddToBlacklist end,
                set = function(_, newValue) db.showButtonAddToBlacklist = newValue end,
                width = 1.75,
                order = 26,
            },
            header_RIOOptions = {
                type = 'header',
                name = "Raider.IO Options",
                order = 30,
            },
            range_RIOScorelowerThreshold = {
                type = 'range',
                name = "RIO Score Lower Threshold",
                desc = "Sets the lower threshold of RIO score. All scores equal or lower use the specified color.",
                disabled = function() return RaiderIO == nil end,
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
                desc = "Sets the upper threshold of RIO score. All scores equal or higher use the specified color.",
                disabled = function() return RaiderIO == nil end,
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
                desc = "Sets the lower threshold color. All scores equal or higher use the specified color.",
                disabled = function() return RaiderIO == nil end,
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
                disabled = function() return RaiderIO == nil end,
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
                disabled = function() return RaiderIO == nil end,
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
                disabled = function() return RaiderIO == nil end,
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

        for i,name in pairs(db.blacklist) do
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
    if not RaiderIO == nil and db.showRIOscore then

        local categoryID = select(3, C_LFGList.GetActivityInfo(result.activityID))
        if categoryID == LFG_DUNGEON_CATEGORY_ID then

            local currentRio = LFGSE.GetPlayerRIO_CurrentSeason(result.leaderName)
            local previousRio = LFGSE.GetPlayerRIO_PreviousSeason(result.leaderName)

            local displayString = "%s | %s"

            local scoreString

            if currentRio == "0" and previousRio == "0" then
                scoreString = "---"
            elseif currentRio == "0" and not previousRio == "0" then
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

---------------------
--- LFG Dropdown ----
---------------------

local supportedTypes = {
    PARTY = 1,
    PLAYER = 1,
    RAID_PLAYER = 1,
    RAID = 1,
    -- FRIEND = 1,
    -- BN_FRIEND = 1,
    -- GUILD = 1,
    -- GUILD_OFFLINE = 1,
    CHAT_ROSTER = 1,
    -- TARGET = 1,
    -- ARENAENEMY = 1,
    -- FOCUS = 1,
    -- WORLD_STATE_SCORE = 1,
    COMMUNITIES_WOW_MEMBER = 1,
    -- COMMUNITIES_GUILD_MEMBER = 1,
    -- SELF = 1 -- We dont want to blacklist ourselves, right?
}

local frameButton

LFGSE.isBlacklisted = function(charNameCheck)
    if not charNameCheck:find("-") then
        charNameCheck = charNameCheck .. "-" ..GetNormalizedRealmName()
    end
    for i,charName in pairs(db.blacklist) do
        if charName == charNameCheck then
            return true
        end
    end
    return false
end

local function onClick_AddToBlacklist()
    CloseDropDownMenus()

    if LFGSE.isBlacklisted(frameButton.charName) then
        LFGSE.ChatMessage(string.format("|c"..COLOR_ERROR.."%s|r%s|c"..COLOR_ERROR.."%s|r", "This player (", frameButton.charName, ") is already blacklisted! No action taken."))
    else
        table.insert(db.blacklist, frameButton.charName)
        LFGSE.ChatMessage(string.format("|c"..COLOR_SUCCESS.."%s|r%s", "Player blacklisted: ", frameButton.charName))
    end
end

local function CustomOnShow(self) -- UIDropDownMenuTemplates.xml#257
    local parent = self:GetParent() or self
    local width = parent:GetWidth()
    local height = 32
    for i = 1, #self.buttons do
        local button = self.buttons[i]
        if button:IsShown() then
            button:SetWidth(width - 32) -- anchor offsets for left/right
        end
    end
    self:SetWidth(width)
end

local function CustomButtonOnEnter(self) -- UIDropDownMenuTemplates.xml#155
    _G[self:GetName() .. "Highlight"]:Show()
end

local function CustomButtonOnLeave(self) -- UIDropDownMenuTemplates.xml#178
    _G[self:GetName() .. "Highlight"]:Hide()
end

frameButton = CreateFrame("Button", addonName .. "_CustomDropDownList", UIParent, "UIDropDownListTemplate")
frameButton:Hide()

do
    frameButton:SetScript("OnClick", nil)
    frameButton:SetScript("OnUpdate", nil)
    frameButton:SetScript("OnShow", nil)--CustomOnShow)
    frameButton:SetScript("OnHide", nil)
    _G[frameButton:GetName() .. "Backdrop"]:Hide()
    frameButton.buttons = {}
    for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
        local button = _G[frameButton:GetName() .. "Button" .. i]
        if not button then
            break
        end
        frameButton.buttons[i] = button
        button:Hide()
        button:SetScript("OnClick", nil)
        button:SetScript("OnEnter", CustomButtonOnEnter)
        button:SetScript("OnLeave", CustomButtonOnLeave)
        button:SetScript("OnEnable", nil)
        button:SetScript("OnDisable", nil)
        button:SetPoint("TOPLEFT", frameButton, "TOPLEFT", 16, -8 * i)
        local text = _G[button:GetName() .. "NormalText"]
        text:ClearAllPoints()
        text:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        _G[button:GetName() .. "Check"]:SetAlpha(0)
        _G[button:GetName() .. "UnCheck"]:SetAlpha(0)
        _G[button:GetName() .. "Icon"]:SetAlpha(0)
        _G[button:GetName() .. "ColorSwatch"]:SetAlpha(0)
        _G[button:GetName() .. "ExpandArrow"]:SetAlpha(0)
        _G[button:GetName() .. "InvisibleButton"]:SetAlpha(0)
    end
    frameButton.buttonBlacklist = frameButton.buttons[1]
    local buttonBlacklistName = frameButton.buttonBlacklist:GetName()
    local text = _G[buttonBlacklistName .. "NormalText"]
    text:SetText("Add to Blacklist")
    text:Show()
    frameButton.buttonBlacklist:SetScript("OnClick", onClick_AddToBlacklist)
    frameButton.buttonBlacklist:Show()
end



local function ShowCustomDropDown(list, name)
    frameButton.charName = name
    frameButton:SetParent(list)
    frameButton:SetFrameStrata(list:GetFrameStrata())
    frameButton:SetFrameLevel(list:GetFrameLevel() + 1)
    frameButton:ClearAllPoints()

    local listWidth, listHeight = list:GetSize()

    local height = 32
    for i = 1, #frameButton.buttons do
        local button = frameButton.buttons[i]
        if button:IsShown() then
            button:SetWidth(listWidth - 32) -- anchor offsets for left/right
            button:SetHeight(height / 2)
        end
    end

    frameButton:SetWidth(listWidth)
    frameButton:SetHeight(height)

    local frameButtonWidth, frameButtonHeight = frameButton:GetSize()

    list:SetHeight(listHeight + frameButtonHeight)

    local offset = 0
    if RaiderIO then
        offset = offset + 48
    end


    frameButton:SetPoint("BOTTOMLEFT", list, "BOTTOMLEFT", 0, offset)
    frameButton:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", 0, offset)
    --frameButton:SetPoint("TOPLEFT", list, "TOPRIGHT", 0, 0)
    --frameButton:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", frameButtonWidth, 0)

    frameButton:Show()
end

local function HideCustomDropDown()
    frameButton:Hide()
end

local function OnShow(self)
    if not self.dropdown then return end
    if not db.showButtonAddToBlacklist then return end

    if self.dropdown.Button == _G.LFGListFrameDropDownButton then -- LFG
        local fullName = self.dropdown.menuList[2].arg1
        if not fullName:find("-") then
            fullName = fullName .. "-" .. GetNormalizedRealmName()
        end
        ShowCustomDropDown(self, fullName)
    elseif self.dropdown.which and supportedTypes[self.dropdown.which] then -- UnitPopup
        local dropdownFullName
        if self.dropdown.name then
            if self.dropdown.server and not self.dropdown.name:find("-") then
                dropdownFullName = self.dropdown.name .. "-" .. self.dropdown.server
            else
                dropdownFullName = self.dropdown.name .. "-" .. GetNormalizedRealmName()
            end
        end
        ShowCustomDropDown(self, self.dropdown.chatTarget or dropdownFullName)
    end
end

local function OnHide()
    HideCustomDropDown()
end

DropDownList1:HookScript("OnShow", OnShow)
DropDownList1:HookScript("OnHide", OnHide)

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
