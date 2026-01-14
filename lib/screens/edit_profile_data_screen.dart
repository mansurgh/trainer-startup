import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/noir_theme.dart';
import '../providers/profile_provider.dart';
import '../services/noir_toast_service.dart';
import '../l10n/app_localizations.dart';

class EditProfileDataScreen extends ConsumerStatefulWidget {
  const EditProfileDataScreen({super.key});
  @override
  ConsumerState<EditProfileDataScreen> createState() => _EditProfileDataScreenState();
}

class _EditProfileDataScreenState extends ConsumerState<EditProfileDataScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  bool _isSaving = false;

  bool _isValidAge(String value) {
    final age = int.tryParse(value);
    return age != null && age >= 10 && age <= 120;
  }

  bool _isValidHeight(String value) {
    final height = int.tryParse(value);
    return height != null && height >= 100 && height <= 250;
  }

  bool _isValidWeight(String value) {
    final weight = double.tryParse(value);
    return weight != null && weight >= 20 && weight <= 300;
  }

  @override
  void initState() {
    super.initState();
    // Load from ProfileProvider (not userProvider)
    final profile = ref.read(profileProvider).profile;
    _name.text = profile?.name ?? '';
    _age.text = (profile?.age ?? '').toString();
    _height.text = (profile?.height ?? '').toString();
    _weight.text = (profile?.weight ?? '').toString();
    
    // Add listeners for validation
    _name.addListener(() => setState(() {}));
    _age.addListener(() => setState(() {}));
    _height.addListener(() => setState(() {}));
    _weight.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      final notifier = ref.read(profileProvider.notifier);
      final l10n = AppLocalizations.of(context)!;
      
      // Update profile with all fields
      await notifier.updateProfile(
        name: _name.text.trim().isNotEmpty ? _name.text.trim() : null,
        age: int.tryParse(_age.text),
        height: int.tryParse(_height.text),
        weight: double.tryParse(_weight.text),
      );
      
      if (mounted) {
        NoirToast.success(context, l10n.dataSaved);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        NoirToast.error(context, 'Ошибка сохранения: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: kNoirBlack,
      appBar: AppBar(
        backgroundColor: kNoirBlack,
        foregroundColor: kContentHigh,
        title: Text(l10n.profileData, style: kNoirTitleLarge),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _NoirField(
            label: l10n.name,
            controller: _name,
            errorText: _name.text.isNotEmpty && _name.text.trim().isEmpty 
                ? l10n.enterName
                : null,
          ),
          _NoirField(
            label: l10n.age,
            controller: _age,
            keyboardType: TextInputType.number,
            errorText: _age.text.isNotEmpty && !_isValidAge(_age.text)
                ? '10-120'
                : null,
          ),
          _NoirField(
            label: l10n.height,
            controller: _height,
            keyboardType: TextInputType.number,
            suffix: l10n.cm,
            errorText: _height.text.isNotEmpty && !_isValidHeight(_height.text)
                ? '100-250'
                : null,
          ),
          _NoirField(
            label: l10n.weight,
            controller: _weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: l10n.kg,
            errorText: _weight.text.isNotEmpty && !_isValidWeight(_weight.text)
                ? '20-300'
                : null,
          ),
          const SizedBox(height: 24),
          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: kContentHigh,
                foregroundColor: kNoirBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadiusMD),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(kNoirBlack),
                      ),
                    )
                  : Text(
                      l10n.save,
                      style: kNoirBodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: kNoirBlack,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Noir Glass styled text field
class _NoirField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? errorText;
  final String? suffix;
  
  const _NoirField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.errorText,
    this.suffix,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: kNoirGraphite,
          borderRadius: BorderRadius.circular(kRadiusMD),
          border: Border.all(
            color: errorText != null
                ? const Color(0xFFF87171).withOpacity(0.5)
                : kBorderLight,
          ),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: kNoirBodyLarge.copyWith(color: kContentHigh),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: kNoirBodyMedium.copyWith(color: kContentMedium),
            suffixText: suffix,
            suffixStyle: kNoirBodyMedium.copyWith(color: kContentMedium),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorText: errorText,
            errorStyle: const TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }
}
