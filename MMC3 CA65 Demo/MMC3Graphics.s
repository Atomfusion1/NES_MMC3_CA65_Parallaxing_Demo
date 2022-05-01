; This code is for loading Graphics into 2x2kb and 4x1kb section 

;CHR map mode →	$8000.D7 = 0	$8000.D7 = 1
;PPU Bank	    Value of MMC3 register
;$0000-$03FF	    R0	        R2    R0 and R1 are 2K Banks 
;$0400-$07FF	    ^           R3          
;$0800-$0BFF	    R1	        R4
;$0C00-$0FFF	    ^           R5          
;$1000-$13FF	    R2	        R0   
;$1400-$17FF	    R3          ^ 
;$1800-$1BFF	    R4	        R1
;$1C00-$1FFF	    R5          ^

;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;;;; BankSwitching Code MMC3
; Working  This Way Protects from Bus Conflicts
; All this code to load in CHR Bank 2 
LOADCHR:
    LDX #$08            ; Start of Page to load Add 8 Hex per CHR .. CHR 3 = $10 or 16 
    LDA #$80            ; Starting Address for $8000 0,1,2,3,4,5,6 
    LDY #$00            ; Loop Counter 
    LoadPPU2k:          ; load two sets 2x2k to make first 4k (BACKGROUND)
        STA $8000       ; Bank Selection with Inversion 
        STX $8001       ; Selection of Bank 
        INY
        INX             ; Increase X x 2 as 2k 
        INX
        CLC
        ADC #$01
        CPY #$02        ; For loop 
        BNE LoadPPU2k
    LoadPPU1k:              ; load 4 * 1k sets to make FORGROUND 4k
        STA $8000           ; Bank Selection with Inversion 
        STX $8001           ; Selection of Bank 
        INY
        INX                 ; Increase X * x as 1k 
        CLC
        ADC #$01
        CPY #$06        ; For loop
        BNE LoadPPU1k
RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;  

LOADPALETTES1:
    M_PPUADDR_HiAddr_LowAddr #$3F,#$00  ; Clear address latch used for $2006

    M_FORLOOP_X_StartHex #$00
    LDA PaletteData, X  ; Load Array of Palette Data 
    STA $2007           ; Save Pallet of X 
    M_NEXT_X_CPXValue #$20
RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOADSPRITES:
    M_FORLOOP_X_StartHex #$00
    CLC
    LDA SpriteData, X   ; Load Sprite Array
    ADC SpriteY
    STA $0200, X 
    INX 
    LDA SpriteData, X   ; Load Sprite Array
    STA $0200, X  
    INX 
    LDA SpriteData, X   ; Load Sprite Array
    STA $0200, X  
    INX 
    CLC
    LDA SpriteData, X   ; Load Sprite Array
    ADC SpriteX
    STA $0200, X    
    M_NEXT_X_CPXValue #$20  
RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;

LOADFIREBALL:
    M_FORLOOP_X_StartHex #$20
    CLC
    LDA FireBallSpriteY
    STA $0200, X 
    INX 
    LDA SpriteData, X   ; Load Sprite Array
    STA $0200, X  
    INX 
    LDA SpriteData, X   ; Load Sprite Array
    STA $0200, X  
    INX 
    CLC
    LDA FireBallSpriteX
    STA $0200, X    
    M_NEXT_X_CPXValue #$24
    M_IFNOTEQUALY_Addr_CPXValue_Jump FireBallSpriteX, #$FF, @4
        CLC
        ADC #$08
        STA FireBallSpriteX
        BCC :+
            M_LOADA_Addr_Hex FireBallSpriteX, #$FF
            M_LOADA_Addr_Hex FireBallSpriteY, #$FF
        :
    @4:
RTS

LOADBACKGROUND:
; Initialize world to point to world data
; Load Lower Byte of WorldData Location
    BIT $2002   ; This Read Reset 2006 High / Low Byte locations This loaded $2000 into PPU 
    STA $2006   ; Start Page to Load info 
    LDA #$00
    STA $2006
    ; Reset X and Y positions 
    LDX #$00
    LDY #$00
LoadWorld:
    LDA (world), Y
    STA $2007
    INY
    CPX #$03                
    BNE :+                  ; Goes to first : after it 
    CPY #$C0                ; X = 3 and Y = C0
    BEQ DoneLoadingWorld    ; Breaks out of loop 
:                           ; Unnamed Label BNE:+ 
    CPY #$00
    BNE LoadWorld
        INX
        INC world+1     ; High Byte add 1 so same as adding 256 to address 
        JMP LoadWorld   ; Large Loop 
    DoneLoadingWorld:
        ; the last 64 bytes in a bin file created from NESST has the attribute table in it so lets load it in also 
    Attributes:
        LDA (world), Y
        STA $2007
        INY
        CPX #$03                
        BNE :+                  ; Goes to first : after it 
        CPY #$C0                ; X = 3 and Y = C0
        BEQ DoneLoadingAttributes    ; Breaks out of loop 
    :                           ; Unnamed Label BNE:+ 
        CPY #$00
        BNE Attributes
    DoneLoadingAttributes:

    LDX #$00        ; Reset Scroll Position
    STX $2006
    STX $2006
RTS

