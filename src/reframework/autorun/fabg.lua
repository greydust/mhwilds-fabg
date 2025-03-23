local setting = require('fabg.setting')
local util = require('fabg.util')

setting.LoadSettings()

log.debug(tostring(sdk.get_managed_singleton('app.PlayerManager')))

local function isUsingHBG(character)
    if character:get_WeaponType() == 12 then
        local wpHandling = character:get_WeaponHandling() -- app.cHunterWp12Handling
        local energyBullet = wpHandling:get_EnergyBulletInfo() -- app.Wp12Def.cEnergyBulletInfo
        return setting.Settings.enableHBG and (not wpHandling:get_IsEnergyMode() or energyBullet:get_StandardEnergyShellType() ~= 0)
    end
    return false
end

local function isUsingLBG(character)
    if character:get_WeaponType() == 13 then
        local wpHandling = character:get_WeaponHandling() -- app.cHunterWp13Handling
        -- In rapid fire mode, disable full-auto until the magazine is empty or full. This will only enable auto reload without interfering with rapid fire.
        return character:get_WeaponType() == 13 and setting.Settings.enableLBG and (not wpHandling:get_IsRapidShotBoost() or (not setting.Settings.disableRapidFire and (wpHandling:getCurrentAmmo():get_IsEmptyAmmo() or wpHandling:getCurrentAmmo():get_IsFullAmmo())))
    end
    return false
end

local function isUsingBG(character)
    return character:get_IsWeaponOn() and (isUsingHBG(character) or isUsingLBG(character))
end

local function getCharacter()
    local masterPlayer = sdk.get_managed_singleton('app.PlayerManager'):getMasterPlayer() -- app.cPlayerManageInfo
    if masterPlayer then
        return masterPlayer:get_Character() -- app.HunterCharacter
    end
    return nil
end

local state = {}

local mouseUpdate = false
local mouseOnTrigger = false
local padUpdate = false
local padOnTrigger = false
sdk.hook(sdk.find_type_definition('ace.cGameInput'):get_method('applyFromMouseKeyboard'), function(args)
end,
function(retval)
    local targetKey = util.MouseKeyboard._Keys[setting.Settings.mouseTrigger]
    if not state[setting.Settings.mouseTrigger] then
        state[setting.Settings.mouseTrigger] = 0
    end

    local character = getCharacter()
    if character and setting.Settings.enabled and setting.Settings.enableMouse
            and util.MouseKeyboard and isUsingBG(character) and setting.Settings.mouseTrigger >= 0 then
        if mouseUpdate then
            mouseUpdate = false
            mouseOnTrigger = not mouseOnTrigger
        end
        if targetKey._On == true then
            if mouseOnTrigger then
                targetKey._OnTrigger = true
                targetKey._Repeat = true
                targetKey._OffTrigger = false
            else
                targetKey._On = false
                targetKey._OnTrigger = false
                targetKey._Repeat = false
                targetKey._OffTrigger = true
            end
        end
    end
end)

sdk.hook(sdk.find_type_definition('ace.cGameInput'):get_method('applyFromPad'), function(args)
end,
function(retval)
    local targetKey = util.Pad._Keys[setting.Settings.padTrigger]
    if not state[setting.Settings.padTrigger] then
        state[setting.Settings.padTrigger] = 0
    end

    local character = getCharacter()
    if character and setting.Settings.enabled and setting.Settings.enablePad
            and util.Pad and isUsingBG(character) and setting.Settings.padTrigger >= 0 then
        if padUpdate then
            padUpdate = false
            padOnTrigger = not padOnTrigger
        end
        if targetKey._On == true then
            if padOnTrigger then
                targetKey._OnTrigger = true
                targetKey._Repeat = true
                targetKey._OffTrigger = false
            else
                targetKey._On = false
                targetKey._OnTrigger = false
                targetKey._Repeat = false
                targetKey._OffTrigger = true
            end
        end
    end
end)

re.on_pre_application_entry('UpdateBehavior', function()
    if not util.Pad then
        local inputManager = sdk.get_managed_singleton('app.GameInputManager')
        if inputManager then
            util.Pad = inputManager:get_PlayerInput() -- app.cPlayerGameInput
        end
    end

    if not util.MouseKeyboard then
        local inputManager = sdk.get_managed_singleton('app.GameInputManager')
        if inputManager then
            util.MouseKeyboard = inputManager:get_PcPlayerInput() -- app.cPcPlayerGameInput
        end
    end
end)

re.on_frame(function()
    mouseUpdate = true
    padUpdate = true
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
        changed, value = imgui.checkbox('  Disable in Rapid Fire Mode', setting.Settings.disableRapidFire)
        if changed then
            setting.Settings.disableRapidFire = value
            setting.SaveSettings()
        end

        imgui.new_line()

        changed, value = imgui.checkbox('Enable Pad', setting.Settings.enablePad)
        if changed then
            setting.Settings.enablePad = value
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
