import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'keys.dart';
import 'classes.dart';
import 'pages/sessionDetails.dart';
import 'pages/addSession.dart';
import 'pages/analytics.dart';

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
  String _sortCriteria = 'Default';
  List<sportSession> _sessions = [];
  List<sportSession> _originalSessions = [];

  void _applySorting() {
    setState(() {
      if (_sortCriteria == 'Distance') {
        _sessions.sort((a, b) => a.distance.compareTo(b.distance));
      } else if (_sortCriteria == 'Duration') {
        _sessions.sort((a, b) => a.duration.compareTo(b.duration));
      } else {
        _sessions = List.from(_originalSessions); // Reset to original order
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        centerTitle: true,
        actions: [
          // Add Session Button
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSessionPage(),
                  ),
                );
              },
              child: Container(
                width: 150,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Add Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsPage(),
                  ),
                );
              },
              child: Container(
                width: 150, // Adjust width for larger button
                height: 50, // Adjust height for larger button
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green, // Button color
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: const Text(
                  'Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Larger text
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sort by:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12.0),
                DropdownButton<String>(
                  value: _sortCriteria,
                  items: const [
                    DropdownMenuItem(
                      value: 'Default',
                      child: Text('Default'),
                    ),
                    DropdownMenuItem(
                      value: 'Distance',
                      child: Text('Distance'),
                    ),
                    DropdownMenuItem(
                      value: 'Duration',
                      child: Text('Duration'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortCriteria = value!;
                    });
                    _applySorting();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                  return const Center(child: Text('No data available'));
                }

                // Initialize session lists when data is fetched
                if (_sessions.isEmpty && _originalSessions.isEmpty) {
                  final fetchedSessions = (snapshot.data as List<dynamic>)
                      .map((item) => sportSession.fromMap(item))
                      .toList();
                  _sessions = List.from(fetchedSessions);
                  _originalSessions = List.from(fetchedSessions);
                }

                return ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return ListTile(
                      title: Text(
                          '${session.discipline} - ${session.date.toLocal().toString().split(' ')[0]}'),
                      subtitle: Text(
                          'Distance: ${session.distance} km | Duration: ${session.duration} min'),
                      trailing: Text('Sensations: ${session.sensations}'),
                      onTap: () {
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
          ),
        ],
      ),
    );
  }
}
