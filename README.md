# Mellon

Mellon is a Hammerspoon-based tool for managing windows and spaces. Due to limitations of Apple's implementation of spaces, Mellon incorporates a mended version of them, and they are further referred to as mspaces or MSpaces.

MSpaces are fast and powerful, fast in the senso of that switching between them is instantaneous, and powerful in the sense of the implementation of additional features such as a more flexible version of 'sticky windows'. 'Sticky window' denotes a window that is present on as many mspaces as you like. All 'sticky windows' are full-featured references, meaning they can have different sizes and positions on different mspaces.

Mellon has been developed with the goal of saving time when working on the Mac, and that starts with organizing windows and mspaces. Therefore, windows and mspaces can be organized using keyboard shortcuts. However, at times it can be a sensible alternative to use your pointer device (or devices, as some people use mosue and trackpad simultaneously), and that is why many of the tasks can be aided by your mouse or (Magic) trackpad.

Mellon is easiest explained on the go. Therefore, go ahead with the installation.


## Installation

Mellon has been built on top of Hammerspoon and consequently requires [Hammerspoon](https://www.hammerspoon.org/) to be installed and running.

To install Mellon, after downloading and unzipping, move the folder to ~/.hammerspoon/Spoons and make sure the name of the folder is 'Mellon.spoon'. 

Alternatively, run the following command on a terminal:

```lua

mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/franzbu/Mellon.spoon.git ~/.hammerspoon/Spoons/Mellon.spoon

```

## Usage

Once you've installed Mellon, add the following lines to your `~/.hammerspoon/init.lua` file:

```lua
local Mellon = hs.loadSpoon('Mellon')

Mellon:new({

  -- default MSpaces:
  MSpaces = { '1', '2', '3', 'E', 'T' }, -- default { '1', '2', '3' }
  startMSpace = 'E', -- default 2

  modifier1 = { 'alt' }, -- default: { 'alt' } -> for window management with mouse (also modifier2)
  modifier2 = { 'ctrl' }, -- default: { 'ctrl' }
   
  -- keyboard shortcuts (alongside modifier 1 + modifier2 -> adjustable) for moving windows to/switching mspaces
  prevMSpace = 'a',
  nextMSpace = 's',
  moveWindowPrevMSpace = 'd',
  moveWindowNextMSpace = 'f',
  moveWindowPrevMSpaceSwitch = 'q',
  moveWindowNextMSpaceSwitch = 'w',

})

```

Restart Hammerspoon and you are ready to go. You also might want to adjust 'MSpaces' and the default mspace after the start. 

In case you would like to change the default modifier keys (default modifier1) for pressing alongside prevMSpace, nextMSpace, and so on, you can add the following line with the desired modifier adjustments to 'init.lua':

```lua
  ...
  modifierSwitchMS = { 'shift', 'ctrl', 'alt', 'cmd' },
  ...
```

Now, by pressing 'modifierSwitchMS' and 'moveWindowPrevMSpaceSwitch', for instance, you move the active window on your mspace to the adjacent mspace to the left and switch there as well. For moving the window without switching or switching without moving press the proper keyboard shortcuts.

To create 'sticky windows', press the modifier1 and modifier2 keys simultaneously and additionally press the key corresponding to the mspace you would like to create a reference of the currently active window on, for instance, '3'. In case you would like to adjust the modifier keys, add the following line to your 'init.lua':


```lua
  ...
  modifierReference = { 'ctrl', 'shift' },
  ...
```

For switching between all windows on your current mspace, press 'modifier1' and 'tab'. For switching between references of windows ('sticky windows), press 'modifier1' and 'escape'. Also here the keys can be changed the following way:


```lua
  ...
  modifierSwitchWin = modifier1, -- default: modifier1
  -- keyboard shortcuts alongside 'modifierSwitchWin'
  switchCurrentMS = 'tab', -- default: 'tab' -> switch between windows of current mspace
  switchReferences = 'escape', -- default: 'escape' -> switch between references of same window, which by design are on different mspaces
  ...
```



More to follow.
