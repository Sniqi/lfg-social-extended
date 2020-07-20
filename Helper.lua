-- Sniqi // 07-2020
local addonName, LFGSE = ...
local L = LFGSE.L

--------------------------
--- Helper functions  ----
--------------------------

LFGSE.ChatMessage = function(message)
    local preString = "|cfffbff00[LFGSE]|r "
    print( string.format("%s%s", preString, message))
end

LFGSE.convertColorToHex = function(decimalColor)
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

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end