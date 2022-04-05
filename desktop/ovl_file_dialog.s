;;; ============================================================
;;; Overlay for File Dialog (used by Copy/Delete/Add/Edit)
;;;
;;; Compiled as part of desktop.s
;;; ============================================================


.scope file_dialog
        .org $5000

        MLIEntry := main::MLIRelayImpl
        MGTKEntry := MGTKRelayImpl

;;; ============================================================

Exec:
        jmp     Start

;;; ============================================================

;;; Required proc definitions
MLIRelayImpl            := main::MLIRelayImpl
CheckMouseMoved         := main::CheckMouseMoved
YieldLoop               := main::YieldLoop
DetectDoubleClick       := main::StashCoordsAndDetectDoubleClick
ButtonEventLoop         := ButtonEventLoopRelay
ModifierDown            := main::ModifierDown
ShiftDown               := main::ShiftDown
AdjustVolumeNameCase    := main::AdjustVolumeNameCase
AdjustFileEntryCase     := main::AdjustFileEntryCase

;;; Required data definitions
buf_input1_left := path_buf0
buf_input2_left := path_buf1

;;; Required macro definitions
        .define FD_EXTENDED 1
        .include "../lib/file_dialog.s"
        .include "../lib/muldiv.s"

;;; ============================================================

        PAD_TO $7000

.endscope ; file_dialog

file_dialog__Exec := file_dialog::Exec
