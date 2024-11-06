local function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local EnhancedSpaces = {}

EnhancedSpaces.author = "Franz B. <csaa6335@gmail.com>"
EnhancedSpaces.homepage = "https://github.com/franzbu/EnhancedSpaces.spoon"
EnhancedSpaces.license = "MIT"
EnhancedSpaces.name = "EnhancedSpaces"
EnhancedSpaces.version = "0.9.24"
EnhancedSpaces.spoonPath = scriptPath()

local function tableToMap(table)
  local map = {}
  for _, v in pairs(table) do
    map[v] = true
  end
  return map
end

local function getWindowUnderMouse()
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

function EnhancedSpaces:new(options)
  hs.window.animationDuration = 0
  options = options or {}

  pM = options.outerPadding or 5
  local innerPadding = options.innerPadding or 5
  pI = innerPadding / 2

  menuModifier1 = options.menuModifier1 or { 'alt' } 
  menuModifier2 = options.menuModifier2 or { 'ctrl' } 
  menuModifier3 = options.menuModifier3 or mergeModifiers(menuModifier1, menuModifier2)
  menuTitles = options.menuTitles or { send = "Send Window", get = "Get Window", help = 'Help', about = 'About' }
  
  hammerspoonMenu = options.hammerspoonMenu or false
  hammerspoonMenuItems = options.hammerspoonMenuItems or { reload = "Reload Config", open = "Open Config", console = 'Console', preferences = 'Preferences', about = 'About Hammerspoon', update = 'Check for Updates...', relaunch = 'Relaunch Hammerspoon', quit = 'Quit Hammerspoon' }

  popupModifier = options.popupModifier or nil
  mbMainPopupKey = options.mbMainPopupKey or nil
  mbSendPopupKey = options.mbSendPopupKey or nil
  mbGetPopupKey = options.mbGetPopupKey or nil

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
  modifierSnap3 = options.modifierSnap3 or { 'cmd', 'shift' }
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

  gridIndicator = options.gridIndicator or { 20, 1, 0, 0, 0.33 }

  customWallpaper = options.customWallpaper or false

  startupCommands = options.startupCommands or nil

  local moveResize = {
    disabledApps = tableToMap(options.disabledApps or {}),
    moveStartMouseEvent = buttonNameToEventType('left', 'moveMouseButton'),
    resizeStartMouseEvent = buttonNameToEventType('right', 'resizeMouseButton'),
  }

  setmetatable(moveResize, self)
  self.__index = self

  moveResize.clickHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseDown,
      hs.eventtap.event.types.rightMouseDown,
    },
    moveResize:handleClick()
  )

  moveResize.cancelHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseUp,
      hs.eventtap.event.types.rightMouseUp,
    },
    moveResize:handleCancel()
  )

  moveResize.dragHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseDragged,
      hs.eventtap.event.types.rightMouseDragged,
    },
    moveResize:handleDrag()
  )

  max = hs.screen.mainScreen():frame()

  filter_all = hs.window.filter.new()
  winAll = filter_all:getWindows()--hs.window.sortByFocused)
  winMSpaces = {}
  for i = 1, #winAll do
    winMSpaces[i] = {}
    winMSpaces[i].win = winAll[i]
    winMSpaces[i].mspace = {}
    winMSpaces[i].frame = {}
    for k = 1, #mspaces do
      winMSpaces[i].frame[k] = winAll[i]:frame()
      if k == currentMSpace then
        winMSpaces[i].mspace[k] = true
      else
        winMSpaces[i].mspace[k] = false
      end
    end
  end
  windowsOnCurrentMS = {} -- always up-to-date list of windows on current mSpace
  windowsNotOnCurrentMS = {}

  menubar = hs.menubar.new(true, "A"):setTitle(mspaces[currentMSpace])
  menubar:setTooltip("mSpace")

  
  -- recover stranded windows at start
  for i = 1, #winAll do
    -- if window not on current mSpace, move it; i.e., if on current mSpace, don't resize
    if winAll[i]:topLeft().x >= max.w - 1 then -- don't touch windows that are on current screen, even if they are in openAppMSpace
      if indexOpenAppMSpace(winAll[i]) ~= nil then -- te be recovered according to openAppMSpace
        assignMS(winAll[i], false)
      else -- this means that window was on another mSpace, but is not in openAppMSpace                                                                                                                                       -- window in 'hiding spot'
        -- move window to middle of the current mSpace
        winMSpaces[getWinMSpacesPos(winAll[i])].frame[currentMSpace] = hs.geometry.point(max.w / 2 - winAll[i]:frame().w / 2, max.h / 2 - winAll[i]:frame().h / 2, winAll[i]:frame().w, winAll[i]:frame().h)                                                                                      -- put window in middle of screen
      end
      refreshMenu()
    end
  end

  -- watchdogs
  hs.window.filter.default:subscribe(hs.window.filter.windowNotOnScreen, function()
    hs.timer.doAfter(0.000000001, function() --delay necessary, otherwise 'filter_all = hs.window.filter.new()' not ready after two Orion windows are 'cmd-q'-ed at once
      refreshWinMSpaces()
      adjustWindowsOncurrentMS()
      if #windowsOnCurrentMS > 0 then
        windowsOnCurrentMS[1]:focus() -- activate last active window on current mSpace when closing/minimizing one
      end
      refreshMenu()
    end)
  end)
  hs.window.filter.default:subscribe(hs.window.filter.windowOnScreen, function(w)
    if w:application():name() ~= 'Alfred' and w:application():name() ~= 'DockHelper' then
      --print('windowOnScreen' .. w:application():name())
      if not enteredFullscreen then
        refreshWinMSpaces()
        moveMiddleAfterMouseMinimized(w)
        assignMS(w, true)
        w:focus()
      end
    end
  end)
  hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function(w)
    if w:application():name() ~= 'Alfred' and w:application():name() ~= 'DockHelper' then
      --print('windowFocused')
      refreshWinMSpaces()
      cmdTabFocus()
      refreshMenu()
    end
  end)
  -- 'window_filter.lua' has been adjusted: 'local WINDOWMOVED_DELAY=0.01' instead of '0.5' to get rid of delay
  filter = dofile(hs.spoons.resourcePath('lib/window_filter.lua'))
  filter.default:subscribe(filter.windowMoved, function(w)
    print('windowMoved')
    adjustWinFrame()
    refreshWinMSpaces()
    refreshMenu()
  end)
  -- next 2 filters are for avoiding calling assignMS(_, true) after unfullscreening a window ('windowOnScreen' is called for each window after a window gets unfullscreened)
  enteredFullscreen = false
  filter.default:subscribe(filter.windowFullscreened, function()
    --print('windowFullscreened')
    enteredFullscreen = true
  end)
  filter.default:subscribe(filter.windowUnfullscreened, function(w)
    --print('windowUnfullscreened')
    hs.timer.doAfter(0.5, function() -- not necessary with 'hs.window.filter.default:subscribe...'
      w:focus()
      enteredFullscreen = false
      refreshWinMSpaces()
    end)
  end)

  -- cycle through windows of current mSpace
  --switcher = switcher.new(hs.window.filter.new():setRegions({hs.geometry.new(0, 0, max.w - 1, max.h)}))switcher.ui.highlightColor = { 0.4, 0.4, 0.5, 0.8 }
  switcher = dofile(hs.spoons.resourcePath('lib/window_switcher.lua'))
  switcher = switcher.new()
  switcher.ui.thumbnailSize = 112
  switcher.ui.selectedThumbnailSize = 284
  switcher.ui.backgroundColor = { 0.3, 0.3, 0.3, 0.5 }
  switcher.ui.textSize = 16
  switcher.ui.showSelectedTitle = false
  hs.hotkey.bind(modifierSwitchWin, modifierSwitchWinKeys[1], function()
    adjustWindowsOncurrentMS()
    switcher:next(windowsOnCurrentMS)
  end)
  hs.hotkey.bind({modifierSwitchWin[1], 'shift' }, modifierSwitchWinKeys[1], function()
    switcher:previous(windowsOnCurrentMS)
  end)

  -- cycle through references of one window
  hs.hotkey.bind(modifierSwitchWin, modifierSwitchWinKeys[2], function()
    pos = getWinMSpacesPos(hs.window.focusedWindow())
    local nextFR = getnextMSpaceNumber(currentMSpace)
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

  -- reference/dereference windows to/from mspaces, goto mspaces
  for i = 1, #mspaces do
    hs.hotkey.bind(modifierReference, mspaces[i], function()
      refWinMSpace(i)
    end)
  end
  -- de-reference
  hs.hotkey.bind(modifierReference, "0", function()
    derefWinMSpace()
  end)

  -- switching spaces/moving windows
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

  -- keyboard shortcuts - snapping windows into grid postions
  if modifierSnap1 ~= '' then
    for i = 1, #modifierSnapKeys[1] do
      hs.hotkey.bind(modifierSnap1, modifierSnapKeys[1][i][2], function()
        hs.window.focusedWindow():move(snap(modifierSnapKeys[1][i][1]), nil, false, 0)
      end)
    end
  end
  if modifierSnap2 ~= '' then
    for i = 1, #modifierSnapKeys[2] do
      hs.hotkey.bind(modifierSnap2, modifierSnapKeys[2][i][2], function()
        hs.window.focusedWindow():move(snap(modifierSnapKeys[2][i][1]), nil, false, 0)
      end)
    end
  end
  if modifierSnap3 ~= '' then
    hs.alert.show(hs.inspect(modifierSnap3))
    for i = 1, #modifierSnapKeys[3] do
      hs.hotkey.bind(modifierSnap3, modifierSnapKeys[3][i][2], function()
        hs.window.focusedWindow():move(snap(modifierSnapKeys[3][i][1]), nil, false, 0)
      end)
    end
  end

  -- popup menus
  if popupModifier ~= nil and mbMainPopupKey ~= nil then
    hs.hotkey.bind(popupModifier, mbMainPopupKey, function()
      mbMainPopup:popupMenu(hs.mouse.absolutePosition() )
    end)
  end

  if popupModifier ~= nil and mbSendPopupKey ~= nil then
    hs.hotkey.bind(popupModifier, mbSendPopupKey, function()
      mbSendPopup:popupMenu(hs.mouse.absolutePosition() )
    end)
  end
  if popupModifier ~= nil and mbGetPopupKey ~= nil then
    hs.hotkey.bind(popupModifier, mbGetPopupKey, function()
      mbGetPopup:popupMenu(hs.mouse.absolutePosition() )
    end)
  end

  -- startup commands
  if startupCommands ~= nil then
    for i = 1, #startupCommands do
      os.execute(startupCommands[i])
    end
  end

  adjustWindowsOncurrentMS()
  refreshMenu()
  goToSpace(currentMSpace) -- refresh
  moveResize.clickHandler:start()
  return moveResize
end


function refreshMenu()
  mainMenu = {
    { title = "mSpaces",
      menu = createMSpaceMenu(),
    },
    { title = "-" },
    { title = getToogleRefWindow()[1], disabled = getToogleRefWindow()[2],
      menu = createToggleRefMenu(),
    },
    { title = "-" },
    { title = menuTitles.send, disabled = returnTrueIfZero(windowsOnCurrentMS),
      menu = createSendWindowMenu(),
    },
    { title = menuTitles.get, disabled = returnTrueIfZero(windowsNotOnCurrentMS),
      menu = createGetWindowMenu(),
    },
    { title = "-" },
    { title = menuTitles.help, fn = function() os.execute('/usr/bin/open https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md') end },
    { title = menuTitles.about, fn =  function() hs.dialog.blockAlert('EnhancedSpaces', 'v0.9.23\n\n\n\nIncreases your productivity so you have more time for what really matters in life.') end },
    { title = "-" },
    { title = hsTitle(), --image = hs.image.imageFromPath(hs.configdir .. '/Spoons/EnhancedSpaces.spoon/images/hs.png'):setSize({ h = 15, w = 15 }),
      menu = hsMenu(),
    },
  }
  menubar:setMenu(mainMenu)

  mbMainPopup = hs.menubar.new(false)
  mainPopupMenu = {
    { title = "mSpaces",
      menu = createMSpaceMenu(),
    },
    { title = "-" },
    { title = getToogleRefWindow()[1], disabled = getToogleRefWindow()[2],
      menu = createToggleRefMenu(),
    },
    { title = "-" },
    { title = menuTitles.send, disabled = returnTrueIfZero(windowsOnCurrentMS),
      menu = createSendWindowMenu(),
    },
    { title = menuTitles.get, disabled = returnTrueIfZero(windowsNotOnCurrentMS),
      menu = createGetWindowMenu(),
    },
  }
  mbMainPopup:setMenu(mainPopupMenu)

  mbSendPopup = hs.menubar.new(false)
  sendWindowMenu = {
    { title = "-" },
    { title = menuTitles.send, disabled = returnTrueIfZero(windowsOnCurrentMS),
      menu = createSendWindowMenu(),
    },
  }
  mbSendPopup:setMenu(sendWindowMenu)

  mbGetPopup = hs.menubar.new(false)
  getWindowMenu = {
    { title = menuTitles.get, disabled = returnTrueIfZero(windowsNotOnCurrentMS),
      menu = createGetWindowMenu(),
    },
  }
  mbGetPopup:setMenu(getWindowMenu)
end
function returnTrueIfZero(t) -- disable send/get titles in menu in case windowsOnCurrentMS/windowsNotOnCurrentMS is empty
  if #t == 0 then
    return true
  end
  return false
end
function hsTitle()
  if not hammerspoonMenu then return nil end
  return 'Hammerspoon'
end
function hsMenu()
  if not hammerspoonMenu then return nil end
  return {
    { title = hammerspoonMenuItems.reload, fn = function() hs.reload() end },
    { title = hammerspoonMenuItems.open, fn = function() os.execute('/usr/bin/open ~/.hammerspoon/init.lua') end },
    { title = "-" },
    { title = hammerspoonMenuItems.console, fn = function() hs.toggleConsole() end },
    { title = hammerspoonMenuItems.preferences, fn = function() hs.openPreferences() end },
    { title = "-" },
    { title = hammerspoonMenuItems.about, fn = function() hs.openAbout() end },
    { title = hammerspoonMenuItems.update, fn = function() hs.checkForUpdates() end },
    { title = "-" },
    { title = hammerspoonMenuItems.relaunch, fn = function() hs.relaunch() end },
    { title = hammerspoonMenuItems.quit, fn = function() os.execute('/usr/bin/killall -9 Hammerspoon') end },
  }
end

-- switch to mSpace
function createMSpaceMenu()
  mSpaceMenu = {}
  for i = 1, #mspaces do
    table.insert(mSpaceMenu, { title = mspaces[i], checked = mSpaceMenuItemChecked(i), disabled = mSpaceMenuItemChecked(i), fn = function(mods)
      goToSpace(i)
    end })
  end
  return mSpaceMenu
end
function mSpaceMenuItemChecked(j)
  if j == currentMSpace then
    return true
  else
    return false
  end
end
-- menu returns table with modifers pressed in this format: '{ alt = true, cmd = false, ctrl = false, fn = false, shift = false } -> turned into array of modifiers used
function getModifiersMods(mods)
  local t = {}
  for i,v in pairs(mods) do
    if v then
      table.insert(t, i)
    end
  end
  return t
end
-- references: toggle (no modifier); menuModifier1: remove all references but the one clicked; menuModifier2: reference all but the one clicked; menuModifier3: reference all
function getToogleRefWindow()
  if #windowsOnCurrentMS > 0 then
    return { windowsOnCurrentMS[1]:application():name(), false }
  else
    return { '', true }
  end
end
function createToggleRefMenu()
  local w = hs.window.focusedWindow()
  winMenu = {}
  for i = 1, #mspaces do
    table.insert(winMenu, { title = mspaces[i], checked = winPresent(w, i), fn = function(mods)
      if modifiersEqual(getModifiersMods(mods), menuModifier3) then -- menuModifier3: only the selected item enabled and moving there
        for j = 1, #mspaces do
          if j == i then
            winMSpaces[getWinMSpacesPos(w)].mspace[j] = true
          else
            winMSpaces[getWinMSpacesPos(w)].mspace[j] = false
          end
        end
        goToSpace(i)
      elseif modifiersEqual(getModifiersMods(mods), menuModifier1) then -- menuModifier1: remove all refs except the one clicked
        for j = 1, #mspaces do
          if j == i then
            winMSpaces[getWinMSpacesPos(w)].mspace[j] = true
          else
            winMSpaces[getWinMSpacesPos(w)].mspace[j] = false
          end
        end
      elseif modifiersEqual(getModifiersMods(mods), menuModifier2) then -- menuModifier2: put refs on all mSpaces
        for j = 1, #mspaces do
          winMSpaces[getWinMSpacesPos(w)].mspace[j] = true
        end
      else  -- toggle (true and false on current mSpace)
        winMSpaces[getWinMSpacesPos(w)].mspace[i] = not winMSpaces[getWinMSpacesPos(w)].mspace[i]
      end
      -- triggering watchdog 'windowMoved' as workaround for initiating refreshMenu() for menu to get updated (immediately)
      --winMSpaces[getWinMSpacesPos(w)].win:move({ 1, 0 }, nil, false, 0)
      --winMSpaces[getWinMSpacesPos(w)].win:move({ -1, 0 }, nil, false, 0)
      w:move({ -1, 0 }, nil, false, 0)
      w:move({ 1, 0 }, nil, false, 0)

      refreshWinMSpaces()
      goToSpace(currentMSpace)
    end })
  end
  return winMenu
end
function winPresent(w, i)
  --if w ~= nil and winMSpaces[getWinMSpacesPos(w)] ~= nil then --winMSpaces[getWinMSpacesPos(w)].mspace[i] ~= nil then
    if winMSpaces[getWinMSpacesPos(w)].mspace[i] then
      return true
    else
      return false
    end
  --end
end


-- move windows from current mSpace to another one: no modifier: stay; menuModifier1: keep reference on current mSpace; menuModifier2: references on all mSpaces; menuModifier3 to tag along
function createSendWindowMenu()
  moveWindowMenu = {}
  for i = 1, #windowsOnCurrentMS do 
    table.insert(moveWindowMenu, { title = windowsOnCurrentMS[i]:application():name(),
      menu = createSendWindowMenuItems(windowsOnCurrentMS[i])
    } )
    --if #createSendWindowMenuItems(windowsOnCurrentMS[i]) == 0 then
    --  moveWindowMenu[i].disabled = true
    --end
  end
  return moveWindowMenu
end
function createSendWindowMenuItems(w)
  moveWindowMenuItems = {}
  for i = 1, #mspaces do
    if winMSpaces[getWinMSpacesPos(w)].mspace[i] then
      table.insert(moveWindowMenuItems, { title = mspaces[i], checked = true, disabled = true })
    else 
      table.insert(moveWindowMenuItems, { title = mspaces[i], checked = winMSpaces[getWinMSpacesPos(w)].mspace[i], fn = function(mods)
        if modifiersEqual(getModifiersMods(mods), menuModifier3) then -- menuModifier3: move to new mSpace alongside with window
          winMSpaces[getWinMSpacesPos(w)].mspace[currentMSpace] = false
          winMSpaces[getWinMSpacesPos(w)].mspace[i] = true
          goToSpace(i)
        elseif modifiersEqual(getModifiersMods(mods), menuModifier1) then -- menuModifier1: keep reference on current mSpace
          winMSpaces[getWinMSpacesPos(w)].mspace[i] = true
        elseif modifiersEqual(getModifiersMods(mods), menuModifier2) then -- menuModifier2: references on all mSpaces
          for j = 1, #mspaces do
            winMSpaces[getWinMSpacesPos(w)].mspace[j] = true
          end
        else -- no modifier: stay on screen
          winMSpaces[getWinMSpacesPos(w)].mspace[currentMSpace] = false
          winMSpaces[getWinMSpacesPos(w)].mspace[i] = true
        end
        goToSpace(currentMSpace) --refresh
      end })
    end
  end
  return moveWindowMenuItems
end


-- fetch window from another mSpace to current one -> with modifier add reference, without move
function createGetWindowMenu()
  getWindowMenu = {}
  for i = 1, #windowsNotOnCurrentMS do
    table.insert(getWindowMenu, { title = windowsNotOnCurrentMS[i]:application():name(), fn = function(mods) 
      local w = winMSpaces[getWinMSpacesPos(windowsNotOnCurrentMS[i])].win
      local indexTrue -- get index of mSpace where window is currently active to set frame accordingly
      for j = 1, #mspaces do 
        if winMSpaces[getWinMSpacesPos(windowsNotOnCurrentMS[i])].mspace[j] then
          indexTrue = j
          break
        end
      end

      for j = 1, #mspaces do -- copy frame from currently mSpace where window is currently active to other mSpaces
        winMSpaces[getWinMSpacesPos(windowsNotOnCurrentMS[i])].frame[j] = winMSpaces[getWinMSpacesPos(windowsNotOnCurrentMS[i])].frame[indexTrue]
      end

      winMSpaces[getWinMSpacesPos(windowsNotOnCurrentMS[i])].mspace[currentMSpace] = true -- to be done in all cases
      if modifiersEqual(getModifiersMods(mods), menuModifier1) then -- menuModifier1: get reference of window
        -- add window to current mSpace
        -- nothing to be done ATM
      elseif modifiersEqual(getModifiersMods(mods), menuModifier2) then -- menuModifier2: put reference on all mSpaces
        -- put reference on all other mSpaces
        for j = 1, #mspaces do
          if j ~= currentMSpace then --and not winMSpaces[getWinMSpacesPos(windowsNotOnCurrentMS[i])].mspace[j] then
            winMSpaces[getWinMSpacesPos(windowsNotOnCurrentMS[i])].mspace[j] = true -- add window to other mSpaces          
          end
        end
      else -- no modifier: move window to current mSpace and delete reference on all other mSpaces
        for j = 1, #mspaces do
          if j ~= currentMSpace and winMSpaces[getWinMSpacesPos(windowsNotOnCurrentMS[i])].mspace[j] then
            winMSpaces[getWinMSpacesPos(windowsNotOnCurrentMS[i])].mspace[j] = false -- remove window from other mSpaces          
          end
        end
      end
      --[[
      print('----------')
      for j = 1, #mspaces do
        print(winMSpaces[getWinMSpacesPos(w)].mspace[j])
        print(tostring((winMSpaces[getWinMSpacesPos(w)].frame[j])))
      end
      --]]

      goToSpace(currentMSpace)
      w:focus()
    end })
   

    end

  

  return getWindowMenu
end
-- end menu


function EnhancedSpaces:stop()
  if cv ~= nil then
    for i = 1, #cv do -- delete canvases
      cv[i]:delete()
    end
  end
  self.cancelHandler:stop()
  self.dragHandler:stop()
  self.clickHandler:start()
end

sumdx = 0
sumdy = 0
function EnhancedSpaces:handleDrag()
  return function(event)
    local current =  hs.window.focusedWindow():frame()
    local dx = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
    local dy = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)
    if isMoving then 
      hs.window.focusedWindow():move({ dx, dy }, nil, false, 0)
      sumdx = sumdx + dx
      sumdy = sumdy + dy
      movedNotResized = true

      moveLeftMS = false
      moveRightMS = false
      if current.x + current.w * ratioMSpaces < 0 then   -- left
        for i = 1, #cv do cv[i]:hide() end
        moveLeftMS = true
      elseif current.x + current.w > max.w + current.w * ratioMSpaces then   -- right
        for i = 1, #cv do cv[i]:hide() end
        moveRightMS = true
      else
        for i = 1, #cv do cv[i]:show() end
        moveLeftMS = false
        moveRightMS = false
      end
      return true
    elseif useResize then
      if mH <= -m and mV <= m and mV > -m then -- 9 o'clock
        local geomNew = hs.geometry.new(current.x + dx, current.y)--, current.w - dx, current.h)
        geomNew.x2 = bottomRight.x
        geomNew.y2 = bottomRight.y
        hs.window.focusedWindow():move(geomNew, nil, false, 0)
      elseif mH <= -m and mV <= -m then -- 10:30
        local geomNew = hs.geometry.new(current.x + dx, current.y + dy)--, current.w - dx, current.h - dy)
        geomNew.x2 = bottomRight.x
        geomNew.y2 = bottomRight.y
        hs.window.focusedWindow():move(geomNew, nil, false, 0)
      elseif mH > -m and mH <= m and mV <= -m then -- 12 o'clock
        local geomNew = hs.geometry.new(current.x, current.y + dy)--, current.w, current.h - dy)
        geomNew.x2 = bottomRight.x
        geomNew.y2 = bottomRight.y
        hs.window.focusedWindow():move(geomNew, nil, false, 0)
      elseif mH > m and mV <= -m then -- 1:30
        local geomNew = hs.geometry.new(current.x, current.y + dy, current.w + dx, current.h - dy)
        geomNew.y2 = bottomRight.y
        hs.window.focusedWindow():move(geomNew, nil, false, 0)
      elseif mH > m and mV > -m and mV <= m then -- 3 o'clock
        hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y, current.w + dx, current.h), nil, false, 0)
      elseif mH > m and mV > m then -- 4:30
        hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y, current.w + dx, current.h + dy), nil, false, 0)
      elseif mV > m and mH <= m and mH > -m then -- 6 o'clock
        hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y, current.w, current.h + dy), nil, false, 0)
      elseif mH <= -m and mV > m then -- 7:30
        local geomNew = hs.geometry.new(current.x + dx, current.y, current.w - dx, current.h + dy)
        geomNew.x2 = bottomRight.x
        hs.window.focusedWindow():move(geomNew, nil, false, 0)
      else -- middle area of window (M) -> moving (not resizing) window
        hs.window.focusedWindow():move({ dx, dy }, nil, false, 0)
        movedNotResized = true
      end
      return true
    else
      return nil
    end
  end
end


function EnhancedSpaces:handleClick()
  return function(event)
    flags = eventToArray(event:getFlags())
    eventType = event:getType()
    -- enable active modifiers (modifier1, modifier2, modifierMS)
    isMoving = false
    isResizing = false
    if eventType == self.moveStartMouseEvent then
      if modifiersEqual(flags, modifier1) then
        isMoving = true
      elseif modifier2 ~= nil and modifiersEqual(flags, modifier2) then
        isMoving = true
      elseif modifierMS ~= nil and modifiersEqual(flags, modifierMS) then
        isMoving = true
      end
    elseif eventType == self.resizeStartMouseEvent then
      if modifiersEqual(flags, modifier1) then
        isResizing = true
      elseif modifier2 ~= nil and modifiersEqual(flags, modifier2) then
        isResizing = true
      elseif modifierMS ~= nil and modifiersEqual(flags, modifierMS) then
        isResizing = true
      end
    end

    -- if menu is open, handleClick() needs to be stopped (it still reacts on mouse button release, which is fine)
    if hs.window.focusedWindow() == nil or hs.window.focusedWindow():application():name() == 'Hammerspoon' then
      isResizing = false
      isMoving = false
    end

    if isMoving or isResizing then
      local currentWindow = getWindowUnderMouse()
      if #self.disabledApps >= 1 then
        if self.disabledApps[currentWindow:application():name()] then
          return nil
        end
      end

      -- prevent error when clicking on screen (and not window) with pressed modifier(s)
      if type(getWindowUnderMouse()) == "nil" then
        self.cancelHandler:start()
        self.dragHandler:stop()
        self.clickHandler:stop()
        -- Prevent selection
        return true
      end

      local win = getWindowUnderMouse():focus()
      local frame = win:frame()
      max = win:screen():frame()
      maxWithMB = win:screen():fullFrame()
      heightMB = maxWithMB.h - max.h -- height menu bar
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
      if isResizing then
        bottomRight = {}
        bottomRight['x'] = frame.x + frame.w
        bottomRight['y'] = frame.y + frame.h
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


function EnhancedSpaces:handleCancel()
  return function()
    self:doMagic()
    self:stop()
  end
end


function EnhancedSpaces:doMagic() -- automatic positioning and adjustments, for example, prevent window from moving/resizing beyond screen boundaries
  local targetWindow = hs.window.focusedWindow()
  local modifierDM = eventToArray(hs.eventtap.checkKeyboardModifiers()) -- modifiers (still) pressed after releasing mouse button 
  local frame = hs.window.focusedWindow():frame()
  local xNew = frame.x
  local yNew = frame.y
  local wNew = frame.w
  local hNew = frame.h
  if not moveLeftMS and not moveRightMS then -- if moved to other workspace, no resizing/repositioning wanted/necessary
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
          if yNew < heightMB + pM then -- top padding
            yNew = 0 + heightMB + pM
          end
          targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
            if yNew < heightMB + pM then -- top padding
              yNew = 0 + heightMB + pM
            end
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
            if yNew < heightMB + pM then -- top padding
              yNew = 0 + heightMB + pM
            end
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
            if yNew < heightMB + pM then -- top padding
              yNew = 0 + heightMB + pM
            end
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
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
      targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
    end
  -- mSpaces
  elseif movedNotResized then
    if moveLeftMS then
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
    elseif moveRightMS then
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
    targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
  end
  sumdx = 0
  sumdy = 0
  moveLeftMS = false
  moveRightMS = false
end


-- creating canvases at screen borders
function createCanvas(n, x, y, w, h)
  cv[n] = hs.canvas.new(hs.geometry.rect(x, y, w, h))
  cv[n]:insertElement({
    action = 'fill',
    type = 'rectangle',
    fillColor = { red = gridIndicator[2], green = gridIndicator[3], blue = gridIndicator[4], alpha = gridIndicator[5] },
    roundedRectRadii = { xRadius = 5.0, yRadius = 5.0 },
  }, 1)
  cv[n]:show()
end

 -- event looks like this: {'alt' 'true'}; function turns table into an 'array' so
 -- it can be compared to the other arrays (modifier1, modifier2,...)
function eventToArray(a) -- maybe extend to work with more than one modifier at at time
  local k = 1
  local b = {}
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
  if #a ~= #b then return false end 
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
  local m1_2 = {} -- merge modifier1 and modifier2:
  for i = 1, #m1 do
    table.insert(m1_2, m1[i])
  end
  for i = 1, #m2 do
    local ap = false -- already present
    for j = 1, #m1_2 do -- avoid double entries
      if m1_2[j] == m2[i] then
        ap = true
        break
      end
    end
    if not ap then
      table.insert(m1_2, m2[i])
    end
  end
  table.sort(m1_2)
  return m1_2
end


function isIncludedWinAll(w) -- check whether window id is included in table
  for i,v in pairs(winAll) do
    if w:id() == winAll[i]:id() then
      return true
    end
  end
  return false
end


function copyTable(a)
  local b = {}
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


function goToSpace(target)
  max = hs.screen.mainScreen():frame()
  maxWithMB = hs.screen.mainScreen():fullFrame()
  heightMB = maxWithMB.h - max.h   -- height menu bar
  for i,v in pairs(winMSpaces) do
    if winMSpaces[i].mspace[target] == true then
      winMSpaces[i].win:setFrame(winMSpaces[i].frame[target]) -- 'unhide' window
    else
      winMSpaces[i].win:setTopLeft(hs.geometry.point(max.w - 1, max.h))
    end
  end
  currentMSpace = target
  menubar:setTitle(mspaces[target])

  --adjust wallpaper
  if customWallpaper then
    local screen = hs.screen.mainScreen()
    if hs.fs.displayName(hs.configdir .. '/Spoons/EnhancedSpaces.spoon/wallpapers/' .. mspaces[currentMSpace] .. '.jpg') then
      screen:desktopImageURL('file://' .. hs.configdir .. '/Spoons/EnhancedSpaces.spoon/wallpapers/' .. mspaces[currentMSpace] .. '.jpg')
    else
      screen:desktopImageURL('file://' .. hs.configdir .. '/Spoons/EnhancedSpaces.spoon/wallpapers/default.jpg')
    end
  end

  refreshWinMSpaces()
  adjustWindowsOncurrentMS()

  if #windowsOnCurrentMS > 0 then
    windowsOnCurrentMS[1]:focus() -- activate last used window on new mSpace
  end
end


-- prepare table windowsOnCurrentMS with windows on current mSpace for lib.window_switcher; also prepare windowsNotOnCurrentMS
function adjustWindowsOncurrentMS()
  windowsOnCurrentMS = {}
  windowsNotOnCurrentMS = {}
  for i = 1, #winAll do
    if winMSpaces[getWinMSpacesPos(winAll[i])].mspace[currentMSpace] then
      table.insert(windowsOnCurrentMS, winAll[i])
    else
      table.insert(windowsNotOnCurrentMS, winAll[i])
    end
  end
end


function moveToSpace(target, origin, boolKeyboard)
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
  refreshWinMSpaces()
end


function refreshWinMSpaces()
  winAll = filter_all:getWindows() --hs.window.sortByFocused)
  --[[
  print('=======')
  for i = 1, #winAll do
    print(winAll[i]:application():name())
  end
  --]]
  -- delete closed or minimized windows
  --::again::
  for i = 1, #winMSpaces do
    if not isIncludedWinAll(winMSpaces[i].win) then
      table.remove(winMSpaces, i)
      --goto again
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
        winMSpaces[#winMSpaces].frame[k] = winAll[i]:frame()
        if k == currentMSpace then
          winMSpaces[#winMSpaces].mspace[k] = true
        else
          winMSpaces[#winMSpaces].mspace[k] = false
        end
      end
    end
  end
  -- adjust table with windows on current mSpace for lib.window_switcher
  adjustWindowsOncurrentMS()
  --refreshMenu()
end


-- when 'normal' window switchers such as AltTab or macOS' cmd-tab are used, cmdTabFocus() switches to correct mSpace
function cmdTabFocus()
  -- when choosing to switch to window by cycling through all apps, go to mSpace of chosen window
  if hs.window.focusedWindow() ~= nil and winMSpaces[getWinMSpacesPos(hs.window.focusedWindow())] ~= nil then
    if not winMSpaces[getWinMSpacesPos(hs.window.focusedWindow())].mspace[currentMSpace] then -- in case focused window is not on current mSpace, switch to the one containing it
      for i = 1, #mspaces do
        if winMSpaces[getWinMSpacesPos(hs.window.focusedWindow())].mspace[i] then
          goToSpace(i)
          break
        end
      end
    end
  end
end


-- triggered by hs.window.filter.windowMoved -> adjusts coordinates of moved window
function adjustWinFrame()
  -- subscribed filter for some reason takes a couple of seconds to trigger method -> alternative: hs.timer.doEvery()
  if hs.window.focusedWindow() ~= nil then
    max = hs.window.focusedWindow():screen():frame() 
    if hs.window.focusedWindow():topLeft().x < max.w - 2 then -- prevents subscriber-method to refresh coordinates of window that has just been 'hidden'
      if winMSpaces[getWinMSpacesPos(hs.window.focusedWindow())] ~= nil then 
        winMSpaces[getWinMSpacesPos(hs.window.focusedWindow())].frame[currentMSpace] = hs.window.focusedWindow():frame()
      end
    end
  end
end


function getWinMSpacesPos(w)
  if w ~= nil and winMSpaces ~= nil then
    for i = 1, #winMSpaces do
      if w:id() == winMSpaces[i].win:id() then
        return i
      end
    end
    return nil
  end
end


function refWinMSpace(target) -- add 'copy' of window on current mspace to target mspace
  local fwin = hs.window.focusedWindow()
  max = fwin:screen():frame()
  winMSpaces[getWinMSpacesPos(fwin)].mspace[target] = true
  -- copy frame from original mSpace
  winMSpaces[getWinMSpacesPos(fwin)].frame[target] = winMSpaces[getWinMSpacesPos(fwin)].frame[currentMSpace]
  refreshMenu()
  refreshWinMSpaces()
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
  goToSpace(currentMSpace) -- refresh
  refreshMenu()
  refreshWinMSpaces()
end


function assignMS(w, boolgotoSpace)
  if indexOpenAppMSpace(w) ~= nil then
    local i = indexOpenAppMSpace(w)
    for j = 1, #mspaces do
      if openAppMSpace[i][2] == mspaces[j] then
        winMSpaces[getWinMSpacesPos(w)].mspace[j] = true
        if openAppMSpace[i][3] ~= nil then
          winMSpaces[getWinMSpacesPos(w)].frame[j] = snap(openAppMSpace[i][3])
        else
          winMSpaces[getWinMSpacesPos(w)].frame[indexOf(mspaces, openAppMSpace[i][2])] = hs.geometry.point(max.w / 2 - w:frame().w / 2, max.h / 2 - w:frame().h / 2, w:frame().w, w:frame().h)                                                                                                      -- put window in middle of screen
        end
        if boolgotoSpace then                                                                                                                                                                      -- not when EnhancedSpaces is started
          goToSpace(indexOf(mspaces, openAppMSpace[i][2]))
        end
      else
        winMSpaces[getWinMSpacesPos(w)].mspace[j] = false
      end
    end
  end
end

function indexOpenAppMSpace(w)
  if openAppMSpace ~= nil then
    for i = 1, #openAppMSpace do
      if w:application():name():gsub('%W', '') == openAppMSpace[i][1]:gsub('%W', '') then
        return i
      end
    end
    return nil
  end
  return nil
end


-- in case a window has previously been minimized by dragging beyond bottom screen border (or for another reason extends beyond bottom screen border), it will be moved to middle of screen
function moveMiddleAfterMouseMinimized(w)
  if w:frame().y + w:frame().h > max.h + heightMB then
    w:setFrame(hs.geometry.point(max.w / 2 - w:frame().w / 2, max.h / 2 - w:frame().h / 2, w:frame().w, w:frame().h))
    winMSpaces[getWinMSpacesPos(w)].frame[currentMSpace] = hs.geometry.point(max.w / 2 - w:frame().w / 2, max.h / 2 - w:frame().h / 2, w:frame().w, w:frame().h)
  end
end


-- determine hs.geometry object for grid positons
function snap(scenario)
  maxWithMB = hs.window.focusedWindow():screen():fullFrame()
  max = hs.window.focusedWindow():screen():frame()
  heightMB = maxWithMB.h - max.h   -- height menu bar
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


return EnhancedSpaces
