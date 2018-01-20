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
            * Neither the name of giltracker nor the
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

_addon.name = 'giltracker'
_addon.author = 'sylandro'
_addon.version = '1.0.0'
_addon.language = 'English'

config = require('config')
texts = require('texts')
res = require('resources')

local LOGIN_ZONE_PACKET = 0x0A

defaults = {}
defaults.zoneName = {}
defaults.zoneName.pos = {}
defaults.zoneName.pos.x = 0
defaults.zoneName.pos.y = 0
defaults.zoneName.bg = {}
defaults.zoneName.bg.alpha = 255
defaults.zoneName.bg.red = 0
defaults.zoneName.bg.green = 0
defaults.zoneName.bg.blue = 0
defaults.zoneName.bg.visible = false
defaults.zoneName.flags = {}
defaults.zoneName.flags.right = false
defaults.zoneName.flags.bottom = false
defaults.zoneName.flags.bold = true
defaults.zoneName.flags.italic = false
defaults.zoneName.padding = 0
defaults.zoneName.text = {}
defaults.zoneName.text.size = 36
defaults.zoneName.text.centerAdjust = 3
defaults.zoneName.text.font = 'Century Schoolbook'
defaults.zoneName.text.fonts = {'sans-serif', 'Arial', 'Trebuchet MS'}
defaults.zoneName.text.alpha = 85
defaults.zoneName.text.red = 255
defaults.zoneName.text.green = 255
defaults.zoneName.text.blue = 193
defaults.zoneName.text.stroke = {}
defaults.zoneName.text.stroke.width = 4
defaults.zoneName.text.stroke.alpha = 30
defaults.zoneName.text.stroke.red = 51
defaults.zoneName.text.stroke.green = 47
defaults.zoneName.text.stroke.blue = 38
defaults.zoneName.text.visible = true
defaults.zoneName.format = '%s'
defaults.regionName = {}
defaults.regionName.pos = {}
defaults.regionName.pos.x = 0
defaults.regionName.pos.y = 0
defaults.regionName.bg = {}
defaults.regionName.bg.alpha = 255
defaults.regionName.bg.red = 0
defaults.regionName.bg.green = 0
defaults.regionName.bg.blue = 0
defaults.regionName.bg.visible = false
defaults.regionName.flags = {}
defaults.regionName.flags.right = false
defaults.regionName.flags.bottom = false
defaults.regionName.flags.bold = true
defaults.regionName.flags.italic = false
defaults.regionName.padding = 0
defaults.regionName.text = {}
defaults.regionName.text.size = 24
defaults.regionName.text.centerAdjust = 4
defaults.regionName.text.font = 'Century Schoolbook'
defaults.regionName.text.fonts = {'sans-serif', 'Arial', 'Trebuchet MS'}
defaults.regionName.text.alpha = 85
defaults.regionName.text.red = 255
defaults.regionName.text.green = 255
defaults.regionName.text.blue = 193
defaults.regionName.text.stroke = {}
defaults.regionName.text.stroke.width = 4
defaults.regionName.text.stroke.alpha = 30
defaults.regionName.text.stroke.red = 51
defaults.regionName.text.stroke.green = 47
defaults.regionName.text.stroke.blue = 38
defaults.regionName.text.visible = true
defaults.regionName.format = '- %s -'
defaults.centered = true
defaults.fadeTime = 1
defaults.displayTime = 3
defaults.waitTime = 3

local settings = config.load(defaults)
config.save(settings)

settings.zoneName.text.draggable = false
settings.regionName.text.draggable = false

region_to_zone_map = {
    [0] = S{230,231,232,233,223},
    [1] = S{234,235,236,237,224},
    [2] = S{238,239,240,241,242,225},
    [3] = S{243,244,245,246},
    [4] = S{100,101,139,140,141,142,167,190},
    [5] = S{102,103,108,193,196,248,221,228},
    [6] = S{1,2,104,105,149,150,195},
    [7] = S{106,107,143,144,172,173,191},
    [8] = S{109,110,147,148,197},
    [9] = S{115,116,145,146,169,170,192,194},
    [10] = S{3,4,117,118,198,213,249,46,220,227},
    [11] = S{7,8,119,120,151,152,200},
    [12] = S{9,10,111,166,203,204,206},
    [13] = S{5,6,112,161,162,165},
    [14] = S{126,127,157,158,179,184},
    [15] = S{121,122,153,154,202,251},
    [16] = S{114,125,168,208,209,247},
    [17] = S{113,128,174,201,212,128},
    [18] = S{123,176,250,252,226},
    [19] = S{124,159,160,163,205,207,211},
    [20] = S{130,177,178,180,181},
    [21] = S{39,40,41,42,134,135,185,186,187,188,294,295},
    [22] = S{11,12,13},
    [23] = S{26},
    [24] = S{24,25,27,28,29,30,31,32},
    [25] = S{14,16,17,18,19,20,21,22,23},
    [26] = S{33,34,35,36},
    [27] = S{37,38},
    [28] = S{48,50,53,46,58,59,47},
    [29] = S{52,71},
    [30] = S{65,66,67,68,51},
    [31] = S{61,62,63,64},
    [32] = S{54,55,56,57,60,69,78,79},
    [33] = S{72,73,74,75,76,77},
    [34] = S{80,81,86},
    [35] = S{82,84,175},
    [36] = S{87,88,89,93},
    [37] = S{83,90,91,171},
    [38] = S{94,95,96,129},
    [39] = S{97,98,164},
    [40] = S{136},
    [41] = S{137},
    [42] = S{85},
    [43] = S{92},
    [44] = S{99},
    [45] = S{155,138,156},
    [46] = S{15,45,132,215,216,217,218,253,254,255},
    [47] = S{182,222},
    [48] = S{43,44,183},
    [49] = S{256,257,284},
    [50] = S{280,258},
    [51] = S{259,260,261,262,263,265,266,267,268,269,270,271,272,273,281,264,282},
    [52] = S{274,276,277,275},
    [53] = S{288,289},
    [54] = S{291,292,293},
}

local last_update = 0
local zone_text = texts.new(settings.zoneName)
local region_text = texts.new(settings.regionName)

config.register(settings, function(settings)
    windower_settings = windower.get_windower_settings()
    xRes = windower_settings.ui_x_res
    yRes = windower_settings.ui_y_res
    local fade_millis = settings.fadeTime * 25
    zone_fade_step = settings.zoneName.text.alpha / fade_millis
    zone_stroke_fade_step = settings.zoneName.text.stroke.alpha / fade_millis
    region_fade_step = settings.regionName.text.alpha / fade_millis
    region_stroke_fade_step = settings.zoneName.text.stroke.alpha / fade_millis
end)

windower.register_event('incoming chunk',function(id,org,_modi,_is_injected,_is_blocked)
    if (id == LOGIN_ZONE_PACKET) then
        setup_zone()
    end
end)

windower.register_event('prerender',function()
    if ready then display() end
end)

function setup_zone()
    setup_names()
    center_text()
    setup_text(zone_text,zone_name)
    setup_text(region_text,region_name)
    ready = true
    last_update = os.clock()
end

function setup_names()
    local zone_id = windower.ffxi.get_info().zone
    zone_name = string.format(settings.zoneName.format,res.zones[zone_id].en)
    region_name = 'Unknown'
    for i,v in pairs(region_to_zone_map) do
        if v:contains(zone_id) then
            region_name = res.regions[i].en
        end
    end
    region_name = string.format(settings.regionName.format,region_name)
end

function center_text()
    if (settings.centered) then
        zone_text:pos(math.ceil((xRes/2) - (string.len(zone_name) * (settings.zoneName.text.size / settings.zoneName.text.centerAdjust))),
            (yRes/2) - (settings.zoneName.text.size * 2))
        region_text:pos(math.ceil((xRes/2) - (string.len(region_name) * (settings.regionName.text.size / settings.regionName.text.centerAdjust))),
            zone_text:pos_y() - (settings.regionName.text.size * 2))
    end
end

function setup_text(textbox,text)
    textbox:text(text)
    textbox:alpha(0)
    textbox:stroke_alpha(0)
    textbox:show()
end

function display()
    local time = os.clock() - last_update
    if (time > (settings.fadeTime * 2) + settings.displayTime + settings.waitTime) then
        hide()
    elseif (time > settings.fadeTime + settings.displayTime + settings.waitTime) then
        fade_out()
    elseif (time > settings.waitTime and time <= settings.fadeTime + settings.waitTime) then
        fade_in()
    end
end

function hide()
    ready = false
    zone_text:hide()
    region_text:hide()
end

function fade_in()
    add_alpha(zone_text:alpha() + zone_fade_step,zone_text)
    add_stroke_alpha(zone_text:stroke_alpha() + zone_fade_step,zone_text)
    add_alpha(region_text:alpha() + region_fade_step,region_text)
    add_stroke_alpha(region_text:stroke_alpha() + region_fade_step,region_text)
end

function add_alpha(alpha,textbox)
    if (alpha < 255) then
        textbox:alpha(alpha)
    end
end

function add_stroke_alpha(alpha,textbox)
    if (alpha < 255) then
        textbox:stroke_alpha(alpha)
    end
end

function fade_out()
    substract_alpha(zone_text:alpha() - zone_fade_step,zone_text)
    substract_stroke_alpha(zone_text:stroke_alpha() - zone_fade_step,zone_text)
    substract_alpha(region_text:alpha() - region_fade_step,region_text)
    substract_stroke_alpha(region_text:stroke_alpha() - region_fade_step,region_text)
end

function substract_alpha(alpha,textbox)
    if (alpha >= 0) then
        textbox:alpha(alpha)
    end
end

function substract_stroke_alpha(alpha,textbox)
    if (alpha >= 0) then
        textbox:stroke_alpha(alpha)
    end
end
