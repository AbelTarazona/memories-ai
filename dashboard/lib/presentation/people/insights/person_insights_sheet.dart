import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/person_insight_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_open_ai_repository.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories_web_admin/presentation/people/bloc/person_insights_bloc.dart';
import 'package:memories_web_admin/presentation/people/bloc/person_insights_event.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PersonInsightsSheet extends StatelessWidget {
  final String personId;
  final String personName;

  const PersonInsightsSheet({
    super.key,
    required this.personId,
    required this.personName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PersonInsightsBloc(
        supabaseRepository: context.read<ISupabaseRepository>(),
        openAiRepository: context.read<IOpenAIRepository>(),
      )..add(FetchPersonInsights(personId: personId, personName: personName)),
      child: Builder(
        builder: (context) {
          return ShadSheet(
            constraints: const BoxConstraints(maxWidth: 600),
            title: const Text('Relationship Insights'),
            description: Text('Análisis de tu relación con $personName'),
            actions: [
              ShadButton.outline(
                leading: const Icon(LucideIcons.refreshCcw, size: 16),
                onPressed: () {
                  context.read<PersonInsightsBloc>().add(
                    FetchPersonInsights(
                      personId: personId,
                      personName: personName,
                      forceReload: true,
                    ),
                  );
                },
                child: const Text('Regenerar'),
              ),
            ],
            child: BlocBuilder<PersonInsightsBloc, BaseState<PersonInsightModel>>(
              builder: (context, state) {
                if (state is LoadingState) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Generando análisis con IA...'),
                        Text(
                          'Esto puede tomar unos segundos.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                } else if (state is ErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.circleAlert,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar insights',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text((state as ErrorState).failure.message),
                        const SizedBox(height: 16),
                        ShadButton(
                          child: const Text('Reintentar'),
                          onPressed: () {
                            context.read<PersonInsightsBloc>().add(
                              FetchPersonInsights(
                                personId: personId,
                                personName: personName,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else if (state is LoadedState<PersonInsightModel>) {
                  final insight = state.data;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Summary
                        if (insight.summary != null)
                          _buildCard(
                            title: 'Resumen',
                            icon: LucideIcons.bookOpen,
                            content: Text(insight.summary!),
                          ),
                        const SizedBox(height: 16),

                        // Dominant Role & Confidence
                        if (insight.dominantRole != null)
                          Builder(
                            builder: (context) {
                              final (roleLabel, roleIcon) = _getRoleInfo(
                                insight.dominantRole!.label,
                              );
                              return _buildCard(
                                title: 'Rol Dominante',
                                icon: LucideIcons.user,
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          roleIcon,
                                          size: 24,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          roleLabel,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (insight.dominantRole!.confidence !=
                                        null)
                                      _buildCircularConfidence(
                                        insight.dominantRole!.confidence!,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 16),

                        // Emotional Impact
                        if (insight.emotionalImpact != null)
                          _buildCard(
                            title: 'Impacto Emocional',
                            icon: LucideIcons.heart,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (insight.emotionalImpact!.dominantEmotions !=
                                    null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: insight
                                          .emotionalImpact!
                                          .dominantEmotions!
                                          .map((e) => ShadBadge(child: Text(e)))
                                          .toList(),
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildBalanceIcon(
                                      insight.emotionalImpact!.overallBalance,
                                    ),
                                    _buildIntensityIcon(
                                      insight.emotionalImpact!.averageIntensity,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Evolution
                        if (insight.relationshipEvolution != null)
                          _buildCard(
                            title: 'Evolución',
                            icon: LucideIcons.trendingUp,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insight.relationshipEvolution!.description ??
                                      '',
                                ),
                                const SizedBox(height: 16),
                                _buildTrendSelector(
                                  insight.relationshipEvolution!.trend,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Risk Flags
                        if (insight.riskFlags != null &&
                            insight.riskFlags!.isNotEmpty)
                          ShadCard(
                            padding: const EdgeInsets.all(16),
                            // backgroundColor: Colors.red.shade50,
                            // borderColor: Colors.red.shade200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.triangleAlert,
                                      color: Colors.red.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Atención',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...insight.riskFlags!.map(
                                  (flag) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '• ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                color: Colors.red.shade900,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '${flag.label}: ',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: flag.description,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (insight.riskFlags != null &&
                            insight.riskFlags!.isNotEmpty)
                          const SizedBox(height: 16),

                        // Themes
                        if (insight.keyThemes != null &&
                            insight.keyThemes!.isNotEmpty)
                          _buildCard(
                            title: 'Temas Clave',
                            icon: LucideIcons.tag,
                            content: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: insight.keyThemes!
                                  .map(
                                    (t) => ShadBadge.secondary(child: Text(t)),
                                  )
                                  .toList(),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Quotes
                        if (insight.representativeQuotes != null &&
                            insight.representativeQuotes!.isNotEmpty)
                          ShadAccordion<String>(
                            children: [
                              ShadAccordionItem(
                                value: 'quotes',
                                title: const Text('Citas Representativas'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: insight.representativeQuotes!
                                      .map(
                                        (q) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            '"$q"',
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 24),

                        // Footer
                        Text(
                          'Análisis generado el ${insight.analyzedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(insight.analyzedAt!) : 'N/A'}\nModelo: ${insight.modelUsed ?? 'Unknown'}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              AppText(text: title, fontWeight: FontWeight.w600, fontSize: 16),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildCircularConfidence(double confidence) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: confidence,
            backgroundColor: Colors.grey.shade200,
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(
              confidence > 0.7 ? Colors.green : Colors.orange,
            ),
          ),
        ),
        Text(
          '${(confidence * 100).toInt()}%',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBalanceIcon(String? balance) {
    IconData icon;
    Color color;

    switch (balance?.toLowerCase()) {
      case 'positive':
        icon = LucideIcons.smile;
        color = Colors.green;
        break;
      case 'negative':
        icon = LucideIcons.frown;
        color = Colors.red;
        break;
      case 'neutral':
        icon = LucideIcons.meh;
        color = Colors.grey;
        break;
      case 'mixed':
        icon = LucideIcons.shuffle;
        color = Colors.orange;
        break;
      default:
        icon = LucideIcons.handHelping;
        color = Colors.grey;
    }

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          balance ?? 'N/A',
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildIntensityIcon(String? intensity) {
    IconData icon;
    Color color;
    String label = intensity ?? 'N/A';

    switch (intensity?.toLowerCase()) {
      case 'high':
        icon = LucideIcons.signal;
        color = Colors.red;
        label = 'Alta';
        break;
      case 'medium':
        icon = LucideIcons.signalMedium;
        color = Colors.orange;
        label = 'Media';
        break;
      case 'low':
        icon = LucideIcons.signalLow;
        color = Colors.green;
        label = 'Baja';
        break;
      default:
        icon = LucideIcons.signalZero;
        color = Colors.grey;
    }

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  (String, IconData) _getRoleInfo(String? role) {
    switch (role?.toLowerCase()) {
      case 'support':
        return ('Apoyo', LucideIcons.handHeart);
      case 'conflict':
        return ('Conflicto', LucideIcons.swords);
      case 'mentor':
        return ('Mentor', LucideIcons.graduationCap);
      case 'family':
        return ('Familia', LucideIcons.users);
      case 'partner':
        return ('Pareja', LucideIcons.heart);
      case 'friend':
        return ('Amigo', LucideIcons.userPlus);
      case 'neutral':
        return ('Neutral', LucideIcons.user);
      case 'mixed':
        return ('Mixto', LucideIcons.shuffle);
      default:
        return (role ?? 'Desconocido', LucideIcons.handHelping);
    }
  }

  Widget _buildTrendSelector(String? currentTrend) {
    final trends = [
      ('improving', 'Mejorando', LucideIcons.trendingUp),
      ('stable', 'Estable', LucideIcons.minus),
      ('deteriorating', 'Deteriorando', LucideIcons.trendingDown),
      ('fluctuating', 'Fluctuante', LucideIcons.activity),
      ('unclear', 'Incierto', LucideIcons.handHelping),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: trends.map((t) {
          final key = t.$1;
          final label = t.$2;
          final icon = t.$3;
          final isSelected = currentTrend?.toLowerCase() == key;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  (String, IconData) _getTrendInfo(String? trend) {
    switch (trend?.toLowerCase()) {
      case 'improving':
        return ('Mejorando', LucideIcons.trendingUp);
      case 'stable':
        return ('Estable', LucideIcons.minus);
      case 'deteriorating':
        return ('Deteriorando', LucideIcons.trendingDown);
      case 'fluctuating':
        return ('Fluctuante', LucideIcons.activity);
      case 'unclear':
        return ('Incierto', LucideIcons.handHelping);
      default:
        return (trend ?? 'N/A', LucideIcons.handHelping);
    }
  }
}
