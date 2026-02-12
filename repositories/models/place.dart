class Place {
  final String id;
  final String name;
  final double latitude;
  final double length;

  const Place({required this.id, required this.name, required this.latitude, required this.length});

  const Place.initial()
      : id = '',
        name = '',
        latitude = 0.0,
        length = 0.0;
}
