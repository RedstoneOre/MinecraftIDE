|![Empty Image](docs/empty.png)|![Minecraft IDE](MinecraftIDE.png)|![Empty Image](docs/empty.png)|
|-|-|-|

[中文(简体)](docs/README.zh-CN.md) [Homepage](.)

# Minecraft IDE
### Edit files just like playing minecraft

## Installation
This project can only be runned on Linux
```sh
git clone https://github.com/RedstoneOre/MinecraftIDE.git

```

## Usage
```sh
cd MinecraftIDE
./mcide
```
See [arguments](docs/arguments/en-US.txt) for argument usage details

## Operation

Use w,a,s,d or arrow keys to move

Use i,j,k,l to move focus

Use e to open/close inventory

Use arrow keys to move cursor in the inventory

use \[ to left click, \] to right click in the inventory

Use 1~9 to select slot in hotbar / swap items with hotbar in the inventory

Use \[ to dig, \] to place/interact

Use q to leave

## Structures

```
#]   #  -
[#   -  #
```
a piston, interact with the `#` to extend
```
#-]  #  -
     |  |
[-#  -  #
```
a extended piston, interact with the `#` to contract
+ one piston can have multiple heads

## Progress

- [x] File Operations
- - [x] Basic file reading (char 0~127 now)
- - [x] Multiple file reading
- - [x] File Saving
- - [x] Multiple file saving
- - [x] Save Reading
- - [x] Save Saving
- - - [ ] Entities Saving
- [x] Arguments Reading
- - [x] Editor
- - [x] Simple Mode
- - [x] Help
- [ ] Editing
- - [x] Map
- - [x] Moving
- - [x] Mining
- - [x] Placing
- - [x] Entities
- - - [x] Support
- - - [x] Item Type
- - - [ ] Battary Type
- - - [x] Creating & Deleting
- - - [ ] Entity Moving
- - [ ] Crafting
- - [ ] Inventory
- - - [x] Support
- - - [x] Displaying
- - - [x] Item Operating
- - - [x] Pick
- - - [ ] Drop
- [ ] Optimize
- - [ ] Multi-threading
- - - [x] Input thread
- - - [x] Async Print
- - - [ ] Entity thread
- - [x] Display Cache
- - [x] Free Headers Including
- [ ] Modding
- - [ ] \(Nothing Done\)
