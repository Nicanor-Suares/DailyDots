import 'package:dailydots/models/app_settings.dart';
import 'package:dailydots/models/habit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;


  // SET UP

  // INITIALIZE DATABASE
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  // Save first date of app startup (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // Get first date of app startup (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  // CRUD OPERATIONS

  // List of habits
  final List<Habit> currentHabits = [];

  // Create
  Future<void> addHabit(String habitName) async {
    // create new habit
    final newHabit = Habit()..name = habitName;

    // save to db
    await isar.writeTxn(() => isar.habits.put(newHabit));

    // re-read from db
    readHabits();
  }

  // Read
  Future<void> readHabits() async {
    // get all habits from db
    List <Habit> fetchedHabits = await isar.habits.where().findAll();

    // give to current habits (local list)
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    // update UI
    notifyListeners();
  }

  // Update (on/off)
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // find the habit from the id
    final habit = await isar.habits.get(id);
    // update completion status
    if(habit != null) {
      await isar.writeTxn(() async {
        // if habit completed -> add current date to completedDays
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          final today = DateTime.now();

          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day
            )
          );

        // if NOT completed -> remove current date from completedDays
        } else {
          habit.completedDays.removeWhere(
          (date) =>
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day);
        }
        // save the updated habits
        await isar.habits.put(habit);
      });
    }

    // re-read from db
    readHabits();
  }

  // Update (name)
  Future<void> updateHabitName(int id, String newName) async {
    // find habit by id
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habits.put(habit);
      });
    }

    readHabits();
  }

  // Delete
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    readHabits();
  }

}