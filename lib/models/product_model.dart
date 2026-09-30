// Modelo de datos completo para la ficha técnica del producto
class ProductModel {
  final int? id;
  final int? userId;
  final String sku;
  final String name;
  final String brand;
  final String category;
  final String location;
  final double purchasePrice;
  final double salePrice;
  final double taxPercentage;
  final int stock;
  final int minStock;
  final int reorderPoint;
  final String batchNumber;
  final String expirationDate;
  final String supplier;
  final String status;
  final String createdAt;

  ProductModel({
    this.id,
    this.userId,
    required this.sku,
    required this.name,
    required this.brand,
    required this.category,
    required this.location,
    required this.purchasePrice,
    required this.salePrice,
    required this.taxPercentage,
    required this.stock,
    required this.minStock,
    required this.reorderPoint,
    required this.batchNumber,
    required this.expirationDate,
    required this.supplier,
    required this.status,
    required this.createdAt,
  });

  // Métodos de cálculo financiero y stock
  double get taxAmount => salePrice * (taxPercentage / 100);
  double get priceWithTax => salePrice + taxAmount;
  double get profitMargin => salePrice - purchasePrice;
  double get totalValue => salePrice * stock;
  bool get isLowStock => stock <= minStock;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'sku': sku,
      'name': name,
      'brand': brand,
      'category': category,
      'location': location,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'taxPercentage': taxPercentage,
      'stock': stock,
      'minStock': minStock,
      'reorderPoint': reorderPoint,
      'batchNumber': batchNumber,
      'expirationDate': expirationDate,
      'supplier': supplier,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      userId: map['userId'],
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? 'General',
      location: map['location'] ?? 'Bodega Principal',
      purchasePrice: (map['purchasePrice'] as num).toDouble(),
      salePrice: (map['salePrice'] as num).toDouble(),
      taxPercentage: (map['taxPercentage'] as num? ?? 19.0).toDouble(),
      stock: map['stock'] as int,
      minStock: map['minStock'] as int,
      reorderPoint: map['reorderPoint'] as int? ?? 10,
      batchNumber: map['batchNumber'] ?? '',
      expirationDate: map['expirationDate'] ?? '',
      supplier: map['supplier'] ?? '',
      status: map['status'] ?? 'Activo',
      createdAt: map['createdAt'] ?? '',
    );
  }
}