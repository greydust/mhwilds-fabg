local util = require('fabg.util')

local Setting = {
    Settings = {
        enabled = true,
        enableHBG = true,
        enableLBG = true,
        enableGamepad = true,
        enableMouse = false,
        mouseTrigger = util.Settings.DEFAULT_MOUSE_TRIGGER,
    },
}

function Setting.SaveSettings()
	json.dump_file('fabg.json', Setting.Settings)
end

function Setting.LoadSettings()
	local loadedSettings = json.load_file('fabg.json')
	if loadedSettings then
        for k, v in pairs(loadedSettings) do
            Setting.Settings[k] = v
        end
	end
end

return Setting
