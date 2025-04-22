import 'dart:math';

class ChargingStationDetails {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? website;
  final double? rating;
  final bool? openNow;
  final List<Review>? reviews;

  // Extra dummy fields (including status)
  final int numberOfConnectors;
  final List<String> connectorTypes;
  final String status; // Newly added field
  final double pricePer15Min;
  final String timing;
  final bool isPublic;
  final String capacity;

  ChargingStationDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.website,
    this.rating,
    this.openNow,
    this.reviews,
    // Dummy fields
    required this.numberOfConnectors,
    required this.connectorTypes,
    required this.status,
    required this.pricePer15Min,
    required this.timing,
    required this.isPublic,
    required this.capacity,
  });

  factory ChargingStationDetails.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    // Generate dummy data for extra fields.
    DummyData dummy = DummyDataGenerator.generateDummyData();

    return ChargingStationDetails(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      address: json['vicinity'] as String,
      latitude: location['lat'] as double,
      longitude: location['lng'] as double,
      phoneNumber: json['formatted_phone_number'],
      website: json['website'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      openNow: json['opening_hours'] != null &&
              json['opening_hours']['open_now'] != null
          ? json['opening_hours']['open_now'] as bool
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((reviewJson) => Review.fromJson(reviewJson))
              .toList()
          : null,
      // Attach dummy values
      numberOfConnectors: dummy.numberOfConnectors,
      connectorTypes: dummy.connectorTypes,
      status: dummy.status,
      pricePer15Min: dummy.pricePer15Min,
      timing: dummy.timing,
      isPublic: dummy.isPublic,
      capacity: dummy.capacity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'numberOfConnectors': numberOfConnectors,
      'connectorTypes': connectorTypes,
      'status': status,
      'pricePer15Min': pricePer15Min,
      'timing': timing,
      'isPublic': isPublic,
      'capacity': capacity,
    };
  }
}

class Review {
  final String authorName;
  final double rating;
  final String text;

  Review({
    required this.authorName,
    required this.rating,
    required this.text,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['author_name'] ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      text: json['text'] ?? '',
    );
  }
}

// Helper class to hold dummy values.
class DummyData {
  final int numberOfConnectors;
  final List<String> connectorTypes;
  final String status;
  final double pricePer15Min;
  final String timing;
  final bool isPublic;
  final String capacity;

  DummyData({
    required this.numberOfConnectors,
    required this.connectorTypes,
    required this.status,
    required this.pricePer15Min,
    required this.timing,
    required this.isPublic,
    required this.capacity,
  });
}

// Dummy data generator for extra fields.
class DummyDataGenerator {
  static DummyData generateDummyData() {
    final random = Random();

    int numberOfConnectors = random.nextInt(5) + 1; // 1 to 5 connectors

    List<String> availableConnectorTypes = [
      'Type1',
      'Type2',
      'CCS',
      'CHAdeMO',
      'Tesla',
      'GB/T',
      'Other'
    ];
    availableConnectorTypes.shuffle(random);
    int count = random.nextInt(3) + 1; // Pick between 1 and 3 types.
    List<String> connectorTypes = availableConnectorTypes.take(count).toList();

    // Generate random status.
    String status = random.nextBool() ? "Open" : "Closed";

    // Price per 15 minutes.
    double pricePer15Min = (random.nextInt(11) + 5).toDouble(); // between 5 and 15

    // Timing
    String timing = random.nextBool() ? "24 Hours" : "9:00 AM - 10:00 PM";

    // Public or Private.
    bool isPublic = random.nextBool();

    List<String> capacities = ["25 kW", "50 kW", "75 kW", "100 kW"];
    String capacity = capacities[random.nextInt(capacities.length)];

    return DummyData(
      numberOfConnectors: numberOfConnectors,
      connectorTypes: connectorTypes,
      status: status,
      pricePer15Min: pricePer15Min,
      timing: timing,
      isPublic: isPublic,
      capacity: capacity,
    );
  }
}
