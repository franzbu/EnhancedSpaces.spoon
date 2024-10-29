# v0.9.15

* improved assigning positions and spaces for windows at start

# v0.9.14

* fixed recovering of windows at start of EnhancedSpaces

# v0.9.13

* improved smothnesss when leaving fullscreen mode

# v0.9.12

* filter subscriptions for 'windowFullscreened' and 'windowUnfullscreened' added -> fixed calling assignMS() after leaving a window's fullscreen mode

# v0.9.11

* As the name SpaceHammer had already been used, this tool has been renamed.

# v0.9.10

* Code cleanup, added 'moveLeftMS = false' and 'moveRightMS = false' to doMagic()

# v0.9.9

* using 'hs.geometry.x2' and 'hs.geometry.y2' for manual resizing of windows

# v0.9.8

* 'dofile' instead of 'require'

# v0.9.7

* cycling: windows are sorted last window focused first

# v0.9.6

* using slighty adjusted version of 'window_switcher.lua': own table with windows for cycling through is used (windowsOnCurrentMSpace)
*   
# v0.9.5

* using slighty adjusted version of 'window_filter.lua': 'local WINDOWMOVED_DELAY=0.01' instead of '0.5' to get rid of delay (instead of 'hs.timer.doEvery()')
  
# v0.9.4

* changed window position to middle of screen when unminimized after having been minimized my dragging beyond bottom screen border
  
# v0.9.3

* extended use of 'hs.timer.doEvery()' instead of filter subscription

# v0.9.2

* bug fixes
  
# v0.9.1

* added padding for manual resizing windows and moving up to 10 percent of windows past screen borders

  
# v0.9

* added option to work around time delay caused by filter subscription when moving windows ('init.lua': 'increaseResponsiveness = true, -- default: false')


  
# v0.8

* sensible focussing of windows


# v0.7.3

* snap: keep size of window and put in in center of screen ('a8')


# v0.7.2

* code cleanup

# v0.7.1

* code cleanup
  
# v0.7

* open windows on pre-defined mSpaces

# v0.6

* padding: gaps between windows and between windows and screen borders can be defined
  
# v0.5

* mSpaces: automatic backup/restore of mSpaces and windows (add 'backup = true' to 'init.lua') -> deprecated: use the option to open windows on pre-defined mSpaces instead

 # v0.4

* pre-release
  
