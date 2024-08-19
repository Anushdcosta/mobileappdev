import 'package:chat_app/main.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(secretapp());
}

class secretapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final double _fontSize = 18.0; // Change this to adjust font size

  void _addTask(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add({'task': task, 'completed': false});
      });
      _controller.clear();
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
    });
  }

  void _printHello() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _printHello();
              // If you need to navigate back in a real app, use Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a task',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _addTask(_controller.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final isCompleted = task['completed'] as bool;
                return ListTile(
                  title: Text(
                    task['task'],
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.black,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontSize: _fontSize, // Adjust the font size here
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(isCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank),
                    onPressed: () => _toggleTaskCompletion(index),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
