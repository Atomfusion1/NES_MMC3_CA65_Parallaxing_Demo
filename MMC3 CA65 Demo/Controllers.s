; At the same time that we strobe bit 0, we initialize the ring counter
; so we're hitting two birds with one stone here
READJOY:
    LDA #$01
    ; While the strobe bit is set, Buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
    STA JOYPAD1
    STA Buttons
    LSR a        ; now A is 0
    ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 Buttons (newly reloaded) to be read from JOYPAD1.
    STA JOYPAD1
@loop:
    LDA JOYPAD1
    LSR a	       ; bit 0 -> Carry
    ROL Buttons  ; Carry -> bit 0; bit 7 -> Carry
    BCC @loop
; Finished getting Buttons Read them 

; Button Up
    LDA Buttons
    AND #BUTTON_UP
    BEQ :+
    ; Handle presses.
    DEC SpriteY
    M_IFEQUALY_Addr_CPXValue_Jump Speed,#$01,@4
        DEC SpriteY
        DEC SpriteY
        DEC SpriteY
    @4:
:

; Button Down
    LDA Buttons
    AND #BUTTON_DOWN
    BEQ :+
    ; Handle presses.
    INC SpriteY
    M_IFEQUALY_Addr_CPXValue_Jump Speed,#$01,@3
        INC SpriteY
        INC SpriteY
        INC SpriteY
    @3:
:

; Button Left
    LDA Buttons
    AND #BUTTON_LEFT
    BEQ :+
    ; Handle presses.
    DEC SpriteX
    DEC SpriteX
    M_IFEQUALY_Addr_CPXValue_Jump Speed,#$01,@2
        DEC SpriteX
        DEC SpriteX
        DEC SpriteX
    @2:
    M_LOADX_Addr_Hex FlipSprites, #$01
:

; Button Right
    LDA Buttons
    AND #BUTTON_RIGHT
    BEQ :+
    ; Handle presses.
    INC SpriteX
    INC SpriteX
    M_IFEQUALY_Addr_CPXValue_Jump Speed,#$01,@1
        INC SpriteX
        INC SpriteX
        INC SpriteX
    @1:
    M_LOADX_Addr_Hex FlipSprites, #$00
:
    M_LOADX_Addr_Hex Speed, #$0
; Button A
    LDA Buttons
    AND #BUTTON_A
    BEQ :+
    ; Handle presses.
    M_LOADX_Addr_Hex Speed, #$1
:

; Button B
    LDA Buttons
    AND #BUTTON_B
    BEQ :+
    ; Handle presses.
    M_IFEQUALY_Addr_CPXValue_Jump FireBallSpriteX, #$FF, @End
        LDA SpriteY
        CLC
        ADC #$6A
        STA FireBallSpriteY
        LDA SpriteX
        CLC
        ADC #$83 
        STA FireBallSpriteX
    @End:
:

; Button Select
    LDA Buttons
    AND #BUTTON_SELECT
    BEQ :+
    ; Handle presses.
:

; Button Start
    LDA Buttons
    AND #BUTTON_START
    BEQ :+
    ; Handle presses.
:

RTS