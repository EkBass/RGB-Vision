' game.bas
' RGB Vision — game engine
' Kristian Virtanen, 2026
' MIT License
' ============================================================
' Called from rgb.bas: GOSUB [game:start]
' Returns when player presses ESC or completes all levels
' ============================================================

' --- Physics (based on platformer_example.bas) ---
LET GAME_TILE#    = 20
LET GAME_GRAV#    = 0.4
LET GAME_JUMP#    = -10
LET GAME_MSPD#    = 3
LET GAME_AIR#     = 2
LET GAME_GFRIC#   = 0.85
LET GAME_AFRIC#   = 0.98
LET GAME_MAXFALL# = 12
LET GAME_PW#      = 0.4
LET GAME_PH#      = 0.8

' --- Map dimensions ---
LET GAME_MW#      = 31
LET GAME_MH#      = 15

' --- Light & modes ---
LET GAME_LIGHT#   = 7
LET GAME_GREEN#   = 0
LET GAME_RED#     = 1
LET GAME_BLUE#    = 2

' --- Enemies ---
LET GAME_ESPD#    = 1.5

' --- Total levels ---
LET MAX_LEVELS# = 10

' --- Init flag (prevents double-loading sounds) ---
LET gameInitDone$ = false

DIM Map$
DIM enemies$
DIM coins$
DIM gHsSave$

GOTO [game:moduleEnd]

' ============================================================
[game:start]
    GOSUB [game:initVars]
    startTime$ = TICKS
    LET gPlayLoop$ = true
    WHILE gPlayLoop$
        GOSUB [game:loadLevel]
        GOSUB [game:loop]
        IF gRunning$ = false THEN
            gPlayLoop$ = false
        ELSEIF gAlive$ = false THEN
            GOSUB [game:showGameOver]
            gPlayLoop$ = false
        ELSEIF gLevelComplete$ = true THEN
            gLevelNum$ = gLevelNum$ + 1
            IF gLevelNum$ > MAX_LEVELS# THEN
                GOSUB [game:showEnding]
                gPlayLoop$ = false
            ENDIF
        ENDIF
    WEND
    GOSUB [game:cleanup]
RETURN

' ============================================================
[game:initVars]
    ' Game logic
    LET gRunning$            = true
    LET gLevelNum$           = 1	' START LEVEL
    LET gAlive$              = true
    LET gLevelComplete$      = false
    LET gScore$              = 0
    LET gTotalOptCoins$      = 0    ' Cumulative optional coins collected
    LET gMandatoryTotal$     = 0
    LET gMandatoryCollected$ = 0
    LET gRgbMode$           = GAME_GREEN#
    LET gSpawnX$            = 2
    LET gSpawnY$            = 2
    LET gMapW$              = GAME_MW#
    LET gMapH$              = GAME_MH#

    ' Player physics
    LET gpx$        = 0
    LET gpy$        = 0
    LET gvx$        = 0
    LET gvy$        = 0
    LET gOnGround$  = 0
    LET gHighestY$  = 0

    ' Camera
    LET gCamX$ = 0
    LET gCamY$ = 0

    ' Input
    LET gKey$ = 0

    ' Physics working variables
    LET gMoveInput$  = 0
    LET gNewX$       = 0
    LET gNewY$       = 0
    LET gLeftEdge$   = 0
    LET gRightEdge$  = 0
    LET gTopEdge$    = 0
    LET gBottomEdge$ = 0
    LET gTestX$      = 0
    LET gTestY$      = 0
    LET gTestYBot$   = 0
    LET gTestYTop$   = 0
    LET gHitLeft$    = 0
    LET gHitRight$   = 0
    LET gHitFloor$   = 0
    LET gHitCeil$    = 0
    LET gTileCh$     = ""

    ' Rendering working variables
    LET gStartX$  = 0
    LET gStartY$  = 0
    LET gEndX$    = 0
    LET gEndY$    = 0
    LET gTileX$   = 0
    LET gTileY$   = 0
    LET gSx$      = 0
    LET gSy$      = 0
    LET gDist$    = 0
    LET gBright$  = 0
    LET gR$       = 0
    LET gGg$      = 0
    LET gBl$      = 0

    ' Enemy loop variables
    LET gEnemyCount$ = 0
    LET gCoinCount$  = 0
    LET eIdx$        = 0
    LET gSurpriseCooldown$ = 0
    LET gSurSubLabel$      = ""
    LET gBgMusic$          = ""
    LET eX$          = 0
    LET eDir$        = 0
    LET nextX$       = 0
    LET nextTileX$   = 0
    LET eTileY$      = 0

    ' Coin loop variables
    LET cIdx$  = 0
    LET cX$    = 0
    LET cY$    = 0

    ' Row scanning
    LET scanRow$ = 0
    LET scanCol$ = 0
    LET scanCh$  = ""

    ' Highscore & ending screen
    LET gBestTime$    = 0
    LET gPrevBestTime$ = 0
    LET gIsNewRecord$ = false
    LET gDigitN$      = 0
    LET gDigitX$      = 0
    LET gDigitY$      = 0
    LET gDigitColor$  = 0
    LET gDigitTimeMs$ = 0
    LET gSeg0$  = 0
    LET gSeg1$  = 0
    LET gSeg2$  = 0
    LET gSeg3$  = 0
    LET gSeg4$  = 0
    LET gSeg5$  = 0
    LET gSeg6$  = 0
    LET gSt$    = 0
    LET gSh$    = 0
    LET gSw$    = 0
    LET gDx2$   = 0
    LET gDy2$   = 0
    LET gDTotalMs$ = 0
    LET gDSecs$    = 0
    LET gDMins$    = 0
    LET gDCenti$   = 0
    LET gDStartX$  = 0
    LET gColX$     = 0

    ' Sounds — loaded once at first run
    IF gameInitDone$ = false THEN
        LET gSndCoin$        = LOADSOUND("assets/audio/coin.mp3")
        LET gSndJump$        = LOADSOUND("assets/audio/jump.mp3")
        LET gSndGameOver$    = LOADSOUND("assets/audio/game-over.mp3")
        LET gSndLevelPassed$ = LOADSOUND("assets/audio/levelPassed.mp3")
    ENDIF

    IF gameInitDone$ = true THEN
        DELARRAY Map$
        DELARRAY enemies$
        DELARRAY coins$
    ENDIF
    DIM Map$
    DIM enemies$
    DIM coins$
    gameInitDone$ = true
RETURN

' ============================================================
[game:loadLevel]
    LET gLevelLabel$ = "[level:" + TRIM(STR(gLevelNum$)) + "]"
    GOSUB gLevelLabel$

    GOSUB [game:scanMap]

    ' Read surprise-sub label into its own variable
    gSurSubLabel$ = ""
    IF HASKEY(Map$("surprise-sub")) THEN gSurSubLabel$ = Map$("surprise-sub")

    GOSUB [game:showLevelTitle]

    ' Place player at spawn
    gpx$         = gSpawnX$
    gpy$         = gSpawnY$
    gvx$         = 0
    gvy$         = 0
    gOnGround$   = 0
    gHighestY$   = gpy$
    gAlive$              = true
    gLevelComplete$      = false
    gMandatoryCollected$ = 0
    gSurpriseCooldown$   = 0

    ' Background music
    IF gBgMusic$ <> "" THEN SOUNDSTOP(gBgMusic$)
    IF musicState$ = true AND Map$("bg-sound") <> "" THEN
        LET gBgMusic$ = LOADSOUND(Map$("bg-sound"))
        SOUNDREPEAT(gBgMusic$)
    ENDIF
RETURN

' ============================================================
[game:scanMap]
    ' Scan Map$ rows for spawns, coins, enemies
    gSpawnX$ = 2 : gSpawnY$ = 2
    gMapW$   = Map$("cols")
    gMapH$   = Map$("rows")
    DELARRAY enemies$
    DELARRAY coins$
    DIM enemies$
    DIM coins$
    gEnemyCount$ = 0
    gCoinCount$  = 0
    gMandatoryTotal$ = 0

    FOR scanRow$ = 1 TO gMapH$
        FOR scanCol$ = 1 TO gMapW$
            scanCh$ = MID(Map$("row" + STR(scanRow$)), scanCol$, 1)
            IF scanCh$ = "-" THEN
                gSpawnX$ = scanCol$ - 0.5
                gSpawnY$ = scanRow$ - 0.5
            ENDIF
            IF scanCh$ = "@" THEN
                enemies$("x"  + STR(gEnemyCount$)) = scanCol$ - 0.5
                enemies$("y"  + STR(gEnemyCount$)) = scanRow$ - 0.5
                enemies$("dir" + STR(gEnemyCount$)) = 1
                gEnemyCount$ = gEnemyCount$ + 1
            ENDIF
            IF scanCh$ = "$" OR scanCh$ = "&" THEN
                coins$("x"    + STR(gCoinCount$)) = scanCol$ - 0.5
                coins$("y"    + STR(gCoinCount$)) = scanRow$ - 0.5
                coins$("type" + STR(gCoinCount$)) = scanCh$
                coins$("on"   + STR(gCoinCount$)) = 1
                IF scanCh$ = "&" THEN gMandatoryTotal$ = gMandatoryTotal$ + 1
                gCoinCount$ = gCoinCount$ + 1
            ENDIF
        NEXT
    NEXT
RETURN

' ============================================================
[game:loop]
    WHILE gRunning$ AND gAlive$ AND gLevelComplete$ = false
        gKey$ = INKEY
        IF gKey$ = KEY_ESC# THEN gRunning$ = false

        ' Mode switch with spacebar
        IF gKey$ = KEY_SPACE# THEN
            gRgbMode$ = gRgbMode$ + 1
            IF gRgbMode$ > GAME_BLUE# THEN gRgbMode$ = GAME_GREEN#
        ENDIF

        ' Input
        gMoveInput$ = 0
        IF KEYDOWN(KEY_LEFT#)  THEN gMoveInput$ = -1
        IF KEYDOWN(KEY_RIGHT#) THEN gMoveInput$ = 1
        IF KEYDOWN(KEY_UP#) AND gOnGround$ = 1 THEN
            gvy$ = GAME_JUMP#
            gOnGround$ = 0
            IF soundState$ = true THEN SOUNDONCE(gSndJump$)
        ENDIF

        ' Physics
        IF gOnGround$ = 1 THEN
            gvx$ = gMoveInput$ * GAME_MSPD#
            gvx$ = gvx$ * GAME_GFRIC#
        ELSE
            gvx$ = gvx$ + (gMoveInput$ * GAME_AIR#)
            gvx$ = gvx$ * GAME_AFRIC#
            IF gvx$ >  GAME_MSPD# THEN gvx$ =  GAME_MSPD#
            IF gvx$ < -GAME_MSPD# THEN gvx$ = -GAME_MSPD#
        ENDIF
        gvy$ = gvy$ + GAME_GRAV#
        IF gvy$ > GAME_MAXFALL# THEN gvy$ = GAME_MAXFALL#
        IF gpy$ < gHighestY$ THEN gHighestY$ = gpy$

        GOSUB [game:physics]
        GOSUB [game:checkSurprise]
        GOSUB [game:updateEnemies]
        GOSUB [game:checkCoins]
        GOSUB [game:checkExit]

        ' Camera
        gCamX$ = INT(gpx$ * GAME_TILE# - 320)
        gCamY$ = INT(gpy$ * GAME_TILE# - 240)
        IF gCamX$ < 0 THEN gCamX$ = 0
        IF gCamY$ < 0 THEN gCamY$ = 0
        IF gCamX$ > gMapW$ * GAME_TILE# - 640 THEN gCamX$ = gMapW$ * GAME_TILE# - 640
        IF gCamY$ > gMapH$ * GAME_TILE# - 480 THEN gCamY$ = gMapH$ * GAME_TILE# - 480

        GOSUB [game:render]
        SLEEP 16
    WEND
RETURN

' ============================================================
[game:physics]
    ' Horizontal (X-axis)
    gNewX$       = gpx$ + gvx$ * 0.016
    gLeftEdge$   = gNewX$ - GAME_PW# / 2
    gRightEdge$  = gNewX$ + GAME_PW# / 2
    gHitLeft$    = 0
    gHitRight$   = 0

    IF gvx$ < 0 THEN
        gTestX$ = INT(gLeftEdge$)
        gTestY$ = INT(gpy$)
        IF gTestX$ >= 0 AND gTestX$ < gMapW$ AND gTestY$ >= 0 AND gTestY$ < gMapH$ THEN
            gTileCh$ = MID(Map$("row" + STR(gTestY$ + 1)), gTestX$ + 1, 1)
            IF gTileCh$ = "#" THEN gHitLeft$ = 1
        ENDIF
    ENDIF
    IF gvx$ > 0 THEN
        gTestX$ = INT(gRightEdge$)
        gTestY$ = INT(gpy$)
        IF gTestX$ >= 0 AND gTestX$ < gMapW$ AND gTestY$ >= 0 AND gTestY$ < gMapH$ THEN
            gTileCh$ = MID(Map$("row" + STR(gTestY$ + 1)), gTestX$ + 1, 1)
            IF gTileCh$ = "#" THEN gHitRight$ = 1
        ENDIF
    ENDIF

    IF gHitLeft$ = 0 AND gHitRight$ = 0 THEN
        gpx$ = gNewX$
    ELSE
        gvx$ = 0
    ENDIF

    ' Vertical (Y-axis) - falling (floor)
    gNewY$       = gpy$ + gvy$ * 0.016
    gLeftEdge$   = gpx$ - GAME_PW# / 2
    gRightEdge$  = gpx$ + GAME_PW# / 2
    gHitFloor$   = 0

    IF gvy$ >= 0 THEN
        gTestYBot$ = INT(gNewY$ + GAME_PH# / 2)
        gTestX$    = INT(gLeftEdge$)
        IF gTestX$ >= 0 AND gTestX$ < gMapW$ AND gTestYBot$ >= 0 AND gTestYBot$ < gMapH$ THEN
            gTileCh$ = MID(Map$("row" + STR(gTestYBot$ + 1)), gTestX$ + 1, 1)
            IF gTileCh$ = "#" THEN gHitFloor$ = 1
        ENDIF
        gTestX$ = INT(gRightEdge$)
        IF gTestX$ >= 0 AND gTestX$ < gMapW$ AND gTestYBot$ >= 0 AND gTestYBot$ < gMapH$ THEN
            gTileCh$ = MID(Map$("row" + STR(gTestYBot$ + 1)), gTestX$ + 1, 1)
            IF gTileCh$ = "#" THEN gHitFloor$ = 1
        ENDIF
        IF gHitFloor$ = 1 THEN
            gpy$       = gTestYBot$ - GAME_PH# / 2
            gvy$       = 0
            gOnGround$ = 1
            gHighestY$ = gpy$
        ELSE
            gpy$       = gNewY$
            gOnGround$ = 0
        ENDIF
    ENDIF

    ' Vertical (Y-axis) - rising (ceiling)
    gHitCeil$ = 0
    IF gvy$ < 0 THEN
        gTestYTop$ = INT(gNewY$ - GAME_PH# / 2)
        gTestX$    = INT(gLeftEdge$)
        IF gTestX$ >= 0 AND gTestX$ < gMapW$ AND gTestYTop$ >= 0 AND gTestYTop$ < gMapH$ THEN
            gTileCh$ = MID(Map$("row" + STR(gTestYTop$ + 1)), gTestX$ + 1, 1)
            IF gTileCh$ = "#" THEN gHitCeil$ = 1
        ENDIF
        gTestX$ = INT(gRightEdge$)
        IF gTestX$ >= 0 AND gTestX$ < gMapW$ AND gTestYTop$ >= 0 AND gTestYTop$ < gMapH$ THEN
            gTileCh$ = MID(Map$("row" + STR(gTestYTop$ + 1)), gTestX$ + 1, 1)
            IF gTileCh$ = "#" THEN gHitCeil$ = 1
        ENDIF
        IF gHitCeil$ = 1 THEN
            gpy$ = gTestYTop$ + 1 + GAME_PH# / 2
            gvy$ = 0
        ELSE
            gpy$ = gNewY$
        ENDIF
    ENDIF

    ' Acid check — player center point tested every frame
    LET gAcidTx$ = INT(gpx$ + 0.2)
    LET gAcidTy$ = INT(gpy$ + 0.2)
    IF gAcidTx$ >= 0 AND gAcidTx$ < gMapW$ AND gAcidTy$ >= 0 AND gAcidTy$ < gMapH$ THEN
        IF MID(Map$("row" + STR(gAcidTy$ + 1)), gAcidTx$ + 1, 1) = "!" THEN gAlive$ = false
    ENDIF
RETURN

' ============================================================
[game:updateEnemies]
    FOR eIdx$ = 0 TO gEnemyCount$ - 1
        eX$   = enemies$("x"   + STR(eIdx$))
        eDir$ = enemies$("dir" + STR(eIdx$))
        nextX$     = eX$ + eDir$ * GAME_ESPD# * 0.016
        nextTileX$ = INT(nextX$ + eDir$ * 0.5)
        eTileY$    = INT(enemies$("y" + STR(eIdx$)))

        ' Turn if: wall/acid ahead OR empty floor ahead (would fall)
        gTileCh$ = MID(Map$("row" + STR(eTileY$ + 1)), nextTileX$ + 1, 1)
        LET eBelowCh$ = MID(Map$("row" + STR(eTileY$ + 2)), nextTileX$ + 1, 1)
        LET eTurnAround$ = false
        IF gTileCh$ = "#" OR gTileCh$ = "?" OR gTileCh$ = "!" THEN eTurnAround$ = true
        IF eBelowCh$ = "." OR eBelowCh$ = "-" OR eBelowCh$ = "$" OR eBelowCh$ = "&" OR eBelowCh$ = "+" THEN eTurnAround$ = true
        IF eTurnAround$ = true THEN
            enemies$("dir" + STR(eIdx$)) = -eDir$
        ELSE
            enemies$("x" + STR(eIdx$)) = nextX$
        ENDIF

        ' Collision with player (kills regardless of current mode)
        IF ABS(enemies$("x" + STR(eIdx$)) - gpx$) < 0.8 THEN
            IF ABS(enemies$("y" + STR(eIdx$)) - gpy$) < 0.8 THEN
                gAlive$ = false
            ENDIF
        ENDIF
    NEXT
RETURN

' ============================================================
' Surprise tile (?): triggers Map$("surprise-sub") once per visit.
' The ? tile is replaced with . after first trigger.
' Set Map$("surprise-sub") in the level definition to customize the effect.
' ============================================================
[game:checkSurprise]
    LET gSurTileX$ = INT(gpx$)
    LET gSurTileY$ = INT(gpy$)
    LET gSurCh$    = ""
    IF gSurTileX$ >= 0 AND gSurTileX$ < gMapW$ AND gSurTileY$ >= 0 AND gSurTileY$ < gMapH$ THEN
        gSurCh$ = MID(Map$("row" + STR(gSurTileY$ + 1)), gSurTileX$ + 1, 1)
    ENDIF

    IF gSurCh$ = "?" THEN
        IF gSurpriseCooldown$ = 0 THEN
            gSurpriseCooldown$ = 1
            ' Replace ? with . in the map
            LET gSurRowKey$ = "row" + STR(gSurTileY$ + 1)
            LET gSurRow$    = Map$(gSurRowKey$)
            Map$(gSurRowKey$) = LEFT(gSurRow$, gSurTileX$) + "." + MID(gSurRow$, gSurTileX$ + 2, LEN(gSurRow$))
            IF gSurSubLabel$ <> "" THEN GOSUB gSurSubLabel$
        ENDIF
    ELSE
        gSurpriseCooldown$ = 0
    ENDIF
RETURN

' ============================================================
[game:checkCoins]
    FOR cIdx$ = 0 TO gCoinCount$ - 1
        IF coins$("on" + STR(cIdx$)) = 1 THEN
            IF ABS(coins$("x" + STR(cIdx$)) - gpx$) < 0.7 THEN
                IF ABS(coins$("y" + STR(cIdx$)) - gpy$) < 0.7 THEN
                    coins$("on" + STR(cIdx$)) = 0
                    gScore$ = gScore$ + 10
                    IF soundState$ = true THEN SOUNDONCE(gSndCoin$)
                    IF coins$("type" + STR(cIdx$)) = "&" THEN
                        gMandatoryCollected$ = gMandatoryCollected$ + 1
                    ELSE
                        gTotalOptCoins$ = gTotalOptCoins$ + 1
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
    NEXT
RETURN

' ============================================================
[game:checkExit]
    ' Exit activates only when all mandatory coins are collected
    IF gMandatoryCollected$ < gMandatoryTotal$ THEN RETURN

    FOR scanRow$ = 1 TO gMapH$
        FOR scanCol$ = 1 TO gMapW$
            IF MID(Map$("row" + STR(scanRow$)), scanCol$, 1) = "+" THEN
                IF ABS((scanCol$ - 0.5) - gpx$) < 0.8 THEN
                    IF ABS((scanRow$ - 0.5) - gpy$) < 0.8 THEN
                        gLevelComplete$ = true
                    ENDIF
                ENDIF
            ENDIF
        NEXT
    NEXT
RETURN

' ============================================================
[game:showLevelTitle]
    IF soundState$ = true THEN SOUNDONCE(gSndLevelPassed$)
    LET gTitleImg$ = "assets/img/title_level" + TRIM(STR(gLevelNum$)) + ".png"
    LET gTitleShape$ = LOADIMAGE(gTitleImg$)
    SCREENLOCK ON
    LINE (0, 0)-(640, 480), RGB(0, 0, 0), BF
    MOVESHAPE gTitleShape$, 1, 1
    DRAWSHAPE gTitleShape$
    SCREENLOCK OFF
    SLEEP 3000
    REMOVESHAPE gTitleShape$
RETURN

' ============================================================
[game:showGameOver]
    IF soundState$ = true THEN SOUNDONCE(gSndGameOver$)

    ' Load and show game over image
    LET gGoImg$ = LOADIMAGE("assets/img/gameover.png")
    SCREENLOCK ON
    LINE (0, 0)-(640, 480), RGB(0, 0, 0), BF
    MOVESHAPE gGoImg$, 1, 1
    DRAWSHAPE gGoImg$
    SCREENLOCK OFF

    ' Wait 2 seconds (let sound play)
    SLEEP 2000

    REMOVESHAPE gGoImg$
RETURN

' ============================================================
[game:showEnding]
    ' --- Calculate final time ---
    LET gEndTime$   = TICKS - startTime$
    LET gBonus$     = gTotalOptCoins$ * 200
    LET gFinalTime$ = gEndTime$ - gBonus$
    IF gFinalTime$ < 0 THEN gFinalTime$ = 0

    ' --- Load best time from file ---
    LET gBestTime$ = 1800000    ' default 30:00
    IF FileExists("highscore.txt") THEN
        LET gHsSave$ = FileRead("highscore.txt")
        IF HASKEY(gHsSave$("best")) THEN
            gBestTime$ = VAL(gHsSave$("best"))
        ENDIF
    ENDIF

    ' --- Save new record if improved ---
    LET gPrevBestTime$ = gBestTime$
    LET gIsNewRecord$ = false
    IF gFinalTime$ < gBestTime$ THEN
        gBestTime$ = gFinalTime$
        gIsNewRecord$ = true
        gHsSave$("best") = gBestTime$
        FileWrite "highscore.txt", gHsSave$
    ENDIF

    ' --- Draw ending screen ---
    SCREENLOCK ON
    LINE (0,0)-(640,480), RGB(0,0,0), BF

    LET gEndBg$ = LOADIMAGE("assets/img/menu.png")
    MOVESHAPE gEndBg$, 0, 0
    DRAWSHAPE gEndBg$
    REMOVESHAPE gEndBg$

    ' Player's time — green, centered at y=270
    gDigitColor$ = RGB(0, 220, 0)
    gDigitTimeMs$ = gFinalTime$
    gDigitY$ = 270
    GOSUB [game:drawMmSs]

    ' Show NEW RECORD image if record broken
    IF gIsNewRecord$ = true THEN
        LET gNrImg$ = LOADIMAGE("assets/img/new_record.png")
        MOVESHAPE gNrImg$, 200, 415
        DRAWSHAPE gNrImg$
        REMOVESHAPE gNrImg$
    ENDIF

    SCREENLOCK OFF
    SLEEP 5000
    WAITKEY()
RETURN

' ============================================================
[game:cleanup]
    IF gBgMusic$ <> "" THEN SOUNDSTOP(gBgMusic$)
    DELARRAY Map$
    DELARRAY enemies$
    DELARRAY coins$
    gameInitDone$ = false
RETURN

' ============================================================
[game:render]
    SCREENLOCK ON
    LINE (0, 0)-(640, 480), RGB(0, 0, 0), BF

    ' Map — only tiles near player (light radius)
    gStartX$ = INT(gpx$) - GAME_LIGHT# - 1
    gStartY$ = INT(gpy$) - GAME_LIGHT# - 1
    gEndX$   = INT(gpx$) + GAME_LIGHT# + 1
    gEndY$   = INT(gpy$) + GAME_LIGHT# + 1
    IF gStartX$ < 0          THEN gStartX$ = 0
    IF gStartY$ < 0          THEN gStartY$ = 0
    IF gEndX$   > gMapW$ - 1 THEN gEndX$   = gMapW$ - 1
    IF gEndY$   > gMapH$ - 1 THEN gEndY$   = gMapH$ - 1

    FOR gTileY$ = gStartY$ TO gEndY$
        FOR gTileX$ = gStartX$ TO gEndX$
            gDist$   = DISTANCE(gpx$, gpy$, gTileX$ + 0.5, gTileY$ + 0.5)
            gBright$ = 255 - INT(gDist$ / GAME_LIGHT# * 220)
            IF gBright$ < 20 THEN gBright$ = 20
            gTileCh$ = MID(Map$("row" + STR(gTileY$ + 1)), gTileX$ + 1, 1)
            gSx$     = gTileX$ * GAME_TILE# - gCamX$
            gSy$     = gTileY$ * GAME_TILE# - gCamY$

            ' GREEN: walls and structure
            IF gRgbMode$ = GAME_GREEN# THEN
                IF gTileCh$ = "#" THEN
                    LINE (gSx$, gSy$)-(gSx$ + GAME_TILE#, gSy$ + GAME_TILE#), RGB(0, gBright$, 0), BF
                ENDIF
                IF gTileCh$ = "?" THEN
                    LINE (gSx$, gSy$)-(gSx$ + GAME_TILE#, gSy$ + GAME_TILE#), RGB(60, 0, 80), BF
                ENDIF
                IF gTileCh$ = "!" THEN
                    LINE (gSx$, gSy$)-(gSx$ + GAME_TILE#, gSy$ + GAME_TILE#), RGB(gBright$, gBright$, 0), BF
                ENDIF
            ENDIF

            ' BLUE: coins and exit
            IF gRgbMode$ = GAME_BLUE# THEN
                IF gTileCh$ = "+" THEN
                    IF gMandatoryCollected$ >= gMandatoryTotal$ THEN
                        ' Active exit — bright cyan
                        LINE (gSx$, gSy$)-(gSx$ + GAME_TILE#, gSy$ + GAME_TILE#), RGB(0, gBright$, gBright$), BF
                    ELSE
                        ' Inactive exit — dim gray
                        LINE (gSx$, gSy$)-(gSx$ + GAME_TILE#, gSy$ + GAME_TILE#), RGB(40, 40, 40), BF
                    ENDIF
                ENDIF
            ENDIF
        NEXT
    NEXT

    ' Working variables for LOS checks
    LET gLosTargX$ = 0
    LET gLosTargY$ = 0
    LET gLosOk$    = true
    GOSUB [game:renderCoins]
    GOSUB [game:renderEnemies]
    GOSUB [game:renderPlayer]
    SCREENLOCK OFF
RETURN

' ============================================================
[game:renderCoins]
    IF gRgbMode$ = GAME_BLUE# THEN
        FOR cIdx$ = 0 TO gCoinCount$ - 1
            IF coins$("on" + STR(cIdx$)) = 1 THEN
                gDist$ = DISTANCE(gpx$, gpy$, coins$("x" + STR(cIdx$)), coins$("y" + STR(cIdx$)))
                IF gDist$ <= GAME_LIGHT# THEN
                    gLosTargX$ = coins$("x" + STR(cIdx$))
                    gLosTargY$ = coins$("y" + STR(cIdx$))
                    GOSUB [game:checkLOS]
                    IF gLosOk$ = true THEN
                        gBright$ = 255 - INT(gDist$ / GAME_LIGHT# * 200)
                        gSx$ = INT(coins$("x" + STR(cIdx$)) * GAME_TILE# - gCamX$)
                        gSy$ = INT(coins$("y" + STR(cIdx$)) * GAME_TILE# - gCamY$)
                        IF coins$("type" + STR(cIdx$)) = "&" THEN
                            CIRCLE (gSx$, gSy$), 7, RGB(0, gBright$, gBright$), 1
                        ELSE
                            CIRCLE (gSx$, gSy$), 5, RGB(0, INT(gBright$ * 0.6), gBright$), 1
                        ENDIF
                    ENDIF
                ENDIF
            ENDIF
        NEXT
    ENDIF
RETURN

' ============================================================
[game:renderEnemies]
    IF gRgbMode$ = GAME_RED# THEN
        FOR eIdx$ = 0 TO gEnemyCount$ - 1
            gDist$ = DISTANCE(gpx$, gpy$, enemies$("x" + STR(eIdx$)), enemies$("y" + STR(eIdx$)))
            IF gDist$ <= GAME_LIGHT# THEN
                gLosTargX$ = enemies$("x" + STR(eIdx$))
                gLosTargY$ = enemies$("y" + STR(eIdx$))
                GOSUB [game:checkLOS]
                IF gLosOk$ = true THEN
                    gBright$ = 255 - INT(gDist$ / GAME_LIGHT# * 200)
                    gSx$ = INT(enemies$("x" + STR(eIdx$)) * GAME_TILE# - gCamX$)
                    gSy$ = INT(enemies$("y" + STR(eIdx$)) * GAME_TILE# - gCamY$)
                    LINE (gSx$ - 6, gSy$ - 8)-(gSx$ + 6, gSy$ + 8), RGB(gBright$, 0, 0), BF
                ENDIF
            ENDIF
        NEXT
    ENDIF
RETURN

' ============================================================
' LOS check: steps from player toward target in 0.5-tile increments.
' If any step hits a wall (#/?/!) -> gLosOk$ = false.
' Set gLosTargX$/Y$ before calling.
' ============================================================
[game:checkLOS]
    LET losDx$    = gLosTargX$ - gpx$
    LET losDy$    = gLosTargY$ - gpy$
    LET losSteps$ = INT(DISTANCE(gpx$, gpy$, gLosTargX$, gLosTargY$) / 0.5) + 1
    LET losStepX$ = losDx$ / losSteps$
    LET losStepY$ = losDy$ / losSteps$
    LET losCx$    = gpx$
    LET losCy$    = gpy$
    gLosOk$ = true
    FOR losSt$ = 1 TO losSteps$ - 1
        losCx$ = losCx$ + losStepX$
        losCy$ = losCy$ + losStepY$
        LET losTx$ = INT(losCx$)
        LET losTy$ = INT(losCy$)
        IF losTx$ >= 0 AND losTx$ < gMapW$ AND losTy$ >= 0 AND losTy$ < gMapH$ THEN
            LET losCh$ = MID(Map$("row" + STR(losTy$ + 1)), losTx$ + 1, 1)
            IF losCh$ = "#" OR losCh$ = "?" THEN
                gLosOk$ = false
                losSt$  = losSteps$
            ENDIF
        ENDIF
    NEXT
RETURN

' ============================================================
[game:renderPlayer]
    gSx$ = INT(gpx$ * GAME_TILE# - gCamX$)
    gSy$ = INT(gpy$ * GAME_TILE# - gCamY$)
    LET gR$  = 0
    LET gGg$ = 0
    LET gBl$ = 0
    IF gRgbMode$ = GAME_GREEN# THEN gGg$ = 255
    IF gRgbMode$ = GAME_RED#   THEN gR$  = 255
    IF gRgbMode$ = GAME_BLUE#  THEN gBl$ = 255
    LINE (gSx$ - 4, gSy$ - 7)-(gSx$ + 4, gSy$ + 7), RGB(gR$, gGg$, gBl$), BF
RETURN

' ============================================================
[game:renderHUD]
    COLOR 15, 0
    LOCATE 1, 1
    IF gRgbMode$ = GAME_GREEN# THEN PRINT "[ GREEN ]  ";
    IF gRgbMode$ = GAME_RED#   THEN PRINT "[  RED  ]  ";
    IF gRgbMode$ = GAME_BLUE#  THEN PRINT "[ BLUE  ]  ";
    PRINT "Score:"; gScore$; "  Coins:"; gMandatoryCollected$; "/"; gMandatoryTotal$; "   "
    COLOR 7, 0
RETURN


' ============================================================
' TILE REFERENCE
'
' Green mode (structure):
'   # = Wall. Impassable.
'   . = Empty space. Player moves here.
'   ? = Surprise tile. Looks almost like #. Triggers a random effect.
'   ! = Acid tile. Instant death.
'
' Red mode (enemies):
'   @ = Enemy. Patrols left/right.
'
' Blue mode (objectives):
'   $ = Normal coin. Points only.
'   & = Mandatory coin. All must be collected before the exit activates.
'   + = Exit. Leads to next level.
'   - = Start point. Player spawn.
'
' Always visible (regardless of mode):
'   A-Z, 0-9 = Text characters. Shown in level text-color.
'              Use for in-game messages, hints and tutorials.
' ============================================================

[level:1]
    Map$("level")      		= 1
    Map$("title")      		= "Beginning"
    Map$("text-color") 		= 10
    Map$("bg-sound")   		= "assets/audio/The_Zone.mp3"
	Map$("surprise-sub") 	= "[five-coins]"
    Map$("cols")       		= 31
    Map$("rows")       		= 21
	Map$("row1") 			= "###############################"
	Map$("row2") 			= "#-....@.................@....+#"
	Map$("row3") 			= "##$..#####............####..$##"
	Map$("row4") 			= "###$.......................$###"
	Map$("row5") 			= "#.##$..........$..........$##.#"
	Map$("row6") 			= "#..##$........$$$........$##..#"
	Map$("row7") 			= "#...##$......$$#$$......$##...#"
	Map$("row8") 			= "#....##$....$$$$$$$....$##....#"
	Map$("row9") 			= "#.....##$...#######?..$##.....#"
	Map$("row10") 			= "#......##..##$$$$$##..##......#"
	Map$("row11") 			= "#..............@..............#"
	Map$("row12") 			= "#$$$$$$###.#########.###$$$$$$#"
	Map$("row13") 			= "#$$$$$##.#.$$$$$$$$$.#.##$$$$$#"
	Map$("row14") 			= "#$$$$##..##....@....##..##$$$$#"
	Map$("row15") 			= "#$$$##......#######......##$$$#"
	Map$("row16") 			= "#$$##....###$$$$$$$###....##$$#"
	Map$("row17") 			= "#$##....#..............##..##$#"
	Map$("row18") 			= "###....#......##....###.....###"
	Map$("row19") 			= "##....#....##$$$$##..........##"
	Map$("row20") 			= "#.......##$$$$&$$$$$##........#"
	Map$("row21") 			= "###############################"
RETURN

[level:2]
    Map$("level")      		= 2
    Map$("title")      		= "Levels"
    Map$("text-color") 		= 10
    Map$("bg-sound")   		= "assets/audio/virus.mp3"
	Map$("surprise-sub") 	= "[ten-coins]"
    Map$("cols")       		= 31
    Map$("rows")       		= 21
	Map$("row1") 			= "###############################"
	Map$("row2") 			= "#-$$$$$$$$$$$$$$$$$$$$$$$$$$$$#"
	Map$("row3") 			= "##............................#"
	Map$("row4") 			= "########!###!#####!####!#####&#"
	Map$("row5") 			= "#?$$$$$$$$$$$$$$$$$$$$$$$$$$$$#"
	Map$("row6") 			= "#.............................#"
	Map$("row7") 			= "#&###!###########!#############"
	Map$("row8") 			= "#.............................#"
	Map$("row9") 			= "#!............................#"
	Map$("row10") 			= "###########!##.#####!###!######"
	Map$("row11") 			= "#.............................#"
	Map$("row12") 			= "#.............................#"
	Map$("row13") 			= "#......&......................#"
	Map$("row14") 			= "#$##$$##$$##$$##$$##$$##$$##$$#"
	Map$("row15") 			= "############################!&#"
	Map$("row16") 			= "#.............................#"
	Map$("row17") 			= "#.#############################"
	Map$("row18") 			= "#.$$$$$$$$$$$$$$$$$$$$$$$$$$$$#"
	Map$("row19") 			= "#.............................#"
	Map$("row20") 			= "#!##@###@#@###@#@###@#@##@##.+#"
	Map$("row21") 			= "###############################"
RETURN

[level:3]
    Map$("level")      		= 3
    Map$("title")      		= "Falls"
    Map$("text-color") 		= 10
    Map$("bg-sound")   		= "assets/audio/We_all_gonna_die.mp3"
	Map$("surprise-sub") 	= "[jump-scare1]"
    Map$("cols")       		= 31
    Map$("rows")       		= 21
	Map$("row1") 			= "###############################"
	Map$("row2") 			= "#.................#$$$...&.#-$#"
	Map$("row3") 			= "#.........#####.$.###$##...##$#"
	Map$("row4") 			= "#.......##....#.$.#.$.#..###.$#"
	Map$("row5") 			= "#.....##......#.$.#$..#....#.$#"
	Map$("row6") 			= "#..##.........#.$.#$..##...#$.#"
	Map$("row7") 			= "#....##.......#.$.#$.!#....#$.#"
	Map$("row8") 			= "#......##.....#.$.#$..#..###$!#"
	Map$("row9") 			= "#........##...#.$.#.$.#....#$.#"
	Map$("row10") 			= "#...........###.$.#..$##...#$.#"
	Map$("row11") 			= "#.........##..#.$.#!.$#....#$.#"
	Map$("row12") 			= "#.......##....#.$.#.$.#..###$.#"
	Map$("row13") 			= "#.....##......#.$.#$..#....#?$#"
	Map$("row14") 			= "#....#........#.$.#$..##...#.$#"
	Map$("row15") 			= "#$##..........#.$.#$.!#....#.$#"
	Map$("row16") 			= "#$$$###.......#.+.#$.!#..###.$#"
	Map$("row17") 			= "#$$$$$$$##....#!#!#$.!#....#.$#"
	Map$("row18") 			= "#$$$$$$$$$$#......#.$.##...#.$#"
	Map$("row19") 			= "#$$$$$$$$$$$#$##..#..$#..###!$#"
	Map$("row20") 			= "#$$$$$$$$$$$$$$$.....$##....$.#"
	Map$("row21") 			= "###############################"
RETURN

[level:4]
    Map$("level")      		= 4
    Map$("title")      		= "Traps"
    Map$("text-color") 		= 10
    Map$("bg-sound")   		= "assets/audio/The_Zone.mp3"
	Map$("surprise-sub") 	= "[fifty-coins]"
    Map$("cols")       		= 31
    Map$("rows")       		= 21
	Map$("row1") 			= "###############################"
	Map$("row2") 			= "#$$$$$$$$$....................#"
	Map$("row3") 			= "#@$$$$$$@$$...................#"
	Map$("row4") 			= "###############..#$##.#.#.....#"
	Map$("row5") 			= "#$$$$$$$$$$$$....#$$#.#.#.....#"
	Map$("row6") 			= "#############...##..#.#.#.....#"
	Map$("row7") 			= "#..............##...#.#.##!##.#"
	Map$("row8") 			= "#....###########....#.#.$$....#"
	Map$("row9") 			= "#..-...$$$$$$$$#....#.#.$$....#"
	Map$("row10") 			= "#..#.###########!!!!#.#.$$....#"
	Map$("row11") 			= "#...............#.....#.#!#...#"
	Map$("row12") 			= "#############!!!#!#####.#....$#"
	Map$("row13") 			= "#$$$$$$$$$$$$$$$$$$$$$#!#..&#!#"
	Map$("row14") 			= "#..........................#.?#"
	Map$("row15") 			= "#..@..............@...........#"
	Map$("row16") 			= "#.#############################"
	Map$("row17") 			= "#.!...........................#"
	Map$("row18") 			= "#..!..........................#"
	Map$("row19") 			= "#...!.........................#"
	Map$("row20") 			= "#!.....!..!..!..!..!..!.....!+#"
	Map$("row21") 			= "###############################"
RETURN

[level:5]
    Map$("level")      		= 5
    Map$("title")      		= "Smile"
    Map$("text-color") 		= 10
    Map$("bg-sound")   		= "assets/audio/R2D2.mp3"
	Map$("surprise-sub") 	= "[start-again]"
    Map$("cols")       		= 31
    Map$("rows")       		= 21
	Map$("row1") 			= "###############################"
	Map$("row2") 			= "#.$$.......................$$.#"
	Map$("row3") 			= "#.##......##.#.#.#.##......##.#"
	Map$("row4") 			= "#.##.$$$$.##.......##......##.#"
	Map$("row5") 			= "#....$##$..............##.....#"
	Map$("row6") 			= "#....$##$..............##.....#"
	Map$("row7") 			= "#.##$$$$$$##.......##$$$$$##..#"
	Map$("row8") 			= "#..##$$$##..........##$$$##...#"
	Map$("row9") 			= "#...#####............#####....#"
	Map$("row10") 			= "#..............@..............#"
	Map$("row11") 			= "#............####.............#"
	Map$("row12") 			= "#...........##..##............#"
	Map$("row13") 			= "#...........#.&?.#............#"
	Map$("row14") 			= "#...........#.##.#............#"
	Map$("row15") 			= "#.............................#"
	Map$("row16") 			= "#.##.........#..#..........##.#"
	Map$("row17") 			= "#..##.......#....#........##..#"
	Map$("row18") 			= "#...##..@........@.......##...#"
	Map$("row19") 			= "#....####################....+#"
	Map$("row20") 			= "#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#"
	Map$("row21") 			= "###############################"
RETURN

[level:6]
    Map$("level")      		= 6
    Map$("title")      		= "So many"
    Map$("text-color") 		= 10
    Map$("bg-sound")   		= "assets/audio/Run-Amok.mp3"
	Map$("surprise-sub") 	= "[fifty-coins]"
    Map$("cols")       		= 31
    Map$("rows")       		= 21
	Map$("row1") 			= "###############################"
	Map$("row2") 			= "#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#"
	Map$("row3") 			= "#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#"
	Map$("row4") 			= "#$$$$$########..#########$$$$$#"
	Map$("row5") 			= "#$$$$#...................#.?..#"
	Map$("row6") 			= "#$$#...&...@.........&.....#..#"
	Map$("row7") 			= "#..##!####!###..#######!#.#...#"
	Map$("row8") 			= "#.......................#.....#"
	Map$("row9") 			= "#........................#....#"
	Map$("row10") 			= "#.............#..##.@.....#..##"
	Map$("row11") 			= "#..&.$$$$....#.#...###......#$#"
	Map$("row12") 			= "#..####!#...#.$.#....#.....#$$#"
	Map$("row13") 			= "#..........#.$&$.#....#.&.#$$$#"
	Map$("row14") 			= "#..&.$....#.$.#.$.#....###$$$$#"
	Map$("row15") 			= "#..#!#...#.$.#.#.$.#..........#"
	Map$("row16") 			= "#.......#.$.#...#.$.#.........#"
	Map$("row17") 			= "#......#.$.#.....#.$.#........#"
	Map$("row18") 			= "#.#...#.$.#...#...#.$.#...#...#"
	Map$("row19") 			= "#.............................#"
	Map$("row20") 			= "#.&.#.&.#.&.#.&.#.&.#.&.#.+.#-#"
	Map$("row21") 			= "###############!#########!#####"
RETURN

[level:7]
    Map$("level")      		= 7
    Map$("title")      		= "Race Track"
    Map$("text-color") 		= 10
    Map$("bg-sound")   		= "assets/audio/virus.mp3"
	Map$("surprise-sub") 	= "[fifty-coins]"
    Map$("cols")       		= 31
    Map$("rows")       		= 21
	Map$("row1") 			= "###############################"
	Map$("row2") 			= "#............................##"
	Map$("row3") 			= "#............-+...........@...#"
	Map$("row4") 			= "#$..!##########!###########...#"
	Map$("row5") 			= "#.$.########################..#"
	Map$("row6") 			= "#..$#######################...#"
	Map$("row7") 			= "#.?.!#.......................##"
	Map$("row8") 			= "#$..#............$$$........###"
	Map$("row9") 			= "#.$.#....###!###!###!###!######"
	Map$("row10") 			= "#..$!##.......................#"
	Map$("row11") 			= "#.$.####......................#"
	Map$("row12") 			= "#$..####!##############!#....##"
	Map$("row13") 			= "#.$.!...........$#########...##"
	Map$("row14") 			= "#..$#.............$######...###"
	Map$("row15") 			= "#.$.##...########..$####...####"
	Map$("row16") 			= "#$..###.........##...$#...#####"
	Map$("row17") 			= "#.$.###&.........##......######"
	Map$("row18") 			= "#..$#!#######...####....#######"
	Map$("row19") 			= "#.$.$.$.$.$.$..#####!##!#######"
	Map$("row20") 			= "#!.$.$.$.$.$.$#################"
	Map$("row21") 			= "###############################"
RETURN

[level:8]
    Map$("level")      		= 8
    Map$("title")      		= "Maze"
    Map$("text-color") 		= 10
	Map$("bg-sound")   		= "assets/audio/We_all_gonna_die.mp3"
	Map$("surprise-sub") 	= "[pause-game]"
    Map$("cols")       		= 31
    Map$("rows")       		= 21
	Map$("row1") 			= "###############################"
	Map$("row2") 			= "#.+...........................#"
	Map$("row3") 			= "#.###########.................#"
	Map$("row4") 			= "#...........##!##!##!###......#"
	Map$("row5") 			= "#!!@...###$$$$$$$$$$$$$$$$....#"
	Map$("row6") 			= "#!!####..&################..#!#"
	Map$("row7") 			= "###...$$$$$$$$$$$..........#$$#"
	Map$("row8") 			= "#.....###########.............#"
	Map$("row9") 			= "#$$##.......$$..###############"
	Map$("row10") 			= "#$$$$##...#.##-...............#"
	Map$("row11") 			= "########..#..##..#..#..#..#..##"
	Map$("row12") 			= "#$$$$$...#.#..#.##.##.##.##.###"
	Map$("row13") 			= "#$####..##..#$$?$$$$$$#..##...#"
	Map$("row14") 			= "#$#.&..#.#..###########..###..#"
	Map$("row15") 			= "#$#...#..#$$$$$$$$$$$$#$$$$$..#"
	Map$("row16") 			= "#!#..#...#..#..#####..######..#"
	Map$("row17") 			= "#...#....#..##.....@..........#"
	Map$("row18") 			= "#..#......#...#...###.#######.#"
	Map$("row19") 			= "#.##########...#..#...........#"
	Map$("row20") 			= "#&$$$$$$$$$$$$$$#...#.######&.#"
	Map$("row21") 			= "###############################"
RETURN

[level:9]
    Map$("level")      		= 9
    Map$("title")      		= "P*C-M*N"
    Map$("text-color") 		= 10
	Map$("bg-sound")   		= "assets/audio/R2D2.mp3"
	Map$("surprise-sub") 	= "[start-again]"
    Map$("cols")       		= 31
    Map$("rows")       		= 21
	Map$("row1") 			= "###############################"
	Map$("row2") 			= "#$$$$$$$$$$$$#####$$$$$$$$$$-$#"
	Map$("row3") 			= "#$###$####$#$$$#$$$#$####$###$#"
	Map$("row4") 			= "#$#$#$#$$#$###$#$###$#$$#$#$#$#"
	Map$("row5") 			= "#$###$####$#$$$#$$$#$####$###$#"
	Map$("row6") 			= "#$$$$$$$$$$$$#!#!#$$$$$$$$$$$$#"
	Map$("row7") 			= "#$###$#$####$$$&$$$####$#$###$#"
	Map$("row8") 			= "#$#$$$#$####$#####$####$#$$$#$#"
	Map$("row9") 			= "#$#$###$$@$$$$###$$$@$$$###$#$#"
	Map$("row10") 			= "#$#$$$#$####$$$&$$$####$#$$$#$#"
	Map$("row11") 			= "#$###$#$######$#$######$#$###$#"
	Map$("row12") 			= "#$#$$$#$####$$$&$$$####$#$$$#$#"
	Map$("row13") 			= "#$#$###$$@$$$$###$$$@$$$###$#$#"
	Map$("row14") 			= "#$#$$$#$####$#####$####$#$$$#$#"
	Map$("row15") 			= "#$###$#$####$$$&$$$####$#$###$#"
	Map$("row16") 			= "#$$$$$$$$$$$$#####$$$$$$$$$$$$#"
	Map$("row17") 			= "#$###$####$#$$$#$$$#$####$###$#"
	Map$("row18") 			= "#$#$#$#$$#$###$#$###$#$$#$#$#$#"
	Map$("row19") 			= "#$###$####$#$$$#$$$#$####$###$#"
	Map$("row20") 			= "#$$$$$$$$$$$$#!!!#?$$$$$$$$$$+#"
	Map$("row21") 			= "###############################"
RETURN

[level:10]
    Map$("level")      		= 10
    Map$("title")      		= "FINAL"
    Map$("text-color") 		= 10
	Map$("bg-sound")   		= "assets/audio/simulacra.mp3"
	Map$("surprise-sub") 	= "[fifty-coins]"
    Map$("cols")       		= 31
    Map$("rows")       		= 21
	Map$("row1") 			= "###############################"
	Map$("row2") 			= "#.............+..............$#"
	Map$("row3") 			= "#.....####################...$#"
	Map$("row4") 			= "#####......................##$#"
	Map$("row5") 			= "#.....#...#...#...#...#...#..$#"
	Map$("row6") 			= "##..#...#...!...!...#...#...#$#"
	Map$("row7") 			= "###...#...#...#...#...#...#..$#"
	Map$("row8") 			= "####.###.###.###.###.###.###.$#"
	Map$("row9") 			= "#$$$$$$$$?$$$$$$$$$$$$$$$$$$$$#"
	Map$("row10") 			= "###.###.###.###.###.###.###.#$#"
	Map$("row11") 			= "#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#"
	Map$("row12") 			= "##.###.###.###.###.###.###.##$#"
	Map$("row13") 			= "#..&...&...&...&...&...&...&.$#"
	Map$("row14") 			= "#.###.###.###.###.###.###.###$#"
	Map$("row15") 			= "#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#"
	Map$("row16") 			= "####.###.###.###.###.###.###.$#"
	Map$("row17") 			= "#...........................@$#"
	Map$("row18") 			= "#..##########################$#"
	Map$("row19") 			= "##.$$$$$$$$$$$$$$$$$$$$$$$$$$$#"
	Map$("row20") 			= "#?..........................-$#"
	Map$("row21") 			= "######!######!#################"
RETURN

' ============================================================
' drawMmSs: draws time as M:SS:CC in 7-segment style.
' Set before calling: gDigitTimeMs$, gDigitY$, gDigitColor$
' ============================================================
[game:drawMmSs]
    LET gDTotalMs$ = gDigitTimeMs$
    LET gDSecs$    = INT(gDTotalMs$ / 1000)
    LET gDMins$    = INT(gDSecs$ / 60)
    IF gDMins$ > 9 THEN gDMins$ = 9
    LET gDSecs$    = MOD(gDSecs$, 60)
    LET gDCenti$   = INT(MOD(gDTotalMs$, 1000) / 10)

    ' Layout M:SS:CC — 5 digits, 2 colons, total width 291px, centered
    LET gDStartX$ = INT((640 - 291) / 2)

    gDigitN$ = gDMins$
    gDigitX$ = gDStartX$
    GOSUB [game:drawDigit]

    gColX$ = gDStartX$ + 58
    CIRCLE (gColX$, gDigitY$ + 18), 4, gDigitColor$, 1
    CIRCLE (gColX$, gDigitY$ + 44), 4, gDigitColor$, 1

    gDigitN$ = INT(gDSecs$ / 10) : gDigitX$ = gDStartX$ + 78  : GOSUB [game:drawDigit]
    gDigitN$ = MOD(gDSecs$, 10)  : gDigitX$ = gDStartX$ + 128 : GOSUB [game:drawDigit]

    gColX$ = gDStartX$ + 186
    CIRCLE (gColX$, gDigitY$ + 18), 4, gDigitColor$, 1
    CIRCLE (gColX$, gDigitY$ + 44), 4, gDigitColor$, 1

    gDigitN$ = INT(gDCenti$ / 10) : gDigitX$ = gDStartX$ + 206 : GOSUB [game:drawDigit]
    gDigitN$ = MOD(gDCenti$, 10)  : gDigitX$ = gDStartX$ + 256 : GOSUB [game:drawDigit]
RETURN

' ============================================================
' drawDigit: draws a single 7-segment digit.
' Set before calling: gDigitN$ (0-9), gDigitX$, gDigitY$, gDigitColor$
' Digit width ~40px, height ~64px
' ============================================================
[game:drawDigit]
    LET gSt$ = 5
    LET gSh$ = 27
    LET gSw$ = 30
    LET gDx2$ = gDigitX$
    LET gDy2$ = gDigitY$

    LET gSeg0$ = 0 : LET gSeg1$ = 0 : LET gSeg2$ = 0
    LET gSeg3$ = 0 : LET gSeg4$ = 0 : LET gSeg5$ = 0 : LET gSeg6$ = 0

    IF gDigitN$ = 0 THEN gSeg0$=1 : gSeg1$=1 : gSeg2$=1 : gSeg4$=1 : gSeg5$=1 : gSeg6$=1
    IF gDigitN$ = 1 THEN gSeg2$=1 : gSeg5$=1
    IF gDigitN$ = 2 THEN gSeg0$=1 : gSeg2$=1 : gSeg3$=1 : gSeg4$=1 : gSeg6$=1
    IF gDigitN$ = 3 THEN gSeg0$=1 : gSeg2$=1 : gSeg3$=1 : gSeg5$=1 : gSeg6$=1
    IF gDigitN$ = 4 THEN gSeg1$=1 : gSeg2$=1 : gSeg3$=1 : gSeg5$=1
    IF gDigitN$ = 5 THEN gSeg0$=1 : gSeg1$=1 : gSeg3$=1 : gSeg5$=1 : gSeg6$=1
    IF gDigitN$ = 6 THEN gSeg0$=1 : gSeg1$=1 : gSeg3$=1 : gSeg4$=1 : gSeg5$=1 : gSeg6$=1
    IF gDigitN$ = 7 THEN gSeg0$=1 : gSeg2$=1 : gSeg5$=1
    IF gDigitN$ = 8 THEN gSeg0$=1 : gSeg1$=1 : gSeg2$=1 : gSeg3$=1 : gSeg4$=1 : gSeg5$=1 : gSeg6$=1
    IF gDigitN$ = 9 THEN gSeg0$=1 : gSeg1$=1 : gSeg2$=1 : gSeg3$=1 : gSeg5$=1 : gSeg6$=1

    ' Seg 0: top
    IF gSeg0$ = 1 THEN LINE (gDx2$+3, gDy2$)-(gDx2$+gSw$+2, gDy2$+gSt$), gDigitColor$, BF
    ' Seg 1: upper left
    IF gSeg1$ = 1 THEN LINE (gDx2$, gDy2$+3)-(gDx2$+gSt$, gDy2$+gSh$), gDigitColor$, BF
    ' Seg 2: upper right
    IF gSeg2$ = 1 THEN LINE (gDx2$+gSw$+2, gDy2$+3)-(gDx2$+gSw$+gSt$+2, gDy2$+gSh$), gDigitColor$, BF
    ' Seg 3: middle
    IF gSeg3$ = 1 THEN LINE (gDx2$+3, gDy2$+gSh$)-(gDx2$+gSw$+2, gDy2$+gSh$+gSt$), gDigitColor$, BF
    ' Seg 4: lower left
    IF gSeg4$ = 1 THEN LINE (gDx2$, gDy2$+gSh$+gSt$)-(gDx2$+gSt$, gDy2$+gSh$*2+gSt$), gDigitColor$, BF
    ' Seg 5: lower right
    IF gSeg5$ = 1 THEN LINE (gDx2$+gSw$+2, gDy2$+gSh$+gSt$)-(gDx2$+gSw$+gSt$+2, gDy2$+gSh$*2+gSt$), gDigitColor$, BF
    ' Seg 6: bottom
    IF gSeg6$ = 1 THEN LINE (gDx2$+3, gDy2$+gSh$*2+gSt$)-(gDx2$+gSw$+2, gDy2$+gSh$*2+gSt$*2), gDigitColor$, BF
RETURN

' ============================================================
[game:moduleEnd]
