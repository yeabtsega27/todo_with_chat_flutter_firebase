import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/DatabaseService.dart';
import 'package:todo_app_with_chat/Service/navigation_service.dart';
import 'package:todo_app_with_chat/core/models/toDoModel.dart';
import 'package:todo_app_with_chat/features/Todo/view//widgets/to_do_app_bar.dart';
import 'package:todo_app_with_chat/features/Todo/view//widgets/to_do_card.dart';
import 'package:todo_app_with_chat/features/Todo/view/to_do_detail_page.dart';
import 'package:todo_app_with_chat/locator.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});
  @override
  _ToDoPageState createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  late DatabaseService _databaseService;
  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Loading state
        }

        List<ToDoModel>? todoList = [];
        List<ToDoModel>? pinedTodoList = [];
        print("todo");
        snapshot.data?.forEach((todo) {
          if (todo.pined) {
            pinedTodoList.add(todo);
          } else {
            todoList.add(todo);
          }
        });
        List<ToDoModel> combinedList = [...pinedTodoList, ...todoList];

        return Body(
          todoList: combinedList,
        );
      },
      stream: _databaseService.getMyToDo(),
    );
  }
}

class Body extends StatefulWidget {
  List<ToDoModel> todoList;
  Body({
    super.key,
    required this.todoList,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isGrid = true;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  @override
  void initState() {
    super.initState();
    _databaseService = locator.get<DatabaseService>();
    _navigationService = locator.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ToDoAppBar(onChange: (bool value) {
        setState(() {
          isGrid = value;
        });
      }),
      body: Column(
        children: [
          (widget.todoList.isEmpty)
              ? const Text("no todo found")
              : Expanded(
                  child: isGrid
                      ? buildGridView(widget.todoList) // Show Grid View
                      : buildListView(widget.todoList),
                )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          String id = await _databaseService.createToDo();
          _navigationService.push(MaterialPageRoute(
              builder: (context) => ToDoDetailPage(todoId: id)));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildGridView(List<ToDoModel> todoList) {
    return MasonryGridView.count(
      crossAxisCount: 2, // Number of columns in the grid
      itemCount: todoList.length,
      itemBuilder: (context, index) {
        return ToDoCard(todo: todoList[index]);
      },
    );
  }

  Widget buildListView(List<ToDoModel> todoList) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: todoList.length,
      itemBuilder: (context, index) {
        return ToDoCard(todo: todoList[index]);
      },
    );
  }
}
