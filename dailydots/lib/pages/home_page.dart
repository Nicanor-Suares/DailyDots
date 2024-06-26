import 'package:dailydots/components/my_habit_tile.dart';
import 'package:dailydots/components/my_heat_map.dart';
import 'package:dailydots/database/habit_database.dart';
import 'package:dailydots/models/habit.dart';
import 'package:dailydots/util/habit_util.dart';
import 'package:flutter/material.dart';
import 'package:dailydots/components/my_drawer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  final TextEditingController textController = TextEditingController();

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: "Create a new habit"),
        ),
        actions: [
            // cancel button
            MaterialButton(onPressed: () {
              // close modal
              Navigator.pop(context);
              // clear controller
              textController.clear();
            },
              child: const Text("Cancel"),
            ),
            // save button
            MaterialButton(onPressed: () {
            // get new habit's name
            String newHabitName = textController.text;

            // save
            context.read<HabitDatabase>().addHabit(newHabitName);
            // close modal
            Navigator.pop(context);

            // clear controller
            textController.clear();
          },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  // edit habit box
  void editHabitBox(Habit habit) {
    // pre-set name
    textController.text = habit.name;
    showDialog(context: context, builder: (context) => AlertDialog(
      content: TextField(
        controller: textController,
      ),
      actions: [
            // cancel button
            MaterialButton(onPressed: () {
              // close modal
              Navigator.pop(context);
              // clear controller
              textController.clear();
            },
              child: const Text("Cancel"),
            ),
            // save button
            MaterialButton(onPressed: () {
            // get new habit's name
            String newHabitName = textController.text;

            // save
            context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);
            // close modal
            Navigator.pop(context);

            // clear controller
            textController.clear();
          },
            child: const Text("Save"),
          ),
      ],
    ),);
  }


  // delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Are you sure you want to delete the habit?"),
      actions: [
            // cancel button
            MaterialButton(onPressed: () {
              // close modal
              Navigator.pop(context);
              // clear controller
              textController.clear();
            },
              child: const Text("Cancel"),
            ),
            // delete button
            MaterialButton(onPressed: () {
            // delete
            context.read<HabitDatabase>().deleteHabit(habit.id);
            // close modal
            Navigator.pop(context);
          },
            child: const Text("Delete"),
          ),
      ],
    ),);
  }


  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Daily Dots"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: iconColor,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: iconColor,
        ),
      ),
      body: ListView(
        children: [
          //HEATMAP
          _buildHeatMap(),
          //HABIT LIST
          _buildHabitList(),
        ],
      ),
    );
  }

Widget _buildHeatMap() {
  final habitDatabase = context.watch<HabitDatabase>();
  List<Habit> currentHabits = habitDatabase.currentHabits;

  return FutureBuilder<DateTime?>(
    future: habitDatabase.getFirstLaunchDate(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Container(
          margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          padding: const EdgeInsets.all(12.0), // Adjust padding as needed
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // Slightly gray background color
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8), // Adjust spacing as needed
              MyHeatMap(
                startDate: snapshot.data!,
                datasets: prepHeatMapDataset(currentHabits),
              ),
            ],
          ),
        );
      } else {
        return Container();
      }
    },
  );
}



Widget _buildHabitList() {
  final habitDatabase = context.watch<HabitDatabase>();
  List<Habit> currentHabits = habitDatabase.currentHabits;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          'My Habits',
        ),
      ),
      ListView.builder(
        itemCount: currentHabits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final habit = currentHabits[index];
          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

          return MyHabitTile(
            text: habit.name,
            isCompleted: isCompletedToday,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        },
      ),
    ],
  );
}


}