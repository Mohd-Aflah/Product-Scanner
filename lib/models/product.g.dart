// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      productCode: fields[0] as int,
      barcode: fields[1] as String?,
      name: fields[2] as String,
      category: fields[3] as String,
      purchaseRate: fields[4] as double,
      salesRate: fields[5] as double,
      stock: fields[6] as int,
      vatEnabled: fields[7] as bool,
      netPrice: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.productCode)
      ..writeByte(1)
      ..write(obj.barcode)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.purchaseRate)
      ..writeByte(5)
      ..write(obj.salesRate)
      ..writeByte(6)
      ..write(obj.stock)
      ..writeByte(7)
      ..write(obj.vatEnabled)
      ..writeByte(8)
      ..write(obj.netPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
