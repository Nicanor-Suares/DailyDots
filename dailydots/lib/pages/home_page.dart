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

          // cancel button
          MaterialButton(onPressed: () {
            // close modal
            Navigator.pop(context);
            // clear controller
            textController.clear();
          },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add),
      ),
      body: _buildHabitList(),
    );
  }

  Widget _buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.builder(
      itemCount: currentHabits.length,
      itemBuilder: (context, index) {
        final habit = currentHabits[index];

        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        return ListTile(
          title: Text(habit.name),
          );
      },
    );
  }

}