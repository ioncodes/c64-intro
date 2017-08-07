clear_screen:
    lda #$20
    ldx #$00
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    dex
    bne *-13
    rts

clear_color:
    lda #$03
    ldx #$00
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    dex
    bne *-13
    rts