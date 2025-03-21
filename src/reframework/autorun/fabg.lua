local inputManager = sdk.get_managed_singleton('app.GameInputManager')
local mkbInput = inputManager:get_PcPlayerInput()

local setting = require('fabg.setting')
local util = require('fabg.util')

setting.LoadSettings()

local function isUsingHBG()
    return util.Character:get_WeaponType() == 12 and setting.Settings.enableHBG
end

local function isUsingLBG()
    return util.Character:get_WeaponType() == 13 and setting.Settings.enableLBG
end

local function isUsingBG()
    return util.Character and util.Character:get_IsWeaponOn() and (isUsingHBG() or isUsingLBG())
end

local lastOn = 0
sdk.hook(sdk.find_type_definition('ace.cGameInput'):get_method('applyFromMouseKeyboard'), function(args)
end,
function(retval)
    if setting.Settings.enabled and setting.Settings.enableMouse and util.MouseKeyboard and isUsingBG() and setting.Settings.mouseTrigger >= 0 then
        local keys = mkbInput._Keys
        local targetKeys = {keys[setting.Settings.mouseTrigger]}
        for k, v in pairs(targetKeys) do
            if v._On == true then
                if lastOn == 0 then
                    v._OnTrigger = true
                    v._Repeat = true
                    v._OffTrigger = false
                elseif lastOn == 2 then
                    v._On = false
                    v._OnTrigger = false
                    v._Repeat = false
                    v._OffTrigger = true
                end
                log.debug(tostring(k) .. ' OnTrigger: ' .. tostring(v._OnTrigger) .. ' OffTrigger: ' .. tostring(v._OffTrigger) .. ' lastOn: ' .. tostring(lastOn)) 
            end
        end
        -- Two functions calls applyFromMouseKeyboard in one update, so a full loop is 4 calls.
        lastOn = (lastOn + 1) % 4
    end
end)

re.on_pre_application_entry('UpdateBehavior', function()
    if not util.Character then
        local playerManager = sdk.get_managed_singleton('app.PlayerManager')
        if playerManager then
            local masterPlayer = playerManager:getMasterPlayer() -- app.cPlayerManageInfo
            if masterPlayer then
                util.Character = masterPlayer:get_Character() -- app.HunterCharacter
            end
        end
    end

    if not util.Pad then
        -- TODO: implement pad
    end

    if not util.MouseKeyboard then
        local inputManager = sdk.get_managed_singleton('app.GameInputManager')
        if inputManager then
            util.MouseKeyboard = inputManager:get_PcPlayerInput() -- app.cPcPlayerGameInput
        end
    end
end)

re.on_draw_ui(function()
    if imgui.tree_node('Full-Auto Bowguns') then
        changed, value = imgui.checkbox('Enabled', setting.Settings.enabled)
        if changed then
            setting.Settings.enabled = value
            setting.SaveSettings()
        end

        imgui.new_line()

        changed, value = imgui.checkbox('Enable Heavy Bowgun', setting.Settings.enableHBG)
        if changed then
            setting.Settings.enableHBG = value
            setting.SaveSettings()
        end
        changed, value = imgui.checkbox('Enable Light Bowgun', setting.Settings.enableLBG)
        if changed then
            setting.Settings.enableLBG = value
            setting.SaveSettings()
        end

        imgui.new_line()

        changed, value = imgui.checkbox('Enable Gamepad', setting.Settings.enableGamepad)
        if changed then
            setting.Settings.enableGamepad = value
            setting.SaveSettings()
        end

        changed, value = imgui.checkbox('Enable Mouse', setting.Settings.enableMouse)
        if changed then
            setting.Settings.enableMouse = value
            setting.SaveSettings()
        end

        imgui.tree_pop();
    end
end)


--[[


local padDevice = sdk.find_type_definition('ace.PadManager');

local triggerOffset = sdk.find_type_definition('ace.cMouseKeyboardInfo.KEY_INFO'):get_field('_Trigger'):get_offset_from_base()






re.on_config_save(function()
	setting.SaveSettings();
end)
]]--