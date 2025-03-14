import 'dart:io';

import 'package:client/app/services/local_storage.dart';
import 'package:client/data/providers/network/api_endpoint.dart';
import 'package:client/data/providers/network/api_request_representable.dart';
import 'package:client/data/providers/network/api_provider.dart';
import 'package:get/get.dart';

enum ProductActionType { getAll, searchByName, searchByCategory, purchase }

class ProductClientAPI implements APIRequestRepresentable {
  final ProductActionType type;
  String? searchTerm;
  String? categoryId;
  String? productId;
  int? quantity;
  final store = Get.find<LocalStorageService>();

  ProductClientAPI._({
    required this.type,
    this.searchTerm,
    this.categoryId,
    this.productId,
    this.quantity,
  });

  // Get all products constructor
  ProductClientAPI.getAll() : this._(type: ProductActionType.getAll);

  // Search by product name
  ProductClientAPI.searchByName({required String searchTerm})
      : this._(type: ProductActionType.searchByName, searchTerm: searchTerm);

  // Search by category
  ProductClientAPI.searchByCategory({required String categoryId})
      : this._(type: ProductActionType.searchByCategory, categoryId: categoryId);

  // Purchase product
  ProductClientAPI.purchase({required String productId, required int quantity})
      : this._(type: ProductActionType.purchase, productId: productId, quantity: quantity);

  @override
  String get endpoint => APIEndpoint.baseURL + "/client";

  @override
  String get path {
    switch (type) {
      case ProductActionType.getAll:
        return "/products";
      case ProductActionType.searchByName:
        return "/products/search";
      case ProductActionType.searchByCategory:
        return "/products/category/$categoryId";
      case ProductActionType.purchase:
        return "/products/$productId/purchase";
      default:
        return "";
    }
  }

  @override
  HTTPMethod get method {
    switch (type) {
      case ProductActionType.getAll:
      case ProductActionType.searchByCategory:
      case ProductActionType.searchByName:
        return HTTPMethod.get;
      case ProductActionType.purchase:
        return HTTPMethod.post;
      default:
        return HTTPMethod.get;
    }
  }

  @override
  Map<String, String> get headers => {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${store.token}',
      };

  @override
  Map<String, String>? get query {
    if (type == ProductActionType.searchByName) {
      return {
        "name": searchTerm!,
      };
    }
    return null;
  }

  @override
  dynamic get body {
    if (type == ProductActionType.purchase) {
      return {
        "quantity": quantity,
      };
    }
    return null;
  }

  @override
  String get url => endpoint + path;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
