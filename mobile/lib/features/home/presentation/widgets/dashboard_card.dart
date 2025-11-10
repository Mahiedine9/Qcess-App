import 'package:flutter/material.dart';
import 'package:mobile/features/home/data/models/user_dashboard.dart';

class DashboardCard extends StatelessWidget {
  final UserDashboard userDashboard;

  const DashboardCard({super.key, required this.userDashboard});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (userDashboard.profilePictureUrl != null)
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(userDashboard.profilePictureUrl!),
                )
              else
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
              const SizedBox(height: 12),
              Text(
                userDashboard.username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 30),
              _buildStatRow("Total accès", userDashboard.totalAccess.toString()),
              _buildStatRow("Zones accessibles", userDashboard.totalZones.toString()),
              _buildStatRow(
                "Dernier accès",
                userDashboard.lastAccess != null
                    ? "${userDashboard.lastAccess}"
                    : "Aucun accès récent",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
