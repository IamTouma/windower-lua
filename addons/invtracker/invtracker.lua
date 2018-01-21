--[[    BSD License Disclaimer
        Copyright © 2017, sylandro
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of invtracker nor the
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

_addon.name = 'invtracker'
_addon.author = 'sylandro'
_addon.version = '1.0.0'
_addon.language = 'English'

config = require('config')
images = require('images')
texts = require('texts')
res = require('resources')
packets = require('packets')

local CUTSCENE_STATUS_ID = 4
local SCROLL_LOCK_KEY = 70
local MAX_EQUIPMENT_SIZE = 16
local DEFAULT_ITEM_STATUS = 0
local EQUIPPED_ITEM_STATUS = 5
local LINKSHELL_EQUIPPED_ITEM_STATUS = 19
local BAZAAR_ITEM_STATUS = 25
local EQUIPMENT_CHANGED_PACKET = 0x50
local ITEM_UPDATE_PACKET = 0x20
local INVENTORY_FINISH_PACKET = 0x1D
local LOGIN_ZONE_PACKET = 0x0A
local TREASURE_FIND_ITEM_PACKET = 0xD2
local TREASURE_LOT_ITEM_PACKET = 0xD3
local GIL_ITEM_ID = 0xFFFF
local LINKSHELL_ACTIVE_PACKET_DATA = 19

local hideKey = SCROLL_LOCK_KEY
local is_hidden_by_cutscene = false
local is_hidden_by_key = false

defaults = {}
defaults.HideKey = SCROLL_LOCK_KEY
defaults.slotImage = {}
defaults.slotImage.spacing = 4
defaults.slotImage.blockSpacing = 4
defaults.slotImage.visible = true
defaults.slotImage.pos = {}
defaults.slotImage.pos.x = -360
defaults.slotImage.pos.y = -50
defaults.slotImage.equipment = {}
defaults.slotImage.equipment.visible = true
defaults.slotImage.equipment.maxColumns = 4
defaults.slotImage.inventory = {}
defaults.slotImage.inventory.visible = true
defaults.slotImage.inventory.maxColumns = 5
defaults.slotImage.mogSafe = {}
defaults.slotImage.mogSafe.visible = false
defaults.slotImage.mogSafe.maxColumns = 5
defaults.slotImage.mogStorage = {}
defaults.slotImage.mogStorage.visible = false
defaults.slotImage.mogStorage.maxColumns = 5
defaults.slotImage.mogLocker = {}
defaults.slotImage.mogLocker.visible = false
defaults.slotImage.mogLocker.maxColumns = 5
defaults.slotImage.mogSatchel = {}
defaults.slotImage.mogSatchel.visible = true
defaults.slotImage.mogSatchel.maxColumns = 5
defaults.slotImage.mogSack = {}
defaults.slotImage.mogSack.visible = true
defaults.slotImage.mogSack.maxColumns = 5
defaults.slotImage.mogCase = {}
defaults.slotImage.mogCase.visible = true
defaults.slotImage.mogCase.maxColumns = 5
defaults.slotImage.mogWardrobe = {}
defaults.slotImage.mogWardrobe.visible = false
defaults.slotImage.mogWardrobe.maxColumns = 5
defaults.slotImage.tempInventory = {}
defaults.slotImage.tempInventory.maxColumns = 1
defaults.slotImage.tempInventory.visible = true
defaults.slotImage.treasury = {}
defaults.slotImage.treasury.visible = true
defaults.slotImage.treasury.maxColumns = 1
defaults.slotImage.status = {}
defaults.slotImage.status.default = {}
defaults.slotImage.status.default.color = {}
defaults.slotImage.status.default.color.alpha = 255
defaults.slotImage.status.default.color.red = 0
defaults.slotImage.status.default.color.green = 170
defaults.slotImage.status.default.color.blue = 170
defaults.slotImage.status.default.background = {}
defaults.slotImage.status.default.background.color = {}
defaults.slotImage.status.default.background.color.alpha = 200
defaults.slotImage.status.default.background.color.red = 0
defaults.slotImage.status.default.background.color.green = 60
defaults.slotImage.status.default.background.color.blue = 60
defaults.slotImage.status.fullStack = {}
defaults.slotImage.status.fullStack.color = {}
defaults.slotImage.status.fullStack.color.alpha = 255
defaults.slotImage.status.fullStack.color.red = 245
defaults.slotImage.status.fullStack.color.green = 40
defaults.slotImage.status.fullStack.color.blue = 40
defaults.slotImage.status.fullStack.background = {}
defaults.slotImage.status.fullStack.background.color = {}
defaults.slotImage.status.fullStack.background.color.alpha = 200
defaults.slotImage.status.fullStack.background.color.red = 100
defaults.slotImage.status.fullStack.background.color.green = 0
defaults.slotImage.status.fullStack.background.color.blue = 0
defaults.slotImage.status.equipment = {}
defaults.slotImage.status.equipment.color = {}
defaults.slotImage.status.equipment.color.alpha = 255
defaults.slotImage.status.equipment.color.red = 253
defaults.slotImage.status.equipment.color.green = 252
defaults.slotImage.status.equipment.color.blue = 250
defaults.slotImage.status.equipment.background = {}
defaults.slotImage.status.equipment.background.color = {}
defaults.slotImage.status.equipment.background.color.alpha = 200
defaults.slotImage.status.equipment.background.color.red = 50
defaults.slotImage.status.equipment.background.color.green = 50
defaults.slotImage.status.equipment.background.color.blue = 50
defaults.slotImage.status.equipped = {}
defaults.slotImage.status.equipped.color = {}
defaults.slotImage.status.equipped.color.alpha = 255
defaults.slotImage.status.equipped.color.red = 150
defaults.slotImage.status.equipped.color.green = 255
defaults.slotImage.status.equipped.color.blue = 150
defaults.slotImage.status.equipped.background = {}
defaults.slotImage.status.equipped.background.color = {}
defaults.slotImage.status.equipped.background.color.alpha = 200
defaults.slotImage.status.equipped.background.color.red = 0
defaults.slotImage.status.equipped.background.color.green = 100
defaults.slotImage.status.equipped.background.color.blue = 0
defaults.slotImage.status.linkshellEquipped = {}
defaults.slotImage.status.linkshellEquipped.color = {}
defaults.slotImage.status.linkshellEquipped.color.alpha = 255
defaults.slotImage.status.linkshellEquipped.color.red = 150
defaults.slotImage.status.linkshellEquipped.color.green = 255
defaults.slotImage.status.linkshellEquipped.color.blue = 150
defaults.slotImage.status.linkshellEquipped.background = {}
defaults.slotImage.status.linkshellEquipped.background.color = {}
defaults.slotImage.status.linkshellEquipped.background.color.alpha = 200
defaults.slotImage.status.linkshellEquipped.background.color.red = 0
defaults.slotImage.status.linkshellEquipped.background.color.green = 100
defaults.slotImage.status.linkshellEquipped.background.color.blue = 0
defaults.slotImage.status.bazaar = {}
defaults.slotImage.status.bazaar.color = {}
defaults.slotImage.status.bazaar.color.alpha = 255
defaults.slotImage.status.bazaar.color.red = 225
defaults.slotImage.status.bazaar.color.green = 160
defaults.slotImage.status.bazaar.color.blue = 30
defaults.slotImage.status.bazaar.background = {}
defaults.slotImage.status.bazaar.background.color = {}
defaults.slotImage.status.bazaar.background.color.alpha = 200
defaults.slotImage.status.bazaar.background.color.red = 100
defaults.slotImage.status.bazaar.background.color.green = 100
defaults.slotImage.status.bazaar.background.color.blue = 0
defaults.slotImage.status.tempItem = {}
defaults.slotImage.status.tempItem.color = {}
defaults.slotImage.status.tempItem.color.alpha = 255
defaults.slotImage.status.tempItem.color.red = 255
defaults.slotImage.status.tempItem.color.green = 130
defaults.slotImage.status.tempItem.color.blue = 255
defaults.slotImage.status.tempItem.background = {}
defaults.slotImage.status.tempItem.background.color = {}
defaults.slotImage.status.tempItem.background.color.alpha = 200
defaults.slotImage.status.tempItem.background.color.red = 100
defaults.slotImage.status.tempItem.background.color.green = 0
defaults.slotImage.status.tempItem.background.color.blue = 100
defaults.slotImage.status.empty = {}
defaults.slotImage.status.empty.color = {}
defaults.slotImage.status.empty.color.alpha = 150
defaults.slotImage.status.empty.color.red = 0
defaults.slotImage.status.empty.color.green = 0
defaults.slotImage.status.empty.color.blue = 0
defaults.slotImage.status.empty.background = {}
defaults.slotImage.status.empty.background.color = {}
defaults.slotImage.status.empty.background.color.alpha = 150
defaults.slotImage.status.empty.background.color.red = 0
defaults.slotImage.status.empty.background.color.green = 0
defaults.slotImage.status.empty.background.color.blue = 0

local settings = config.load(defaults)
config.save(settings)

settings.slotImage.box = {}
settings.slotImage.box.size = {}
settings.slotImage.box.size.height = 2
settings.slotImage.box.size.width = 2
settings.slotImage.box.texture = {}
settings.slotImage.box.texture.path = windower.addon_path..'slot.png'
settings.slotImage.box.texture.fit = false
settings.slotImage.box.repeatable = {}
settings.slotImage.box.repeatable.x = 1
settings.slotImage.box.repeatable.y = 1
settings.slotImage.background = {}
settings.slotImage.background.size = {}
settings.slotImage.background.size.height = 3
settings.slotImage.background.size.width = 3
settings.slotImage.background.texture = {}
settings.slotImage.background.texture.path = windower.addon_path..'slot.png'
settings.slotImage.background.texture.fit = false
settings.slotImage.background.repeatable = {}
settings.slotImage.background.repeatable.x = 1
settings.slotImage.background.repeatable.y = 1

local windower_settings = windower.get_windower_settings()
local yRes = windower_settings.ui_y_res
local xRes = windower_settings.ui_x_res
local current_block = 0
local current_slot = 1
local current_row = 1
local current_column = 1
local last_column = 1
local items = {}
local slot_images = {}
local inventory_loaded = false
local ready = false
local last_treasure_count = 0

config.register(settings, function(settings)
    hideKey = settings.HideKey
    xBase = settings.slotImage.pos.x
    yBase = settings.slotImage.pos.y
end)

windower.register_event('load',function()
    if windower.ffxi.get_info().logged_in then
        initialize()
    end
end)

windower.register_event('login',function()
    update()
    hide()
end)

windower.register_event('logout', function(...)
    inventory_loaded = false
    hide()
    clear()
end)

windower.register_event('add item', function(id,...)
    if (id ~= GIL_ITEM_ID) then ready = true end
end)

windower.register_event('remove item', function(id,...)
    if (id ~= GIL_ITEM_ID) then ready = true end
end)

windower.register_event('linkshell change', function(new,old)
    if (old ~= new) then ready = true end
end)

windower.register_event('incoming chunk',function(id,org,_modi,_is_injected,_is_blocked)
    if (id == LOGIN_ZONE_PACKET) then
        inventory_loaded = false
    elseif (id == EQUIPMENT_CHANGED_PACKET) then
        ready = true
    elseif (id == ITEM_UPDATE_PACKET) then
        ready_if_valid_packet(org)
    elseif (id == INVENTORY_FINISH_PACKET) then
        refresh_inventory()
    elseif (id == TREASURE_FIND_ITEM_PACKET or id == TREASURE_LOT_ITEM_PACKET) then
        update_treasury()
    end
end)

windower.register_event('status change', function(new_status_id)
    local is_cutscene_playing = is_cutscene(new_status_id)
    toggle_display_if_cutscene(is_cutscene_playing)
end)

windower.register_event('keyboard', function(dik, down, _flags, _blocked)
    toggle_display_if_hide_key_is_pressed(dik, down)
end)

function refresh_inventory()
    if (ready and inventory_loaded) then
        update()
        ready = false
    elseif (not inventory_loaded) then
        initialize()
    end
end

function initialize()
    inventory_loaded = true
    update()
    if not is_hidden_by_key and not is_hidden_by_cutscene then show() end
end

function ready_if_valid_packet(packet_data)
    local p = packets.parse('incoming',packet_data)
    if (p.Status ~= LINKSHELL_ACTIVE_PACKET_DATA) then ready = true end
end

function update()
    setup_indexes()
    update_equipment()
    update_items()
end

function setup_indexes()
    current_block = 0
    last_column = 1
    items = windower.ffxi.get_items()
end

function update_equipment()
    if (settings.slotImage.equipment.visible) then
        initialize_block()
        print_equipment(items.equipment.back)
        print_equipment(items.equipment.waist)
        print_equipment(items.equipment.legs)
        print_equipment(items.equipment.feet)
        print_equipment(items.equipment.body)
        print_equipment(items.equipment.hands)
        print_equipment(items.equipment.left_ring)
        print_equipment(items.equipment.right_ring)
        print_equipment(items.equipment.head)
        print_equipment(items.equipment.neck)
        print_equipment(items.equipment.left_ear)
        print_equipment(items.equipment.right_ear)
        print_equipment(items.equipment.main)
        print_equipment(items.equipment.sub)
        print_equipment(items.equipment.range)
        print_equipment(items.equipment.ammo)
    end
end

function update_items()
    local s = settings.slotImage
    update_bag(s.inventory,items.inventory,items.max_inventory,items.enabled_inventory)
    update_bag(s.mogSafe,items.safe,items.max_safe,items.enabled_safe)
    update_bag(s.mogSafe,items.safe2,items.max_safe2,items.enabled_safe2)
    update_bag(s.mogStorage,items.storage,items.max_storage,items.enabled_storage)
    update_bag(s.mogLocker,items.locker,items.max_locker,items.enabled_locker)
    update_bag(s.mogSatchel,items.satchel,items.max_satchel,items.enabled_satchel)
    update_bag(s.mogSack,items.sack,items.max_sack,items.enabled_sack)
    update_bag(s.mogCase,items.case,items.max_case,items.enabled_case)
    update_bag(s.mogWardrobe,items.wardrobe,items.max_wardrobe,items.enabled_wardrobe)
    update_bag(s.mogWardrobe,items.wardrobe2,items.max_wardrobe2,items.enabled_wardrobe2)
    update_bag(s.mogWardrobe,items.wardrobe3,items.max_wardrobe3,items.enabled_wardrobe3)
    update_bag(s.mogWardrobe,items.wardrobe4,items.max_wardrobe4,items.enabled_wardrobe4)
    update_temp_bag(s.tempInventory,items.temporary)
    update_treasure_bag(s.treasury,items.treasure)
end

function update_treasury()
    local s = settings.slotImage
    if (inventory_loaded and s.treasury.visible) then
        setup_indexes()
        initialize_block_if_enabled(s.equipment.visible, true,s.equipment.maxColumns,MAX_EQUIPMENT_SIZE)
        initialize_block_if_enabled(s.inventory.visible,items.enabled_inventory,s.inventory.maxColumns,items.max_inventory)
        initialize_block_if_enabled(s.mogSafe.visible,items.enabled_safe,s.mogSafe.maxColumns,items.max_safe)
        initialize_block_if_enabled(s.mogSafe.visible,items.enabled_safe2,s.mogSafe.maxColumns,items.max_safe2)
        initialize_block_if_enabled(s.mogStorage.visible,items.enabled_storage,s.mogStorage.maxColumns,items.max_storage)
        initialize_block_if_enabled(s.mogLocker.visible,items.enabled_locker,s.mogLocker.maxColumns,items.max_locker)
        initialize_block_if_enabled(s.mogSatchel.visible,items.enabled_satchel,s.mogSatchel.maxColumns,items.max_satchel)
        initialize_block_if_enabled(s.mogSack.visible,items.enabled_sack,s.mogSack.maxColumns,items.max_sack)
        initialize_block_if_enabled(s.mogCase.visible,items.enabled_case,s.mogCase.maxColumns,items.max_case)
        initialize_block_if_enabled(s.mogWardrobe.visible,items.enabled_wardrobe,s.mogWardrobe.maxColumns,items.max_wardrobe)
        initialize_block_if_enabled(s.mogWardrobe.visible,items.enabled_wardrobe2,s.mogWardrobe.maxColumns,items.max_wardrobe2)
        initialize_block_if_enabled(s.mogWardrobe.visible,items.enabled_wardrobe3,s.mogWardrobe.maxColumns,items.max_wardrobe3)
        initialize_block_if_enabled(s.mogWardrobe.visible,items.enabled_wardrobe4,s.mogWardrobe.maxColumns,items.max_wardrobe4)
        initialize_block_if_enabled(s.tempInventory.visible,true,s.tempInventory.maxColumns,items.temporary.max)
        update_treasure_bag(s.treasury,items.treasure)
    end
end

function update_bag(config, bag, max, enabled)
    if (config.visible and enabled) then
        initialize_block()
        print_bag(config, bag, max)
    end
end

function update_temp_bag(config, bag)
    if (config.visible and bag.enabled) then
        initialize_block()
        for key=1,bag.max,1 do
            if bag[key].count > 0 then
                print_slot(settings.slotImage.status.tempItem,config.maxColumns,bag.max)
            else
                if slot_images[current_block][key] ~= nil then
                    slot_images[current_block][key].background:alpha(0)
                    slot_images[current_block][key].box:alpha(0)
                end
            end
        end
    end
end

function update_treasure_bag(config,bag)
    if (config.visible) then
        local treasure_count = count_treasure()
        if (treasure_count ~= last_treasure_count) then
            initialize_block()
            for k, _v in ipairs(slot_images[current_block]) do
                slot_images[current_block][k].background:alpha(0)
                slot_images[current_block][k].box:alpha(0)
            end
            for _k, _v in pairs(bag) do
                print_slot(settings.slotImage.status.tempItem,config.maxColumns,80)
            end
            last_treasure_count = treasure_count
        end
    end
end

function count_treasure()
    local count = 0
    for _k, _v in pairs(items.treasure) do count = count + 1 end
    return count
end

function initialize_block_if_enabled(visible,enabled,max_columns,last_index)
    if visible and enabled then
        initialize_block()
        current_slot = last_index
        current_column = max_columns
        update_indexes(max_columns,last_index)
    end
end

function initialize_block()
    current_block = current_block + 1
    if slot_images[current_block] == nil then
        slot_images[current_block] = {}
    end
    current_slot = 1
    current_row = 1
    current_column = 1
end

function print_equipment(status)
  if (status > 0) then
      print_slot(settings.slotImage.status.equipment,settings.slotImage.equipment.maxColumns,MAX_EQUIPMENT_SIZE)
  else
      print_slot(settings.slotImage.status.empty,settings.slotImage.equipment.maxColumns,MAX_EQUIPMENT_SIZE)
  end
end

function print_bag(config, bag, max)
    sort_table(bag)
    for key=1,max,1 do
      if (bag[key].count > 0) then
          print_item(config,bag[key],max)
      else
          print_slot(settings.slotImage.status.empty,config.maxColumns,max)
      end
    end
end

function sort_table(bag)
    table.sort(bag, function(a,b)
        if (a.status ~= b.status) then
            return a.status > b.status
        end
        if (a.count > 0 and b.count > 0) then
            full_stack_a = res.items[a.id].stack - a.count
            full_stack_b = res.items[b.id].stack - b.count
            if (full_stack_a ~= full_stack_b) then
                return full_stack_a < full_stack_b
            end
        end
        return a.count > b.count
    end)
end

function print_item(config, item, last_index)
    local s = settings.slotImage
    if (item.status == DEFAULT_ITEM_STATUS) then
        if (item.count == res.items[item.id].stack) then
            print_slot(s.status.fullStack,config.maxColumns,last_index)
        else
            print_slot(s.status.default,config.maxColumns,last_index)
        end
    elseif (item.status == EQUIPPED_ITEM_STATUS) then
        print_slot(s.status.equipped,config.maxColumns,last_index)
    elseif (item.status == LINKSHELL_EQUIPPED_ITEM_STATUS) then
        print_slot(s.status.linkshellEquipped,config.maxColumns,last_index)
    elseif (item.status == BAZAAR_ITEM_STATUS) then
        print_slot(s.status.bazaar,config.maxColumns,last_index)
    else
        print_slot(s.status.empty,config.maxColumns,last_index)
    end
end

function print_slot(status, max_columns, last_index)
    update_coordinates()
    if slot_images[current_block][current_slot] == nil then
        slot_images[current_block][current_slot] = {}
    end
    print_slot_background(status.background.color)
    print_slot_box(status.color)
    update_indexes(max_columns,last_index)
end

function print_slot_background(slot_color, max_columns, last_index)
    local slot_image = slot_images[current_block][current_slot]
    local s = settings.slotImage
    if slot_image.background == nil then
        slot_image.background = images.new(s.background)
        slot_image.background:pos(current_x,current_y)
    end
    slot_image.background:width(s.background.size.width)
    slot_image.background:height(s.background.size.height)
    slot_image.background:alpha(slot_color.alpha)
    slot_image.background:color(slot_color.red,slot_color.green,slot_color.blue)
end

function print_slot_box(slot_color, max_columns, last_index)
    local slot_image = slot_images[current_block][current_slot]
    local s = settings.slotImage
    if slot_image.box == nil then
        slot_image.box = images.new(s.box)
        slot_image.box:pos(current_x,current_y)
    end
    slot_image.box:width(s.box.size.width)
    slot_image.box:height(s.box.size.height)
    slot_image.box:color(slot_color.red,slot_color.green,slot_color.blue)
    slot_image.box:alpha(slot_color.alpha)
end

function update_coordinates()
    local s = settings.slotImage
    current_x = xRes + xBase +
        ((current_column - 1) * s.spacing) +
        ((current_block - 1) * s.blockSpacing) +
        ((last_column - 1) * s.spacing)
    current_y = yRes + yBase - ((current_row - 1) * s.spacing)
end

function update_indexes(max_columns, last_index)
    if (current_slot % max_columns) == 0 then
        if (current_slot == last_index) then
            last_column = last_column + current_column
        end
        current_column = 1
        current_row = current_row + 1
    else
        current_column = current_column + 1
    end
    current_slot = current_slot + 1
end

function show()
    for key,block in ipairs(slot_images) do
        for key,slot in ipairs(block) do
            slot.background:show()
            slot.box:show()
        end
    end
end

function hide()
    for key,block in ipairs(slot_images) do
        for key,slot in ipairs(block) do
            slot.background:hide()
            slot.box:hide()
        end
    end
end

function clear()
    slot_images = {}
end

function is_cutscene(status_id)
    return status_id == CUTSCENE_STATUS_ID
end

function toggle_display_if_cutscene(is_cutscene_playing)
    if (is_cutscene_playing) and (not is_hidden_by_key) then
        is_hidden_by_cutscene = true
        hide()
    elseif (not is_cutscene_playing) and (not is_hidden_by_key) then
        is_hidden_by_cutscene = false
        show()
    end
end

function toggle_display_if_hide_key_is_pressed(key_pressed, key_down)
    if (key_pressed == hideKey) and (key_down) and (is_hidden_by_key) and (not is_hidden_by_cutscene) then
        is_hidden_by_key = false
        show()
    elseif (key_pressed == hideKey) and (key_down) and (not is_hidden_by_key) and (not is_hidden_by_cutscene) then
        is_hidden_by_key = true
        hide()
    end
end
