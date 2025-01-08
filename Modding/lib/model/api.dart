import 'dart:ffi';
import 'package:ffi/ffi.dart';

final class CStringView extends Struct {
  external Pointer<Utf8> value;

  @Size()
  external int size;
}

final class CStringList extends Struct {
  external Pointer<CStringView> value;

  @Size()
  external int size;
}

typedef ShellCallbackCView = Void Function(
  Pointer<CStringList> list,
  Pointer<CStringView> destination,
);

typedef ShellCallbackDartView = int Function(
  Pointer<CStringList> list,
  Pointer<CStringView> destination,
);

typedef KernelExecuteCAPI = Int32 Function(
  Pointer<CStringList> arguments,
  Pointer<NativeFunction<ShellCallbackCView>> mCallback,
);

typedef KernelExecuteDartAPI = int Function(
  Pointer<CStringList> arguments,
  Pointer<NativeFunction<ShellCallbackCView>> mCallback,
);
