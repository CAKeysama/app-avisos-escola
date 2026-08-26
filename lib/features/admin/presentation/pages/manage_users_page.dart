import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';

class ManageUsersPage extends ConsumerStatefulWidget {
  const ManageUsersPage({super.key});

  @override
  ConsumerState<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends ConsumerState<ManageUsersPage> {
  late List<UserEntity> _users;

  @override
  void initState() {
    super.initState();
    _users = List.from(MockDataService.mockUsers);
  }

  void _changeUserRole(UserEntity user) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alterar Papel de ${user.name}', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ...UserRole.values.map((role) {
                return ListTile(
                  leading: Icon(
                    user.role == role ? Icons.check_circle : Icons.circle_outlined,
                    color: user.role == role ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(role.label),
                  onTap: () {
                    setState(() {
                      final index = _users.indexWhere((u) => u.id == user.id);
                      if (index != -1) {
                        _users[index] = _users[index].copyWith(role: role);
                      }
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Papel de ${user.name} alterado para ${role.label}')),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Usuários e Permissões'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final u = _users[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AppCard(
                    onTap: () => _changeUserRole(u),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
                          child: Text(u.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.name, style: AppTypography.labelLarge),
                              Text(
                                '${u.email} • ${u.academicSummary}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            u.role.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
