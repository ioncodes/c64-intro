#import "registers.asm"
#import "data.asm"
#import "helpers.asm"

:BasicUpstart2(main)

main:
    sei                     // Disable Interrupts
    lda #$7f                // Disable CIA
    sta CIA1_INTERRUPTS
    sta CIA2_INTERRUPTS

    lda #$35                // Bank out Kernal and Basic
    sta $01                 // $e000-$ffff

    lda #<irq1              // IRQ Low
    ldx #>irq1              // IRQ High
    sta IRQLO               // Interrupt Vector
    stx IRQHI               // Interrupt Vector

    lda #$01                // Enable Raster Interrupts
    sta IMR
    lda #$34                // Interrupt on line 52
    sta RASTER
    lda #$1b                // Clear the High bit (lines 256-318)
    sta YSCROLL
    lda #$0e                // Set Background
    sta BORDER_COLOR        // and Border colors
    lda #$06
    sta BACKGROUND_COLOR
    lda #$00
    sta SPRITES             // Turn off sprites

    jsr clear_screen
    jsr clear_color

    asl INTERRUPT_STATUS    // Ack any previous raster interrupt
    bit CIA1_INTERRUPTS     // reading the interrupt control registers
    bit CIA2_INTERRUPTS     // clears them
    
    lda #$00                // The accumulator needs to be $00 for the music subroutine
    jsr INIT_MUSIC          // Initialize Music

    cli                     // Allow IRQ's

    jmp *                   // Endless Loop

irq1:
    sta reseta1             // Preserve A, X and Y
    stx resetx1             // Registers
    sty resety1             // using self modifying code

    lda #<irq2              // Set IRQ Vector
    ldx #>irq2              // to point to the
                            // next part of the
    sta IRQLO               // Stable IRQ
    stx IRQHI           
    inc RASTER              // set raster interrupt to the next line
    asl INTERRUPT_STATUS    // Ack raster interrupt
    tsx                     // Store the stack pointer! It points to the
    cli                     // return information of irq1.

    nop
    nop
    nop
    nop
    nop
    nop
    nop                     // IRQ Triggers
            
irq2:
    txs                     // Restore stack pointer to point the return
                            // information of irq1, being our endless loop.
    ldx #$09                // Wait exactly 9 * (2+3) cycles so that the raster line
    dex                     // is in the border
    bne *-1

    lda #$00                // Set the screen and border colors
    ldx #$00
    sta BORDER_COLOR
    stx BACKGROUND_COLOR

    lda #<irq3              // Set IRQ to point
    ldx #>irq3              // to subsequent IRQ
    ldy #$68                // at line $68
    sta IRQLO
    stx IRQHI
    sty RASTER
    asl INTERRUPT_STATUS    // Ack RASTER IRQ
 
lab_a1: lda #$00            // Reload A,X,and Y
.label reseta1 = lab_a1+1

lab_x1: ldx #$00
.label resetx1 = lab_x1+1

lab_y1: ldy #$00
.label resety1 = lab_y1+1
 
    rti                     // Return from IRQ

irq3:
    sta reseta2             // Preserve A,X,and Y
    stx resetx2             // Registers
    sty resety2

    ldy #$13                // Waste time so this
    dey                     // IRQ does not try
    bne *-1                 // to reoccur on the
                            // same line!
    lda #$00                // More colors
    ldx #$00
    sta BORDER_COLOR
    stx BACKGROUND_COLOR

    ldx #0
    sta YSCROLL
    ldy RASTER              // Get current raster
    iny                     // Start drawing at next line or the first line will be wrong
!loop:
    lda colors, X
!:  cpy RASTER
    bne !-                  // line cycle
    sta BORDER_COLOR
    cpx #51
    beq !+                  // end
    inx
    iny
    jmp !loop-

!:
    nop                     // little hack to fix the last line
    nop                     // TODO: make it shorter and less hackish
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop                     // Line finished drawing

    /*
        Raster-critical code needs to be done above this comment. Don't forget to resync the rasters!
        This comment marks the beginning of the section which is raster independent (for example music).
        This means we can do things without the raster getting desynced.
    */

    jsr PLAY_MUSIC          // Play the music

    lda #$00                // Make the rest black again
    ldx #$00
    sta BORDER_COLOR
    stx BACKGROUND_COLOR

    lda #<irq1              // Reset Vectors to
    ldx #>irq1              // first IRQ again
    ldy #$34                // at line $34
    sta IRQLO
    stx IRQHI
    sty RASTER
    asl INTERRUPT_STATUS    // Ack RASTER IRQ
 
lab_a2: lda #$00            // Reload A,X,and Y
.label reseta2  = lab_a2+1

lab_x2: ldx #$00
.label resetx2  = lab_x2+1

lab_y2: ldy #$00
.label resety2  = lab_y2+1
 
    rti                     // Return from IRQ

.pc = $1000-$7e "Music"
.import binary "../res/music.sid"