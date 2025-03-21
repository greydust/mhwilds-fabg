require('fabg.button.mouse_button')

local Util = {
    Settings = {
        DEFAULT_GAMEPAD_TRIGGER = 2048,
        DEFAULT_MOUSE_TRIGGER = 15,
    },
    Character = nil, -- app.HunterCharacter
    Pad = nil,
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
