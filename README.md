# SpaceHammer

SpaceHammer has been inspired by a variety of tools, among them Aerospace, Moom and BetterTouchTool. SpaceHammer has simplified my life with my Mac; may it do the same for you.

To simplify one's life is not too bad, but what does this tool actually do to justify my spending time with it, you might ask. 

Well, first, spending your time with SpaceHammer will actually save you time. As far as the capabilities of this tool are concerned, the answer is simple: it helps you organize your workspace, which comes down to two main tasks: managing your spaces and your applications and windows on them. 

When it comes to spaces, SpaceHammer provides a new implementation of what Apple has straightforwardly termed 'Spaces'; in SpaceHammer they are called mSpaces.

mSpaces follow the approach of representing windows rather than containing them, which, for instance, makes it possible to have the same window on more than one mSpace. When it comes to managing windows, they are positioned and resized with keyboard shortcuts or a flick of your pointing device according to your demands.

Still, this is nothing really new, I hear you say, and you are right. You might be surprised, though, what difference sometimes even a slightly altered approach can make. But read on and judge for yourself.

One last thing before we dive in: windows and mSpaces can be handled using your keyboard only; however, similar to other operations, at times it is simpler and faster to use keyboard and pointing device together. Thus SpaceHammer provides this additional option wherever it is beneficial. 


## Installation

SpaceHammer requires [Hammerspoon](https://www.hammerspoon.org/), so just go ahead with its installation.

To install SpaceHammer, after downloading and unzipping it, move the folder to ~/.hammerspoon/Spoons and make sure the name of the folder is 'SpaceHammer.spoon'. 

Alternatively, run the following command in a terminal window:

```bash

mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/franzbu/SpaceHammer.spoon.git ~/.hammerspoon/Spoons/SpaceHammer.spoon

```

## Usage

Once you have installed SpaceHammer, add the following lines to your `~/.hammerspoon/init.lua` file:

```lua
local SpaceHammer = hs.loadSpoon('SpaceHammer')

SpaceHammer:new({
  -- mSpaces:
  mSpaces = { '1', '2', '3', 'E', 'T' }, -- default { '1', '2', '3' }
  startmSpace = 'E', -- default 2

  modifier1 = { 'alt' }, -- default: { 'alt' }
  modifier2 = { 'ctrl' }, -- default: { 'ctrl' }
})

```

Restart Hammerspoon and you are ready to go. You might be interested in adjusting the amount and names of your mSpaces and your default mSpace; to do so change the above entries. 

After starting SpaceHammer, all you will see for now is a new icon in your menu bar indicating your current mSpace. Let us find out now how to populate your mSpaces.

## mSpaces

The default setup uses 'ctrl' and the keys 'a', 's', 'd', 'f', 'q', and 'w' to switch to the mSpace to the left/right ('a', 's'), move a window to the mSpace to the left/right ('d', 'f'), move a window to the mSpace to the left/right while at the same time switching there ('q', 'w'). 

Now, by pressing 'ctrl' and 'q', for instance, you move the active window from your current mSpace to the adjacent mSpace on the left and at the same time switch there. 

The below lines represent the default setup, and you do not need to add them to your 'init.lua' unless you prefer different shortcuts:

```lua
  ...
  modifierMS = { 'ctrl' }, -- default: { 'ctrl' }
  -- 1, 2: switch to mSpace left/right ('a', 's')
  -- 3, 4: move window to mSpace left/right ('d', 'f')
  -- 5, 6: move window to mSpace left/right and switch there ('q', 'w')
  modifierMSKeys = {'a', 's', 'd', 'f', 'q', 'w'}, -- default: {'a', 's', 'd', 'f', 'q', 'w'}
  ...
```

### Switch Directly to Any mSpace

For switching directly to any mSpace, press 'alt' and the key for your mSpace.

As before, the line below represents the default setup, and you do not need to add it to your 'init.lua' unless you prefer a different shortcut:

```lua
  ...
  modifierMoveWinMSpace = { 'alt' }, -- default: { 'alt' }
  ...
```

### Move Windows Directly to Any mSpace

For moving windows to any mSpace, press 'alt-ctrl' and the key for the mSpace to which you want the active window to move.

As before, the below line represents the default setup, and you do not need to add it to your 'init.lua' unless you prefer a different shortcut:

```lua
  ...
  modifierSwitchMS = { 'alt', 'ctrl' }, -- default: { 'alt', 'ctrl' }
  ...
```


## mSpaces Carry Further Potential

By now we have covered the basics, but we have not walked over the finish line yet. That being said, this section is mainly for advanced users and can be skipped.

This section is about having 'copies' of windows on more than one mSpace. 

If you want to unlock the full potential of mSpaces, it is helpful to understand the underlying philosophy: See each mSpace as a representation of your windows rather than just an area where your windows can be placed - or, in other words, an mSpace can be understood as a set of 'symbolic links' to your actual windows. Due to this approach you could, for instance, have two mSpaces with the same windows in different sizes and positions, which could be sensible for specific workflows where it makes sense to be switching instantly between a bigger window of one and a smaller window of another application and vice versa. Or you can have the same Notes, Calendar, Finder or Safari window on two, three, or all of your mSpaces.
  
To create representations of windows, press the 'ctrl' and 'shift' modifiers simultaneously and additionally press the key corresponding to the mSpace you would like to create a reference of the currently active window on, for instance, '3'. 

As before, the below line represents the default setup, and you do not need to add it to your 'init.lua' unless you prefer a different shortcut:

```lua
  ...
  modifierReference = { 'ctrl', 'shift' }, -- default: { 'ctrl', 'shift' }
  ...
```

To delete a reference, press 'modifierReference' and '0'. In case you are 'de-referencing' the last representation of a window on your mSpaces, the window gets minimized.


## Switching Between Windows

You can use macOS's integrated window switcher (cmd-tab) or any third party switcher such as [AltTab]([[https://www.hammerspoon.org/](https://karabiner-elements.pqrs.org/](https://alt-tab-macos.netlify.app/))) for switching between all your windows. Also for switching between the different windows of one application you can use Apple's integrated switcher or any third party alternative.

However, to make use of the advanced features mSpaces provide, SpaceHammer offers additional possibilities for window-switching, namely (1) switching between the windows on the current mSpace and (2) switching between references of windows ('sticky windows').

### Switching between Windows of the Current mSpace

For switching between the windows of your current mSpace, press 'alt' and 'tab'. 

As before, the below lines represent the default setup, and you do not need to add them to your 'init.lua' unless you prefer different shortcuts:


```lua
  ...
  -- keyboard shortcuts for switching between windows on one mSpace...
  -- ... and between references of one and the same window on different mSpaces
  modifierSwitchWin = { 'alt' }, -- default: modifier1
  modifierSwitchWinKeys = { 'tab', 'escape' }, -- default: { 'tab', 'escape' }
  ...
```

### Switching between References of Windows

For switching between the references of a window ('sticky windows'), press 'alt' and 'escape'. In case you prefer a different key, change the second element in the table 'modifierSwitchWinKeys' (see above).


## Moving and Resizing Windows:

With SpaceHammer you can automatically resize and position the windows on your mSpaces according to a dynamically changing grid size. Let us get started with manual moving and resizing, though:


### Manual Moving and Positioning

To make moving windows easier than the usual clicking on the title bar (which you are still free to do), hold 'alt' or 'ctrl' down, position your cursor in any area within the window, click the left mouse button, and drag the window. If a window is dragged up to 10 percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the borders of the screen. If the window is dragged beyond this 10-percent-limit, things are getting interesting because then window management with automatic resizing and positioning comes into play.


### Automatic Resizing and Positioning - Mouse, Trackpad

For automatic resizing and positioning of a window, you simply move between 10 and 80 percent of the window beyond the left, right, or bottom borders of your screen using while pressing 'alt' or 'ctrl'. 

As long as windows are resized - or moved within the borders of the screen -, it makes no difference whether you use your 'alt' or 'ctrl'. However, once a window is moved beyond the screen borders, different positioning and resizing scenarios are called into action; they are as follows:

* modifier1: 
  * If windows are moved beyond the left (right) borders of the screen: imagine your screen border divided into three sections: if the cursor crosses the screen border in the middle section, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower sections, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: imagine your bottom screen border divided into three sections: if the cursor crosses the screen border in the middle section, the window snaps into full screen. Crossing the screen border in the left or right sections, the window snaps into the respective halfs of the screen.

* modifier2: 
  * The difference to 'alt' is that your screen has a 3x3 grid. This means that windows snap into the left third of the 3x3 grid when dragged beyond the left screen border and into the right third when dragged beyond the right screen border. If 'ctrl' is released before the left mouse button, the window will snap into the middle column.
 
* The moment dragging of a window starts, indicators will guide you. For changing their appearance see below.

All this is been implemented with the goal of being as intuitive as possible; therefore, you will be able to train your muscle memory in no time. Promise.


### Automatic Resizing and Positioning - Keyboard

The automatic resizing and positioning using keyboard shortcuts is not enabled by default, so if you want to use this feature, add the following lines to your 'init.lua' (they will be explained in a minute, and it will also be explained how you can adjust the keyboard shortcuts to your liking):

```lua
  ...
  modifierSnap1 = { 'cmd', 'alt' }, -- default: nil
  modifierSnap2 = { 'cmd', 'ctrl' }, -- default: nil
  modifierSnap3 = { 'cmd', 'alt', 'ctrl' }, -- default: nil

  modifierSnapKeys = {
    -- modifierSnapKey1
    {{'a1','1'},{'a2','2'},{'a3','3'},{'a4','4'},{'a5','5'},{'a6','6'},{'a7','7'}},
    -- modifierSnapKey2
    {{'b1','1'},{'b2','2'},{'b3','3'},{'b4','4'},{'b5','5'},{'b6','6'},{'b7','7'},{'b8','8'},{'b9','9'},{'b10','0'},{'b11','o'},{'b12','p'}},
    -- modifierSnapKey3
    {{'c1','1'},{'c2','2'},{'c3','3'},{'c4','4'},{'c5','5'},{'c6','6'},{'c7','7'},{'c8','8'},{'c9','9'},{'c10','0'},{'c11','o'},{'c12','p'}},
  },
  ...
```

To resize and move the active window into a 2x2 grid position, use 'modifierSnap1' and numbers 1-7. 

To resize and move the active window into a 3x3 grid position, use 'modifierSnap2' and numbers 1-9, additionally '0', 'o', and 'p'. 

'modifierSnap3' also uses a 3x3 grid and is combined with the same keys as 'modifierSnap2'. However, the windows snap into different sizes, see '3x3 Grid - Double (and Quadruple) Sizes' below.

Below you find the pre-assigned keyboard shortcuts. As has been mentioned, you can change and freely combine them; more about that below.

#### 2x2 Grid
'modifierSnap1' and '1': left half of screen -> 'a1'
'modifierSnap1' and '2': right half of screen -> 'a2'
'modifierSnap1' and '3': top left quarter of screen -> 'a3'
'modifierSnap1' and '4': bottom left quarter of screen -> 'a4'
'modifierSnap1' and '5': top right quarter of screen -> 'a5'
'modifierSnap1' and '6': bottom right quarter of screen -> 'a6'
'modifierSnap1' and '7': whole screen -> 'a7'

#### 3x3 Grid
Windows are positioned as follows:
'modifierSnap2' and '1': left third of screen -> 'b1'
'modifierSnap2' and '2': middle third of screen -> 'b2'
'modifierSnap2' and '3': right third of screen -> 'b3'
'modifierSnap2' and '4': left top ninth of screen -> 'b4'
'modifierSnap2' and '5': left middle ninth of screen -> 'b5'
'modifierSnap2' and '6': left bottom ninth of screen -> 'b6'
'modifierSnap2' and '7': middle top ninth of screen -> 'b7'
'modifierSnap2' and '8': middle middle ninth of screen -> 'b8'
'modifierSnap2' and '9': middle bottom ninth of screen -> 'b9'
'modifierSnap2' and '0': right top ninth of screen -> 'b10'
'modifierSnap2' and 'o': right middle ninth of screen -> 'b11'
'modifierSnap2' and 'p': right bottom ninth of screen -> 'b12'



#### 3x3 Grid - Double (and Quadruple) Sizes
You can have windows take up more cells on the 3x3 grid (the 3x3 grid consists of 9 cells). The pre-defined positions and sizes are as follows (descriptions might be difficult to follow; so simply try the keyboard shortcuts out):

'modifierSnap3' and '1': left two thirds of screen': 3 cells -> 'c1'
'modifierSnap3' and '2': right two thirds of screen': 3 cells -> 'c2'
'modifierSnap3' and '3': left third, upper two cells -> 'c3'
'modifierSnap3' and '4': left third, lower two cells -> 'c4'
'modifierSnap3' and '5': middle third, upper two cells -> 'c5'
'modifierSnap3' and '6': middle third, lower two cells -> 'c6'
'modifierSnap3' and '7': right third, upper two cells -> 'c7'
'modifierSnap3' and '8': right third, lower two cells -> 'c8'
'modifierSnap3' and '9': top left and middle thirds': 4 cells -> 'c9'
'modifierSnap3' and '0': bottom left and middle thirds': 4 cells -> 'c10'
'modifierSnap3' and 'o': top middle and right thirds': 4 cells -> 'c11'
'modifierSnap3' and 'p': bottom middle and right thirds': 4 cells -> 'c12'

As has been mentioned, these keyboard shortcuts are fully customizable, which is best shown with an example: let us assume for a moment that you just need windows to snap into three different grid positions, (1) right half of screen -> 'a2', (2) right middle ninth of screen -> 'b11', and (3) middle third, upper two cells -> 'c5', and you would like to use modifierSnap2 with the keys 'j', 'k', and 'l' to achieve that; then your 'init.lua' would look like this:

```lua
  ...
  modifierSnap2 = { 'cmd', 'ctrl' }, -- default: nil

  modifierSnapKeys = {
    -- modifierSnapKey1
    {},
    -- modifierSnapKey2
    {{'a2','j'},{'b11','k'},{'c5','l'}},
    -- modifierSnapKey3
    {},
  },
  ...
```
As you can see in the example above, 'modifierSnapKey1' and 'modifierSnapKey3' are not used and are therefore empty. 'modifierSnapKey2' contains the three desired shortcuts. 

Now, by pressing 'modifierSnapKey1' and 'j', for example, scenario 'a2' is activated, which means that the active window snaps into the right half of the screen.

## Additional Explanations

### Change Size, Color, and Opacity of Grid Indicators

In case you would like to change the size, color and/or opacity of the grid indicators, add the following line to your 'init.lua'. The values, in this order, stand for: width, red, green, blue, opacity. Apart from the width, values between 0 and 1 are possible:

```lua
  ...
  -- change grid indicators:
    gridIndicator = { 20, 1, 0, 0, 0.5 }, -- default: { 20, 1, 0, 0, 0.5 }, 

  ...
```

### Restart

- If you restart SpaceHammer, the windows on the current mSpace remain the way they were before the restart, while the windows that were placed on other mSpaces will be moved to the current mSpace. 

This also means that if at some point you want to stop using SpaceHammer, either move all windows to the current mSpace first, or simply restart SpaceHammer one more time.

As an optical experimental feature, SpaceHammer can automatically backup and restore mSpaces and their windows; more in the section 'Backup and Restore of mSpaces' below.


## Experimental

### Backup and Restore of mSpaces

mSpaces with their windows can be automatically backed up and restored. Only the windows open at the time SpaceHammer starts will be restored.

```lua
  ...
  -- automatic backup and restore of mSpaces:
  backup = true, -- default: false
  ...
```

Note: you can always restore mSpaces and their windows after increasing the amount of mSpaces in settings, i.e., 'mSpaces = ' in 'init.lua'. However, restoring after decreasing the amount of mSpaces is only possible if there are at least as many mSpaces left as the index of the mSpace with the last window on it before the decrease of mSpaces.


### Manual Resizing

Similar to manual moving, manual resizing of windows can be initiated by positioning the cursor in virtually any area of the window. Be aware, though, that windows of certain applications, such as LosslessCut or Kdenlive, can behave in a stuttering and sluggish way when being resized. That being said, resizing works well with the usual suspects such as Safari, Google Chrome, or Finder.

In order to enable manual resizing, add the following lines to your 'init.lua':

```lua
  ...
  -- enable resizing:
  resize = true, -- default: false
  ...
```

To manually resize a window, hold your 'modifier1' or 'modifier2' down, then click the right mouse button in any part of the window and drag the window.

To have the additional possibility of precisely resizing windows horizontally-only or vertically-only, 30 percent of the window (15 precent left and right of the middle of each border) is reserved for horizontal-only and vertical-only resizing. The size of this area can be adjusted; for more information see below.

<img src="https://github.com/franzbu/WinHammer.spoon/blob/main/doc/demo1.gif" />

At the center of the window there is an erea (M) where you can also move the window by pressing the right mouse button. 

<img src="https://github.com/franzbu/WinHammer.spoon/blob/main/doc/resizing.png" width="200">


#### Manual Resizing of Windows - Margin

You can change the size of the area of the window where the vertical-only and horizontal-only resizing applies by adjusting the option 'margin'. The standard value is 0.3, which corresponds to 30 percent. Changing it to 0 results in deactivating this options, changing it to 1 results in deactivating resizing.

```lua
  ...
  -- adjust the size of the area with vertical-only and horizontal-only resizing:
  margin = 0.2, -- default: 0.3
  ...
```


## Uninstall SpaceHammer

In case you at some point had the automatic backup and restore function activated, start SpaceHammer once with it deactivated; to do so, delete the following line in your 'init.lua' (or set it to false).

```lua
  ...
  -- automatic backup and restore of mSpaces:
  backup = true, -- default: false
  ...
```


Other than that you only have to delete the folder 'SpaceHammer.spoon' in the folder '~/.hammerspoon/Spoons/' and delete the corresponding section in your 'init.lua'.


