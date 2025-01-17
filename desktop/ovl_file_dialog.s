;;; ============================================================
;;; Overlay for File Dialog (used by Copy/Add/Edit)
;;;
;;; Compiled as part of desktop.s
;;; ============================================================

        BEGINSEG OverlayFileDialog

.scope file_dialog

        MLIEntry := main::MLIRelayImpl
        MGTKEntry := MGTKRelayImpl
        LETKEntry := LETKRelayImpl
        BTKEntry := BTKRelayImpl

;;; ============================================================

Exec:
        jmp     Start

;;; ============================================================

;;; Required proc definitions
CheckMouseMoved         := main::CheckMouseMoved
YieldLoop               := main::YieldLoop
DetectDoubleClick       := main::StashCoordsAndDetectDoubleClick
AdjustVolumeNameCase    := main::AdjustVolumeNameCase
AdjustFileEntryCase     := main::AdjustFileEntryCase

;;; Required macro definitions
        .include "../lib/file_dialog.s"
        .include "../lib/muldiv.s"

;;; ============================================================

.endscope ; file_dialog

file_dialog__Exec := file_dialog::Exec

        ENDSEG OverlayFileDialog
