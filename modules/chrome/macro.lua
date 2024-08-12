local function isGoogleChromeActive()
  local frontApp = hs.application.frontmostApplication()
  return frontApp and frontApp:name() == "Google Chrome"
end

local function performKeySequence(tabPressCount)
    -- Function to press a key with modifiers and ensure it completes
    local function keyStroke(modifiers, key, delay)
        hs.eventtap.event.newKeyEvent(modifiers, key, true):post()
        hs.eventtap.event.newKeyEvent(modifiers, key, false):post()
        if delay then
            hs.timer.usleep(delay)
        end
    end

    -- Press "cmd-shift-y"
    keyStroke({"cmd", "shift"}, "y", 70000)  -- Delay for 70ms

    -- Press "tab" specified number of times
    for i = 1, tabPressCount do
        keyStroke({}, "tab", 5000)  -- Delay for 5ms
    end

    -- Press "enter"
    keyStroke({}, "return", 50000)  -- Delay for 50ms

    -- Press "cmd-shift-y" again
    keyStroke({"cmd", "shift"}, "y", 0)
end

return {
  isGoogleChromeActive = isGoogleChromeActive,
  performKeySequence = performKeySequence
}
