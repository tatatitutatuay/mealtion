import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/add_meal_state.dart';

const _draftsKey = 'meal_drafts';

class MealDraft {
  final String id;
  final DateTime savedAt;
  final AddMealState state;

  MealDraft({required this.id, required this.savedAt, required this.state});

  Map<String, dynamic> toJson() => {
        'id': id,
        'savedAt': savedAt.toIso8601String(),
        'state': _stateToJson(state),
      };

  factory MealDraft.fromJson(Map<String, dynamic> json) => MealDraft(
        id: json['id'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
        state: _stateFromJson(json['state'] as Map<String, dynamic>),
      );
}

Map<String, dynamic> _stateToJson(AddMealState s) => {
      'date': s.date.toIso8601String(),
      'timeHour': s.time.hour,
      'timeMinute': s.time.minute,
      'source': s.source.name,
      'restaurant': s.restaurant,
      'branch': s.branch,
      'tags': s.tags,
      'price': s.price,
      'heaviness': s.heaviness?.name,
      'feeling': s.feeling?.name,
      'note': s.note,
      'isPrivate': s.isPrivate,
      'foods': s.foods.map((f) => {'name': f.name, 'sortOrder': f.sortOrder}).toList(),
      // Photos stored as local paths only (files may not persist across sessions)
      'photoPaths': s.photos.map((p) => p.localPath).toList(),
    };

AddMealState _stateFromJson(Map<String, dynamic> j) => AddMealState(
      date: DateTime.parse(j['date'] as String),
      time: TimeOfDay(hour: j['timeHour'] as int, minute: j['timeMinute'] as int),
      source: MealSource.values.firstWhere((s) => s.name == j['source'], orElse: () => MealSource.restaurant),
      restaurant: j['restaurant'] as String?,
      branch: j['branch'] as String?,
      tags: (j['tags'] as List<dynamic>).cast<String>(),
      price: (j['price'] as num?)?.toDouble(),
      heaviness: j['heaviness'] != null
          ? Heaviness.values.firstWhere((h) => h.name == j['heaviness'], orElse: () => Heaviness.light)
          : null,
      feeling: j['feeling'] != null
          ? Feeling.values.firstWhere((f) => f.name == j['feeling'], orElse: () => Feeling.like)
          : null,
      note: j['note'] as String?,
      isPrivate: j['isPrivate'] as bool? ?? false,
      foods: (j['foods'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((f) => AddMealFood(name: f['name'] as String, sortOrder: f['sortOrder'] as int))
          .toList(),
      photos: const [],
    );

final draftProvider = StateNotifierProvider<DraftNotifier, List<MealDraft>>((ref) {
  return DraftNotifier();
});

class DraftNotifier extends StateNotifier<List<MealDraft>> {
  DraftNotifier() : super(const []);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftsKey);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    state = list.map(MealDraft.fromJson).toList();
  }

  Future<void> save(AddMealState mealState) async {
    final draft = MealDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      savedAt: DateTime.now(),
      state: mealState,
    );
    final newList = [draft, ...state];
    await _persist(newList);
    state = newList;
  }

  Future<void> delete(String id) async {
    final newList = state.where((d) => d.id != id).toList();
    await _persist(newList);
    state = newList;
  }

  Future<void> _persist(List<MealDraft> drafts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftsKey, jsonEncode(drafts.map((d) => d.toJson()).toList()));
  }
}
