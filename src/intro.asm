:BasicUpstart2(start)

start:
    lda #$00
    tax
    tay
    jsr $1000           // init routine of sid

    jsr init_interrupts

    jmp *               // Don't break :)

init_interrupts:
    sei                 // disable interrupts

    lda #$7f            // Turn off VIC/CIA interrupts
    sta $dc0d
    sta $dd0d

    lda #$01            // enable raster interrupts
    sta $d01a

    lda #$1b            // Enter text mode
    sta $d011

    ldx #$08            // Single color mode
    stx $d016

    ldy #$14            // Use default charset
    sty $d018

    lda #<irq           // Setup interrupt
    ldx #>irq
    sta $0314
    stx $0315

    ldy #160            // Trigger interrupt at this raster
    sty $d012

    lda $dc0d           // Clear pending interrupts
    lda $dd0d
    asl $d019

    cli                 // Enable interrupts

    rts

irq:
    jsr $1006           // Play sid sub routine
    inc $d020
    asl $d019           // The interrupt triggered, so clear the interrupt flag
    jmp $ea81           // Return from interrupt

.pc = $1000-$7e "Music"
.import binary "music.sid"
