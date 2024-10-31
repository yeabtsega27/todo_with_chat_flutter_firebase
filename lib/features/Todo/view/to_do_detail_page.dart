import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:todo_app_with_chat/Service/DatabaseService/database_service.dart';
import 'package:todo_app_with_chat/core/models/toDoModel.dart';
import 'package:todo_app_with_chat/features/Todo/view//show_image.dart';
import 'package:todo_app_with_chat/features/Todo/view//widgets/bottom_action.dart';
import 'package:todo_app_with_chat/features/Todo/view//widgets/note_input.dart';
import 'package:todo_app_with_chat/features/Todo/view//widgets/title_input.dart';
import 'package:todo_app_with_chat/locator.dart';

class ToDoDetailPage extends StatefulWidget {
  final String todoId;
  const ToDoDetailPage({super.key, required this.todoId});

  @override
  State<ToDoDetailPage> createState() => _ToDoDetailPageState();
}

class _ToDoDetailPageState extends State<ToDoDetailPage> {
  late DatabaseService _databaseService;
  @override
  void initState() {
    _databaseService = locator.get<DatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService().getToDoById(widget.todoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body:
                  Center(child: CircularProgressIndicator())); // Loading state
        }

        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text('Error: ${snapshot.error}'))); // Error state
        }
        if (snapshot.data == null) {
          return const Scaffold(
              body: Center(child: Text('No to do found'))); // Error state
        }

        ToDoModel toDo = snapshot.data ?? ToDoModel.fromJson({});

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    _databaseService.pinUnPinToDo(toDo.id, context);
                  },
                  icon: Icon(
                      toDo.pined ? Icons.push_pin : Icons.push_pin_outlined))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        StaggeredGrid.count(
                          crossAxisCount: 6,
                          children: (List.generate(toDo.photos.length, (i) {
                            int rem = toDo.photos.length % 3;
                            int count = rem == 1 && i == 0
                                ? 6
                                : rem == 2 && i <= 1
                                    ? 3
                                    : 2;
                            return StaggeredGridTile.count(
                                crossAxisCellCount: count,
                                mainAxisCellCount: count,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ShowImage(
                                                  photo: toDo.photos[i],
                                                  todoId: toDo.id,
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Image.network(
                                      toDo.photos[i].photoURL,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ));
                          })),
                        ),
                        TitleInput(title: toDo.title, id: toDo.id),
                        NoteInput(note: toDo.note, id: toDo.id),
                      ],
                    ),
                  ),
                )),
                BottomAction(
                  date: toDo.updatedAt.toString(),
                  todoId: toDo.id,
                  users: toDo.users,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
