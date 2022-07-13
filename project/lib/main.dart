import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final taskcontroler = TextEditingController();

  Future<void> init() async {
    var databasesPath = await getDatabasesPath();
    String path = '$databasesPath demo.db';

// Delete the database
    await deleteDatabase(path);

// open the database
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
    });

// Insert some records in a transaction
    await database.transaction((txn) async {
      // int id1 = await txn.rawInsert(
      //     'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');

      int id2 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
          ['$taskcontroler.text', 12345678, 3.1416]);
    });

// Update some record
    int count = await database.rawUpdate(
        'UPDATE Test SET name = ?, value = ? WHERE name = ?',
        ['updated name', '9876', 'some name']);

// Get the records
    List<Map> list = await database.rawQuery('SELECT * FROM Test');
    List<Map> expectedList = [
      {'name': 'updated name', 'id': 1, 'value': 9876, 'num': 456.789},
      {'name': 'another name', 'id': 2, 'value': 12345678, 'num': 3.1416}
    ];
    print(list);
    print(expectedList);

// Delete a record
    // count = await database
    //     .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
    // assert(count == 1);

// Close the database
    await database.close();
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   init();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: taskcontroler,
              decoration: const InputDecoration(hintText: 'Escreva sua tarefa'),
            ),
            MaterialButton(
              onPressed: () {
                init();
              },
              child: const Text('salvar'),
            )
          ],
        ),
      ),
    );
  }
}
