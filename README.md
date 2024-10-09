# Mellon

Mellon has been inspired by Aerospace, Moom, BetterTouchTool, and others. Mellon has simplified my life with my Mac; may it do the same for you.

To simplify one's life is not too bad, but what does this tool actually do to justify my spending time with it, you might ask. 

Well, first, spending your time with Mellon will actually save you time. As far as the capabilities of this tool are concerned, the answer is simple: it helps you organize your workspace, which comes down to two main tasks: managing your spaces and your applications and windows on them. 

When it comes to spaces, Mellon provides a new implementation of what Apple has straightforwardly termed 'Spaces'; in Mellon they are called mSpaces, and what the 'm' stands for is a story I am not going to bore you with. 

Suffice to say that mSpaces follow the approach of representing windows rather than containing them, which, for instance, makes it possible to have the same window on more than one mSpace. When it comes to managing windows, they are positioned and resized according to your demands with keyboard shortcuts or a flick of your pointing device.

Still, this is nothing really new, I hear you say, and you are right. The way your windows and spaces are managed, is, though, and you might be surprised at what a difference sometimes even a slightly altered approach can make. But read on and judge for yourself.

One last thing before we get our toes wet: windows and mSpaces can be handled using your keyboard only; however, similar to other operations, at times it is simpler and faster to use keyboard and pointing device together. Thus Mellon provides this additional option wherever it is beneficial. 


## Installation

Mellon requires [Hammerspoon](https://www.hammerspoon.org/), so just go ahead with its installation.

To install Mellon, after downloading and unzipping it, move the folder to ~/.hammerspoon/Spoons and make sure the name of the folder is 'Mellon.spoon'. 

Alternatively, run the following command in a terminal window:

```bash

mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/franzbu/Mellon.spoon.git ~/.hammerspoon/Spoons/Mellon.spoon

```

## Usage

Once you have installed Mellon, add the following lines to your `~/.hammerspoon/init.lua` file:

```lua
local Mellon = hs.loadSpoon('Mellon')

Mellon:new({

  -- mSpaces:
  mSpaces = { '1', '2', '3', 'E', 'T' }, -- default { '1', '2', '3' }
  startmSpace = 'E', -- default 2

  modifier1 = { 'alt' }, -- default: { 'alt' }
  modifier2 = { 'ctrl' }, -- default: { 'ctrl' }

})

```

Restart Hammerspoon and you are ready to go. You might additionally be interested in adjusting the amount and names of your mSpaces and your default mSpace; to do so see above. 

After having Mellon runngin, all you will see for now is a new icon in your menu bar indicating your current mSpace. Let us find out now how to populate your mSpaces.

## mSpaces

The default setup uses modifier1 and modifier2 pressed at the same time and the keys 'a', 's', 'd', 'f', 'q', and 'w' to switch to the mSpace on the left/right ('a', 's'), move a window to the mSpace on the left/right ('d', 'f'), move a window to the mSpace on the left/right and switch there ('q', 'w'). 

Now, by pressing 'modifier1', 'modifier2', and 'q', for instance, you move the active window from your current mSpace to the adjacent mSpace on the left and switch there. For moving the window without switching or switching to another mSpace without moving any windows use the appropriate keyboard shortcuts.

In case you would like to change the modifier for dealing with mSpaces while keeping the original 'modifier1' (which is used for other operations as well, as you will see in a minute) and/or change additional keys, add the following lines with the desired adjustments to your 'init.lua'; the example below shows my setup with CapsLock set up as hyper key, for example, using [Karabiner Elements]([https://www.hammerspoon.org/](https://karabiner-elements.pqrs.org/)):


```lua
  ...
  modifierMS = { 'alt', 'ctrl' }, -- default: modifier1 + modifier2
  -- 1, 2: switch to mSpace left/right ('a', 's')
  -- 3, 4: move window to mSpace left/right ('d', 'f')
  -- 5, 6: move window to mSpace left/right and switch there ('q', 'w')
  modifierMSKeys = {'a', 's', 'd', 'f', 'q', 'w'}, -- default: {'a', 's', 'd', 'f', 'q', 'w'}
  ...
```

### Switch Directly to Any mSpace

For switching directly to any mSpace, press 'alt' . In case you would like to change this modifier, add the following line to your 'init.lua', making the appropriate changes ragarding your desired modifier(s):

```lua
  ...
  modifierMoveWinMSpace = { 'alt' }, -- default: { 'alt' }
  ...
```

### Move Windows Directly to Any mSpace

So far we have discussed how to move windows to the adjacent mSpace. In case you would like to have a keyboard shortcut for moving windows to any mSpace directly, add the following line to your 'init.lua', making the appropriate changes regarding your desired modifier(s):

```lua
  ...
  modifierSwitchMS = { 'alt', 'shift' }, -- default: nil
  ...
```


## mSpaces Carry Further Potential

However, we have not walked over the finish line yet. That being said, this section is for advanced users and can be skipped.

If you want to unlock the full potential of mSpaces, it is helpful to understand the underlying philosophy: see each mSpace as a representation of your windows rather than just some area where your windows can be placed, or, in other words: an mSpace is a set of 'symbolic links' to your windows. Due to this approach, you could, for instance, have two mSpaces with the same windows in different sizes and positions, which might even be sensible for specific workflows where it makes sense to be switching instantly between a bigger window of one and a smaller window of another application and vice versa. Or you can have the same Notes, Calendar, Finder or Safari window on two, three, or all of your mSpaces.
  
To create representations of windows, press the 'ctrl' and 'shift' modifiers simultaneously and additionally press the key corresponding to the mSpace you would like to create a reference of the currently active window on, for instance, '3'. In case you would like to adjust the modifiers, add the following line to your 'init.lua':

```lua
  ...
  modifierReference = { 'ctrl', 'shift' }, -- default: { 'ctrl', 'shift' }
  ...
```
To delete a reference, press 'modifierReference' and '0'. In case you are 'de-referencing' the last representation of a window on your mSpaces, the window gets minimized.


## Switching Between Windows

You can use macOS's integrated window switcher (cmd-tab) or any third party switcher such as [AltTab]([[https://www.hammerspoon.org/](https://karabiner-elements.pqrs.org/](https://alt-tab-macos.netlify.app/))) for switching between all your windows. Also for switching between the different windows of one application you can use Apple's integrated switcher or any third party alternative.

However, since mSpaces provide additional features, these need harvesting, and Mellon provides further possibilities for switching between windows, namely (1) switching between all the windows on the current mSpace and (2) switching between references of windows ('sticky windows').

### Switching between Windows of the Current mSpace

For switching between the windows of your current mSpace, press 'modifier1' and 'tab', and for switching in reverse order additionally press 'shift'. Add the following lines to 'init.lua' in case you prefer different keyboard shortcuts:


```lua
  ...
  -- keyboard shortcuts for switching between windows on one mSpace...
  -- ... and between references of one and the same window on different mSpaces
  modifierSwitchWin = { 'alt' }, -- default: modifier1
  modifierSwitchWinKeys = { 'tab', 'escape' }, -- default: { 'tab', 'escape' }
  ...
```

### Switching between References of Windows

For switching between the references of a window ('sticky windows'), press 'modifier1' and 'escape'. In case you prefer a different key, change the second element in the table 'modifierSwitchWinKeys' (see above).


## Moving and Resizing Windows:

With Mellon you can automatically resize and position the windows on your mSpaces according to a dynamically changing grid size. Let us get started with manual moving and resizing, though:


### Manual Moving and Positioning

To make moving windows easier than having to hold on to the title bar (which you are still free to do), hold 'modifier1' or 'modifier2' down, position your cursor in any area within the window, click the left mouse button, and drag the window. If a window is dragged up to 10 percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the borders of the screen. If the window is dragged beyond this 10-percent-limit, things are getting interesting because then window management with automatic resizing and positioning comes into play.


### Automatic Resizing and Positioning - Mouse and/or Trackpad

For automatic resizing and positioning of a window, you simply move between 10 and 80 percent of the window beyond the left, right, or bottom borders of your screen using while pressing 'modifier1' or 'modifier2'. 

As long as windows are resized - or moved within the borders of the screen -, it makes no difference whether you use your 'modifier1' or 'modifier2'. However, once a window is moved beyond the screen borders, different positioning and resizing scenarios are called into action; they are as follows:

* modifier1: 
  * If windows are moved beyond the left (right) borders of the screen: imagine your screen border divided into three sections: if the cursor crosses the screen border in the middle section, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower sections, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: imagine your bottom screen border divided into three sections: if the cursor crosses the screen border in the middle section, the window snaps into full screen. Crossing the screen border in the left or right sections, the window snaps into the respective halfs of the screen.

* modifier2: 
  * The difference to 'modifier1' is that your screen has a 3x3 grid. This means that windows snap into the left third of the 3x3 grid when dragged beyond the left screen border and into the right third when dragged beyond the right screen border. If 'modifier2' is released before the left mouse button, the window will snap into the middle column.
 
* The moment dragging of a window starts, indicators will guide you. For changing their appearance see below.

All this is been implemented with the goal of being as intuitive as possible; therefore, you will be able to train your muscle memory in no time. Promise.


### Automatic Resizing and Positioning - Keyboard

Add the following lines to your 'init.lua', these entries will be explained in a minute, and it will also be shown how to adjust the keyboard shortcuts:

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

'modifierSnap3' with the same keys as with 'modifierSnap2' also uses a 3x3 grid, but the windows snap into different sizes, see '3x3 Grid - Double (and Quadruple) Sizes' below.


#### 2x2 Grid

- 1: left half of screen -> 'a1'
- 2: right half of screen -> 'a2'
- 3: top left quarter of screen -> 'a3'
- 4: bottom left quarter of screen -> 'a4'
- 5: top right quarter of screen -> 'a5'
- 6: bottom right quarter of screen -> 'a6'
- 7: whole screen -> 'a7'

#### 3x3 Grid

Windows are positioned as follows:
- 1: left third of screen -> 'b1'
- 2: middle third of screen -> 'b2'
- 3: right third of screen -> 'b3'
- 4: left top ninth of screen -> 'b4'
- 5: left middle ninth of screen -> 'b5'
- 6: left bottom ninth of screen -> 'b6'
- 7: middle top ninth of screen -> 'b7'
- 8: middle middle ninth of screen -> 'b8'
- 9: middle bottom ninth of screen -> 'b9'
- 0: right top ninth of screen -> 'b10'
- o: right middle ninth of screen -> 'b11'
- p: right bottom ninth of screen -> 'b12'

#### 3x3 Grid - Double (and Quadruple) Sizes

With the following keyboard shortcuts, you can create windows that take up more cells on the 3x3 grid, which contains 9 cells altogether:

Windows are positioned as follows -> (descriptions might be difficult to understand; so just try it out):
- 1: left two thirds of screen: 3 cells -> 'c1'
- 2: right two thirds of screen: 3 cells -> 'c2'
- 3: left third, upper two cells -> 'c3'
- 4: left third, lower two cells -> 'c4'
- 5: middle third, upper two cells -> 'c5'
- 6: middle third, lower two cells -> 'c6'
- 7: right third, upper two cells -> 'c7'
- 8: right third, lower two cells -> 'c8'
- 9: top left and middle thirds: 4 cells -> 'c9'
- 0: bottom left and middle thirds: 4 cells -> 'c10'
- o: top middle and right thirds: 4 cells -> 'c11'
- p: bottom middle and right thirds: 4 cells -> 'c12'

As has been pointed out, these keyboard shortcuts are fully customizable. 

Here is an example: let us assume you just need windows to snap into three different grid positions, (1) right half of screen -> 'a2', (2) right middle ninth of screen -> 'b11', and (3) middle third, upper two cells -> 'c5', and you would like to use modifierSnap2 with the keys 'j', 'k', and 'l', then your 'init.lua' would look like this:

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


## Additional Information

### Change Size, Color, and Opacity of Grid Indicators

In case you would like to change the size, color and/or opacity of the grid indicators, add the following line to your 'init.lua'. The values, in this order, stand for: width, red, green, blue, opacity. Apart from the width, values between 0 and 1 are possible:

```lua
  ...
  -- change grid indicators:
    gridIndicator = { 20, 1, 0, 0, 0.5 }, -- default: { 20, 1, 0, 0, 0.5 }, 

  ...
```

### Restart

- If you restart Mellon, the windows on the current mSpace remain the way they were before the restart, while the windows that were placed on other mSpaces will also be moved to the current mSpace. In other words, if you want to stop using Mellon, either move all windows to one mSpace first, or restart Mellon one last time. A backup feature restoring windows to their original mSpaces is on the todo list.


## Experimental

### Manual Resizing

Similar to manual moving, manual resizing of windows can be initiated by positioning the cursor in virtually any area of the window. Be aware, though, that windows of certain applications, such as LosslessCut or Kdenlive, can behave in a stuttering and sluggish way when being resized. That being said, resizing works well with the usual suspects such as Safari, Google Chrome, or Finder.

In order to enable manual resizing, add the following option to your 'init.lua':

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



