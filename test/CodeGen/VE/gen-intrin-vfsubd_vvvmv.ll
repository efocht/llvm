; RUN: llc < %s -mtriple=ve-unknown-unknown | FileCheck %s

; Function Attrs: nounwind
define void @vfsubd_vvvmv(double* %pvx, double* %pvy, double* %pvz, i32* %pvm, double* nocapture readnone %pvd, i32 %n) {
; CHECK-LABEL: vfsubd_vvvmv
; CHECK: .LBB0_2
; CHECK: 	vfsub.d %v3,%v0,%v1,%vm1
entry:
  %cmp24 = icmp sgt i32 %n, 0
  br i1 %cmp24, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body, %entry
  ret void

for.body:                                         ; preds = %entry, %for.body
  %pvx.addr.029 = phi double* [ %add.ptr, %for.body ], [ %pvx, %entry ]
  %pvy.addr.028 = phi double* [ %add.ptr3, %for.body ], [ %pvy, %entry ]
  %pvz.addr.027 = phi double* [ %add.ptr4, %for.body ], [ %pvz, %entry ]
  %pvm.addr.026 = phi i32* [ %add.ptr5, %for.body ], [ %pvm, %entry ]
  %i.025 = phi i32 [ %add, %for.body ], [ 0, %entry ]
  %sub = sub nsw i32 %n, %i.025
  %cmp1 = icmp slt i32 %sub, 256
  %spec.select = select i1 %cmp1, i32 %sub, i32 256
  tail call void @llvm.ve.lvl(i32 %spec.select)
  %0 = bitcast double* %pvy.addr.028 to i8*
  %1 = tail call <256 x double> @llvm.ve.vld.vss(i64 8, i8* %0)
  %2 = bitcast double* %pvz.addr.027 to i8*
  %3 = tail call <256 x double> @llvm.ve.vld.vss(i64 8, i8* %2)
  %4 = bitcast i32* %pvm.addr.026 to i8*
  %5 = tail call <256 x double> @llvm.ve.vldlzx.vss(i64 4, i8* %4)
  %6 = tail call <4 x i64> @llvm.ve.vfmkw.mcv(i32 7, <256 x double> %5)
  %7 = bitcast double* %pvx.addr.029 to i8*
  %8 = tail call <256 x double> @llvm.ve.vld.vss(i64 8, i8* %7)
  %9 = tail call <256 x double> @llvm.ve.vfsubd.vvvmv(<256 x double> %1, <256 x double> %3, <4 x i64> %6, <256 x double> %8)
  tail call void @llvm.ve.vst.vss(<256 x double> %9, i64 8, i8* %7)
  %add.ptr = getelementptr inbounds double, double* %pvx.addr.029, i64 256
  %add.ptr3 = getelementptr inbounds double, double* %pvy.addr.028, i64 256
  %add.ptr4 = getelementptr inbounds double, double* %pvz.addr.027, i64 256
  %add.ptr5 = getelementptr inbounds i32, i32* %pvm.addr.026, i64 256
  %add = add nuw nsw i32 %i.025, 256
  %cmp = icmp slt i32 %add, %n
  br i1 %cmp, label %for.body, label %for.cond.cleanup
}

; Function Attrs: nounwind
declare void @llvm.ve.lvl(i32)

; Function Attrs: nounwind readonly
declare <256 x double> @llvm.ve.vld.vss(i64, i8*)

; Function Attrs: nounwind readonly
declare <256 x double> @llvm.ve.vldlzx.vss(i64, i8*)

; Function Attrs: nounwind readnone
declare <4 x i64> @llvm.ve.vfmkw.mcv(i32, <256 x double>)

; Function Attrs: nounwind readnone
declare <256 x double> @llvm.ve.vfsubd.vvvmv(<256 x double>, <256 x double>, <4 x i64>, <256 x double>)

; Function Attrs: nounwind writeonly
declare void @llvm.ve.vst.vss(<256 x double>, i64, i8*)

