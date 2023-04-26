// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_provider_state/utils/debounce.dart';

import '../models/todo_model.dart';
import '../provider/providers.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 40.0,
            ),
            child: Column(
              children: [
                const TodoHeader(),
                const CreateTodo(),
                const SizedBox(
                  height: 20.0,
                ),
                SearchAndFilteTodo(),
                const ShowTodos(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodoHeader extends StatelessWidget {
  const TodoHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Todo',
          style: TextStyle(fontSize: 40.0),
        ),
        Text(
          '${context.watch<ActiveTodoCountState>().activeTodoCount} items left',
          style: const TextStyle(fontSize: 20.0, color: Colors.redAccent),
        ),
      ],
    );
  }
}

class CreateTodo extends StatefulWidget {
  const CreateTodo({Key? key}) : super(key: key);

  @override
  State<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  final newTodoController = TextEditingController();
  @override
  void dispose() {
    newTodoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: newTodoController,
      decoration: const InputDecoration(labelText: 'What to do?'),
      onSubmitted: (String? todoDesc) {
        if (todoDesc != null && todoDesc.trim().isNotEmpty) {
          context.read<TodoList>().addTodo(todoDesc);
          newTodoController.clear();
        }
      },
    );
  }
}

class SearchAndFilteTodo extends StatelessWidget {
  SearchAndFilteTodo({super.key});
  final debounce = Debounce(millisecounds: 1000);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          // ignore: prefer_const_constructors
          decoration: InputDecoration(
            labelText: 'Search todo ',
            border: InputBorder.none,
            filled: true,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (String? newSearchTerm) {
            if (newSearchTerm != null) {
              debounce.run(() {
                context.read<TodoSearch>().setSearchTerm(newSearchTerm);
              });
            }
          },
        ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            fillterButton(context, Filter.all),
            fillterButton(context, Filter.active),
            fillterButton(context, Filter.completed),
          ],
        )
      ],
    );
  }
}

Widget fillterButton(BuildContext context, Filter filter) {
  return TextButton(
    onPressed: () {
      context.read<TodoFilter>().changeFilter(filter);
    },
    child: Text(
      filter == Filter.all
          ? 'All'
          : filter == Filter.active
              ? 'Active'
              : 'completed',
      style: TextStyle(
        fontSize: 18.0,
        color: textCoolor(context, filter),
      ),
    ),
  );
}

Color textCoolor(BuildContext context, Filter filter) {
  final currentFilter = context.watch<TodoFilterState>().filter;
  return currentFilter == filter ? Colors.blue : Colors.grey;
}

class ShowTodos extends StatelessWidget {
  const ShowTodos({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<FilteredTodosState>().filterdTodos;

    Widget showBackground(int direction) {
      return Container(
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          color: Colors.red,
          alignment: direction == 0 ? Alignment.centerLeft : Alignment.centerRight,
          // ignore: prefer_const_constructors
          child: Icon(
            color: Colors.white,
            size: 30.0,
            Icons.delete,
          ));
    }

    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemCount: todos.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(color: Colors.grey);
      },
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: ValueKey(todos[index].id),
          background: showBackground(0),
          secondaryBackground: showBackground(1),
          onDismissed: (_) {
            context.read<TodoList>().removeTodo(todos[index]);
          },
          child: Todoitem(todos: todos[index]),
          confirmDismiss: (_) {
            return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('are you sure?'),
                  content: const Text('Do you realy want to delete ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class Todoitem extends StatefulWidget {
  final Todo todos;

  const Todoitem({
    Key? key,
    required this.todos,
  }) : super(key: key);

  @override
  State<Todoitem> createState() => _TodoitemState();
}

class _TodoitemState extends State<Todoitem> {
  late final TextEditingController textController;
  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            bool _error = false;
            textController.text = widget.todos.desc;

            return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return AlertDialog(
                  title: const Text('Edit Todo'),
                  content: TextField(
                    controller: textController,
                    autofocus: true,
                    decoration: InputDecoration(errorText: _error ? 'Value cant be empty' : null),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _error = textController.text.isEmpty ? true : false;
                          if (!_error) {
                            context.read<TodoList>().editTodo(widget.todos.id, textController.text);
                            Navigator.pop(context);
                          }
                        });
                      },
                      child: const Text('Edite'),
                    )
                  ],
                );
              },
            );
          },
        );
      },
      leading: Checkbox(
        value: widget.todos.completed,
        onChanged: (bool? checked) {
          context.read<TodoList>().toggelTodo(widget.todos.id);
        },
      ),
      title: Text(widget.todos.desc),
    );
  }
}
