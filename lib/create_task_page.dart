import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class CreateTaskPage extends StatefulWidget {
  final ParseUser currentUser;

  const CreateTaskPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isSaving = false;

  Future<void> saveTask() async {
    setState(() {
      isSaving = true;
    });

    final task =
        ParseObject('Task')
          ..set('title', titleController.text.trim())
          ..set('description', descriptionController.text.trim())
          ..set('user', widget.currentUser);

    final response = await task.save();

    setState(() {
      isSaving = false;
    });

    if (response.success) {
      Navigator.pop(context); // Go back to homepage
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create task')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Task Title Field
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                labelStyle: TextStyle(color: theme.colorScheme.secondary),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.onSurface),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Task Description Field
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: theme.colorScheme.secondary),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.onSurface),
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 30),

            // Save Task Button
            isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary, // Updated here
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Task',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
