import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:textsummarize/dependencies/dependencies.dart';
import 'package:textsummarize/models/Pair.dart';
import 'package:textsummarize/pages/CallScreen.dart';
import 'package:textsummarize/pages/home.dart';
import 'package:textsummarize/services/IAuthenticateService.dart';
import './pages/login.dart';

void main() async {
  try{
    await dotenv.load(fileName: '.env');
  }
  catch(e){
    print(e);
    runApp(
    ErrorWidget(e.toString())
    );
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();  // Ensure Flutter is initialized

  Iauthenticateservice authService=Injection.getInstance<Iauthenticateservice>(Iauthenticateservice.typeName, true);

  Pair<bool,Object> result = await authService.initializing();

  if (!result.first) {
    // Handle Database initialization failure
    print("Database initialization failed: ${result.second}");
    runApp(
        ErrorWidget(result.second)
    );
    return; // Exit or handle the failure accordingly
  }

  Pair<bool,Object> authResult = await authService.getAuth();
  bool isAuthenticated = authResult.first;
  runApp(MyApp(isAuthenticated: isAuthenticated));
}

// void main() {
//   runApp(MaterialApp(
//     home: CallScreen(meetingId: "123456",isCaller: true,), // Example meeting ID
//     // home: CallScreen(meetingId: "123456"),
//   ));
// }

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Text Summarizer App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
    home: isAuthenticated ? const HomePage() : const LoginPage(),  // Navigate based on authentication status
    );
  }
}
