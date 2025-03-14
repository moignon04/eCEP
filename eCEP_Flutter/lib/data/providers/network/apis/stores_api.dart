import 'dart:io';
import 'package:client/app/services/local_storage.dart';
import 'package:client/data/providers/network/api_endpoint.dart';
import 'package:client/data/providers/network/api_request_representable.dart';
import 'package:client/data/providers/network/api_provider.dart';
import 'package:get/get.dart';

enum StoreActionType { getAll, searchByName }

class StoreApi implements APIRequestRepresentable {
  final StoreActionType actionType;
  final String? searchTerm;
  final LocalStorageService store = Get.find<LocalStorageService>();

  StoreApi._({
    required this.actionType,
    this.searchTerm,
  });

  StoreApi.getAll() : this._(actionType: StoreActionType.getAll);

  StoreApi.searchByName({required String searchTerm})
      : this._(actionType: StoreActionType.searchByName, searchTerm: searchTerm);

  @override
  String get endpoint => APIEndpoint.baseURL + "/client";

  @override
  String get path {
    switch (actionType) {
      case StoreActionType.getAll:
        return "/stores";
      case StoreActionType.searchByName:
        return "/stores/search";
      default:
        return "";
    }
  }

  @override
  HTTPMethod get method {
    switch (actionType) {
      case StoreActionType.getAll:
      case StoreActionType.searchByName:
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
    if (actionType == StoreActionType.searchByName) {
      return {
        "name": searchTerm!,
      };
    }
    return null;
  }

  @override
  dynamic get body => null;

  @override
  String get url => endpoint + path;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
