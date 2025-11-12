import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_services/services.dart';
import 'order_success_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  bool _isProcessing = false;
  String? selectedDelivery;
  String? selectedPayment;
  String? promoCode;
  double discount = 0;

  double getTotal(List cart) {
    double total = 0;
    for (var item in cart) {
      total += (item.price);
    }
    return total - discount;
  }

  void _selectDelivery() async {
    final method = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => ListView(
        children: [
          ListTile(
            title: const Text("Standard Delivery (2-3 Days)"),
            onTap: () => Navigator.pop(context, "Standard Delivery"),
          ),
          ListTile(
            title: const Text("Express Delivery (24 Hrs)"),
            onTap: () => Navigator.pop(context, "Express Delivery"),
          ),
        ],
      ),
    );
    if (method != null) setState(() => selectedDelivery = method);
  }

  void _selectPayment() async {
    final method = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.credit_card, color: Colors.blue),
            title: const Text("Credit / Debit Card"),
            onTap: () => Navigator.pop(context, "Card"),
          ),
          ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: Colors.green,
            ),
            title: const Text("Google Pay"),
            onTap: () => Navigator.pop(context, "Google Pay"),
          ),
          ListTile(
            leading: const Icon(Icons.money, color: Colors.orange),
            title: const Text("Cash on Delivery"),
            onTap: () => Navigator.pop(context, "Cash on Delivery"),
          ),
        ],
      ),
    );
    if (method != null) setState(() => selectedPayment = method);
  }

  void _applyPromo() async {
    final promo = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Enter Promo Code"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "e.g. SAVE10"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
    if (promo != null && promo.isNotEmpty) {
      setState(() {
        promoCode = promo;
        discount = 3.00;
      });
    }
  }

  Future<void> _handlePayment(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartItems = authProvider.cartItems;

    if (selectedDelivery == null || selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select delivery & payment method."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);

    final purchasedItems = List.from(cartItems);
    authProvider.clearCart();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(products: [])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cart = authProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Text(
                      "🛒 Your cart is empty",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final product = cart[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "\$${product.price}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              authProvider.removeFromCart(product);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (cart.isNotEmpty)
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _checkoutRow(
                    "Delivery",
                    selectedDelivery ?? "Select Method",
                    _selectDelivery,
                  ),
                  _checkoutRow(
                    "Payment",
                    selectedPayment ?? "Select Method",
                    _selectPayment,
                  ),
                  _checkoutRow(
                    "Promo Code",
                    promoCode ?? "Pick discount",
                    _applyPromo,
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Cost", style: TextStyle(fontSize: 18)),
                      Text(
                        "\$${getTotal(cart).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isProcessing
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 100,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _handlePayment(context),
                          child: const Text(
                            "Place Order",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                     ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _checkoutRow(String title, String value, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}

