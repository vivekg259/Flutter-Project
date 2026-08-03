/// Holds the live list of programs and the learner-facing filters.
///
/// Wraps [FirestoreService.watchPrograms] so the Programs screen can read,
/// search and filter programs reactively without touching Firestore.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/program.dart';
import '../services/firestore_service.dart';

class ProgramProvider extends ChangeNotifier {
  ProgramProvider({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService() {
    _subscribe();
    _startPublishTimer();
  }

  /// Test seam: builds the provider from a raw program stream without needing
  /// a real Firestore connection (used by widget/unit tests).
  @visibleForTesting
  ProgramProvider.fromStream(Stream<List<Program>> programStream)
    : _firestore = null {
    _subscribeTo(programStream);
    _startPublishTimer();
  }

  final FirestoreService? _firestore;
  StreamSubscription<List<Program>>? _sub;
  Timer? _publishTimer;

  List<Program> _allPrograms = [];
  List<Program> _filtered = [];
  List<Program> _published = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _levelFilter; // null = all levels
  String? _statusFilter; // null = all statuses

  List<Program> get programs => _filtered;
  List<Program> get publishedPrograms => _published;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get levelFilter => _levelFilter;
  String? get statusFilter => _statusFilter;

  /// Unique level values, derived from current data — used by the filter chip row.
  List<String> get availableLevels =>
      _allPrograms.map((p) => p.level).toSet().toList()..sort();

  void _subscribe() {
    _isLoading = true;
    notifyListeners();
    _sub = _firestore!.watchPrograms().listen(
      _onPrograms,
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Test seam — mirrors [_subscribe] using a caller-provided stream.
  void _subscribeTo(Stream<List<Program>> programStream) {
    _isLoading = true;
    notifyListeners();
    _sub = programStream.listen(
      _onPrograms,
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _onPrograms(List<Program> programs) {
    _allPrograms = programs;
    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  void setLevelFilter(String? level) {
    _levelFilter = level;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _levelFilter = null;
    _statusFilter = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _published = List<Program>.unmodifiable(
      _allPrograms.where((p) => p.isPublished),
    );
    _filtered = _allPrograms.where((p) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.instructor.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.skills.any(
            (s) => s.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
      final matchesLevel = _levelFilter == null || p.level == _levelFilter;
      final matchesStatus = _statusFilter == null || p.status == _statusFilter;
      final matchesPublished = p.isPublished;
      return matchesSearch && matchesLevel && matchesStatus && matchesPublished;
    }).toList();
  }

  /// Periodic re-check so scheduled-publish programs auto-surface without
  /// requiring a manual screen refresh by the learner.
  void _startPublishTimer() {
    _publishTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _applyFilters();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _publishTimer?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}
