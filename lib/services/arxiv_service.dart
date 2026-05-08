import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../models/research_paper.dart';

class ArxivService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://export.arxiv.org/api',
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  static final Map<String, List<ResearchPaper>> _cache = {};
  static DateTime? _lastRequestTime;

  static Future<List<ResearchPaper>> search(String keyword, {int retryCount = 0}) async {
    if (_cache.containsKey(keyword)) {
      return _cache[keyword]!;
    }

    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed.inSeconds < 3) {
        await Future.delayed(Duration(seconds: 3 - elapsed.inSeconds));
      }
    }

    try {
      _lastRequestTime = DateTime.now();

      final response = await _dio.get(
        '/query',
        queryParameters: {
          'search_query': 'all:"$keyword"',
          'start': 0,
          'max_results': 10,
        },
      );

      final document = XmlDocument.parse(response.data.toString());
      final entries = document.findAllElements('entry');
      List<ResearchPaper> papers = [];

      for (final entry in entries) {
        final title = entry.findElements('title').first.innerText.trim();
        final summary = entry.findElements('summary').first.innerText.trim();
        final published = entry.findElements('published').first.innerText.trim();
        final link = entry.findElements('id').first.innerText.trim();

        papers.add(
          ResearchPaper(
            title: title,
            summary: summary,
            link: link,
            published: published,
          ),
        );
      }

      _cache[keyword] = papers;
      return papers;
    } on DioException catch (e) {
      if (retryCount < 1 && (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.response?.statusCode == 429)) {
        await Future.delayed(const Duration(seconds: 4));
        return search(keyword, retryCount: retryCount + 1);
      }

      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timed out. ArXiv servers are currently slow.');
      }
      if (e.response?.statusCode == 429) {
        throw Exception('ArXiv is busy (Rate Limited). Please try again in 10 seconds.');
      }
      throw Exception('ArXiv is temporarily unavailable. Check your connection.');
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }
}
