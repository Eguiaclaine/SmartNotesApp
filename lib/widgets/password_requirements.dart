import 'package:flutter/material.dart';

import '../utils/validation_utils.dart';

class PasswordRequirementsList extends StatelessWidget {
  const PasswordRequirementsList({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final requirements = PasswordRequirements(password);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Requirements',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        _RequirementRow(
          label: 'At least 8 characters',
          met: requirements.hasMinLength,
          scheme: scheme,
        ),
        _RequirementRow(
          label: 'Contains an uppercase letter',
          met: requirements.hasUppercase,
          scheme: scheme,
        ),
        _RequirementRow(
          label: 'Contains a lowercase letter',
          met: requirements.hasLowercase,
          scheme: scheme,
        ),
        _RequirementRow(
          label: 'Contains a number',
          met: requirements.hasNumber,
          scheme: scheme,
        ),
        _RequirementRow(
          label: 'Contains a special character',
          met: requirements.hasSpecial,
          scheme: scheme,
        ),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.label,
    required this.met,
    required this.scheme,
  });

  final String label;
  final bool met;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: met ? Colors.green : scheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: met ? scheme.onSurfaceVariant : scheme.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
