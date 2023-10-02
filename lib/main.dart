// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_typing_uninitialized_variables

import 'dart:core';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'util.dart';

var message;
const String databaseHost = '47.250.10.195';
const int databasePort = 5432;
const String databaseName = 'amast_rnd';
const String username = 'rnd_user';
final String password = dotenv.get('SERVER_PASSWORD', fallback: '');

var databaseConnection = PostgreSQLConnection(
  databaseHost,
  databasePort,
  databaseName,
  queryTimeoutInSeconds: 3600,
  timeoutInSeconds: 3600,
  username: username,
  password: password,
);

initDatabaseConnection() async {
  try {
    // Open a connection to the PostgreSQL database
    await databaseConnection.open();

    // Check if the connection is successful
    if (databaseConnection.isClosed) {
      message = 'Failed to connect to the database.';
    } else {
      message = 'Connected to the database.';
      // You can now execute your database queries here.
    }
  } catch (e) {
    message = 'Error connecting to the database: $e';
  } finally {
    // Close the database connection when done
    // await databaseConnection.close();
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterConfig.loadEnvVariables();
  await dotenv.load(fileName: '.env');
  await initDatabaseConnection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String response = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(message),
              spaceVertical(15),
              ElevatedButton(
                  onPressed: () async {
                    // await databaseConnection.open();
                    await databaseConnection.query('''
        CREATE TABLE public.table_imran(
          id serial primary key NOT NULL,
          name text NULL,
          email text NULL
        );
        ''');

                    print('query passed: 1');
                    await databaseConnection.close();
                    setState(() {
                      message = 'Closed connection, reload to reconnect.';
                    });
                    print('close connection: 1');
                  },
                  child: Text('Create New Table')),
              spaceVertical(10),
              ElevatedButton(
                  onPressed: () async {
                    await databaseConnection.query('''
        DROP TABLE public.table_imran;
        ''');
                    print('query passed: 1');
                    await databaseConnection.close();
                    setState(() {
                      message = 'Closed connection, reload to reconnect.';
                    });
                    print('close connection: 1');
                  },
                  child: Text('Delete Table')),
              spaceVertical(100),
              ElevatedButton(
                  onPressed: () async {
                    // await databaseConnection.open();
                    await databaseConnection.query('''
        INSERT INTO public.table_imran(name,email)
        VALUES ('Imran', 'imr4nfazli@gmail.com');
        ''');

                    print('query passed: 1');
                    await databaseConnection.close();
                    setState(() {
                      message = 'Closed connection, reload to reconnect.';
                    });
                    print('close connection: 1');
                  },
                  child: Text('Create Data')),
              spaceVertical(10),
              ElevatedButton(
                  onPressed: () async {
                    var postgresResponse = await databaseConnection.query('''
        SELECT * from public.table_imran;
        ''');
                    print('query passed: 1');

                    if (postgresResponse.isEmpty) {
                      await databaseConnection.close();
                      response = '===\nDatabase is empty.\n===';
                      setState(() {
                        message = 'Closed connection, reload to reconnect.';
                      });
                      return;
                    }

                    await databaseConnection.close();
                    setState(() {
                      message = 'Closed connection, reload to reconnect.';
                      for (var row in postgresResponse) {
                        String temp = '''
        ===
        id: ${row[0]}
        name: ${row[1]}
        email: ${row[2]}
        ===
        ''';
                        response = '$response\n$temp';
                      }
                    });
                    print(response);

                    print('close connection: 1');
                  },
                  child: Text('Read Data')),
              spaceVertical(10),
              // Text('response\n$response'),
              response == '' ? SizedBox() : Text(response),
              response == '' ? SizedBox() : spaceVertical(10),
              ElevatedButton(
                  onPressed: () async {
                    await databaseConnection.query('''
        UPDATE public.table_imran SET email='fazli.salikin@gmail.com' WHERE id=2;
        ''');
                    print('query passed: 1');

                    await databaseConnection.close();
                    setState(() {
                      message = 'Closed connection, reload to reconnect.';
                    });
                    print('close connection: 1');
                  },
                  child: Text('Update Data')),
              spaceVertical(10),
              ElevatedButton(
                  onPressed: () async {
                    await databaseConnection.query('''
        DELETE FROM public.table_imran WHERE id>0;
        ''');
                    print('query passed: 1');

                    await databaseConnection.close();
                    setState(() {
                      message = 'Closed connection, reload to reconnect.';
                    });
                    print('close connection: 1');
                  },
                  child: Text('Delete Data')),
              spaceVertical(100),
              ElevatedButton(
                  onPressed: () async {
                    await databaseConnection.close();
                  },
                  child: Text('Close Connection')),
              spaceVertical(50),
            ],
          ),
        ),
      ),
    );
  }
}
