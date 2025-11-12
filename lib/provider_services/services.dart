import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../model/product.dart';


class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _token;
  String? get token => _token;

  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? get data => _profileData;

 /*---------------GoogleAuthentication--------------*/
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<UserCredential?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _token = googleAuth.idToken;
      _profileData = {
        "name": userCredential.user?.displayName,
        "email": userCredential.user?.email,
        "avatar": userCredential.user?.photoURL,
      };

      notifyListeners();
      return userCredential;
    } catch (e) {
      debugPrint("Google login error: $e");
      return null;
    }
  }

 /*-------------LoginSection------*/
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final url =
    Uri.parse("https://api.zhndev.site/wp-json/foodflow/v1/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );

      _isLoading = false;
      notifyListeners();

      debugPrint("Login response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data["token"] ??
            data["data"]?["token"] ??
            data["jwt_token"];

        if (_token == null) {
          debugPrint("Token not found in login response");
          return false;
        }

        debugPrint("Token saved: $_token");
        return true;
      } else {
        debugPrint("Login failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Login error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /*-------------SignUpSection------*/
  Future<bool> signUp(String name, String email, String password, String number) async {
    _isLoading = true;
    notifyListeners();

    final url =
    Uri.parse("https://api.zhndev.site/wp-json/foodflow/v1/auth/register");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "phone": number,
        }),
      );

      _isLoading = false;
      notifyListeners();

      debugPrint("Signup response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data["token"] ?? data["data"]?["token"];
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Signup error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /*-------------userFetchProfileSection------*/
  Future<void> fetchProfile() async {
    if (_token == null) {
      debugPrint("No token found, cannot fetch profile");
      return;
    }
    _isLoading = true;
    notifyListeners();

    final url =
    Uri.parse("https://api.zhndev.site/wp-json/foodflow/v1/user/profile");

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      debugPrint("Profile response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _profileData = decoded['data'] ?? decoded;
        debugPrint("Extracted Profile Data: $_profileData");
      } else {
        debugPrint("Failed to fetch profile: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Profile fetch error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _profileData = null;
    _isLoading = false;
    _auth.signOut();
    GoogleSignIn().signOut();
    notifyListeners();
  }

  /*-------------fetchProductsSection------*/
  static const String baseUrl = "https://fakestoreapi.com/products";

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }



  /*-------------favoriteProductToggleSection------*/
  final List<Product> _favorites = [];
  List<Product> get favorites => _favorites;

  bool isFavorite(Product product) {
    return _favorites.contains(product);
  }
  void toggleFavorite(Product product) {
    if (_favorites.contains(product)) {
      _favorites.remove(product);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }


  /*-------------Cart Management Section------*/
  List<Product> cart = [];
  final List<Product> _cartItems = [];
  List<Product> get cartItems => _cartItems;

  void addToCart(Product product) {
    if (!_cartItems.contains(product)) {
      _cartItems.add(product);
      notifyListeners();
    }
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /*-------------Order Success Simulation------*/
  Future<void> completePayment(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    clearCart();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Order Successful!"),
        backgroundColor: Colors.green,
      ),
    );
  }
}


