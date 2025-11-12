import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_services/services.dart';
import 'cart_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Column(
        children: [
          Expanded(
            child: authProvider.favorites.isEmpty
                ? const Center(child: Text('No favorites yet'))
                : ListView.builder(
                    itemCount: authProvider.favorites.length,
                    itemBuilder: (context, index) {
                      final product = authProvider.favorites[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            product.image,
                            width: 50,
                            height: 50,
                          ),
                          title: Text(product.title),
                          subtitle: Text("\$${product.price}"),
                          trailing: IconButton(
                            onPressed: () {
                              authProvider.toggleFavorite(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${product.title} removed from favorites",
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          ElevatedButton(
            onPressed: () {
              for (var product in authProvider.favorites) {
                authProvider.addToCart(product);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Items added to cart")),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            child: const Text("Add to Cart"),
          ),
        ],
      ),
    );
  }
}
