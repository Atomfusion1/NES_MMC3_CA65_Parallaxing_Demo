;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Header Settings For Starter NES roms this is boiler plate 
; Compile with ca65
; .\cc65\bin\ca65 helloNES.asm -o helloNES.o --debug-info
; .\cc65\bin\ld65 helloNES.o -o helloNES.nes -t nes --dbgfile helloNES.dbg
; Basic NMOS 6502 http://www.6502.org/tutorials/6502opcodes.html
; Start Tutorial Warning they are in NESASM https://nerdy-nights.nes.science/
; https://github.com/ddribin/nerdy-nights
; https://github.com/JamesSheppardd/Nerdy-Nights-ca65-Translation

; Include Definitions and Macros before any other code 
.include "NESDefMacro.s"
; Graphics Swapping to Come 

; Start NES Header
.segment "HEADER"
.include "Header.s"

; Setup ZeroPage Variables 
.segment "ZEROPAGE"
world:          .res 2  ; 16 Bit Value (High/Low Bits need to be inserted ) used to load sprites (pointer)
hTimer:         .res 1  ; Parallax timer 
Timer:          .res 1  ; VSync Timer  
sTimer:         .res 2  ; Second Timer 
fTimer:         .res 1  ; FrameTimer for X 
fTimer1:        .res 1  ; FrameTimer for X 
fTimer2:        .res 1  ; FrameTimer for X 
fTimer3:        .res 1  ; FrameTimer for X 
Parallax:       .res 1  ; Value to wach for Parallax 
ScrollX:        .res 1  ; Scroll X High/Low 
ScrollX1:       .res 1  ; Scroll X High/Low 
ScrollX2:       .res 1  ; Scroll X High/Low 
ScrollX3:       .res 1  ; Scroll X High/Low 
CounterINT:     .res 1  ; 
SpriteLocation: .res 2  ;
Buttons:        .res 1  ; Collect Button Information 
SpriteX:        .res 1  ; Sprite X position 
SpriteY:        .res 1  ; Sprite Y position
FlipSprites:    .res 1  ; Turn Around 
Speed:          .res 1  ; Speed Multiply
FireBallSpriteX:.res 1  ; fireball sprite
FireBallSpriteY:.res 1  ; Fireball X 
Temp:           .res 1  ; Temp Storage for Passing to macros 

; Setup Interrupts (CPU Hardware Timers Essentially)
.segment "VECTORS"
    ; Non-maskable interrupt NMI (NTSC = 60 Times per Second)
    ; Connected to the PPU and detects vertical blanking 
    .addr NMI
    ; When the processor first turns on or is reset, it will jump to the label reset: Located at $FFFD
    ; If your nes.cfg file is off this is what breaks (Check Hex editor and Last line you should see 6 bytes )
    .addr RESET
    ; External interrupt IRQ (unused)
    .addr IRQ; MMC3 use etc. 

; Internal NES RAM
.segment "RAM"


; CAUTION !!  the Game does not know what bank is what, if you get this wrong your code will jump to another bank but may still work 
; I am actually using that for the color swap to work without changing the JSR routine 
; The compiler looks at all banks at the same time for Code (ie no naming the function the same)
; but the NES only sees the Banks that are assigned for Addressing
; Want more Banks Add them in nes.cfg in *2 and Header PRGROM 
; Swapable Bank 64k
.segment "BANK0"
COLOR1:         ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color  
    M_MMC3_BGCOLOR_Hex #COLOR_BLACK
RTS

; Swapable Bank 
.segment "BANK1"
COLOR1I:        ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color  
    M_MMC3_BGCOLOR_Hex #COLOR_GRAY2
RTS

; Swapable Bank 
.segment "BANK2"
COLOR2:         ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color 
    M_MMC3_BGCOLOR_Hex #COLOR_LIGHTBLUE
RTS

; Swapable Bank 
.segment "BANK3"
COLOR2I:        ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color 
    M_MMC3_BGCOLOR_Hex #COLOR_GREEN
RTS

; Swapable Bank 
.segment "BANK4"
COLOR3:         ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color 
    M_MMC3_BGCOLOR_Hex #COLOR_VIOLET
RTS

; Swapable Bank 
.segment "BANK5"
COLOR3I:        ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color 
    M_MMC3_BGCOLOR_Hex #COLOR_LIGHTGREEN ; Macro Swap Banks 
RTS

; IMPORTANT NOTE MMC3 Must Start Reset and Setup PRG ROM at $E000, Its the only known fixed memory area 
; Start Memory at $E000
.segment "PAGE_FIXED"
    .include "Reset.s"  ; Basic Reset Call and Memory Setup

; This protects from entering into NMI before 
; Also you can do CPU Related things while the Screen is being Drawn as long as you end in a loop 
; before NMI triggers 
Loop:
    JMP Loop    


; This is where you do everything to control the game (PPU should go here)
; You can use a second loop to do CPU calulations while the screen is drawing IE collisions 
; But make sure its finished before the next VBlank Trigger 
;NMI Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NMI:  ; Just use Background in First 4k and Sprites in second 4k with 8x8 tiles
    JSR READJOY
    JSR LOADSPRITES             ; Do this first as it messed up X and Y 
    JSR LOADFIREBALL
    INC fTimer  


    
    M_INC_TIMER_X_BNE_Addr_Hhex_Jlocal Timer, #$3D, @OUT   ; Add Timer BNE if at value else @local 
        M_LOADX_Addr_Hex Timer, #$01 ; 
        INC sTimer
@OUT:

    M_INC_TIMER_X_BNE_Addr_Hhex_Jlocal hTimer, #$04, @OUT1
        LDX #$00
        STX hTimer
        

        M_IFEQUALY_Addr_CPXValue_Jump Parallax, #$08, @2
            LDY #$00
            STY Parallax
        @2:
    ; CHANGE CHR IN MMC3 Location $85 using Array 
        M_CHR_Select_DataHex #$85, {ParallaxData, Y}        ; Change CHR 
        INY                                                 ; Must use {} for using pointer in macro 
        STY Parallax
@OUT1:

    M_IFEQUALY_Addr_CPXValue_Jump fTimer, #$00, @13
        INC ScrollX  
    @13:

    LDA #$02                                            ; Upload 256 bytes of data from CPU page XX00-XXFF to OAM (Draw Screen Setup for VBlank)
    STA $4014                                           ; set the high byte (02) of the RAM address, start the transfer

; On The Fly PRG ROM Selection Code :
    M_PRG_ROM_Select_DataHex #$86,#$00  ; Load $86 Low bank 8000 #0 
    M_PRG_ROM_Select_DataHex #$87,#$01  ; Load $87 High bank A000 #1
    
    JSR COLOR1          ; Jump to Color in Bank 

    ; Reset IRQ Counter for new Line 
    M_LOADX_Addr_Hex CounterINT, #$00  

    M_MMC3_IRQ_START_Hex {ParallaxINT,X}                ; Macro IRQ Start

    M_SCROLL_PAGE_Hex ScrollX
    M_SCROLLING_Xhex_Yhex sTimer, #$00
RTI                                                     ; Interrupt Return.. RTS for normal Returns 
; NMI FINISH ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





; IRQ START ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IRQ:
    ; IRQ Trigger location is dependent on Mirroring, Background to Sprite location in PPU
    ; This IRQ should Save DATA as it will Jump From your Code and you may need A,X,Y values 
    M_STACK_LOAD                                        ; Macro Store A, X, Y into Stack
    M_DELAY_Hex #$04                                    ; Delay Processor (Have Loop in Blank Time)

    M_INC_TIMER_X_BNE_Addr_Hhex_Jlocal CounterINT, #$01, @OUT

@OUT:
    M_IFEQUALY_Addr_CPXValue_Jump CounterINT, #$01, @OUT3
        CLC
        LDA fTimer
        ROL            ; divide by 8 
        STA fTimer1
        M_SCROLLING_Xhex_Yhex fTimer, #$00
    M_ENDIF_JumpEnd @OUT3

    CPX #$02
    BNE :+
        LDA fTimer
       ; ROL            ; divide by 4 
        STA fTimer2
        CLC
        ADC fTimer
        STA fTimer2
        M_SCROLLING_Xhex_Yhex fTimer2, #$00
:

    CPX #$03
    BNE :+
        LDA fTimer
        ROL             ; divide by 2 
        ROL
        STA fTimer2 
        M_SCROLLING_Xhex_Yhex fTimer2, #$00
:

    CPX #$04
    BNE :+
        LDA fTimer
        ROL             ; divide by 2 
        ROL
        STA fTimer3 
        CLC
        ADC fTimer
        STA fTimer3
        M_SCROLLING_Xhex_Yhex fTimer3, #$00
:

    LDX CounterINT
    M_MMC3_IRQ_START_Hex {ParallaxINT,X}        ; Macro IRQ Start     
    CPX #$04
    BNE:+
        MMC3_IRQ_DISABLE
:
    M_STACK_UNLOAD                              ; Macro Retrive A, X, Y From Stack 
RTI ; 
; IRQ FINISH ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; Area For Subroutines 
; This is Just Graphics Arrays and Data Storage/Setup Not for Code 

.include "Controllers.s"
.include "Graphics.s"


.end   ; End Assembly can put anything past this and the compiler will ignore it 




