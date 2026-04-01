' intro.bas
' RGB Vision — cassette-style loading intro screen
' Kristian Virtanen, 2026
' MIT License
DEF FN Intro$()
    DIM iData$
    LET iData$("block")  = 40
    LET iData$("cols")   = SCREEN_W# / iData$("block")
    LET iData$("rows")   = SCREEN_H# / iData$("block")
    LET iData$("total")  = iData$("cols") * iData$("rows")

    iData$("img") = LOADIMAGE("assets/img/intro.png")

    MOVESHAPE iData$("img"), 1, 1

    iData$("music") = LOADSOUND("assets/audio/Push.mp3")


    iData$("framePerBlock") = 13

    ' Loop counters must be regular variables (not array elements)
    LET r$ = 0
    LET c$ = 0
    LET idx$ = 0

    DIM order$
    FOR r$ = 0 TO iData$("rows") - 1
        FOR c$ = 0 TO iData$("cols") - 1
            order$(idx$, 0) = r$
            order$(idx$, 1) = c$
            idx$ = idx$ + 1
        NEXT
    NEXT

    DIM covered$
    FOR r$ = 0 TO iData$("rows") - 1
        FOR c$ = 0 TO iData$("cols") - 1
            covered$(r$, c$) = 1
        NEXT
    NEXT

    LET revealed$ = 0
    LET frameCount$ = 0
    LET running$ = 1

    SOUNDONCE(iData$("music"))
	
    WHILE running$ = 1
        IF INKEY <> 0 THEN running$ = 0

        frameCount$ = frameCount$ + 1
        IF MOD(frameCount$, iData$("framePerBlock")) = 0 THEN
            IF revealed$ < iData$("total") THEN
                r$ = order$(revealed$, 0)
                c$ = order$(revealed$, 1)
                covered$(r$, c$) = 0
                revealed$ = revealed$ + 1
            ELSE
                running$ = 0
            ENDIF
        ENDIF

        SCREENLOCK ON
        DRAWSHAPE iData$("img")
        FOR r$ = 0 TO iData$("rows") - 1
            FOR c$ = 0 TO iData$("cols") - 1
                IF covered$(r$, c$) = 1 THEN
                    LINE (c$ * iData$("block"), r$ * iData$("block"))-(c$ * iData$("block") + iData$("block"), r$ * iData$("block") + iData$("block")), RGB(25, 25, 112), BF
                ENDIF
            NEXT
        NEXT
        SCREENLOCK OFF
        SLEEP 22
    WEND

	
    SOUNDSTOP(iData$("music"))

	REMOVESHAPE iData$("img")
	
    DELARRAY order$
    DELARRAY covered$
    DELARRAY iData$
    RETURN 0
END DEF