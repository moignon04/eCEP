import 'dart:io';

import 'package:client/app/services/local_storage.dart';
import 'package:client/data/providers/network/api_endpoint.dart';
import 'package:client/data/providers/network/api_request_representable.dart';
import 'package:client/data/providers/network/api_provider.dart';
import 'package:get/get.dart';

enum ServiceActionType { getAll, searchByName, searchByCategory}

class ServiceClientAPI implements APIRequestRepresentable {
  final ServiceActionType type;
  String? searchTerm;
  String? categoryId;
  DateTime? date;
  int? country;
  final store = Get.find<LocalStorageService>();

  ServiceClientAPI._({
    required this.type,
    this.searchTerm,
    this.categoryId,
    this.date,
    this.country,
  });

  // Get all services constructor
  ServiceClientAPI.getAll() : this._(type: ServiceActionType.getAll);

  // Search by service name
  ServiceClientAPI.searchByName({required String searchTerm})
      : this._(type: ServiceActionType.searchByName, searchTerm: searchTerm);

  // Search by category
  ServiceClientAPI.searchByCategory({required String categoryId})
      : this._(type: ServiceActionType.searchByCategory, categoryId: categoryId);

  @override
  String get endpoint => APIEndpoint.baseURL + "/client";

  @override
  String get path {
    switch (type) {
      case ServiceActionType.getAll:
        return "/services";
      case ServiceActionType.searchByName:
        return "/services/search";
      case ServiceActionType.searchByCategory:
        return "/services/category/$categoryId";
      default:
        return "";
    }
  }

  @override
  HTTPMethod get method {
    switch (type) {
      case ServiceActionType.getAll:
      case ServiceActionType.searchByCategory:
      case ServiceActionType.searchByName:
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
    if (type == ServiceActionType.searchByName) {
      return {
        "name": searchTerm!,
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

  @override
  get body => null;

}
