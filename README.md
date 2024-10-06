# Mellon

Mellon is a Hammerspoon-based tool for managing windows and spaces. Due to limitations of Apple's implementation of spaces, Mellon incorporates a mended and improved version of spaces; from now on they are referred to as MSpaces or, simply, mspaces.

MSpaces are fast and powerful: fast in the sense of that switching between them is instantaneous, and powerful in the sense of that the implementation of additional features such as 'sticky windows'. 'Sticky window' denotes a window that is present on as many mspaces as you like. All 'sticky windows' are full-featured references, meaning they can have different sizes and positions on different mspaces.

Mellon has been developed with the goal of saving time when working, and that starts with organizing windows and mspaces. Therefore, windows and mspaces can be handled using keyboard shortcuts. However, at times it can be a sensible approach to also use your pointer device, and that is why many of the tasks can be aided by your mouse or trackpad.

Mellon is easiest explained on the go. Therefore, simply go ahead with its installation.


## Installation

Mellon has been built on top of Hammerspoon and consequently requires [Hammerspoon](https://www.hammerspoon.org/) to be installed and running.

To install Mellon, after downloading and unzipping, move the folder to ~/.hammerspoon/Spoons and make sure the name of the folder is 'Mellon.spoon'. 

Alternatively, run the following command in a terminal window:

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

Restart Hammerspoon and you are ready to go. You also might want to adjust the amount and names of your 'MSpaces' and the default mspace. 

In case you would like to change the default modifier key(s) (default modifier1 = { 'alt' }) for pressing alongside prevMSpace, nextMSpace, and so on, you can add the following line with the desired modifier adjustments to 'init.lua':

```lua
  ...
  modifierSwitchMS = { 'shift', 'ctrl', 'alt', 'cmd' },
  ...
```
## MSpaces

Now, by pressing 'modifierSwitchMS' and 'moveWindowPrevMSpaceSwitch', for instance, you move the active window on your current mspace to the adjacent mspace on the left and switch there simultaneously. For moving the window without switching or switching without moving press the designated keyboard shortcuts.

To create 'sticky windows', press your 'ctrl' and 'shift' keys simultaneously and additionally press the key corresponding to the mspace you would like to create a reference of the currently active window on, for instance, '3'. In case you would like to adjust the modifier keys, add the following line to your 'init.lua':

```lua
  ...
  modifierReference = { 'alt', 'ctrl' },
  ...
```

For switching between all windows on your current mspace, press 'modifier1' and 'tab'. For switching between references of windows ('sticky windows), press 'modifier1' and 'escape'. Add the following lines to 'init.lua' in case you prefer different key combinations:

```lua
  ...
  modifierSwitchWin = modifier1, -- default: modifier1
  -- keyboard shortcuts alongside 'modifierSwitchWin'
  switchCurrentMS = 'tab', -- default: 'tab' -> switch between windows of current mspace
  switchReferences = 'escape', -- default: 'escape' -> switch between references of same window, which by design are on different mspaces
  ...
```

## A few further hints, more to follow:

Mellon can automatically resize your windows on your mspaces on a dynamically (according to your intentions, of course) changing grid size. You can use your mouse or trackpad by using your modifier keys and dragging your windows beyond certain areas of the borders of your screen. But first to manual moving and resizing:


### Manual Moving and Positioning

To move a window, hold your 'modifier1' or 'modifier2' key(s) down, position your cursor in any area within the window, click the left mouse button, and drag the window. If a window is dragged up to 10 percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the borders of the screen. If the window is dragged beyond the 10-percent-margin, things are getting interesting because then window management with automatic resizing and positioning comes into play.

### Automatic Resizing and Positioning 

For automatic resizing and positioning of a window, you simply have to move between 10 and 80 percent of the window beyond the left, right, or bottom (no upper limit here) borders of your screen using your left mouse button. 

As long as windows are resized - or moved within the borders of the screen -, it makes no difference whether you use your 'modifier1' or 'modifier2' keys. However, once a window is moved beyond the screen borders (10 - 80 percent of the window), different positioning and resizing scenarios are called into action; they are as follows:

* modifier1: 
  * If windows are moved beyond the left (right) borders of the screen: imagine your screen border divided into three equally long sections: if the cursor crosses the screen border in the middle third of the border, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower thirds, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: imagine your bottom screen border divided into three equally long sections: if the cursor crosses the screen border in the middle third of the bottom border, the window snaps into full screen. Crossing the screen border in the left or right thirds, the window snaps into the respective halfs of the screen.

* modifier2: 
  * The difference to 'modifier1' is that your screen has a 3x3 grid. This means that windows snap into the left third of the 3x3 grid when dragged beyond the left screen border and into the right third when dragged beyond the right screen border. If 'modifier2' is released before the left mouse button, the window will snap into the middle.
 
* The moment dragging of a window starts, indicators appear to guide the user as to where to drag the window for different window managing scenarios.

All this is been implemented with the goal of being as intuitive as possible; therefore, you shoud be able to build up your muscle memory quickly.

### Keyboard Shortcuts for Resizing and Positioning Wiondows

To resize and move the active window into a 2x2 grid position, use your 'modifier1' and number keys 1-7. In case you would like to use a different modifier key, add the following line to your 'init.lua':


```lua
  ...
  modifierSnap2 = { 'ctrl', 'shift' }, -- default: modifier1 
  ...
```

3x3 grid is coming.

