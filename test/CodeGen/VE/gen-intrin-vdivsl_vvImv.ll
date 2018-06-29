; RUN: llc < %s -mtriple=ve-unknown-unknown | FileCheck %s
; ModuleID = 'gen/tests/vdivsl_vvImv.c'
source_filename = "gen/tests/vdivsl_vvImv.c"
target datalayout = "e-m:e-i64:64-n32:64-S64-v16384:64:64"
target triple = "ve"

; Function Attrs: nounwind
define dso_local void @vdivsl_vvImv(i64* %pvx, i64* %pvy, i32* %pvm, i64* nocapture readnone %pvd, i32 %n) local_unnamed_addr #0 {
; CHECK-LABEL: vdivsl_vvImv
; CHECK: .LBB0_2
; CHECK: 	vdivs.l %v2,%v0,3,%vm1
entry:
  %cmp21 = icmp sgt i32 %n, 0
  br i1 %cmp21, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body, %entry
  ret void

for.body:                                         ; preds = %entry, %for.body
  %pvx.addr.025 = phi i64* [ %add.ptr, %for.body ], [ %pvx, %entry ]
  %pvy.addr.024 = phi i64* [ %add.ptr3, %for.body ], [ %pvy, %entry ]
  %pvm.addr.023 = phi i32* [ %add.ptr4, %for.body ], [ %pvm, %entry ]
  %i.022 = phi i32 [ %add, %for.body ], [ 0, %entry ]
  %sub = sub nsw i32 %n, %i.022
  %cmp1 = icmp slt i32 %sub, 256
  %spec.select = select i1 %cmp1, i32 %sub, i32 256
  tail call void @llvm.ve.lvl(i32 %spec.select)
  %0 = bitcast i64* %pvy.addr.024 to i8*
  %1 = tail call <256 x double> @llvm.ve.vld.vss(i64 8, i8* %0)
  %2 = bitcast i32* %pvm.addr.023 to i8*
  %3 = tail call <256 x double> @llvm.ve.vldlzx.vss(i64 4, i8* %2)
  %4 = tail call <4 x i64> @llvm.ve.vfmkw.mcv(i32 1, <256 x double> %3)
  %5 = bitcast i64* %pvx.addr.025 to i8*
  %6 = tail call <256 x double> @llvm.ve.vld.vss(i64 8, i8* %5)
  %7 = tail call <256 x double> @llvm.ve.vdivsl.vvsmv(<256 x double> %1, i64 3, <4 x i64> %4, <256 x double> %6)
  tail call void @llvm.ve.vst.vss(<256 x double> %7, i64 8, i8* %5)
  %add.ptr = getelementptr inbounds i64, i64* %pvx.addr.025, i64 256
  %add.ptr3 = getelementptr inbounds i64, i64* %pvy.addr.024, i64 256
  %add.ptr4 = getelementptr inbounds i32, i32* %pvm.addr.023, i64 256
  %add = add nuw nsw i32 %i.022, 256
  %cmp = icmp slt i32 %add, %n
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}

; Function Attrs: nounwind
declare void @llvm.ve.lvl(i32) #1

; Function Attrs: nounwind readonly
declare <256 x double> @llvm.ve.vld.vss(i64, i8*) #2

; Function Attrs: nounwind readonly
declare <256 x double> @llvm.ve.vldlzx.vss(i64, i8*) #2

; Function Attrs: nounwind readnone
declare <4 x i64> @llvm.ve.vfmkw.mcv(i32, <256 x double>) #3

; Function Attrs: nounwind readnone
declare <256 x double> @llvm.ve.vdivsl.vvsmv(<256 x double>, i64, <4 x i64>, <256 x double>) #3

; Function Attrs: nounwind writeonly
declare void @llvm.ve.vst.vss(<256 x double>, i64, i8*) #4

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }
attributes #2 = { nounwind readonly }
attributes #3 = { nounwind readnone }
attributes #4 = { nounwind writeonly }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 7.0.0 (git@socsv218.svp.cl.nec.co.jp:ve-llvm/clang.git ff1b212b167d14362ffe05ebdd4e0b9f5948c408) (llvm/llvm.git 3e4d7ab07238a034015240bd22960dc74ed4dd85)"}
