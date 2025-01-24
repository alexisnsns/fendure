import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddSessionPage extends StatefulWidget {
  const AddSessionPage({super.key});

  @override
  _AddSessionPageState createState() => _AddSessionPageState();
}

class _AddSessionPageState extends State<AddSessionPage> {
  final TextEditingController _disciplineController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _sensationsController = TextEditingController();

  String? _errorMessage; // To store the error message

  Future<void> addSession() async {
    final discipline = _disciplineController.text;
    final distance = double.tryParse(_distanceController.text);
    final duration = int.tryParse(_durationController.text);
    final date = DateTime.tryParse(_dateController.text);
    final sensation = int.tryParse(_sensationsController.text);

    setState(() {
      _errorMessage = null; // Reset error message
    });

    if (discipline.isEmpty ||
        distance == null ||
        duration == null ||
        date == null) {
      setState(() {
        _errorMessage = 'Please fill all fields correctly.';
      });
      return;
    }

    final formattedDate = date.toIso8601String();

    try {
      final response = await Supabase.instance.client.from('sessions').insert({
        'discipline': discipline,
        'distance': distance,
        'duration': duration,
        'date': formattedDate,
        'sensations': sensation,
      }).select();

      if (response.isEmpty) {
        setState(() {
          _errorMessage = 'No data returned from Supabase.';
        });
        return;
      }

      print('Inserted data: $response');
      Navigator.pop(context); // Navigate back on success
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
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
            TextField(
              controller: _disciplineController,
              decoration: const InputDecoration(
                labelText: 'Discipline',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date (YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _distanceController,
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sensationsController,
              decoration: const InputDecoration(
                labelText: 'Sensations',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: addSession,
              child: const Text('Add Session'),
            ),
            const SizedBox(height: 16),
            // Display error message if present
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
