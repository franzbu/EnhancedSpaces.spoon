--[[
local function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end
--]]

local EnhancedSpaces = {}

EnhancedSpaces.author = "Franz B. <csaa6335@gmail.com>"
EnhancedSpaces.homepage = "https://github.com/franzbu/EnhancedSpaces.spoon"
EnhancedSpaces.license = "MIT"
EnhancedSpaces.name = "EnhancedSpaces"
EnhancedSpaces.version = "0.9.61"
--EnhancedSpaces.spoonPath = scriptPath()

function EnhancedSpaces:tableToMap(table)
  local map = {}
  for _, v in pairs(table) do
    map[v] = true
  end
  return map
end

function EnhancedSpaces:getWindowUnderMouse()
  local my_pos = hs.geometry.new(hs.mouse.absolutePosition())
  local my_screen = hs.mouse.getCurrentScreen()
  return hs.fnutils.find(hs.window.orderedWindows(), function(w)
    return my_screen == w:screen() and my_pos:inside(w:frame())
  end)
end

function EnhancedSpaces:buttonNameToEventType(name, optionName)
  if name == 'left' then return hs.eventtap.event.types.leftMouseDown end
  if name == 'right' then return hs.eventtap.event.types.rightMouseDown end
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
  menuModifier3 = options.menuModifier3 or self:mergeModifiers(menuModifier1, menuModifier2)
  menuTitles = options.menuTitles or { swap = 'Swap', send = "Send Window", get = "Get Window", help = 'Help', about = 'About', hammerspoon = 'Hammerspoon' }

  hammerspoonMenu = options.hammerspoonMenu or false
  hammerspoonMenuItems = options.hammerspoonMenuItems or { reload = "Reload Config", config = "Open Config", console = 'Console', preferences = 'Preferences', about = 'About Hammerspoon', update = 'Check for Updates...', relaunch = 'Relaunch Hammerspoon', quit = 'Quit Hammerspoon' }

  popupModifier = options.popupModifier or nil
  mbMainPopupKey = options.mbMainPopupKey or nil
  mbSendPopupKey = options.mbSendPopupKey or nil
  mbGetPopupKey = options.mbGetPopupKey or nil
  mbSwapPopupKey = options.mbSwapPopupKey or nil

  modifier1 = options.modifier1 or { 'alt' }
  modifier2 = options.modifier2 or { 'ctrl' }
  modifier1_2 = self:mergeModifiers(modifier1, modifier2)

  modifierReference = options.modifierReference or { 'ctrl', 'shift' }
  deReferenceKey = options.deReferenceKey or '0'
    
  modifierMS = options.modifierMS or modifier2
  modifierMSKeys = options.modifierMSKeys or { 'a', 's', 'd', 'f', 'q', 'w' }

  openAppMSpace = options.openAppMSpace or nil

  modifierSwitchWin = options.modifierSwitchWin or modifier1
  modifierSwitchWinKeys = options.modifierSwitchWinKeys or { 'a', 'q' }

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
  resizeMargin = margin * 100 / 2

  useResize = options.resize or false

  ratioMSpaces = options.ratioMSpaces or 0.8

  mspaces = options.mSpaces or { '1', '2', '3' }
  currentMSpace = self:indexOf(options.MSpaces, options.startMSpace) or 2

  gridIndicator = options.gridIndicator or { 20, 1, 0, 0, 0.33 }

  customWallpaper = options.customWallpaper or false
  wallpapers = {}
  if customWallpaper then
    wallpapers = self:createWallpapers()
  else
    for i = 1, #mspaces do
      --wallpapers[i] = hs.image.imageFromPath(hs.configdir .. '/Spoons/EnhancedSpaces.spoon/wallpapers/default.jpg')
      wallpapers[i] = hs.image.imageFromURL(hs.screen.mainScreen():desktopImageURL())
    end
  end

  startupCommands = options.startupCommands or nil

  swapModifier = options.swapModifier or { 'alt' }
  swapKey = options.swapKey or 's'
  swapSwitchFocus = options.swapSwitchFocus or false

  -- mSpace Control
  mSpaceControlModifier = options.mSpaceControlModifier or { 'alt' }
  mSpaceControlKey = options.mSpaceControlKey or 'a'
  mSpaceControlShow = options.mSpaceControlShow or mspaces
  mSpaceControlConfig = options.mSpaceControlConfig or { 50, 0, 0, 0, 0.9 }
  if mSpaceControlConfig[1] < 1 then mSpaceControlConfig[1] = 1 end
  mSpaceControlFrame = options.mSpaceControlFrame or  { 3, 1, 0, 0, 1, }
  mSpaceControlHideHSC = options.mSpaceControlHideHSC or false -- hide Hammerspoon Console
  mSpaceControlWinOpacity = options.mSpaceControlWinOpacity or 1

  -- switcher
  switcher = dofile(hs.spoons.resourcePath('lib/window_switcher.lua'))
  switcherConfig = options.switcherConfig or {
    textColor = { 0.9, 0.9, 0.9 },
    fontName = 'Lucida Grande',
    textSize = 16, -- in screen points
    highlightColor = { 0.8, 0.5, 0, 0.8 }, -- highlight color for the selected window
    backgroundColor = { 0.3, 0.3, 0.3, 0.5 },
    onlyActiveApplication = false, -- only show windows of the active application
    showTitles = true, -- show window titles
    titleBackgroundColor = { 0, 0, 0 },
    showThumbnails = true, -- show window thumbnails
    selectedThumbnailSize = 284, -- size of window thumbnails in screen points
    showSelectedThumbnail = true, -- show a larger thumbnail for the currently selected window
    thumbnailSize = 112,
    showSelectedTitle = false, -- show larger title for the currently selected window
  }

  --window_filter.lua: windows to disregard
  SKIP_APPS_TRANSIENT_WINDOWS = options.SKIP_APPS_TRANSIENT_WINDOWS or {
    'Spotlight', 'Notification Center', 'loginwindow', 'ScreenSaverEngine', 'PressAndHold',
    'PopClip','Isolator', 'CheatSheet', 'CornerClickBG', 'Moom', 'CursorSense Manager',
    'Music Manager', 'Google Drive', 'Dropbox', '1Password mini', 'Colors for Hue', 'MacID',
    'CrashPlan menu bar', 'Flux', 'Jettison', 'Bartender', 'SystemPal', 'BetterSnapTool', 'Grandview', 'Radium',
    'MenuMetersApp', 'DemoPro', 'DockHelper', 'Maccy', 'Albert', 'Alfred',
  }

  local moveResize = {
    disabledApps = self:tableToMap(options.disabledApps or {}),
    moveStartMouseEvent = self:buttonNameToEventType('left', 'moveMouseButton'),
    resizeStartMouseEvent = self:buttonNameToEventType('right', 'resizeMouseButton'),
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

  autohideDock = self:getDockAutohide()
  maxFF = hs.screen.mainScreen():fullFrame()
  if autohideDock then -- no dock
    max = hs.screen.mainScreen():frame()
    heightMB = maxFF.h - max.h
    heightDock = 0

    hs.timer.doAfter(0.00001, function()
      self:initiateAtStart()
      self:refreshWinTables()
      moveResize.clickHandler:start()
      return moveResize
    end)
  else -- with dock
    local hfmd = hs.screen.mainScreen():frame() -- height frame with menu bar and dock in it
    self:setDockAutohide(true)
    hs.timer.doAfter(0.00001, function()
      local hfm = hs.screen.mainScreen():frame() -- height frame with menu bar in it
      heightDock = hfm.h - hfmd.h
      heightMB = maxFF.h - hfm.h
      max = hfmd

      self:initiateAtStart()
      self:refreshWinTables()
      moveResize.clickHandler:start()
      return moveResize
    end)
  end
end


function EnhancedSpaces:initiateAtStart()
  filter = dofile(hs.spoons.resourcePath('lib/window_filter.lua'))
  filter_all = filter.new()
  winAll = filter_all:getWindows()--hs.window.sortByFocused)
  winMSpaces = {}
  for i = 1, #winAll do
    winMSpaces[i] = {}
    winMSpaces[i].win = winAll[i]
    winMSpaces[i].appName = winAll[i]:application():name() -- ':application():name()' causes errors if used 'later', mostly when creating menu
    winMSpaces[i].snapshot = {}
    winMSpaces[i].mspace = {}
    winMSpaces[i].frame = {}
    for k = 1, #mspaces do
      winMSpaces[i].frame[k] = winAll[i]:frame()
      local s = winAll[i]:snapshot()
      if s then
        winMSpaces[i].snapshot[k] = s:setSize({w = winAll[i]:size().w / 2, h = winAll[i]:size().h / 2})
      end
      if k == currentMSpace then
        winMSpaces[i].mspace[k] = true
      else
        winMSpaces[i].mspace[k] = false
      end
    end
  end
  windowsOnCurrentMS = {} -- always up-to-date list of windows on current mSpace
  _windowsOnCurrentMS = {} -- without active window for switching
  windowsNotOnCurrentMS = {}

  menubar = hs.menubar.new(true, "A"):setTitle(mspaces[currentMSpace])
  menubar:setTooltip("mSpace")

  -- recover windows at start
  for i = 1, #winAll do
    -- in case window is not on current mSpace, move it; i.e., if on current mSpace, don't resize
    if winAll[i]:topLeft().x >= max.w - 1 then -- don't touch windows that are on current screen, even if they are in openAppMSpace
      if self:indexOpenAppMSpace(winAll[i]) ~= nil then -- te be recovered according to openAppMSpace
        self:assignMS(winAll[i], false)
      else -- this means that window was on another mSpace, but is not in openAppMSpace                                                                                                                                       -- window in 'hiding spot'
        -- move window to middle of the current mSpace
        winMSpaces[self:getPosWinMSpaces(winAll[i])].frame[currentMSpace] = hs.geometry.rect(max.w / 2 - winAll[i]:frame().w / 2, max.h / 2 - winAll[i]:frame().h / 2, winAll[i]:frame().w, winAll[i]:frame().h)                                                                                      -- put window in middle of screen
      end
    end
  end

  -- watchdogs
  filter.default:subscribe(filter.windowNotOnScreen, function(w)
    --print('____________ windowNotOnScreen ____________')
    hs.timer.doAfter(0.0000001, function() --delay, otherwise 'filter_all = hs.window.filter.new()' not ready after closing of windows (in certain situations)
      if not enteredFullscreen then
        if w:frame().h ~= maxFF.h then
          self:refreshWinTables()
        end
      end
    end)
    hs.timer.doAfter(1, function()
      if not enteredFullscreen then
        if windowsOnCurrentMS ~= nil and #windowsOnCurrentMS >= 1 then
          windowsOnCurrentMS[1]:focus() -- activate last active window on current mSpace when closing/minimizing one
        end
      end
      self:refreshWinTables()
    end)

    -- for avoiding switching of focus after force-closing a window in fullscreen-mode: set 'enteredFullscreen' to false if fullscreen window has been force-closed (then 'fullscreenedWindowID' is not present)
    -- when force-closing window, 'enteredFullscreen' needs to be set to 'false'
    if w:id() == fullscreenedWindowID then
      hs.timer.doAfter(5, function()
        enteredFullscreen = false
        self:refreshWinTables()
      end)
    end
  end)

  filter.default:subscribe(filter.windowOnScreen, function(w)
    hs.timer.doAfter(0.0000001, function()
      if not enteredFullscreen then -- 'windowOnScreen' is triggered when leaving fullscreen, which is hereby counteracted
        --print('____________ windowOnScreen ____________')-- .. winMSpaces[self:getPosWinMSpaces(w)].appName)   
        if self:indexOpenAppMSpace(w) ~= nil and not self:contextMenuTelegram() then -- with Telegram context menu open, other windows aren't assigned mSpaces when opened
          self:refreshWinTables()
          self:moveMiddleAfterMouseMinimized(w)
          self:assignMS(w, true)
          w:focus()
        else
          self:refreshWinTables()
          w:focus()
        end
      end
    end)
  end)

  filter.default:subscribe(filter.windowFocused, function(w)
    --print('____________ windowFocused ____________ ' .. winMSpaces[self:getPosWinMSpaces(w)].appName)
    self:refreshSnapshots(currentMSpace)
    if w:frame().h == maxFF.h and w:frame().w == max.w then
      enteredFullscreen = true
      fullscreenedWindowID = w:id()
    end
    --if not enteredFullscreen and w:frame().h ~= maxFF.h then
    if w:frame().h ~= maxFF.h and not boolMSpaceControl then -- and not enteredFullscreen then
      hs.timer.doAfter(0.0000001, function()
        self:refreshWinTables()
        self:cmdTabFocus(w)
      end)
    end
    --end)
  end)

  -- 'window_filter.lua' has been adjusted: 'local WINDOWMOVED_DELAY=0.01' instead of '0.5' to get rid of delay
  filter.default:subscribe(filter.windowMoved, function(w)
    hs.timer.doAfter(0.0000001, function()
      self:refreshSnapshots(currentMSpace)
      --print('____________ windowMoved ____________' .. winMSpaces[self:getPosWinMSpaces(w)].appName .. ', ' .. w:frame().h)
      if w:frame().h == maxFF.h and w:frame().w == max.w then
        enteredFullscreen = true
        fullscreenedWindowID = w:id()
      elseif not enteredFullscreen and not boolMSpaceControl then
        self:adjustWinFrame(w)
        self:refreshWinTables()
      end
    end)
  end)

  -- next 2 filters are for avoiding calling self:assignMS(_, true) after unfullscreening a window ('windowOnScreen' is called for each window after a window gets unfullscreened)
  enteredFullscreen = false
  fullscreenedWindowID = 0
  ---[[ -- doesn't get triggered reliably; workaround has been implemented instead
  filter.default:subscribe(filter.windowFullscreened, function(w)
    --print('_____!!!_______ windowFullscreened ____________' .. winMSpaces[self:getPosWinMSpaces(w)].appName)
    enteredFullscreen = true
    fullscreenedWindowID = w:id()
  end)
  --]]

  filter.default:subscribe(filter.windowUnfullscreened, function(w)
    --print('____________ windowUnfullscreened ____________' .. winMSpaces[self:getPosWinMSpaces(w)].appName)
    hs.timer.doAfter(0.5, function()
      w:focus()
      enteredFullscreen = false
      self:refreshWinTables()
    end)
  end)
  --[[ --screenwatcher: stops working if screen resolution is changed a couple of time
  boolStart = true -- for 'hs.screen.watcher.new' not to get triggered at start
  local screenwatcher = hs.screen.watcher.new(function()
    if not boolStart then
      boolStart = true
      print('!!! screenwatcher...')
      autohideDock = self:getDockAutohide()
      maxFF = hs.screen.mainScreen():fullFrame()
      if autohideDock then -- no dock
        max = hs.screen.mainScreen():frame()
        heightMB = maxFF.h - max.h
        heightDock = 0
    
      else -- with dock
        local hfmd = hs.screen.mainScreen():frame() -- height frame with menu bar and dock in it
        self:setDockAutohide(true)
        hs.timer.doAfter(0.1, function()
          local hfm = hs.screen.mainScreen():frame() -- height frame with menu bar in it
          heightDock = hfm.h - hfmd.h
          heightMB = maxFF.h - hfm.h
          max = hfmd
        end)
        hs.timer.doAfter(0.1, function()
          self:setDockAutohide(false)
        end)
        hs.timer.doAfter(1, function()
          --self:setDockAutohide(false)
          boolStart = false
        end)

      end
    end
  end)
  screenwatcher:start()
  --]]

  switcher = switcher.new()
  switcher.ui.textColor = switcherConfig.textColor
  switcher.ui.fontName = switcherConfig.fontName
  switcher.ui.textSize = switcherConfig.textSize
  switcher.ui.highlightColor = switcherConfig.highlightColor
  switcher.ui.backgroundColor = switcherConfig.backgroundColor
  switcher.ui.onlyActiveApplication = switcherConfig.onlyActiveApplication
  switcher.ui.showTitles = switcherConfig.showTitles
  switcher.ui.titleBackgroundColor = switcherConfig.titleBackgroundColor
  switcher.ui.showThumbnails = switcherConfig.showThumbnails
  switcher.ui.selectedThumbnailSize = switcherConfig.selectedThumbnailSize
  switcher.ui.showSelectedThumbnail = switcherConfig.showSelectedThumbnail
  switcher.ui.thumbnailSize = switcherConfig.thumbnailSize
  switcher.ui.showSelectedTitle = switcherConfig.showSelectedTitle

  -- cycle through windows of current mSpace
  if modifierSwitchWin[1] ~= '' then
    hs.hotkey.bind(modifierSwitchWin, modifierSwitchWinKeys[1], function()
      self:refreshWinTables() -- for using up-to-date window tables (after force-closing apps this could be an issue otherwiese)
      switcherChangeFocus = true
      winGiveFocus = switcher:next(windowsOnCurrentMS)
    end)
    hs.hotkey.bind({modifierSwitchWin[1], 'shift' }, modifierSwitchWinKeys[1], function()
      self:refreshWinTables() -- for using up-to-date window tables (after force-closing apps this could be an issue otherwiese)
      switcherChangeFocus = true
      winGiveFocus = switcher:previous(windowsOnCurrentMS) --reverse order
    end)
    -- 'subscribe', watchdog for releasing { 'alt' } -> to give focus to selected window (without all windows along the way would be given focus, which would falsify tables containing windows in order of "FocusedLast"
    prevModifierSwitchWin = nil
    keyboardTrackerSwitchWin = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
      local flags = self:eventToArray(e:getFlags())
      -- since on modifierSwitchWin release the flag is 'nil', var 'prevModifierSwitchWin' is used
      if switcherChangeFocus and self:modifiersEqual(prevModifierSwitchWin, modifierSwitchWin) and winGiveFocus ~= nil then
        winGiveFocus:focus()
        switcherChangeFocus = false
      end
      prevModifierSwitchWin = flags
    end)
    keyboardTrackerSwitchWin:start()

    -- cycle through windows of current mSpace with the exception of active one, then swap
    switcherSwapWindows = false
    if swapModifier[1] ~= '' then
      hs.hotkey.bind(swapModifier, swapKey, function()
        self:refreshWinTables() -- for using up-to-date window tables (after force-closing apps this could be an issue otherwiese)
        win1 = winAll[1]
        switcherSwapWindows = true
        win2 = switcher:next(_windowsOnCurrentMS)
      end)
      hs.hotkey.bind({swapModifier[1], 'shift' }, swapKey, function()
        self:refreshWinTables() -- for using up-to-date window tables (after force-closing apps this could be an issue otherwiese)
        win1 = winAll[1]
        switcherSwapWindows = true
        win2 = switcher:previous(_windowsOnCurrentMS) --reverse order
      end)

      -- 'subscribe', watchdog for releasing swapModifier
      prevModifierSwap = nil
      keyboardTrackerSwapWin = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
        local flags = self:eventToArray(e:getFlags())
        -- since on swapModifier release the flag is 'nil', var 'prevModifierSwap' is used
        if switcherSwapWindows and self:modifiersEqual(prevModifierSwap, swapModifier) and win2 ~= nil then
          local frameWin1 = winMSpaces[self:getPosWinMSpaces(win1)].frame[currentMSpace]
          winMSpaces[self:getPosWinMSpaces(win1)].frame[currentMSpace] = winMSpaces[self:getPosWinMSpaces(win2)].frame[currentMSpace]
          winMSpaces[self:getPosWinMSpaces(win2)].frame[currentMSpace] = frameWin1
          
          if swapSwitchFocus then
            hs.timer.doAfter(0.001, function()
              win2:focus()
            end)
          else -- focus stays with app in new place - still, focus needs to shift back and forth for window tables such as windowsOnCurrentMS to move a window also up the ranking order if it has been 'passively' chosen (when switching places)
            win2:focus()
            win1:focus()
          end
          self:refreshWinTables()
          switcherSwapWindows = false
        end
        prevModifierSwap = flags
      end)
      keyboardTrackerSwapWin:start()
    end
  end

  if modifierSwitchWin[1] ~= '' then
    -- cycle through references of one window
    hs.hotkey.bind(modifierSwitchWin, modifierSwitchWinKeys[2], function()
      pos = self:getPosWinMSpaces(hs.window.focusedWindow())
      local nextFR = self:getnextMSpaceNumber(currentMSpace)
      while not winMSpaces[pos].mspace[nextFR] do
        if nextFR == #mspaces then
          nextFR = 1
        else
          nextFR = nextFR + 1
        end
      end
      self:goToSpace(nextFR)
      winMSpaces[pos].win:focus()
    end)
  end

  -- cycle through mSpaces
  mSpaceCyclePos = currentMSpace
  mSpaceCycleCount = 0
  if mSpaceControlModifier[1] ~= '' then
    hs.hotkey.bind(mSpaceControlModifier, mSpaceControlKey, function()
      if not boolMSpaceControl then
        self:mSpaceControl()
      else
        frameCanvas[mSpaceCyclePos]:delete()
        mSpaceCyclePos = self:getnextMSpaceNumber(mSpaceCyclePos)
        frameCanvas[mSpaceCyclePos]:show()
        canvasMSpaceControl[mSpaceCyclePos]:show()
        for i = 1, #canvasWin do
          canvasWin[i]:show()
        end
      end
      mSpaceCycleCount = mSpaceCycleCount + 1
    end)
    -- reverse order by additionally pressing 'shift'
    mSpaceControlModifierReverse = self:mergeModifiers(mSpaceControlModifier, { 'shift' })
    hs.hotkey.bind(mSpaceControlModifierReverse, mSpaceControlKey, function()
      if not boolMSpaceControl then
        self:mSpaceControl()
      else
        frameCanvas[mSpaceCyclePos]:delete()
        mSpaceCyclePos = self:getprevMSpaceNumber(mSpaceCyclePos)
        frameCanvas[mSpaceCyclePos]:show()
        canvasMSpaceControl[mSpaceCyclePos]:show()
        for i = 1, #canvasWin do
          canvasWin[i]:show()
        end
      end
      mSpaceCycleCount = mSpaceCycleCount + 1
    end)
    prevmSpaceControlModifier = nil
    keyboardTrackerMSpaceControl = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
      local flags = self:eventToArray(e:getFlags())
      -- since on mSpaceControlModifier release the flag is 'nil', var 'prevmSpaceControlModifier' is used
      if (self:modifiersEqual(prevmSpaceControlModifier, mSpaceControlModifier) or self:modifiersEqual(prevmSpaceControlModifier, mSpaceControlModifierReverse) or self:modifiersEqual(prevmSpaceControlModifier, { 'shift'}) or self:modifiersEqual(prevmSpaceControlModifier, { 'alt'})) and flags[1] == nil and boolMSpaceControl and mSpaceCycleCount > 1 then
        self:goToSpace(mSpaceCyclePos)
        hs.timer.doAfter(0.0000001, function()
          boolMSpaceControl = false
          mSpaceCycleCount = 0
        end)
        for i = 1, #canvasMSpaceControl do
          canvasMSpaceControl[i]:delete()
          frameCanvas[i]:delete()
        end
        for i = 1, #canvasWin do
          canvasWin[i]:delete()
        end
        baseCanvas:delete()
      end
      prevmSpaceControlModifier = flags
    end)
    keyboardTrackerMSpaceControl:start()
    -- pressing 'Esc' closes mSpace Control
    if mSpaceControlModifier[1] ~= '' then
      keyboardTrackerMSpaceControlEsc = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
        if e:getKeyCode() == 53 and boolMSpaceControl then
          boolMSpaceControl = false
          mSpaceCycleCount = 0
          for i = 1, #canvasMSpaceControl do
            canvasMSpaceControl[i]:delete()
            frameCanvas[i]:delete()
          end
          for i = 1, #canvasWin do
            canvasWin[i]:delete()
          end
          baseCanvas:delete()
          refreshMSpaces() -- refresh mSpace
        end
      end)
      keyboardTrackerMSpaceControlEsc:start()
    end
  end

  if modifierReference[1] ~= '' then
    -- reference/dereference windows to/from mspaces, goto mspaces
    for i = 1, #mspaces do
      hs.hotkey.bind(modifierReference, mspaces[i], function()
        self:refWinMSpace(i)
      end)
    end
    -- de-reference
    hs.hotkey.bind(modifierReference, deReferenceKey, function()
      self:derefWinMSpace()
    end)
  end

  if modifierMS[1] ~= '' then
    -- switching spaces/moving windows
    hs.hotkey.bind(modifierMS, modifierMSKeys[1], function() -- previous space (incl. cycle)
      currentMSpace = self:getprevMSpaceNumber(currentMSpace)
      self:goToSpace(currentMSpace)
    end)
    hs.hotkey.bind(modifierMS, modifierMSKeys[2], function() -- next space (incl. cycle)
      currentMSpace = self:getnextMSpaceNumber(currentMSpace)
      self:goToSpace(currentMSpace)
    end)
    hs.hotkey.bind(modifierMS, modifierMSKeys[5], function() -- move active window to previous space and switch there (incl. cycle)
      -- move window to prev space and switch there
      self:moveToSpace(self:getprevMSpaceNumber(currentMSpace), currentMSpace, true)
      currentMSpace = self:getprevMSpaceNumber(currentMSpace)
      self:goToSpace(currentMSpace)
    end)
    hs.hotkey.bind(modifierMS, modifierMSKeys[6], function() -- move active window to next space and switch there (incl. cycle)
      -- move window to next space and switch there
        self:moveToSpace(self:getnextMSpaceNumber(currentMSpace), currentMSpace, true)
        currentMSpace = self:getnextMSpaceNumber(currentMSpace)
        self:goToSpace(currentMSpace)
    end)
    hs.hotkey.bind(modifierMS, modifierMSKeys[3], function() -- move active window to previous space (incl. cycle)
      -- move window to prev space
      self:moveToSpace(self:getprevMSpaceNumber(currentMSpace), currentMSpace, true)
    end)
    hs.hotkey.bind(modifierMS, modifierMSKeys[4], function() -- move active window to next space (incl. cycle)
      -- move window to next space
      self:moveToSpace(self:getnextMSpaceNumber(currentMSpace), currentMSpace, true)
    end)
  end

  -- goto mspaces directly with 'modifierSwitchMS-<name of mspace>'
  if modifierSwitchMS[1] ~= '' then
    for i = 1, #mspaces do
      hs.hotkey.bind(modifierSwitchMS, mspaces[i], function()
        self:goToSpace(i)
      end)
    end
  end

  -- move window to specific mSpace
  if modifierMoveWinMSpace[1] ~= '' then
    for i = 1, #mspaces do
      hs.hotkey.bind(modifierMoveWinMSpace, mspaces[i], function() -- move active window to next space and switch there (incl. cycle)
      self:moveToSpace(i, currentMSpace, true)
      end)
    end
  end

  -- keyboard shortcuts - snapping windows into grid postions
  if modifierSnap1[1] ~= '' then
    for i = 1, #modifierSnapKeys[1] do
      hs.hotkey.bind(modifierSnap1, modifierSnapKeys[1][i][2], function()
        hs.window.focusedWindow():move(self:snap(modifierSnapKeys[1][i][1]), nil, false, 0)
      end)
    end
  end
  if modifierSnap2[1] ~= '' then
    for i = 1, #modifierSnapKeys[2] do
      hs.hotkey.bind(modifierSnap2, modifierSnapKeys[2][i][2], function()
        hs.window.focusedWindow():move(self:snap(modifierSnapKeys[2][i][1]), nil, false, 0)
      end)
    end
  end
  if modifierSnap3[1] ~= '' then
    for i = 1, #modifierSnapKeys[3] do
      hs.hotkey.bind(modifierSnap3, modifierSnapKeys[3][i][2], function()
        hs.window.focusedWindow():move(self:snap(modifierSnapKeys[3][i][1]), nil, false, 0)
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
  if popupModifier ~= nil and mbSwapPopupKey ~= nil then
    hs.hotkey.bind(popupModifier, mbSwapPopupKey, function()
      mbSwapPopup:popupMenu(hs.mouse.absolutePosition() )
    end)
  end

  -- startup commands
  if startupCommands ~= nil then
    for i = 1, #startupCommands do
      os.execute(startupCommands[i])
    end
  end

  if not autohideDock then
    -- has to be triggered later than 'self:setDockAutohide(true)'
    self:setDockAutohide(false)
  end
  --[[
  hs.timer.doAfter(1, function()
    boolStart = false
  end)
  --]]
end

-- mSpace Control: prepare wallpapers
---[[
function EnhancedSpaces:createWallpapers()
  local wp = {}
  for i = 1, #mspaces do
    if hs.fs.displayName(hs.configdir .. '/Spoons/EnhancedSpaces.spoon/wallpapers/' .. mspaces[i] .. '.jpg') then
      wp[i] = hs.image.imageFromPath(hs.configdir .. '/Spoons/EnhancedSpaces.spoon/wallpapers/' .. mspaces[i] .. '.jpg')
    else
      wp[i] = hs.image.imageFromPath(hs.configdir .. '/Spoons/EnhancedSpaces.spoon/wallpapers/default.jpg')
    end
  end
  return wp
end
--]]
--[[
function EnhancedSpaces:createWallpapers()
  local wp = {}
  for i = 1, #mspaces do
    if hs.fs.displayName(hs.spoons.resourcePath('wallpapers/' .. mspaces[i] .. '.jpg')) then
      hs.alert.show('safasdf')
      wp[i] = hs.image.imageFromPath(hs.spoons.resourcePath('wallpapers/' .. mspaces[i] .. '.jpg'))
    else
      wp[i] = hs.image.imageFromPath(hs.spoons.resourcePath('wallpapers/default.jpg'))
    end
  end
  return wp
end
--]]

-- mSpace Control
boolMSpaceControl = false
canvasMSpaceControl = {} -- canvases containing one mSpace preview each
frameCanvas = {} -- frame for highlighting current mSpace
canvasWin = {} -- 
function EnhancedSpaces:mSpaceControl()
  boolMSpaceControl = true

  -- background canvas
  baseCanvas = hs.canvas:new()
  baseCanvas:insertElement(
  {
    action = 'fill',
    type = 'rectangle',
    fillColor = {
      red = mSpaceControlConfig[2],
      green = mSpaceControlConfig[3],
      blue = mSpaceControlConfig[4],
      alpha = mSpaceControlConfig[5]
    },
    trackMouseDown = true,
  }, 1)
  --baseCanvas:canvasMouseEvents(true, false, false, false) -- ([down], [up], [enterExit], [move])
  baseCanvas:mouseCallback(function() -- (canvas object, event, id, x, y)
    self:goToSpace(currentMSpace)
    hs.timer.doAfter(0.0000001, function()
      boolMSpaceControl = false
      mSpaceCycleCount = 0
    end)

    for i = 1, #canvasMSpaceControl do
      canvasMSpaceControl[i]:delete()
      frameCanvas[i]:delete()
    end
    for i = 1, #canvasWin do
      canvasWin[i]:delete()
    end
    baseCanvas:delete()
  end)
  baseCanvas:frame(hs.geometry.new(0, 0, maxFF.w, maxFF.h))
  baseCanvas:show()

  -- canvases with previews of mSpaces
  for i = 1, #mSpaceControlShow do
    canvasMSpaceControl[i] = hs.canvas:new()
    canvasMSpaceControl[i]:insertElement(
    {
      image = wallpapers[i],
      imageScaling = 'scaleToFit',
      type = 'image',
      trackMouseDown = true,
    }, 1)
    --canvasMSpaceControl[i]:canvasMouseEvents(true, false, false, false) -- ([down], [up], [enterExit], [move])
    canvasMSpaceControl[i]:mouseCallback(function() -- (canvas object, event, id, x, y)
      self:goToSpace(self:indexOf(mspaces, mSpaceControlShow[i]))
      hs.timer.doAfter(0.0000000001, function() -- prevent watchdogs 'windowFocused' and 'windowMoved' from being triggered
        boolMSpaceControl = false
        mSpaceCycleCount = 0
      end)
      for j = 1, #canvasMSpaceControl do
        canvasMSpaceControl[j]:delete()
        frameCanvas[j]:delete()
      end
      for j = 1, #canvasWin do
        canvasWin[j]:delete()
      end
      baseCanvas:delete()
    end)
  end

  if #mSpaceControlShow <= 4 then
    mSpaceControlX = 2
    mSpaceControlY = 2
  elseif #mSpaceControlShow <= 6 then
    mSpaceControlX = 2
    mSpaceControlY = 3
  elseif #mSpaceControlShow <= 9 then
    mSpaceControlX = 3
    mSpaceControlY = 3
  elseif #mSpaceControlShow <= 12 then
    mSpaceControlX = 3
    mSpaceControlY = 4
  elseif #mSpaceControlShow <= 16 then
    mSpaceControlX = 4
    mSpaceControlY = 4
  elseif #mSpaceControlShow <= 20 then
    mSpaceControlX = 4
    mSpaceControlY = 5
  elseif #mSpaceControlShow <= 25 then
    mSpaceControlX = 5
    mSpaceControlY = 5
  elseif #mSpaceControlShow <= 30 then
    mSpaceControlX = 5
    mSpaceControlY = 6
  else
    mSpaceControlX = math.ceil(math.sqrt(#mSpaceControlShow))
    mSpaceControlY = mSpaceControlX
  end
  local padH = mSpaceControlConfig[1] / 1000 * max.w / mSpaceControlY
  local ft = mSpaceControlFrame[1] -- frame thickness
  local screenRatio = maxFF.h / max.w
  local mSpacePreviewW = (max.w - 2 * padH) / mSpaceControlY - 2 * padH
  local mSpacePreviewH = mSpacePreviewW * screenRatio
  local padV = (maxFF.h - mSpaceControlX * mSpacePreviewH) / (mSpaceControlX + 1)
  local k = 1
  for i = 1, mSpaceControlX do
    for j = 1, mSpaceControlY do
      if k > #mSpaceControlShow then break end
      canvasMSpaceControl[k]:frame(hs.geometry.new(
        2 * padH + (j - 1) * mSpacePreviewW + (j-1) * 2 * padH, -- x
        i * padV + (i - 1) * mSpacePreviewH, -- y
        mSpacePreviewW, -- w
        mSpacePreviewH -- h
      ))
      canvasMSpaceControl[k]:show()
      -- frame around current mSpace
      if mSpaceControlFrame[1] ~= '' then
        frameCanvas[k] = hs.canvas:new()
        frameCanvas[k]:insertElement(
        {
          action = 'fill',
          type = 'rectangle',
          fillColor = {
            red = mSpaceControlFrame[2],
            green = mSpaceControlFrame[3],
            blue = mSpaceControlFrame[4],
            alpha = mSpaceControlFrame[5],
          },
          trackMouseDown = true,
        }, 1)
        --frameCanvas[k]:canvasMouseEvents(true, false, false, false) -- ([down], [up], [enterExit], [move])
        frameCanvas[k]:mouseCallback(function() -- (canvas object, event, id, x, y)
          self:goToSpace(currentMSpace)
          hs.timer.doAfter(0.0000001,
            function() -- prevent watchdogs windowFocused and windowMoved from being triggered
              boolMSpaceControl = false
              mSpaceCycleCount = 0
            end)

          for o = 1, #canvasMSpaceControl do
            canvasMSpaceControl[o]:delete()
            frameCanvas[o]:delete()
          end
          for o = 1, #canvasWin do
            canvasWin[o]:delete()
          end
          baseCanvas:delete()
        end)
        frameCanvas[k]:frame(hs.geometry.new(
          canvasMSpaceControl[k]:frame().x - ft,
          canvasMSpaceControl[k]:frame().y - ft,
          canvasMSpaceControl[k]:frame().w + 2 * ft,
          canvasMSpaceControl[k]:frame().h + 2 * ft
        ))
      end
      k = k + 1
    end
  end

  frameCanvas[currentMSpace]:show() -- show at the end, so frame is on top of adjacent mSpaces
  canvasMSpaceControl[currentMSpace]:show() -- necessary, otherwise frameCanvas would be on top

  -- insert windows
  for i = 1, #mspaces do
    local ratioW = canvasMSpaceControl[i]:frame().w / max.w
    local ratioH = canvasMSpaceControl[i]:frame().h / max.h
    for j = #winMSpaces, 1, -1 do -- last focused 'painted' last, so it is in foreground
      if winMSpaces[j].mspace[i] then
        table.insert(canvasWin, hs.canvas:new())
        canvasWin[#canvasWin]:insertElement(
        {
          image = winMSpaces[j].snapshot[i],
          imageAlpha = mSpaceControlWinOpacity,
          type = 'image',
          imageScaling = 'scaleToFit',
          trackMouseDown = true,
          id = winMSpaces[j].win:id(),
        }, 1)
        --canvasWin[#canvasWin]:canvasMouseEvents(true, false, false, false) -- ([down], [up], [enterExit], [move]) -- id is always '_canvas_' and therefore not usable here
        canvasWin[#canvasWin]:mouseCallback(function(_, _, id) -- (canvas object, event, id, x, y)
          self:goToSpace(i)
          -- unreliable for giving focus to window on clicked canvasWin: winMSpaces[j] -> 'winMSpaces[j].win:id()' handed as 'id' works
          -- reason unclear: winMSpaces[j] unreliable, 
           for o = 1, #winMSpaces do
            if winMSpaces[o].win:id() == id then
              winMSpaces[o].win:focus()
              hs.mouse.absolutePosition(hs.geometry.point(
                winMSpaces[o].win:frame().x + winMSpaces[o].win:frame().w / 2,
                winMSpaces[o].win:frame().y + winMSpaces[o].win:frame().h / 2
              ))
              break
            end
          end
          -- cleaning up
          hs.timer.doAfter(0.0000001, function()
            boolMSpaceControl = false
            mSpaceCycleCount = 0
          end)

          for n = 1, #canvasMSpaceControl do
            canvasMSpaceControl[n]:delete()
            frameCanvas[n]:delete()
          end
          for n = 1, #canvasWin do
            canvasWin[n]:delete()
          end
          baseCanvas:delete()
        end)
        canvasWin[#canvasWin]:frame(hs.geometry.new(
          winMSpaces[j].frame[i].x * ratioW + canvasMSpaceControl[i]:frame().x,
          winMSpaces[j].frame[i].y * ratioH - heightMB * ratioH + canvasMSpaceControl[i]:frame().y,
          winMSpaces[j].frame[i].w * ratioW,
          winMSpaces[j].frame[i].h * ratioH
        ))
        canvasWin[#canvasWin]:show()
      end
    end
  end
  self:goToSpace(currentMSpace)
end


function EnhancedSpaces:refreshMenu()
  mainMenu = {
    {
      title = "mSpace Control",
      fn = function(mods) self:mSpaceControl() end
    },
    {
      title = "mSpaces",
      menu = self:createMSpaceMenu(),
    },
    { title = "-" },
    {
      title = menuTitles.swap, disabled = self:trueIfZero(_windowsOnCurrentMS),
      menu = self:createSwapWindowMenu(),
    },
    { title = "-" },
    {
      title = self:getToggleRefWindow()[1], disabled = self:getToggleRefWindow()[2],
      menu = self:createToggleRefMenu(),
    },
    { title = "-" },
    {
      title = menuTitles.send, disabled = self:trueIfZero(windowsOnCurrentMS),
      menu = self:createSendWindowMenu(),
    },
    {
      title = menuTitles.get, disabled = self:trueIfZero(windowsNotOnCurrentMS),
      menu = self:createGetWindowMenu(),
    },
    { title = "-" },
    { title = menuTitles.help, fn = function() os.execute('/usr/bin/open https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md') end },
    { title = menuTitles.about, fn =  function() hs.dialog.blockAlert('EnhancedSpaces', 'v0.9.61.1\n\n\nMakes you more productive.\nUse your time for what really matters.') end },
    { title = "-" },
    {
      title = self:hsTitle(), --image = hs.image.imageFromPath(hs.configdir .. '/Spoons/EnhancedSpaces.spoon/images/hs.png'):setSize({ h = 15, w = 15 }),
      menu = self:hsMenu(),
    },
  }
  menubar:setMenu(mainMenu)

  mbMainPopup = hs.menubar.new(false)
  mainPopupMenu = {
    {
      title = "mSpaces",
      menu = self:createMSpaceMenu(),
    },
    { title = "-" },
    {
      title = menuTitles.swap, disabled = self:trueIfZero(_windowsOnCurrentMS),
      menu = self:createSwapWindowMenu(),
    },
    { title = "-" },
    {
      title = self:getToggleRefWindow()[1], disabled = self:getToggleRefWindow()[2],
      menu = self:createToggleRefMenu(),
    },
    { title = "-" },
    {
      title = menuTitles.send, disabled = self:trueIfZero(windowsOnCurrentMS),
      menu = self:createSendWindowMenu(),
    },
    {
      title = menuTitles.get, disabled = self:trueIfZero(windowsNotOnCurrentMS),
      menu = self:createGetWindowMenu(),
    },
  }
  mbMainPopup:setMenu(mainPopupMenu)

  mbSwapPopup = hs.menubar.new(false)
  swapWindowMenu = {
    {
      title = menuTitles.swap, disabled = self:trueIfZero(_windowsOnCurrentMS),
      menu = self:createSwapWindowMenu(),
    },
  }
  mbSwapPopup:setMenu(swapWindowMenu)

  mbSendPopup = hs.menubar.new(false)
  sendWindowMenu = {
    { title = "-" },
    {
      title = menuTitles.send, disabled = self:trueIfZero(windowsOnCurrentMS),
      menu = self:createSendWindowMenu(),
    },
  }
  mbSendPopup:setMenu(sendWindowMenu)

  mbGetPopup = hs.menubar.new(false)
  getWindowMenu = {
    { 
      title = menuTitles.get, disabled = self:trueIfZero(windowsNotOnCurrentMS),
      menu = self:createGetWindowMenu(),
    },
  }
  mbGetPopup:setMenu(getWindowMenu)
end
function EnhancedSpaces:trueIfZero(t) -- disable send/get titles in menu in case windowsOnCurrentMS/windowsNotOnCurrentMS is empty
  if #t == 0 then return true end
  return false
end
function EnhancedSpaces:hsTitle()
  if not hammerspoonMenu then return nil end
  return menuTitles.hammerspoon
end
function EnhancedSpaces:hsMenu()
  if not hammerspoonMenu then return nil end
  return {
    { title = hammerspoonMenuItems.reload, fn = function() hs.reload() end },
    { title = hammerspoonMenuItems.config, fn = function() os.execute('/usr/bin/open ~/.hammerspoon/init.lua') end },
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
function EnhancedSpaces:createMSpaceMenu()
  mSpaceMenu = {}
  for i = 1, #mspaces do
    table.insert(mSpaceMenu, { title = mspaces[i], checked = self:mSpaceMenuItemChecked(i), disabled = self:mSpaceMenuItemChecked(i), fn = function(mods)
      self:goToSpace(i)
    end })
  end
  return mSpaceMenu
end
function EnhancedSpaces:mSpaceMenuItemChecked(j)
  if j == currentMSpace then return true end
  return false
end
-- menu returns table with modifers pressed in this format: '{ alt = true, cmd = false, ctrl = false, fn = false, shift = false } -> turned into array of modifiers used
function EnhancedSpaces:getModifiersMods(mods)
  local t = {}
  for i,v in pairs(mods) do
    if v then
      table.insert(t, i)
    end
  end
  return t
end


-- swap windows on current mSpace
function EnhancedSpaces:createSwapWindowMenu()
  swapWindowMenu = {}
  for i = 1, #windowsOnCurrentMS do
    table.insert(swapWindowMenu, {
      --title = windowsOnCurrentMS[i]:application():name(),
      title = winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].appName,
      menu = self:createSwapWindowMenuItems(windowsOnCurrentMS[i]),
    })
  end
  return swapWindowMenu
end


function EnhancedSpaces:createSwapWindowMenuItems(w)
  --if w == nil then return end
  swapWindowMenuItems = {}
  for i = 1, #windowsOnCurrentMS do
    if w:id() ~= windowsOnCurrentMS[i]:id() then
      table.insert(swapWindowMenuItems, {
        --title = windowsOnCurrentMS[i]:application():name(),
        title = winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].appName,
        checked = false,
        disabled = false,
        fn = function(mods)
          if self:modifiersEqual(self:getModifiersMods(mods), menuModifier3) then -- menuModifier3: move windows to a5/a6
            winMSpaces[self:getPosWinMSpaces(w)].frame[currentMSpace] = self:snap('a5')
            winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].frame[currentMSpace] = self:snap('a6')
            --self:goToSpace(currentMSpace) -- refresh screen
            self:refreshWinTables()
            winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].win:focus()
            winMSpaces[self:getPosWinMSpaces(w)].win:focus()
          elseif self:modifiersEqual(self:getModifiersMods(mods), menuModifier2) then -- menuModifier2: move windows to a3/a4
            winMSpaces[self:getPosWinMSpaces(w)].frame[currentMSpace] = self:snap('a3')
            winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].frame[currentMSpace] = self:snap('a4')
            --self:goToSpace(currentMSpace) -- refresh screen
            self:refreshWinTables()
            winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].win:focus()
            winMSpaces[self:getPosWinMSpaces(w)].win:focus()
          elseif self:modifiersEqual(self:getModifiersMods(mods), menuModifier1) then -- menuModifier1: move windows to a1/a2
            winMSpaces[self:getPosWinMSpaces(w)].frame[currentMSpace] = self:snap('a1')
            winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].frame[currentMSpace] = self:snap('a2')
            --self:goToSpace(currentMSpace) -- refresh screen
            self:refreshWinTables()
            winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].win:focus()
            winMSpaces[self:getPosWinMSpaces(w)].win:focus()
          else
            local frameWin1 = winMSpaces[self:getPosWinMSpaces(w)].frame[currentMSpace]
            winMSpaces[self:getPosWinMSpaces(w)].frame[currentMSpace] = winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])]
            .frame[currentMSpace]
            winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].frame[currentMSpace] = frameWin1
            --self:goToSpace(currentMSpace) -- refresh screen
            self:refreshWinTables()
            winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].win:focus()
            winMSpaces[self:getPosWinMSpaces(w)].win:focus()
          end
        end
      })
    end
  end
  return swapWindowMenuItems
end


-- references: toggle (no modifier); menuModifier1: remove all references but the one clicked; menuModifier2: reference all but the one clicked; menuModifier3: reference all
function EnhancedSpaces:getToggleRefWindow()
  if windowsOnCurrentMS ~= nil and #windowsOnCurrentMS > 0 then
    --return { windowsOnCurrentMS[1]:application():name(), false }
    return { winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[1])].appName, false }
  else
    return { '', true }
  end
end
function EnhancedSpaces:createToggleRefMenu()
  posWin = self:getPosWinMSpaces(hs.window.focusedWindow()) --or false
  if posWin == nil then return end -- if window has just been minimized/closed, it is irrelevant for toggling references (focus is about to move to other window))
  winMenu = {}
  for i = 1, #mspaces do
    table.insert(winMenu, {
      title = mspaces[i],
      checked = winMSpaces[posWin].mspace[i],
      fn = function(mods)
        if self:modifiersEqual(self:getModifiersMods(mods), menuModifier3) then -- menuModifier3: only the selected item enabled and moving there
          for j = 1, #mspaces do
            if j == i then
              winMSpaces[posWin].mspace[j] = true
            else
              winMSpaces[posWin].mspace[j] = false
            end
          end
          self:goToSpace(i)
        elseif self:modifiersEqual(self:getModifiersMods(mods), menuModifier1) then -- menuModifier1: remove all refs except the one clicked
          for j = 1, #mspaces do
            if j == i then
              winMSpaces[posWin].mspace[j] = true
            else
              winMSpaces[posWin].mspace[j] = false
            end
          end
        elseif self:modifiersEqual(self:getModifiersMods(mods), menuModifier2) then -- menuModifier2: put refs on all mSpaces
          for j = 1, #mspaces do
            winMSpaces[posWin].mspace[j] = true
          end
        else  -- toggle (true and false on current mSpace)
          winMSpaces[posWin].mspace[i] = not winMSpaces[posWin].mspace[i]
        end
        --self:goToSpace(currentMSpace) -- refresh screen
        self:refreshWinTables()
      end,
    })
  end
  return winMenu
end


-- move windows from current mSpace to another one: no modifier: stay; menuModifier1: keep reference on current mSpace; menuModifier2: references on all mSpaces; menuModifier3 to tag along
function EnhancedSpaces:createSendWindowMenu()
  moveWindowMenu = {}
  for i = 1, #windowsOnCurrentMS do
    if windowsOnCurrentMS[i] ~= nil then
      table.insert(moveWindowMenu, {
        --title = windowsOnCurrentMS[i]:application():name(),
        title = winMSpaces[self:getPosWinMSpaces(windowsOnCurrentMS[i])].appName,
        menu = self:createSendWindowMenuItems(windowsOnCurrentMS[i]),
      })
    end
  end
  return moveWindowMenu
end
function EnhancedSpaces:createSendWindowMenuItems(w)
  moveWindowMenuItems = {}
  for i = 1, #mspaces do
    if winMSpaces[self:getPosWinMSpaces(w)].mspace[i] then
      table.insert(moveWindowMenuItems, { 
        title = mspaces[i], 
        checked = true, 
        disabled = true,
      })
    else
      table.insert(moveWindowMenuItems, { 
        title = mspaces[i],
        checked = winMSpaces[self:getPosWinMSpaces(w)].mspace[i],
        fn = function(mods)
          if self:modifiersEqual(self:getModifiersMods(mods), menuModifier3) then -- menuModifier3: move to new mSpace alongside with window
            winMSpaces[self:getPosWinMSpaces(w)].mspace[currentMSpace] = false
            winMSpaces[self:getPosWinMSpaces(w)].mspace[i] = true
            winMSpaces[self:getPosWinMSpaces(w)].frame[i] = winMSpaces[self:getPosWinMSpaces(w)].frame[currentMSpace]
            self:goToSpace(i)
          elseif self:modifiersEqual(self:getModifiersMods(mods), menuModifier1) then -- menuModifier1: keep reference on current mSpace
            winMSpaces[self:getPosWinMSpaces(w)].mspace[i] = true
          elseif self:modifiersEqual(self:getModifiersMods(mods), menuModifier2) then -- menuModifier2: references on all mSpaces
            for j = 1, #mspaces do -- currentMSpace could be skipped, but it's faster this way
              winMSpaces[self:getPosWinMSpaces(w)].mspace[j] = true
              winMSpaces[self:getPosWinMSpaces(w)].frame[j] = winMSpaces[self:getPosWinMSpaces(w)].frame[currentMSpace]
            end
          else -- no modifier: stay on screen
            winMSpaces[self:getPosWinMSpaces(w)].mspace[currentMSpace] = false
            winMSpaces[self:getPosWinMSpaces(w)].mspace[i] = true
            winMSpaces[self:getPosWinMSpaces(w)].frame[i] = winMSpaces[self:getPosWinMSpaces(w)].frame[currentMSpace]
          end
          --self:goToSpace(currentMSpace) --refresh
          self:refreshWinTables()
        end,
      })
    end
  end
  return moveWindowMenuItems
end


-- fetch window from another mSpace to current one -> with modifier add reference, without move
function EnhancedSpaces:createGetWindowMenu()
  getWindowMenu = {}
  if windowsNotOnCurrentMS ~= nil then
    for i = 1, #windowsNotOnCurrentMS do
      table.insert(getWindowMenu, { 
        --title = windowsNotOnCurrentMS[i]:application():name(),
        title = winMSpaces[self:getPosWinMSpaces(windowsNotOnCurrentMS[i])].appName,
        fn = function(mods) 
          local w = winMSpaces[self:getPosWinMSpaces(windowsNotOnCurrentMS[i])].win
          local indexTrue -- get index of mSpace where window is currently active to set frame accordingly
          for j = 1, #mspaces do 
            if winMSpaces[self:getPosWinMSpaces(windowsNotOnCurrentMS[i])].mspace[j] then
              indexTrue = j
              break
            end
          end
          for j = 1, #mspaces do -- copy frame from current mSpace where window is currently active to other mSpaces
            winMSpaces[self:getPosWinMSpaces(windowsNotOnCurrentMS[i])].frame[j] = winMSpaces[self:getPosWinMSpaces(windowsNotOnCurrentMS[i])].frame[indexTrue]
          end
          winMSpaces[self:getPosWinMSpaces(windowsNotOnCurrentMS[i])].mspace[currentMSpace] = true -- to be done in all cases
          if self:modifiersEqual(self:getModifiersMods(mods), menuModifier1) then -- menuModifier1: get reference of window
            -- add window to current mSpace
            -- nothing to be done ATM
          elseif self:modifiersEqual(self:getModifiersMods(mods), menuModifier2) then -- menuModifier2: put reference on all mSpaces
            -- put reference on all other mSpaces
            for j = 1, #mspaces do
              if j ~= currentMSpace then --and not winMSpaces[self:getPosWinMSpaces(windowsNotOnCurrentMS[i])].mspace[j] then
                winMSpaces[self:getPosWinMSpaces(windowsNotOnCurrentMS[i])].mspace[j] = true -- add window to other mSpaces          
              end
            end
          else -- no modifier: move window to current mSpace and delete reference on all other mSpaces
            for j = 1, #mspaces do
              if j ~= currentMSpace and winMSpaces[self:getPosWinMSpaces(windowsNotOnCurrentMS[i])].mspace[j] then
                winMSpaces[self:getPosWinMSpaces(windowsNotOnCurrentMS[i])].mspace[j] = false -- remove window from other mSpaces          
              end
            end
          end
          --self:goToSpace(currentMSpace) -- refresh windows
          self:refreshWinTables()
          w:focus()
        end,
      })
    end
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
      if deltaMH <= -resizeMargin and deltaMV <= resizeMargin and deltaMV > -resizeMargin then -- 9 o'clock
        local geomNew = hs.geometry.new(current.x + dx, current.y)--, current.w - dx, current.h)
        geomNew.x2 = bottomRight.x
        geomNew.y2 = bottomRight.y
        hs.window.focusedWindow():move(geomNew, nil, false, 0)
      elseif deltaMH <= -resizeMargin and deltaMV <= -resizeMargin then -- 10:30
        local geomNew = hs.geometry.new(current.x + dx, current.y + dy)--, current.w - dx, current.h - dy)
        geomNew.x2 = bottomRight.x
        geomNew.y2 = bottomRight.y
        hs.window.focusedWindow():move(geomNew, nil, false, 0)
      elseif deltaMH > -resizeMargin and deltaMH <= resizeMargin and deltaMV <= -resizeMargin then -- 12 o'clock
        local geomNew = hs.geometry.new(current.x, current.y + dy)--, current.w, current.h - dy)
        geomNew.x2 = bottomRight.x
        geomNew.y2 = bottomRight.y
        hs.window.focusedWindow():move(geomNew, nil, false, 0)
      elseif deltaMH > resizeMargin and deltaMV <= -resizeMargin then -- 1:30
        local geomNew = hs.geometry.new(current.x, current.y + dy, current.w + dx, current.h - dy)
        geomNew.y2 = bottomRight.y
        hs.window.focusedWindow():move(geomNew, nil, false, 0)
      elseif deltaMH > resizeMargin and deltaMV > -resizeMargin and deltaMV <= resizeMargin then -- 3 o'clock
        hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y, current.w + dx, current.h), nil, false, 0)
      elseif deltaMH > resizeMargin and deltaMV > resizeMargin then -- 4:30
        hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y, current.w + dx, current.h + dy), nil, false, 0)
      elseif deltaMV > resizeMargin and deltaMH <= resizeMargin and deltaMH > -resizeMargin then -- 6 o'clock
        hs.window.focusedWindow():move(hs.geometry.new(current.x, current.y, current.w, current.h + dy), nil, false, 0)
      elseif deltaMH <= -resizeMargin and deltaMV > resizeMargin then -- 7:30
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
    flags = self:eventToArray(event:getFlags())
    eventType = event:getType()
    -- enable active modifiers (modifier1, modifier2, modifierMS)
    isMoving = false
    isResizing = false
    if eventType == self.moveStartMouseEvent then
      if self:modifiersEqual(flags, modifier1) then
        isMoving = true
      elseif modifier2 ~= nil and self:modifiersEqual(flags, modifier2) then
        isMoving = true
      elseif modifierMS ~= nil and self:modifiersEqual(flags, modifierMS) then
        isMoving = true
      end
    elseif eventType == self.resizeStartMouseEvent then
      if self:modifiersEqual(flags, modifier1) then
        isResizing = true
      elseif modifier2 ~= nil and self:modifiersEqual(flags, modifier2) then
        isResizing = true
      elseif modifierMS ~= nil and self:modifiersEqual(flags, modifierMS) then
        isResizing = true
      end
    end

    -- in case menu is open, handleClick() needs to be stopped (it still reacts on mouse button release, which is fine)
    if hs.window.focusedWindow() == nil or hs.window.focusedWindow():application():name() == 'Hammerspoon' then
    --if hs.window.focusedWindow() == nil or winMSpaces[self:getPosWinMSpaces(hs.window.focusedWindow())].appName == 'Hammerspoon' then
      isResizing = false
      isMoving = false
    end

    if isMoving or isResizing then
      local currentWindow = self:getWindowUnderMouse()
      if #self.disabledApps >= 1 then
        if self.disabledApps[currentWindow:application():name()] then
          return nil
        end
      end

      -- prevent error when clicking on screen (and not window) with pressed modifier(s)
      if type(self:getWindowUnderMouse()) == "nil" then
        self.cancelHandler:start()
        self.dragHandler:stop()
        self.clickHandler:stop()
        -- Prevent selection
        return true
      end

      local win = self:getWindowUnderMouse():focus()
      local frame = win:frame()
      max = win:screen():frame()
      --maxFF = win:screen():fullFrame()
      --heightMB = maxFF.h - max.h -- height menu bar
      local xNew = frame.x
      local yNew = frame.y
      local wNew = frame.w
      local hNew = frame.h

      local mousePos = hs.mouse.absolutePosition()
      local mx = wNew + xNew - mousePos.x -- distance between right border of window and cursor
      local dmah = wNew / 2 - mx -- absolute delta: mid window - cursor
      deltaMH = dmah * 100 / wNew -- delta from mid window: -50(left border of window) to 50 (left border)

      local my = hNew + yNew - mousePos.y
      local dmav = hNew / 2 - my
      deltaMV = dmav * 100 / hNew -- delta from mid window in %: from -50(=top border of window) to 50 (bottom border)

      -- show canvases for visually supporting automatic window positioning and resizing
      local thickness = gridIndicator[1] -- thickness of bar
      cv = {} -- canvases need to be reset
      if eventType == self.moveStartMouseEvent and self:modifiersEqual(flags, modifier1) then
        self:createCanvas(1, 0, max.h / 3, thickness, max.h / 3)
        self:createCanvas(2, max.w / 3, heightMB + max.h - thickness, max.w / 3, thickness)
        self:createCanvas(3, max.w - thickness, max.h / 3, thickness, max.h / 3)
      elseif eventType == self.moveStartMouseEvent and (self:modifiersEqual(flags, modifier2)) then -- or self:modifiersEqual(flags, modifier1_2)) then
        self:createCanvas(1, 0, max.h / 5, thickness, max.h / 5)
        self:createCanvas(2, 0, max.h / 5 * 3, thickness, max.h / 5)
        self:createCanvas(3, max.w / 5, heightMB + max.h - thickness, max.w / 5, thickness)
        self:createCanvas(4, max.w / 5 * 3, heightMB + max.h - thickness, max.w / 5, thickness)
        self:createCanvas(5, max.w - thickness, max.h / 5, thickness, max.h / 5)
        self:createCanvas(6, max.w - thickness, max.h / 5 * 3, thickness, max.h / 5)
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
  local modifierDM = self:eventToArray(hs.eventtap.checkKeyboardModifiers()) -- modifiers (still) pressed after releasing mouse button 
  local frame = hs.window.focusedWindow():frame()
  local xNew = frame.x
  local yNew = frame.y
  local wNew = frame.w
  local hNew = frame.h
  if not moveLeftMS and not moveRightMS then -- if moved to other workspace, no resizing/repositioning wanted/necessary
    if movedNotResized then
      -- window moved past left screen border
      if self:modifiersEqual(flags, modifier1) then
        gridX = 2
        gridY = 2
      elseif self:modifiersEqual(flags, modifier2) then --or self:modifiersEqual(flags, modifier1_2) then
        gridX = 3
        gridY = 3
      end

      if self:modifiersEqual(flags, modifier1) and self:modifiersEqual(flags, modifierDM) then
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
                hs.window.focusedWindow():move(self:snap('a1'), nil, false, 0)
              elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
                hs.window.focusedWindow():move(self:snap('a3'), nil, false, 0)
              else -- bottom third
                hs.window.focusedWindow():move(self:snap('a4'), nil, false, 0)
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
                hs.window.focusedWindow():move(self:snap('a2'), nil, false, 0)
              elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
                hs.window.focusedWindow():move(self:snap('a5'), nil, false, 0)
              else -- bottom third
                hs.window.focusedWindow():move(self:snap('a6'), nil, false, 0)
              end
            end
          end
        -- moved window below bottom of screen 2x2
        elseif frame.y + hNew > maxFF.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
          if max.h - frame.y > math.abs(max.h - frame.y - hNew) * 9 then -- and flags:containExactly(modifier1) then -- move window as is back within boundaries
            yNew = maxFF.h - hNew - pM
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            for i = 1, gridX, 1 do
              if hs.mouse.getRelativePosition().x + sumdx > max.w / 3 and hs.mouse.getRelativePosition().x + sumdx < max.w * 2 / 3 then -- middle
                hs.window.focusedWindow():move(self:snap('a7'), nil, false, 0)
                break
              elseif hs.mouse.getRelativePosition().x + sumdx <= max.w / 3 then -- left
                hs.window.focusedWindow():move(self:snap('a1'), nil, false, 0)
                break
              else -- right
                hs.window.focusedWindow():move(self:snap('a2'), nil, false, 0)
                break
              end
            end
          end
        end
      elseif self:modifiersEqual(flags, modifier1) and #modifierDM == 0 then -- modifier key released before left mouse button
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
                hs.window.focusedWindow():move(self:snap('a2'), nil, false, 0)
              elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
                hs.window.focusedWindow():move(self:snap('a5'), nil, false, 0)
              else -- bottom third
                hs.window.focusedWindow():move(self:snap('a6'), nil, false, 0)
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
                hs.window.focusedWindow():move(self:snap('a1'), nil, false, 0)
              elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
                hs.window.focusedWindow():move(self:snap('a3'), nil, false, 0)
              else -- bottom third
                hs.window.focusedWindow():move(self:snap('a4'), nil, false, 0)
              end
            end
          end
        elseif frame.y + hNew > maxFF.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then -- bottom border
          hs.window.focusedWindow():minimize()                
        end
      -- 3x3
      elseif self:modifiersEqual(flags, modifier2) and self:modifiersEqual(flags, modifierDM) then --todo: ?not necessary? -> and eventType == self.moveStartMouseEvent
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
                    hs.window.focusedWindow():move(self:snap('a4'), nil, false, 0)
                  elseif i == 2 then
                    hs.window.focusedWindow():move(self:snap('b5'), nil, false, 0)
                  elseif i == 3 then
                    hs.window.focusedWindow():move(self:snap('b6'), nil, false, 0)
                  end
                  break
                end
              end
            -- first (upper) double area -> c3
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              hs.window.focusedWindow():move(self:snap('c3'), nil, false, 0)
            else -- second (lower) double area -> c4
              hs.window.focusedWindow():move(self:snap('c4'), nil, false, 0)
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
                    hs.window.focusedWindow():move(self:snap('b10'), nil, false, 0)
                  elseif i == 2 then
                    hs.window.focusedWindow():move(self:snap('b11'), nil, false, 0)
                  elseif i == 3 then
                    hs.window.focusedWindow():move(self:snap('b12'), nil, false, 0)
                  end
                  break
                end
              end
            -- first (upper) double area -> c7
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              hs.window.focusedWindow():move(self:snap('c7'), nil, false, 0)
            else -- second (lower) double area -> c8
              hs.window.focusedWindow():move(self:snap('c8'), nil, false, 0)
            end
          end
        -- moved window below bottom of screen 3x3
        elseif frame.y + hNew > maxFF.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
          if max.h - frame.y > math.abs(max.h - frame.y - hNew) * 9 then -- and flags:containExactly(modifier1) then -- move window as is back within boundaries
            yNew = maxFF.h - hNew - pM
            targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
          elseif eventType == self.moveStartMouseEvent then -- automatically resize and position window within grid, but only with left mouse button
            if (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 2 and hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 3) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 4) then
              -- releasing modifier before mouse button; 3 standard areas
              for i = 1, gridX, 1 do
                if hs.mouse.getRelativePosition().x + sumdx < max.w - (gridX - i) * max.w / gridX then 
                  if i == 1 then
                    hs.window.focusedWindow():move(self:snap('b1'), nil, false, 0)
                  elseif i == 2 then
                    hs.window.focusedWindow():move(self:snap('b2'), nil, false, 0)
                  elseif i == 3 then
                    hs.window.focusedWindow():move(self:snap('b3'), nil, false, 0)
                  end
                  break
                end
              end
            -- first (left) double width -> c1
            elseif (hs.mouse.getRelativePosition().x + sumdx > max.w / 5) and (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 2) then
              hs.window.focusedWindow():move(self:snap('c1'), nil, false, 0)
            else -- second (right) double width -> c2
              hs.window.focusedWindow():move(self:snap('c2'), nil, false, 0)
            end
          end
        end
      -- if dragged beyond left/right screen border, window snaps to middle column
      --elseif self:modifiersEqual(flags, modifier1_2) then --todo: ?not necessary? -> and eventType == self.moveStartMouseEvent
      elseif self:modifiersEqual(flags, modifier2) and #modifierDM == 0 then --todo: ?not necessary? -> and eventType == self.moveStartMouseEvent
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
                    hs.window.focusedWindow():move(self:snap('b7'), nil, false, 0)
                  elseif i == 2 then
                    hs.window.focusedWindow():move(self:snap('b8'), nil, false, 0)
                  elseif i == 3 then
                    hs.window.focusedWindow():move(self:snap('b9'), nil, false, 0)
                  end
                end
              end
            -- first (upper) double area -> c5
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              hs.window.focusedWindow():move(self:snap('c5'), nil, false, 0)
            else -- second (lower) double area -> c6
              hs.window.focusedWindow():move(self:snap('c6'), nil, false, 0)
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
                    hs.window.focusedWindow():move(self:snap('b7'), nil, false, 0)
                  elseif i == 2 then
                    hs.window.focusedWindow():move(self:snap('b8'), nil, false, 0)
                  elseif i == 3 then
                    hs.window.focusedWindow():move(self:snap('b9'), nil, false, 0)
                  end
                  break
                end
              end
            -- first (upper) double area -> c5
            elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
              hs.window.focusedWindow():move(self:snap('c5'), nil, false, 0)
            else -- second (lower) double area -> c6
              hs.window.focusedWindow():move(self:snap('c6'), nil, false, 0)
            end
          end
        -- moved window below bottom of screen 3x3, modifier released
        elseif frame.y + hNew > maxFF.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
          if max.h - frame.y > math.abs(max.h - frame.y - hNew) * 9 then -- and flags:containExactly(modifier1) then -- move window as is back within boundaries
            yNew = maxFF.h - hNew - pM
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
              --self:snap('c1')
            else -- second (right) double width -> c2
              hs.window.focusedWindow():minimize()
              --self:snap('c2')
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
     self:moveToSpace(self:getprevMSpaceNumber(currentMSpace), currentMSpace, false)
      hs.timer.doAfter(0.1, function()
        --self:goToSpace(currentMSpace) -- refresh screen (otherwise window still visible in former mspace)
        self:refreshWinTables()
      end)
      if self:modifiersEqual(modifierDM, flags) then -- if modifier is still pressed, switch to where window has been moved  
        hs.timer.doAfter(0.02, function()
          currentMSpace = self:getprevMSpaceNumber(currentMSpace)
          self:goToSpace(currentMSpace)
        end)
      end
    elseif moveRightMS then
      self:moveToSpace(self:getnextMSpaceNumber(currentMSpace), currentMSpace, false)
      hs.timer.doAfter(0.1, function()
        --self:goToSpace(currentMSpace) -- refresh screen (otherwise window still visible in former mspace)
        self:refreshWinTables()
      end)
      if self:modifiersEqual(modifierDM, flags) then
        hs.timer.doAfter(0.02, function()
          currentMSpace = self:getnextMSpaceNumber(currentMSpace)
          self:goToSpace(currentMSpace)
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
function EnhancedSpaces:createCanvas(n, x, y, w, h)
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
function EnhancedSpaces:eventToArray(a) -- maybe extend to work with more than one modifier at at time
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


function EnhancedSpaces:modifiersEqual(a, b)
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


function EnhancedSpaces:mergeModifiers(m1, m2)
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


function EnhancedSpaces:isIncludedWinAll(w) -- check whether window id is included in table
  for i,v in pairs(winAll) do
    if w:id() == winAll[i]:id() then
      return true
    end
  end
  return false
end


function EnhancedSpaces:copyTable(a)
  local b = {}
  for i,v in pairs(a) do
    b[i] = v
  end
  return b
end


function EnhancedSpaces:indexOf(array, value)
  if array == nil then return nil end
  for i, v in ipairs(array) do
      if v == value then
          return i
      end
  end
  return nil
end


function EnhancedSpaces:getprevMSpaceNumber(cS)
  if cS == 1 then return #mspaces end
  return cS - 1
end
function EnhancedSpaces:getnextMSpaceNumber(cS)
  if cS == #mspaces then return 1 end
  return cS + 1
end


function EnhancedSpaces:goToSpace(target)
  --[[ -- now done in self:refreshWinTables()
  max = hs.screen.mainScreen():frame()
  maxFF = hs.screen.mainScreen():fullFrame()
  heightMB = maxFF.h - max.h   -- height menu bar
  for i,v in pairs(winMSpaces) do
    if winMSpaces[i].mspace[target] == true then
      --winMSpaces[i].win:setFrame(winMSpaces[i].frame[target]) -- 'unhide' window
      winMSpaces[i].win:move(winMSpaces[i].frame[target]) -- 'unhide' window
    else
      winMSpaces[i].win:setTopLeft(hs.geometry.point(max.w - 1, max.h))
      --winMSpaces[i].win:move(hs.geometry.point(max.w - 1, max.h, winMSpaces[i].win:frame().x, winMSpaces[i].win:frame().y)) 
    end
  end
  --]]
  currentMSpace = target
   mSpaceCyclePos = currentMSpace
  menubar:setTitle(mspaces[target])
  --hs.spoons.resourcePath
  --adjust wallpaper
  ---[[
  if customWallpaper then
    if hs.fs.displayName(hs.configdir .. '/Spoons/EnhancedSpaces.spoon/wallpapers/' .. mspaces[currentMSpace] .. '.jpg') then
      hs.screen.mainScreen():desktopImageURL('file://' .. hs.configdir .. '/Spoons/EnhancedSpaces.spoon/wallpapers/' .. mspaces[currentMSpace] .. '.jpg')
    else
      hs.screen.mainScreen():desktopImageURL('file://' .. hs.configdir .. '/Spoons/EnhancedSpaces.spoon/wallpapers/default.jpg')
    end
  end
  --]]
  --[[
  if customWallpaper then
    if hs.fs.displayName(hs.spoons.resourcePath('wallpapers/' .. mspaces[currentMSpace] .. '.jpg')) then
      hs.screen.mainScreen():desktopImageURL('file://' .. hs.spoons.resourcePath('wallpapers/' .. mspaces[currentMSpace] .. '.jpg'))
    else
      hs.screen.mainScreen():desktopImageURL('file://' .. hs.spoons.resourcePath('wallpapers/default.jpg'))
    end
  end
  --]]

  self:refreshWinTables()

  if #windowsOnCurrentMS > 0 then
    windowsOnCurrentMS[1]:focus() -- activate last used window on new mSpace
  end
end


function EnhancedSpaces:moveToSpace(target, origin, boolKeyboard)
  local fwin = hs.window.focusedWindow()
  max = fwin:screen():frame()
  fwin:setTopLeft(hs.geometry.point(max.w - 1, max.h))
  winMSpaces[self:getPosWinMSpaces(fwin)].mspace[target] = true
  winMSpaces[self:getPosWinMSpaces(fwin)].mspace[origin] = false
  -- keep position when moved by keyboard shortcut, otherwise move to middle of screen
  if boolKeyboard then
    winMSpaces[self:getPosWinMSpaces(fwin)].frame[target] = winMSpaces[self:getPosWinMSpaces(fwin)].frame[origin]
  else  --point/rect
    winMSpaces[self:getPosWinMSpaces(fwin)].frame[target] = hs.geometry.rect(
      max.w / 2 - fwin:frame().w / 2, 
      max.h / 2 - fwin:frame().h / 2, 
      fwin:frame().w, fwin:frame().h
    ) -- put window in middle of screen            
  end
  -- move snapshot
  winMSpaces[self:getPosWinMSpaces(fwin)].snapshot[target] = winMSpaces[self:getPosWinMSpaces(fwin)].snapshot[origin]
  winMSpaces[self:getPosWinMSpaces(fwin)].snapshot[origin] = nil

  self:refreshWinTables()
end


function EnhancedSpaces:refreshSnapshots(msp)
  for i = 1, #winMSpaces do
    if winMSpaces[i].mspace[msp] then
      winMSpaces[i].snapshot[msp] = winMSpaces[i].win:snapshot() --:setSize({w =  winMSpaces[i].win:size().w / 2, h =  winMSpaces[i].win:size().h / 2})
    end
  end
end


function EnhancedSpaces:refreshWinTables()
  ---[[
  winAll = filter_all:getWindows() --hs.window.sortByFocused)
  -- remove minimized/closed windows
  for i = 1, #winMSpaces do
    if not self:isIncludedWinAll(winMSpaces[i].win) then
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
        break
      end
    end
    if not there then
      table.insert(winMSpaces, {})
      winMSpaces[#winMSpaces].win = winAll[i]
      winMSpaces[#winMSpaces].appName = winAll[i]:application():name()
      winMSpaces[#winMSpaces].snapshot = {}
      winMSpaces[#winMSpaces].mspace = {}
      winMSpaces[#winMSpaces].frame = {}
      for k = 1, #mspaces do
        winMSpaces[#winMSpaces].frame[k] = winAll[i]:frame()
        if k == currentMSpace then
          winMSpaces[#winMSpaces].mspace[k] = true
          winMSpaces[#winMSpaces].snapshot[k] = winAll[i]:snapshot():setSize({w =  winAll[i]:size().w / 2, h =  winAll[i]:size().h / 2})
        else
          winMSpaces[#winMSpaces].mspace[k] = false
        end
      end
    end
  end

  
  -- sort winMSpaces the same way as winAll, i.e., last focused first
  for i = 1, #winAll do
    for j = 1, #winMSpaces do
      local k = self:getPosWinMSpaces(winAll[i])
      if winMSpaces[k] ~= i then
        table.insert(winMSpaces, i, winMSpaces[k])
        table.remove(winMSpaces, k + 1)
        break
      end
    end
  end

  -- refresh window-tables for windows on current mSpace/other mSpaces
  windowsOnCurrentMS = {}
  _windowsOnCurrentMS = {} -- without active window for 'swap-switcher'
  windowsNotOnCurrentMS = {}
  for i = 1, #winAll do
    if winMSpaces[self:getPosWinMSpaces(winAll[i])].mspace[currentMSpace] then
      table.insert(windowsOnCurrentMS, winAll[i])
      if hs.window.focusedWindow() ~= nil then
        if winAll[i]:id() ~= hs.window.focusedWindow():id() then
          table.insert(_windowsOnCurrentMS, winAll[i]) -- windows of current mSpace except the active one
        end
      end
    else
      table.insert(windowsNotOnCurrentMS, winAll[i])
    end
  end
  table.insert(_windowsOnCurrentMS, 1, _windowsOnCurrentMS[#_windowsOnCurrentMS])
  table.remove(_windowsOnCurrentMS, #_windowsOnCurrentMS)

  refreshMSpaces()
  EnhancedSpaces:refreshMenu()
--]]
end

function refreshMSpaces()
  max = hs.screen.mainScreen():frame()
  for i,v in pairs(winMSpaces) do
    if winMSpaces[i].mspace[currentMSpace] == true then
      --winMSpaces[i].win:setFrame(winMSpaces[i].frame[target]) -- 'unhide' window
      winMSpaces[i].win:move(winMSpaces[i].frame[currentMSpace]) -- 'unhide' window
    else
      winMSpaces[i].win:setTopLeft(hs.geometry.point(max.w - 1, max.h - 1))
      --winMSpaces[i].win:move(hs.geometry.point(max.w - 1, max.h, winMSpaces[i].win:frame().x, winMSpaces[i].win:frame().y)) 
    end
  end
end


-- when standard window switchers such as AltTab or macOS' cmd-tab are used, self:cmdTabFocus() switches to correct mSpace
function EnhancedSpaces:cmdTabFocus(w)
  -- when choosing to switch to window by cycling through all apps, go to mSpace of chosen window
  if w ~= nil and winMSpaces[self:getPosWinMSpaces(w)] ~= nil then
    if not winMSpaces[self:getPosWinMSpaces(w)].mspace[currentMSpace] then -- in case focused window is not on current mSpace, switch to the one containing it
      for i = 1, #mspaces do
        if winMSpaces[self:getPosWinMSpaces(w)].mspace[i] then
          self:goToSpace(i)
          break
        end
      end
    end
  end
end


-- triggered by hs.window.filter.windowMoved -> adjusts coordinates of moved window
function EnhancedSpaces:adjustWinFrame(w)
  -- subscribed filter for some reason takes a couple of seconds to trigger method -> alternative: hs.timer.doEvery()
  if w ~= nil then
    max = w:screen():frame()
    if w:topLeft().x < max.w - 2 then -- prevents subscriber-method to refresh coordinates of window that has just been 'hidden'
      if winMSpaces[self:getPosWinMSpaces(w)] ~= nil then
        winMSpaces[self:getPosWinMSpaces(w)].frame[currentMSpace] = w:frame()
      end
    end
  end
end


function EnhancedSpaces:getPosWinMSpaces(w)
  if w == nil or winMSpaces == nil then return nil end
  for i = 1, #winMSpaces do
    if w:id() == winMSpaces[i].win:id() then
      return i
    end
  end
  return nil
end


function EnhancedSpaces:refWinMSpace(target) -- add 'copy' of window on current mSpace to target mSpace
  local fwin = hs.window.focusedWindow()
  max = fwin:screen():frame()
  winMSpaces[self:getPosWinMSpaces(fwin)].mspace[target] = true
  -- copy frame from original mSpace
  winMSpaces[self:getPosWinMSpaces(fwin)].frame[target] = winMSpaces[self:getPosWinMSpaces(fwin)].frame[currentMSpace]
  --self:goToSpace(currentMSpace) -- refresh screen
  self:refreshWinTables()
end


function EnhancedSpaces:derefWinMSpace()
  local fwin = hs.window.focusedWindow()
  max = fwin:screen():frame()
  winMSpaces[self:getPosWinMSpaces(fwin)].mspace[currentMSpace] = false
  -- in case all 'mspace' are 'false', close window
  local all_false = true
  for i = 1, #winMSpaces[self:getPosWinMSpaces(fwin)].mspace do
    if winMSpaces[self:getPosWinMSpaces(fwin)].mspace[i] then
      all_false = false
    end
  end
  if all_false then
    fwin:minimize()
  end
  --self:goToSpace(currentMSpace) -- refresh screen
  self:refreshWinTables()
end


function EnhancedSpaces:assignMS(w, boolgotoSpace)
  if self:indexOpenAppMSpace(w) ~= nil then
    local i = self:indexOpenAppMSpace(w)
    for j = 1, #mspaces do
      if openAppMSpace[i][2] == mspaces[j] and self:getPosWinMSpaces(w) ~= nil  then
        winMSpaces[self:getPosWinMSpaces(w)].mspace[j] = true
        -- in case position is given and also outer and inner padding are given
        if openAppMSpace[i][3] ~= nil and openAppMSpace[i][4] ~= nil and openAppMSpace[i][5] ~= nil then
          --winMSpaces[self:getPosWinMSpaces(w)].frame[j] = self:snap(openAppMSpace[i][3], openAppMSpace[i][4], openAppMSpace[i][5])
          for k = 1, #mspaces do
            winMSpaces[self:getPosWinMSpaces(w)].frame[k] = self:snap(openAppMSpace[i][3], openAppMSpace[i][4], openAppMSpace[i][5])
          end
        -- in case position is given without outer/inner padding
        elseif openAppMSpace[i][3] ~= nil then
          --winMSpaces[self:getPosWinMSpaces(w)].frame[j] = self:snap(openAppMSpace[i][3])
          for k = 1, #mspaces do
            winMSpaces[self:getPosWinMSpaces(w)].frame[k] = self:snap(openAppMSpace[i][3])
          end
        -- app given without additional parameters
        else --point/rect
          --winMSpaces[self:getPosWinMSpaces(w)].frame[self:indexOf(mspaces, openAppMSpace[i][2])] = hs.geometry.rect(max.w / 2 - w:frame().w / 2, max.h / 2 - w:frame().h / 2, w:frame().w, w:frame().h) -- put window in middle of screen
          for k = 1, #mspaces do
            winMSpaces[self:getPosWinMSpaces(w)].frame[k] = hs.geometry.rect(max.w / 2 - w:frame().w / 2, max.h / 2 - w:frame().h / 2, w:frame().w, w:frame().h) -- put window in middle of screen
          end
        end
        if boolgotoSpace then -- not when EnhancedSpaces is started
          self:goToSpace(self:indexOf(mspaces, openAppMSpace[i][2]))
        end
      elseif self:getPosWinMSpaces(w) ~= nil then
        winMSpaces[self:getPosWinMSpaces(w)].mspace[j] = false
      end
    end
  end
end


function EnhancedSpaces:indexOpenAppMSpace(w)
  if openAppMSpace == nil then return nil end
  for i = 1, #openAppMSpace do
    if w:application():name():gsub('%W', '') == openAppMSpace[i][1]:gsub('%W', '') then
      return i
    end
  end
  return nil
end


function EnhancedSpaces:contextMenuTelegram() -- return 'true' if there are more than one Telegram windows (they are context menus that should not trigger windowOnScreen and consequently self:assignMS(), which places context menu wrongly)
  self:refreshWinTables()
  k = 0
  for i = 1, #winAll do
    --if winAll[i]:application():name() == 'Telegram' then
    if winMSpaces[self:getPosWinMSpaces(winAll[i])].appName == 'Telegram' then
      k = k + 1
      if k > 1 then return true end
    end
  end
  return false
end


-- in case a window has previously been minimized by dragging beyond bottom screen border (or for another reason extends beyond bottom screen border), it will be moved to middle of screen
function EnhancedSpaces:moveMiddleAfterMouseMinimized(w)
  if w:frame().y + w:frame().h > max.h + heightMB then
    w:setFrame(hs.geometry.point(max.w / 2 - w:frame().w / 2, max.h / 2 - w:frame().h / 2, w:frame().w, w:frame().h))
    winMSpaces[self:getPosWinMSpaces(w)].frame[currentMSpace] = hs.geometry.rect(max.w / 2 - w:frame().w / 2,
      max.h / 2 - w:frame().h / 2, w:frame().w, w:frame().h)
  end
end


-- determine hs.geometry object for grid positons
function EnhancedSpaces:snap(scenario, pMl, pIl)
  local pMOrg = pM
  local pIOrg = pI
  if pMl ~= nil and pIl ~= nil then
    pM = pMl
    pI = pIl
  end
  --maxFF = hs.window.focusedWindow():screen():fullFrame()
  max = hs.window.focusedWindow():screen():frame()
  --heightMB = maxFF.h - max.h   -- height menu bar
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
    wNew = max.w / 2 - pM - pI
    hNew = max.h / 2 - pM - pI
  elseif scenario == 'a4' then -- bottom left quarter of screen
    xNew = 0 + pM
    yNew = heightMB + max.h / 2 + pI
    wNew = max.w / 2 - pM - pI
    hNew = max.h / 2 - pM - pI
  elseif scenario == 'a5' then -- top right quarter of screen
    xNew = max.w / 2 + pI
    yNew = heightMB + pM
    wNew = max.w / 2 - pM - pI
    hNew = max.h / 2 - pM - pI
  elseif scenario == 'a6' then -- bottom right quarter of screen
    xNew = max.w / 2 + pI
    yNew = heightMB + max.h / 2 + pI
    wNew = max.w / 2 - pM - pI
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
  elseif scenario == 'b7' then -- middle top ninth of screen
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
  pM = pMOrg
  pI = pIOrg
  return hs.geometry.rect(xNew, yNew, wNew, hNew)
end


-- applecript: https://github.com/Hammerspoon/hammerspoon/discussions/3560
--hs.eventtap.keyStroke({'command', 'option'}, 'd') -- toggle autohide dock
function EnhancedSpaces:shellArg(x)
  return [[']] .. string.gsub(x, [[']], [['\'']]) .. [[']]
end
function EnhancedSpaces:applescript(x)
  return hs.execute('osascript -e ' .. self:shellArg(x))
end
setDockAutohideScript = [[
  tell application "System Events"
    tell dock preferences
      set autohide to %s
    end tell
  end tell
]]
-- https://stackoverflow.com/questions/14433602/hide-menu-bar-and-dock-globally-with-applescript
getDockAutohideScript = [[
  tell application "System Events"
    tell dock preferences
        set dockprops to get properties
        set dockhidestate to autohide of dockprops
        if autohide = true then
            return true
        else
            return false
        end if
    end tell
  end tell
]]
function EnhancedSpaces:getDockAutohide()
  local returnValue = tostring(self:applescript(getDockAutohideScript:format()))
  if returnValue:gsub('%W', '') == 'true' then
    return true
  else
    return false
  end
end
function EnhancedSpaces:setDockAutohide(autohide)
  self:applescript(setDockAutohideScript:format(autohide and 'true' or 'false'))
end
function EnhancedSpaces:toggleDockAutohide()
  self:applescript(setDockAutohideScript:format('not autohide'))
end


return EnhancedSpaces
