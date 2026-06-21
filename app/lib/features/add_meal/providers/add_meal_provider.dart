import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/add_meal_state.dart';

final addMealProvider = StateNotifierProvider<AddMealNotifier, AddMealState>((ref) {
  return AddMealNotifier();
});

class AddMealNotifier extends StateNotifier<AddMealState> {
  AddMealNotifier() : super(AddMealState(
    date: DateTime.now(),
    time: TimeOfDay.now(),
  ));

  void setPhotos(List<AddMealPhoto> photos) {
    state = state.copyWith(photos: photos);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setTime(TimeOfDay time) {
    state = state.copyWith(time: time);
  }

  void addFood(String name) {
    if (state.foods.any((f) => f.name == name)) return;
    state = state.copyWith(
      foods: [...state.foods, AddMealFood(name: name, sortOrder: state.foods.length)],
    );
  }

  void removeFood(int index) {
    final foods = [...state.foods];
    foods.removeAt(index);
    state = state.copyWith(foods: foods);
  }

  void updateFood(int index, String name) {
    final foods = [...state.foods];
    foods[index] = AddMealFood(name: name, sortOrder: index);
    state = state.copyWith(foods: foods);
  }

  void setSource(MealSource source) {
    state = state.copyWith(
      source: source,
      restaurant: source == MealSource.home ? null : state.restaurant,
      branch: source == MealSource.home ? null : state.branch,
    );
  }

  void setRestaurant(String? restaurant) {
    state = state.copyWith(restaurant: restaurant);
  }

  void setBranch(String? branch) {
    state = state.copyWith(branch: branch);
  }

  void addTag(String tag) {
    if (state.tags.contains(tag)) return;
    state = state.copyWith(tags: [...state.tags, tag]);
  }

  void removeTag(String tag) {
    state = state.copyWith(tags: state.tags.where((t) => t != tag).toList());
  }

  void setPrice(double? price) {
    state = state.copyWith(price: price);
  }

  void setHeaviness(Heaviness? heaviness) {
    state = state.copyWith(heaviness: heaviness);
  }

  void setFeeling(Feeling? feeling) {
    state = state.copyWith(feeling: feeling);
  }

  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  void setPrivate(bool isPrivate) {
    state = state.copyWith(isPrivate: isPrivate);
  }

  void reset() {
    state = AddMealState(date: DateTime.now(), time: TimeOfDay.now());
  }
}
