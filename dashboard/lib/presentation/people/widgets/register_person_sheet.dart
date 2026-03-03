import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/bloc/fetch_event.dart';
import 'package:memories_web_admin/data/models/appearance_options.dart';
import 'package:memories_web_admin/data/models/people_model.dart';
import 'package:memories_web_admin/data/models/person_traits_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories_web_admin/presentation/people/bloc/upsert_person_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RegisterPersonSheet extends StatelessWidget {
  final PeopleModel? person;

  const RegisterPersonSheet({super.key, this.person});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpsertPersonBloc(
        repository: context.read<ISupabaseRepository>(),
      ),
      child: RegisterPersonContent(person: person),
    );
  }
}

class RegisterPersonContent extends StatefulWidget {
  final PeopleModel? person;

  const RegisterPersonContent({super.key, this.person});

  @override
  State<RegisterPersonContent> createState() => _RegisterPersonContentState();
}

class _RegisterPersonContentState extends State<RegisterPersonContent> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descriptionController = TextEditingController();

  late final bool _isEditing;

  String? _gender;
  String? _skinTone;
  String? _skinUndertone;
  String? _eyeColor;
  String? _hairColor;
  String? _hairLength;
  String? _hairTexture;
  String? _facialHair;
  String? _glasses;
  String? _freckles;
  String? _tattoos;
  String? _bodyType;

  List<String> _fashionStyles = <String>[];
  List<String> _distinctiveMarks = <String>[];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.person != null;

    final person = widget.person;
    if (person != null) {
      _fullNameController.text = person.displayName;
      _aliasController.text = person.alias ?? '';
      _descriptionController.text = person.traits.notes ?? '';
      _gender = ['male', 'female', 'nonbinary'].contains(person.gender)
          ? person.gender
          : null;

      _skinTone = person.traits.skinTone;
      _skinUndertone = person.traits.skinUndertone;
      _eyeColor = person.traits.eyeColor;
      _hairColor = person.traits.hairColor;
      _hairLength = person.traits.hairLength;
      _hairTexture = person.traits.hairTexture;
      _facialHair = person.traits.facialHair;
      _glasses = person.traits.glasses;
      _freckles = person.traits.freckles;
      _tattoos = person.traits.tattoos;
      _bodyType = person.traits.bodyType;

      _fashionStyles = List<String>.from(
        person.traits.fashionStyle ?? <String>[],
      );
      _distinctiveMarks = List<String>.from(
        person.traits.distinctiveMarks ?? <String>[],
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _aliasController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final fullName = _fullNameController.text.trim();
    final aliasText = _aliasController.text.trim();
    final description = _descriptionController.text.trim();

    final traits = PersonTraitsModel(
      skinTone: _skinTone,
      skinUndertone: _skinUndertone,
      eyeColor: _eyeColor,
      hairColor: _hairColor,
      hairLength: _hairLength,
      hairTexture: _hairTexture,
      facialHair: _facialHair,
      glasses: _glasses,
      freckles: _freckles,
      tattoos: _tattoos,
      bodyType: _bodyType,
      fashionStyle: List<String>.from(_fashionStyles),
      distinctiveMarks: List<String>.from(_distinctiveMarks),
      notes: description,
    );

    final alias = aliasText.isEmpty ? null : aliasText;
    final ageRange = widget.person?.ageRange;
    final height = widget.person?.heightCm?.toString();

    FocusScope.of(context).unfocus();
    context.read<UpsertPersonBloc>().add(
      FetchEvent(
        UpsertPersonParameters(
          id: widget.person?.id,
          displayName: fullName,
          traits: traits,
          alias: alias,
          gender: _gender,
          ageRange: ageRange,
          height: height,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Editar persona' : 'Registrar persona';
    final submitLabel = _isEditing ? 'Guardar cambios' : 'Registrar persona';

    return BlocListener<UpsertPersonBloc, BaseState<void>>(
      listener: (context, state) {
        if (state is LoadedState<void>) {
          context.pop(true);
        } else if (state is ErrorState<void>) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Error'),
              description: Text(state.failure.message),
            ),
          );
        }
      },
      child: ShadSheet(
        constraints: const BoxConstraints(maxWidth: 540),
        title: Text(title),
        description: const Text(
          'Completa los datos físicos de la persona usando las opciones sugeridas.',
        ),
        actions: [
          BlocBuilder<UpsertPersonBloc, BaseState<void>>(
            builder: (context, state) {
              final isLoading = state is LoadingState<void>;
              return ShadButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(submitLabel),
              );
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildTextField(
                        controller: _fullNameController,
                        label: 'Nombre completo',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el nombre de la persona';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _aliasController,
                        label: 'Alias (opcional)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Género',
                  value: _gender,
                  options: const ['male', 'female', 'nonbinary'],
                  onChanged: (value) => setState(() => _gender = value),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Descripción (opcional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Color de piel',
                        value: _skinTone,
                        options: AppearanceOptions.skinTone,
                        onChanged: (value) => setState(() => _skinTone = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Subtono de piel',
                        value: _skinUndertone,
                        options: AppearanceOptions.skinUndertone,
                        onChanged: (value) =>
                            setState(() => _skinUndertone = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Color de ojos',
                        value: _eyeColor,
                        options: AppearanceOptions.eyeColor,
                        onChanged: (value) => setState(() => _eyeColor = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Color de cabello',
                        value: _hairColor,
                        options: AppearanceOptions.hairColor,
                        onChanged: (value) =>
                            setState(() => _hairColor = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Largo de cabello',
                        value: _hairLength,
                        options: AppearanceOptions.hairLength,
                        onChanged: (value) =>
                            setState(() => _hairLength = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Textura de cabello',
                        value: _hairTexture,
                        options: AppearanceOptions.hairTexture,
                        onChanged: (value) =>
                            setState(() => _hairTexture = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Vello facial',
                        value: _facialHair,
                        options: AppearanceOptions.facialHair,
                        onChanged: (value) =>
                            setState(() => _facialHair = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Uso de lentes',
                        value: _glasses,
                        options: AppearanceOptions.glasses,
                        onChanged: (value) => setState(() => _glasses = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Pecas',
                        value: _freckles,
                        options: AppearanceOptions.freckles,
                        onChanged: (value) => setState(() => _freckles = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Tatuajes',
                        value: _tattoos,
                        options: AppearanceOptions.tattoos,
                        onChanged: (value) => setState(() => _tattoos = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Tipo de cuerpo',
                  value: _bodyType,
                  options: AppearanceOptions.bodyType,
                  onChanged: (value) => setState(() => _bodyType = value),
                ),
                const SizedBox(height: 24),
                _buildMultiSelectChips(
                  label: 'Estilo de moda (puedes seleccionar varios)',
                  options: AppearanceOptions.fashionStyle,
                  values: _fashionStyles,
                  onChanged: (values) =>
                      setState(() => _fashionStyles = values),
                ),
                const SizedBox(height: 16),
                _buildMultiSelectChips(
                  label: 'Rasgos distintivos (puedes seleccionar varios)',
                  options: AppearanceOptions.distinctiveMarks,
                  values: _distinctiveMarks,
                  onChanged: (values) =>
                      setState(() => _distinctiveMarks = values),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? value,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona una opción';
        }
        return null;
      },
    );
  }

  Widget _buildMultiSelectChips({
    required String label,
    required List<String> options,
    required List<String> values,
    required ValueChanged<List<String>> onChanged,
  }) {
    return FormField<List<String>>(
      initialValue: values,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final selected = values.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: (isSelected) {
                    final updated = List<String>.from(values);
                    if (isSelected) {
                      updated.add(option);
                    } else {
                      updated.remove(option);
                    }
                    onChanged(updated);
                    state.didChange(updated);
                  },
                );
              }).toList(),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  state.errorText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
