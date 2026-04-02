import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/health_tips_provider.dart';

class PublishTipScreen extends ConsumerStatefulWidget {
  const PublishTipScreen({super.key});

  @override
  ConsumerState<PublishTipScreen> createState() => _PublishTipScreenState();
}

class _PublishTipScreenState extends ConsumerState<PublishTipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();

  String _category = 'AUTRE';
  String _visibility = 'ALL';
  List<String> _districts = [];
  bool _publishing = false;

  static const _categories = [
    ('AUTRE', '💡 Autre'),
    ('NUTRITION', '🥗 Nutrition'),
    ('SPORT', '🏃 Sport & Activité'),
    ('SANTE_MENTALE', '🧠 Santé mentale'),
    ('PREVENTION', '🔬 Prévention'),
    ('MEDICAMENT', '💊 Médicaments'),
    ('HYGIENE', '🧼 Hygiène'),
    ('GROSSESSE', '🤰 Grossesse'),
    ('ENFANT', '👶 Santé enfant'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    super.dispose();
  }

  void _addDistrict() {
    final d = _districtCtrl.text.trim();
    if (d.isNotEmpty && !_districts.contains(d)) {
      setState(() => _districts.add(d));
      _districtCtrl.clear();
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_visibility == 'DISTRICT' && _districts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un quartier')),
      );
      return;
    }

    setState(() => _publishing = true);

    final data = {
      'title': _titleCtrl.text.trim(),
      'content': _contentCtrl.text.trim(),
      'category': _category,
      'visibility': _visibility,
      if (_visibility != 'ALL') 'target_city': _cityCtrl.text.trim(),
      if (_visibility == 'DISTRICT') 'target_districts': _districts,
    };

    final ok = await ref.read(healthTipsProvider.notifier).publishTip(data);
    if (!mounted) return;
    setState(() => _publishing = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Astuce publiée ! Les patients ciblés ont été notifiés.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la publication'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text('Publier une astuce santé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Catégorie ──────────────────────────────────────────────
              const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories.map((cat) {
                    final selected = _category == cat.$1;
                    return GestureDetector(
                      onTap: () => setState(() => _category = cat.$1),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF10B981) : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: selected ? const Color(0xFF10B981) : Colors.grey.shade300),
                        ),
                        child: Text(cat.$2, style: TextStyle(fontSize: 13, color: selected ? Colors.white : Colors.black87, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // ── Titre ──────────────────────────────────────────────────
              const Text('Titre', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                decoration: _inputDeco('Ex : 5 conseils pour bien dormir'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Titre requis' : null,
              ),
              const SizedBox(height: 16),

              // ── Contenu ────────────────────────────────────────────────
              const Text('Contenu du conseil', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 6,
                decoration: _inputDeco('Rédigez votre conseil ou astuce santé…'),
                validator: (v) => v == null || v.trim().length < 20 ? 'Minimum 20 caractères' : null,
              ),
              const SizedBox(height: 24),

              // ── Visibilité ─────────────────────────────────────────────
              const Text('Qui verra ce conseil ?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 10),
              _VisibilityOption(
                value: 'ALL',
                selected: _visibility == 'ALL',
                icon: Icons.public,
                label: 'Tout le monde',
                subtitle: 'Visible par tous les patients de l\'application',
                onTap: () => setState(() => _visibility = 'ALL'),
              ),
              const SizedBox(height: 8),
              _VisibilityOption(
                value: 'CITY',
                selected: _visibility == 'CITY',
                icon: Icons.location_city,
                label: 'Une ville',
                subtitle: 'Visible uniquement dans une ville précise',
                onTap: () => setState(() => _visibility = 'CITY'),
              ),
              const SizedBox(height: 8),
              _VisibilityOption(
                value: 'DISTRICT',
                selected: _visibility == 'DISTRICT',
                icon: Icons.place,
                label: 'Des quartiers',
                subtitle: 'Ciblage ultra-précis par quartier de résidence',
                onTap: () => setState(() => _visibility = 'DISTRICT'),
              ),

              // ── Ville (si CITY ou DISTRICT) ────────────────────────────
              if (_visibility != 'ALL') ...[
                const SizedBox(height: 20),
                const Text('Ville', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cityCtrl,
                  decoration: _inputDeco('Ex : Yaoundé'),
                  validator: (v) => _visibility != 'ALL' && (v == null || v.trim().isEmpty)
                      ? 'Ville requise'
                      : null,
                ),
              ],

              // ── Quartiers (si DISTRICT) ────────────────────────────────
              if (_visibility == 'DISTRICT') ...[
                const SizedBox(height: 16),
                const Text('Quartiers ciblés', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _districtCtrl,
                      decoration: _inputDeco('Ex : Bastos, Mvan…'),
                      onFieldSubmitted: (_) => _addDistrict(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addDistrict,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ]),
                if (_districts.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 6,
                    children: _districts.map((d) => Chip(
                      label: Text(d, style: const TextStyle(fontSize: 13)),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() => _districts.remove(d)),
                      backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                      deleteIconColor: const Color(0xFF10B981),
                    )).toList(),
                  ),
                ],
              ],

              const SizedBox(height: 32),

              // ── Bouton publier ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _publishing ? null : _publish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _publishing
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('Publier et notifier les patients', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981))),
      );
}

class _VisibilityOption extends StatelessWidget {
  final String value;
  final bool selected;
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.value,
    required this.selected,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF10B981).withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF10B981) : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? const Color(0xFF10B981) : Colors.grey, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? const Color(0xFF10B981) : Colors.black87)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
          ),
          if (selected) const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
        ]),
      ),
    );
  }
}
