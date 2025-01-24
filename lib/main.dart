import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'keys.dart';
import 'classes.dart';
import 'pages/sessionDetails.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_KEY,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sessions',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _future = Supabase.instance.client.from('sessions').select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar is a header that appears at the top of the screen
      appBar: AppBar(
        title: const Text('Sessions'),
      ),
      // body is the main content of the screen
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle empty data
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          // Extract sessions and convert to Session objects
          final sessions = (snapshot.data as List<dynamic>)
              .map((item) => sportSession.fromMap(item))
              .toList();

          // Display sessions in a ListView
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                title: Text(
                    '${session.discipline} - ${session.date.toLocal().toString().split(' ')[0]}'),
                subtitle: Text(
                    'Distance: ${session.distance} km | Duration: ${session.duration} min'),
                trailing: Text('Sensations: ${session.sensations}'),
                onTap: () {
                  // Navigate to the details page on tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SessionDetailsPage(session: session),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
