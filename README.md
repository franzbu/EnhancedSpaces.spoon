# EnhancedSpaces


macOS introduced changes to Apple's Spaces feature that broke many third party tools that had added various enhancements, among them Hammerspoon's spaces.

That is the reason EnhancedSpaces exists; it started as a replacement for Apple's Spaces - in EnhancedSpaces they are called mSpaces, providing features Apple doesn't, such as sticky windows and - most importantly, bringing back time-saving features such as easily and quickly moving windows between mSpaces, opening windows on pre-arranged mSpaces and the latter optionally in pre-arranged sizes and positions.

As an additional feature, you can use EnhancedSpaces' integrated window manager for resizing and positioning your windows with keyboard shortcuts or, optionally, with the help of your mouse or trackpad. However, you can also use your favorite window manager to organize the windows on your mSpaces.

EnhancedSpaces has been inspired by various applications, among them AeroSpace, Moom and BetterTouchTool. EnhancedSpaces has simplified my life with macOS; may it do the same for you.


## Installation

EnhancedSpaces requires [Hammerspoon](https://www.hammerspoon.org/), so if you have not been using the latter yet, go ahead with its installation. Besides installing Hammerspoon for EnhancedSpaces' sake, you might also be interested in Hammerspoon's virtually endless possibilities for taylor-made customizations of your macOS. 

To install EnhancedSpaces, after downloading and unzipping, move the folder to `~/.hammerspoon/Spoons` and make sure the name of the folder is `EnhancedSpaces.spoon`. 

Alternatively, you can run the following terminal command:

```bash

mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/franzbu/EnhancedSpaces.spoon.git ~/.hammerspoon/Spoons/EnhancedSpaces.spoon

```

## mSpaces

Once you've installed EnhancedSpaces, add the following lines to the file `~/.hammerspoon/init.lua`; you might want to adjust the amount and names of your mSpaces and `startmSpace`, which is the mSpace you will be greeted with:

```lua
local EnhancedSpaces = hs.loadSpoon('EnhancedSpaces')
EnhancedSpaces:new({
  mSpaces = { '1', '2', '3', 'E', 'T' }, -- default { '1', '2', '3' }
  startmSpace = 'E', -- default 2
})

```

Restart Hammerspoon and you're ready to go; it is normal that the start of EnhancedSpaces takes a couple of seconds as this is the time the watchdogs need for registering. All you will see for now is a new icon in your menu bar indicating your current mSpace, so let us find out what you can do with your new mSpaces.

### Usage

You can use the Control (`ctrl`) - in case you're interested in an elegant alternative in the form of a hyper key, see section 'Notes' below - and the `s` keys to cycle through your mSpaces. To cycle in reverse order, press `ctrl` and `a`. To move the active window to the mSpace on the left (right) and switch there alongside with the window, press `ctrl` and `q` (`w`); to move the window while staying on the current mSpace press `ctrl` and `d` (`ctrl` and `w`).

The lines below represent the default setup, and you don't need to add them to your `init.lua` unless you want to apply changes:

```lua
  ...
  modifierMS = { 'ctrl' }, -- default: { 'ctrl' }
  modifierMSKeys = { 'a', 's', 'd', 'f', 'q', 'w' }, -- default: { 'a', 's', 'd', 'f', 'q', 'w' }
  ...
```


### Switch Directly to Any mSpace

For switching directly to any mSpace, press `alt` and the key for your mSpace, for example, `3`.

As before, the line below represents the default setup, and you don't need to add it to your `init.lua` unless you want to apply any changes:

```lua
  ...
  modifierMoveWinMSpace = { 'alt' }, -- default: { 'alt' }
  ...
```

### Move Windows Directly to Any mSpace

For moving windows to an mSpace, press `alt-ctrl` and the key for the target mSpace.

As before, the line below represents the default setup, and you don't need to add it to your `init.lua` unless you want to apply changes:

```lua
  ...
  modifierSwitchMS = { 'alt', 'ctrl' }, -- default: { 'alt', 'ctrl' }
  ...
```

### Same Window on More Than One mSpace

By now we have covered the basics, but we haven't walked over the finish line yet. That being said, this section is mainly for advanced use cases, namely having 'the same window on more than one mSpace, also known as 'sticky windows'. 

To unlock the full potential of mSpaces, it is helpful to understand the underlying philosophy: Each mSpace is a representation of your windows rather than just a space containing them - or, in other words, an mSpace can be understood as a set of 'symbolic links' to a subset of your open windows. Due to this approach you could, for instance, have two mSpaces with the same windows in different sizes and positions, or - a scenario that is more likely - you can have the same Notes, Calendar, Finder or Safari window on two, three, or all your mSpaces.
  
To make a window visible on another mSpace as well, press the `ctrl-shift` modifiers and additionally press the key corresponding to the target mSpace, for instance, `3`. 

As before, the below line represents the default setup, and you don't need to add it to your `init.lua` unless you want to apply changes:

```lua
  ...
  modifierReference = { 'ctrl', 'shift' }, -- default: { 'ctrl', 'shift' }
  ...
```

To delete a reference, press `modifierReference` and `0`. In case you're 'de-referencing' the last representation of a window on your mSpaces, the window gets minimized.


### Switching Between Windows

Apart from switching between all windows, for which you will obviously use macOS' integrated window switcher (Command-Tab) or the third party switcher of your choice, such as [AltTab](https://alt-tab-macos.netlify.app/), additional possibilities have been implemented in EnhancedSpaces for window-switching, namely (1) switching between the windows on the current mSpace and (2) switching between references of windows ('sticky windows').

#### Switching between Windows of the Current mSpace

For switching to the windows of your current mSpace, press `alt` and `tab`. 

As before, the below lines represent the default setup, and you don't need to add them to your `init.lua` unless you prefer different shortcuts:


```lua
  ...
  -- keyboard shortcuts for switching between windows on current mSpace and between references
  modifierSwitchWin = { 'alt' }, -- default: { 'alt' }
  modifierSwitchWinKeys = { 'tab', 'escape' }, -- default: { 'tab', 'escape' }
  ...
```

For cycling through the windows of your current mSpace in reverse order, additionally press `shift`.


#### Switching between References of Windows

For switching between the references of a window ('sticky windows'), press `alt` and `escape`. In case you prefer a different key, change the second element in the table `modifierSwitchWinKeys` (see above).


## Moving and Resizing Windows:

With EnhancedSpaces you can automatically resize and position the windows on your mSpaces according to a dynamically changing grid size. 


### Automatic Resizing and Positioning - Keyboard

The following lines show the default keyboard shortcuts for the automatic resizing and positioning of windows.

As before, you don't need to add these lines to your `init.lua` unless you want to apply changes. 

```lua
  ...
  modifierSnap1 = { 'cmd', 'alt' }, -- default: { 'cmd', 'alt' }
  modifierSnap2 = { 'cmd', 'ctrl' }, -- default: { 'cmd', 'ctrl' }
  modifierSnap3 = { 'cmd', 'shift' }, -- default: { 'cmd', 'shift' }
  ...
```

In case you would like to disable EnhancedSpaces' window manager because you manage your windows manually or you prefer using another window manager, change the entries like this:

```lua
  ...
  modifierSnap1 = nil, -- default: { 'cmd', 'alt' }
  modifierSnap2 = nil, -- default: { 'cmd', 'ctrl' }
  modifierSnap3 = nil, -- default: { 'cmd', 'shift' }
  ...
```

To resize and move the active window into a 2x2 grid position, use `modifierSnap1` (default the Command and Option keys) and numbers `1-8`. 

To resize and move the active window into a 3x3 grid position, use `modifierSnap2` and numbers `1-9`, additionally `0`, `o`, and `p`. 

`modifierSnap3` also uses a 3x3 grid; however, the windows snap into different sizes, see '3x3 Grid - Double (and Quadruple) Sizes' below.

Below you find the pre-assigned keyboard shortcuts.

#### 2x2 Grid
- `modifierSnap1` and `1`: left half of screen -> 'a1'
- `modifierSnap1` and `2`: right half of screen -> 'a2'
- `modifierSnap1` and `3`: top left quarter of screen -> 'a3'
- `modifierSnap1` and `4`: bottom left quarter of screen -> 'a4'
- `modifierSnap1` and `5`: top right quarter of screen -> 'a5'
- `modifierSnap1` and `6`: bottom right quarter of screen -> 'a6'
- `modifierSnap1` and `7`: whole screen -> 'a7'
- `modifierSnap1` and `8`: size as is, center of screen -> 'a8'


#### 3x3 Grid
- `modifierSnap2` and `1`: left third of screen -> 'b1'
- `modifierSnap2` and `2`: middle third of screen -> 'b2'
- `modifierSnap2` and `3`: right third of screen -> 'b3'
- `modifierSnap2` and `4`: left top ninth of screen -> 'b4'
- `modifierSnap2` and `5`: left middle ninth of screen -> 'b5'
- `modifierSnap2` and `6`: left bottom ninth of screen -> 'b6'
- `modifierSnap2` and `7`: middle top ninth of screen -> 'b7'
- `modifierSnap2` and `8`: middle middle ninth of screen -> 'b8'
- `modifierSnap2` and `9`: middle bottom ninth of screen -> 'b9'
- `modifierSnap2` and `0`: right top ninth of screen -> 'b10'
- `modifierSnap2` and `o`: right middle ninth of screen -> 'b11'
- `modifierSnap2` and `p`: right bottom ninth of screen -> 'b12'


#### 3x3 Grid - Additional Window Sizes
You can have windows take up more cells on the 3x3 grid. The pre-defined positions and sizes are as follows (descriptions might be tricky; so simply try the keyboard shortcuts out):

- `modifierSnap3` and `1`: left two thirds of screen: 6 cells -> 'c1'
- `modifierSnap3` and `2`: right two thirds of screen: 6 cells -> 'c2'
- `modifierSnap3` and `3`: left third, upper two cells -> 'c3'
- `modifierSnap3` and `4`: left third, lower two cells -> 'c4'
- `modifierSnap3` and `5`: middle third, upper two cells -> 'c5'
- `modifierSnap3` and `6`: middle third, lower two cells -> 'c6'
- `modifierSnap3` and `7`: right third, upper two cells -> 'c7'
- `modifierSnap3` and `8`: right third, lower two cells -> 'c8'
- `modifierSnap3` and `9`: top left and middle thirds: 4 cells -> 'c9'
- `modifierSnap3` and `0`: bottom left and middle thirds: 4 cells -> 'c10'
- `modifierSnap3` and `o`: top middle and right thirds: 4 cells -> 'c11'
- `modifierSnap3` and `p`: bottom middle and right thirds: 4 cells -> 'c12'

As has been mentioned, these keyboard shortcuts are fully customizable. Let us first have a look at the standard setup, i.e., the way the keyboard shortcuts have been pre-defined:


```lua
  ...
  modifierSnapKeys = {
    -- modifierSnapKey1
    {{'a1','1'},{'a2','2'},{'a3','3'},{'a4','4'},{'a5','5'},{'a6','6'},{'a7','7'},{'a8','8'}},
    -- modifierSnapKey2
    {{'b1','1'},{'b2','2'},{'b3','3'},{'b4','4'},{'b5','5'},{'b6','6'},{'b7','7'},{'b8','8'},{'b9','9'},{'b10','0'},{'b11','o'},{'b12','p'}},
    -- modifierSnapKey3
    {{'c1','1'},{'c2','2'},{'c3','3'},{'c4','4'},{'c5','5'},{'c6','6'},{'c7','7'},{'c8','8'},{'c9','9'},{'c10','0'},{'c11','o'},{'c12','p'}},
  },
  ...
```

In case you would like to make changes, you can combine any of the three modifiers `modifierSnap1`, `modifierSnap1`, and `modifierSnap1` with any of the scenarios.

This is best shown by means of an example: let us assume that you just need windows to snap into three different grid positions:
- (1) right half of screen -> 'a2'
- (2) right middle ninth of screen -> 'b11'
- (3) middle third, upper two cells -> 'c5'

Let us further assume that you would like to use `modifierSnap1` with the keys `j`, `k`, and `l` to achieve that; then you would add the following lines to your `init.lua`:

```lua
  ...
  modifierSnapKeys = {
    -- modifierSnapKey1
    {{'a2','j'},{'b11','k'},{'c5','l'}},
    -- modifierSnapKey2
    {},
    -- modifierSnapKey3
    {},
  },
  ...
```
As you can see in the example above, `modifierSnapKey2` and `modifierSnapKey3` are not used and are therefore without any entries.

Now, by pressing `modifierSnapKey1` and `j`, for example, scenario 'a2' is activated, which means that the active window snaps into the right half of the screen.


## Using Mouse/Trackpad

### Move windows to Adjacent mSpaces

You can also use your pointing device to move a window to an adjacent mSpace by pressing the Option (`alt`) or Control (`ctrl`) key and dragging 80 percent or more of the window beyond the left or right screen border. If you release the modifier key before releasing the mouse button, the window is moved while you stay on the current mSpace, otherwise you switch to the mSpace alongside with the window. 

As per default, `modifier1` uses the same modifier key as `modifierMS` and `modifier2` the same as `modifierMoveWinMSpace`. They don't interfere; however, in case you prefer different mouse modifiers, you can add the following lines to your `init.lua` and adjust them to your liking:

```lua
   ...
  -- mouse modifiers
  modifier1 = { 'alt' }, -- default: { 'alt' }
  modifier2 = { 'ctrl' }, -- default: { 'ctrl' }
  ...
```

### Using Mouse Trackpad for Moving and Resizing Windows

Similar to other operations, at times it can be simpler and faster if you use both your keyboard and pointing device at the same time. Thus EnhancedSpaces provides an alternative by enabling the use of a pointing device whenever it has the potential of being beneficial. 


#### Manual Moving and Positioning

To make moving windows easier than the usual clicking on the title bar (which you're still free to do), hold down `modifier1` or `modifier2`, position your cursor in any area within the window, click the left mouse button, and drag the window. If a window is dragged up to 10 percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the borders of the screen. If the window is dragged beyond this 10-percent-limit, things are getting interesting because then window management with automatic resizing and positioning comes into play.


#### Automatic Resizing and Positioning - Mouse, Trackpad

For automatic resizing and positioning of a window, you simply move between 10 and 80 percent of the window beyond the left, right, or bottom borders of your screen using while pressing `alt` or `ctrl`. 

As long as windows are resized - or moved within the borders of the screen -, it makes no difference whether you use `modifier1` or `modifier2`. However, once a window is moved beyond the screen borders, different positioning and resizing scenarios are called into action; they are as follows:

* modifier1 (`alt`, unless changed): 
  * If windows are moved beyond the left (right) borders of the screen: imagine your screen border divided into three sections: if the cursor crosses the screen border in the middle section, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower sections, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: imagine your bottom screen border divided into three sections: if the cursor crosses the screen border in the middle section, the window snaps into full screen. Crossing the screen border in the left or right sections, the window snaps into the respective halfs of the screen.

* modifier2 (`ctrl`, unless changed): 
  * The difference to `modifier1` is that your screen has a 3x3 grid. This means that windows snap into the left third of the 3x3 grid when dragged beyond the left screen border and into the right third when dragged beyond the right screen border. If `ctrl` is released before the left mouse button, the window will snap into the middle column.
 
* The moment dragging of a window starts, indicators will appear around the borders of the screen to guide you. For changing the appearance of the indicators see section 'Change Size, Color, and Opacity of Grid Indicators' below.

- Additional feature: if you drag a window beyond the bottom border of the screen and `modifier1` or `modifier2` is released before the left mouse button, the window will be minimized.

All this is been implemented with the goal of being as intuitive as possible; therefore, you will be able to train your muscle memory quickly.

<img src="https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/demo2.gif" />


## Additional Features

### Open Windows in Pre-Arranged mSpaces

If you want EnhancedSpaces to automatically move windows to specific mSpaces when they are opened, add the following lines to your `init.lua`: 

```lua
  ...
  openAppMSpace = {
    {'Google Chrome', '2'},
    {'Microsoft To Do', '3'},
    {'Safari', '2'},
    {'Email', 'E'},
  }, -- default: nil
  ...
```

The way appications are assigend to certain mSpaces is self-explanatory. To get the names of the applications of open windows, you can simply run the following command in Hammerspoon's Console:

```lua
for _, v in pairs(hs.window.filter.default:getWindows()) do print(v:application():name()) end
```

You will get an output like this:

```bash
2024-10-20 07:38:13: Hammerspoon
2024-10-20 07:38:13: Terminal
2024-10-20 07:38:13: Google Chrome
2024-10-20 07:38:13: Code
2024-10-20 07:38:13: Microsoft To Do
2024-10-20 07:38:13: Email
2024-10-20 07:38:13: Finder
```

In case you would also like to pre-define the position of the window on the mSpace, you can add that information as a third entry:

```lua
  ...
  openAppMSpace = {
    {'Google Chrome', '2', 'a1'},
    {'Microsoft To Do', '3', 'a2'},
    {'Safari', '2', 'a2'},
    {'Email', 'E'},
  },
  ...
```

'a1', for example, represents the left half of your screen, 'a2' the right half of your screen. To get the entire list of possible scenarios, see section 'Automatic Resizing and Positioning - Keyboard'.


### Padding

In case you would like to change the padding in between the windows and/or between the windows and the screen border, add the following lines with values to your liking to your `init.lua`:

```lua
  ...
  -- padding between window borders and screen borders
  outerPadding = 5, -- default: 5
  -- padding between window borders
  innerPadding = 5, -- default: 5
  ...
```

### Change Size, Color, and Opacity of Grid Indicators

In case you would like to change the size, color and/or opacity of the grid indicators, add the following line to your `init.lua`, and alter the values according to your liking. The values, in the same order, stand for: width, red, green, blue, opacity. Apart from the width, values between 0 and 1 are possible:

```lua
  ...
  -- change grid indicators:
    gridIndicator = { 20, 1, 0, 0, 0.33 }, -- default: { 20, 1, 0, 0, 0.33 }, 

  ...
```

## Experimental Features

### Manual Resizing

Similar to manual moving, manual resizing of windows can be initiated by positioning the cursor in virtually any area of the window. Be aware, though, that windows of certain applications can behave in a stuttering and sluggish way when being resized. 

In order to enable manual resizing, add the following to your `init.lua`:

```lua
  ...
  -- enable resizing:
  resize = true, -- default: false
  ...
```

To manually resize a window, hold your `modifier1` or `modifier2` down, then click the right mouse button in any part of the window and drag the window.

To have the additional possibility of precisely resizing windows horizontally-only or vertically-only, 30 percent of the window (15 precent left and right of the middle of each window border) is reserved for horizontal-only and vertical-only resizing. The size of this area can be adjusted; for more information see below.

<img src="https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/demo1.gif" />

At the center of the window there is an erea (M) where you can also move the window by pressing the right mouse button. 

<img src="https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/resizing.png" width="200">


#### Manual Resizing of Windows - Margin

You can change the size of the area of the window where the vertical-only and horizontal-only resizing applies by adjusting the option `margin`. The standard value is 0.3, which corresponds to 30 percent. Changing it to 0 would result in deactivating this options, changing it to 1 would result in deactivating resizing.

```lua
  ...
  -- adjust the size of the area with vertical-only and horizontal-only resizing:
  margin = 0.2, -- default: 0.3
  ...
```

## Notes

### Hyper Key

EnhancedSpaces (and other applications for that matter) can benefit from setting the Caps Lock key up as so called hyper key, which basically means that you get an additional modifier key, as - due to the impracticality of pressing four keys at once - you would hardly be tempted to use the combination of four modifiers otherwise. 

Among others, you can use the application [Karabiner Elements](https://karabiner-elements.pqrs.org/) for creating such a hyper key.

#### Option 1

In this scenario, the original function of the Caps Lock key remains untouched. Using the aforementioned Karabiner Elements, in 'Settings - Complex Modifications' you can click 'Add predefined rule' and search for 'Caps Lock → Hyper Key (⌃⌥⇧⌘) (Caps Lock if alone)'. As the name suggests, with this modification you keep the original function of Caps Lock when pressed and released, while at the same time it functions as hyper key when another key is pressed before Caps Lock is released.

#### Option 2

As an alternative to option 1 I present my personal setup: Caps Lock's functionality is further extended by using a single press (without any other keys) of Caps Lock as stimulating pressing the hyper key and spacebar keys, which in turn can be used to open an application such as Alfred, which is what I use it for. 

The original purpose of Caps Lock is still available; you can trigger this function by pressing the Shift (Command, Option, and Control work likewise) and Caps Lock keys simultaneously.

For this modification, go to 'Settings - Complex Modifications', click 'Add your own rule' and paste the following lines:

```bash
{
    "description": "Hyper key implementation",
    "manipulators": [
        {
            "from": { "key_code": "caps_lock" },
            "to": [
                {
                    "key_code": "left_option",
                    "modifiers": ["left_command", "left_control", "left_shift"]
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "spacebar",
                    "modifiers": ["left_command", "left_control", "left_option", "left_shift"]
                }
            ],
            "type": "basic"
        }
    ]
}
```

Now you can assign your newly created `hyper key` for any modifiers in EnhancedSpaces, for example, `modifierMS`:


```lua
  ...
  modifierMS = { 'cmd', 'alt', 'ctrl', 'shift' }, -- default: { 'ctrl' }
  modifierMSKeys = { 'a', 's', 'd', 'f', 'q', 'w' }, -- default: { 'a', 's', 'd', 'f', 'q', 'w' }
  ...
```
Now, pressing `Caps Lock` and `a`, for instance, switches to the mSpace on the left.

### Uninstall EnhancedSpaces

In case you have used the option `openAppMSpace`, disable or remove that section from your `init.lua` and (re)start EnhancedSpaces afterwards to move all open windows to your main mSpace, which after disabling or uninstalling EnhancedSpaces will automatically become your default space.

```lua
  ...
  --[[
  openAppMSpace = {
    {'Google Chrome', '2', 'a1'},
    {'Code', '2', 'a2'},
    {'Microsoft To Do', 'T'},
    {'Email', 'E'},
  },
  ]]
  ...
```

Afterwards delete the folder `EnhancedSpaces.spoon` in `~/.hammerspoon/Spoons/` and delete the corresponding section in your `init.lua`.

