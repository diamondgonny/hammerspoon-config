local boxes = {}
local inputEnglish = "com.apple.keylayout.ABC"
local box_height = 29
local box_alpha = 0.35
local GREEN = hs.drawing.color.osx_green
local lastInputSource = hs.keycodes.currentSourceID()
local soundToggle = hs.sound.getByName("Tink")

function sync_aurora()
    local currentSource = hs.keycodes.currentSourceID()
    -- 입력소스가 변경되었을 때만 효과음 재생
    if currentSource ~= lastInputSource then
        soundToggle:play()
        lastInputSource = currentSource
    end

    disable_show()
    if currentSource ~= inputEnglish then
        enable_show()
    end
end

function enable_show()
    reset_boxes()
    hs.fnutils.each(hs.screen.allScreens(), function(scr)
        local frame = scr:fullFrame()

        local box = newBox()
        draw_rectangle(box, frame.x, frame.y, frame.w, box_height, GREEN)
        table.insert(boxes, box)

        local box2 = newBox()
        draw_rectangle(box2, frame.x, frame.y + frame.h - 10, frame.w, box_height, GREEN)
        table.insert(boxes, box2)
    end)
end

function disable_show()
    hs.fnutils.each(boxes, function(box)
        if box ~= nil then
            box:delete()
        end
    end)
    reset_boxes()
end

function newBox()
    return hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
end

function reset_boxes()
    boxes = {}
end

function draw_rectangle(target_draw, x, y, width, height, fill_color)
    -- 그릴 영역 크기를 잡는다
    target_draw:setSize(hs.geometry.rect(x, y, width, height))
    -- 그릴 영역의 위치를 잡는다
    target_draw:setTopLeft(hs.geometry.point(x, y))

    target_draw:setFillColor(fill_color)
    target_draw:setFill(true)
    target_draw:setAlpha(box_alpha)
    target_draw:setLevel(hs.drawing.windowLevels.overlay)
    target_draw:setStroke(false)
    target_draw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    target_draw:show()
end

-- 1. Event Trigger (inputSourceChanged)로 신호가 발생하나 어떤 입력소스가 활성화되었는지 안 알려줌
-- 2. 그 정보를 얻기 위해 다시 macos에 hs.keycodes.currentSourceID()로 정보 요청
-- 3. 1, 2의 시간 차이로 인해 입력소스가 바뀌었을 때 aurora 상태가 언어 상태와 일치하지 않는 경우가 생김

-- 5초에 한 번씩 aurora 상태가 언어 상태와 일치하는지 확인한다
hs.timer.doEvery(5, sync_aurora)
-- 입력소스 변경 이벤트에 이벤트 리스너를 달아준다
hs.keycodes.inputSourceChanged(sync_aurora)
