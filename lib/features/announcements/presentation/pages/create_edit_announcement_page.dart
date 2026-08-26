import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
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

    // Ajusta o público padrão de acordo com a permissão
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aviso publicado no mural com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
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

    final availableClasses = MockDataService.classes
        .where((c) => c['courseId'] == _selectedCourseId)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Novo Aviso Acadêmico'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título
                    AppTextField(
                      label: 'Título do Aviso *',
                      hint: 'Ex: Mudança de Sala para a aula de UX',
                      controller: _titleController,
                      validator: (val) => Validators.minLength(val, 5, 'Título muito curto'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Categoria
                    Text(
                      'Categoria de Comunicação',
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<AnnouncementCategory>(
                      value: _category,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined, size: 20),
                      ),
                      items: AnnouncementCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(cat.icon, size: 16, color: cat.color),
                              const SizedBox(width: 8),
                              Text(cat.label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _category = val ?? _category),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Nível de Prioridade
                    Text(
                      'Nível de Prioridade',
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: AnnouncementPriority.values.map((prio) {
                        final isSelected = _priority == prio;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () => setState(() => _priority = prio),
                              borderRadius: AppRadius.borderMd,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? prio.color
                                      : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                                  borderRadius: AppRadius.borderMd,
                                  border: Border.all(
                                    color: isSelected
                                        ? prio.color
                                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      prio.icon,
                                      size: 18,
                                      color: isSelected ? Colors.white : prio.color,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      prio.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : Colors.black87),
                                        fontSize: 12,
                                        fontWeight:
                                            isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Público-Alvo Segmentado (com regras de permissão)
                    Text(
                      'Público-Alvo',
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<AnnouncementTargetType>(
                      value: _targetType,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.people_outline, size: 20),
                      ),
                      items: [
                        if (user.role.canCreateForClass)
                          const DropdownMenuItem(
                            value: AnnouncementTargetType.classTarget,
                            child: Text('Turma / Sala Específica'),
                          ),
                        if (user.role.canCreateForCourse)
                          const DropdownMenuItem(
                            value: AnnouncementTargetType.course,
                            child: Text('Todo o Curso'),
                          ),
                        if (user.role.canCreateForSchool)
                          const DropdownMenuItem(
                            value: AnnouncementTargetType.school,
                            child: Text('Toda a Escola (Geral)'),
                          ),
                      ],
                      onChanged: (val) => setState(() => _targetType = val ?? _targetType),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Se for para Turma específica, seleciona a turma
                    if (_targetType == AnnouncementTargetType.classTarget) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedClassId,
                        decoration: const InputDecoration(
                          labelText: 'Selecione a Turma',
                          prefixIcon: Icon(Icons.meeting_room_outlined, size: 20),
                        ),
                        items: availableClasses.map((cl) {
                          return DropdownMenuItem<String>(
                            value: cl['id'],
                            child: Text(cl['name']!, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedClassId = val),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Conteúdo / Descrição do Aviso
                    AppTextField(
                      label: 'Descrição Completa *',
                      hint: 'Digite aqui todos os detalhes do comunicado institucional...',
                      controller: _descriptionController,
                      maxLines: 5,
                      validator: (val) => Validators.minLength(val, 10, 'Descrição muito curta'),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Opção de Fixar (se autorizado)
                    if (user.role.canPinAnnouncements) ...[
                      SwitchListTile(
                        value: _isPinned,
                        onChanged: (val) => setState(() => _isPinned = val),
                        title: const Text('Fixar aviso no topo do mural'),
                        subtitle: const Text('O aviso ficará em destaque para todos os alunos'),
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Botão Publicar
                    AppButton(
                      text: 'Publicar Aviso no Mural',
                      isLoading: _isLoading,
                      onPressed: _submit,
                      icon: Icons.send_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
