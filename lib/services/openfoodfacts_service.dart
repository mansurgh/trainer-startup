import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_product.dart';

/// Provider для Open Food Facts сервиса
final openFoodFactsServiceProvider = Provider<OpenFoodFactsService>((ref) {
  return OpenFoodFactsService();
});

/// Сервис для работы с Open Food Facts API
/// База данных 2M+ продуктов
class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const String _userAgent = 'Trainer - AI Fitness Coach - iOS/Android';

  final http.Client _client;

  OpenFoodFactsService({http.Client? client}) : _client = client ?? http.Client();

  /// Получить продукт по штрих-коду
  Future<FoodProduct?> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$_baseUrl/product/$barcode.json');
      
      final response = await _client.get(
        url,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // Проверяем что продукт найден
        if (data['status'] == 1 && data['product'] != null) {
          return FoodProduct.fromJson(data['product']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching product by barcode: $e');
      return null;
    }
  }

  /// Поиск продуктов по названию
  Future<List<FoodProduct>> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'search_terms': query,
          'page': page.toString(),
          'page_size': pageSize.toString(),
          'json': '1',
          'fields': 'code,product_name,brands,image_url,nutriments,serving_size,categories',
        },
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>? ?? [];
        
        return products
            .map((p) => FoodProduct.fromJson(p as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Поиск продуктов по категории
  Future<List<FoodProduct>> getProductsByCategory(
    String category, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/category/$category.json').replace(
        queryParameters: {
          'page': page.toString(),
          'page_size': pageSize.toString(),
          'fields': 'code,product_name,brands,image_url,nutriments,serving_size,categories',
        },
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>? ?? [];
        
        return products
            .map((p) => FoodProduct.fromJson(p as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}

/// State для хранения последних отсканированных продуктов
class ScannedProductsNotifier extends StateNotifier<List<FoodProduct>> {
  ScannedProductsNotifier() : super([]);

  void addProduct(FoodProduct product) {
    // Добавляем в начало списка
    state = [product, ...state];
    
    // Ограничиваем историю 20 продуктами
    if (state.length > 20) {
      state = state.sublist(0, 20);
    }
  }

  void clearHistory() {
    state = [];
  }
}

final scannedProductsProvider =
    StateNotifierProvider<ScannedProductsNotifier, List<FoodProduct>>((ref) {
  return ScannedProductsNotifier();
});
