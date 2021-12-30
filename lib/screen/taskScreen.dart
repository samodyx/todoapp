import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/models/taskModel.dart';
import 'package:todoapp/screen/addTask.dart';
import 'package:todoapp/utilities/dbHelper.dart';

class MyTasks extends StatefulWidget {
  @override
  _MyTasksState createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> {
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  Future<List<Task>> _taskList;
  DatabaseHelper _dbHelper;

  String todoListSearch="";

  void _refreshTaskList() async {
    setState(() {
      _taskList = _dbHelper.fetchTask(todoListSearch);
    });
  }

  @override
  void initState() {
    _dbHelper = DatabaseHelper.instance;
    _refreshTaskList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _refreshTaskList();
    return Scaffold(

        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddTask(
                      refreshList: _refreshTaskList,
                    )
                )
            );
          },
          child: Icon(Icons.add),
        ),
        body: FutureBuilder(
          future: _taskList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final int completedTask = snapshot.data
                .where((Task task) => task?.status == 1)
                .toList()
                .length;

            return ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: 60,
                  horizontal: 25,
                ),
                itemCount: 1+snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "My Tasks",
                          style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Completed $completedTask of ${snapshot.data.length}",
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),

                        SizedBox(
                          height: 20.0,
                        ),
                        TextField(
                          style: TextStyle(color: Colors.white),
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) {
                            setState(() {
                              todoListSearch = value;
                            });
                          },
                          decoration: InputDecoration(

                              labelText: 'Search',
                              labelStyle: TextStyle(
                                  color: Colors.white),
                              prefixIcon: Icon(Icons.search,
                              color: Color(0XFF06BAD9)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                              )),
                        ),

                        SizedBox(
                          height: 20,
                        ),
                      ],

                    );
                  }
                  return _buildTask(snapshot.data[index - 1]);
                });
          },
        ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildTask(Task task) {

    String date="";

    if(task?.date!=null){
      date=_dateFormat.format(task.date);
    }


    return Padding(
      padding: EdgeInsets.symmetric(),
      child: Material(

        color: Colors.transparent,
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(

              padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 10.0),
              decoration: BoxDecoration(
                gradient: task?.status==0? LinearGradient(begin: Alignment.topLeft,end: Alignment.bottomRight,colors: const [Color(0XFF70A9FF), Color(0XFF90BCFF),]):LinearGradient(begin: Alignment.topLeft,end: Alignment.bottomRight,colors: const [Color(0XFFFFC026 ), Color(0XFFFFA21D ),]),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                      color: Color(0XFF515151).withOpacity(.25),
                      blurRadius: 6,
                      offset: Offset(2, 5))
                ],
              ),
              child: ListTile(
                title: Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    task?.title!=null ? task.title : "Task" ,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,

                    ),
                  ),
                ),
                subtitle:
                Text("${date} . ${task?.priority}",
                    style: TextStyle(
                      fontSize: 15,
                    )),
                trailing: Checkbox(
                  onChanged: (val) {

                    task?.status = val ? 1 : 0;

                    _dbHelper.updateTask(task);
                    _refreshTaskList();
                  },
                  value: task?.status == 1 ? true : false,
                  activeColor: Color(0XFF52001B),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTask(
                      task: task,
                      refreshList: _refreshTaskList,
                    ),
                  ),
                ),

                leading:task?.status==0? Icon(Icons.event, color: task?.priority == "High" ?
                Colors.red : task?.priority=="Medium"? Color(0XFF0776CA):
                Color(0XFF0AA51A),):Icon(Icons.check, color: task?.priority == "High" ?
                Colors.red : Color(0XFF0E1D35),),
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
              ),
            ),
            SizedBox(
              height: 20,
            ),

          ],

        ),

      ),

    );

  }
}