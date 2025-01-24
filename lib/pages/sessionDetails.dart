import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Ensure Supabase is imported
import '../classes.dart';

class SessionDetailsPage extends StatelessWidget {
  final sportSession session;

  const SessionDetailsPage({super.key, required this.session});

  // Function to delete the session from Supabase
  Future<void> deleteSession(BuildContext context) async {
    final response = await Supabase.instance.client
        .from('sessions')
        .delete()
        .eq('id', session.id);

    if (response.error != null) {
      // Handle error if the deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error!.message}')),
      );
    } else {
      // If deletion is successful, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session deleted successfully')),
      );
      // Optionally, navigate back to the previous screen after successful deletion
      Navigator.pop(context);
    }
  }

  // Show confirmation dialog before deleting
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
            // Add Delete Button
            ElevatedButton(
              onPressed: () => _showDeleteConfirmation(context),
              child: const Text('Delete Session'),
            ),
          ],
        ),
      ),
    );
  }
}
