require('fabg.button.mouse_button')

local Util = {
    Settings = {
        DEFAULT_MOUSE_TRIGGER = 15,
        DEFAULT_PAD_TRIGGER = 2,
    },
    Character = nil, -- app.HunterCharacter
    Pad = nil, -- app.cPlayerGameInput
    MouseKeyboard = nil, -- app.cPcPlayerGameInput
}

function Util.SafeRequire(name)
    local success = pcall(function() require(name) end) 
    if success then
        return require(name)
    end
    return nil
end

return Util
