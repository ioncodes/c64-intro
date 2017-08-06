:BasicUpstart2(start)

.var IRQLO = $0314
.var IRQHI = $0315
.var OLDIRQ = $ea81

.var INITMUSIC = $1000
.var PLAYMUSIC = $1006

.var RASTER = $d012
.var YSCROLL = $d011

.var SCROLLREG = $d016

.var CHARSET = $d018

.var IMR = $d01a

.var TIMERINTERRUPT = $dc0d
.var RASTERINTERRUPT = $d019

.var TEXTCOLOR = $0286
.var BORDERCOLOR = $d020
.var BACKGROUNDCOLOR = $d021


start:
    sei

    jsr init

    lda #<irq
    sta IRQLO
    lda #>irq
    sta IRQHI

    lda YSCROLL
    and #$7f
    sta YSCROLL

    lda #$81            // Timer Interrupt
    sta TIMERINTERRUPT

    ldy #160            // Raster Interrupt
    sty RASTER
 
    lda #$01
    sta IMR             // Enable Raster Interrupt

    lda #$00

    jsr INITMUSIC

    cli

    jmp *               // Don't break :)

init:
    lda #$00
    sta BORDERCOLOR
    sta BACKGROUNDCOLOR
    sta TEXTCOLOR
    jsr $e536
    rts

irq:
    lda YSCROLL
    bpl raster          // Trigger is Raster Interrupt
    lda #$1a
    sta CHARSET
    lda #$c8
    sta SCROLLREG

    jsr PLAYMUSIC
    lda TIMERINTERRUPT  // ACK Timer Interrupt, do this or it will start multiple times!
    jmp OLDIRQ

raster:
    inc BORDERCOLOR
    asl RASTERINTERRUPT
    jmp OLDIRQ

.pc = $1000-$7e "Music"
.import binary "music.sid"
