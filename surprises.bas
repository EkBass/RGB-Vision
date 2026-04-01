' surprises.bas
' RGB Vision — surprise tile effects
' Kristian Virtanen, 2026
' MIT License
'
' Each subroutine here is triggered when a player steps on a ? tile.
' Assign the label to Map$("surprise-sub") in the level definition.
GOTO [surprises:moduleEnd]

[jump-scare1]

    LET scareSnd$ = LOADSOUND("assets/audio/game-over.mp3")
    IF soundState$ = true THEN SOUNDONCE(scareSnd$)

	' Shows fake "Game Over" image. Text at the bottom reads: "You didn't die, I was kidding"
    LET scareImg$ = LOADIMAGE("assets/img/gameover-but-no.png")
    SCREENLOCK ON
    LINE (0, 0)-(640, 480), RGB(0, 0, 0), BF
    MOVESHAPE scareImg$, 1, 1
    DRAWSHAPE scareImg$
    SCREENLOCK OFF

    ' Odota 3 sekuntia (ääni saa soi rauhassa)
    SLEEP 2000

    REMOVESHAPE scareImg$
RETURN

[five-coins]
    LET coinsSnd$ = LOADSOUND("assets/audio/5coins.mp3")
    IF soundState$ = true THEN SOUNDONCE(coinsSnd$)
	gTotalOptCoins$ = gTotalOptCoins$ + 5
RETURN

[ten-coins]
    LET coinsSnd$ = LOADSOUND("assets/audio/10coins.mp3")
    IF soundState$ = true THEN SOUNDONCE(coinsSnd$)
	gTotalOptCoins$ = gTotalOptCoins$ + 10
RETURN

[fifty-coins]
    LET coinsSnd$ = LOADSOUND("assets/audio/50coins.mp3")
    IF soundState$ = true THEN SOUNDONCE(coinsSnd$)
	gTotalOptCoins$ = gTotalOptCoins$ + 50
RETURN

[start-again]
    LET scareSnd$ = LOADSOUND("assets/audio/game-over.mp3")
    IF soundState$ = true THEN SOUNDONCE(scareSnd$)
	gpx$ = gSpawnX$
    gpy$ = gSpawnY$
    gvx$ = 0
    gvy$ = 0
    gOnGround$ = 0
RETURN

[pause-game]
    LET scareSnd$ = LOADSOUND("assets/audio/pause5.mp3")
    IF soundState$ = true THEN SOUNDONCE(scareSnd$)
	SLEEP 5000
RETURN
[surprises:moduleEnd]