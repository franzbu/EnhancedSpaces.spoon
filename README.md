# EnhancedSpaces

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/overview.jpg' class="rotate90" />

## First Things First: Who Is This For? 
Not only power users sooner or later feel restricted by the confinements of a single screen; there is no such thing as too much space. A multi-monitor arrangement is the obvious remedy; however, there is a lesser-known solution that enables the user to have more than one screen on a single display: virtual screens or, as they are called in EnhancedSpaces, mSpaces.

mSpaces have both advantages and disadvantages when compared to multi-monitor arrangements. One of the advantages is that you don't have to move your head around to look at another screen - using mSpaces is like swapping the monitors of your multi-monitor arrangement by means of a keyboard shortcut. An obvious disadvantage of mSpaces is that you can't look at more than one of them at a time; however, while every user prefers a different workflow, for many of us looking at two or more monitors simultaneously is simply unnecessary, in which case the benefits of mSpaces comfortably outweigh the downsides.

I dismissed my multi-monitor arrangement in favor of virtual screens years ago and have not looked back. I started out using macOS' built-in Spaces and also used various alternatives; however, something was always missing, which eventually led to the development of an application that manages virtual screens and windows the way I've envisioned it. Enter EnhancedSpaces.

One of EnhancedSpaces' main design goals has been to make managing mSpaces and windows intuitive and efficient. A screen and window manager does its job best when you hardly notice it. In other words: Your windows have the right size and are in the right place with you investing the least possible time and energy to get there. 

EnhancedSpaces' features include using [sticky windows](https://github.com/franzbu/EnhancedSpaces.spoon/tree/main#same-window-on-more-than-one-mspace), [swapping windows](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#swapping-windows), [showing all mSpaces](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#mspace-control) on a grid with the possibility to cycle through them, and [automatically opening windows](https://github.com/franzbu/EnhancedSpaces.spoon/tree/main#open-windows-in-pre-arranged-mspaces) on predefined mSpaces in predefined sizes and positions. Using EnhancedSpaces' window manager you can resize and rearrange your windows with keyboard shortcuts or with your mouse or trackpad. Additionally, the most common features are also available via [menu](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#menu) and [popup menu](https://github.com/franzbu/EnhancedSpaces.spoon/tree/main#popup-menus).

Focus has also been given to making EnhancedSpaces a pleasure to use. So can you customize EnhancedSpaces' menus to your needs, for example, change them to your preferred language, set [individual wallpapers](https://github.com/franzbu/EnhancedSpaces.spoon/tree/main#custom-wallpapers) for each of your mSpaces, change the appearance of the window switcher, and [resize windows](https://github.com/franzbu/EnhancedSpaces.spoon/tree/main#manual-resizing) into all directions using the whole area of the windows rather than just their borders.

Another appeal of EnhancedSpaces is that managing both virtual screens and windows results in synergies that are impossible to achieve when using separate applications, for example, you can drag a window - with your pointing device placed within the whole area of the window, not only its title bar - beyond the borders of the screen and have it reemerge on another mSpace.

So who is EnhancedSpaces for? It has been made for users who like working on multiple screens and want something more efficient and customizable than Apple's Spaces. 

EnhancedSpaces has increased my productivity with macOS. May it do the same for you.


## Introduction
EnhancedSpaces requires [Hammerspoon](https://www.hammerspoon.org/), so in case you haven't used the latter yet, go ahead with its installation.

You can simply regard Hammerspoon as a requirement for EnhancedSpaces; you install it alongside EnhancedSpaces and then forget about it.

However, Hammerspoon might be worthy of a second look in case you're interested in improving workflows on your Mac. Let me demonstrate that with an example:

``` lua
-- connect to VPN
hs.hotkey.bind({ 'cmd', 'shift' }, 's', function()
  os.execute('/usr/local/bin/piactl set region switzerland')
  os.execute('/usr/local/bin/piactl connect')
end)

-- disconnect
hs.hotkey.bind({ 'cmd', 'shift' }, 'd', function()
  os.execute('/usr/local/bin/piactl disconnect')
end)
```

These few lines of Hammerspoon code enable you to connect to one of PIA's VPN servers using the keyboard shortcut `Command-Shift-s`, while `Command-Shift-d` disconnects from the VPN server. 

Even if you're unfamiliar with writing code, there is a plethora of ready-made examples out there, and even without ever having written any code, it's easy to adjust the above lines to, for instance, connecting to your VPN server using `c` in your hotkey instead of `s`, right?

But let's move our focus back to EnhancedSpaces.

## Installation
Download EnhancedSpaces and move the folder to `~/.hammerspoon/Spoons`. Make sure the name of the folder is `EnhancedSpaces.spoon`. 

As an alternative to manually downloading and installing, you can run the following terminal command:

```bash
mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/franzbu/EnhancedSpaces.spoon.git ~/.hammerspoon/Spoons/EnhancedSpaces.spoon
```

## Setting up EnhancedSpaces
Configuring EnhancedSpaces involves rolling up your sleeves and grabbing your keyboard. While it is understandable that even some power users prefer a graphical user interface for adjusting the preferences of their applications, there are substantial advantages to text based configuration that are easily missed unless experienced first-hand. 

One such benefit is that once you've got the knack of it, making changes to your setup is straightforward and efficient, which are reasons why you have become interested in EnhancedSpaces in the first place, right?

Once you've installed EnhancedSpaces, add the following lines to the file `~/.hammerspoon/init.lua` (you can edit that file by clicking the Hammerspoon icon in your menu bar and choosing 'Open Config'). You might also want to adjust the amount and names of your mSpaces and `startmSpace`, which is the mSpace you are greeted with:

``` lua
local EnhancedSpaces = hs.loadSpoon('EnhancedSpaces')
EnhancedSpaces:new({
  mSpaces = { '1', '2', '3', 'E', 'T' }, -- default { '1', '2', '3' }
  startmSpace = 'E', -- default 2
})
```

If you'd like to go ahead without delay, the following terminal command can be used as an alternative to manually editing `init.lua`. In this case the default options are used, which means that the mSpaces `1`, `2`, and `3`are created, with `2` as the default mSpace:

```bash
echo -e "local EnhancedSpaces = hs.loadSpoon('EnhancedSpaces')\nEnhancedSpaces:new({\nmSpaces = { '1', '2', '3' }, -- default: { '1', '2', '3' }\nstartmSpace = '2', -- default: 2\n})" >> ~/.hammerspoon/init.lua
```

Reload Hammerspoon's configuration (menu bar icon - 'Reload Config') and you're ready to go. All you see for now is a new icon in your menu bar indicating your current mSpace, so let's find out how you can interact with your new mSpaces.

## Menu
You can use keyboard shortcuts for handling windows and mSpaces; however, sometimes it can be convenient to get things done via menu - even more so at the beginning, when the muscle memory regarding the new hotkeys might not yet be at full steam.

EnhancedSpaces' menu can be used to switch to another mSpace with or without moving a window along, to swap windows, to get a window from another mSpace, and to create references of windows, i.e., the already mentioned 'sticky windows', which means that the same window can be shown on more than one mSpace - more about references of windows in the section [Same Window on More Than One mSpace](https://github.com/franzbu/EnhancedSpaces.spoon/tree/main#same-window-on-more-than-one-mspace).

Clicking EnhancedSpaces' icon in the menu bar, a menu like this is shown:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/menu1.png' width='200'>


`mSpaces` is for switching to another mSpace:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/menu2.png' width='200'>


`Swap`, as its name implies, is for swapping two windows, which means that they adopt each other's positions and sizes:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/menu_swap.png' width='380'>


The next entry in the menu shows the currently active window (in case there is no active window, for example, when you're on an empty mSpace, this entry is empty by design); here you can toggle the references of the window; more about this feature in the section [Same Window on More Than One mSpace](https://github.com/franzbu/EnhancedSpaces.spoon/tree/main#same-window-on-more-than-one-mspace)).

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/menu3.png' width='200'>


Selecting `Send Window` you see a list of all windows on the current mSpace and the mSpaces you can send each of the windows to:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/menu4.png' width='350'>


Selecting `Get Windows` you see a list of all open windows that are not on your current mSpace, and by selecting one, it is moved to the current mSpace.

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/menu5.png' width='300'>


It is also possible to use popup menus; more about that feature in the section [Additional Features - Popup Menus](https://github.com/franzbu/EnhancedSpaces.spoon/tree/main#popup-menus)

For additional functionality there is the possibility for using modifier keys with your menus, for example, for creating references of a window on all mSpaces at once, or for tagging along with a window when sending it to another mSpace; more about that feature in section [Advanced Menu Features](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#advanced-menu-features).

There you can also see how to change the menu entries, for example, to your preferred language. Additionally, you can see how to include Hammerspoon's menu into EnhancedSpaces', which has the additional benefit of making Hammerspoon's menu redundant, i.e., you can then remove it from your menu bar.


## Keyboard Shortcuts
You can use Control (`ctrl`) - in case you're interested in an elegant alternative in the form of a hyper key, see section [Notes - Hyper Key](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#hyper-key) - and `s` to cycle through your mSpaces. To cycle in reverse order, press `ctrl` and `a`. To move the active window to the mSpace on the left (right) and switch there alongside with the window, press `ctrl` and `q` (`w`); to move the window while staying on the current mSpace press `ctrl` and `d` (`f`).

The lines below represent the default setup, and you don't need to add them to your `init.lua` unless you want to make changes:

``` lua
  modifierMS = { 'ctrl' }, -- default: { 'ctrl' }
  modifierMSKeys = {
    'a', -- cycle through mSpaces; default: 'a'
    's', -- cycle through mSpaces (other direction); default: 's'
    'd', -- send active window to left mSpace; default: 'd'
    'f', -- send active window to right mSpace; default: 'f'
    'q', -- send active window to left mSpace and switch there; default: 'q'
    'w', -- send active window to right mSpace and switch there; default: 'w'
  },
```

In case you want to disable this hotkey, change the line above as follows:
``` lua
  modifierMS = { '' }, -- default: { 'ctrl' }
```

When changing modifiers, make sure that you substitute them with other modifiers such as { 'cmd' }, { 'alt' }, { 'ctrl' }, { 'shift' } and combinations of modifiers, e.g., { 'alt', 'ctrl' }.

Just in case it is not entirely clear where to add these lines or future modifications to your file `init.lua`:

``` lua
local EnhancedSpaces = hs.loadSpoon('EnhancedSpaces')
EnhancedSpaces:new({
  --  ______________ modifications to EnhancedSpaces below this line ______________

  mSpaces = { '1', '2', '3', 'E', 'T' }, -- default: { '1', '2', '3' }
  startmSpace = 'E', -- default: 2

  modifierMS = { 'ctrl' }, -- default: { 'ctrl' }
  modifierMSKeys = {
    'a', -- cycle through mSpaces; default: 'a'
    's', -- cycle through mSpaces (other direction); default: 's'
    'd', -- send active window to left mSpace; default: 'd'
    'f', -- send active window to right mSpace; default: 'f'
    'q', -- send active window to left mSpace and switch there; default: 'q'
    'w', -- send active window to right mSpace and switch there; default: 'w'
  },


  --  ______________ modifications to EnhancedSpaces above this line ______________
})
```

The order of the modifications is entirely up to you.

### Switch Directly to Any mSpace
For switching directly to any mSpace, press the Option key (`alt`) and the key for your mSpace, for example, `3`.

As before, the line below represents the default setup, and you don't need to add it to your `init.lua` unless you want to make changes:

``` lua
  modifierSwitchMS = { 'alt' }, -- default: { 'alt' }
```

In case you want to disable this hotkey, change the line above as follows:
``` lua
  modifierSwitchMS = { '' }, -- default: { 'alt' }
```

### Move Windows Directly to Any mSpace
For moving a window to another mSpace, press `alt-ctrl` and the key for the target mSpace.

As before, the line below represents the default setup, and you don't need to add it to your `init.lua` unless you want to make changes:

``` lua
  modifierMoveWinMSpace = { 'alt', 'ctrl' }, -- default: { 'alt', 'ctrl' }
```

In case you want to disable this hotkey, change the line above as follows:
``` lua
  modifierMoveWinMSpace = { '' }, -- default: { 'alt', 'ctrl' }
```

### Same Window on More Than One mSpace
This section is about showing the same window on more than one mSpace, also known as 'sticky window'. 

To unlock the full potential of mSpaces, it is helpful to understand the underlying philosophy: Each mSpace is a representation of your windows rather than just a space containing them - or, in other words, an mSpace can be understood as a set of symbolic links to as many of your open windows as you want. 

Due to this approach, you can, for instance, have two mSpaces with the same windows in different sizes and positions, or you can have the same Notes, Calendar, Finder or Safari window on two, three, or all your mSpaces.
  
To create a reference of a window via keyboard shortcut (you've already seen how to do this via menu), press the `ctrl-shift` modifiers and additionally press the key corresponding to the target mSpace, for instance, `3`. 

As before, the following line represents the default modifier keys, and you don't need to add it to your `init.lua` unless you want to apply changes:

``` lua
  modifierReference = { 'ctrl', 'shift' }, -- default: { 'ctrl', 'shift' }
```


In case you want to disable this hotkey, change the line above as follows:
``` lua
  modifierReference = { '' }, -- default: { 'ctrl', 'shift' }
```

To delete a reference, press `modifierReference` and `0`. In case you're dereferencing, i.e., delete the reference of, the last representation of a window on your mSpaces, the window gets minimized.

In case you'd like to change the key for dereferencing a window, for example, if you want to add an mSpace entitled '0', you can add the following line to your `init.lua` and change it to your liking:

``` lua
  deReferenceKey = '0', -- default: '0'

```

### Switching Between Windows
Apart from switching between all of your open windows, for which you can continue using macOS' integrated window switcher (Command-Tab) or the third party switcher of your choice, such as [AltTab](https://alt-tab-macos.netlify.app/), additional possibilities have been implemented in EnhancedSpaces for window-switching, namely (1) switching between the windows on the current mSpace and (2) switching between references of windows ('sticky windows').

#### Switching between Windows of Current mSpace
For switching between the windows of your current mSpace, press `alt` and `tab`. 

As before, the lines below represent the default setup, and you don't need to add them to your `init.lua` unless you prefer different shortcuts:


``` lua
  -- keyboard shortcuts for switching between windows on current mSpace and between references
  modifierSwitchWin = { 'alt' }, -- default: { 'alt' }
  modifierSwitchWinKeys = { 'tab', 'escape' }, -- default: { 'tab', 'escape' }
```

For cycling through the windows of your current mSpace in reverse order, additionally press `shift`.

In case you want to disable this hotkey, change the line above as follows:
``` lua
  modifierSwitchWin = { '' }, -- default: { 'alt' }
```


You can also make two windows swap places using keyboard shortcuts; more about this feature in the section [Swapping Windows](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#swapping-windows).


#### Switching between References of Windows
For switching between the references of a window ('sticky windows'), press `alt` and `escape`. In case you prefer a different key, change the second element in the table `modifierSwitchWinKeys` (see above).


## Moving and Resizing Windows:
With EnhancedSpaces you can automatically resize and position the windows on your mSpaces according to a dynamically changing grid size. 


### Automatic Resizing and Positioning - Keyboard
The following lines show the default keyboard shortcuts for the automatic resizing and positioning of windows.

As before, you don't need to add these lines to your `init.lua` unless you want to apply changes. 

``` lua
  modifierSnap1 = { 'cmd', 'alt' }, -- default: { 'cmd', 'alt' }
  modifierSnap2 = { 'cmd', 'ctrl' }, -- default: { 'cmd', 'ctrl' }
  modifierSnap3 = { 'cmd', 'shift' }, -- default: { 'cmd', 'shift' }
```

In case you would like to disable EnhancedSpaces' window manager because you manage your windows manually or prefer using another window manager, change the lines as follows:

``` lua
  modifierSnap1 = { '' }, -- default: { 'cmd', 'alt' }
  modifierSnap2 = { '' }, -- default: { 'cmd', 'ctrl' }
  modifierSnap3 = { '' }, -- default: { 'cmd', 'shift' }
```

To resize and move the active window into a 2x2 grid position, use `modifierSnap1` (default the Command and Option keys) and numbers `1-8`. 

To resize and move the active window into a 3x3 grid position, use `modifierSnap2` and numbers `1-9`, additionally `0`, `o`, and `p`. 

`modifierSnap3` also uses a 3x3 grid with different sizes and positions, see '3x3 Grid - Additional Window Sizes' below.

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
Here, the pre-defined positions and sizes of the windows are as follows (descriptions might be tricky; so simply try them out):

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

As has been mentioned, these keyboard shortcuts are fully customizable. Let's first have a look at the default setup:


``` lua
  modifierSnapKeys = {
    -- modifierSnapKey1
    {
      { 'a1', '1' }, 
      { 'a2', '2' }, 
      { 'a3', '3' }, 
      { 'a4', '4' }, 
      { 'a5', '5' }, 
      { 'a6', '6' }, 
      { 'a7', '7' }, 
      { 'a8', '8' },
     },

    -- modifierSnapKey2
    { 
      { 'b1', '1' }, 
      { 'b2', '2' }, 
      { 'b3', '3' }, 
      { 'b4', '4' }, 
      { 'b5', '5' }, 
      { 'b6', '6' }, 
      { 'b7', '7' }, 
      { 'b8', '8' }, 
      { 'b9', '9' }, 
      { 'b10', '0' }, 
      { 'b11', 'o' }, 
      { 'b12', 'p' },
     },

    -- modifierSnapKey3
    { 
      { 'c1', '1' }, 
      { 'c2', '2' }, 
      { 'c3', '3' }, 
      { 'c4', '4' }, 
      { 'c5', '5' }, 
      { 'c6', '6' }, 
      { 'c7', '7' }, 
      { 'c8', '8' }, 
      { 'c9', '9' }, 
      { 'c10', '0' }, 
      { 'c11', 'o' }, 
      { 'c12', 'p' },
     },
   },
```

In case you would like to make changes, you can combine any of the three modifiers `modifierSnap1`, `modifierSnap1`, and `modifierSnap1` with any of the scenarios.

This is best shown by means of an example: Let's assume that you just need windows to snap into three different grid positions:
- (1) right half of screen -> 'a2'
- (2) right middle ninth of screen -> 'b11'
- (3) middle third, upper two cells -> 'c5'

Let's further assume that you would like to use `modifierSnap1` with the keys `j`, `k`, and `l`, then these would be the lines to add to your `init.lua`:

``` lua
  modifierSnapKeys = {
    -- modifierSnapKey1
    {
      { 'a2', 'j' },
      { 'b11', 'k' },
      { 'c5', 'l' },
    },

    -- modifierSnapKey2
    {
    },

    -- modifierSnapKey3
    {
    },
  },
```
As you can see, `modifierSnapKey2` and `modifierSnapKey3` are not used and are therefore empty.

Now, by pressing `modifierSnapKey1` and `j`, for example, the active window snaps into the right half of the screen.


## Using Mouse/Trackpad

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/demo2.gif' />

Similar to many operations, at times it can be simpler and faster if you use both your keyboard and pointing device at the same time. Thus EnhancedSpaces provides an alternative by enabling the use of a pointing device whenever it has the potential of being beneficial. 

### Move Windows to Adjacent mSpaces
You can also use your pointing device to move a window to an adjacent mSpace by pressing the Option (`alt`) or Control (`ctrl`) key and dragging 80 percent or more of the window beyond the left or right screen border. If you release the modifier key before releasing the mouse button, the window is moved while you stay on the current mSpace, otherwise you switch to the mSpace alongside with the window. 

As per default, `modifier1` uses the same modifier key as `modifierMS` and `modifier2` the same as `modifierMoveWinMSpace`. They don't interfere; however, in case you prefer to change these pointing device modifiers, you can add the following lines to your `init.lua` and adjust them to your liking:

``` lua
  -- pointing device modifiers
  modifier1 = { 'alt' }, -- default: { 'alt' }
  modifier2 = { 'ctrl' }, -- default: { 'ctrl' }
```

### Using Mouse or Trackpad for Moving and Resizing Windows
#### Manual Moving and Positioning
To make the process of moving windows easier than the usual clicking the title bar (which you're still free to do), hold down `modifier1` or `modifier2`, position your cursor in any area within the window, click the left mouse button, and drag the window. If a window is dragged up to 10 percent of its width (left and right borders of screen) or its height (bottom border) outside the screen borders, it will automatically snap back within the borders of the screen. If the window is dragged beyond this 10-percent-limit, things are getting interesting because then window management with automatic resizing and positioning comes into play.

#### Automatic Resizing and Positioning - Mouse or Trackpad
For automatic resizing and positioning of a window, you simply move between 10 and 80 percent of the window beyond the left, right, or bottom borders of your screen while pressing `alt` or `ctrl`. 

As long as windows are resized - or moved within the borders of the screen -, it makes no difference whether you use `modifier1` or `modifier2`. However, once a window is moved beyond the screen borders, different positioning and resizing scenarios are called into action; they are as follows:

* modifier1 (`alt`, unless changed): 
  * If windows are moved beyond the left (right) borders of the screen: Imagine your screen border divided into three sections: if the cursor crosses the screen border in the middle section, the window snaps into the left (right) half of the screen. Crossing the screen border in the upper and lower sections, the window snaps into the respective quarters of the screen.
  * If windows are moved beyond the bottom border of the screen: Again, imagine your bottom screen border divided into three sections: if the cursor crosses the screen border in the middle section, the window snaps into full screen. Crossing the screen border in the left or right sections, the window snaps into the respective halves of the screen.

* modifier2 (`ctrl`, unless changed): 
  * The difference to `modifier1` is that your screen has an underlying 3x3 grid. This means that windows snap into the left third of the 3x3 grid when dragged beyond the left screen border and into the right third when dragged beyond the right screen border. If `ctrl` is released before the left mouse button, the window will snap into the middle column.
 
* The moment dragging of a window starts, indicators will appear around the borders of the screen to guide you. For changing the appearance of the indicators, see section [Additional Features - Change Size, Color, and Opacity of Grid Indicators](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#change-size-color-and-opacity-of-grid-indicators).

- Additional feature: If you drag a window beyond the bottom border of the screen and `modifier1` or `modifier2` is released before the left mouse button, the window will be minimized.


## Additional Features
### Open Windows in Pre-Arranged mSpaces
If you want EnhancedSpaces to automatically move windows to specific mSpaces, add the following to your `init.lua`: 

``` lua
  openAppMSpace = {
    { 'Google Chrome', '2' },
    { 'Microsoft To Do', '3' },
    { 'Safari', '2' },
    { 'Email', 'E' },
  }, -- default: nil
```

The way applications are assigned to certain mSpaces is self-explanatory. To get the names of the applications of currently open windows, you can run the following command in Hammerspoon's Console:

``` lua
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

In case you would also like to pre-define the position of the window, you can add that information as follows:

``` lua
  openAppMSpace = {
    { 'Google Chrome', '2', 'a1' },
    { 'Microsoft To Do', '3', 'a2' },
    { 'Safari', '2', 'a2' },
    { 'Email', 'E' },
  }, -- default: nil
```

'a1', for example, represents the left half of your screen, 'a2' the right half of your screen. To get the entire list of possible scenarios, see section [Automatic Resizing and Positioning - Keyboard](https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/README.md#automatic-resizing-and-positioning---keyboard).


You have the further option to set a different than the standard padding between a window and the border and between windows; you can add that information as follows:

``` lua
  openAppMSpace = {
    { 'Google Chrome', '2', 'a1', 30, 20 },
    { 'Microsoft To Do', '3', 'a2' },
    { 'Safari', '2', 'a2', 30, 20 },
    { 'Email', 'E' },
  }, -- default: nil
```

In the scenario above, Google Chrome and Safari are placed in the left and right halves of mSpace `2` with a gap of 30 to the screen borders and of 20 between the two windows.


### Swapping Windows
Pressing `Ctrl` and `Escape`, your active window swaps places with another window of your choice. In case you'd like to change the keys, add the following lines to your `init.lua` and adjust them to your liking:

``` lua
  swapModifier = { 'ctrl' }, -- default: { 'ctrl' }
  swapKey = 'escape', -- default: 'escape'
```

For disabling this hotkey, add the following line to your `init.lua`:

``` lua
  swapModifier = { '' },  -- default: { 'ctrl' }
```

By default, the focus stays with the same window; in case you prefer the focus to switch to the other window (and thus remain in the same position), add the following line to your `init.lua`:

``` lua
  swapSwitchFocus = true, -- default: false

```

### Changing Appearance of Switcher
For changing the appearance of the switcher for cycling through the windows of the current mSpace when either switching or swapping windows, add the following lines to your `init.lua` and adjust the values according to your preferences:

``` lua
  switcherConfig = { 
    textColor = { 0.9, 0.9, 0.9 }, -- default: { 0.9, 0.9, 0.9 }
    fontName = 'Lucida Grande', -- default: 'Lucida Grande'
    textSize = 16, -- in screen points; default: 16
    highlightColor = { 0.8, 0.5, 0, 0.8 }, -- highlight color for the selected window; default: { 0.8, 0.5, 0, 0.8 }
    backgroundColor = { 0.3, 0.3, 0.3, 0.5 }, -- default: { 0.3, 0.3, 0.3, 0.5 }
    onlyActiveApplication = false, -- only show windows of the active application; default: false
    showTitles = true, -- show window titles; default: true
    titleBackgroundColor = { 0, 0, 0 }, -- default: { 0, 0, 0 }
    showThumbnails = true, -- show window thumbnails; default: true
    selectedThumbnailSize = 284, -- size of window thumbnails in screen points; default: 284
    showSelectedThumbnail = true, -- show a larger thumbnail for the currently selected window; default: true
    thumbnailSize = 112, -- default: 112
    showSelectedTitle = false, -- show larger title for the currently selected window; default: false
  },
```

### Custom Wallpapers
For selecting an individual wallpaper for each mSpace, add the following to your `init.lua`: 

``` lua
  -- individual wallpaper for each mSpace
  customWallpaper = true, -- default: false
```

Add the wallpapers you would like to use in the format `jpg` to the folder `~/.hammerspoon/Spoons/EnhancedSpaces.spoon/wallpapers/`, and name each file after the corresponding mSpace, for example, `1.jpg` or `e.jpg`. If you name one file `default.jpg`, that wallpaper will be used whenever there is an mSpace with no corresponding wallpaper.


### Padding
In case you would like to change the gap in between the windows and/or between the windows and the screen border, add the following lines with values to your liking to your `init.lua`:

``` lua
  -- padding between window borders and screen borders
  outerPadding = 5, -- default: 5
  -- padding between window borders
  innerPadding = 5, -- default: 5
```

### Change Size, Color, and Opacity of Grid Indicators

In case you would like to change the size, color and/or opacity of the grid indicators, add the following line to your `init.lua`, and alter the values according to your liking. Apart from the width, values between 0 and 1 are possible:

``` lua
  -- change grid indicators:
    gridIndicator = { 
      20, -- width; default: 20
      1, -- red; default: 1
      0, -- green; default: 0
      0, -- blue; default: 0
      0.33 -- opacity; default: 0.33
    },  
```

### Popup Menus
Optionally, you can open a popup menu at the position of your pointing device; this can be enabled by adding the following lines to `init.lua` (as popup menus are not enabled by default in EnhancedSpaces, these lines always need to be added in case you want to use a popup menu in EnhancedSpaces, not only if you would like to make changes to the keyboard shortcuts):

``` lua
  -- popup menu
  popupModifier = { 'cmd', 'alt', 'ctrl' }, -- default: nil
  mbMainPopupKey = 'e', -- default: nil
  mbSendPopupKey = 'r', -- default: nil
  mbGetPopupKey = 't', -- default: nil
  mbSwapPopupKey = 'y', -- default: nil
```

`popupModifier - mbMainPopupKey` opens the main popup menu:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/popup3.png' width='200'>


With `popupModifier - mbSendPopupKey` the menu 'Send Windows' pops up:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/popup2.png' width='330'>


Likewise, with `popupModifier - mbGetPopupKey` 'Get Windows' pops up:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/popup1.png' width='330'>


Likewise, with `popupModifier - mbSwapPopupKey` the menu for swapping two windows pops up:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/popup_menu_swap.png' width='400'>



If you set any of the four keys for the according popup menus to `nil` (or don't include them in your `init.lua` in the first place), consequently they are not available. `popupModifier` needs to be set for either of the popup menus to be shown.


## Advanced Menu Features
It is possible to use modifier keys to access additional features. Below you can see the default modifiers and their functions; you don't need to add these lines to your `init.lua` unless you want to make changes:

``` lua
  -- menu: modifier keys to unlock additional features
  menuModifier1 = { 'alt' }, -- default: { 'alt' }
  menuModifier2 = { 'ctrl' }, -- default: { 'ctrl' }
  menuModifier3 = { 'alt', 'ctrl' }, -- default: menuModifier1 and menuModifier1
```

`menuModifier3` by default combines `menuModifier1` and `menuModifier2`, in other words, `menuModifier3` means pressing `menuModifier1` and `menuModifier2` at the same time. 

Below you can see what effect the modifier keys have; the first menu entry, 'mSpaces', reveals its whole potential without any additional modifier keys and is therefore not listed:

#### Menu Item `Swap`
- no modifier: swap windows, which includes swapping sizes and positions
- menuModifier1: window chosen first snaps into position 'a1' (left half of screen), second window snaps into 'a2'
- menuModifier2: window chosen first snaps into position 'a3', second window snaps into 'a4'
- menuModifier3: window chosen first snaps into position 'a5', second window snaps into 'a6'

#### Menu Item `CURRENTLY ACTIVE WINDOW`
- no modifier: toggle reference of active window on selected mSpace; if all mSpaces end up unchecked, the window is minimized
- menuModifier1: delete all reference except for the selected mSpace
- menuModifier2: put references of window on all mSpaces
- menuModifier3: same as `menuModifier1`, additionally tagging along with the window

#### Menu Item `Send Window`
- no modifier: send reference of window to selected mSpace; references on other mSpaces remain unaffected
- menuModifier1: send window to selected mSpace while keeping a reference of the window on the current mSpace
- menuModifier2: put references of window on all mSpaces
- menuModifier3: same as `menuModifier1`, additionally tagging along with the window

#### Menu Item `Get Window`
- no modifier: move selected window to current mSpace
- menuModifier1: create reference of selected window on current mSpace; references on other mSpaces remain unaffected
- menuModifier2: create reference of selected window on all mSpaces

### Changing Menu Titles
For changing the menu titles, for example, to have them in your preferred language, you can add the following line to your `init.lua`; this is an example for changing the menu tiles to German:

``` lua
-- default: { swap = 'Swap', send = 'Send Window', get = 'Get Window', help = 'Help', about = 'About', hammerspoon = 'Hammerspoon' }
menuTitles = {
  swap = 'Vertauschen',
  send = 'Senden',
  get = 'Holen',
  help = 'Hilfe',
  about = 'Über',
  hammerspoon = 'Hammerspoon'
},

```

With the entries above, you get the following menu:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/menu6.png' width='200'>

As you can see, the last entry from the list above, `hammerspoon = 'Hammerspoon' isn't visible in the menu; that only happens if the integration of Hammerspoon's menu into EnhancedSpaces' is enabled; find out directly below how to do that.

### Including Hammerspoon's Menu in EnhancedSpaces'
For including Hammerspoon's menu in EnhancedSpaces', add the following to your `init.lua`: 

``` lua
  -- enable Hammerspoon's menu in EnhancedSpaces'
  hammerspoonMenu = true, -- default: false
```

This results in the following addition to EnhancedSpaces' menu:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/menu_hs2.png' width='360'>

This also means that Hammerspoon's menu icon in the menu bar becomes redundant and can be disabled. To do so, uncheck 'Show menu icon' in Hammerspoon's preferences.


#### Changing Hammerspoon's Menu Titles
For changing the menu titles regarding Hammerspoon, for example, to show them in your preferred language, you can add the following to your `init.lua`; this is an example for displaying the menu in German:

``` lua
-- default: { reload = 'Reload Config', config = 'Open Config', console = 'Console', preferences = 'Preferences', about = 'About Hammerspoon', update = 'Check for Updates...', relaunch = 'Relaunch Hammerspoon', quit = 'Quit Hammerspoon' }
hammerspoonMenuItems = {
  reload = 'Konfiguration neu laden',
  config = 'Konfiguration öffnen',
  console = 'Konsole',
  preferences = 'Einstellungen',
  about = 'Über Hammerspoon',
  update = 'Nach Updates suchen',
  relaunch = 'Hammerspoon neu starten',
  quit = 'Hammerspoon beenden'
},
```

This is the resulting menu:

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/menu_hs2_ger.png' width='360'>

## Experimental Features
Features listed here have undergone some testing and are supposed to work as expected; however, as they have yet to be thoroughly tested, the occational hiccup should not be entirely unexpected. 

Furthermore, as these features aren't final yet, there might still be changes to its implementation, so if one of these features stops working after an update, please return to this documentation in order to implement the necessary adjustments to your `init.lua`.

### mSpace Control

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/overview_frame.jpg' width=700 />

mSpace Control shows a preview of all or - if you so choose - a selection of your mSpaces and enables you to switch between them by cycling through them via keyboard shortcut or by clicking on them. To enable mSpace Control, add the following lines to your `init.lua`:

``` lua
  -- mSpace Control
  mSpaceControlModifier = { 'alt' }, -- default: { '' }
  mSpaceControlKey = 'a', -- default: 'a'
```

To cycle through your mSpaces, keep `mSpaceControlModifier` pressed - or press it again while mSpace Control is open - and use `mSpaceControlKey` for cycling. To cycle through your mSpaces in reverse order, additionally press `shift`.

To change thickness, color and/or opacity of the frame that highlights the current mSpace, add the following to your `init.lua`; apart from the frame thickness, values between 0 and 1 are possible:

``` lua
  -- hightlight currently active mSpace
  mSpaceControlFrame = { 
    3, -- frame thickness; default: 3
    1, -- red; default: 1
    0, -- green; default: 0
    0, -- blue; default: 0
    1, -- opacity; default: 1
  },
```

By default, mSpace Control shows all your mSpaces in their original order. In case you'd like to exclude mSpaces from mSpace Control or change their order, add the following to your `init.lua` and make the changes you like:

``` lua
  -- exclude mSpaces and/or change their order of appearance
  mSpaceControlShow = { 'E', '3', 'T', '2' },
```


In case you'd like to change the padding, color and/or opacity of mSpace Control, add the following to your `init.lua`, and adjust the values to your liking. Apart from the padding (be aware that due to the fixed aspect ratio of the previews of the mSpaces, the values for the outer and inner padding are relative rather than absolute), values between 0 and 1 are possible:

``` lua
  -- configure mSpace Control
  mSpaceControlConfig = { 
    60, -- outer padding; default: 60
    60, -- inner padding; default: 60
    0, -- red; default: 0
    0, -- green; default: 0
    0, -- blue; default: 0
    0.9, -- opacity; default: 0.9
  },
```


### Applications To Be Left Alone by EnhancedSpaces
Any operating system has dialogs and windows of a more temporary nature, such as Spotlight or Alfred, that are dealt with differently than standard 'persistent' application windows. Hammerspoon's list of such windows and dialogs by its very nature cannot be comprehensive, as new applications are being developed. 

Should you encounter windows that behave erratically such as claiming focus when they shouldn't, you can add these applications to the list of windows to be left alone by adding the following lines to the configuration of EnhancedSpaces in your `init.lua`:

``` lua
  -- window_filter.lua: windows to disregard
  SKIP_APPS_TRANSIENT_WINDOWS = {
    'Spotlight', 'Notification Center', 'loginwindow', 'ScreenSaverEngine', 'PressAndHold',
    'PopClip','Isolator', 'CheatSheet', 'CornerClickBG', 'Moom', 'CursorSense Manager',
    'Music Manager', 'Google Drive', 'Dropbox', '1Password mini', 'Colors for Hue', 'MacID',
    'CrashPlan menu bar', 'Flux', 'Jettison', 'Bartender', 'SystemPal', 'BetterSnapTool', 'Grandview', 'Radium',
    'MenuMetersApp', 'DemoPro', 'DockHelper', 'Maccy', 'Albert', 'Alfred',
  },
```
As has been hinted at, the above list is Hammerspoon's, extended with a few others; they are 'DockHelper', 'Maccy', 'Albert', and 'Alfred'.

Adding your own applications is as easy as adding their names to the list ('application name' followed by a comma). You are advised to keep the default entries.

To get the names of open applications, you can use the method referred to in [Additional Features -
Open Windows in Pre-Arranged mSpaces](https://github.com/franzbu/EnhancedSpaces.spoon#open-windows-in-pre-arranged-mspaces)

The list above represents the default setup, and you only need to add it to your `init.lua` on case you want to extend it. 

### Startup Commands
In case you would like EnhancedSpaces to execute commands at startup, you can add those commands do your `init.lua`:

``` lua
  startupCommands = {
    'command 1',
    'command 2',
    'command 3',
  },
```
Below is an example for starting [JankyBorders](https://github.com/FelixKratz/JankyBorders):

``` lua
  startupCommands = {
    '/opt/homebrew/bin/borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0 &',
  }
```

### Manual Resizing
Similar to manual moving, manual resizing of windows can be initiated by positioning the cursor in any area of a window. Be aware, though, that windows of certain applications can behave in a sluggish way when being resized. 

In order to enable manual resizing, add the following to your `init.lua`:

``` lua
  -- enable resizing:
  resize = true, -- default: false
```

To manually resize a window, hold your `modifier1` or `modifier2` down, then click the right mouse button in any part of the window and drag the window.

To have the additional possibility of precisely resizing windows horizontally-only or vertically-only, 30 percent of the window (15 precent left and right of the middle of each window border) is reserved for horizontal-only and vertical-only resizing. The size of this area can be adjusted; for more information see below.

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/demo1.gif' />

At the center of the window there is an area (M) where you can also move the window by pressing the right mouse button. 

<img src='https://github.com/franzbu/EnhancedSpaces.spoon/blob/main/doc/resizing.png' width='200'>


#### Manual Resizing of Windows - Margin

You can change the size of the area of the window where the vertical-only and horizontal-only resizing applies by adjusting the option `margin`. The standard value is 0.3, which corresponds to 30 percent. Changing it to 0 would result in deactivating this option, changing it to 1 would result in making resizing this way impossible.

``` lua
  -- adjust the size of the area with vertical-only and horizontal-only resizing:
  margin = 0.2, -- default: 0.3
```

## Notes

### Mission Control

For Apple's Mission Control (F3) to show windows on mSpaces adequately, enable `System Settings` - `Desktop & Dock` - `Group windows by application`.

### Hyper Key

EnhancedSpaces (and other applications for that matter) can benefit from setting the Caps Lock key up as so-called hyper key, which basically means that you get an additional modifier key, as - due to the impracticality of pressing four modifier keys at once - you would hardly be tempted to use such a combination otherwise. 

Among others, you can use the application [Karabiner Elements](https://karabiner-elements.pqrs.org/) for the creation of your hyper key.

#### Option 1

In this scenario, the original function of the Caps Lock key remains untouched. Using the aforementioned Karabiner Elements, in 'Settings - Complex Modifications' you can click 'Add predefined rule' and search for 'Caps Lock → Hyper Key (⌃⌥⇧⌘) (Caps Lock if alone)'. As the name suggests, with this modification you keep the original function of Caps Lock when it is pressed and released, while it also functions as hyper key when another key is pressed before Caps Lock is released.

#### Option 2

As an alternative to option one, I present my setup: Caps Lock's functionality is further extended by using a single press (without any other keys) of Caps Lock as simulating pressing the hyper key and spacebar keys, which in turn can be used to open an application such as Alfred, which is what I use this for. 

The original purpose of Caps Lock is still available; you can trigger that function by pressing the Shift (Command, Option, and Control work likewise) and Caps Lock keys simultaneously.

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

Now you can assign your newly created `hyper key` to any modifiers in EnhancedSpaces, for example, `modifierMS`:


``` lua
  modifierMS = { 'cmd', 'alt', 'ctrl', 'shift' }, -- default: { 'ctrl' }
```
Now, pressing `Caps Lock` and `a`, for instance, switches to the mSpace on the left.


### Uninstalling EnhancedSpaces

In case you have used the option `openAppMSpace`, disable or remove that section from your `init.lua` and (re)start EnhancedSpaces to move all open windows to your main mSpace, which after disabling or uninstalling EnhancedSpaces will automatically become your default space.

``` lua
  --[[
  openAppMSpace = {
    {'Google Chrome', '2', 'a1'},
    {'Code', '2', 'a2'},
    {'Microsoft To Do', 'T'},
    {'Email', 'E'},
  },
  ]]
```

As final step, stop Hammerspoon, delete the folder `EnhancedSpaces.spoon` in `~/.hammerspoon/Spoons/` and remove the corresponding section from your `init.lua`.
