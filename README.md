# RGB Vision

A tile-based platformer made for **[Jam for All BASIC Dialects #7](https://itch.io/jam/jam-for-all-basic-dialects-7)**.

**Play it:** https://ek-bass.itch.io/rgb-vision  
**Engine:** [BazzBasic](https://ekbass.github.io/BazzBasic/)  
**License:** MIT

**Note:** This repository is archived because I do not plan to develope this anymore after the Jam ends. Source is still usefull and good to play with BazzBasic. Edit it as you wish.

---

## Concept

You navigate dark levels with a small light radius around you. The catch: the world
is split across three RGB vision modes, and no single mode shows everything.

| Mode | Key | What you see |
|------|-----|--------------|
| 🟢 GREEN | Space | Walls, acid tiles, surprise tiles |
| 🔴 RED | Space | Enemies |
| 🔵 BLUE | Space | Coins, mandatory coins, exit |

Cycle modes constantly to survive. Text characters (A–Z, 0–9) in levels are always visible.

## Controls

| Key | Action |
|-----|--------|
| ← → | Move |
| ↑ | Jump |
| Space | Cycle RGB mode |
| ESC | Quit |

---

## Tile Reference

| Tile | Mode | Description |
|------|------|-------------|
| `#` | Green | Wall — solid, impassable |
| `.` | Green | Empty space |
| `!` | Green | Acid — instant death |
| `?` | Green | Surprise tile — triggers a random effect |
| `@` | Red | Enemy — patrols left/right |
| `$` | Blue | Normal coin — points |
| `&` | Blue | Mandatory coin — all must be collected to open exit |
| `+` | Blue | Exit — leads to next level |
| `-` | Blue | Player spawn point |

---

## Surprise Tiles (?)

Surprise tiles look almost identical to normal walls in GREEN mode. Stepping on one
triggers an effect defined per level — a jump scare image, teleport back to spawn,
bonus coins, a forced pause, and more. Each tile triggers only once per visit.

---

## Scoring & Time

- Each coin collected: +10 points
- All 10 levels completed → final time is shown
- Optional coins reduce your final time by 0.2 seconds each
- Best time is saved to `highscore.txt`

---

## Project Structure

| File | Description |
|------|-------------|
| `rgb.bas` | Entry point — screen init, includes, main loop |
| `game.bas` | Game engine: physics, rendering, levels 1–10 |
| `menu.bas` | Main menu |
| `intro.bas` | Cassette-style loading screen |
| `surprises.bas` | Surprise tile effect subroutines |
| `assets/` | Images and audio |

---

## Running the Game

Requires **BazzBasic** (included as `BazzBasic.exe`):

```
bazzbasic.exe rgb.bas
```

Or just double-click `rgb.bas` if BazzBasic is set as the default handler.

Windows x64 only. SDL2.dll and SDL2_mixer.dll are bundled.

---

## Adding Levels

Levels are defined as GOSUB labels in `game.bas`. Each level is a BazzBasic
associative array. Copy an existing level block and edit the rows:

```basic
[level:11]
    Map$("level")       = 11
    Map$("title")       = "My Level"
    Map$("text-color")  = 10
    Map$("bg-sound")    = "assets/audio/mytrack.mp3"
    Map$("surprise-sub")= "[my-surprise]"
    Map$("cols")        = 31
    Map$("rows")        = 21
    Map$("row1")        = "###############################"
    ' ... 20 more rows ...
RETURN
```

Then update `MAX_LEVELS#` at the top of `game.bas`.

---

## Built With

- **[BazzBasic 1.0](https://ekbass.github.io/BazzBasic/)** — BASIC interpreter for .NET 10 with SDL2
- SDL2 + SDL2_mixer for graphics and audio
- Physics engine based on the BazzBasic `platformer_example.bas` demo

---

## License

MIT — see source files for details.  
Kristian Virtanen, 2026
