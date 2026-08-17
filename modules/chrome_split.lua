-- Chrome: 현재 탭 URL을 split view로 복제
--   1) 활성 탭의 {id, URL, 탭 수}를 AppleScript으로 스냅샷
--   2) split view 켜기 (cmd-opt-n)
--   3) "활성 탭 id 변경 + 탭 수 +1 + 새 탭이 빈 split pane 페이지"일 때,
--      검증하고 URL 열기
--   참고) GC 방지를 위해 작업하는 동안 M이라는 테이블 객체를 활용함

local POLL_INTERVAL = 0.20 -- (초 단위)
local POLL_TIMEOUT  = 2.00
local HOTKEY_MODS = { "cmd", "alt" }
local HOTKEY_KEY = ","
local CHROME_BUNDLE_ID = "com.google.Chrome"
local EMPTY_SPLIT_PANE_URL = "chrome://tab-search.top-chrome/split_new_tab_page"
local M = {}
local splitWorkerOccupied = false

local function chromeIsFrontmost()
    local app = hs.application.frontmostApplication()
    return app ~= nil and app:bundleID() == CHROME_BUNDLE_ID
end

local function getActiveTabSnapshot()
    local ok, res = hs.osascript.applescript([[
        tell application "Google Chrome"
            set w to front window
            return {(id of active tab of w) as string, URL of active tab of w, count of tabs of w}
        end tell
    ]])
    if ok and type(res) == "table" and #res == 3 then
        return { id = res[1], url = res[2], tabCount = res[3] }
    end
    return nil
end

local function setUrlIfNewPane(base)
    local safeUrl = base.url:gsub('\\', '\\\\'):gsub('"', '\\"')
    local script = string.format([[
        tell application "Google Chrome"
            set w to front window
            if ((id of active tab of w) as string is not "%s") and (count of tabs of w is %d) and (URL of active tab of w starts with "%s") then
                set URL of active tab of w to "%s"
                return "set"
            end if
            return "wait"
        end tell
    ]], base.id, base.tabCount + 1, EMPTY_SPLIT_PANE_URL, safeUrl)
    local ok, res = hs.osascript.applescript(script)
    if ok then return res end
    return nil
end

local function openCurrentUrlInSplit()
    -- 1)
    if splitWorkerOccupied then return end
    local base = getActiveTabSnapshot()
    if base == nil then
        hs.alert.show("Chrome 활성 탭 정보를 읽지 못했습니다")
        return
    end
    if base.url == "" or base.url:find("^chrome://") or base.url:find("^about:") then
        hs.alert.show("split으로 복제할 수 없는 페이지입니다")
        return
    end

    -- 2)
    if not chromeIsFrontmost() then return end
    splitWorkerOccupied = true
    hs.eventtap.keyStroke({ "cmd", "alt" }, "n")

    -- 3)
    local deadline = hs.timer.secondsSinceEpoch() + POLL_TIMEOUT
    local function pollNewPane()
        local result = setUrlIfNewPane(base)
        if result == "set" or hs.timer.secondsSinceEpoch() >= deadline then
            splitWorkerOccupied = false
            M.pollTimer = nil
        else
            M.pollTimer = hs.timer.doAfter(POLL_INTERVAL, pollNewPane)
        end
    end
    M.pollTimer = hs.timer.doAfter(POLL_INTERVAL, pollNewPane)
end

M.hotkey = hs.hotkey.new(HOTKEY_MODS, HOTKEY_KEY, openCurrentUrlInSplit)

M.appWatcher = hs.application.watcher.new(function(_, event, app)
    if app ~= nil and app:bundleID() == CHROME_BUNDLE_ID then
        if event == hs.application.watcher.activated then
            M.hotkey:enable()
        elseif event == hs.application.watcher.deactivated then
            M.hotkey:disable()
        end
    end
end)
M.appWatcher:start()
if chromeIsFrontmost() then M.hotkey:enable() end

return M
