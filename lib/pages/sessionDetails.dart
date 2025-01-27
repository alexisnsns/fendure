import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../classes.dart';

class SessionDetailsPage extends StatelessWidget {
  final sportSession session;

  const SessionDetailsPage({super.key, required this.session});

  // Function to update the session in Supabase
  Future<void> updateSession(
    BuildContext context,
    String discipline,
    double distance,
    int duration,
    String sensations,
  ) async {
    if (discipline.isEmpty ||
        distance <= 0 ||
        duration <= 0 ||
        sensations.isEmpty) {
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('sessions')
          .update({
            'discipline': discipline,
            'distance': distance,
            'duration': duration,
            'sensations': sensations,
          })
          .eq('id', session.id)
          .select();

      print('Updated data: $response');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session updated successfully')),
      );
      Navigator.pop(context);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print('Exception during update: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to show the update modal
  void _showUpdateModal(BuildContext context) {
    final TextEditingController disciplineController =
        TextEditingController(text: session.discipline);
    final TextEditingController distanceController =
        TextEditingController(text: session.distance.toString());
    final TextEditingController durationController =
        TextEditingController(text: session.duration.toString());
    final TextEditingController sensationsController =
        TextEditingController(text: session.sensations.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: disciplineController,
                  decoration: const InputDecoration(labelText: 'Discipline'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: distanceController,
                  decoration: const InputDecoration(labelText: 'Distance (km)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: durationController,
                  decoration:
                      const InputDecoration(labelText: 'Duration (minutes)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: sensationsController,
                  decoration: const InputDecoration(labelText: 'Sensations'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the modal
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform the update
                final updatedDiscipline = disciplineController.text;
                final updatedDistance =
                    double.tryParse(distanceController.text) ?? 0;
                final updatedDuration =
                    int.tryParse(durationController.text) ?? 0;
                final updatedSensations = sensationsController.text;

                updateSession(
                  context,
                  updatedDiscipline,
                  updatedDistance,
                  updatedDuration,
                  updatedSensations,
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete the session from Supabase
  Future<void> deleteSession(BuildContext context) async {
    final response = await Supabase.instance.client
        .from('sessions')
        .delete()
        .eq('id', session.id);

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error!.message}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session deleted successfully')),
      );
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Session'),
          content: const Text('Are you sure you want to delete this session?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                deleteSession(context); // Proceed with deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${session.discipline} - ${session.date.toLocal().toString().split(' ')[0]}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${session.date.toLocal().toString()}'),
            const SizedBox(height: 8),
            Text('Discipline: ${session.discipline}'),
            const SizedBox(height: 8),
            Text('Distance: ${session.distance} km'),
            const SizedBox(height: 8),
            Text('Duration: ${session.duration} minutes'),
            const SizedBox(height: 8),
            Text('Sensations: ${session.sensations}'),
            const SizedBox(height: 8),
            Text('User ID: ${session.userId ?? 'Not Available'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showDeleteConfirmation(context),
              child: const Text('Delete Session'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showUpdateModal(context),
              child: const Text('Update Session'),
            ),
          ],
        ),
      ),
    );
  }
}
