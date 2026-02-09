// lib/providers/content_manager.dart

import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'dart:developer' as developer;
import 'dart:convert';

// A clean model to hold all the data for the homepage.
class PageContent {
  final Map<String, dynamic> siteContent;
  final List<Map<String, dynamic>> newsAndEvents;
  final List<Map<String, dynamic>> serviceTimes;

  PageContent({
    required this.siteContent,
    required this.newsAndEvents,
    required this.serviceTimes,
  });

  factory PageContent.empty() =>
      PageContent(siteContent: {}, newsAndEvents: [], serviceTimes: []);
}

class ContentManager extends ChangeNotifier {
  PageContent _content = PageContent.empty();
  bool _isLoading = true;
  String? _error;

  PageContent get content => _content;
  Map<String, dynamic> get siteContent => _content.siteContent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ContentManager() {
    fetchContent();
  }

  Future<void> fetchContent() async {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await ApiService.get('/homepage-content');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _content = PageContent(
          siteContent: data['site_content'] is Map<String, dynamic>
              ? data['site_content']
              : {},
          newsAndEvents: data['news_and_events'] is List
              ? List<Map<String, dynamic>>.from(data['news_and_events'])
              : [],
          serviceTimes: data['service_times'] is List
              ? List<Map<String, dynamic>>.from(data['service_times'])
              : [],
        );
        _error = null;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw 'Failed to load page content: ${errorData['message'] ?? 'Unknown error'}';
      }
    } catch (e, s) {
      developer.log("Error fetching homepage content",
          name: "ContentManager", error: e, stackTrace: s);
      _error =
          "Failed to load page content.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
