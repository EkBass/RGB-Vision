' menu.bas
' RGB Vision — Main Menu Module
' Kristian Virtanen, 2026
' MIT License

LET MENU_Y0# = 28
LET MENU_Y1# = 100
LET MENU_Y2# = 172
LET MENU_Y3# = 244
LET MENU_Y4# = 316
LET MENU_HW#     = 100
LET MENU_HH#     = 31
LET MENU_SCALE#  = 0.5
LET MENU_DRAW_X# = 220
LET MENU_CX#     = 320

LET menuBestTime$ = 1800000

GOTO [menu:moduleEnd]

' ============================================================
[menu:init]
    DIM menuBtn$
    menuBtn$("bg")       = LOADIMAGE("assets/img/menu.png")
    menuBtn$("new_game") = LOADIMAGE("assets/img/button_new_game.png")
    menuBtn$("sound_on") = LOADIMAGE("assets/img/button_sound_on.png")
    menuBtn$("sound_off")= LOADIMAGE("assets/img/button_sound_off.png")
    menuBtn$("music_on") = LOADIMAGE("assets/img/button_music_on.png")
    menuBtn$("music_off")= LOADIMAGE("assets/img/button_music_off.png")
    menuBtn$("manual")   = LOADIMAGE("assets/img/button_manual.png")
    menuBtn$("exit")     = LOADIMAGE("assets/img/button_exit.png")

    SCALESHAPE menuBtn$("new_game"),  MENU_SCALE#
    SCALESHAPE menuBtn$("sound_on"),  MENU_SCALE#
    SCALESHAPE menuBtn$("sound_off"), MENU_SCALE#
    SCALESHAPE menuBtn$("music_on"),  MENU_SCALE#
    SCALESHAPE menuBtn$("music_off"), MENU_SCALE#
    SCALESHAPE menuBtn$("manual"),    MENU_SCALE#
    SCALESHAPE menuBtn$("exit"),      MENU_SCALE#

    LET menuMusic$ = LOADSOUND("assets/audio/Powerful-Trap.mp3")
    IF musicState$ = true THEN SOUNDREPEAT(menuMusic$)

    LET menuSel$       = 0
    LET menuDone$      = false
    LET menuAction$    = ""
    LET menuClickCool$ = 0
    LET menuBestTime$  = 1800000
RETURN

' ============================================================
[menu:run]
    ' Always load best time fresh from file
    LET menuBestTime$ = 1800000
    IF FileExists("highscore.txt") THEN
        LET gHsSave$ = FileRead("highscore.txt")
        IF HASKEY(gHsSave$("best")) THEN
            menuBestTime$ = VAL(gHsSave$("best"))
        ENDIF
    ENDIF

    LET menuDone$   = false
    LET menuAction$ = ""

    WHILE menuDone$ = false
        LET menuKey$ = INKEY

        IF menuKey$ = KEY_UP# THEN
            menuSel$ = menuSel$ - 1
            IF menuSel$ < 0 THEN menuSel$ = 4
        ENDIF
        IF menuKey$ = KEY_DOWN# THEN
            menuSel$ = menuSel$ + 1
            IF menuSel$ > 4 THEN menuSel$ = 0
        ENDIF
        IF menuKey$ = KEY_ENTER# THEN GOSUB [menu:activate]
        IF menuKey$ = KEY_ESC#   THEN menuAction$ = "exit" : menuDone$ = true

        SCREENLOCK ON
        GOSUB [menu:draw]
        SCREENLOCK OFF
        SLEEP 16
    WEND
RETURN

' ============================================================
[menu:draw]
    MOVESHAPE menuBtn$("bg"), 0, 0
    DRAWSHAPE menuBtn$("bg")

    MOVESHAPE menuBtn$("new_game"), MENU_DRAW_X#, MENU_Y0# - MENU_HH#
    DRAWSHAPE menuBtn$("new_game")

    IF soundState$ = true THEN
        MOVESHAPE menuBtn$("sound_on"),  MENU_DRAW_X#, MENU_Y1# - MENU_HH#
        DRAWSHAPE menuBtn$("sound_on")
    ELSE
        MOVESHAPE menuBtn$("sound_off"), MENU_DRAW_X#, MENU_Y1# - MENU_HH#
        DRAWSHAPE menuBtn$("sound_off")
    ENDIF

    IF musicState$ = true THEN
        MOVESHAPE menuBtn$("music_on"),  MENU_DRAW_X#, MENU_Y2# - MENU_HH#
        DRAWSHAPE menuBtn$("music_on")
    ELSE
        MOVESHAPE menuBtn$("music_off"), MENU_DRAW_X#, MENU_Y2# - MENU_HH#
        DRAWSHAPE menuBtn$("music_off")
    ENDIF

    MOVESHAPE menuBtn$("manual"), MENU_DRAW_X#, MENU_Y3# - MENU_HH#
    DRAWSHAPE menuBtn$("manual")

    MOVESHAPE menuBtn$("exit"), MENU_DRAW_X#, MENU_Y4# - MENU_HH#
    DRAWSHAPE menuBtn$("exit")

    ' Highlight selected button
    LET hlCY$ = MENU_Y0# + menuSel$ * 72
    LINE (MENU_DRAW_X# - 4, hlCY$ - MENU_HH# - 4)-(MENU_DRAW_X# + MENU_HW# * 2 + 4, hlCY$ + MENU_HH# + 4), RGB(0,200,0), B

    ' Best time — digits shown next to "BEST TIME:" text in menu.png
    gDigitColor$  = RGB(0, 200, 0)
    gDigitTimeMs$ = menuBestTime$
    gDigitY$      = 400
    GOSUB [game:drawMmSs]
RETURN

' ============================================================
[menu:activate]
    IF menuSel$ = 0 THEN menuAction$ = "new_game" : menuDone$ = true

    IF menuSel$ = 1 THEN
        IF soundState$ = true THEN soundState$ = false ELSE soundState$ = true
    ENDIF

    IF menuSel$ = 2 THEN
        IF musicState$ = true THEN
            musicState$ = false
            SOUNDSTOP(menuMusic$)
        ELSE
            musicState$ = true
            SOUNDREPEAT(menuMusic$)
        ENDIF
    ENDIF

    ' Manual — opens file with default application (no spaces in filename needed)
    IF menuSel$ = 3 THEN
        LET temp$ = SHELL("cmd /c start manual.pdf")
    ENDIF

    IF menuSel$ = 4 THEN menuAction$ = "exit" : menuDone$ = true
RETURN

' ============================================================
[menu:cleanup]
    SOUNDSTOP(menuMusic$)
    REMOVESHAPE menuBtn$("bg")
    REMOVESHAPE menuBtn$("new_game")
    REMOVESHAPE menuBtn$("sound_on")
    REMOVESHAPE menuBtn$("sound_off")
    REMOVESHAPE menuBtn$("music_on")
    REMOVESHAPE menuBtn$("music_off")
    REMOVESHAPE menuBtn$("manual")
    REMOVESHAPE menuBtn$("exit")
    DELARRAY menuBtn$
RETURN

' ============================================================
[menu:moduleEnd]
