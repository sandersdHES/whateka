import 'package:flutter/material.dart';
import '../services/activity_service.dart';
import '../models/activity.dart';
import '../models/ai_response.dart';
import '../widgets/fun_loading_widget.dart';

class AiResultScreen extends StatefulWidget {
  final Map<String, dynamic> userPrefs;
  final Map<String, dynamic> contextData;

  const AiResultScreen({
    super.key,
    required this.userPrefs,
    required this.contextData,
  });

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  final ActivityService _activityService = ActivityService();
  late Future<AiResponse> _aiFuture;

  @override
  void initState() {
    super.initState();
    // Launch AI recommendation search on screen load
    _aiFuture = _activityService.getAIRecommendations(
      userPrefs: widget.userPrefs,
      context: widget.contextData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("L'avis de l'Expert"),
        centerTitle: true,
      ),
      body: FutureBuilder<AiResponse>(
        future: _aiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: FunLoadingWidget());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      snapshot.error.toString().contains("surchargé")
                          ? Icons.hourglass_empty
                          : Icons.error_outline,
                      size: 64,
                      color: snapshot.error.toString().contains("surchargé")
                          ? Colors.orange
                          : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString().contains("surchargé")
                          ? "Forte affluence"
                          : "Erreur lors du chargement",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll("Exception: ", ""),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _aiFuture = _activityService.getAIRecommendations(
                            userPrefs: widget.userPrefs,
                            context: widget.contextData,
                          );
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Réessayer"),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Retour"),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.activities.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Aucune activité trouvée",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Essayez de modifier vos critères de recherche",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Recommencer"),
                    ),
                  ],
                ),
              ),
            );
          }

          final response = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Global AI comment section
                if (response.globalComment.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade50,
                          Colors.cyan.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              "Conseil personnalisé",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          response.globalComment,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Section title
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      "Top ${response.activities.length} Activités",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Activities list
                ...response.activities
                    .map((activity) => _buildActivityCard(activity)),

                // Extra padding at bottom for comfortable scrolling
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/activity_detail',
            arguments: activity,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: activity.imageUrl != null
                  ? Image.network(
                      activity.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[300]!, Colors.grey[200]!],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.landscape,
                            size: 60, color: Colors.white),
                      ),
                    ),
            ),

            // Activity details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and location
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.location,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Duration and price level
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        activity.duration,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      ...List.generate(
                        activity.priceLevel,
                        (index) => const Icon(
                          Icons.euro,
                          size: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // AI reasoning highlight
                  if (activity.aiReason != null &&
                      activity.aiReason!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              activity.aiReason!,
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
