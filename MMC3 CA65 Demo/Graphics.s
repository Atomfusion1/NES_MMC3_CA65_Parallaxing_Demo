; Sprite and Background Setup


; Lines to Trigger IRQ
ParallaxINT:
    .byte $75, $29, $11, $11

ParallaxData: 
    .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19 

PaletteData:
    .byte $0F,$07,$17,$37   ; Background palette data
    .byte $0F,$05,$16,$27   ; Background palette data
    .byte $0F,$03,$12,$22   ; Background palette data
    .byte $0F,$0B,$00,$10   ; Background palette data
    .byte $0F,$16,$27,$18   ; Sprite palette data
    .byte $0F,$1A,$30,$27   ; Sprite palette data
    .byte $0F,$16,$30,$27   ; Sprite palette data
    .byte $0F,$0F,$36,$17   ; Sprite palette data


; Sprite Location Data In Binary 
SpriteData:
;Man    Y pos, Tile, Sprite (1-4), X pos
    .byte $60, $00, $00, $78
    .byte $60, $01, $00, $80
    .byte $66, $02, $00, $78
    .byte $66, $03, $00, $80
    .byte $6E, $04, $00, $78
    .byte $6E, $05, $00, $80
    .byte $76, $06, $00, $78
    .byte $76, $07, $00, $80
; FireBallData
    .byte $00, $64, $01, $00

WorldData1:
    .incbin "Parallax2.bin" ; Binary File hexed.it

WorldData2:
    .incbin "Parallax3.bin" ; Binary File hexed.it

; Background Data in binary file 32 x 30 grid of data 
; https://hexed.it/ Settings: Bytes per row 32, Show 0x00 bytes as space .. Welcome Background 
; ; NES Screen Tool https://forums.nesdev.org/viewtopic.php?t=15648
; Sprite Data Edit in yy-chr
; Swap in Bank 2 into graphics include
.include "MMC3Graphics.s"

.segment "CHR"
    .incbin ".\Graphics\1kTestA.chr"      ; Im just using this for filler to show bank switching 
    .incbin ".\Graphics\1kTestB.chr"      ; Im just using this for filler to show bank switching 
    .incbin ".\Graphics\1kTestB.chr"      ; Im just using this for filler to show bank switching 
    .incbin ".\Graphics\1kTestA.chr"      ; Im just using this for filler to show bank switching 
    .incbin ".\Graphics\2kTestA.chr"      ; Im just using this for filler to show bank switching 
    .incbin ".\Graphics\2kTestB.chr"      ; Im just using this for filler to show bank switching    
    .incbin ".\Graphics\4kSprites.chr"     ; sprites second 
    .incbin ".\Graphics\4kBack.chr"        ; background first 
    .incbin ".\Graphics\CloudParallax.chr"
    .incbin ".\Graphics\CloudBK.chr"