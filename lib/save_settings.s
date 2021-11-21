;;; ============================================================
;;; Save Settings
;;;
;;; Used in control panel DAs
;;; ============================================================

filename:
        PASCAL_STRING kFilenameDeskTopConfig

filename_buffer:
        .res kPathBufferSize

;;; The space between `WINDOW_ENTRY_TABLES` and `DA_IO_BUFFER` is usable in
;;; Main memory only.
        write_buffer := WINDOW_ENTRY_TABLES
        .assert DA_IO_BUFFER - write_buffer >= .sizeof(DeskTopSettings), error, "Not enough room"

        DEFINE_CREATE_PARAMS create_params, filename, ACCESS_DEFAULT, $F1
        DEFINE_OPEN_PARAMS open_params, filename, DA_IO_BUFFER
        DEFINE_WRITE_PARAMS write_params, write_buffer, .sizeof(DeskTopSettings)
        DEFINE_CLOSE_PARAMS close_params

.proc save_settings
        ;; Run from Main, but with LCBANK1 in

        ;; Copy from LCBANK to somewhere ProDOS can read.
        COPY_STRUCT DeskTopSettings, SETTINGS, write_buffer

        ;; Write to desktop current prefix
        ldax    #filename
        stax    create_params::pathname
        stax    open_params::pathname
        jsr     do_write

        ;; Write to the original file location, if necessary
        jsr     GetCopiedToRAMCardFlag
        beq     done
        ldax    #filename_buffer
        stax    create_params::pathname
        stax    open_params::pathname
        jsr     CopyDeskTopOriginalPrefix
        jsr     append_filename
        copy    #0, second_try_flag
@retry: jsr     do_write
        bcc     done

        ;; First time - ask if we should even try.
        lda     second_try_flag
        bne     :+
        inc     second_try_flag
        lda     #kWarningMsgSaveChanges
        jsr     JUMP_TABLE_SHOW_WARNING
        beq     @retry
        bne     done            ; always

        ;; Second time - prompt to insert.
:       lda     #kWarningMsgInsertSystemDisk
        jsr     JUMP_TABLE_SHOW_WARNING
        beq     @retry

done:   rts

second_try_flag:
        .byte   0

.proc append_filename
        ;; Append filename to buffer
        inc     filename_buffer ; Add '/' separator
        ldx     filename_buffer
        lda     #'/'
        sta     filename_buffer,x

        ldx     #0              ; Append filename
        ldy     filename_buffer
:       inx
        iny
        lda     filename,x
        sta     filename_buffer,y
        cpx     filename
        bne     :-
        sty     filename_buffer
        rts
.endproc

.proc do_write
        ;; Create if necessary
        copy16  DATELO, create_params::create_date
        copy16  TIMELO, create_params::create_time
        JUMP_TABLE_MLI_CALL CREATE, create_params

        JUMP_TABLE_MLI_CALL OPEN, open_params
        bcs     done
        lda     open_params::ref_num
        sta     write_params::ref_num
        sta     close_params::ref_num
        JUMP_TABLE_MLI_CALL WRITE, write_params
close:  JUMP_TABLE_MLI_CALL CLOSE, close_params
done:   rts
.endproc

.endproc
