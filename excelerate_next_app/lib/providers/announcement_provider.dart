/// Live announcements feed used by Home and Updates screens.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/announcement.dart';
import '../services/firestore_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  AnnouncementProvider({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService() {
    _subscribe();
  }

  final FirestoreService _firestore;
  StreamSubscription<List<Announcement>>? _sub;

  List<Announcement> _announcements = [];
  bool _isLoading = true;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;

  /// Latest announcements first — already sorted by query, but expose a helper.
  List<Announcement> get latest => _announcements;

  void _subscribe() {
    _sub = _firestore.watchAnnouncements().listen(
      (items) {
        _announcements = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
