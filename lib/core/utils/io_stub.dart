class File {
  File(String path);
  Future<bool> exists() async => false;
  Future<void> delete() async {}
}
