class Printer {
  String? address;
  String? name;
  ConnectionType? connectionType;
  bool? isConnected;
  String? vendorId;
  String? productId;

  Printer({
    this.address,
    this.name,
    this.connectionType,
    this.vendorId,
    this.productId,
  });

  @override
  String toString() {
    return 'Printer{name: $name,address: $address, vendorId: $vendorId, productId: $productId}';
  }
}

enum ConnectionType {
  BLE,
  BLUETOOTH,
  USB,
  TCP,
}
