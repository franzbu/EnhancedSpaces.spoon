local function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local SpaceHammer = {}

SpaceHammer.author = "Franz B. <csaa6335@gmail.com>"
SpaceHammer.homepage = "https://github.com/franzbu/SpaceHammer.spoon"
SpaceHammer.winMSpaces = "MIT"
SpaceHammer.name = "SpaceHammer"
SpaceHammer.version = "0.9.1"
SpaceHammer.spoonPath = scriptPath()

local dragTypes = {
  move = 1,
  resize = 2,
}

local function tableToMap(table)
  local map = {}
  for _, v in pairs(table) do
    map[v] = true
  end
  return map
end

local function getWindowUnderMouse()
  --local _ = hs.application
  local my_pos = hs.geometry.new(hs.mouse.absolutePosition())
  local my_screen = hs.mouse.getCurrentScreen()
  return hs.fnutils.find(hs.window.orderedWindows(), function(w)
    return my_screen == w:screen() and my_pos:inside(w:frame())
  end)
end

local function buttonNameToEventType(name, optionName)
  if name == 'left' then
    return hs.eventtap.event.types.leftMouseDown
  end
  if name == 'right' then
    return hs.eventtap.event.types.rightMouseDown
  end
  error(optionName .. ': only "left" and "right" mouse button supported, got ' .. name)
end

function SpaceHammer:new(options)
  hs.window.animationDuration = 0
  options = options or {}

  pM = options.outerPadding or 5
  local innerPadding = options.innerPadding or 5
  pI = innerPadding / 2

  modifier1 = options.modifier1 or { 'alt' } 
  modifier2 = options.modifier2 or { 'ctrl' } 
  modifier1_2 = mergeModifiers(modifier1, modifier2) 
  modifierReference = options.modifierReference or { 'ctrl', 'shift' } 
    
  modifierMS = options.modifierMS or modifier2
  modifierMSKeys = options.modifierMSKeys or { 'a', 's', 'd', 'f', 'q', 'w' }

  openAppMSpace = options.openAppMSpace or nil

  modifierSwitchWin = options.modifierSwitchWin or modifier1
  modifierSwitchWinKeys = options.modifierSwitchWinKeys or { 'tab', 'escape' }

  modifierSnap1 = options.modifierSnap1 or { 'cmd', 'alt' }
  modifierSnap2 = options.modifierSnap2 or { 'cmd', 'ctrl' }
  modifierSnap3 = options.modifierSnap3 or { 'cmd', 'alt', 'ctrl' }
  modifierSnapKeys = options.modifierSnapKeys or {
    -- modifierSnapKey1
    {{'a1','1'},{'a2','2'},{'a3','3'},{'a4','4'},{'a5','5'},{'a6','6'},{'a7','7'},{'a8','8'}},
    -- modifierSnapKey2
    {{'b1','1'},{'b2','2'},{'b3','3'},{'b4','4'},{'b5','5'},{'b6','6'},{'b7','7'},{'b8','8'},{'b9','9'},{'b10','0'},{'b11','o'},{'b12','p'}},
    -- modifierSnapKey3
    {{'c1','1'},{'c2','2'},{'c3','3'},{'c4','4'},{'c5','5'},{'c6','6'},{'c7','7'},{'c8','8'},{'c9','9'},{'c10','0'},{'c11','o'},{'c12','p'}},
  }

  -- switch to mSpace
  modifierSwitchMS = options.modifierSwitchMS or modifier1

  -- move window to mSpace
  modifierMoveWinMSpace = options.modifierMoveWinMSpace or modifier1_2

  local margin = options.margin or 0.3
  m = margin * 100 / 2

  useResize = options.resize or false

  ratioMSpaces = options.ratioMSpaces or 0.8

  mspaces = options.mSpaces or { '1', '2', '3' }
  currentMSpace = indexOf(options.MSpaces, options.startMSpace) or 2

  gridIndicator = options.gridIndicator or { 20, 1, 0.83, 0, 0.4 }

  increasedResponsiveness = options.increasedResponsiveness or false

  local resizer = {
    disabledApps = tableToMap(options.disabledApps or {}),
    dragging = false,
    dragType = nil,
    moveStartMouseEvent = buttonNameToEventType('left', 'moveMouseButton'),
    resizeStartMouseEvent = buttonNameToEventType('right', 'resizeMouseButton'),
    targetWindow = nil,
  }

  setmetatable(resizer, self)
  self.__index = self

  resizer.clickHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseDown,
      hs.eventtap.event.types.rightMouseDown,
    },
    resizer:handleClick()
  )

  resizer.cancelHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseUp,
      hs.eventtap.event.types.rightMouseUp,
    },
    resizer:handleCancel()
  )

  resizer.dragHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseDragged,
      hs.eventtap.event.types.rightMouseDragged,
    },
    resizer:handleDrag()
  )

    -- menubar
  menubar = hs.menubar.new(true, "A"):setTitle(mspaces[currentMSpace])
  menubar:setTooltip("mSpace")

  filter_all = hs.window.filter.new()
  winAll = filter_all:getWindows()--hs.window.sortByFocused)

  winMSpaces = {}
  max = hs.screen.mainScreen():frame()
  --initialize winMSpaces
  refreshWinMSpaces()

  -- recover stranded windows at start
  for i = 1, #winAll do
    if winAll[i]:topLeft().x >= max.w - 1 then                                                                                                                                                                 -- window in 'hiding spot'
      -- move window to the middle of the current mSpace
      winMSpaces[getWinMSpacesPos(winAll[i])].frame[currentMSpace] = hs.geometry.point(
      max.w / 2 - winAll[i]:frame().w / 2, max.h / 2 - winAll[i]:frame().h / 2, winAll[i]:frame().w, winAll[i]:frame().h)                                                                                      -- put window in middle of screen
      assignMS(winAll[i], false)
    end
  end

  -- watchdogs
  ---[[
  filter = hs.window.filter --subscribe: when a new window (dis)appears, run refreshWindowsWS
  filter.default:subscribe(filter.windowNotOnScreen, function(w)
    refreshWinMSpaces(w)
  end)
  filter.default:subscribe(filter.windowOnScreen, function(w)
    refreshWinMSpaces(w)
    assignMS(w, true)
    w:focus()
  end)
  filter.default:subscribe(filter.windowFocused, function(w)
    refreshWinMSpaces(w)
    cmdTabFocus(w)
  end)

  -- moving of windows reacted to constantly or through filter subscription
  if increasedResponsiveness then
  -- global variable 'adjustWinFrameTimer' to avoid timer being garbage collected
    adjustWinFrameTimer = hs.timer.doEvery(0.2, function() 
      adjustWinFrame()
    end)
  else
    filter.default:subscribe(filter.windowMoved, function(w)
      adjustWinFrame()
    end)
  end
  --]]

  --[[ -- flagsKeyboardTracker
  -- 'subscribe', watchdog for modifier keys
  cycleModCounter = 0 
  local events = hs.eventtap.event.types
  local prevModifier = nil
  cycleAll = false
  keyboardTracker = hs.eventtap.new({ events.flagsChanged }, function(e)
    local flagsKeyboardTracker = eventToArray(e:getFlags())
    -- on modifier release flag is assigned 'nil' -> prevModifier remedies that
    if modifiersEqual(flagsKeyboardTracker, modifierSwitchWin) or modifiersEqual(prevModifier, modifierSwitchWin) then
      cycleModCounter = cycleModCounter + 1
      if cycleModCounter % 2 == 0 then -- only when released (and not when pressed)
        prevModifier = nil
        if cycleAll then
          hs.timer.doAfter(0.02, function()
            cycleModCounter = 0
            pos = getWinMSpacesPos(hs.window.focusedWindow())
            for i = 1, #mspaces do
              if winMSpaces[pos].mspace[i] then
                goToSpace(i)
                break 
              end
            end
          end)
          cycleAll = false
        end
      end
    end
    prevModifier = flagsKeyboardTracker
  end)
  keyboardTracker:start()
  --]]

  ---[[
  -- cycle throuth windows of current mSpace
  switcher = hs.window.switcher.new(hs.window.filter.new():setRegions({hs.geometry.new(0, 0, max.w - 1, max.h)}))
  switcher.ui.highlightColor = { 0.4, 0.4, 0.5, 0.8 }
  switcher.ui.thumbnailSize = 112
  switcher.ui.selectedThumbnailSize = 284
  switcher.ui.backgroundColor = { 0.3, 0.3, 0.3, 0.5 }
  switcher.ui.textSize = 16
  switcher.ui.showSelectedTitle = false
  hs.hotkey.bind(modifierSwitchWin, modifierSwitchWinKeys[1], function()
    --cycleAll = false --true when cycling through all apps (if on other mSpaces necessary to switch there)
    switcher:next()
    --after release of modifierSwitchWin, watchdog initiates whatever needs to be done
  end)
  hs.hotkey.bind({modifierSwitchWin[1], 'shift' }, modifierSwitchWinKeys[1], function()
    --cycleAll = false --true when cycling through all apps
    switcher:previous()
  end)
  --]]

  -- cycle through windows of current WS (without UI), todo (maybe): last focus first
  --[[
  local nextFMS = 1
  hs.hotkey.bind(modifierSwitchWin, modifierSwitchWinKeys[1], function()
    if nextFMS > #winMSpaces then nextFMS = 1 end
    while not winMSpaces[nextFMS].mspace[currentMSpace] do
      if nextFMS == #winMSpaces then
        nextFMS = 1
      else
        nextFMS = nextFMS + 1
      end
    end
    winMSpaces[nextFMS].win:focus()
    nextFMS = nextFMS + 1
  end)
  --]]

  -- cycle through references of one window
  local nextFR = 1
  hs.hotkey.bind(modifierSwitchWin, modifierSwitchWinKeys[2], function()
    pos = getWinMSpacesPos(hs.window.focusedWindow())
    nextFR = getnextMSpaceNumber(currentMSpace)
    while not winMSpaces[pos].mspace[nextFR] do
      if nextFR == #mspaces then
        nextFR = 1
      else
        nextFR = nextFR + 1
      end
    end
    goToSpace(nextFR)
    winMSpaces[pos].win:focus()
  end)

  --_________ reference/dereference windows to/from mspaces, goto mspaces _________
  -- reference
  for i = 1, #mspaces do
    hs.hotkey.bind(modifierReference, mspaces[i], function()
      refWinMSpace(i)
    end)
  end
  -- de-reference
hs.hotkey.bind(modifierReference, "0", function()
    derefWinMSpace()
  end)

  --_________ switching spaces / moving windows _________
  hs.hotkey.bind(modifierMS, modifierMSKeys[1], function() -- previous space (incl. cycle)
    currentMSpace = getprevMSpaceNumber(currentMSpace)
    goToSpace(currentMSpace)
  end)
  hs.hotkey.bind(modifierMS, modifierMSKeys[2], function() -- next space (incl. cycle)
    currentMSpace = getnextMSpaceNumber(currentMSpace)
    goToSpace(currentMSpace)
  end)
  hs.hotkey.bind(modifierMS, modifierMSKeys[5], function() -- move active window to previous space and switch there (incl. cycle)
    -- move window to prev space and switch there
    moveToSpace(getprevMSpaceNumber(currentMSpace), currentMSpace, true)
    currentMSpace = getprevMSpaceNumber(currentMSpace)
    goToSpace(currentMSpace)
  end)
  hs.hotkey.bind(modifierMS, modifierMSKeys[6], function() -- move active window to next space and switch there (incl. cycle)
    -- move window to next space and switch there
      moveToSpace(getnextMSpaceNumber(currentMSpace), currentMSpace, true)
      currentMSpace = getnextMSpaceNumber(currentMSpace)
      goToSpace(currentMSpace)
  end)
  hs.hotkey.bind(modifierMS, modifierMSKeys[3], function() -- move active window to previous space (incl. cycle)
    -- move window to prev space
    moveToSpace(getprevMSpaceNumber(currentMSpace), currentMSpace, true)
  end)
  hs.hotkey.bind(modifierMS, modifierMSKeys[4], function() -- move active window to next space (incl. cycle)
    -- move window to next space
    moveToSpace(getnextMSpaceNumber(currentMSpace), currentMSpace, true)
  end)

  -- goto mspaces directly with 'modifierMoveWinMSpace-<name of mspace>'
  if modifierMoveWinMSpace ~= nil then
    for i = 1, #mspaces do
      hs.hotkey.bind(modifierSwitchMS, mspaces[i], function()
        goToSpace(i)
      end)
    end
  end

  -- moving window to specific mSpace
  if modifierMoveWinMSpace ~= nil then
    for i = 1, #mspaces do
      hs.hotkey.bind(modifierMoveWinMSpace, mspaces[i], function() -- move active window to next space and switch there (incl. cycle)
       moveToSpace(i, currentMSpace, true)
      end)
    end
  end

  -- ___________ keyboard shortcuts - snapping windows into grid postions ___________
  if modifierSnap1 ~= nil then
    for i = 1, #modifierSnapKeys[1] do
      hs.hotkey.bind(modifierSnap1, modifierSnapKeys[1][i][2], function()
        hs.window.focusedWindow():move(snap(modifierSnapKeys[1][i][1]), nil, false, 0)
      end)
    end
  end
  if modifierSnap2 ~= nil then
    for i = 1, #modifierSnapKeys[2] do
      hs.hotkey.bind(modifierSnap2, modifierSnapKeys[2][i][2], function()
        hs.window.focusedWindow():move(snap(modifierSnapKeys[2][i][1]), nil, false, 0)
      end)
    end
  end
  if modifierSnap3 ~= nil then
    for i = 1, #modifierSnapKeys[3] do
      hs.hotkey.bind(modifierSnap3, modifierSnapKeys[3][i][2], function()
        hs.window.focusedWindow():move(snap(modifierSnapKeys[3][i][1]), nil, false, 0)
      end)
    end
  end

  -- debug
  --[[
  hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "m", function()
   print("_______winAll_________")
    for i, v in pairs(winAll) do
      print(i, v)
    end
    print("_______winMSpaces_________")
    for i, v in pairs(winMSpaces) do
      print(i .. ": " .. "mspace " .. tostring(winMSpaces[i].mspace))
      print("id: " .. winMSpaces[i].win:application():name())
      local ms = ""
      for j = 1, #mspaces do
        ms = ms .. tostring(winMSpaces[i].mspace[j]) .. ", "
      end
      print("mSpaces: " .. ms)

      for j = 1, #mspaces do -- frame
        print(tostring(winMSpaces[i].frame[j]))
      end

    end
  end)

  hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "k", function()

  end)

  hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "l", function()
  end)

  -- list names of apps of (visible) windows
  hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "i", function()
    for i = 1, #winMSpaces do -- frame
      print(tostring(winMSpaces[i].win:application():name()))
    end
  end)
  --]]


  goToSpace(currentMSpace) -- refresh
  resizer.clickHandler:start()
  return resizer
end


function SpaceHammer:stop()
  self.dragging = false
  self.dragType = nil
  for i = 1, #cv do -- delete canvases
    
    cv[i]:delete()
  end
  self.cancelHandler:stop()
  self.dragHandler:stop()
  self.clickHandler:start()
end


function SpaceHammer:isResizing()
  return self.dragType == dragTypes.resize
end


function SpaceHammer:isMoving()
  return self.dragType == dragTypes.move
end


sumdx = 0
sumdy = 0
function SpaceHammer:handleDrag()
  return function(event)
    if not self.dragging then return nil end
    local currentSize =  hs.window.focusedWindow():size() -- win:frame
    local current =  hs.window.focusedWindow():topLeft() 
    local dx = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
    local dy = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)
    if self:isMoving() then
      hs.window.focusedWindow():move({ dx, dy }, nil, false, 0)
      sumdy = sumdy + dy
      sumdx = sumdx + dx
      movedNotResized = true

      -- mSpaces
      moveLeftAS = false -- these two variables are also needed in case AeroSpace is deactivated
      moveRightAS = false
      if current.x + currentSize.w * ratioMSpaces < 0 then   -- left
        for i = 1, #cv do
          cv[i]:hide()
        end
        moveLeftAS = true
      elseif current.x + currentSize.w > max.w + currentSize.w * ratioMSpaces then   -- right
        for i = 1, #cv do
          cv[i]:hide()
        end
        moveRightAS = true
      else
        for i = 1, #cv do
          cv[i]:show()
        end
        moveLeftAS = false
        moveRightAS = false
      end

      return true
    elseif self:isResizing() and useResize then
      movedNotResized = false
      if mH <= -m and mV <= m and mV > -m then -- 9 o'clock
        hs.window.focusedWindow():move(hs.geometry.new(current.x + dx, current.y, currentSize.w - dx, currentSize.h), nil, false, 0)
      elseif mH <= -m and mV <= -m then -- 10:30
        if dy < 0 then -- prevent extension of downwards when cursor enters menubar
          if current.y > heightMB then
            hs.window.focusedWindow():move(hs.geometry.new(current.x + dx, current.y + dy, currentSize.w - dx, currentSize.h - dy), nil, false,
              0)
          end
        else
          hs.window.focusedWindow():move(hs.geometry.new(current.x + dx, current.y + dy, currentSize.w - dx, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > -m and mH <= m and mV <= -m then -- 12 o'clock
        if dy < 0 then -- prevent extension of downwards when cursor enters menubar
          if current.y > heightMB then
            hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y + dy, currentSize.w, currentSize.h - dy), nil, false, 0)
          end
        else
          hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y + dy, currentSize.w, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > m and mV <= -m then -- 1:30
        if dy < 0 then -- prevent extension of downwards when cursor enters menubar
          if current.y > heightMB then
            hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y + dy, currentSize.w + dx, currentSize.h - dy), nil, false, 0)
          end
        else
          hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y + dy, currentSize.w + dx, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > m and mV > -m and mV <= m then -- 3 o'clock
        hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y, currentSize.w + dx, currentSize.h), nil, false, 0)
      elseif mH > m and mV > m then -- 4:30
        hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y, currentSize.w + dx, currentSize.h + dy), nil, false, 0)
      elseif mV > m and mH <= m and mH > -m then -- 6 o'clock
        hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y, currentSize.w, currentSize.h + dy), nil, false, 0)
      elseif mH <= -m and mV > m then -- 7:30
        hs.window.focusedWindow():move(hs.geometry.new(current.x + dx, current.y, currentSize.w - dx, currentSize.h + dy), nil, false, 0)
      else -- middle -> moving (not resizing) window
        hs.window.focusedWindow():move({ dx, dy }, nil, false, 0)
        movedNotResized = true
      end
      return true
    else
      return nil
    end
  end
end


function SpaceHammer:handleCancel()
  return function()
    if not self.dragging then return end
    self:doMagic()
    self:stop()
  end
end


function SpaceHammer:doMagic() -- automatic positioning and adjustments, for example, prevent window from moving/resizing beyond screen boundaries
  if not self.targetWindow then return end
  local modifierDM = eventToArray(hs.eventtap.checkKeyboardModifiers()) -- modifiers (still) pressed after releasing mouse button 
  local frame = hs.window.focusedWindow():frame()
  local xNew = frame.x
  local yNew = frame.y
  local wNew = frame.w
  local hNew = frame.h
  if not moveLeftAS and not moveRightAS then -- if moved to other workspace, no resizing/repositioning wanted/necessary
    if movedNotResized then
      -- window moved past left screen border
      if modifiersEqual(flags, modifier1) then
        gridX = 2
        gridY = 2
      elseif modifiersEqual(flags, modifier2) then --or modifiersEqual(flags, modifier1_2) then
        gridX = 3
        gridY = 3
      end

      if modifiersEqual(flags, modifier1) and modifiersEqual(flags, modifierDM) then
        if frame.x < 0 and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- left and not bottom
          if math.abs(frame.x) < wNew / 10 then -- moved past border by 10 or less percent: move window as is back within boundaries of screen
          xNew = 0 + pM
          self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          -- window moved past left screen border 2x2
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            for i = 1, gridY, 1 do
              -- middle third of left border
              if hs.mouse.getRelativePosition().y + sumdy > max.h / 3 and hs.mouse.getRelativePosition().y + sumdy < max.h * 2 / 3 then -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment
                hs.window.focusedWindow():move(snap('a1'), nil, false, 0)
              elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
                hs.window.focusedWindow():move(snap('a3'), nil, false, 0)
              else -- bottom third
                hs.window.focusedWindow():move(snap('a4'), nil, false, 0)
              end
            end
          end
        -- moved window past right screen border 2x2
        elseif frame.x + frame.w > max.w and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- right and not bottom
          if max.w - frame.x > math.abs(max.w - frame.x - wNew) * 9 then -- 9 times as much inside screen than outside = 10 percent outside; move window back within boundaries of screen (keep size)
            wNew = frame.w
            xNew = max.w - wNew - pM
            self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            for i = 1, gridY, 1 do
              -- middle third of left border
              if hs.mouse.getRelativePosition().y + sumdy > max.h / 3 and hs.mouse.getRelativePosition().y + sumdy < max.h * 2 / 3 then
                hs.window.focusedWindow():move(snap('a2'), nil, false, 0)
              elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
                hs.window.focusedWindow():move(snap('a5'), nil, false, 0)
              else -- bottom third
                hs.window.focusedWindow():move(snap('a6'), nil, false, 0)
              end
            end
          end
        -- moved window below bottom of screen 2x2
        elseif frame.y + hNew > maxWithMB.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
          if max.h - frame.y > math.abs(max.h - frame.y - hNew) * 9 then -- and flags:containExactly(modifier1) then -- move window as is back within boundaries
            yNew = maxWithMB.h - hNew - pM
            self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            for i = 1, gridX, 1 do
              if hs.mouse.getRelativePosition().x + sumdx > max.w / 3 and hs.mouse.getRelativePosition().x + sumdx < max.w * 2 / 3 then -- middle
                hs.window.focusedWindow():move(snap('a7'), nil, false, 0)
                break
              elseif hs.mouse.getRelativePosition().x + sumdx <= max.w / 3 then -- left
                hs.window.focusedWindow():move(snap('a1'), nil, false, 0)
                break
              else -- right
                hs.window.focusedWindow():move(snap('a2'), nil, false, 0)
                break
              end
            end
          end
        end
      elseif modifiersEqual(flags, modifier1) and #modifierDM == 0 then -- modifier key released before left mouse button
        -- 2x2
        if frame.x < 0 and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- left and not bottom
          if math.abs(frame.x) < wNew / 10 then -- moved past border by 10 or less percent: move window as is back within boundaries of screen
            xNew = 0 + pM
            self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          -- window moved past left border -> window is snapped to right side
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            for i = 1, gridY, 1 do
              -- middle third of left border
              if hs.mouse.getRelativePosition().y + sumdy > max.h / 3 and hs.mouse.getRelativePosition().y + sumdy < max.h * 2 / 3 then
                hs.window.focusedWindow():move(snap('a2'), nil, false, 0)
              elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
                hs.window.focusedWindow():move(snap('a5'), nil, false, 0)
              else -- bottom third
                hs.window.focusedWindow():move(snap('a6'), nil, false, 0)
              end
            end
          end
        elseif frame.x + frame.w > max.w and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- right and not bottom
          if max.w - frame.x > math.abs(max.w - frame.x - wNew) * 9 then -- 9 times as much inside screen than outside = 10 percent outside; move window back within boundaries of screen (keep size)
            wNew = frame.w
            xNew = max.w - wNew - pM
            self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          -- window moved past right border -> window is snapped to left side
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            for i = 1, gridY, 1 do
              -- middle third of left border
              if hs.mouse.getRelativePosition().y + sumdy > max.h / 3 and hs.mouse.getRelativePosition().y + sumdy < max.h * 2 / 3 then -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment
                hs.window.focusedWindow():move(snap('a1'), nil, false, 0)
              elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
                hs.window.focusedWindow():move(snap('a3'), nil, false, 0)
              else -- bottom third
                hs.window.focusedWindow():move(snap('a4'), nil, false, 0)
              end
            end
          end
        elseif frame.y + hNew > maxWithMB.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then -- bottom border
          hs.window.focusedWindow():minimize()                
        end
      -- 3x3
      elseif modifiersEqual(flags, modifier2) and modifiersEqual(flags, modifierDM) then --todo: ?not necessary? -> and eventType == self.moveStartMouseEvent
        if frame.x < 0 and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- left and not bottom
          if math.abs(frame.x) < wNew / 10 then -- moved past border by 10 or less percent: move window as is back within boundaries of screen
            xNew = 0 + pM
            self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          -- window moved past left screen border 3x3
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            -- 3 standard areas
            if (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 2 and hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 3) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 4) then
              for i = 1, gridY, 1 do
                -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment             
                if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
                  if i == 1 then
                    hs.window.focusedWindow():move(snap('a4'), nil, false, 0)
                  elseif i == 2 then
                    hs.window.focusedWindow():move(snap('b5'), nil, false, 0)
                  elseif i == 3 then
                    hs.window.focusedWindow():move(snap('b6'), nil, false, 0)
                  end
                  break
                end
              end
            -- first (upper) double area -> c3
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              hs.window.focusedWindow():move(snap('c3'), nil, false, 0)
            else -- second (lower) double area -> c4
              hs.window.focusedWindow():move(snap('c4'), nil, false, 0)
            end
          end
        -- moved window past right screen border 3x3
        elseif frame.x + frame.w > max.w and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- right and not bottom
          if max.w - frame.x > math.abs(max.w - frame.x - wNew) * 9 then  -- 9 times as much inside screen than outside = 10 percent outside; move window back within boundaries of screen (keep size)
            wNew = frame.w
            xNew = max.w - wNew - pM
            self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment                     
            if (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 2 and hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 3) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 4) then
              -- 3 standard areas
              for i = 1, gridY, 1 do
                if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
                  if i == 1 then
                    hs.window.focusedWindow():move(snap('b10'), nil, false, 0)
                  elseif i == 2 then
                    hs.window.focusedWindow():move(snap('b11'), nil, false, 0)
                  elseif i == 3 then
                    hs.window.focusedWindow():move(snap('b12'), nil, false, 0)
                  end
                  break
                end
              end
            -- first (upper) double area -> c7
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              hs.window.focusedWindow():move(snap('c7'), nil, false, 0)
            else -- second (lower) double area -> c8
              hs.window.focusedWindow():move(snap('c8'), nil, false, 0)
            end
          end
        -- moved window below bottom of screen 3x3
        elseif frame.y + hNew > maxWithMB.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
          if max.h - frame.y > math.abs(max.h - frame.y - hNew) * 9 then -- and flags:containExactly(modifier1) then -- move window as is back within boundaries
            yNew = maxWithMB.h - hNew - pM
            self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            if (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 2 and hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 3) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 4) then
              -- releasing modifier before mouse button; 3 standard areas
              for i = 1, gridX, 1 do
                if hs.mouse.getRelativePosition().x + sumdx < max.w - (gridX - i) * max.w / gridX then 
                  if i == 1 then
                    hs.window.focusedWindow():move(snap('b1'), nil, false, 0)
                  elseif i == 2 then
                    hs.window.focusedWindow():move(snap('b2'), nil, false, 0)
                  elseif i == 3 then
                    hs.window.focusedWindow():move(snap('b3'), nil, false, 0)
                  end
                  break
                end
              end
            -- first (left) double width -> c1
            elseif (hs.mouse.getRelativePosition().x + sumdx > max.w / 5) and (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 2) then
              hs.window.focusedWindow():move(snap('c1'), nil, false, 0)
            else -- second (right) double width -> c2
              hs.window.focusedWindow():move(snap('c2'), nil, false, 0)
            end
          end
        end
      -- if dragged beyond left/right screen border, window snaps to middle column
      --elseif modifiersEqual(flags, modifier1_2) then --todo: ?not necessary? -> and eventType == self.moveStartMouseEvent
      elseif modifiersEqual(flags, modifier2) and #modifierDM == 0 then --todo: ?not necessary? -> and eventType == self.moveStartMouseEvent
        -- left and not bottom, modifier released
        if frame.x < 0 and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then 
          if math.abs(frame.x) < wNew / 10 then -- moved past border by 10 or less percent: move window as is back within boundaries of screen
            xNew = 0 + pM
            self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          -- window moved past left screen border 3x3
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            -- releasing modifier before mouse button; 3 standard areas, snap into middle column
            if (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 2 and hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 3) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 4) then
              for i = 1, gridY, 1 do
                -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment             
                if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
                  if i == 1 then
                    hs.window.focusedWindow():move(snap('b7'), nil, false, 0)
                  elseif i == 2 then
                    hs.window.focusedWindow():move(snap('b8'), nil, false, 0)
                  elseif i == 3 then
                    hs.window.focusedWindow():move(snap('b9'), nil, false, 0)
                  end
                end
              end
            -- first (upper) double area -> c5
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              hs.window.focusedWindow():move(snap('c5'), nil, false, 0)
            else -- second (lower) double area -> c6
              hs.window.focusedWindow():move(snap('c6'), nil, false, 0)
            end
          end
        -- moved window past right screen border 3x3, modifier released
        elseif frame.x + frame.w > max.w and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- right and not bottom
          if max.w - frame.x > math.abs(max.w - frame.x - wNew) * 9 then  -- 9 times as much inside screen than outside = 10 percent outside; move window back within boundaries of screen (keep size)
            wNew = frame.w
            xNew = max.w - wNew - pM
            self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment                     
            if (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 2 and hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 3) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 4) then
              -- realeasing modifier before mouse button; 3 standard areas, snap into middle column, same than section before with left screen border
              for i = 1, gridY, 1 do
                if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
                  if i == 1 then
                    hs.window.focusedWindow():move(snap('b7'), nil, false, 0)
                  elseif i == 2 then
                    hs.window.focusedWindow():move(snap('b8'), nil, false, 0)
                  elseif i == 3 then
                    hs.window.focusedWindow():move(snap('b9'), nil, false, 0)
                  end
                  break
                end
              end
            -- first (upper) double area -> c5
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              hs.window.focusedWindow():move(snap('c5'), nil, false, 0)
            else -- second (lower) double area -> c6
              hs.window.focusedWindow():move(snap('c6'), nil, false, 0)
            end
          end
        -- moved window below bottom of screen 3x3, modifier released
        elseif frame.y + hNew > maxWithMB.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
          if max.h - frame.y > math.abs(max.h - frame.y - hNew) * 9 then -- and flags:containExactly(modifier1) then -- move window as is back within boundaries
            yNew = maxWithMB.h - hNew - pM
            self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            if (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 2 and hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 3) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 4) then
              -- realeasing modifier before mouse button; 3 standard areas
              for i = 1, gridX, 1 do
                if hs.mouse.getRelativePosition().x + sumdx < max.w - (gridX - i) * max.w / gridX then 
                  hs.window.focusedWindow():minimize()
                  break
                end
              end
            -- first (left) double width -> c1
            elseif (hs.mouse.getRelativePosition().x + sumdx > max.w / 5) and (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 2) then
              hs.window.focusedWindow():minimize()
              --snap('c1')
            else -- second (right) double width -> c2
              hs.window.focusedWindow():minimize()
              --snap('c2')
            end
          end
        end
      end
    else -- if window has been resized (and not moved)
      if frame.x < 0 then -- window resized past left screen border
        wNew = frame.w + frame.x + pM
        xNew = 0 + pM
      elseif frame.x + frame.w > max.w then -- window resized past right screen border
        wNew = max.w - frame.x - pM
        xNew = max.w - wNew - pM
      end
      if frame.y < heightMB then -- if window has been resized past beginning of menu bar, height of window is corrected accordingly
        hNew = frame.h + frame.y - heightMB - pM
        yNew = heightMB + pM
      end
      self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
  
    end
    --
  -- mSpaces
  elseif movedNotResized then
    if moveLeftAS then
     moveToSpace(getprevMSpaceNumber(currentMSpace), currentMSpace, false)
      hs.timer.doAfter(0.1, function()
        goToSpace(currentMSpace) -- refresh (otherwise window still visible in former mspace)
      end)
      if modifiersEqual(modifierDM, flags) then -- if modifier is still pressed, switch to where window has been moved  
        hs.timer.doAfter(0.02, function()
          currentMSpace = getprevMSpaceNumber(currentMSpace)
          goToSpace(currentMSpace)
        end)
      end
    elseif moveRightAS then
      moveToSpace(getnextMSpaceNumber(currentMSpace), currentMSpace, false)
      hs.timer.doAfter(0.1, function()
        goToSpace(currentMSpace) -- refresh (otherwise window still visible in former mspace)
      end)
      if modifiersEqual(modifierDM, flags) then
        hs.timer.doAfter(0.02, function()
          currentMSpace = getnextMSpaceNumber(currentMSpace)
          goToSpace(currentMSpace)
        end)
      end
    end
    -- position window in middle of new workspace
    xNew = max.w / 2 - wNew / 2
    yNew = max.h / 2 - hNew / 2
    self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
  end
  sumdx = 0
  sumdy = 0
end


function SpaceHammer:handleClick()
  return function(event)
    if self.dragging then return true end
    flags = eventToArray(event:getFlags())
    eventType = event:getType()

    -- enable active modifiers (modifier1, modifier2, modifierMS, modifier4)
    isMoving = false
    isResizing = false
    if eventType == self.moveStartMouseEvent then
      if modifiersEqual(flags, modifier1) then
        isMoving = true
      elseif modifier2 ~= nil and modifiersEqual(flags, modifier2) then
        isMoving = true
      elseif modifierMS ~= nil and modifiersEqual(flags, modifierMS) then
        isMoving = true
      --elseif modifier4 ~= nil and modifiersEqual(flags, modifier4) then
      --  isMoving = true
     --elseif modifier1_2 ~= nil and modifiersEqual(flags, modifier1_2) then
      --  isMoving = true
      end
    elseif eventType == self.resizeStartMouseEvent then
      if modifiersEqual(flags, modifier1) then
        isResizing = true
      elseif modifier2 ~= nil and modifiersEqual(flags, modifier2) then
        isResizing = true
      elseif modifierMS ~= nil and modifiersEqual(flags, modifierMS) then
        isResizing = true
      --elseif modifier4 ~= nil and modifiersEqual(flags, modifier4) then
      --  isResizing = true
      --elseif modifier1_2 ~= nil and modifiersEqual(flags, modifier1_2) then
      --  isResizing = true
      end
    end

    if isMoving or isResizing then
      local currentWindow = getWindowUnderMouse()
      if #self.disabledApps >= 1 then
        if self.disabledApps[currentWindow:application():name()] then
          return nil
        end
      end

      self.dragging = true
      self.targetWindow = currentWindow
      
      if isMoving then
        self.dragType = dragTypes.move
      else
        self.dragType = dragTypes.resize
      end
    
      -- prevent error when clicking on screen (and not window) with pressed modifier(s)
      if type(getWindowUnderMouse()) == "nil" then
        self.cancelHandler:start()
        self.dragHandler:stop()
        self.clickHandler:stop()
        -- Prevent selection
        return true
      end

      local win = getWindowUnderMouse():focus() --todo (?done? ->experimental): error if clicked on screen (and not window)
      local frame = win:frame()
      max = win:screen():frame() 
      maxWithMB = win:screen():fullFrame()
      heightMB = maxWithMB.h - max.h   -- height menu bar
      local xNew = frame.x
      local yNew = frame.y
      local wNew = frame.w
      local hNew = frame.h

      local mousePos = hs.mouse.absolutePosition()
      local mx = wNew + xNew - mousePos.x -- distance between right border of window and cursor
      local dmah = wNew / 2 - mx -- absolute delta: mid window - cursor
      mH = dmah * 100 / wNew -- delta from mid window: -50(left border of window) to 50 (left border)

      local my = hNew + yNew - mousePos.y
      local dmav = hNew / 2 - my
      mV = dmav * 100 / hNew -- delta from mid window in %: from -50(=top border of window) to 50 (bottom border)

      -- show canvases for visually supporting automatic window positioning and resizing
      local thickness = gridIndicator[1] -- thickness of bar
      cv = {} -- canvases need to be reset
      if eventType == self.moveStartMouseEvent and modifiersEqual(flags, modifier1) then
        createCanvas(1, 0, max.h / 3, thickness, max.h / 3)
        createCanvas(2, max.w / 3, heightMB + max.h - thickness, max.w / 3, thickness)
        createCanvas(3, max.w - thickness, max.h / 3, thickness, max.h / 3)
      elseif eventType == self.moveStartMouseEvent and (modifiersEqual(flags, modifier2)) then -- or modifiersEqual(flags, modifier1_2)) then
        createCanvas(1, 0, max.h / 5, thickness, max.h / 5)
        createCanvas(2, 0, max.h / 5 * 3, thickness, max.h / 5)
        createCanvas(3, max.w / 5, heightMB + max.h - thickness, max.w / 5, thickness)
        createCanvas(4, max.w / 5 * 3, heightMB + max.h - thickness, max.w / 5, thickness)
        createCanvas(5, max.w - thickness, max.h / 5, thickness, max.h / 5)
        createCanvas(6, max.w - thickness, max.h / 5 * 3, thickness, max.h / 5)
      end
      self.cancelHandler:start()
      self.dragHandler:start()
      self.clickHandler:stop()
      -- Prevent selection
      return true
    else
      return nil
    end
  end
end


-- function for creating canvases at screen border
function createCanvas(n, x, y, w, h)
  cv[n] = hs.canvas.new(hs.geometry.rect(x, y, w, h))
  cv[n]:insertElement(
    {
      action = 'fill',
      type = 'rectangle',
      fillColor = { red = gridIndicator[2], green = gridIndicator[4], blue = gridIndicator[4], alpha = gridIndicator[5] },
      roundedRectRadii = { xRadius = 5.0, yRadius = 5.0 },
    },
    1
  )
  cv[n]:show()
end


 -- event looks like this: {'alt' 'true'}; function turns table into an 'array' so
 -- it can be compared to the other arrays (modifier1, modifier2,...)
function eventToArray(a) -- maybe extend to work with more than one modifier at at time
  k = 1
  b = {}
  for i,_ in pairs(a) do
    if i == "cmd" or i == "alt" or i == "ctrl" or i == "shift" then -- or i == "fn" then
      b[k] = i
      k = k + 1
    end
  end
  return b
end


function modifiersEqual(a, b)
  if a == nil or b == nil then return false end
  if #a ~= #b then 
    return false
  end 
  table.sort(a)
  table.sort(b)
  for i = 1, #a do
    if a[i] ~= b[i] then
      return false
    end
  end
  return true
end


function mergeModifiers(m1, m2)
  m1_2 = {} -- merge modifier1 and modifier2:
  k = 1
  for i = 1, #m1 do
    m1_2[k] = m1[i]
    k = k + 1
  end
  for i = 1, #m2 do
    ap = false -- already present
    for j = 1, #m1_2 do -- avoid double entries
      if m1_2[j] == m2[i] then
        ap = true
        break
      end
    end
    if not ap then
      m1_2[k] = m2[i]
      k = k + 1
    end
  end
  return m1_2
end


function isIncludedWinAll(w) -- check whether window id is included in table
  local a = false
  for i,v in pairs(winAll) do
    if w:id() == winAll[i]:id() then
      a = true
    end
  end
  return a
end


function isIncludedWinMSpaces(w) -- check whether window id is included in table
  local a = false
  for i,v in pairs(winAll) do
    if w:id() == winMSpaces[i].win:id() then
      return i
    end
  end
  return 0
end


function copyTable(a)
  b = {}
  for i,v in pairs(a) do
    b[i] = v
  end
  return b
end


function indexOf(array, value)
  if array == nil then return nil end
  for i, v in ipairs(array) do
      if v == value then
          return i
      end
  end
  return nil
end


function getprevMSpaceNumber(cS)
  if cS == 1 then
    return #mspaces
  else
    return cS - 1
  end
end


function getnextMSpaceNumber(cS)
  if cS == #mspaces then
    return 1
  else
    return cS + 1
  end
end


winOnlyMoved = false -- prevent watchdog from giving focus to window if it has been moved to other mspace without switching there
function goToSpace(target)
  winOnlyMoved = false
  max = hs.screen.mainScreen():frame()
  for i,v in pairs(winMSpaces) do
    if winMSpaces[i].mspace[target] == true then
      winMSpaces[i].win:setFrame(winMSpaces[i].frame[target]) -- 'unhide' window
    else
      winMSpaces[i].win:setTopLeft(hs.geometry.point(max.w - 1, max.h))
    end
  end
  currentMSpace = target
  menubar:setTitle(tostring(mspaces[target]))
end


function moveToSpace(target, origin, boolKeyboard)
  winOnlyMoved = true
  local fwin = hs.window.focusedWindow()
  max = fwin:screen():frame()
  fwin:setTopLeft(hs.geometry.point(max.w - 1, max.h))

  winMSpaces[getWinMSpacesPos(fwin)].mspace[target] = true
  winMSpaces[getWinMSpacesPos(fwin)].mspace[origin] = false

  -- keep position when moved by keyboard shortcut, otherwise move to middle of screen
  if boolKeyboard then
    winMSpaces[getWinMSpacesPos(fwin)].frame[target] = winMSpaces[getWinMSpacesPos(fwin)].frame[origin]
  else  
    winMSpaces[getWinMSpacesPos(fwin)].frame[target] = hs.geometry.point(max.w / 2 - fwin:frame().w / 2, max.h / 2 - fwin:frame().h / 2, fwin:frame().w, fwin:frame().h) -- put window in middle of screen            
  end
end


function refreshWinMSpaces(w)
  --filter_all = hs.window.filter.new()
  winAll = filter_all:getWindows() --hs.window.sortByFocused)
  if #winMSpaces == 0 then -- at first start
    for i = 1, #winAll do
      winMSpaces[i] = {}
      winMSpaces[i].win = winAll[i]
      winMSpaces[i].mspace = {}
      winMSpaces[i].frame = {}
      for k = 1, #mspaces do
        if k == currentMSpace then
          winMSpaces[i].mspace[k] = true
          winMSpaces[i].frame[k] = winAll[i]:frame()
        else
          winMSpaces[i].mspace[k] = false
          winMSpaces[i].frame[k] = winAll[i]:frame() -- hs.geometry.new(0, 0, 1, 1) --{0,0,0,0}  nil
        end
      end
    end
  end

  -- delete closed or minimized windows
  for i = 1, #winMSpaces do
    if not isIncludedWinAll(winMSpaces[i].win) then
      table.remove(winMSpaces, i)
      break
    end
  end

  -- add missing windows
  for i = 1, #winAll do
    local there = false
    for j = 1, #winMSpaces do
      if winAll[i]:id() == winMSpaces[j].win:id() then
        there = true
      end
    end
    if not there then
      table.insert(winMSpaces, {})
      winMSpaces[#winMSpaces].win = winAll[i]
      winMSpaces[#winMSpaces].mspace = {}
      winMSpaces[#winMSpaces].frame = {}
      for k = 1, #mspaces do
        if k == currentMSpace then
          winMSpaces[#winMSpaces].mspace[k] = true
          winMSpaces[#winMSpaces].frame[k] = winAll[i]:frame()
        else
          winMSpaces[#winMSpaces].mspace[k] = false
          winMSpaces[#winMSpaces].frame[k] = winAll[i]:frame()
        end
      end
    end
  end

  winOnlyMoved = false
end


-- when 'normal' window switchers such as altTab or macOS' cmd-tab are used, cmdTabFocus() switches to correct mSpace
function cmdTabFocus(w)
  -- when choosing to switch to window by cycling through all apps, go to mSpace of chosen window
  if w ~= nil then
    if not winMSpaces[getWinMSpacesPos(w)].mspace[currentMSpace] then -- in case focused window is not on current mSpace, switch to the one containing it
      for i = 1, #mspaces do
        if winMSpaces[getWinMSpacesPos(w)].mspace[i] then
          goToSpace(i)
          break
        end
      end
    end
  end
end


function adjustWinFrame()
  -- subscribed filter for some reason takes a couple of seconds to trigger method
  w = hs.window.focusedWindow()
  if w ~= nil then
    --print("adjustWinFrame")
    max = w:screen():frame() 
    if w:topLeft().x < max.w - 2 then   -- prevents subscriber-method to refresh coordinates of window that has just been 'hidden'
      if winMSpaces[getWinMSpacesPos(w)] ~= nil then 
        winMSpaces[getWinMSpacesPos(w)].frame[currentMSpace] = w:frame()
      end
    end
  end
end


function getWinMSpacesPos(w)
  for i = 1, #winMSpaces do
    if w:id() == winMSpaces[i].win:id() then
      return i
    end
  end
  return nil
end


function refWinMSpace(target) -- add 'copy' of window on current mspace to target mspace
  local fwin = hs.window.focusedWindow()
  max = fwin:screen():frame()
  winMSpaces[getWinMSpacesPos(fwin)].mspace[target] = true
  -- copy frame from original mSpace
  winMSpaces[getWinMSpacesPos(fwin)].frame[target] = winMSpaces[getWinMSpacesPos(fwin)].frame[currentMSpace]
end


function derefWinMSpace()
  local fwin = hs.window.focusedWindow()
  max = fwin:screen():frame()
  winMSpaces[getWinMSpacesPos(fwin)].mspace[currentMSpace] = false
  -- in case all 'mspace' are 'false', close window
  local all_false = true
  for i = 1, #winMSpaces[getWinMSpacesPos(fwin)].mspace do
    if winMSpaces[getWinMSpacesPos(fwin)].mspace[i] then
      all_false = false
    end
  end
  if all_false then
    fwin:minimize()
  end
  menubar:setTitle(tostring(currentMSpace))
  goToSpace(currentMSpace) -- refresh
end


-- move windows to pre-defined mSpaces; at start (not boolgotoSpace) and later (boolgotoSpace)
function assignMS(w, boolgotoSpace)
  if openAppMSpace ~= nil then
    for i = 1, #openAppMSpace do
      if w:application():name():gsub('%W','') == openAppMSpace[i][1]:gsub('%W','') then
        for j = 1, #mspaces do
          if openAppMSpace[i][2] == mspaces[j] then
            winMSpaces[getWinMSpacesPos(w)].mspace[j] = true
            if openAppMSpace[i][3] ~= nil then
              winMSpaces[getWinMSpacesPos(w)].frame[j] = snap(openAppMSpace[i][3])
            else
              winMSpaces[getWinMSpacesPos(w)].frame[indexOf(mspaces, openAppMSpace[i][2])] = hs.geometry.point(max.w / 2 - w:frame().w / 2, max.h / 2 - w:frame().h / 2, w:frame().w, w:frame().h) -- put window in middle of screen            
            end
            if boolgotoSpace then -- not when SpaceHammer is started
              goToSpace(indexOf(mspaces, openAppMSpace[i][2]))
            end
          else
            winMSpaces[getWinMSpacesPos(w)].mspace[j] = false
          end
        end
      end
    end
  end
end


-- determine hs.geometry object for grid positons
function snap(scenario)
  maxWithMB = hs.window.focusedWindow():screen():fullFrame()
  max = hs.window.focusedWindow():screen():frame()
  local heightMB = maxWithMB.h - max.h   -- height menu bar
  local xNew = 0
  local yNew = 0
  local wNew = 0
  local hNew = 0
  if scenario == 'a1' then -- left half of screen
    xNew = 0 + pM
    yNew = heightMB + pM
    wNew = max.w / 2 - pM - pI
    hNew = max.h - 2 * pM 
  elseif scenario == 'a2' then -- right half of screen
    xNew = max.w / 2 + pI
    yNew = heightMB + pM
    wNew = max.w / 2 - pM - pI
    hNew = max.h - 2 * pM
  elseif scenario == 'a3' then -- top left quarter of screen 
    xNew = 0 + pM
    yNew = heightMB + pM
    wNew = max.w / 2 - pM  - pI
    hNew = max.h / 2 - pM - pI
  elseif scenario == 'a4' then -- bottom left quarter of screen
    xNew = 0 + pM
    yNew = heightMB + max.h / 2 + pI
    wNew = max.w / 2 - pM  - pI
    hNew = max.h / 2 - pM - pI
  elseif scenario == 'a5' then -- top right quarter of screen
    xNew = max.w / 2 + pI
    yNew = heightMB + pM
    wNew = max.w / 2 - pM  - pI
    hNew = max.h / 2 - pM - pI
  elseif scenario == 'a6' then -- bottom right quarter of screen
    xNew = max.w / 2 + pI
    yNew = heightMB + max.h / 2 + pI
    wNew = max.w / 2 - pM  - pI
    hNew = max.h / 2 - pM - pI
  elseif scenario == 'a7' then -- whole screen
    xNew = 0 + pM
    yNew = heightMB + pM
    wNew = max.w - 2 * pM
    hNew = max.h - 2 * pM
  elseif scenario == 'a8' then -- whole screen
    xNew = max.w / 2 - hs.window.focusedWindow():frame().w / 2
    yNew = max.h / 2 - hs.window.focusedWindow():frame().h / 2
    wNew = hs.window.focusedWindow():frame().w
    hNew = hs.window.focusedWindow():frame().h

  
  elseif scenario == 'b1' then -- left third of screen
    xNew = 0 + pM
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = max.h - 2 * pM
  elseif scenario == 'b2' then -- middle third of screen
    xNew = pM + 1 * ((max.w - 2 * pM - 4 * pI) / 3) + 2 * pI
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = max.h - 2 * pM 
  elseif scenario == 'b3' then -- right third of screen
    xNew = pM + 2 * ((max.w - 2 * pM - 4 * pI) / 3) + 4 * pI
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = max.h - 2 * pM 


  elseif scenario == 'b4' then -- left top ninth of screen
    xNew = 0 + pM
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - 4 * pI) / 3
  elseif scenario == 'b5' then -- left middle ninth of screen
    xNew = 0 + pM
    yNew = heightMB + pM + 1 * ((max.h - 2 * pM - 4 * pI) / 3) + 2 * pI
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - 4 * pI) / 3
  elseif scenario == 'b6' then -- left bottom ninth of screen
    xNew = 0 + pM
    yNew = heightMB + pM + 2 * ((max.h - 2 * pM - 4 * pI) / 3) + 4 * pI
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - 4 * pI) / 3


  elseif scenario == 'b7'then -- middle top ninth of screen
    xNew = pM + 1 * ((max.w - 2 * pM - 4 * pI) / 3) + 2 * pI
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - 4 * pI) / 3
  elseif scenario == 'b8' then -- middle middle ninth of screen
    xNew = pM + 1 * ((max.w - 2 * pM - 4 * pI) / 3) + 2 * pI
    yNew = heightMB + pM + 1 * ((max.h - 2 * pM - 4 * pI) / 3) + 2 * pI
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - 4 * pI) / 3
  elseif scenario == 'b9' then -- middle bottom ninth of screen
    xNew = pM + 1 * ((max.w - 2 * pM - 4 * pI) / 3) + 2 * pI
    yNew = heightMB + pM + 2 * ((max.h - 2 * pM - 4 * pI) / 3) + 4 * pI
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - 4 * pI) / 3


  elseif scenario == 'b10' then -- right top ninth of screen
    xNew = pM + 2 * ((max.w - 2 * pM - 4 * pI) / 3) + 4 * pI
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - 4 * pI) / 3
  elseif scenario == 'b11' then -- right middle ninth of screen
    xNew = pM + 2 * ((max.w - 2 * pM - 4 * pI) / 3) + 4 * pI
    yNew = heightMB + pM + 1 * ((max.h - 2 * pM - 4 * pI) / 3) + 2 * pI
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - 4 * pI) / 3
  elseif scenario == 'b12' then -- right bottom ninth of screen
    xNew = pM + 2 * ((max.w - 2 * pM - 4 * pI) / 3) + 4 * pI
    yNew = heightMB + pM + 2 * ((max.h - 2 * pM - 4 * pI) / 3) + 4 * pI
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - 4 * pI) / 3


  elseif scenario == 'c1' then -- left two thirds of screen': 6 cells
    xNew = 0 + pM
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - pI) / 3 * 2
    hNew = max.h - 2 * pM
  elseif scenario == 'c2' then -- right two thirds of screen': 6 cells
    xNew = pM + 1 * ((max.w - 2 * pM - 4 * pI) / 3) + 2 * pI
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - pI) / 3 * 2
    hNew = max.h - 2 * pM


  elseif scenario == 'c3' then -- left third, upper two cells
    xNew = 0 + pM
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - pI) / 3 * 2
  elseif scenario == 'c4' then -- left third, lower two cells
    xNew = 0 + pM
    yNew = heightMB + pM + 1 * ((max.h - 2 * pM - 4 * pI) / 3) + 2 * pI
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - pI) / 3 * 2


  elseif scenario == 'c5' then -- middle third, upper two cells
    xNew = pM + 1 * ((max.w - 2 * pM - 4 * pI) / 3) + 2 * pI
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - pI) / 3 * 2
  elseif scenario == 'c6' then -- middle third, lower two cells
    xNew = pM + 1 * ((max.w - 2 * pM - 4 * pI) / 3) + 2 * pI
    yNew = heightMB + pM + 1 * ((max.h - 2 * pM - 4 * pI) / 3) + 2 * pI
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - pI) / 3 * 2

  elseif scenario == 'c7' then -- right third, upper two cells
    xNew = pM + 2 * ((max.w - 2 * pM - 4 * pI) / 3) + 4 * pI
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - pI) / 3 * 2
  elseif scenario == 'c8' then -- right third, lower two cells
    xNew = pM + 2 * ((max.w - 2 * pM - 4 * pI) / 3) + 4 * pI
    yNew = heightMB + pM + 1 * ((max.h - 2 * pM - 4 * pI) / 3) + 2 * pI
    wNew = (max.w - 2 * pM - 4 * pI) / 3
    hNew = (max.h - 2 * pM - pI) / 3 * 2

  elseif scenario == 'c9' then -- top left and middle thirds': 4 cells
    xNew = 0 + pM
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - pI) / 3 * 2
    hNew = (max.h - 2 * pM - pI) / 3 * 2
  elseif scenario == 'c10' then -- bottom left and middle thirds': 4 cells
    xNew = 0 + pM
    yNew = heightMB + pM + 1 * ((max.h - 2 * pM - 4 * pI) / 3) + 2 * pI
    wNew = (max.w - 2 * pM - pI) / 3 * 2
    hNew = (max.h - 2 * pM - pI) / 3 * 2

  elseif scenario == 'c11' then -- top middle and right thirds': 4 cells
    xNew = pM + 1 * ((max.w - 2 * pM - 4 * pI) / 3) + 2 * pI
    yNew = heightMB + pM
    wNew = (max.w - 2 * pM - pI) / 3 * 2
    hNew = (max.h - 2 * pM - pI) / 3 * 2
  elseif scenario == 'c12' then -- bottom middle and right thirds': 4 cells
    xNew = pM + 1 * ((max.w - 2 * pM - 4 * pI) / 3) + 2 * pI
    yNew = heightMB + pM + 1 * ((max.h - 2 * pM - 4 * pI) / 3) + 2 * pI
    wNew = (max.w - 2 * pM - pI) / 3 * 2
    hNew = (max.h - 2 * pM - pI) / 3 * 2
  end
  return hs.geometry.new(xNew, yNew, wNew, hNew)
end


return SpaceHammer
