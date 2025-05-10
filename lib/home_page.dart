import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'create_task_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final ParseUser currentUser;

  const HomePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ParseObject> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('user', widget.currentUser);

    final response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        tasks = response.results as List<ParseObject>;
        isLoading = false;
      });
    } else {
      setState(() {
        tasks = [];
        isLoading = false;
      });
    }
  }

  Future<void> deleteTask(ParseObject task) async {
    final response = await task.delete();
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
      fetchTasks();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete task')));
    }
  }

  Future<void> editTask(ParseObject task) async {
    final updatedTitleController = TextEditingController(
      text: task.get<String>('title'),
    );
    final updatedDescriptionController = TextEditingController(
      text: task.get<String>('description'),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Task'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: updatedTitleController,
                    decoration: const InputDecoration(labelText: 'Task Title'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: updatedDescriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  task.set('title', updatedTitleController.text.trim());
                  task.set(
                    'description',
                    updatedDescriptionController.text.trim(),
                  );

                  final response = await task.save();

                  if (response.success) {
                    Navigator.pop(context);
                    fetchTasks();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task updated successfully'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update task')),
                    );
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
    );
  }

  Future<void> logout() async {
    await widget.currentUser.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : tasks.isEmpty
              ? const Center(child: Text('No tasks found.'))
              : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.get<String>('title') ?? 'Untitled',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(task.get<String>('description') ?? ''),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                label: const Text('Edit'),
                                onPressed: () => editTask(task),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                label: const Text('Delete'),
                                onPressed: () => deleteTask(task),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateTaskPage(currentUser: widget.currentUser),
            ),
          );
          fetchTasks(); // Refresh after adding task
        },
      ),
    );
  }
}
