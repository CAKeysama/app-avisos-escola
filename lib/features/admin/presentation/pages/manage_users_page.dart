import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/role_request_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/controllers/role_requests_controller.dart';

class ManageUsersPage extends ConsumerStatefulWidget {
  const ManageUsersPage({super.key});

  @override
  ConsumerState<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends ConsumerState<ManageUsersPage> {
  List<UserEntity> _users = [];
  int _selectedTab = 0; // 0 = Solicitações Pendentes, 1 = Todos os Usuários
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  StreamSubscription? _usersSub;

  @override
  void initState() {
    super.initState();
    _listenToFirestoreUsers();
  }

  void _listenToFirestoreUsers() {
    _usersSub = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _users = snapshot.docs.map((doc) {
            final data = doc.data();
            return UserEntity(
              id: doc.id,
              name: data['name'] as String? ?? 'Usuário',
              email: data['email'] as String? ?? '',
              role: UserRole.fromString(data['role'] as String?),
              courseId: data['courseId'] as String?,
              courseName: data['courseName'] as String?,
              semester: data['semester'] as int?,
              classId: data['classId'] as String?,
              className: data['className'] as String?,
              institution: data['institution'] as String? ?? 'FATEC',
            );
          }).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _changeUserRoleDirectly(UserEntity user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separator = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final textPrimary = isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary;
    final textSecondary = isDark ? AppColors.labelSecondaryDark : AppColors.labelSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 16),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: separator,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: Text(
                    'Alterar Papel de ${user.name}',
                    style: AppTypography.headline.copyWith(color: textPrimary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Defina diretamente as permissões de acesso deste usuário:',
                    style: AppTypography.caption.copyWith(color: textSecondary),
                  ),
                ),
                Container(height: 0.5, color: separator),
                ...UserRole.values.map((role) {
                  final isCurrent = user.role == role;
                  return Column(
                    children: [
                      ListTile(
                        tileColor: Colors.transparent,
                        leading: Icon(
                          isCurrent
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isCurrent
                              ? (isDark ? AppColors.primaryLight : AppColors.primary)
                              : separator,
                          size: 20,
                        ),
                        title: Text(
                          role.label,
                          style: AppTypography.body.copyWith(
                            color: textPrimary,
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        onTap: () async {
                          // Atualiza diretamente no Cloud Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.id)
                              .update({'role': role.name});

                          if (ctx.mounted) Navigator.of(ctx).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Papel de ${user.name} alterado para ${role.label}'),
                              ),
                            );
                          }
                        },
                      ),
                      Container(
                        height: 0.5,
                        color: separator,
                        margin: const EdgeInsets.only(left: 52),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingRequests =
        ref.watch(roleRequestsProvider.notifier).pendingRequests;

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separator = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final textPrimary = isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary;
    final textSecondary = isDark ? AppColors.labelSecondaryDark : AppColors.labelSecondary;
    final textTertiary = isDark ? AppColors.labelTertiaryDark : AppColors.labelTertiary;
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: Text(
          'Usuários & Cargos',
          style: AppTypography.navTitle.copyWith(color: textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: accent),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: separator.withOpacity(0.6)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                // ── Segmented Control iOS ──────────────────────────────────
                Container(
                  height: 36,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.fillDark : AppColors.fillLight,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      _SegmentTab(
                        label: 'Solicitações (${pendingRequests.length})',
                        isSelected: _selectedTab == 0,
                        surface: surface,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                      _SegmentTab(
                        label: 'Todos os Usuários (${_users.length})',
                        isSelected: _selectedTab == 1,
                        surface: surface,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Conteúdo da Aba 0: Solicitações Pendentes ───────────────
                if (_selectedTab == 0) ...[
                  if (pendingRequests.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 48, color: AppColors.success),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhuma solicitação pendente',
                            style: AppTypography.headline
                                .copyWith(color: textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Todas as solicitações de cargos foram processadas.',
                            style: AppTypography.footnote
                                .copyWith(color: textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    Material(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (int i = 0; i < pendingRequests.length; i++) ...[
                            _RoleRequestTile(
                              request: pendingRequests[i],
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              textTertiary: textTertiary,
                              accent: accent,
                              onApprove: () {
                                ref
                                    .read(roleRequestsProvider.notifier)
                                    .approveRequest(pendingRequests[i].id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Solicitação de ${pendingRequests[i].userName} aprovada!',
                                    ),
                                  ),
                                );
                              },
                              onReject: () {
                                ref
                                    .read(roleRequestsProvider.notifier)
                                    .rejectRequest(pendingRequests[i].id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Solicitação de ${pendingRequests[i].userName} recusada.',
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (i < pendingRequests.length - 1)
                              Container(
                                height: 0.5,
                                color: separator,
                                margin: const EdgeInsets.only(left: 16),
                              ),
                          ],
                        ],
                      ),
                    ),
                ],

                // ── Conteúdo da Aba 1: Todos os Usuários ───────────────────
                if (_selectedTab == 1) ...[
                  // Barra de busca estilo iOS
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.fillDark : AppColors.fillLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      textAlignVertical: TextAlignVertical.center,
                      style: AppTypography.subheadline
                          .copyWith(color: textPrimary),
                      decoration: InputDecoration(
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Buscar por nome, e-mail ou cargo...',
                        hintStyle: AppTypography.subheadline
                            .copyWith(color: textTertiary),
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 18, color: textTertiary),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                                child: Icon(Icons.cancel,
                                    size: 16, color: textTertiary),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Lista de Usuários Filtrados
                  () {
                    final filteredUsers = _users.where((u) {
                      if (_searchQuery.trim().isEmpty) return true;
                      final q = _searchQuery.trim().toLowerCase();
                      return u.name.toLowerCase().contains(q) ||
                          u.email.toLowerCase().contains(q) ||
                          u.role.label.toLowerCase().contains(q) ||
                          u.academicSummary.toLowerCase().contains(q);
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 42, color: textTertiary),
                            const SizedBox(height: 10),
                            Text(
                              'Nenhum usuário encontrado',
                              style: AppTypography.headline
                                  .copyWith(color: textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Não há resultados para "$_searchQuery"',
                              style: AppTypography.footnote
                                  .copyWith(color: textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return Material(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (int i = 0; i < filteredUsers.length; i++) ...[
                            _UserTile(
                              user: filteredUsers[i],
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              textTertiary: textTertiary,
                              accent: accent,
                              onTap: () =>
                                  _changeUserRoleDirectly(filteredUsers[i]),
                            ),
                            if (i < filteredUsers.length - 1)
                              Container(
                                height: 0.5,
                                color: separator,
                                margin: const EdgeInsets.only(left: 16),
                              ),
                          ],
                        ],
                      ),
                    );
                  }(),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Componentes auxiliares ──────────────────────────────────────────────────

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? surface : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? textPrimary : textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleRequestTile extends StatelessWidget {
  final RoleRequestEntity request;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RoleRequestTile({
    required this.request,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.userName,
                  style: AppTypography.subheadline.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Pediu: ${request.requestedRole.label}',
                  style: AppTypography.caption.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${request.userEmail} • ${request.currentRole.label}',
            style: AppTypography.caption.copyWith(color: textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onReject,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: const Text('Recusar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Aprovar Cargo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserEntity user;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 19,
              backgroundColor: accent.withOpacity(0.12),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Informações do Usuário
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: AppTypography.subheadline.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user.role.label,
                          style: AppTypography.caption2.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: AppTypography.caption.copyWith(color: textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.academicSummary.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      user.academicSummary,
                      style: AppTypography.caption2
                          .copyWith(color: textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 16, color: textTertiary),
          ],
        ),
      ),
    );
  }
}
