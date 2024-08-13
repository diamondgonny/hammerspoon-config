local chrome = {}

-- Function to check if Google Chrome is active
local function isGoogleChromeActive()
    local frontApp = hs.application.frontmostApplication()
    return frontApp and frontApp:name() == "Google Chrome"
end

-- Function to press a key with modifiers and ensure it completes
local function keyStroke(modifiers, key, delay)
    hs.eventtap.event.newKeyEvent(modifiers, key, true):post()
    hs.eventtap.event.newKeyEvent(modifiers, key, false):post()
    if delay then
        hs.timer.usleep(delay)
    end
end

local function performKeySequenceForChatbot(tabPressCount, pressEnter, delayOfEnter)
    for i = 1, tabPressCount do
        keyStroke({}, "tab", 5000)
    end
    if pressEnter then
        keyStroke({}, "return", delayOfEnter)
    end
end

local function performKeySequenceForTranslate(tabPressCount)
    keyStroke({"cmd", "shift"}, "y", 70000)
    for i = 1, tabPressCount do
        keyStroke({}, "tab", 5000)
    end
    keyStroke({}, "return", 50000)
    keyStroke({"cmd", "shift"}, "y", 0)
end

-- Generic function to set up a Chrome hotkey
local function setupChromeHotkey(modifiers, key, action)
    local chromeHotkey = nil

    local function enableChromeHotkey()
        if not chromeHotkey then
            chromeHotkey = hs.hotkey.bind(modifiers, key, function()
                if isGoogleChromeActive() then
                    action()
                end
            end)
        end
    end

    local function disableChromeHotkey()
        if chromeHotkey then
            chromeHotkey:delete()
            chromeHotkey = nil
        end
    end

    hs.application.watcher.new(function(appName, eventType)
        if appName == "Google Chrome" then
            if eventType == hs.application.watcher.activated then
                enableChromeHotkey()
            elseif eventType == hs.application.watcher.deactivated then
                disableChromeHotkey()
            end
        end
    end):start()
end

-- Chatbot Access
local function setupChatbotAccess()
    setupChromeHotkey({"cmd"}, "k", function()
        performKeySequenceForChatbot(1, true, 5000)
        performKeySequenceForChatbot(4, true, 5000)
        performKeySequenceForChatbot(4, true, 500000)
        performKeySequenceForChatbot(2, false, 0)
    end)
end

-- Chatbot Access Widescreen
local function setupChatbotAccessWidescreen()
    setupChromeHotkey({"cmd", "ctrl"}, "k", function()
        performKeySequenceForChatbot(2, true, 5000)
        performKeySequenceForChatbot(4, true, 500000)
        performKeySequenceForChatbot(1, true, 500000)
        performKeySequenceForChatbot(2, false, 0)
    end)
end

-- Translate On
local function setupTranslateOn()
    setupChromeHotkey({"cmd"}, "b", function()
        performKeySequenceForTranslate(9)
    end)
end

-- Translate Off
local function setupTranslateOff()
    setupChromeHotkey({"cmd", "ctrl"}, "b", function()
        performKeySequenceForTranslate(7)
    end)
end

-- Set up all Chrome-related functionalities
setupChatbotAccess()
setupChatbotAccessWidescreen()
setupTranslateOn()
setupTranslateOff()
