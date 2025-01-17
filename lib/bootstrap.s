;;; ============================================================
;;; Bootstrap
;;;
;;; Compiled as part of DeskTop and Selector
;;; ============================================================

        .org MODULE_BOOTSTRAP

;;; Install QuitRoutine to the ProDOS QUIT routine
;;; (Main, LCBANK2) and invoke it.

.proc InstallAsQuit
        MLIEntry := MLI

        src     := QuitRoutine
        dst     := SELECTOR
        .assert sizeof_QuitRoutine <= $200, error, "too large"

        bit     LCBANK2
        bit     LCBANK2

        ldy     #0
:       lda     src,y
        sta     dst,y
        lda     src+$100,y
        sta     dst+$100,y
        dey
        bne     :-

        bit     ROMIN2

        MLI_CALL QUIT, quit_params
        DEFINE_QUIT_PARAMS quit_params
.endproc ; InstallAsQuit
.assert sizeof_QuitRoutine + .sizeof(InstallAsQuit) <= kModuleBootstrapSize, error, "too large"

;;; New QUIT routine. Gets relocated to $1000 by ProDOS before
;;; being executed.

.proc QuitRoutine
        .org ::SELECTOR_ORG

        MLIEntry := MLI

self:
        jmp     start

reinstall_flag:                ; set once prefix saved and reinstalled
        .byte   0

kSplashVtab = 12
str_loading:
        PASCAL_STRING QR_LOADSTRING

filename:
        PASCAL_STRING QR_FILENAME

        ;; ProDOS MLI call param blocks

        io_buf := $1C00
        .assert io_buf + $400 <= kSegmentLoaderAddress, error, "memory overlap"

        DEFINE_SET_MARK_PARAMS set_mark_params, kSegmentLoaderOffset
        DEFINE_READ_PARAMS read_params, kSegmentLoaderAddress, kSegmentLoaderLength
        DEFINE_CLOSE_PARAMS close_params
        DEFINE_GET_PREFIX_PARAMS prefix_params, prefix_buffer
        DEFINE_OPEN_PARAMS open_params, filename, io_buf

start:
        ;; Show and clear 80-column text screen
        bit     ROMIN2
        jsr     SETVID
        jsr     SETKBD
        sta     CLR80VID
        sta     SETALTCHAR
        sta     CLR80STORE
        jsr     SLOT3ENTRY
        jsr     HOME

        ;; IIgs: Reset shadowing
        sec
        jsr     IDROUTINE
        bcs     :+
        copy    #0, SHADOW
:

        ;; --------------------------------------------------

        ;; Display the loading string
        lda     #kSplashVtab
        jsr     VTABZ

        lda     #80             ; HTAB (80-width)/2
        sec                     ; to center
        sbc     str_loading     ; -= width
        lsr     a               ; /= 2
        sta     OURCH

        ldy     #0
:       lda     str_loading+1,y
        ora     #$80
        jsr     COUT
        iny
        cpy     str_loading
        bne     :-

        ;; Close all open files (just in case)
        MLI_CALL CLOSE, close_params

        ;; Initialize system bitmap
        ldx     #BITMAP_SIZE-1
        lda     #0
:       sta     BITMAP,x
        dex
        bpl     :-
        lda     #%00000001      ; ProDOS global page
        sta     BITMAP+BITMAP_SIZE-1
        lda     #%11001111      ; ZP, Stack, Text Page 1
        sta     BITMAP

        lda     reinstall_flag
        bne     proceed

        ;; Re-install quit routine (with prefix memorized)
        MLI_CALL GET_PREFIX, prefix_params
        beq     :+
        jmp     ErrorHandler
:
        ;; --------------------------------------------------

        dec     reinstall_flag
        copy16  IRQLOC, irq_vector_stash

        ;; --------------------------------------------------
        ;; Copy self into the ProDOS QUIT routine
        bit     LCBANK2
        bit     LCBANK2

        ldy     #0
:       lda     self,y
        sta     SELECTOR,y
        lda     self+$100,y
        sta     SELECTOR+$100,y
        dey
        bne     :-

        bit     ROMIN2
        jmp     load_loader

proceed:
        copy16  irq_vector_stash, IRQLOC

;;; ============================================================
;;; Load the Loader at $2000 and invoke it.

load_loader:
        MLI_CALL SET_PREFIX, prefix_params
        bne     prompt_for_system_disk
        MLI_CALL OPEN, open_params
        jne     ErrorHandler
        lda     open_params::ref_num
        sta     set_mark_params::ref_num
        sta     read_params::ref_num
        MLI_CALL SET_MARK, set_mark_params
        bne     ErrorHandler
        MLI_CALL READ, read_params
        bne     ErrorHandler
        MLI_CALL CLOSE, close_params
        bne     ErrorHandler

        jmp     kSegmentLoaderAddress

;;; ============================================================
;;; Display a string, and wait for Return keypress

prompt_for_system_disk:
        jsr     SLOT3ENTRY      ; 80 column mode
        jsr     HOME            ; clear screen
        lda     #kSplashVtab    ; VTAB 12
        jsr     VTABZ

        lda     #80             ; HTAB (80-width)/2
        sec                     ; to center the string
        sbc     disk_prompt     ; -= width
        lsr     a               ; /= 2
        sta     OURCH

        ;; Display prompt
        ldy     #0
:       lda     disk_prompt+1,y
        ora     #$80
        jsr     COUT
        iny
        cpy     disk_prompt
        bne     :-

wait:   sta     KBDSTRB
:       lda     KBD
        bpl     :-
        cmp     #CHAR_RETURN | $80
        bne     wait
        jmp     start

disk_prompt:
        PASCAL_STRING res_string_prompt_insert_system_disk

;;; ============================================================

irq_vector_stash:
        .word   0

;;; ============================================================
;;; Error Handler

.proc ErrorHandler
        sta     $06             ; Crash?
        jmp     MONZ
.endproc ; ErrorHandler

prefix_buffer:
        .res    64, 0

;;; Updated by DeskTop if parts of the path are renamed.
prefix_buffer_offset := prefix_buffer - self

.endproc ; QuitRoutine
sizeof_QuitRoutine = .sizeof(QuitRoutine)
