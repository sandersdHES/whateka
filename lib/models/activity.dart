class Activity {
  final String title;
  final String location;
  final String duration;
  final String description;
  final String imageUrl;
  final String category;
  final List<String> features;

  const Activity({
    required this.title,
    required this.location,
    required this.duration,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.features,
  });
}

const List<Activity> mockActivities = [
  Activity(
    title: 'Visite du Château de Tourbillon',
    location: 'Sion',
    duration: '2h',
    description:
        'Découvrez ce château médiéval perché sur une colline dominant Sion. Une expérience historique unique avec une vue panoramique exceptionnelle.',
    imageUrl:
        'https://images.unsplash.com/photo-1528909514045-2fa4ac7a08ba?q=80&w=1200&auto=format&fit=crop',
    category: 'Culture',
    features: ['Adapté aux familles', 'Accès gratuit'],
  ),
  Activity(
    title: 'Randonnée du Bisse du Ro',
    location: 'Crans-Montana',
    duration: '3h30',
    description:
        'Une randonnée spectaculaire le long d\'un bisse historique taillé dans la roche. Des paysages à couper le souffle pour les amoureux de la nature.',
    imageUrl:
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1200&auto=format&fit=crop',
    category: 'Sport & Nature',
    features: ['Niveau moyen', 'Vue panoramique'],
  ),
  Activity(
    title: 'Dégustation de Vins',
    location: 'Salquencen',
    duration: '1h30',
    description:
        'Plongez au cœur du vignoble valaisan. Dégustation de 5 vins locaux accompagnés de produits du terroir dans une cave traditionnelle.',
    imageUrl:
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?q=80&w=1200&auto=format&fit=crop',
    category: 'Gastronomie',
    features: ['Sur réservation', 'Dès 18 ans'],
  ),
];
