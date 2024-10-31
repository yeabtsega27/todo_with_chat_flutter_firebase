import 'package:flutter/material.dart';
import 'package:todo_app_with_chat/core/models/toDoModel.dart';
import 'package:todo_app_with_chat/features/Todo/view//to_do_detail_page.dart';

class ToDoCard extends StatelessWidget {
  final ToDoModel todo;

  const ToDoCard({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ToDoDetailPage(todoId: todo.id)));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed size image placeholder
              todo.photos.isEmpty
                  ? const SizedBox(height: 0)
                  : todo.photos.length == 1
                      ? Container(
                          // height: 400,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.network(
                            todo.photos[0].photoURL,
                            fit: BoxFit.fitWidth,
                          ),
                        )
                      : Container(
                          child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: todo.photos.length > 6
                                  ? 6
                                  : todo.photos.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                              ),
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.network(
                                    todo.photos[index].photoURL,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }),
                        ),
              const SizedBox(height: 5),
              todo.title != ""
                  ? Text(
                      todo.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const SizedBox(height: 0),
              // If checkboxes are present, show them, otherwise show the note
              todo.checkBoxList.isNotEmpty
                  ? buildCheckBoxList(todo.checkBoxList)
                  : todo.note != ""
                      ? Text(
                          todo.note,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        )
                      : const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCheckBoxList(List<CheckBox> checkBoxList) {
    return Column(
      children: checkBoxList
          .map(
            (checkbox) => Row(
              children: [
                Checkbox(
                  value: checkbox.status == 'Complete',
                  onChanged: (bool? newValue) {
                    // Update the checkbox status logic
                  },
                ),
                Expanded(
                  child: Text(
                    checkbox.note,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
