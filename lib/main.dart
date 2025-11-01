import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool hasNotification = false;



  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Welcome Back",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,

                          )),
                      Text(
                          "Stefani Wong",
                            style: GoogleFonts.poppins(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )),
                    ]
                  ),
                  Stack(
                    children: [
                      IconButton(
                      icon: Image.asset('assets/notification.png', width: 30, height: 30,),
                      onPressed: () {
                        setState(() {
                          hasNotification = !hasNotification;
                        });
                      }
                    ),
                    if (hasNotification)
                      Positioned(
                      right: 15,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width:1,
                            color: Colors.white,
                          ),
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      )
                    )
                    ],
                  )
                ]
              )
            ,
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [const Color(0xFFEAF0FE), const Color(0xFFE9EDFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
                )
              )
            ,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Weight"),
                        Text("Last 90 days")
                      ]
                    ),
                    IconButton(
                      icon: Text("+"),
                      onPressed: (){
                        print("Increment Weight");
                      },
                    )
                  ]
                )
              ]
            ))],
          ),
        )
      ),
    );
  }
}
