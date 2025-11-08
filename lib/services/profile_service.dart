import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Profile Service for managing user profiles in Supabase
class ProfileService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get current user's profile
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return null;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      if (kDebugMode) {
        print('[Profile] Fetched profile for user: $userId');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error fetching profile: $e');
      }
      return null;
    }
  }

  /// Create or update profile
  Future<void> upsertProfile(Map<String, dynamic> profileData) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      // Ensure id is set
      profileData['id'] = userId;
      profileData['updated_at'] = DateTime.now().toIso8601String();

      await _client
          .from('profiles')
          .upsert(profileData);

      if (kDebugMode) {
        print('[Profile] Upserted profile for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error upserting profile: $e');
      }
      rethrow;
    }
  }

  /// Update specific profile fields
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId);

      if (kDebugMode) {
        print('[Profile] Updated profile fields: ${updates.keys.join(", ")}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error updating profile: $e');
      }
      rethrow;
    }
  }

  /// Check if user has active premium subscription
  Future<bool> isPremium() async {
    try {
      final profile = await getProfile();
      if (profile == null) return false;

      final isPremium = profile['is_premium'] as bool? ?? false;
      final subscriptionStatus = profile['subscription_status'] as String?;

      // Check if premium and not expired
      if (isPremium && (subscriptionStatus == 'active' || subscriptionStatus == 'trial')) {
        // Check trial end date
        if (subscriptionStatus == 'trial') {
          final trialEndStr = profile['trial_end_date'] as String?;
          if (trialEndStr != null) {
            final trialEnd = DateTime.parse(trialEndStr);
            return DateTime.now().isBefore(trialEnd);
          }
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error checking premium status: $e');
      }
      return false;
    }
  }

  /// Activate trial period
  Future<void> activateTrial(int days) async {
    try {
      final trialEnd = DateTime.now().add(Duration(days: days));

      await updateProfile({
        'is_premium': true,
        'subscription_status': 'trial',
        'trial_end_date': trialEnd.toIso8601String(),
      });

      if (kDebugMode) {
        print('[Profile] Activated $days-day trial ending on $trialEnd');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error activating trial: $e');
      }
      rethrow;
    }
  }

  /// Activate premium subscription
  Future<void> activatePremium({required DateTime endDate}) async {
    try {
      await updateProfile({
        'is_premium': true,
        'subscription_status': 'active',
        'subscription_start_date': DateTime.now().toIso8601String(),
        'subscription_end_date': endDate.toIso8601String(),
      });

      if (kDebugMode) {
        print('[Profile] Activated premium subscription ending on $endDate');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error activating premium: $e');
      }
      rethrow;
    }
  }

  /// Cancel subscription (mark as expired)
  Future<void> cancelSubscription() async {
    try {
      await updateProfile({
        'is_premium': false,
        'subscription_status': 'expired',
      });

      if (kDebugMode) {
        print('[Profile] Cancelled subscription');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error cancelling subscription: $e');
      }
      rethrow;
    }
  }

  /// Update user settings
  Future<void> updateSettings({
    String? language,
    String? theme,
    String? units,
    bool? notificationsEnabled,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (language != null) updates['language'] = language;
      if (theme != null) updates['theme'] = theme;
      if (units != null) updates['units'] = units;
      if (notificationsEnabled != null) updates['notifications_enabled'] = notificationsEnabled;

      if (updates.isNotEmpty) {
        await updateProfile(updates);
      }

      if (kDebugMode) {
        print('[Profile] Updated settings: ${updates.keys.join(", ")}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error updating settings: $e');
      }
      rethrow;
    }
  }

  /// Update avatar URL
  Future<void> updateAvatar(String avatarUrl) async {
    try {
      await updateProfile({'avatar_url': avatarUrl});

      if (kDebugMode) {
        print('[Profile] Updated avatar URL');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error updating avatar: $e');
      }
      rethrow;
    }
  }

  /// Update physical stats
  Future<void> updatePhysicalStats({
    int? age,
    int? height,
    double? weight,
    String? gender,
    String? goal,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (age != null) updates['age'] = age;
      if (height != null) updates['height'] = height;
      if (weight != null) updates['weight'] = weight;
      if (gender != null) updates['gender'] = gender;
      if (goal != null) updates['goal'] = goal;

      if (updates.isNotEmpty) {
        await updateProfile(updates);
      }

      if (kDebugMode) {
        print('[Profile] Updated physical stats');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error updating physical stats: $e');
      }
      rethrow;
    }
  }
}
