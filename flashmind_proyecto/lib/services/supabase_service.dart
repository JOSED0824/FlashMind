import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/home/data/models/progress_model.dart';

class SupabaseService {
  final SupabaseClient _client;
  final Box<ProgressModel> _progressBox;

  const SupabaseService(this._client, this._progressBox);

  static const _table = 'user_progress';

  /// Pulls cloud progress, merges with local (takes maximums),
  /// saves merged back to Hive and Supabase.
  Future<void> syncProgress(String userId) async {
    try {
      final local = _progressBox.get(userId) ?? ProgressModel.empty(userId);

      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        final cloudPoints = response['total_points'] as int? ?? 0;
        final cloudSessions = response['total_sessions'] as int? ?? 0;
        final cloudStreak = response['current_streak'] as int? ?? 0;
        final cloudLongest = response['longest_streak'] as int? ?? 0;
        final cloudTopics = (response['completed_topic_ids'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final cloudDate = response['last_session_date'] != null
            ? DateTime.tryParse(response['last_session_date'] as String)
            : null;

        final mergedTopics = <String>{
          ...local.completedTopicIds,
          ...cloudTopics,
        }.toList();

        final mergedDate =
            (cloudDate != null && local.lastSessionDate != null)
                ? (cloudDate.isAfter(local.lastSessionDate!)
                    ? cloudDate
                    : local.lastSessionDate)
                : cloudDate ?? local.lastSessionDate;

        final merged = ProgressModel(
          userId: userId,
          totalPoints: _max(local.totalPoints, cloudPoints),
          totalSessions: _max(local.totalSessions, cloudSessions),
          currentStreak: _max(local.currentStreak, cloudStreak),
          longestStreak: _max(local.longestStreak, cloudLongest),
          lastSessionDate: mergedDate,
          completedTopicIds: mergedTopics,
        );

        await _progressBox.put(userId, merged);
        await _push(merged);
      } else {
        await _push(local);
      }
    } catch (_) {
      // Supabase unavailable — local Hive data is used as fallback
    }
  }

  /// Pushes local progress to Supabase after a session completes.
  Future<void> pushProgress(String userId) async {
    try {
      final local = _progressBox.get(userId);
      if (local != null) await _push(local);
    } catch (_) {}
  }

  Future<void> _push(ProgressModel p) async {
    await _client.from(_table).upsert(
      {
        'user_id': p.userId,
        'total_points': p.totalPoints,
        'current_streak': p.currentStreak,
        'longest_streak': p.longestStreak,
        'total_sessions': p.totalSessions,
        'completed_topic_ids': p.completedTopicIds,
        'last_session_date': p.lastSessionDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  int _max(int a, int b) => a > b ? a : b;
}
