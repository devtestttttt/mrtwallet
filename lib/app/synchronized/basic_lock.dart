/// MIT License
library;

/// Copyright (c) 2016, Alexandre Roux Tekartik.

/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:

/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.

/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import 'dart:async';

enum LockId { one, two, three }

/// Basic (non-reentrant) lock
class SynchronizedLock {
  // Future<dynamic>? last;
  final Map<LockId, Future<dynamic>?> last = {};

  Future<T> synchronized<T>(FutureOr<T> Function() func,
      {LockId lockId = LockId.one}) async {
    final prev = last[lockId];
    final completer = Completer<void>.sync();
    last[lockId] = completer.future;
    try {
      // If there is a previous running block, wait for it
      if (prev != null) {
        await prev;
      }

      // Run the function and return the result
      final result = func();
      if (result is Future) {
        return await result;
      } else {
        return result;
      }
    } finally {
      if (identical(last, completer.future)) {
        last[lockId] = null;
      }
      completer.complete();
    }
  }
}
