local INPUT_ENGLISH = "com.apple.keylayout.ABC"
local BOX_HEIGHT = 29
local BOX_ALPHA = 0.35
local GREEN = hs.drawing.color.osx_green

local boxes = {}
local soundPool = {}
local soundPoolIndex = 1

local function play_capslock_sound()
    if #soundPool == 0 then return end
    soundPool[soundPoolIndex]:stop()
    soundPool[soundPoolIndex]:play()
    soundPoolIndex = soundPoolIndex % #soundPool + 1
end

local function on_capslock(event)
    -- keyCode 255: 입력소스 전환 이벤트
    if event:getKeyCode() == 255 then play_capslock_sound() end
    return false
end

local function reset_boxes()
    boxes = {}
end

local function newBox()
    return hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
end

local function draw_rectangle(target_draw, x, y, width, height, fill_color)
    target_draw:setSize(hs.geometry.rect(x, y, width, height))
    target_draw:setTopLeft(hs.geometry.point(x, y))
    target_draw:setFillColor(fill_color)
    target_draw:setFill(true)
    target_draw:setAlpha(BOX_ALPHA)
    target_draw:setLevel(hs.drawing.windowLevels.overlay)
    target_draw:setStroke(false)
    target_draw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    target_draw:show()
end

local function enable_show()
    reset_boxes()
    hs.fnutils.each(hs.screen.allScreens(), function(scr)
        local frame = scr:fullFrame()

        local box = newBox()
        draw_rectangle(box, frame.x, frame.y, frame.w, BOX_HEIGHT, GREEN)
        table.insert(boxes, box)

        local box2 = newBox()
        draw_rectangle(box2, frame.x, frame.y + frame.h - 10, frame.w, BOX_HEIGHT, GREEN)
        table.insert(boxes, box2)
    end)
end

local function disable_show()
    hs.fnutils.each(boxes, function(box)
        if box ~= nil then
            box:delete()
        end
    end)
    reset_boxes()
end

local function sync_aurora()
    local currentSource = hs.keycodes.currentSourceID()
    disable_show()
    if currentSource ~= INPUT_ENGLISH then
        enable_show()
    end
end

-- 1. Event Trigger (inputSourceChanged)로 신호가 발생하나 어떤 입력소스가 활성화되었는지 안 알려줌
-- 2. 그 정보를 얻기 위해 다시 macos에 hs.keycodes.currentSourceID()로 정보 요청
-- 3. 1, 2의 시간 차이로 인해 입력소스가 바뀌었을 때 aurora 상태가 언어 상태와 일치하지 않는 경우가 생김

-- 5초에 한 번씩 aurora 상태가 언어 상태와 일치하는지 확인한다
-- hs.timer.doEvery(5, sync_aurora)

local function setup_watchers()
    -- 리로드 시 이전 인스턴스를 정리한다
    if hs.inputsource_aurora and hs.inputsource_aurora.capslockWatcher then
        hs.inputsource_aurora.capslockWatcher:stop()
    end
    -- 사운드 풀을 초기화한다
    soundPool = {}
    for _ = 1, 4 do
        local sound = hs.sound.getByFile("/System/Library/Sounds/Tink.aiff")
        if sound then table.insert(soundPool, sound) end
    end
    -- Capslock 키 입력 시 사운드를 재생하는 watcher를 등록한다
    hs.inputsource_aurora = {
        capslockWatcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, on_capslock):start()
    }
    -- 입력소스 변경 이벤트에 이벤트 리스너를 달아준다
    hs.keycodes.inputSourceChanged(sync_aurora)
end

setup_watchers()
