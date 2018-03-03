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
            * Neither the name of npcbox nor the
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

_addon.name = 'npcbox'
_addon.author = 'sylandro'
_addon.version = '1.0.0'
_addon.language = 'English'

require('chat')
require('strings')
config = require('config')
texts = require('texts')
images = require('images')
chars = require('chat/chars')

local hide_key = SCROLL_LOCK_KEY
local SCROLL_LOCK_KEY = 70
local DEFAULT_STATUS_ID = 0
local CUTSCENE_STATUS_ID = 4
local LOGIN_ZONE_PACKET = 0x0A
local ZONE_OUT_PACKET = 0x0B
local BLUE_COLOR = '\\cs(51,153,255)'
local GREEN_COLOR = '\\cs(153,255,51)'
local RED_COLOR = '\\cs(255,102,102)'
local PINK_COLOR = '\\cs(255,102,255)'
local YELLOW_COLOR = '\\cs(255,255,102)'

defaults = {}
defaults.hideKey = SCROLL_LOCK_KEY
defaults.pos = {}
defaults.pos.x = 405
defaults.pos.y = 20
defaults.bottom = true
defaults.centered = true
defaults.width = 500
defaults.padding = {}
defaults.padding.x = 20
defaults.padding.y = 15
defaults.theme = 0
defaults.fontLineBreakFactor = 1.55
defaults.npcText = {}
defaults.npcText.bg = {}
defaults.npcText.bg.alpha = 255
defaults.npcText.bg.red = 0
defaults.npcText.bg.green = 0
defaults.npcText.bg.blue = 0
defaults.npcText.bg.visible = false
defaults.npcText.flags = {}
defaults.npcText.flags.right = false
defaults.npcText.flags.bottom = false
defaults.npcText.flags.bold = false
defaults.npcText.flags.italic = false
defaults.npcText.padding = 0
defaults.npcText.text = {}
defaults.npcText.text.size = 12
defaults.npcText.text.font = 'sans-serif'
defaults.npcText.text.fonts = {'Arial', 'Trebuchet MS'}
defaults.npcText.text.alpha = 255
defaults.npcText.text.red = 253
defaults.npcText.text.green = 252
defaults.npcText.text.blue = 250
defaults.npcText.text.stroke = {}
defaults.npcText.text.stroke.width = 2
defaults.npcText.text.stroke.alpha = 200
defaults.npcText.text.stroke.red = 50
defaults.npcText.text.stroke.green = 50
defaults.npcText.text.stroke.blue = 50
defaults.npcText.text.visible = true
defaults.npcName = {}
defaults.npcName.bg = {}
defaults.npcName.bg.alpha = 255
defaults.npcName.bg.red = 0
defaults.npcName.bg.green = 0
defaults.npcName.bg.blue = 0
defaults.npcName.bg.visible = false
defaults.npcName.flags = {}
defaults.npcName.flags.right = false
defaults.npcName.flags.bottom = false
defaults.npcName.flags.bold = false
defaults.npcName.flags.italic = false
defaults.npcName.padding = 0
defaults.npcName.verticalSpacing = 30
defaults.npcName.text = {}
defaults.npcName.text.size = 12
defaults.npcName.text.font = 'sans-serif'
defaults.npcName.text.fonts = {'Arial', 'Trebuchet MS'}
defaults.npcName.text.alpha = 255
defaults.npcName.text.red = 253
defaults.npcName.text.green = 252
defaults.npcName.text.blue = 250
defaults.npcName.text.stroke = {}
defaults.npcName.text.stroke.width = 2
defaults.npcName.text.stroke.alpha = 200
defaults.npcName.text.stroke.red = 50
defaults.npcName.text.stroke.green = 50
defaults.npcName.text.stroke.blue = 50
defaults.npcName.text.visible = true
defaults.backgroundImage = {}
defaults.backgroundImage.size = {}
defaults.backgroundImage.size.x = 128
defaults.backgroundImage.size.y = 128
defaults.cornerBorderImage = {}
defaults.cornerBorderImage.size = {}
defaults.cornerBorderImage.size.x = 8
defaults.cornerBorderImage.size.y = 8
defaults.horizontalBorderImage = {}
defaults.horizontalBorderImage.size = {}
defaults.horizontalBorderImage.size.x = 32
defaults.horizontalBorderImage.size.y = 4
defaults.verticalBorderImage = {}
defaults.verticalBorderImage.size = {}
defaults.verticalBorderImage.size.x = 4
defaults.verticalBorderImage.size.y = 32
defaults.indicatorImage = {}
defaults.indicatorImage.size = {}
defaults.indicatorImage.size.x = 15
defaults.indicatorImage.size.y = 17

local settings = config.load(defaults)
config.save(settings)

settings.npcText.text.draggable = false
settings.npcName.text.draggable = false
settings.boxImage = {}
settings.boxImage.texture = {}
settings.boxImage.texture.fit = false
settings.boxImage.repeatable = {}
settings.boxImage.repeatable.x = 1
settings.boxImage.repeatable.y = 1
settings.boxImage.color = {}
settings.boxImage.color.alpha = 225
settings.boxImage.color.red = 255
settings.boxImage.color.green = 255
settings.boxImage.color.blue = 255
settings.boxImage.draggable = false

local name = ''
local text = ''
local max_line_length = 0
local dismiss_time = 0
local is_hidden_by_cutscene = false
local is_hidden_by_key = false
local is_hidden_by_zoning = false

config.register(settings, function(settings)
    update_defaults()
    create_texts()
    create_images()
    set_paths()
end)

windower.register_event('logout', function(...)
    hide()
end)

windower.register_event('incoming chunk',function(id,org,_modi,_is_injected,_is_blocked)
    if (id == LOGIN_ZONE_PACKET) then
        is_hidden_by_zoning = false
    elseif (id == ZONE_OUT_PACKET) then
        is_hidden_by_zoning = true
        hide()
    end
end)

windower.register_event('status change', function(status_id)
    print('status change: '..status_id)
    toggle_display_if_cutscene(status_id)
end)

windower.register_event('keyboard', function(dik, down, _flags, _blocked)
    toggle_display_if_hide_key_is_pressed(dik, down)
end)

windower.register_event('incoming text', function(original, _modified, mode, _modified_mode)
    print(mode..' '..original)
    if (mode == 150 or mode == 151 or mode == 144 or mode == 148) then
        local cut = original:find(' : ')
        local new_text = ''
        if (cut ~= nil) then
            name = original:sub(1,cut)
            new_text = original:sub(cut+3)
        elseif (mode == 150) then
            new_text = original:sub(3)
        elseif (last_mode == 144) then
            new_text = original
        else
            name = ''
            new_text = original
        end
        if last_mode == 144 then
            text = text..'\n'..new_text
        else
            text = new_text
        end
        --windower.add_to_chat(8,text:tohex())
        if (text:endswith(string.char(0x07))) then text = text:sub(1,-2) end
        replace_chars()
        set_dismiss_time(mode)
        text_ready = true
        last_mode = mode
    end
end)

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

windower.register_event('postrender', function(...)
    if display_ready then prepare_box() end
    if text_ready then prepare_text() end
end)

function update_defaults()
    windower_settings = windower.get_windower_settings()
    x_res = windower_settings.ui_x_res
    y_res = windower_settings.ui_y_res
    x_ratio = windower_settings.x_res / x_res
    y_ratio = windower_settings.y_res / y_res
    hide_key = settings.hideKey
    max_line_length = math.floor((settings.width - (settings.padding.x*2))/ (settings.npcText.text.size/settings.fontLineBreakFactor))
    default_color = '\\cs('..settings.npcText.text.red..','..settings.npcText.text.green..','..settings.npcText.text.blue..')'
end

function create_texts()
    npc_text = texts.new(settings.npcText)
    npc_name = texts.new(settings.npcName)
end

function create_images()
    bg_background = images.new(settings.boxImage)
    bg_border_ul = images.new(settings.boxImage)
    bg_border_ur = images.new(settings.boxImage)
    bg_border_bl = images.new(settings.boxImage)
    bg_border_br = images.new(settings.boxImage)
    bg_border_l = images.new(settings.boxImage)
    bg_border_r = images.new(settings.boxImage)
    bg_border_u = images.new(settings.boxImage)
    bg_border_b = images.new(settings.boxImage)
    indicator = images.new(settings.indicatorImage)
end

function set_paths()
    set_path(bg_background,'/bg.png')
    set_path(bg_border_ul,'/border_ul.png')
    set_path(bg_border_ur,'/border_ur.png')
    set_path(bg_border_bl,'/border_bl.png')
    set_path(bg_border_br,'/border_br.png')
    set_path(bg_border_l,'/border_l.png')
    set_path(bg_border_r,'/border_r.png')
    set_path(bg_border_u,'/border_u.png')
    set_path(bg_border_b,'/border_b.png')
    change_indicator_path(1)

end

function change_indicator_path(index)
    indicator_index = index
    indicator:path(windower.addon_path..'points'..index..'.png')
end

function set_path(image, path)
    image:path(windower.addon_path..'themes/'..settings.theme..path)
end

function prepare_box()
    set_box_extents()
    display_ready = false
end

function set_box_extents()
    local tx,ty = npc_text:extents()
    local text_width = tx*x_ratio
    local text_height = ty*y_ratio
    local _,ny = npc_name:extents()

    local vertical_spacing = 0
    local name_height = 0
    if name:length() > 0 then
        name_height = (ny*y_ratio)
        vertical_spacing = settings.npcName.verticalSpacing
    end
    local height = text_height + name_height + settings.npcName.verticalSpacing

    local box_x = settings.pos.x
    local width = settings.width
    if settings.centered then
        width = text_width + (settings.padding.x * 2)
        box_x = (x_res / 2) - (width/2)
    end
    local box_y = settings.pos.y
    if settings.bottom then
        box_y = y_res - settings.pos.y - height
    end

    npc_name:pos(box_x + settings.padding.x, box_y + settings.padding.y)
    npc_text:pos(box_x + settings.padding.x, box_y + settings.padding.y + vertical_spacing)

    bg_background:size(settings.backgroundImage.size.x, settings.backgroundImage.size.y)
    bg_background:repeat_xy(x_ratio,y_ratio)
    bg_background:width(width)
    bg_background:height(height)
    bg_background:pos(box_x,box_y)

    local corner_width = settings.cornerBorderImage.size.x
    local corner_height = settings.cornerBorderImage.size.y

    bg_border_ul:pos(box_x,box_y)
    bg_border_ul:size(corner_width,corner_height)
    bg_border_ul:repeat_xy(1,1)

    bg_border_ur:pos(box_x + width - corner_width, box_y)
    bg_border_ur:size(corner_width,corner_height)
    bg_border_ur:repeat_xy(1,1)

    bg_border_bl:pos(box_x,box_y + height - corner_height)
    bg_border_bl:size(corner_width,corner_height)
    bg_border_bl:repeat_xy(1,1)

    bg_border_br:pos(box_x + width - corner_width,box_y + height - corner_height)
    bg_border_br:size(corner_width,corner_height)
    bg_border_br:repeat_xy(1,1)

    if indicator_thread == nil or coroutine.status(indicator_thread) == 'dead' then
        indicator_thread = coroutine.schedule(iterate_indicator, 0.05)
    end
    indicator:pos(box_x + width - corner_width - settings.indicatorImage.size.x,
        box_y + height - corner_height - settings.indicatorImage.size.y)
    indicator:size(settings.indicatorImage.size.x,settings.indicatorImage.size.y)

    bg_border_l:pos(box_x, box_y + corner_height)
    bg_border_l:width(settings.verticalBorderImage.size.x)
    bg_border_l:height(height - corner_height*2)
    bg_border_l:repeat_xy(1,y_ratio)

    bg_border_r:pos(box_x + width - settings.verticalBorderImage.size.x, box_y + corner_height)
    bg_border_r:width(settings.verticalBorderImage.size.x)
    bg_border_r:height(height - corner_height*2)
    bg_border_r:repeat_xy(1,y_ratio)

    bg_border_u:pos(box_x + corner_width,box_y)
    bg_border_u:width(width - corner_width*2)
    bg_border_u:height(settings.horizontalBorderImage.size.y)
    bg_border_u:repeat_xy(x_ratio,1)

    bg_border_b:pos(box_x + corner_width,box_y + height - settings.horizontalBorderImage.size.y)
    bg_border_b:width(width - corner_width*2)
    bg_border_b:height(settings.horizontalBorderImage.size.y)
    bg_border_b:repeat_xy(x_ratio,1)
    show()
end

function iterate_indicator()
    if indicator:visible() then
        if indicator_index == 6 then
            change_indicator_path(1)
        else
            change_indicator_path(indicator_index + 1)
        end
        indicator_thread = coroutine.schedule(iterate_indicator, 0.05)
    end
end

function set_dismiss_time(mode)
    if mode == 143 or mode == 144 or mode == 148 then
        dismiss_time = 5
    else
        dismiss_time = 0
    end
    if clear_thread ~= nil and coroutine.status(clear_thread) ~= 'dead' then
        coroutine.close(clear_thread)
    end
    clear_thread = coroutine.schedule(clear,dismiss_time)
end

function prepare_text()
    npc_name:text(name)
    npc_text:text('')
    for _,line in ipairs(text:split('\n')) do
        append_bound_line(line)
    end
    npc_text:show()
    npc_name:show()
    text_ready = false
    display_ready = true
end

function append_bound_line(line)
    local excess_width = line:text_strip_format():length() - max_line_length
    if (excess_width > 0) then
        append_line_on_last_space(line)
    else
        append_line(line)
    end
end

function append_line_on_last_space(line)
    local token_count = 0
    for _ in line:gmatch('\\cs%(%s*%d+,%s*%d+,%s*%d+%s*%)(.-)') do token_count = token_count + 1 end
    local max_allowable_length = max_line_length+(token_count*7)
    local last_space = line:sub(1,max_allowable_length):reverse():find(string.char(0x20))
    if last_space ~= nil then
        last_space = max_allowable_length - last_space + 1
        append_line(line:sub(1,last_space))
        append_bound_line(line:sub(last_space+1))
    else
        append_line(line)
    end
end

function append_line(line)
    npc_text:text(npc_text:text()..line..'\n')
end

function is_sentence(line)
    return line:endswith(string.char(0x2E))
end

function show()
    if npc_text:text():length() > 0 then
        npc_text:show()
        npc_name:show()
        bg_background:show()
        bg_border_ul:show()
        bg_border_ur:show()
        bg_border_bl:show()
        bg_border_br:show()
        bg_border_l:show()
        bg_border_r:show()
        bg_border_u:show()
        bg_border_b:show()
        if dismiss_time == 0 then indicator:show() end
    end
end

function clear()
    npc_text:text('')
    npc_name:text('')
    hide()
end

function hide()
    npc_text:hide()
    npc_name:hide()
    bg_background:hide()
    bg_border_ul:hide()
    bg_border_ur:hide()
    bg_border_bl:hide()
    bg_border_br:hide()
    bg_border_b:hide()
    bg_border_u:hide()
    bg_border_l:hide()
    bg_border_r:hide()
    indicator:hide()
    dismiss_time = 0
end

function replace_chars()
    text = text:gsub(string.char(0x20, 0x7F, 0x36, 0x01),'')
    text = text:gsub(string.char(0x7F, 0x31), '')
    text = text:gsub(string.char(0x07),'\n')
    text = text:gsub(string.char(0x87,0xB2),'“')
    text = text:gsub(string.char(0x87,0xB3),'”')
    text = text:gsub(chars.query,'?')
    text = text:gsub(chars.plus,'+')
    text = text:gsub(chars.minus,'−')
    text = text:gsub(chars.plusminus,'±')
    text = text:gsub(chars.times,'×')
    text = text:gsub(chars.div,'÷')
    text = text:gsub(chars.eq,'=')
    text = text:gsub(chars.neq,'≠')
    text = text:gsub(chars.lt,'<')
    text = text:gsub(chars.gt,'>')
    text = text:gsub(chars.leq,'≤')
    text = text:gsub(chars.geq,'≥')
    text = text:gsub(chars.ll,'≪')
    text = text:gsub(chars.gg,'≫')
    text = text:gsub(chars.root,'√')
    text = text:gsub(chars.inf,'∞')
    text = text:gsub(chars.prop,'∝')
    text = text:gsub(chars.ninf,'⧞')
    text = text:gsub(chars.nearlyeq,'≈')
    text = text:gsub(chars.sharp,'♯')
    text = text:gsub(chars.flat,'♭')
    text = text:gsub(chars.note,'♪')
    text = text:gsub(chars.male,'♂')
    text = text:gsub(chars.female,'♀')
    text = text:gsub(chars.percent,'%')
    text = text:gsub(chars.permil,'‰')
    text = text:gsub(chars.circle,'○')
    text = text:gsub(chars.cdegree,'°')
    text = text:gsub(chars.tm,'™')
    text = text:gsub(chars.copy,'©')
    text = text:gsub(chars.wave,'~')
    text = text:gsub(string.char(0x1E, 0x01),default_color)
    text = text:gsub(string.char(0x1E, 0x02),GREEN_COLOR)
    text = text:gsub(string.char(0x1E, 0x03),BLUE_COLOR)
    text = text:gsub(string.char(0x1E, 0x04),RED_COLOR)
    text = text:gsub(string.char(0x1E, 0x05),PINK_COLOR)
    text = text:gsub(string.char(0x1F, 0x8D),YELLOW_COLOR)
end

function toggle_display_if_cutscene(status_id)
    local cutscene_playing = (status_id == CUTSCENE_STATUS_ID)
    local cutscene_ended = (status_id == DEFAULT_STATUS_ID)
    if not is_hidden_by_zoning then
        if (cutscene_playing) and (not is_hidden_by_key) then
            is_hidden_by_cutscene = true
        elseif (cutscene_ended) and (not is_hidden_by_key) then
            is_hidden_by_cutscene = false
            clear()
        end
    end
end

function toggle_display_if_hide_key_is_pressed(key_pressed, key_down)
    if not is_hidden_by_zoning then
        if (key_pressed == hide_key) and (key_down) and (is_hidden_by_key) then
            is_hidden_by_key = false
            show()
        elseif (key_pressed == hide_key) and (key_down) and (not is_hidden_by_key) then
            is_hidden_by_key = true
            hide()
        end
    end
end
