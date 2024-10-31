import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
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

        return Body(
          todoList: todoList,
          pinedTodoList: pinedTodoList,
        );
      },
      stream: _databaseService.getMyToDo(),
    );
  }
}

class Body extends StatefulWidget {
  List<ToDoModel> todoList;
  List<ToDoModel> pinedTodoList;
  Body({
    super.key,
    required this.todoList,
    required this.pinedTodoList,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isGrid = false;
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
    return Stack(
      children: [
        // Main content
        Column(
          children: [
            // Custom App Bar
            ToDoAppBar(
              onChange: (bool value) {
                setState(() {
                  isGrid = value;
                });
              },
            ),
            // Body content
            Expanded(
              child: widget.todoList.isEmpty
                  ? const Center(child: Text("No todo found"))
                  : isGrid
                      ? buildGridView(widget.todoList, widget.pinedTodoList)
                      : buildListView(
                          [...widget.pinedTodoList, ...widget.todoList]),
            ),
          ],
        ),
        // Floating Action Button
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () async {
              String id = await _databaseService.createToDo();
              _navigationService.push(MaterialPageRoute(
                  builder: (context) => ToDoDetailPage(todoId: id)));
            },
            child: Container(
              margin: const EdgeInsets.all(
                  16.0), // Optional: Add margin around the button
              decoration: const BoxDecoration(
                color: Color(0xFF229ED9),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0), // Adjust padding for size
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30, // Size of the icon
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGridView(
      List<ToDoModel> todoList, List<ToDoModel> pinedTodoList) {
    return MasonryGridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2, // Number of columns in the grid
      itemCount: todoList.length + pinedTodoList.length,
      itemBuilder: (context, index) {
        if (pinedTodoList.length > index) {
          return ToDoCard(todo: pinedTodoList[index]);
        } else {
          return ToDoCard(todo: todoList[index - (pinedTodoList.length)]);
        }
      },
    );
  }

  Widget buildListView(List<ToDoModel> todoList) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: todoList.length,
      itemBuilder: (context, index) {
        if (todoList[index].pined && index == 0) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(child: Text("pined")),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(child: ToDoCard(todo: todoList[index])),
                ],
              )
            ],
          );
        }
        if (index > 0 && !todoList[index].pined && todoList[index - 1].pined) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(child: Text("others")),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(child: ToDoCard(todo: todoList[index])),
                ],
              )
            ],
          );
        }
        return ToDoCard(todo: todoList[index]);
      },
    );
  }
}
