import 'dart:io';
import 'package:flutter/material.dart';

enum MealSource { restaurant, delivery, home }

enum Heaviness { light, satisfying, heavy }

enum Feeling { like, neutral, dislike }

class AddMealPhoto {
  final String localPath;
  final File file;
  int sortOrder;
  final bool isExisting;
  final String? storagePath;

  AddMealPhoto({required this.localPath, required this.file, required this.sortOrder, this.isExisting = false, this.storagePath});
}

class AddMealFood {
  String name;
  int sortOrder;

  AddMealFood({required this.name, required this.sortOrder});
}

class AddMealState {
  final List<AddMealPhoto> photos;
  final DateTime date;
  final TimeOfDay time;
  final List<AddMealFood> foods;
  final MealSource source;
  final String? restaurant;
  final String? branch;
  final List<String> tags;
  final double? price;
  final Heaviness? heaviness;
  final Feeling? feeling;
  final String? note;
  final bool isPrivate;

  const AddMealState({
    this.photos = const [],
    required this.date,
    required this.time,
    this.foods = const [],
    this.source = MealSource.restaurant,
    this.restaurant,
    this.branch,
    this.tags = const [],
    this.price,
    this.heaviness,
    this.feeling,
    this.note,
    this.isPrivate = false,
  });

  AddMealState copyWith({
    List<AddMealPhoto>? photos,
    DateTime? date,
    TimeOfDay? time,
    List<AddMealFood>? foods,
    MealSource? source,
    String? restaurant,
    String? branch,
    List<String>? tags,
    double? price,
    Heaviness? heaviness,
    Feeling? feeling,
    String? note,
    bool? isPrivate,
  }) {
    return AddMealState(
      photos: photos ?? this.photos,
      date: date ?? this.date,
      time: time ?? this.time,
      foods: foods ?? this.foods,
      source: source ?? this.source,
      restaurant: restaurant ?? this.restaurant,
      branch: branch ?? this.branch,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      heaviness: heaviness ?? this.heaviness,
      feeling: feeling ?? this.feeling,
      note: note ?? this.note,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  bool get hasData =>
      photos.isNotEmpty ||
      foods.isNotEmpty ||
      restaurant != null ||
      branch != null ||
      tags.isNotEmpty ||
      price != null ||
      heaviness != null ||
      feeling != null ||
      note != null;

  bool get isValid =>
      photos.isNotEmpty &&
      foods.isNotEmpty &&
      foods.every((f) => f.name.isNotEmpty);
}
