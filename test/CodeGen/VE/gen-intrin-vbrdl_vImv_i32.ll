; RUN: llc < %s -mtriple=ve-unknown-unknown | FileCheck %s
; ModuleID = 'gen/tests/vbrdl_vImv_i32.c'
source_filename = "gen/tests/vbrdl_vImv_i32.c"
target datalayout = "e-m:e-i64:64-n32:64-S64-v16384:64:64"
target triple = "ve"

; Function Attrs: nounwind
define dso_local void @vbrdl_vImv_i32(i32* %pvx, i32* %pvm, i32* nocapture readnone %pvd, i32 %n) local_unnamed_addr #0 {
; CHECK-LABEL: vbrdl_vImv_i32
; CHECK: .LBB0_2
; CHECK: 	vbrdl %v1,3,%vm1
entry:
  %cmp18 = icmp sgt i32 %n, 0
  br i1 %cmp18, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body, %entry
  ret void

for.body:                                         ; preds = %entry, %for.body
  %pvx.addr.021 = phi i32* [ %add.ptr, %for.body ], [ %pvx, %entry ]
  %pvm.addr.020 = phi i32* [ %add.ptr3, %for.body ], [ %pvm, %entry ]
  %i.019 = phi i32 [ %add, %for.body ], [ 0, %entry ]
  %sub = sub nsw i32 %n, %i.019
  %cmp1 = icmp slt i32 %sub, 256
  %spec.select = select i1 %cmp1, i32 %sub, i32 256
  tail call void @llvm.ve.lvl(i32 %spec.select)
  %0 = bitcast i32* %pvm.addr.020 to i8*
  %1 = tail call <256 x double> @llvm.ve.vldlzx.vss(i64 4, i8* %0)
  %2 = tail call <4 x i64> @llvm.ve.vfmkw.mcv(i32 1, <256 x double> %1)
  %3 = bitcast i32* %pvx.addr.021 to i8*
  %4 = tail call <256 x double> @llvm.ve.vldlsx.vss(i64 4, i8* %3)
  %5 = tail call <256 x double> @llvm.ve.vbrdl.vsmv.i32(i32 3, <4 x i64> %2, <256 x double> %4)
  tail call void @llvm.ve.vstl.vss(<256 x double> %5, i64 4, i8* %3)
  %add.ptr = getelementptr inbounds i32, i32* %pvx.addr.021, i64 256
  %add.ptr3 = getelementptr inbounds i32, i32* %pvm.addr.020, i64 256
  %add = add nuw nsw i32 %i.019, 256
  %cmp = icmp slt i32 %add, %n
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}

; Function Attrs: nounwind
declare void @llvm.ve.lvl(i32) #1

; Function Attrs: nounwind readonly
declare <256 x double> @llvm.ve.vldlzx.vss(i64, i8*) #2

; Function Attrs: nounwind readnone
declare <4 x i64> @llvm.ve.vfmkw.mcv(i32, <256 x double>) #3

; Function Attrs: nounwind readonly
declare <256 x double> @llvm.ve.vldlsx.vss(i64, i8*) #2

; Function Attrs: nounwind readnone
declare <256 x double> @llvm.ve.vbrdl.vsmv.i32(i32, <4 x i64>, <256 x double>) #3

; Function Attrs: nounwind writeonly
declare void @llvm.ve.vstl.vss(<256 x double>, i64, i8*) #4

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }
attributes #2 = { nounwind readonly }
attributes #3 = { nounwind readnone }
attributes #4 = { nounwind writeonly }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 7.0.0 (git@socsv218.svp.cl.nec.co.jp:ve-llvm/clang.git ff1b212b167d14362ffe05ebdd4e0b9f5948c408) (llvm/llvm.git 3e4d7ab07238a034015240bd22960dc74ed4dd85)"}
