        .org $800
        .setcpu "65C02"

        .include "apple2.inc"
        .include "../inc/prodos.inc"
        .include "../inc/auxmem.inc"

        .include "a2d.inc"

ROMIN2          := $C082
DATELO  := $BF90
DATEHI  := $BF91


L0000           := $0000
L0020           := $0020
L1000           := $1000
L4021           := $4021

        jmp     copy2aux

L0803:  .byte   $00,$09,$4D,$44,$2E,$53,$59,$53
        .byte   $54,$45,$4D,$03,$04,$08,$00,$09
L0813:  .byte   $00,$02
L0815:  .byte   $00,$03,$00,$00,$04
L081A:  .byte   $00,$23,$08,$02,$00,$00,$00,$01
L0822:  .byte   $00
L0823:  .byte   $00

stash_stack:  .byte   $00
.proc copy2aux

        start := start_da
        end   := last

        tsx
        stx     L0803
        sta     ALTZPOFF
        lda     ROMIN2
        lda     DATELO
        sta     L090F
        lda     DATEHI
        sta     L0910
        lda     #<start
        sta     STARTLO
        lda     #>start
        sta     STARTHI
        lda     #<end
        sta     ENDLO
        lda     #>end
        sta     ENDHI
        lda     #<start
        sta     DESTINATIONLO
        lda     #>start
        sta     DESTINATIONHI
        sec
        jsr     AUXMOVE

        lda     #<start
        sta     XFERSTARTLO
        lda     #>start
        sta     XFERSTARTHI
        php
        pla
        ora     #$40            ; set overflow: aux zp/stack
        pha
        plp
        sec                     ; control main>aux
        jmp     XFER
.endproc

L086B:  sta     ALTZPON
        sta     L0823
        stx     stash_stack
        lda     LCBANK1
        lda     LCBANK1
        lda     L0823
        beq     L08B3
        ldy     #$C8
        lda     #$0E
        ldx     #$08
        jsr     L4021
        bne     L08B3
        lda     L0813
        sta     L0815
        sta     L081A
        sta     L0822
        ldy     #$CE
        lda     #$14
        ldx     #$08
        jsr     L4021
        bne     L08AA
        ldy     #$CB
        lda     #$19
        ldx     #$08
        jsr     L4021
L08AA:  ldy     #$CC
        lda     #$21
        ldx     #$08
        jsr     L4021
L08B3:  ldx     L0803
        txs
        rts

start_da:
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1
        jmp     L0986

ok_button_rect:
        .byte   $6A,$00,$2E,$00,$B5,$00,$39,$00
cancel_button_rect:
        .byte   $10,$00,$2E,$00,$5A,$00,$39,$00

up_arrow_rect:
        .word   $AA,$0A,$B4,$14
down_arrow_rect:
        .byte   $AA,$00,$1E,$00,$B4,$00,$28,$00
fill_rect_params3:
        .byte   $25,$00,$14,$00,$3B,$00,$1E,$00
fill_rect_params7:  .byte   $51,$00,$14,$00,$6F,$00,$1E,$00

fill_rect_params6:  .byte   $7F,$00,$14,$00,$95,$00,$1E,$00
L08FC:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $FF

.proc white_pattern
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.endproc
        .byte   $FF
L090E:  .byte   $00
L090F:  .byte   $00
L0910:  .byte   $00
L0911:  .byte   $1A
L0912:  .byte   $02
L0913:  .byte   $55
L0914:  .byte   $17,$09,$04,$20,$20,$20,$20
L091B:  .byte   $2B,$00,$1E,$00
L091F:  .byte   $22,$09,$02
L0922:  .byte   $20
L0923:  .byte   $20
L0924:  .byte   $57,$00,$1E,$00
L0928:  .byte   $2B,$09,$03,$20,$20,$20
L092E:  .byte   $85,$00,$1E,$00
L0932:  .byte   $35,$09,$02
L0935:  .byte   $20
L0936:  .byte   $20

.proc get_input_params
L0937:  .byte   $00
L0938:  .byte   $00
L0939:  .byte   $00
L093A:  .byte   $00
L093B:  .byte   $00
.endproc

L093C:  .byte   $00
L093D:  .byte   $00
L093E:  .byte   $64
L093F:  .byte   $00
L0940:  .byte   $00
L0941:  .byte   $00
L0942:  .byte   $00
L0943:  .byte   $00,$00,$00,$00
L0947:  .byte   $64,$00,$01

.proc fill_mode_params
mode:   .byte   $02
.endproc
        .byte   $06

.proc create_window_params
id:     .byte   $64
flags:  .byte   $01
title:  .addr   0
hscroll:.byte   0
vscroll:.byte   0
hsmax:  .byte   0
hspos:  .byte   0
vsmax:  .byte   0
vspos:  .byte   0
        .byte   0, 0            ; ???
w1:     .word   100
h1:     .word   100
w2:     .word   $1F4
h2:     .word   $1F4
.proc box
left:   .word   $B4
top:    .word   $32
saddr:  .addr   A2D_SCREEN_ADDR
stride: .word   A2D_SCREEN_STRIDE
hoff:   .word   0
voff:   .word   0
width:  .word   $C7
height: .word   $40
.endproc
.endproc
        ;; ???
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $FF,$00,$00,$00,$00,$00,$04,$02
        .byte   $00,$7F,$00,$88,$00,$00

L0986:  jsr     L0E00
        lda     L0910
        lsr     a
        sta     L0913
        lda     L090F
        and     #$1F
        sta     L0911
        lda     L0910
        ror     a
        lda     L090F
        ror     a
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        sta     L0912
        A2D_CALL A2D_CREATE_WINDOW, create_window_params
        lda     #$00
        sta     L090E
        jsr     L0CF0
        A2D_CALL $2B
L09BB:  A2D_CALL A2D_GET_INPUT, get_input_params
        lda     get_input_params::L0937
        cmp     #$01
        bne     L09CE
        jsr     L0A45
        jmp     L09BB

L09CE:  cmp     #$03
        bne     L09BB
        lda     get_input_params::L0939
        bne     L09BB
        lda     get_input_params::L0938
        cmp     #$0D
        bne     L09E1
        jmp     L0A92

L09E1:  cmp     #$1B
        bne     L09E8
        jmp     L0ABB

L09E8:  cmp     #$08
        beq     L0A26
        cmp     #$15
        beq     L0A33
        cmp     #$0A
        beq     L0A0F
        cmp     #$0B
        bne     L09BB
        A2D_CALL A2D_FILL_RECT, up_arrow_rect
        lda     #$03
        sta     L0B50
        jsr     L0B17
        A2D_CALL A2D_FILL_RECT, up_arrow_rect
        jmp     L09BB

L0A0F:  A2D_CALL A2D_FILL_RECT, down_arrow_rect
        lda     #$04
        sta     L0B50
        jsr     L0B17
        A2D_CALL A2D_FILL_RECT, down_arrow_rect
        jmp     L09BB

L0A26:  sec
        lda     L090E
        sbc     #$01
        bne     L0A3F
        lda     #$03
        jmp     L0A3F

L0A33:  clc
        lda     L090E
        adc     #$01
        cmp     #$04
        bne     L0A3F
        lda     #$01
L0A3F:  jsr     L0DB4
        jmp     L09BB

L0A45:  A2D_CALL A2D_QUERY_TARGET, get_input_params::L0938
        A2D_CALL A2D_SET_FILL_MODE, fill_mode_params
        A2D_CALL A2D_SET_PATTERN, white_pattern
        lda     L093D
        cmp     #$64
        bne     L0A63
        lda     L093C
        bne     L0A64
L0A63:  rts

L0A64:  cmp     #$02
        bne     L0A63
        jsr     L0C54
        cpx     #$00
        beq     L0A63
        txa
        sec
        sbc     #$01
        asl     a
        tay
        lda     L0A84,y
        sta     L0A82
        lda     L0A85,y
        sta     L0A83
L0A82           := * + 1
L0A83           := * + 2
        jmp     L1000

L0A84:  .byte   $92
L0A85:  .byte   $0A,$BB,$0A,$C9,$0A,$D7,$0A,$E5
        .byte   $0A,$E5,$0A,$E5,$0A
L0A92:  A2D_CALL A2D_FILL_RECT, ok_button_rect
        sta     RAMWRTOFF
        lda     L0912
        asl     a
        asl     a
        asl     a
        asl     a
        asl     a
        ora     L0911
        sta     DATELO
        lda     L0913
        rol     a
        sta     DATEHI
        sta     RAMWRTON
        lda     #$01
        sta     L0C1A
        jmp     L0C1B

L0ABB:  A2D_CALL A2D_FILL_RECT, cancel_button_rect
        lda     #$00
        sta     L0C1A
        jmp     L0C1B

        txa
        pha
        A2D_CALL A2D_FILL_RECT, up_arrow_rect
        pla
        tax
        jsr     L0AEC
        rts

        txa
        pha
        A2D_CALL A2D_FILL_RECT, down_arrow_rect
        pla
        tax
        jsr     L0AEC
        rts

        txa
        sec
        sbc     #$04
        jmp     L0DB4

L0AEC:  stx     L0B50
L0AEF:  A2D_CALL A2D_GET_INPUT, get_input_params
        lda     get_input_params::L0937
        cmp     #$02
        beq     L0B02
        jsr     L0B17
        jmp     L0AEF

L0B02:  lda     L0B50
        cmp     #$03
        beq     L0B10
        A2D_CALL A2D_FILL_RECT, down_arrow_rect
        rts

L0B10:  A2D_CALL A2D_FILL_RECT, up_arrow_rect
        rts

L0B17:  jsr     L0DF2
        lda     L0B50
        cmp     #$03
        beq     L0B2C
        lda     #$59
        sta     $07
        lda     #$0B
        sta     $08
        jmp     L0B34

L0B2C:  lda     #$51
        sta     $07
        lda     #$0B
        sta     $08
L0B34:  lda     L090E
        asl     a
        tay
        lda     ($07),y
        sta     L0B45
        iny
        lda     ($07),y
        sta     L0B46
L0B45           := * + 1
L0B46           := * + 2
        jsr     L1000
        A2D_CALL $0C, L08FC
        jmp     L0D73

L0B50:  .byte   $00,$00,$00,$61,$0B,$73,$0B,$85
        .byte   $0B,$00,$00,$97,$0B,$A4,$0B,$B1
        .byte   $0B
        clc
        lda     L0911
        adc     #$01
        cmp     #$20
        bne     L0B6D
        lda     #$01
L0B6D:  sta     L0911
        jmp     L0BBE

        clc
        lda     L0912
        adc     #$01
        cmp     #$0D
        bne     L0B7F
        lda     #$01
L0B7F:  sta     L0912
        jmp     L0BCB

        clc
        lda     L0913
        adc     #$01
        cmp     #$64
        bne     L0B91
        lda     #$00
L0B91:  sta     L0913
        jmp     L0C0D

        dec     L0911
        bne     L0BA1
        lda     #$1F
        sta     L0911
L0BA1:  jmp     L0BBE

        dec     L0912
        bne     L0BAE
        lda     #$0C
        sta     L0912
L0BAE:  jmp     L0BCB

        dec     L0913
        bpl     L0BBB
        lda     #$63
        sta     L0913
L0BBB:  jmp     L0C0D

L0BBE:  lda     L0911
        jsr     div_by_10_then_ascii
        sta     L0922
        stx     L0923
        rts

L0BCB:  lda     L0912
        asl     a
        clc
        adc     L0912
        tax
        dex
        lda     #$2B
        sta     $07
        lda     #$09
        sta     $08
        ldy     #$02
L0BDF:  lda     L0BE9,x
        sta     ($07),y
        dex
        dey
        bpl     L0BDF
        rts

L0BE9:  .byte   "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug"
        .byte   "Sep","Oct","Nov","Dec"
L0C0D:  lda     L0913
        jsr     div_by_10_then_ascii
        sta     L0935
        stx     L0936
        rts

L0C1A:  brk
L0C1B:  A2D_CALL A2D_DESTROY_WINDOW, L0947
        jsr     UNKNOWN_CALL
        .byte   $0C
        .addr   L0000
        ldx     #$09
L0C29:  lda     L0C4B,x
        sta     L0020,x
        dex
        bpl     L0C29
        lda     L0C1A
        beq     L0C48
        lda     L0912
        asl     a
        asl     a
        asl     a
        asl     a
        asl     a
        ora     L0911
        tay
        lda     L0913
        rol     a
        tax
        tya
L0C48:  jmp     L0020

L0C4B:  sta     RAMRDOFF
        sta     RAMWRTOFF
        jmp     L086B

L0C54:  lda     get_input_params::L0938
        sta     L093F
        lda     get_input_params::L0939
        sta     L0940
        lda     get_input_params::L093A
        sta     L0941
        lda     get_input_params::L093B
        sta     L0942
        A2D_CALL A2D_MAP_COORDS, L093E
        A2D_CALL A2D_SET_POS, L0943
        ldx     #$01
        lda     #$C4
        sta     L0C8A
        lda     #$08
        sta     L0C8A+1
L0C84:  txa
        pha
        A2D_CALL A2D_TEST_BOX, $1000, L0C8A
        bne     L0CA6
        clc
        lda     L0C8A
        adc     #$08
        sta     L0C8A
        bcc     L0C9C
        inc     L0C8A+1
L0C9C:  pla
        tax
        inx
        cpx     #$08
        bne     L0C84
        ldx     #$00
        rts

L0CA6:  pla
        tax
        rts

border_rect:  .byte   $04,$00,$02,$00,$C0,$00,$3D,$00
date_rect:  .byte   $20,$00,$0F,$00,$9A,$00,$23,$00

label_ok:
        A2D_DEFSTRING {"OK         ",$0D} ; ends with newline
label_cancel:
        A2D_DEFSTRING "Cancel  ESC"
label_uparrow:
        A2D_DEFSTRING $0B ; up arrow
label_downarrow:
        A2D_DEFSTRING $0A ; down arrow

label_cancel_pos:
        .word   $15,$38
label_ok_pos:
        .word   $6E,$38

label_uparrow_pos:
        .word   $AC,$13
label_downarrow_pos:
        .word   $AC,$27

        ;; Params for $0A call
L0CEE:  .byte   $01,$01

L0CF0:  A2D_CALL A2D_SET_BOX1, create_window_params::box
        A2D_CALL A2D_DRAW_RECT, border_rect
        A2D_CALL $0A, L0CEE     ; ????
        A2D_CALL A2D_DRAW_RECT, date_rect
        A2D_CALL A2D_DRAW_RECT, ok_button_rect
        A2D_CALL A2D_DRAW_RECT, cancel_button_rect

        A2D_CALL A2D_SET_POS, label_ok_pos
        A2D_CALL A2D_DRAW_TEXT, label_ok

        A2D_CALL A2D_SET_POS, label_cancel_pos
        A2D_CALL A2D_DRAW_TEXT, label_cancel

        A2D_CALL A2D_SET_POS, label_uparrow_pos
        A2D_CALL A2D_DRAW_TEXT, label_uparrow
        A2D_CALL A2D_DRAW_RECT, up_arrow_rect

        A2D_CALL A2D_SET_POS, label_downarrow_pos
        A2D_CALL A2D_DRAW_TEXT, label_downarrow
        A2D_CALL A2D_DRAW_RECT, down_arrow_rect

        jsr     L0BBE
        jsr     L0BCB
        jsr     L0C0D
        jsr     L0D81
        jsr     L0D8E
        jsr     L0DA7
        A2D_CALL A2D_SET_FILL_MODE, fill_mode_params
        A2D_CALL A2D_SET_PATTERN, white_pattern
        lda     #$01
        jmp     L0DB4

L0D73:  lda     L090E
        cmp     #$01
        beq     L0D81
        cmp     #$02
        beq     L0D8E
        jmp     L0DA7

L0D81:  A2D_CALL A2D_SET_POS, L091B
        A2D_CALL A2D_DRAW_TEXT, L091F
        rts

L0D8E:  A2D_CALL A2D_SET_POS, L0924
        A2D_CALL A2D_DRAW_TEXT, L0914
        A2D_CALL A2D_SET_POS, L0924
        A2D_CALL A2D_DRAW_TEXT, L0928
        rts

L0DA7:  A2D_CALL A2D_SET_POS, L092E
        A2D_CALL A2D_DRAW_TEXT, L0932
        rts

L0DB4:  pha
        lda     L090E
        beq     L0DD1
        cmp     #$01
        bne     L0DC4
        jsr     L0DE4
        jmp     L0DD1

L0DC4:  cmp     #$02
        bne     L0DCE
        jsr     L0DEB
        jmp     L0DD1

L0DCE:  jsr     L0DDD
L0DD1:  pla
        sta     L090E
        cmp     #$01
        beq     L0DE4
        cmp     #$02
        beq     L0DEB
L0DDD:  A2D_CALL A2D_FILL_RECT, fill_rect_params6
        rts

L0DE4:  A2D_CALL A2D_FILL_RECT, fill_rect_params3
        rts

L0DEB:  A2D_CALL A2D_FILL_RECT, fill_rect_params7
        rts

L0DF2:  lda     #$FF
        sec
L0DF5:  pha
L0DF6:  sbc     #$01
        bne     L0DF6
        pla
        sbc     #$01
        bne     L0DF5
        rts

L0E00:  ldx     #$00
L0E02:  lda     L0000,x
        sta     L0E16,x
        dex
        bne     L0E02
        rts

        ldx     #$00
L0E0D:  lda     L0E16,x
        sta     L0000,x
        dex
        bne     L0E0D
        rts

L0E16:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

.proc div_by_10_then_ascii      ; A = A / 10, X = remainder, results in ASCII form
        ldy     #$00
loop:   cmp     #$0A            ; Y = A / 10
        bcc     :+
        sec
        sbc     #$0A
        iny
        jmp     loop

:       clc                     ; then convert to ASCII
        adc     #'0'
        tax
        tya
        clc
        adc     #'0'
        rts                     ; remainder in X, result in A
.endproc

        rts                     ; ???

last := *
