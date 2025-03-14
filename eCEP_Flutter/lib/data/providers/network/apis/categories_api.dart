import 'dart:io';
import 'package:client/app/services/local_storage.dart';
import 'package:client/data/providers/network/api_endpoint.dart';
import 'package:client/data/providers/network/api_request_representable.dart';
import 'package:client/data/providers/network/api_provider.dart';
import 'package:get/get.dart';

enum CategoryActionType { getAll, searchByName }

class CategoryApi implements APIRequestRepresentable {
  final CategoryActionType actionType;
  final String? searchTerm;
  final LocalStorageService store = Get.find<LocalStorageService>();

  CategoryApi._({
    required this.actionType,
    this.searchTerm,
  });

  // Constructeur pour obtenir toutes les catégories
  CategoryApi.getAll() : this._(actionType: CategoryActionType.getAll);

  // Constructeur pour rechercher par nom de catégorie
  CategoryApi.searchByName({required String searchTerm})
      : this._(actionType: CategoryActionType.searchByName, searchTerm: searchTerm);

  @override
  String get endpoint => APIEndpoint.baseURL + "/client";

  @override
  String get path {
    switch (actionType) {
      case CategoryActionType.getAll:
        return "/categories";
      case CategoryActionType.searchByName:
        return "/categories/search";
      default:
        return "";
    }
  }

  @override
  HTTPMethod get method {
    switch (actionType) {
      case CategoryActionType.getAll:
      case CategoryActionType.searchByName:
        return HTTPMethod.get;
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
    if (actionType == CategoryActionType.searchByName) {
      return {
        "name": searchTerm!,
      };
    }
    return null;
  }

  @override
  dynamic get body => null; // Pas de corps pour les requêtes GET

  @override
  String get url => endpoint + path;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
