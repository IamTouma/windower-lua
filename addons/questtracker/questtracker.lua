--[[    BSD License Disclaimer
        Copyright © 2018, sylandro
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of questtracker nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL sylandro BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'questtracker'
_addon.author = 'sylandro'
_addon.version = '1.0.0'
_addon.language = 'English'
_addon.command = 'questtracker'
_addon.commands = {'qt'}

config = require('config')
texts = require('texts')
images = require('images')
res = require('resources')
packets = require('packets')

local SCROLL_LOCK_KEY = 70
local UNDERSCORE_KEY = 12
local CUTSCENE_STATUS_ID = 4

local LOGIN_ZONE_PACKET = 0x0A
local ZONE_OUT_PACKET = 0x0B
local QUEST_UPDATE_PACKET = 0x56
local hide_key = SCROLL_LOCK_KEY
local hide_key_alt = UNDERSCORE_KEY

defaults = {}
defaults.hideKey = SCROLL_LOCK_KEY
defaults.hideKeyAlternate = UNDERSCORE_KEY
defaults.pos = {}
defaults.pos.x = -140
defaults.pos.y = 205
defaults.missions = {}
defaults.missions.enabled = true
defaults.missions.maxShown = 3
defaults.missions.showId = true
defaults.missions.showTitle = true
defaults.missions.showDescription = true
defaults.missions.showImage = true
defaults.missions.imageHeight = 16
defaults.missions.imageWidth = 16
defaults.missions.order = {}
defaults.missions.order.nation = 1
defaults.missions.order.roz = 2
defaults.missions.order.cop = 3
defaults.missions.order.toau = 4
defaults.missions.order.assault = 5
defaults.missions.order.wotg = 6
defaults.missions.order.campaign = 7
defaults.missions.order.acp = 8
defaults.missions.order.mkd = 9
defaults.missions.order.asa = 10
defaults.missions.order.soa = 11
defaults.missions.order.rov = 12
defaults.quests = {}
defaults.quests.enabled = true
defaults.quests.maxShown = 3
defaults.quests.showId = true
defaults.quests.showTitle = true
defaults.quests.showDescription = true
defaults.quests.showImage = true
defaults.quests.imageHeight = 16
defaults.quests.imageWidth = 16
defaults.quests.order = {}
defaults.quests.order.bastok = 1
defaults.quests.order.sandoria = 2
defaults.quests.order.windurst = 3
defaults.quests.order.jeuno = 4
defaults.quests.order.other = 5
defaults.quests.order.outlands = 6
defaults.quests.order.aht = 7
defaults.quests.order.war = 8
defaults.quests.order.abyssea = 9
defaults.quests.order.adoulin = 10
defaults.quests.order.coalition = 11
defaults.roe = {}
defaults.roe.enabled = true
defaults.roe.maxShown = 10
defaults.roe.showId = true
defaults.roe.showTitle = true
defaults.roe.showDescription = true
defaults.roe.showImage = true
defaults.roe.imageHeight = 16
defaults.roe.imageWidth = 16
defaults.questTitle = {}
defaults.questTitle.bg = {}
defaults.questTitle.bg.alpha = 255
defaults.questTitle.bg.red = 0
defaults.questTitle.bg.green = 0
defaults.questTitle.bg.blue = 0
defaults.questTitle.bg.visible = false
defaults.questTitle.flags = {}
defaults.questTitle.flags.right = true
defaults.questTitle.flags.bottom = false
defaults.questTitle.flags.bold = true
defaults.questTitle.flags.italic = false
defaults.questTitle.padding = 0
defaults.questTitle.maxLength = 0
defaults.questTitle.lineSpacing = 19
defaults.questTitle.text = {}
defaults.questTitle.text.size = 9
defaults.questTitle.text.font = 'sans-serif'
defaults.questTitle.text.fonts = {'Arial', 'Trebuchet MS'}
defaults.questTitle.text.alpha = 255
defaults.questTitle.text.red = 253
defaults.questTitle.text.green = 252
defaults.questTitle.text.blue = 250
defaults.questTitle.text.stroke = {}
defaults.questTitle.text.stroke.width = 2
defaults.questTitle.text.stroke.alpha = 200
defaults.questTitle.text.stroke.red = 50
defaults.questTitle.text.stroke.green = 50
defaults.questTitle.text.stroke.blue = 50
defaults.questTitle.text.visible = true
defaults.questDescription = {}
defaults.questDescription.bg = {}
defaults.questDescription.bg.alpha = 255
defaults.questDescription.bg.red = 0
defaults.questDescription.bg.green = 0
defaults.questDescription.bg.blue = 0
defaults.questDescription.bg.visible = false
defaults.questDescription.flags = {}
defaults.questDescription.flags.right = true
defaults.questDescription.flags.bottom = false
defaults.questDescription.flags.bold = false
defaults.questDescription.flags.italic = false
defaults.questDescription.padding = 0
defaults.questDescription.maxLength = 30
defaults.questDescription.lineSpacing = 15
defaults.questDescription.text = {}
defaults.questDescription.text.size = 8
defaults.questDescription.text.font = 'sans-serif'
defaults.questDescription.text.fonts = {'Arial', 'Trebuchet MS'}
defaults.questDescription.text.alpha = 255
defaults.questDescription.text.red = 253
defaults.questDescription.text.green = 252
defaults.questDescription.text.blue = 250
defaults.questDescription.text.stroke = {}
defaults.questDescription.text.stroke.width = 2
defaults.questDescription.text.stroke.alpha = 200
defaults.questDescription.text.stroke.red = 50
defaults.questDescription.text.stroke.green = 50
defaults.questDescription.text.stroke.blue = 50
defaults.questDescription.text.visible = true
defaults.questImage = {}
defaults.questImage.texture = {}
defaults.questImage.texture.fit = false
defaults.questImage.repeatable = {}
defaults.questImage.repeatable.x = 1
defaults.questImage.repeatable.y = 1

local windower_settings = windower.get_windower_settings()
local yRes = windower_settings.ui_y_res
local xRes = windower_settings.ui_x_res
local settings = config.load(defaults)
config.save(settings)

settings.questImage.draggable = false
settings.questTitle.text.draggable = false
settings.questDescription.text.draggable = false

local missions = {}
local quests = {}
local roe = {}
local trackers = {}
trackers.missions = missions
trackers.quests = quests
trackers.roe = roe

local last_y = 0
local is_hidden_by_cutscene = false
local is_hidden_by_key = false
local is_hidden_by_zoning = false

config.register(settings, function(settings)
    hide_key = settings.hideKey
    hide_key_alt = settings.hideKeyAlternate
end)

windower.register_event('load',function()
    if windower.ffxi.get_info().logged_in then
        show()
    end
end)

windower.register_event('login',function()
    show()
end)

windower.register_event('logout', function(...)
    hide()
end)

windower.register_event('addon command',function(command, ...)
    if command == 'q' then

    else
        windower.add_to_chat('8','questtracker')
    end
end)

windower.register_event('incoming chunk',function(id,org,_modi,_is_injected,_is_blocked)
    if (id == LOGIN_ZONE_PACKET) then
        is_hidden_by_zoning = false
        --print_all()
        show()
    elseif (id == ZONE_OUT_PACKET) then
        is_hidden_by_zoning = true
        hide()
    elseif (id == QUEST_UPDATE_PACKET) then
        get_all(packets.parse('incoming',org))
        print_all()
        show()
    end
end)

windower.register_event('status change', function(new_status_id)
    local is_cutscene_playing = is_cutscene(new_status_id)
    toggle_display_if_cutscene(is_cutscene_playing)
end)

windower.register_event('keyboard', function(dik, down, _flags, _blocked)
    toggle_display_if_hide_key_is_pressed(dik, down)
end)

function get_all(packet)
    get_missions(packet)
    get_quests(packet)
    get_roe(packet)
end

function get_missions(packet)
    local s = settings.missions
    if (s.enabled) then
        local nation_icon = get_nation_icon(packet['Nation'])
        create_mission(packet['Current Nation Mission'],nation_icon,s.order.nation)
        create_mission(packet['Current ROZ Mission'],'img/mission/tcre.png',s.order.roz)
        create_mission(packet['Current COP Mission'],'img/mission/tvcre.png',s.order.cop)
        create_mission(packet['Current TOAU Mission'],'img/mission/acre.png',s.order.toau)
        create_mission(packet['Current Assault Mission'],'img/mission/acre.png',s.order.assault)
        create_mission(packet['Current WOTG Mission'],'img/mission/ccre.png',s.order.wotg)
        create_mission(packet['Current Campaign Mission'],'img/mission/ccre.png',s.order.campaign)
        create_mission(packet['Current ACP Mission'],'img/mission/mcre.png',s.order.acp)
        create_mission(packet['Current MKD Mission'],'img/mission/mcre.png',s.order.mkd)
        create_mission(packet['Current ASA Mission'],'img/mission/mcre.png',s.order.asa)
        create_mission(packet['Current SOA Mission'],'img/mission/adcre.png',s.order.soa)
        create_mission(packet['Current ROV Mission'],'img/mission/rov.png',s.order.rov)
    end
end

function get_nation_icon(id)
    if (id ~= nil) then
        if id == 1 then
            return 'img/mission/bcre.png'
        elseif id == 2 then
            return 'img/mission/scre.png'
        elseif id == 3 then
            return 'img/mission/wcre.png'
        end
    end
end

function create_mission(id,icon,order)
    if (id ~= nil) then
        local mission = {}
        mission.title = {}
        mission.title.id = id
        mission.title.text = truncate_string('Back in the Saddle',settings.questTitle)
        if (settings.missions.showId) then
            mission.title.text = id..': '..mission.title.text
        end
        mission.description = {}
        mission.description.text = truncate_string('Question the residents of Ul\'dah on the Steps of Naid. 0/3',settings.questDescription)
        mission.icon = {}
        mission.icon.path = windower.addon_path..icon
        missions[order] = mission
    end
end

function get_quests(packet)
    local s = settings.quests
    local p = packet['Type']
    if (s.enabled and p ~= nil) then
        --create_quest(packet['Current Bastok Quests'],'img/mission/bcre.png',s.order.bastok)
        --create_quest(packet['Current San d\'Oria Quests'],'img/mission/scre.png',s.order.sandoria)
        --create_quest(packet['Current Windurst Quests'],'img/mission/wcre.png',s.order.windurst)
        --create_quest(packet['Current Jeuno Quests'],'img/mission/jcre.png',s.order.jeuno)
        --create_quest(packet['Current Other Quests'],'img/mission/mcre.png',s.order.other)
        --create_quest(packet['Current Outlands Quests'],'img/mission/tcre.png',s.order.outlands)
        --create_quest(packet['Current TOAU Quests and Missions (TOAU, WOTG, Assault, Campaign)'],'img/mission/acre.png',s.order.aht)
        --create_quest(packet['Current WOTG Quests'],'img/mission/ccre.png',s.order.war)
        --create_quest(packet['Current Abyssea Quests'],'img/mission/mcre.png',s.order.abyssea)
        --create_quest(packet['Current Adoulin Quests'],'img/mission/adcre.png',s.order.adoulin)
        --create_quest(packet['Current Coalition Quests'],'img/mission/adcre.png',s.order.coalition)
    end
end

function create_quest(id,icon,order)
    if (id ~= nil) then
        print(id)
    end
end

function get_roe(packet)
end

function print_all()
    last_y = 0
    print_missions()
    print_quests()
    print_roe()
end

function print_missions()
    local count = 0
    for _i,mission in ipairs(missions) do
        if (mission.title.id ~= 0 and mission.title.id ~= 65535 and count < settings.missions.maxShown) then
            print_mission(mission)
            count = count + 1
        end
    end
end

function print_mission(mission)
    print_image(settings.missions, mission.icon, settings.questImage)
    print_text(settings.missions.showTitle, mission.title, settings.questTitle,settings.missions)
    print_text(settings.missions.showDescription, mission.description, settings.questDescription,settings.missions)
end

function print_quests()
end

function print_roe()
end

function print_text(enabled, label, config, set)
    if (enabled) then
        local y = get_y(config)
        local t = get_text(config, label)
        local imageOffset = 0
        if (set.showImage) then imageOffset = set.imageWidth + 2 end
        t:pos_x(settings.pos.x - imageOffset)
        t:pos_y(y)
        t:text(label.text)
        label.item = t
        last_y = y
    end
end

function get_text(config, label)
    if (label.item ~= nil) then
        return label.item
    else
        return texts.new(config)
    end
end

function print_image(set, label, config)
    if (set.showImage) then
        local y = get_y(settings.questTitle)
        local i = images.new(config)
        i:path(label.path)
        i:size(set.imageHeight,set.imageWidth)
        i:pos(xRes + settings.pos.x - set.imageWidth,y)
        label.item = i
    end
end

function get_y(config)
    if last_y > 0 then
        return last_y + config.lineSpacing
    else
        return settings.pos.y
    end
end

function truncate_string(text,config)
    if (config.maxLength > 0) then
        return text:sub(1,config.maxLength)..'...'
    else
        return text
    end
end

function is_cutscene(status_id)
    return status_id == CUTSCENE_STATUS_ID
end

function show()
    for _k1,tracker in pairs(trackers) do
        for _k2,type in ipairs(tracker) do
            for _k3,item in pairs(type) do
                if (item.item ~= nil) then item.item:show() end
            end
        end
    end
end

function hide()
    for _k1,tracker in pairs(trackers) do
        for _k2,type in ipairs(tracker) do
            for _k3,item in pairs(type) do
                if (item.item ~= nil) then item.item:hide() end
            end
        end
    end
end

function toggle_display_if_cutscene(is_cutscene_playing)
    if not is_hidden_by_zoning then
        if (is_cutscene_playing) and (not is_hidden_by_key) then
            is_hidden_by_cutscene = true
            hide()
        elseif (not is_cutscene_playing) and (not is_hidden_by_key) then
            is_hidden_by_cutscene = false
            show()
        end
    end
end

function toggle_display_if_hide_key_is_pressed(key_pressed, key_down)
    if not is_hidden_by_zoning then
        if (key_pressed == hide_key or key_pressed == hide_key_alt) and (key_down) and (is_hidden_by_key) and (not is_hidden_by_cutscene) then
            is_hidden_by_key = false
            show()
        elseif (key_pressed == hide_key or key_pressed == hide_key_alt) and (key_down) and (not is_hidden_by_key) and (not is_hidden_by_cutscene) then
            is_hidden_by_key = true
            hide()
        end
    end
end
