class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  final String? description;
   int stock;
  final String category;
  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    this.stock = 10,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unknown',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image'] ??
          json['img'] ??
          json['featured_image'] ??
          'https://via.placeholder.com/150',
      description: json['description'] ?? '',
      stock: 10,
      category: json['category'] ?? '',

    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;

}

