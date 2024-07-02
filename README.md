# Tabletop Simulator Scripts

currently holds the collections of lua scripts I have been working on.

## Prerequisites

- Python 3 (for build scripts)
- Add [generic-ide-tabletopsimulator](https://github.com/r3gis3r/generic-ide-tabletopsimulator) to your `./build/` directory
  - `TODO` this is a huge mess, but this is the current backbone of the build process.
- IntelliJ IDE with EmmyLint or Luanalysis plugins installed (typechecking)
  - follow the readme of `generic-ide-tabletopsimulator`, especially if you don't want to use IntelliJ

## Roadmap
- [X] write simple Lua scripts
  - [x] Playmat / Deck shuffler script
  - [x] Write-protected card
  - [x] Stamp to lock/unlock editing
  - [ ] Item shop (place a card in three slots, discard to the bottom after a choice is made)
- [ ] Tabletop Save File patcher
  - [ ] deck editor
  - [ ] implement script bundling functionality
  - [ ] deck editor 2.0 (better graphics, composable graphical elements)
- [ ] Git submodules
  - [ ] savefile patcher as a submodule
  - [ ] improve the build process here
  - [ ] PR the TTS types maintainer with updated types
