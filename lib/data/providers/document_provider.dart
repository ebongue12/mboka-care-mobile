import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/document_model.dart';
import 'auth_provider.dart';

class DocumentState {
  final List<DocumentModel> documents;
  final bool isLoading;
  final String? error;

  DocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
  });

  DocumentState copyWith({
    List<DocumentModel>? documents,
    bool? isLoading,
    String? error,
  }) => DocumentState(
    documents: documents ?? this.documents,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class DocumentNotifier extends StateNotifier<DocumentState> {
  final ApiClient _api;

  DocumentNotifier(this._api) : super(DocumentState());

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final r = await _api.getDocuments();
      final data = r.data;
      List<DocumentModel> docs = [];
      if (data is List) {
        docs = data
            .map((e) => DocumentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (data is Map && data['results'] is List) {
        docs = (data['results'] as List)
            .map((e) => DocumentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      state = state.copyWith(documents: docs, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de charger les documents',
      );
    }
  }
}

final documentProvider =
    StateNotifierProvider<DocumentNotifier, DocumentState>(
  (ref) => DocumentNotifier(ref.watch(apiClientProvider)),
);
