import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/product.dart';
import '../provider_services/services.dart';

class DetailsScreen extends StatefulWidget {
  final Product product;
  const DetailsScreen({super.key, required this.product});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int count = 1;
  bool isExpanded = false;
  int rating = 0;
  late Product localProduct;

  @override
  void initState() {
    super.initState();
    localProduct = widget.product;
    if (localProduct.stock <= 0) count = 0;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    double totalPrice = localProduct.price * count;

    return Scaffold(
      appBar: AppBar(
        title: Text(localProduct.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              localProduct.image,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 100),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    localProduct.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    authProvider.isFavorite(localProduct)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    authProvider.toggleFavorite(localProduct);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "\$${localProduct.price}",
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildQuantitySelector(),
            const SizedBox(height: 15),
            Text(
              localProduct.stock > 0
                  ? "In Stock (${localProduct.stock})"
                  : "Out of Stock",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: localProduct.stock > 0 ? Colors.green : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(

              localProduct.description ?? "No description available.",
              maxLines: isExpanded ? null : 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            TextButton(
              onPressed: () => setState(() => isExpanded = !isExpanded),
              child: Text(isExpanded ? "Show Less" : "Show More"),
            ),
             _buildReviewSection(),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: localProduct.stock > 0 && count > 0
                  ? () {
                setState(() {
                  localProduct.stock -= count;
                  if (localProduct.stock < 0) localProduct.stock = 0;
                });
                Navigator.pop(context, localProduct);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor:
                localProduct.stock > 0 ? Colors.green : Colors.grey,
              ),
              child: Text(
                localProduct.stock > 0
                    ? "Add to Basket (\$${totalPrice.toStringAsFixed(2)})"
                    : "Out of Stock",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: const Text(
                "Review :",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 30),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    color: index < rating ? Colors.orange : Colors.grey,
                    size: 30,
                  ),
                );
              }),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1.5,
            ),
          ],
        );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle, size: 32),
          onPressed: count > 1 ? () => setState(() => count--) : null,
        ),
        const SizedBox(width: 10),
        Container(
          alignment: Alignment.center,
          width: 50,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade200,
          ),
          child: Text(
            "$count",
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.add_circle, size: 32, color: Colors.green),
          onPressed: (count < localProduct.stock)
              ? () => setState(() => count++)
              : null,
        ),


      ],
    );
  }
}
