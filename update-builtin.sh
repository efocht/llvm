#! /bin/sh

#set -v

cp -vf tmp/VEInstrIntrinsic.td  lib/Target/VE/VEInstrIntrinsic.td
cp -vf tmp/IntrinsicsVE2.td     include/llvm/IR/IntrinsicsVE2.td
cp -vf tmp/BuiltinsVE2.def      tools/clang/include/clang/Basic/BuiltinsVE2.def
cp -vf tmp/veintrin2.h          ../test/intrinsic/veintrin2.h
cp -vf tmp/ref.cc               ../test/intrinsic/gen/ref.cc
cp -vf tmp/decl.h               ../test/intrinsic/decl.h

python builtin.py -t

touch include/llvm/IR/Intrinsics.td
touch tools/clang/include/clang/Basic/Builtins.def

