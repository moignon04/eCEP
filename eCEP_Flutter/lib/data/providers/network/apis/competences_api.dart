import 'dart:io';

import 'package:client/app/services/local_storage.dart';
import 'package:client/data/models/lesson.dart';
import 'package:client/data/providers/network/api_endpoint.dart';
import 'package:client/data/providers/network/api_request_representable.dart';
import 'package:client/data/providers/network/api_provider.dart';
import 'package:get/get.dart';

enum CompetenceActionType { getAll, searchByName, searchByCategory}

class CompetenceClientAPI implements APIRequestRepresentable {
  final CompetenceActionType type;
  String? searchTerm;
  String? categoryId;
  DateTime? date;
  int? country;
  final store = Get.find<LocalStorageService>();

  CompetenceClientAPI._({
    required this.type,
    this.searchTerm,
    this.categoryId,
    this.date,
    this.country,
  });

  // Get all services constructor
  CompetenceClientAPI.getAll() : this._(type: CompetenceActionType.getAll);

  // Search by service name
  CompetenceClientAPI.searchByName({required String searchTerm})
      : this._(type: CompetenceActionType.searchByName, searchTerm: searchTerm);

  // Search by category
  CompetenceClientAPI.searchByCategory({required String categoryId})
      : this._(type: CompetenceActionType.searchByCategory, categoryId: categoryId);

  @override
  String get endpoint => APIEndpoint.baseURL + "/client";

  @override
  String get path {
    switch (type) {
      case CompetenceActionType.getAll:
        return "/services";
      case CompetenceActionType.searchByName:
        return "/services/search";
      case CompetenceActionType.searchByCategory:
        return "/services/category/$categoryId";
      default:
        return "";
    }
  }

  @override
  HTTPMethod get method {
    switch (type) {
      case CompetenceActionType.getAll:
      case CompetenceActionType.searchByCategory:
      case CompetenceActionType.searchByName:
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
    if (type == CompetenceActionType.searchByName) {
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
