import 'package:flutter/material.dart';
import '../../../data/models/family_member_model.dart';

class FamilyMemberDetailScreen extends StatelessWidget {
  final FamilyMemberModel member;
  const FamilyMemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(member.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // En-tête
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF009688), Color(0xFF00796B)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  member.firstName.isNotEmpty
                      ? member.firstName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(member.fullName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text(member.relationLabel,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 16),

          _InfoCard(title: '📋 Informations', rows: [
            if (member.phone?.isNotEmpty == true)
              _Row('Téléphone', member.phone!),
            if (member.email?.isNotEmpty == true)
              _Row('Email', member.email!),
            if (member.dateOfBirth != null)
              _Row('Naissance',
                  '${member.dateOfBirth!.day.toString().padLeft(2, '0')}/'
                  '${member.dateOfBirth!.month.toString().padLeft(2, '0')}/'
                  '${member.dateOfBirth!.year}'),
          ]),
          const SizedBox(height: 12),

          _InfoCard(title: '🏥 Santé', rows: [
            _Row('Groupe sanguin',
                member.bloodGroup?.isNotEmpty == true
                    ? member.bloodGroup!
                    : 'Non renseigné'),
            _Row('Allergies',
                member.allergies?.isNotEmpty == true
                    ? member.allergies!
                    : 'Aucune'),
            _Row('Maladies chroniques',
                member.chronicConditions?.isNotEmpty == true
                    ? member.chronicConditions!
                    : 'Aucune'),
          ]),
        ]),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_Row> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...rows,
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14)),
        ),
      ]),
    );
  }
}
