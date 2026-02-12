import 'package:flavor/flavor.dart';
import 'package:flutter/material.dart';
import 'config/config.dart';

void setupFlavor(Config config) {
  final String flavor = config.flavor;
  if (flavor.isEmpty) {
    throw ArgumentError('Flavor cannot be empty');
  }

  switch (flavor) {
    case 'development':
      Flavor.create(Environment.dev, name: flavor, color: Colors.black);
      break;
    case 'staging':
      Flavor.create(Environment.beta, name: flavor, color: Colors.black);
      break;
    case 'production':
      Flavor.create(Environment.production, name: flavor);
      break;
    default:
      throw ArgumentError('Unsupported flavor: $flavor');
  }
}
