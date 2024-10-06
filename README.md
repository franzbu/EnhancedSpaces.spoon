# Mellon

Mellon is a Hammerspoon-based tool for managing windows and spaces. Due to limitations of Apple's 'Spaces', Mellon incorporates a mended and extended implementation; from now on they are referred to as MSpaces.

MSpaces are fast and powerful: fast in the sense that switching between them is instantaneous and moving windows between MSpaces is a matter of pressing a keyboard shortcut or a flick with your pointing device, and powerful in the sense that additional features such as 'sticky windows' have been implemented. 'Sticky window' denotes a window that is present on more than one MSpace, actually on as many MSpaces as you like. 'Sticky windows' are full-featured references, meaning they can have different sizes and positions on different MSpaces. More about this feature later.

Mellon has been developed with the goal of saving time, which is why organizing windows and MSpaces has been optimized to be the least time consuming and the most intuitive possible. Windows and MSpaces can be handled using your keyboard only; however, at times it can be simpler and/or faster if your keyboard and pointer device team up. It will therefore also be possible to do exactly that.

Mellon is easiest explained on the go, so simply get started with its installation.


## Installation

Mellon requires [Hammerspoon](https://www.hammerspoon.org/) to be installed and running.

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

  modifier1 = { 'alt' }, -- default: { 'alt' }
  modifier2 = { 'ctrl' }, -- default: { 'ctrl' }

})

```

Restart Hammerspoon and you are ready to go. You might additionally want to adjust the amount and names of your 'MSpaces' and the default mspace, see above. 


## MSpaces

MSpaces make your life or organizing spaces as you know them easier. The default setup uses 'modifier1' and the keys 'a', 's', 'd', 'f', 'q', and 'w' to switch to MSpace left/right ('a', 's'), move window to MSpace left/right ('d', 'f'), move window to MSpace left/right and switch there ('q', 'w'). 

Now, by pressing 'modifierSwitchMS' and 'q', for instance, you move the active window from your current MSpace to the adjacent MSpace on the left and switch there. For moving the window without switching or switching without moving use the designated keyboard shortcuts.

In case you would like to change the default modifier key and or some of the other keys that make up your keyboard shortcuts, you can add the following lines with the desired adjustments to 'init.lua':


```lua
  ...
  modifierSwitchMS = { 'shift', 'ctrl', 'alt', 'cmd' },
  -- 1, 2: switch to mspace left/right ('a', 's')
  -- 3, 4: move window to mspace left/right ('d', 'f')
  -- 5, 6: move window to mspace left/right and switch there ('q', 'w')
  modifierSwitchMSKeys = {'a', 's', 'd', 'f', 'q', 'w'}, 
  ...
```

## MSpaces Are More

However, this has just been the start. MSpaces will be more if you want them to be. 

See each MSpace as representations of your windows rather than just some space to place them on; for instance, you can have two MSpaces with the same windows on them, even in different sizes and positions. Or you can have the same Notes, Calendar, Finder or Safari window on two or more MSpaces, each representation behaving as if it was the one and only, while returning to the other representations you will notice all changes that have happend in the meantime there as well.
  
To create such representations of windows, press your 'ctrl' and 'shift' keys simultaneously and additionally press the key corresponding to the MSpace you would like to create a reference of the currently active window on, for instance, '3'. In case you would like to adjust the modifier keys, add the following line to your 'init.lua':

```lua
  ...
  modifierReference = { 'alt', 'ctrl' },
  ...
```

## Switching Between Windows

For switching between your windows you can use macOS's integrated window switcher (cmd-tab) or any third party switcher such as AltTab. Also for switching between the different windows of one application you can use Apple's integrated switcher or any third party alternative.

However, since MSpaces provide more features, further possibilities for switching are available.

### Switching between Apps on a Single MSpace

For switching between all windows on your current MSpace, press 'modifier1' and 'tab'. Add the following lines to 'init.lua' in case you prefer different key combinations:


```lua
  ...
  -- keyboard shortcuts for switching between windows on one mspace...
  -- ... and between references of one and the same window on different MSpaces
  modifierSwitchWin = { 'alt' }, -- default: modifier1
  modifierSwitchWinKeys = { 'tab', 'escape' }, -- default: { 'tab', 'escape' }
  ...
```

### Switching between References of Windows

For switching between the references of a window ('sticky windows), press 'modifier1' and 'escape'. In case you would like to change the keys, look directly above; change the second element in the table 'modifierSwitchWinKeys'.


## Moving and Resizing of Windows:

With Mellon you can automatically resize the windows on your MSpaces on a dynamically (according to your intentions, of course) changing grid size. You can use your mouse or trackpad and drag your windows beyond certain areas of the borders of your screen. Let us start with manual moving and resizing, though:


### Manual Moving and Positioning

To move a window, hold your 'modifier1' or 'modifier2' key(s) down, position your cursor in any area within the window, click the left mouse button, and drag the window. If a window is dragged up to 10 percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the borders of the screen. If the window is dragged beyond the 10-percent-margin, things are getting interesting because then window management with automatic resizing and positioning comes into play.

### Automatic Resizing and Positioning - Mouse and/or Trackpad

For automatic resizing and positioning of a window, you simply have to move between 10 and 80 percent of the window beyond the left, right, or bottom (no upper limit here) borders of your screen using your left mouse button. 

As long as windows are resized - or moved within the borders of the screen -, it makes no difference whether you use your 'modifier1' or 'modifier2' keys. However, once a window is moved beyond the screen borders (10 - 80 percent of the window), different positioning and resizing scenarios are called into action; they are as follows:

* modifier1: 
  * If windows are moved beyond the left (right) borders of the screen: imagine your screen border divided into three equally long sections: if the cursor crosses the screen border in the middle third of the border, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower thirds, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: imagine your bottom screen border divided into three equally long sections: if the cursor crosses the screen border in the middle third of the bottom border, the window snaps into full screen. Crossing the screen border in the left or right thirds, the window snaps into the respective halfs of the screen.

* modifier2: 
  * The difference to 'modifier1' is that your screen has a 3x3 grid. This means that windows snap into the left third of the 3x3 grid when dragged beyond the left screen border and into the right third when dragged beyond the right screen border. If 'modifier2' is released before the left mouse button, the window will snap into the middle.
 
* The moment dragging of a window starts, indicators appear to guide the user as to where to drag the window for different window managing scenarios.

All this is been implemented with the goal of being as intuitive as possible; therefore, you will be able to train your muscle memory in no time. Promise.


### Automatic Resizing and Positioning - Keyboard

#### 2x2 Grid

To resize and move the active window into a 2x2 grid position, use your 'modifier1' and number keys 1-7. In case you would like to use a different modifier key, add the following line to your 'init.lua':


```lua
  ...
  modifierSnap2 = { 'ctrl' }, -- default: modifier2
  modifierSnap2Keys = {'4', '5', '6', '7', '8', '9', '0'},
  ...
```

Adjust the keys to your liking; in the order of the entries in 'modifierSnap2Keys', windows are positioned as follows:
- 1: left half of screen (4)
- 2: right half of screen (5)
- 3: top left quarter of screen (6)
- 4: bottom left quarter of screen (7)
- 5: top right quarter of screen (8)
- 6: bottom right quarter of screen (9)
- 0: whole screen (0)

#### 3x3 Grid

Add the following lines to your 'init.lua' (in case this has not become clear yet: if you do not add these lines to your 'init.lua', the default options automatically take over):

```lua
  ...
  modifierSnap3 = { 'alt' }, -- default: modifier2
  modifierSnap3Keys = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'o', 'p'},
  ...
```

Windows are positioned as follows:
- 1: left third of screen (1)
- 2: middle third of screen (2)
- 3: right third of screen (3)
- 4: top left ninth of screen (4)
- 5: middle left night of screen (5)
- 6: bottom left ninth of screen (6)
- ...

##### 3x3 Grid - Double (and Quadruple) Sizes

With the following keyboard shortcuts, you can create windows that take up more cells on the 3x3 grid, which contains 9 cells altogether:

```lua
  ...
  modifierSnap3_2 = { 'ctrl', 'alt', 'shift' }, -- default: modifier1 + modifier2
  modifierSnap3_2Keys = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'o', 'p'},
  ...
```

Windows are positioned as follows (descriptions might prove tricky; in that case simply try it out):
- 1: left two thirds of screen: 3 cells (1)
- 2: right two thirds of screen: 3 cells (2)
- 3: left third, upper two cells (3)
- 4: left third, lower two cells (4)
- 5: middle third, upper two cells (5)
- 6: middle third, lower two cells (6)
- 7: right third, upper two cells (7)
- 8: right third, lower two cells (8)
- 9: top left and middle thirds: 4 cells (9)
- 10: bottom left and middle thirds: 4 cells (10)
- 11: top middle and right thirds: 4 cells (o)
- 12: bottom middle and right thirds: 4 cells (p)

Enjoy!
