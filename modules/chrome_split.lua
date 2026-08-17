-- Chrome: 현재 탭 URL을 split view로 복제
--   0) Chrome이 지금 사용중인 전제로 진행
--   1) 현재 탭 URL + 활성 탭 id 읽기
--   2) split view 켜기 (cmd-opt-n)
--   3) 활성 탭 id가 바뀌면(=새 pane 생성됨) 같은 URL 쓰고 열기
--      바뀌지 않으면(=이미 split 되었거나 읽기 실패) 아무것도 안 함

local HOTKEY_MODS = { "cmd", "alt" }
local HOTKEY_KEY = ","
local POLL_INTERVAL = 0.20 -- 폴링 간격(초)
local POLL_TIMEOUT  = 2.00 -- 최대 대기(초)

local function chromeIsFrontmost()
    local app = hs.application.frontmostApplication()
    return app ~= nil and app:bundleID() == "com.google.Chrome"
end

local function getActiveTabId()
    local ok, id = hs.osascript.applescript(
        'tell application "Google Chrome" to return (id of active tab of front window)'
    )
    if ok then return id end
    return nil
end

local function setActiveTabUrl(url)
    local safeUrl = url:gsub('\\', '\\\\'):gsub('"', '\\"')
    local ok = hs.osascript.applescript(
        'tell application "Google Chrome" to set URL of active tab of front window to "'
        .. safeUrl .. '"'
    )
    if not ok then
        hs.alert.show("split pane에 URL을 열지 못했습니다")
    end
end

local function openCurrentUrlInSplit()
    -- 0)
    if not chromeIsFrontmost() then return end

    -- 1)
    local ok, url = hs.osascript.applescript(
        'tell application "Google Chrome" to return (URL of active tab of front window)'
    )
    if not ok or type(url) ~= "string" or url == "" then
        hs.alert.show("Chrome URL을 가져오지 못했습니다")
        return
    end
    local baseId = getActiveTabId()
    if baseId == nil then
        hs.alert.show("활성 탭 id를 읽지 못했습니다")
        return
    end

    -- 2)
    hs.eventtap.keyStroke({ "cmd", "alt" }, "n")

    -- 3)
    local elapsed = 0
    local function poll()
        local activeTabId = getActiveTabId()
        if activeTabId ~= nil and activeTabId ~= baseId then
            setActiveTabUrl(url)
        elseif elapsed < POLL_TIMEOUT then
            elapsed = elapsed + POLL_INTERVAL
            hs.timer.doAfter(POLL_INTERVAL, poll)
        end -- 읽기실패/타임아웃 시 아무것도 안함
    end
    hs.timer.doAfter(POLL_INTERVAL, poll)
end

hs.hotkey.bind(HOTKEY_MODS, HOTKEY_KEY, openCurrentUrlInSplit)
