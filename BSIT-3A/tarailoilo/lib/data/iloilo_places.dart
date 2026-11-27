import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum PlaceCategory { restaurant, museum, church, mall, other }

extension PlaceCategoryX on PlaceCategory {
  String get label => switch (this) {
    PlaceCategory.restaurant => 'Restaurants',
    PlaceCategory.museum => 'Museums',
    PlaceCategory.church => 'Churches',
    PlaceCategory.mall => 'Malls',
    PlaceCategory.other => 'Others',
  };

  Color get color => switch (this) {
    PlaceCategory.restaurant => const Color(0xFF9A4A12),
    PlaceCategory.museum => const Color(0xFFFFD500),
    PlaceCategory.church => const Color(0xFFE53935),
    PlaceCategory.mall => const Color(0xFF6EE02E),
    PlaceCategory.other => const Color(0xFF9E9E9E),
  };
}

class Place {
  Place(
    this.name,
    this.category,
    double lat,
    double lng, {
    this.verified = true,
  }) : position = LatLng(lat, lng);

  final String name;
  final PlaceCategory category;
  final LatLng position;

  /// false = approximate coordinates that still need checking.
  final bool verified;

  String get id => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

/// All coordinates are (lat, lng). Your sheet used "Long, Lat", so those
/// values were swapped here.
final List<Place> kIloiloPlaces = [
  // ── Others ──────────────────────────────────────────────
  Place('Fort San Pedro', PlaceCategory.other, 10.687991, 122.580040),
  Place(
    'Calle Real (J.M. Basa Street)',
    PlaceCategory.other,
    10.693710,
    122.571380,
  ),
  Place(
    'Molo Mansion (Yusay-Consing Mansion)',
    PlaceCategory.other,
    10.696514,
    122.543431,
  ),
  Place(
    'Avanceña-Camiña Balay nga Bato',
    PlaceCategory.other,
    10.689702,
    122.514855,
  ),
  Place("Nelly's Garden", PlaceCategory.other, 10.718694, 122.562187),
  Place('Casa Mariquit', PlaceCategory.other, 10.726910, 122.556620),
  Place('Iloilo River Esplanade', PlaceCategory.other, 10.702997, 122.555009),
  Place(
    'Plaza Libertad & Sunburst Park',
    PlaceCategory.other,
    10.6957,
    122.5667,
    verified: false,
  ),
  Place('Plazuela', PlaceCategory.other, 10.7128, 122.5484, verified: false),
  // TODO: "Iloilo City Garden of Love" – couldn't find a reliable location.

  // ── Malls ───────────────────────────────────────────────
  Place(
    'Festive Walk Iloilo & K-Town',
    PlaceCategory.mall,
    10.717732,
    122.546857,
  ),
  Place('SM City Iloilo', PlaceCategory.mall, 10.71444, 122.55111), // Wikipedia
  Place(
    'Robinsons Place Iloilo',
    PlaceCategory.mall,
    10.6972,
    122.5666,
    verified: false,
  ),

  // ── Museums ─────────────────────────────────────────────
  Place('Museo Iloilo', PlaceCategory.museum, 10.702796, 122.568416),
  Place(
    'National Museum of the Philippines - Iloilo',
    PlaceCategory.museum,
    10.703222,
    122.568767,
  ),
  Place(
    "FADS of 50's Diner and Museum",
    PlaceCategory.museum,
    10.7160,
    122.5470,
    verified: false,
  ),
  Place(
    'Iloilo Museum of Contemporary Art (ILOMOCA)',
    PlaceCategory.museum,
    10.7010,
    122.5660,
    verified: false,
  ),
  Place(
    'Museum of Philippine Maritime History',
    PlaceCategory.museum,
    10.6992,
    122.5395,
    verified: false,
  ),
  Place(
    'Museum of Philippine Economic History',
    PlaceCategory.museum,
    10.6938,
    122.5712,
    verified: false,
  ),
  Place(
    'UPV Museum of Art and Cultural Heritage',
    PlaceCategory.museum,
    10.6968,
    122.5688,
    verified: false,
  ),

  // ── Churches ────────────────────────────────────────────
  Place(
    'San Jose Placer Parish Church',
    PlaceCategory.church,
    10.693160,
    122.574350,
  ),
  Place(
    'Molo Church (St. Anne Parish Church)',
    PlaceCategory.church,
    10.697410,
    122.544847,
  ),
  Place('Jaro Cathedral Church', PlaceCategory.church, 10.723657, 122.556276),
  Place('Arevalo Parish Church', PlaceCategory.church, 10.688020, 122.515700),
  Place(
    'La Paz Parish Church',
    PlaceCategory.church,
    10.7140,
    122.5700,
    verified: false,
  ),

  // ── Restaurants (all approximate – verify) ──────────────
  Place(
    'Breakthrough Restaurant',
    PlaceCategory.restaurant,
    10.6785,
    122.5265,
    verified: false,
  ),
  Place(
    "Tatoy's Manokan and Seafood Restaurant",
    PlaceCategory.restaurant,
    10.6808,
    122.5273,
    verified: false,
  ),
  Place(
    'Ramboys Liempo',
    PlaceCategory.restaurant,
    10.7140,
    122.5470,
    verified: false,
  ),
  Place(
    'La Paz Batchoy',
    PlaceCategory.restaurant,
    10.7148,
    122.5700,
    verified: false,
  ),
  Place(
    "Ted's Oldtimer La Paz Batchoy",
    PlaceCategory.restaurant,
    10.7155,
    122.5688,
    verified: false,
  ),
  Place(
    "Deco's La Paz Batchoy",
    PlaceCategory.restaurant,
    10.7150,
    122.5695,
    verified: false,
  ),
  Place(
    "Netong's Original Special La Paz Batchoy",
    PlaceCategory.restaurant,
    10.7152,
    122.5705,
    verified: false,
  ),
  Place(
    'Madge Café',
    PlaceCategory.restaurant,
    10.6990,
    122.5655,
    verified: false,
  ),
  Place(
    "Roberto's",
    PlaceCategory.restaurant,
    10.6960,
    122.5650,
    verified: false,
  ),
  Place(
    'Dainty House Restaurant',
    PlaceCategory.restaurant,
    10.6935,
    122.5680,
    verified: false,
  ),
  Place(
    'Mang Inasal',
    PlaceCategory.restaurant,
    10.6990,
    122.5670,
    verified: false,
  ),
  Place(
    'The Summer House',
    PlaceCategory.restaurant,
    10.7130,
    122.5500,
    verified: false,
  ),
  Place(
    "Kap Ising's Pancit Molo",
    PlaceCategory.restaurant,
    10.6975,
    122.5445,
    verified: false,
  ),
  Place(
    'Tita Paz House of Pancit Molo',
    PlaceCategory.restaurant,
    10.6978,
    122.5438,
    verified: false,
  ),
  Place(
    'Panaderia de Molo',
    PlaceCategory.restaurant,
    10.6980,
    122.5447,
    verified: false,
  ),
];
