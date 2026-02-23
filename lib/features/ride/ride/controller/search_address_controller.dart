import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_api_headers/google_api_headers.dart';

// Simple model to store address suggestions
class AddressSuggestion {
  final String address;
  final String? placeId;

  AddressSuggestion({required this.address, this.placeId});

  Map<String, dynamic> toJson() {
    return {'address': address, 'placeId': placeId};
  }

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    return AddressSuggestion(
      address: json['address'] ?? '',
      placeId: json['placeId'],
    );
  }
}

class SearchAddressController extends GetxController {
  Rx<TextEditingController> searchTxtController = TextEditingController().obs;
  RxString searchText = ''.obs;
  RxList<AddressSuggestion> suggestionsList = <AddressSuggestion>[].obs;
  RxList<AddressSuggestion> recentSearches = <AddressSuggestion>[].obs;
  final debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  RxBool isSearch = false.obs;
  static const String recentSearchesKey = 'recent_location_searches';
  static const int maxRecentSearches = 10;

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
  }

  Future<void> loadRecentSearches() async {
    try {
      final String recentSearchesJson = Preferences.getString(
        recentSearchesKey,
      );
      if (recentSearchesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(recentSearchesJson);
        recentSearches.value = decoded
            .map((item) => AddressSuggestion.fromJson(item))
            .toList();
      }
    } catch (e) {
      log('Error loading recent searches: $e');
      recentSearches.value = [];
    }
  }

  Future<void> saveRecentSearch(AddressSuggestion suggestion) async {
    try {
      // Remove duplicate if exists
      recentSearches.removeWhere((item) => item.address == suggestion.address);

      // Add to beginning
      recentSearches.insert(0, suggestion);

      // Keep only max recent searches
      if (recentSearches.length > maxRecentSearches) {
        recentSearches.removeRange(maxRecentSearches, recentSearches.length);
      }

      // Save to preferences
      final List<Map<String, dynamic>> jsonList = recentSearches
          .map((item) => item.toJson())
          .toList();
      await Preferences.setString(recentSearchesKey, json.encode(jsonList));
    } catch (e) {
      log('Error saving recent search: $e');
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      recentSearches.value = [];
      await Preferences.setString(recentSearchesKey, '');
    } catch (e) {
      log('Error clearing recent searches: $e');
    }
  }

  Future<void> fetchAddress(String text) async {
    if (text.isEmpty) {
      suggestionsList.value = [];
      return;
    }

    isSearch.value = true;
    log(":: fetchAddress :: $text");
    try {
      String apiKey = Constant.kGoogleApiKey ?? '';
      // Check for empty, null string, or the literal "null" string
      if (apiKey.isEmpty ||
          apiKey.trim().isEmpty ||
          apiKey == 'null' ||
          apiKey.trim() == 'null') {
        log('⚠️ Using fallback API key (backend key is: "$apiKey")');
        apiKey = 'AIzaSyCvUrBOS0y4FDS6kAhkZhLRjTHtudwG43c';
      } else {
        apiKey = apiKey.trim();
        log('✅ Using API key from backend (length: ${apiKey.length})');
      }

      GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: apiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );

      PlacesAutocompleteResponse response = await places.autocomplete(
        text,
        language: 'en',
        components: [
          Component(Component.country, "kw"),
        ], // Restrict to Kuwait only
      );

      if (response.isOkay) {
        log(
          '✅ Places API: Found ${response.predictions.length} suggestions for "$text"',
        );
        suggestionsList.value = response.predictions
            .map(
              (prediction) => AddressSuggestion(
                address: prediction.description ?? '',
                placeId: prediction.placeId,
              ),
            )
            .toList();
      } else {
        log(
          '❌ Places API Error: ${response.errorMessage ?? "Unknown error"} (Status: ${response.status})',
        );
        suggestionsList.value = [];
      }
      isSearch.value = false;
    } catch (e, stackTrace) {
      log('❌ Exception in fetchAddress: $e');
      log('Stack trace: $stackTrace');
      suggestionsList.value = [];
      isSearch.value = false;
    }
  }
}
