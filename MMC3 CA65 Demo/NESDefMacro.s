; //NOTE: Writing to VRAM outside of VBLANK will cause problems... also note, selecting an address resets PPUSCROLL
; PPU Area 
.define PPUCTRL     $2000       ; N-SBPIAA, N=NMI ON S=SpriteSize B=BackPatternTable P=SpritePatternTable I=IncrementVram 
.define PPUMASK     $2001       ; CCCSBsbM, CCC=ColorEmphesis B=BackgroundOn S=SpriteOn s=spriteClip b=backClip M=Monocrome
.define PPUSTATUS   $2002       ; Read Reset PPUSCROLL and Setup 2006
.define OAMADDR     $2003       ; Sprite Adress 
.define OAMDATA     $2004       ; Sprite Data 
.define PPUSCROLL   $2005       ; X and Y offset 
.define PPUADDR     $2006       ; THIS RESETS PPUSCROLL
.define PPUDATA     $2007       ; 

; CPU Area 
.define JOYPAD1         $4016   
.define JOYPAD2         $4017
.define BUTTON_A        1 << 7  ;    lda buttons
.define BUTTON_B        1 << 6  ;    and #BUTTON_A | BUTTON_B
.define BUTTON_SELECT   1 << 5  ;    beq notPressingAorB
.define BUTTON_START    1 << 4  ;    Handle presses.
.define BUTTON_UP       1 << 3  ;    notPressingAorB: 
.define BUTTON_DOWN     1 << 2
.define BUTTON_LEFT     1 << 1
.define BUTTON_RIGHT    1 << 0

;/* Color defines */
.define COLOR_BLACK             $FF
.define COLOR_WHITE             $30
.define COLOR_RED               $06
.define COLOR_CYAN              $21
.define COLOR_VIOLET            $14
.define COLOR_GREEN             $1A
.define COLOR_BLUE              $12
.define COLOR_YELLOW            $38
.define COLOR_ORANGE            $26
.define COLOR_BROWN             $07
.define COLOR_LIGHTRED          $26
.define COLOR_GRAY1             $3D
.define COLOR_GRAY2             $10
.define COLOR_LIGHTGREEN        $3A
.define COLOR_LIGHTBLUE         $31
.define COLOR_GRAY3             $00

; MMC3 Functions 
.define MMC3_BANK_SELECT    $8000
.define MMC3_BANK_DATA      $8001
.define MMC3_MIRRORING      $4000
.define MMC3_IRQ_DISABLE     STA $E000   ; Any Value will Disable 
.define MMC3_IRQ_ENABLE      STA $E001   ; Any Value will Enable 
.define MMC3_IRQ_RELOAD      STA $C001   ; Any Value Reload IRQ Counter

.macro M_MMC3_IRQ_START_Hex Value            ; Load in Pointers with {ParallaxINT,X}
    MMC3_IRQ_DISABLE
    LDA Value           ; Value to Load 
    STA $C000           ; Loads 
    STA $C001           ; Resets Counter for new Line Count 
    STA $E001           ; Enable IRQ 
.endmacro 

; Bank Changing Subroutine Both $8000 and $A000
; Load Bank Number X for $8000 and Y for $A000
; 86 and 87
.macro M_PRG_ROM_Select_DataHex HIGHLOW, BANK
    LDX HIGHLOW
    STX $8000
    LDX BANK
    STX $8001
.endmacro
; These two are the same but I want to keep them Separate for readability 
; CHR Changing Subroutine Both $8000 and $A000
; Load Bank Number X for $8000 and Y for $A000
; 80=R2 1k, 81=R3 1k, 82=R4 1k, 83=R5 1k, 84=R0 2k, 85=R1 2k,
.macro M_CHR_Select_DataHex HIGHLOW, BANK
    LDX HIGHLOW
    STX $8000
    LDX BANK
    STX $8001
.endmacro

    

; #############################################################
; #############################################################
; MACRO AREA 
; Must be defined before use in code 
; GENERAL AREA 

; Save A, X, Y to Stack 
.macro M_STACK_LOAD
    PHA             ; Push Variables to Stack from A,X,Y 
    TXA
    PHA
    TYA
    PHA
.endmacro

; Load Y, X, A from Stack 
.macro M_STACK_UNLOAD
    PLA                 ; Pull Variables to Stack from Y,X, A
    TAY 
    PLA 
    TAX 
    PLA 
.endmacro

; C If Not Equal Statment in Assembly 
.macro M_IFNOTEQUALY_Addr_CPXValue_Jump Addr, CPXValue, Jump
    LDY Addr
    CPY CPXValue
    BEQ Jump
.endmacro 

; C If Equal Statment in Assembly 
.macro M_IFEQUALY_Addr_CPXValue_Jump Addr, CPXValue, Jump
    LDY Addr
    CPY CPXValue
    BNE Jump
.endmacro 

; EndIf Statment in Assembly Should Mach If OR Else Statment 
.macro M_ENDIF_JumpEnd JumpEnd
    JumpEnd:
.endmacro 

; Else Statment in Assembly 
.macro M_ELSE_Jump_JumpEnd Jump, JumpEnd
    JMP JumpEnd     ; This skips If statment end to EndIf
    Jump:           ; If Statment Lands here 
.endmacro 

; For Loop Statment 
.macro M_FORLOOP_X_StartHex Value
    LDX Value
    @For:
.endmacro

; Return For Statment 
.macro M_NEXT_X_CPXValue CPXValue
    INX
    CPX CPXValue
    BNE @For
.endmacro 

; Delay Loop 
.macro M_DELAY_Hex Value
    LDX Value
:
    DEX
    NOP         ; Waste Time 
    CPX #$00
    BNE :-      ; For Loop Jump Back Up 
.endmacro

; Pointer Load High and Low address 
.macro M_POINTERA_ZPVar_Addr ZPVar, Addr
    LDA #<Addr          ; Load Lower Byte into Location
    STA ZPVar
    LDA #>Addr          ; Load High Byte into Location 
    STA ZPVar+1
.endmacro 
    
; Load Value To A and Save at Address  
.macro M_LOADA_Addr_Hex ADDR, VALUE
    LDA VALUE
    STA ADDR
.endmacro

; Load Value To X and Save at Address  
.macro M_LOADX_Addr_Hex ADDR, VALUE
    LDX VALUE
    STX ADDR
.endmacro

; Load Value To Y and Save at Address  
.macro M_LOADY_Addr_Hex ADDR, VALUE
    LDY VALUE
    STY ADDR
.endmacro

; Write to 2006 To Update Sprites/Background/Palletes
.macro M_PPUADDR_HiAddr_LowAddr HIADDR, LOWADDR
    BIT $2002       ; Reset Write for 2006
    LDX HIADDR
    STX PPUADDR     ; Write High Byte 
    LDX LOWADDR
    STX PPUADDR     ; Write Low Byte
.endmacro 

; Update Scroll Position .. Do this almost last in NMI or IRQ
.macro M_SCROLLING_Xhex_Yhex VALUEX, VALUEY
    LDX VALUEX
    STX $2005
    LDX VALUEY
    STX $2005
.endmacro 

.macro M_ADD_Acc_16_Addr_Value Addr, Value
    LDA Addr
    CLC
    ADC Value
    STA Addr
    BNE :+
    INC Addr+1
    LDA Addr+1
:
.endmacro

.macro M_SUBTRACT_Acc_16_Addr_Value Addr, Value
    LDA Addr
    SEC
    SBC Value
    STA Addr
    BNE :+
    DEC Addr+1
:
.endmacro

; Increase Address .. then Load, Then Compare Then Branch Not Equal 
; Feed Address to increase, Value to check for, and @Local to Branch to 
.macro M_INC_TIMER_X_BNE_Addr_Hhex_Jlocal ADDR, VALUE, JUMP
    INC ADDR
    LDX ADDR
    CPX VALUE
    BNE JUMP
.endmacro

; MMC3 SPECIFIC 

; Bank selection Macro 
.macro M_MMC3_BGCOLOR_Hex Color ; Must define macro before trying to use it 
    BIT $2002       ; Clear address latch used for $2006
    LDA #$3F        ; Setup Background Color 1/2
    STA $2006       ; PPU Reg
    LDA #$00        ; Setup Background Color 2/2
    STA $2006       ; PPU Reg
    LDA Color       ; Set Color Light Pink 
    STA $2007       ; PPU Reg 
    LDA #$00        ; Reset Scroll 
    STA $2006
    STA $2006
.endmacro


; ”PPUSCROLL must always be set after using PPUADDR ($2006). They have a shared internal register and using PPUADDR will overwrite the scroll position.”
; Scrolling Page
.macro M_SCROLL_PAGE_Hex Value
        ;Scroll After sprite load Writing to $2006 $2007 Changes Scroll location 
        BIT $2002
        LDX #$00
        STX $2006   ; Resets PPUCTRL 
        STX $2006
        ; Update Scroll Position
        LDX Value
        CPX #$01
        BNE :+
            LDA #%10001001
            STA PPUCTRL         ; $2000
        :
        CPX #$02
        BNE :+
            DEX
            DEX
            STX Value           ; Reset 0
            LDA #%10001000
            STA PPUCTRL         ; $2000
        :
.endmacro 

