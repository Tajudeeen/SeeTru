import 'package:get_storage/get_storage.dart';
abstract class KeyValueStore {
  dynamic read(String key);
  Future<void> write(String key,dynamic value);
}
class DeviceStore implements KeyValueStore {
  final GetStorage box;
  DeviceStore(this.box);
  @override dynamic read(String key)=>box.read(key);
  @override Future<void> write(String key,dynamic value)=>box.write(key,value);
}
