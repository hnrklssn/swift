// RUN: %target-run-simple-swift-split-file(test.swift -I %t%{fs-sep}Inputs -target %target-swift-6.2-abi-triple -g -Onone)
//
// REQUIRES: executable_test

//--- Inputs/module.modulemap
module Test {
  header "header.h"
}

//--- Inputs/header.h
#define __counted_by(x) __attribute__((__counted_by__(x)))
#define __noescape __attribute__((__noescape__))

static inline void interop_copy(const int* __counted_by(count) _Nonnull in __noescape,
                                int * __counted_by(count) _Nonnull out __noescape,
                                int count) {
  for(int i = 0; i < count; i++)
    out[i] = in[i];
}

//--- test.swift
import Test

func foo() {
  let arr: [Int32] = [1, 2, 3]
  var arrOut: [Int32] = [0, 0]
  var spanOut = arrOut.mutableSpan
  // Both spans share a single C `count` parameter, so the safe
  // wrapper requires their lengths to match and traps when they don't.
  interop_copy(arr.span, &spanOut)
}
foo()
