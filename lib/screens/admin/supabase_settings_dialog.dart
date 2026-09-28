import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/supabase_config.dart';
import '../../theme/app_colors.dart';

class SupabaseSettingsDialog extends StatefulWidget {
  const SupabaseSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const SupabaseSettingsDialog(),
    );
  }

  @override
  State<SupabaseSettingsDialog> createState() => _SupabaseSettingsDialogState();
}

class _SupabaseSettingsDialogState extends State<SupabaseSettingsDialog> {
  final _urlController = TextEditingController();
  final _anonKeyController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final url = await SupabaseConfig.getUrl();
    final key = await SupabaseConfig.getAnonKey();
    _urlController.text = url;
    _anonKeyController.text = key;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _anonKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF3ECF8E).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storage_rounded, color: Color(0xFF3ECF8E), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Conexión con Supabase',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.navy, fontSize: 17),
            ),
          ),
        ],
      ),
      content: _isLoading
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingresa la URL del Proyecto y el Anon Key proporcionados en tu panel de Supabase (Project Settings > API):',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Project URL',
                      hintText: 'https://xxxxxxxxxxxx.supabase.co',
                      prefixIcon: Icon(Icons.link_rounded, size: 20, color: AppColors.navy),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _anonKeyController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Anon Public API Key',
                      hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI...',
                      prefixIcon: Icon(Icons.key_rounded, size: 20, color: AppColors.navy),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      'Tip: El esquema SQL de tablas (`users`, `branches`, `collaborators`, `stages`, `visits`) se encuentra en `supabase/schema.sql`. Puedes ejecutarlo en el SQL Editor de Supabase.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  setState(() => _isSaving = true);
                  final url = _urlController.text.trim();
                  final key = _anonKeyController.text.trim();

                  await SupabaseConfig.saveCredentials(url, key);
                  final success = await SupabaseConfig.initializeClient();

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '¡Conectado exitosamente con Supabase!'
                            : 'Credenciales guardadas. Reiniciando conexión...',
                      ),
                      backgroundColor: success ? AppColors.statusYes : AppColors.primary,
                    ),
                  );
                },
          child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Guardar y Conectar'),
        ),
      ],
    );
  }
}
