import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/bloc/fetch_event.dart';
import 'package:memories_web_admin/core/widgets/app_header.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/people_model.dart';
import 'package:memories_web_admin/presentation/people/bloc/people_list_bloc.dart';
import 'package:memories_web_admin/presentation/people/widgets/register_person_sheet.dart';
import 'package:memories_web_admin/presentation/people/insights/person_insights_sheet.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories_web_admin/presentation/people/bloc/delete_person_bloc.dart';
import 'package:memories_web_admin/presentation/people/widgets/person_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  String? _selectedGender;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 34,
      ),
      child: BlocProvider(
        create: (context) => DeletePersonBloc(
          repository: context.read<ISupabaseRepository>(),
        ),
        child: BlocListener<DeletePersonBloc, BaseState<void>>(
          listener: (context, state) {
            if (state is LoadedState<void>) {
              ShadToaster.of(context).show(
                const ShadToast(
                  title: Text('Persona eliminada'),
                  description: Text(
                    'La persona ha sido eliminada correctamente.',
                  ),
                ),
              );
              _loadPeople();
            } else if (state is ErrorState<void>) {
              ShadToaster.of(context).show(
                ShadToast.destructive(
                  title: const Text('Error'),
                  description: Text(state.failure.message),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppHeader(title: 'Personas'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShadButton.ghost(
                    leading: const Icon(LucideIcons.userPlus),
                    child: const Text('Agregar Persona'),
                    onPressed: () async {
                      showShadSheet<bool>(
                        context: context,
                        side: ShadSheetSide.right,
                        builder: (sheetContext) {
                          return const RegisterPersonSheet();
                        },
                      ).then((value) {
                        if (value == true) {
                          _loadPeople();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 300,
                    child: ShadInput(
                      placeholder: const Text('Buscar personas...'),
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        hint: const Text('Filtrar por género'),
                        isExpanded: true,
                        icon: const Icon(LucideIcons.chevronDown, size: 16),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Masculino'),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Femenino'),
                          ),
                          DropdownMenuItem(
                            value: 'nonbinary',
                            child: Text('No binario'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                          _loadPeople();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<PeopleListBloc, BaseState<List<PeopleModel>>>(
                builder: (context, state) {
                  if (state is LoadingState<List<PeopleModel>>) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is ErrorState<List<PeopleModel>>) {
                    return Expanded(
                      child: Center(
                        child: Text(state.failure.message),
                      ),
                    );
                  } else if (state is LoadedState<List<PeopleModel>>) {
                    var people = List<PeopleModel>.from(state.data);

                    if (_searchController.text.isNotEmpty) {
                      final query = _searchController.text.toLowerCase();
                      people = people.where((person) {
                        final nameMatch = person.displayName
                            .toLowerCase()
                            .contains(query);
                        final aliasMatch =
                            person.alias?.toLowerCase().contains(query) ??
                            false;
                        return nameMatch || aliasMatch;
                      }).toList();
                    }

                    people.sort((a, b) {
                      if (a.isSelf) return -1;
                      if (b.isSelf) return 1;
                      return 0;
                    });

                    if (people.isEmpty) {
                      return const Expanded(
                        child: Center(
                          child: Text('No hay personas disponibles.'),
                        ),
                      );
                    }
                    return Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 300,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                            ),
                        itemCount: people.length,
                        itemBuilder: (BuildContext context, int index) {
                          final person = people[index];
                          return PersonCard(
                            person: person,
                            onReload: _loadPeople,
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadPeople() {
    context.read<PeopleListBloc>().add(FetchEvent(_selectedGender));
  }
}
