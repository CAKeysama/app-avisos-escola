import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/role_requests_controller.dart';
import '../controllers/announcement_feed_controller.dart';
import '../widgets/announcement_card.dart';
import '../widgets/feed_filter_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).user;
    final announcementsAsync = ref.watch(announcementsFeedStreamProvider);
    final pendingRequestsCount = ref
        .watch(roleRequestsProvider.notifier)
        .pendingRequests
        .length;

    final canCreate = user != null &&
        (user.role.canCreateForClass ||
            user.role.canCreateForCourse ||
            user.role.canCreateForSchool);

    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separator = isDark ? AppColors.separatorDark : AppColors.separatorLight;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      // AppBar mínima — só título e ícone de perfil
      appBar: AppBar(
        backgroundColor: surface,
        title: Text(
          AppConstants.appName,
          style: AppTypography.navTitle.copyWith(
            color: isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary,
          ),
        ),
        actions: [
          if (user?.role.canManageUsers == true)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.shield_outlined,
                      size: 22,
                      color: isDark ? AppColors.primaryLight : AppColors.primary),
                  onPressed: () => context.push('/admin'),
                  tooltip: 'Painel da Gestão',
                ),
                if (pendingRequestsCount > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.destructive,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$pendingRequestsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          // Avatar do usuário — minimalista
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.fillDark
                    : AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: separator.withOpacity(0.6)),
        ),
      ),

      // FAB circular — simples, não estendido
      floatingActionButton: canCreate
          ? _CircleFAB(
              onPressed: () => context.push('/create-announcement'),
              isDark: isDark,
            )
          : null,

      body: CustomScrollView(
        slivers: [
          // ── Saudação + Filtros ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large Title — estilo iOS Mail/Mensagens
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                    child: Text(
                      _greeting(user?.name),
                      style: AppTypography.largeTitle.copyWith(
                        color: isDark
                            ? AppColors.labelPrimaryDark
                            : AppColors.labelPrimary,
                      ),
                    ),
                  ),
                  if (user?.academicSummary != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        user!.academicSummary,
                        style: AppTypography.footnote.copyWith(
                          color: isDark
                              ? AppColors.labelSecondaryDark
                              : AppColors.labelSecondary,
                        ),
                      ),
                    ),

                  // Filtros
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: const FeedFilterBar(),
                  ),

                  // Separador antes da lista
                  Container(
                    height: 0.5,
                    color: separator,
                  ),
                ],
              ),
            ),
          ),

          // ── Lista de avisos — fundo cinza da página, seção branca ────
          announcementsAsync.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: AppLoading(message: 'Carregando...'),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: AppErrorView(
                message: e.toString(),
                onRetry: () =>
                    ref.invalidate(announcementsFeedStreamProvider),
              ),
            ),
            data: (announcements) {
              if (announcements.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: 'Tudo em dia',
                    message: 'Nenhum aviso encontrado.',
                    icon: Icons.done_all_rounded,
                  ),
                );
              }

              // Seção branca contida — estilo iOS grouped list
              return SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (int i = 0;
                            i < announcements.length;
                            i++) ...[
                          AnnouncementCard(
                            announcement: announcements[i],
                            onTap: () => context.push(
                                '/announcement/${announcements[i].id}'),
                          ),
                          if (i < announcements.length - 1)
                            Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: separator,
                              indent: 38, // alinhado após o dot
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final prefix = hour < 12
        ? 'Bom dia'
        : hour < 18
            ? 'Boa tarde'
            : 'Boa noite';
    if (name == null) return prefix;
    return '$prefix, ${name.split(' ').first}';
  }
}

/// Botão de ação flutuante circular — simples como o iOS.
class _CircleFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;
  const _CircleFAB({required this.onPressed, required this.isDark});

  @override
  State<_CircleFAB> createState() => _CircleFABState();
}

class _CircleFABState extends State<_CircleFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isDark ? AppColors.primaryLight : AppColors.primary;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_rounded,
              size: 26, color: Colors.white),
        ),
      ),
    );
  }
}
