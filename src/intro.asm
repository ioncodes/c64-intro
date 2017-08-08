#import "registers.asm"
#import "data.asm"
#import "helpers.asm"

:BasicUpstart2(main)

main:
    sei                     // Disable Interrupts

    lda #$00                // Set Background
    sta BORDER_COLOR        // and Border colors
    sta BACKGROUND_COLOR
    sta $0286

    jsr $e544

    ldy #0
!:
    lda revers_text, y
    beq !+
    sta $0400, y
    iny
    bne !-

!:
    lda #$7f                // Disable CIA
    sta CIA1_INTERRUPTS
    sta CIA2_INTERRUPTS

    lda $dc0d
    lda $dd0d

    lda #$1b                // Clear the High bit (lines 256-318)
    sta YSCROLL

    lda #$0                 // Interrupt on line 0
    sta RASTER

    lda #<irq              // IRQ Low
    ldx #>irq              // IRQ High
    sta IRQLO               // Interrupt Vector
    stx IRQHI               // Interrupt Vector

    lda #$01                // Enable Raster Interrupts
    sta IMR
    
    lda $d019
    sta $d019

    cli                     // Allow IRQ's

    jmp *                   // Endless Loop

revers_text:       .text "******** ein graustufenverlauf  ********"
                    .text "******** ein roter farbverlauf  ********"
                    .text "******** ein blauer farbverlauf ********"

                    .for(var i = 0; i < 20; i++) { .byte $20,$a0 }  
                    .byte $00

irq:
    lda $d019 
    sta $d019

    ldx #0
    lda #50 
!:                  
    cmp $d012
    bne !-

!loop:
    ldy wartezeiten, x 
!:
    dey            
    bne !-

    nop
    nop

    lda farbtabelle, x  
    sta $d021   

    inx
    cpx #4 * 8       
    bne !loop-

    lda #0     
    sta $d021         
    jmp $ea7e

wartezeiten:        .byte 8, 1, 8, 8, 8, 8, 8, 8
                    .byte 8, 1, 8, 8, 8, 8, 8, 8
                    .byte 8, 1, 8, 8, 8, 8, 8, 8
                    .byte 8, 1, 8, 8, 8, 8, 8, 8

farbtabelle:        .byte 11,12,15,01,01,15,12,0 
                    .byte 09,02,08,10,15,07,01,0 
                    .byte 06,14,03,01,01,03,14,0  
                    .byte 03,13,01,13,03,13,05,0 