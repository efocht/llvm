; RUN: llc < %s -mtriple=ve-unknown-unknown | FileCheck %s

; Function Attrs: norecurse nounwind readnone
define dso_local <16 x i32> @insert_test(<16 x i32>) local_unnamed_addr #0 {
; CHECK-LABEL: insert_test:
; CHECK:       .LBB{{[0-9]+}}_2:
; CHECK-NEXT:    lea %s34,240(,%s9)
; CHECK-NEXT:    vldl.sx %v0,4,%s34
; CHECK-NEXT:    or %s34, 2, (0)1
; CHECK-NEXT:    lsv %v0(0),%s34
; CHECK-NEXT:    lea %s34,-2048(,%s9)
; CHECK-NEXT:    vstl %v0,4,%s34
; CHECK-NEXT:    vld %v0,8,%s34
; CHECK-NEXT:    lvs %s34,%v0(7)
; CHECK-NEXT:    st %s34, 56(,%s0)
; CHECK-NEXT:    lvs %s34,%v0(6)
; CHECK-NEXT:    st %s34, 48(,%s0)
; CHECK-NEXT:    lvs %s34,%v0(5)
; CHECK-NEXT:    st %s34, 40(,%s0)
; CHECK-NEXT:    lvs %s34,%v0(4)
; CHECK-NEXT:    st %s34, 32(,%s0)
; CHECK-NEXT:    lvs %s34,%v0(3)
; CHECK-NEXT:    st %s34, 24(,%s0)
; CHECK-NEXT:    lvs %s34,%v0(2)
; CHECK-NEXT:    st %s34, 16(,%s0)
; CHECK-NEXT:    lvs %s34,%v0(1)
; CHECK-NEXT:    st %s34, 8(,%s0)
; CHECK-NEXT:    lvs %s34,%v0(0)
; CHECK-NEXT:    st %s34, (,%s0)
  %2 = insertelement <16 x i32> %0, i32 2, i32 0
  ret <16 x i32> %2
}

; Function Attrs: norecurse nounwind readnone
define dso_local i32 @extract_test(<16 x i32>) local_unnamed_addr #0 {
; CHECK-LABEL: extract_test:
; CHECK:       .LBB{{[0-9]+}}_2:
; CHECK-NEXT:    lea %s34,240(,%s9)
; CHECK-NEXT:    vldl.sx %v0,4,%s34
; CHECK-NEXT:    lvs %s0,%v0(0)
; CHECK-NEXT:    # kill: def $sw0 killed $sw0 killed $sx0
  %2 = extractelement <16 x i32> %0, i32 0
  ret i32 %2
}

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
