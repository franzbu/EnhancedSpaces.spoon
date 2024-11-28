# v0.9.43

* mSpace Control: you can cycle through mSpaces both directions by pressing additionally `shift`

# v0.9.42

* mSpace Control : new feature - cycle through mSpaces

# v0.9.41

* mSpace Control: currently active mSpace can be [highlighted](https://github.com/franzbu/EnhancedSpaces.spoon#mspace-control).

# v0.9.40

* new feature: [mSpace Control](https://github.com/franzbu/EnhancedSpaces.spoon#mspace-control)

# v0.9.39

* fullscreen-related fixes and other bug fixes

# v0.9.38

* Windows that are pre-assigned mSpaces and positions (openAppMSpace) can now have different paddings, i.e. gaps, than the standard ones

# v0.9.37

* fixed issue that after force-closing a fullscreen window, newly opened windows would not open on pre-arranged mSpaces
* fixed error messages after force-closing windows

# v0.9.36

* keyboard shortcuts can be disabled
* in 'hammerspoonMenuItems', 'open' has been changed to 'config'

# v0.9.35.4

* corrected issue with switcher configuration (v0.9.35)

# v0.9.35.3

* added feature to change text for 'Hammerspoon' entry in main menu

# v0.9.35.2

* corrected typo

# v0.9.35.1

* fixed bug where windows weren't assigned correct mSpace when opened

# v0.9.35

* added possibilities to (1) [disable switching between the windows of your current mSpace](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#switching-between-windows) and (2) [disable swapping windows](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#swapping-windows)

* added possibility to [change appearance of switcher](https://github.com/franzbu/EnhancedSpaces.spoon#changing-appearance-of-switcher)
  
# v0.9.34

* Added the launcher Albert to the list of applications to be disregarded.
  
# v0.9.34

* Context menus of the application Telegram are correctly handled as dialogs rather than windows

* Added option to add application that are to be disregarded by EnhancedSpaces, e.g., launchers and clipboard managers - see [Windows To Be Disregarded by EnhancedSpaces](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#windows-to-be-disregarded-by-enhancedspaces)

# v0.9.33

* fullscreen-related bug fixed

# v0.9.32

* fixed error when force-closing apps

# v0.9.31.1

* fixed issue with incorrect focus when swapping Terminal windows. In case you're running a previous version of EnhancedSpaces, make sure to update 'lib/window_switcher.lua'

# v0.9.31

* in case you’re using a previous version of EnhancedSpaces, make sure to also update the folder ‘lib’ in `~/.hammerspoon/Spoons/EnhancedSpaces.spoon/`
  
* modified version of hs.window.switcher is used in order to remove delays at the start of EnhancedSpaces and to remove giving focus to selected window; switcher returns window instead for more flexibility
  
* modified version of hs.window.filter is used in order to fix delays, among others, at startup (https://github.com/Hammerspoon/hammerspoon/issues/3712)
  
* other fixes

# v0.9.30

* added possibility to change key for dereferencing windows (var 'deReferenceKey'); additional improvements

# v0.9.29

* additional features for swap menu via modifiers; other improvements

# v0.9.28

* swapping of windows enabled (see documentation); bug fixes

# v0.9.27.1

* bug fix: menu item 'Get Window' works as expected

# v0.9.27

* bug fixes
 
# v0.9.26

* bug fixes
  
# v0.9.25

* bug fixes
  
# v0.9.24

* added option for startup commands

# v0.9.23

* ironing out some bugs
   
# v0.9.22

* added optional popup menus

# v0.9.21

* disable send/get in menu in case in case there are no windows on current/other mSpace(s)

# v0.9.20

* added option for choosing custom wallpapers for each mSpace

# v0.9.19

* added option to include Hammerspoon's menu into EnhancedSpaces'

# v0.9.18

*added possibility for changing (language of) menu titles

# v0.9.17

* added menu

# v0.9.16

* bug fixes
  
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
  
