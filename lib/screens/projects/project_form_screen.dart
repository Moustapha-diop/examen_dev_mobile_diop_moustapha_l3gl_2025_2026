import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

class ProjectFormScreen extends StatefulWidget {
  final String userId;
  final Project? project; // null = création, non-null = modification

  const ProjectFormScreen({
    super.key,
    required this.userId,
    this.project,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectProvider = ProjectProvider();

  bool _isLoading = false;

  // 8 couleurs prédéfinies
  static const List<Color> _colors = [
    Color(0xFF0293ED),
    Color(0xFF61E561),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFFF6B35),
  ];

  late int _selectedColor;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      ///preremplire
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color;
    } else {
      _selectedColor = _colors.first.value;
    }
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final project = _isEditing
        ? widget.project!.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      color: _selectedColor,
      updatedAt: DateTime.now(),
    )
        : Project(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      userId: widget.userId,
      color: _selectedColor,
    );

    if (_isEditing) {
      await _projectProvider.updateProject(project);
    } else {
      await _projectProvider.createProject(project);
    }

    setState(() => _isLoading = false);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    // Aperçu en temps réel
    final previewProject = Project(
      id: 'preview',
      name: _nameController.text.isEmpty
          ? 'Nom du projet'
          : _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      userId: widget.userId,
      color: _selectedColor,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le projet' : 'Nouveau projet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aperçu
              const Text('Aperçu',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              ProjectCard(project: previewProject),
              const SizedBox(height: 24),

              // Champs
              CustomTextField(
                label: 'Nom du projet',
                controller: _nameController,
                hint: 'Mon super projet',
                prefixIcon: Icons.folder_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Le nom est requis';
                  if (v.trim().length < 3) {
                    return 'Minimum 3 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description (optionnel)',
                controller: _descriptionController,
                hint: 'Décrivez votre projet...',
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 24),

              // Sélecteur de couleur
              const Text('Couleur du projet',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color.value;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColor = color.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.textPrimary
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                              color: color.withAlpha(150),
                              blurRadius: 8)
                        ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                          color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: _isEditing ? 'Enregistrer' : 'Créer le projet',
                isLoading: _isLoading,
                onPressed: _submit,
                icon: _isEditing ? Icons.save : Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
