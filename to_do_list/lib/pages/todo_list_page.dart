import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list/models/task.dart';

class TodoListPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    FirebaseFirestore.instance
        .collection("todos")
        .add({"title": _controller.text});

    _controller.text = "";
  }

  void _deleteTask(Task task) async {
    await FirebaseFirestore.instance
        .collection("todos")
        .doc(task.taskId)
        .delete();
  }

  Widget _buildList(QuerySnapshot snapshot) {
    return ListView.builder(
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        final doc = snapshot.docs[index];
        final task = Task.fromSnapShot(doc);
        return _buildListItem(task);
      },
    );
  }

  Widget _buildListItem(Task task) {
    return ListTile(
      title: Dismissible(
          key: Key(task.taskId),
          onDismissed: (direction) {
            _deleteTask(task);
          },
          background: Container(
            color: Colors.red,
          ),
          child: Text(task.title)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: "Enter task name"),
              )),
              FlatButton(
                color: Colors.green,
                onPressed: _addTask,
                child: Text(
                  "Add task",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("todos").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();

              return Expanded(child: _buildList(snapshot.data));
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
      ),
      body: _buildBody(context),
    );
  }
}
