' **********
' *        *
' * Gosubs *
' *        *
' **********
GOSUB [inits:screen]
GOSUB [inits:globals]
GOSUB [sub:setScreen]


' ************
' *          *
' * Includes *
' *          *
' ************
INCLUDE "intro.bas"
INCLUDE "menu.bas"
INCLUDE "game.bas"
INCLUDE "surprises.bas"




' *****************************
' *                           *
' * "loading screen" as intro *
' *                           *
' *****************************
LET menuChoice$ = FN Intro$()


' ******************
' *                *
' * Main game loop *
' *                *
' ******************
GOSUB [menu:init]
GOSUB [menu:run]
GOSUB [menu:cleanup]

WHILE gameExit$ = false
    IF menuAction$ = "new_game" THEN
        GOSUB [game:start]
        ' Pelin jälkeen takaisin menuun
        GOSUB [menu:init]
        GOSUB [menu:run]
        GOSUB [menu:cleanup]
    ENDIF
    IF menuAction$ = "exit"   THEN gameExit$ = true
    IF menuAction$ = "manual" THEN GOSUB [manual:show]
WEND

END

[manual:show]
    ' Placeholder — avaa manual.pdf kun se on luotu
    LET temp$ = SHELL("cmd /c start manual.pdf")
RETURN


' ********************
' *                  *
' * Subs starts here *
' *                  *
' ********************
[sub:setScreen]
    SCREEN 0, SCREEN_W#, SCREEN_H#, TITLE#
    FULLSCREEN FALSE
RETURN ' [/sub:setScreen]	


[inits:screen]
    LET SCREEN_W# 	= 640
    LET SCREEN_H# 	= 480
	LET TITLE# 		= "RGB Vision"
RETURN ' [/inits:screen]


[inits:globals]
	LET gameExit$     = false
	LET musicState$   = true
	LET soundState$   = true
	LET startTime$

	' Jaetut digit-muuttujat (game:drawMmSs + game:drawDigit)
	LET gDigitColor$  = 0
	LET gDigitTimeMs$ = 0
	LET gDigitY$      = 0
	LET gDigitN$      = 0
	LET gDigitX$      = 0
	LET gColX$        = 0
	LET gDTotalMs$    = 0
	LET gDSecs$       = 0
	LET gDMins$       = 0
	LET gDCenti$      = 0
	LET gDStartX$     = 0
	LET gSt$          = 0
	LET gSh$          = 0
	LET gSw$          = 0
	LET gDx2$         = 0
	LET gDy2$         = 0
	LET gSeg0$        = 0
	LET gSeg1$        = 0
	LET gSeg2$        = 0
	LET gSeg3$        = 0
	LET gSeg4$        = 0
	LET gSeg5$        = 0
	LET gSeg6$        = 0
RETURN '[/inits:globals]