import 'package:equatable/equatable.dart';

enum SubscriptionType {
  free,
  pro;

  String get displayName {
    switch (this) {
      case SubscriptionType.free:
        return 'Free';
      case SubscriptionType.pro:
        return 'Pro';
    }
  }

  String get value {
    return name;
  }

  static SubscriptionType fromString(String value) {
    return SubscriptionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SubscriptionType.free,
    );
  }

  int get courseLimit {
    switch (this) {
      case SubscriptionType.free:
        return 2;
      case SubscriptionType.pro:
        return -1; // Unlimited
    }
  }

  bool get isUnlimited => courseLimit == -1;

  List<String> get features {
    switch (this) {
      case SubscriptionType.free:
        return [
          'Up to 2 courses',
          'Basic attendance tracking',
          'Local data storage',
          'Basic notifications',
        ];
      case SubscriptionType.pro:
        return [
          'Unlimited courses',
          'Advanced attendance analytics',
          'Cloud backup & sync',
          'Smart notifications',
          'Export to PDF',
          'Custom themes',
          'Priority support',
        ];
    }
  }
}

class Subscription extends Equatable {
  final String id;
  final String userId;
  final SubscriptionType type;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
  ];

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionType? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isFree => type == SubscriptionType.free;
  bool get isPro => type == SubscriptionType.pro;
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  bool get isValid => isActive && !isExpired;

  int get remainingDays {
    if (endDate == null) return -1; // Unlimited for free subscriptions
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }

  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedEndDate {
    if (endDate == null) return 'Never';
    return '${endDate!.day}/${endDate!.month}/${endDate!.year}';
  }

  String get statusText {
    if (!isActive) return 'Inactive';
    if (isExpired) return 'Expired';
    if (type == SubscriptionType.free) return 'Active (Free)';
    if (remainingDays > 0) return 'Active ($remainingDays days left)';
    return 'Active';
  }

  bool canAddCourse(int currentCourseCount) {
    if (!isValid) return false;
    if (type.isUnlimited) return true;
    return currentCourseCount < type.courseLimit;
  }

  int coursesRemaining(int currentCourseCount) {
    if (!isValid) return 0;
    if (type.isUnlimited) return -1;
    final remaining = type.courseLimit - currentCourseCount;
    return remaining > 0 ? remaining : 0;
  }
}

class SubscriptionPlan extends Equatable {
  final SubscriptionType type;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String duration; // 'monthly', 'yearly'
  final List<String> features;

  const SubscriptionPlan({
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.duration,
    required this.features,
  });

  @override
  List<Object?> get props => [
    type,
    name,
    description,
    price,
    currency,
    duration,
    features,
  ];

  String get formattedPrice {
    if (price == 0) return 'Free';
    return '$currency${price.toStringAsFixed(2)}/$duration';
  }

  bool get isFree => price == 0;

  static List<SubscriptionPlan> get availablePlans => [
    const SubscriptionPlan(
      type: SubscriptionType.free,
      name: 'Free Plan',
      description: 'Perfect for trying out AttendKal',
      price: 0,
      currency: '\$',
      duration: 'forever',
      features: [
        'Up to 2 courses',
        'Basic attendance tracking',
        'Local data storage',
        'Basic notifications',
      ],
    ),
    const SubscriptionPlan(
      type: SubscriptionType.pro,
      name: 'Pro Plan',
      description: 'Complete attendance management solution',
      price: 29.99,
      currency: '\$',
      duration: 'year',
      features: [
        'Unlimited courses',
        'Advanced attendance analytics',
        'Cloud backup & sync',
        'Smart notifications',
        'Export to PDF',
        'Custom themes',
        'Priority support',
      ],
    ),
  ];
}
