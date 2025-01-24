import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Ensure Supabase is imported

class AddSessionPage extends StatefulWidget {
  const AddSessionPage({super.key});

  @override
  _AddSessionPageState createState() => _AddSessionPageState();
}

class _AddSessionPageState extends State<AddSessionPage> {
  // Controllers for form fields
  final TextEditingController _disciplineController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _sensationsController = TextEditingController();

  // Function to add session to Supabase
  Future<void> addSession() async {
    final discipline = _disciplineController.text;
    final distance = double.tryParse(_distanceController.text);
    final duration = int.tryParse(_durationController.text);
    final date = DateTime.tryParse(_dateController.text);
    final sensation = int.tryParse(_sensationsController.text);

    if (date == null) {
      throw Exception('Invalid date format');
    }

    final formattedDate = date.toIso8601String();
    if (discipline.isEmpty || distance == null || duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    try {
      // Insert data into Supabase
      final response = await Supabase.instance.client.from('sessions').insert({
        'discipline': discipline,
        'distance': distance,
        'duration': duration,
        'date': formattedDate,
        'sensations': sensation,
      }).select(); // Ensures you get the inserted data

      // Check if data was successfully inserted
      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data returned from Supabase')),
        );
        return;
      }

      print('Inserted data: $response');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session added successfully!')),
      );

      Navigator.pop(context); // Navigate back
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discipline input
            TextField(
              controller: _disciplineController,
              decoration: const InputDecoration(
                labelText: 'Discipline',
              ),
            ),
            const SizedBox(height: 8),
            // Date input
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date (YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: 8),
            // Distance input
            TextField(
              controller: _distanceController,
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            // Duration input
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            // Sensations input
            TextField(
              controller: _sensationsController,
              decoration: const InputDecoration(
                labelText: 'Sensations',
              ),
            ),
            const SizedBox(height: 16),
            // Submit button
            ElevatedButton(
              onPressed: addSession,
              child: const Text('Add Session'),
            ),
          ],
        ),
      ),
    );
  }
}
