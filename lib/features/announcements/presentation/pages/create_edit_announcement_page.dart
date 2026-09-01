import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/announcement_category.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/announcement_priority.dart';
import '../../domain/entities/announcement_target.dart';
import '../controllers/announcement_feed_controller.dart';

class CreateEditAnnouncementPage extends ConsumerStatefulWidget {
  const CreateEditAnnouncementPage({super.key});

  @override
  ConsumerState<CreateEditAnnouncementPage> createState() =>
      _CreateEditAnnouncementPageState();
}

class _CreateEditAnnouncementPageState
    extends ConsumerState<CreateEditAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  AnnouncementCategory _category = AnnouncementCategory.general;
  AnnouncementPriority _priority = AnnouncementPriority.normal;
  AnnouncementTargetType _targetType = AnnouncementTargetType.classTarget;
  String? _selectedCourseId;
  String? _selectedClassId;
  bool _isPinned = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _selectedCourseId = user?.courseId ?? 'dsm';
    _selectedClassId = user?.classId ?? 'dsm-4-a';

    if (user?.role == UserRole.coordinator || user?.role == UserRole.admin) {
      _targetType = AnnouncementTargetType.school;
    } else {
      _targetType = AnnouncementTargetType.classTarget;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final newAnnouncement = AnnouncementEntity(
        id: 'aviso_${const Uuid().v4().substring(0, 8)}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        authorId: user.id,
        authorName: user.name,
        authorRole: user.role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        targetType: _targetType,
        targetId: _targetType == AnnouncementTargetType.classTarget
            ? _selectedClassId
            : (_targetType == AnnouncementTargetType.course ? _selectedCourseId : null),
        courseId: _selectedCourseId,
        classId: _selectedClassId,
        priority: _priority,
        category: _category,
        isPinned: _isPinned,
        isPublished: true,
      );

      await ref.read(createAnnouncementUseCaseProvider)(
        announcement: newAnnouncement,
        author: user,
      );

      if (mounted) {
        // Dispara notificação local nativa
        NotificationService().showLocalNotification(
          title: '📢 Novo Aviso: ${_titleController.text}',
          body: _descriptionController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aviso publicado no mural com sucesso!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Acesso não autorizado.')));
    }

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separator = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final textPrimary = isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary;
    final textSecondary = isDark ? AppColors.labelSecondaryDark : AppColors.labelSecondary;
    final textTertiary = isDark ? AppColors.labelTertiaryDark : AppColors.labelTertiary;
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;

    final availableClasses = MockDataService.classes
        .where((c) => c['courseId'] == _selectedCourseId)
        .toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: Text(
          'Novo Aviso',
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
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  // ── Seção: Conteúdo do Aviso ─────────────────────────────
                  _SectionHeader(label: 'CONTEÚDO DO AVISO', textTertiary: textTertiary),
                  _GroupedSection(
                    surface: surface,
                    separator: separator,
                    children: [
                      AppTextField(
                        hint: 'Título do Aviso',
                        controller: _titleController,
                        fillColor: Colors.transparent,
                        validator: (val) =>
                            Validators.minLength(val, 5, 'Título muito curto'),
                        textInputAction: TextInputAction.next,
                      ),
                      AppTextField(
                        hint: 'Descrição detalhada do comunicado...',
                        controller: _descriptionController,
                        fillColor: Colors.transparent,
                        maxLines: 4,
                        validator: (val) =>
                            Validators.minLength(val, 10, 'Descrição muito curta'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Seção: Classificação ─────────────────────────────────
                  _SectionHeader(label: 'CLASSIFICAÇÃO E PÚBLICO', textTertiary: textTertiary),
                  _GroupedSection(
                    surface: surface,
                    separator: separator,
                    children: [
                      // Categoria
                      _DropdownRow<AnnouncementCategory>(
                        label: 'Categoria',
                        value: _category,
                        textPrimary: textPrimary,
                        textTertiary: textTertiary,
                        items: AnnouncementCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: cat.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(cat.label,
                                    style: AppTypography.subheadline
                                        .copyWith(color: textPrimary)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _category = val ?? _category),
                      ),
                      // Prioridade
                      _DropdownRow<AnnouncementPriority>(
                        label: 'Prioridade',
                        value: _priority,
                        textPrimary: textPrimary,
                        textTertiary: textTertiary,
                        items: AnnouncementPriority.values.map((prio) {
                          return DropdownMenuItem(
                            value: prio,
                            child: Text(prio.label,
                                style: AppTypography.subheadline
                                    .copyWith(color: textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _priority = val ?? _priority),
                      ),
                      // Público-Alvo
                      _DropdownRow<AnnouncementTargetType>(
                        label: 'Público-Alvo',
                        value: _targetType,
                        textPrimary: textPrimary,
                        textTertiary: textTertiary,
                        items: [
                          if (user.role.canCreateForClass)
                            DropdownMenuItem(
                              value: AnnouncementTargetType.classTarget,
                              child: Text('Turma Específica',
                                  style: AppTypography.subheadline
                                      .copyWith(color: textPrimary)),
                            ),
                          if (user.role.canCreateForCourse)
                            DropdownMenuItem(
                              value: AnnouncementTargetType.course,
                              child: Text('Todo o Curso',
                                  style: AppTypography.subheadline
                                      .copyWith(color: textPrimary)),
                            ),
                          if (user.role.canCreateForSchool)
                            DropdownMenuItem(
                              value: AnnouncementTargetType.school,
                              child: Text('Toda a Escola',
                                  style: AppTypography.subheadline
                                      .copyWith(color: textPrimary)),
                            ),
                        ],
                        onChanged: (val) =>
                            setState(() => _targetType = val ?? _targetType),
                      ),
                      // Turma (se aplicável)
                      if (_targetType == AnnouncementTargetType.classTarget)
                        _DropdownRow<String>(
                          label: 'Selecione a Turma',
                          value: _selectedClassId,
                          textPrimary: textPrimary,
                          textTertiary: textTertiary,
                          items: availableClasses.map((cl) {
                            return DropdownMenuItem<String>(
                              value: cl['id'],
                              child: Text(cl['name']!,
                                  style: AppTypography.subheadline
                                      .copyWith(color: textPrimary),
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedClassId = val),
                        ),
                    ],
                  ),

                  // ── Seção: Opções Adicionais (Fixar no topo) ──────────────
                  if (user.role.canPinAnnouncements) ...[
                    const SizedBox(height: 24),
                    _SectionHeader(label: 'OPÇÕES DE DESTAQUE', textTertiary: textTertiary),
                    _GroupedSection(
                      surface: surface,
                      separator: separator,
                      children: [
                        SwitchListTile(
                          value: _isPinned,
                          onChanged: (val) => setState(() => _isPinned = val),
                          tileColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(
                            'Fixar aviso no topo do mural',
                            style: AppTypography.subheadline.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          subtitle: Text(
                            'O aviso ficará em destaque para todos os alunos',
                            style: AppTypography.footnote.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── Botão Publicar ───────────────────────────────────────
                  AppButton(
                    text: 'Publicar Aviso',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Componentes de Seção Agrupada iOS ───────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color textTertiary;
  const _SectionHeader({required this.label, required this.textTertiary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        label,
        style: AppTypography.caption2.copyWith(
          color: textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GroupedSection extends StatelessWidget {
  final Color surface;
  final Color separator;
  final List<Widget> children;
  const _GroupedSection({
    required this.surface,
    required this.separator,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Container(
                height: 0.5,
                color: separator,
                margin: const EdgeInsets.only(left: 16),
              ),
          ],
        ],
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Color textPrimary;
  final Color textTertiary;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.textPrimary,
    required this.textTertiary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          labelText: label,
          labelStyle: AppTypography.caption.copyWith(color: textTertiary),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            size: 20, color: textTertiary),
        isExpanded: true,
        items: items,
        onChanged: onChanged,
        style: AppTypography.subheadline.copyWith(color: textPrimary),
        dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      ),
    );
  }
}
