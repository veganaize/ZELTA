'       The Legend of Zelda

DIM SHARED buffer(32002) AS INTEGER '   Virtual Screen Buffer
DIM SHARED sprites(32759) AS INTEGER '  Every 130 = new sprite
DECLARE SUB makeCharacter (named AS STRING)
DECLARE SUB drawGuy (named AS STRING, x AS INTEGER, y AS INTEGER)

DECLARE SUB makeFile ()
DECLARE SUB drawMap ()
DECLARE SUB makeMap ()
DEFINT A-Z
'DIM BG(320), box(320), SC(127) ' BG holds background images. Box holds the Box image.
DIM SC(127)

TYPE character
    direction AS INTEGER '    *130  0|1=down 2|3=up 4|5=left 6|7=right
    frame AS INTEGER '              current step 0-1
    spriteOffset AS INTEGER '       offest to sprites in array
END TYPE

DIM SHARED link AS character '      Define Link
    link.direction = 0
    link.frame = 0
    link.spriteOffset = 0

DIM SHARED zelda AS character '     Define Zelda

TYPE tile
    clr AS INTEGER '            color
    spriteOffset AS INTEGER '   offset to sprite in array
END TYPE

DIM SHARED mountain(5, 15, 15)
DIM SHARED mtnArray(320)
DIM SHARED mtn(5, 320)
yi = 0

SCREEN 13 ' graphic coordinate minimums are 0 to 319 column or 199 row maximums.
'SCREEN 9, 0, 0, 1
GET (0, 0)-(319, 199), buffer '     init screen buffer

' set up screen background

makeCharacter "link"
'drawMap

x = 150: y = 50: PX = x: PY = y ' link starting position

'GET (x, y)-(x + 15, y + 15), BG(0) ' GET original BG at start box position
drawGuy "link", x, y

DO 'main loop
    t! = TIMER + .04

    DO '                    1 Tick (1/18th second) keypress scancode read loop
        code% = INP(&H60) '             Get keyboard scan code from port 96
        a$ = INKEY$ '                   So the keyboard buffer won't get full
       
        IF code% < 128 THEN
            SC(code%) = 1
        ELSE
            SC(code% - 128) = 0 '       true/false values to array
            SC(75) = 0: SC(77) = 0: SC(72) = 0: SC(80) = 0
        END IF

    LOOP UNTIL TIMER > t! ' loop until one tick has passed

    PX = x: PY = y ' previous coordinates
    IF SC(75) = 1 THEN x = x - 5: link.direction = 0: IF x < 0 THEN x = 0
    IF SC(77) = 1 THEN x = x + 5: link.direction = 2: IF x > 304 THEN x = 304
    IF SC(72) = 1 THEN y = y - 5: link.direction = 4: IF y < 0 THEN y = 0
    IF SC(80) = 1 THEN y = y + 5: link.direction = 6: IF y > 184 THEN y = 184

    IF x <> PX OR y <> PY THEN '                    Changed coordinate?
        'WAIT 986, 8: PUT (PX, PY), BG(0), PSET '    Replace previous BG first
        'GET (x, y)-(x + 15, y + 15), BG(0) '        GET BG at new position
                                            '       before box is set
        'x = 150: y = 50: PX = x: PY = y         'MAKE LINK STILL
        drawGuy "link", x, y
    END IF

LOOP UNTIL SC(1) = 1 ' main loop until [Esc] key (scan code 1) is pressed
SYSTEM

SUB drawGuy (named AS STRING, x AS INTEGER, y AS INTEGER)
SELECT CASE named
CASE "link"
    FOR r = 0 TO 15
    FOR c = 0 TO 15
        s& = (x + c) + (y * 320& + r)
       
        DEF SEG = &HA000
            'POKE s&, sprites(link.spriteOffset * 256 * (direction * 256) + (r * 16 + c))
            POKE s&, sprites(r * 16 + c)
        DEF SEG

    NEXT c
    NEXT r

    IF link.frame = 1 THEN link.frame = 0
    IF link.frame = 0 THEN link.frame = 1

END SELECT
END SUB

SUB drawMap
OPEN "map00.txt" FOR INPUT AS #1
FOR sy = 0 TO 184 STEP 16     '(200 / 16) divide screen cols into 16x16 units
    'LINE INPUT #1, in$
FOR sx = 0 TO 298 STEP 16     '(320 / 16) divide screen rows into 16x16 units
    IF MID$(in$, sx + 1, 1) <> "." THEN
        'draw tile
        'PUT (sx, sy), mtn(VAL("&H" + MID$(in$, sx + 1, 1)), 0)
    END IF
NEXT sx
NEXT sy
CLOSE (1)
END SUB

SUB makeCharacter (named AS STRING)

SELECT CASE named
CASE "link"
    OPEN "link.bin" FOR RANDOM AS #1 LEN = 2
        FOR r = 0 TO 15
        FOR c = 0 TO 15
            'GET #1, (r * 16 + c + 1), sprites(link.spriteOffset * 256 * (link.direction * 256) + (r * 16 + c))
            GET #1, (r * 16 + c + 1), sprites(r * 16 + c)
        NEXT c
        NEXT r
       
END SELECT
END SUB

SUB makeFile
FOR i = 0 TO 4
    OPEN ("mtn0" + LTRIM$(STR$(i)) + ".txt") FOR INPUT AS #9
    FOR y = 0 TO 15
        LINE INPUT #9, in$
        FOR x = 0 TO 15
            IF MID$(in$, j + 1, 1) = "." THEN
                mountain(i, x, y) = -1
            ELSE
                mountain(i, x, y) = VAL("&H" + MID$(in$, x + 1, 1))
        END IF
        CLOSE (1)
        NEXT x
    NEXT y
    FOR r = 0 TO 15
        FOR c = 0 TO 15
            IF mountain(i, c, r) <> -1 THEN PSET (c, r), mountain(i, c, r)
        NEXT c
    NEXT r
    GET (0, 0)-(15, 15), mtnArray
BSAVE ("mtn0" + LTRIM$(STR$(i)) + ".dat"), VARPTR(mtnArray), 320
CLOSE (9)
NEXT i

END SUB

SUB makeTiles
    FOR i = 0 TO 4
        OPEN "mtn0" + LTRIM$(STR$(i)) + ".dat" FOR BINARY AS #1
        FOR j = 0 TO 320
            GET #1, j, mtn(i, j)
        NEXT j
        CLOSE (1)
    NEXT i
END SUB

