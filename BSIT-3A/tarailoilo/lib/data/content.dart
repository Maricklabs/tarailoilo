// ALL dashboard content lives here. Replace the contents of these lists with
// CMS data later (same fields as the React content.js).
//
// Images live in assets/contentImg/<path>; a missing image shows the pink placeholder.

enum ContentType { landmark, food, event }

String contentSrc(String path) => 'assets/contentImg/$path';

class GalleryPhoto {
  const GalleryPhoto({required this.image, required this.caption});
  final String image;
  final String caption;
}

class ContentItem {
  const ContentItem({
    required this.id,
    required this.type,
    required this.image,
    required this.name,
    required this.short,
    this.slug,
    this.gallery = const [],
    this.distance,
    this.relatedIds,
    this.title,
    this.category,
    this.tags = const [],
    this.history = const [],
    this.date,
    this.location,
  });

  final String id;
  final ContentType type;
  final String? slug;
  final String image;
  final List<GalleryPhoto> gallery;
  final String? distance;
  final List<String>? relatedIds;
  final String name;
  final String short;
  final String? title;
  final String? category;
  final List<String> tags;
  final List<String> history;
  final String? date;
  final String? location;
}

const List<ContentItem> kLandmarks = [
  ContentItem(
    id: 'landmark-museo-iloilo',
    type: ContentType.landmark,
    slug: 'museo-iloilo',
    image: 'landmarks/museo.jpeg',
    gallery: [GalleryPhoto(image: 'landmarks/museo.jpeg', caption: 'Museo Iloilo exterior')],
    name: 'Museo Iloilo',
    short: 'Art, culture, and local history.',
    title: 'Where history meets the story.',
    category: 'Museums',
    tags: ['Museum', 'History', 'Culture'],
    history: [
      'Museo Iloilo is a provincial museum dedicated to preserving and presenting the history, culture, and heritage of Iloilo. Inaugurated in 1971 near the Iloilo Provincial Capitol, it is recognized as one of the earliest government-sponsored museums outside Metro Manila.',
      'Designed by architect Sergio Penasales, the museum houses collections that reflect different periods of Iloilo’s history. Visitors can explore archaeological objects, cultural artifacts, traditional crafts, and historical pieces that provide a glimpse into the lives and traditions of the Ilonggo people.',
      'The museum serves as an important place for learning about the province’s cultural identity and historical development.',
    ],
  ),
  ContentItem(
    id: 'landmark-calle-real',
    type: ContentType.landmark,
    slug: 'calle-real',
    image: 'landmarks/calleReal.jpeg',
    gallery: [GalleryPhoto(image: 'landmarks/calleReal.jpeg', caption: 'Calle Real street view')],
    name: 'Calle Real (J.M. Basa Street)',
    short: 'A historic street filled with architectural heritage.',
    title: 'Walk through the streets of old Iloilo.',
    category: 'Heritage Streets and Heritage Buildings',
    tags: ['Heritage Street', 'Architecture'],
    history: [
      'Calle Real, also known as J.M. Basa Street, is one of Iloilo City’s most recognized historical commercial streets. It reflects the city’s growth as an important center of trade and commerce during the late Spanish and American periods.',
      'The street is lined with heritage buildings that showcase different architectural styles, including Art Deco and other early twentieth-century designs. These buildings once served as commercial establishments, offices, and business spaces for merchants and prominent families.',
      'Today, Calle Real remains an important reminder of Iloilo’s prosperous commercial past and its architectural heritage. It is a place where visitors can appreciate the city’s history through its surviving buildings and streetscape.',
    ],
  ),
  ContentItem(
    id: 'landmark-molo-mansion',
    type: ContentType.landmark,
    slug: 'molo-mansion',
    image: 'landmarks/moloMansion.jpeg',
    gallery: [GalleryPhoto(image: 'landmarks/moloMansion.jpeg', caption: 'Molo Mansion exterior')],
    name: 'Molo Mansion (Yusay-Consing Mansion)',
    short: 'A historic mansion showcasing Ilonggo heritage and craftsmanship.',
    title: 'A glimpse into the elegant past of Molo.',
    category: 'Heritage Houses and Mansions',
    tags: ['Heritage House', 'Architecture'],
    history: [
      'Molo Mansion, also known as the Yusay-Consing Mansion, is a prominent heritage house located in the historic district of Molo, Iloilo City.',
      'Built in 1926, the mansion was originally associated with the family of Don Estanislao Yusay and Doña Petra Lacson-Yusay. It later passed to their daughter Rosario and her husband Timoteo Consing Sr., who served as governor of Iloilo.',
      'The mansion reflects the lifestyle and architectural elegance of prominent Ilonggo families during an important period in the city’s history.',
      'Today, the restored property serves as a space for showcasing Filipino crafts, traditional clothing, local products, and Ilonggo culture.',
    ],
  ),
  ContentItem(
    id: 'landmark-balay-nga-bato',
    type: ContentType.landmark,
    slug: 'balay-nga-bato',
    image: 'landmarks/balayBato.jpeg',
    gallery: [GalleryPhoto(image: 'landmarks/balayBato.jpeg', caption: 'Balay nga Bato exterior')],
    name: 'Avanceña-Camiña Balay nga Bato',
    short: 'An ancestral stone house preserving generations of Ilonggo heritage.',
    title: 'A home filled with generations of history.',
    category: 'Ancestral Houses and Heritage Houses',
    tags: ['Ancestral House', 'Architecture'],
    history: [
      'Avanceña-Camiña Balay nga Bato is a historic ancestral house located in Arevalo, Iloilo City. The house traces its origins to the Avanceña family and was constructed around 1865.',
      'The heritage house is known for its distinctive combination of Filipino, European, and Asian architectural influences. Its design incorporates traditional materials and craftsmanship that reflect the lifestyle of prominent families during the nineteenth century.',
      'The property has been preserved through generations of family ownership and continues to provide visitors with an opportunity to experience the architectural traditions and cultural heritage of old Iloilo.',
    ],
  ),
  ContentItem(
    id: 'landmark-nellys-garden',
    type: ContentType.landmark,
    slug: 'nellys-garden',
    image: 'landmarks/nellyGarden.jpeg',
    gallery: [GalleryPhoto(image: 'landmarks/nellyGarden.jpeg', caption: 'Nelly’s Garden exterior')],
    name: 'Nelly’s Garden',
    short: 'A grand heritage mansion surrounded by beautiful gardens.',
    title: 'Discover the grandeur of old Jaro.',
    category: 'Heritage Houses and Mansions',
    tags: ['Heritage House', 'Mansion'],
    history: [
      'Nelly’s Garden, also known as the Lopez Heritage House or Mansion de Lopez, is one of Iloilo’s most recognizable heritage properties. Located in Jaro, the mansion was built in 1928 by Vicente López and his wife Elena Hofileña López.',
      'The mansion was named after their eldest daughter, Nelly. Its architecture reflects the elegance and wealth associated with Iloilo’s prominent sugar-producing families during the early twentieth century.',
      'Designed in a grand Beaux-Arts style, the property features impressive architectural details and expansive grounds that once served as a setting for family gatherings and social occasions.',
      'It remains an important representation of Iloilo’s heritage and the history of its influential families.',
    ],
  ),
];

const List<ContentItem> kFoods = [
  ContentItem(
    id: 'food-la-paz-batchoy',
    type: ContentType.food,
    slug: 'la-paz-batchoy',
    image: 'foods/lapaz.jpeg',
    gallery: [GalleryPhoto(image: 'foods/lapaz.jpeg', caption: 'La Paz Batchoy')],
    name: 'La Paz Batchoy',
    short: 'Iloilo’s iconic noodle soup with rich broth and savory toppings.',
    title: 'A bowl of Iloilo’s culinary heritage.',
    category: 'Ilonggo Soups and Local Cuisine',
    tags: ['Soup', 'Local Food'],
    history: [
      'La Paz Batchoy originated in the La Paz district of Iloilo City and has become one of the most recognizable dishes in Ilonggo cuisine.',
      'Its history is commonly associated with the food stalls of La Paz Public Market during the 1930s and 1940s. One popular account credits Federico “Deco” Guillergan Sr., who opened a batchoy stall in 1938. Other accounts recognize Teodorico “Ted” Lepura, who established Ted’s Oldtimer in 1945 and helped popularize the dish.',
      'Traditional La Paz Batchoy features noodles served in a rich savory broth, topped with pork meat, innards, crushed chicharon, toasted garlic, and spring onions. Recipes and preparation methods vary between establishments.',
      'Today, it remains a symbol of Iloilo’s food culture and a favorite among locals and visitors.',
    ],
  ),
  ContentItem(
    id: 'food-pancit-molo',
    type: ContentType.food,
    slug: 'pancit-molo',
    image: 'foods/pancitMolo.jpg',
    gallery: [GalleryPhoto(image: 'foods/pancitMolo.jpg', caption: 'Pancit Molo')],
    name: 'Pancit Molo',
    short: 'A comforting dumpling soup inspired by the culinary traditions of Molo.',
    title: 'The comforting taste of Molo.',
    category: 'Ilonggo Soups and Local Cuisine',
    tags: ['Soup', 'Local Food'],
    history: [
      'Pancit Molo is a well-known Ilonggo soup associated with the historic district of Molo in Iloilo City.',
      'Despite its name, the dish does not traditionally contain ordinary noodles. Instead, it features dumplings made with thin wrappers filled with ground meat, often pork or chicken, served in a flavorful broth.',
      'Its development reflects the cultural influences of Chinese communities that once lived and traded in Molo. The dish became an important part of Iloilo’s culinary identity and continues to be enjoyed in homes, restaurants, and local food establishments.',
      'Pancit Molo represents the way different culinary traditions influenced and shaped Ilonggo cuisine.',
    ],
  ),
  ContentItem(
    id: 'food-kbl',
    type: ContentType.food,
    slug: 'kbl',
    image: 'foods/kbl.jpg',
    gallery: [GalleryPhoto(image: 'foods/kbl.jpg', caption: 'KBL')],
    name: 'KBL (Kadyos, Baboy, kag Langka)',
    short: 'A traditional Ilonggo soup combining pigeon peas, pork, and jackfruit.',
    title: 'Three ingredients, one Ilonggo tradition.',
    category: 'Traditional Ilonggo Dishes and Soups',
    tags: ['Traditional Dish', 'Soup'],
    history: [
      'KBL stands for Kadyos, Baboy, kag Langka, three ingredients that form one of the most recognizable traditional dishes of Western Visayas.',
      'Kadyos refers to pigeon peas, baboy refers to pork, and langka refers to unripe jackfruit. These ingredients are slowly cooked together to create a hearty soup with a distinct flavor.',
      'The dish is commonly seasoned with batuan, a local fruit used as a souring ingredient in many Western Visayan dishes. The combination creates a characteristic balance of savory and sour flavors.',
      'KBL is more than a traditional meal. It represents the everyday food traditions and culinary identity of Ilonggo households.',
    ],
  ),
  ContentItem(
    id: 'food-kansi',
    type: ContentType.food,
    slug: 'kansi',
    image: 'foods/kansi.jpeg',
    gallery: [GalleryPhoto(image: 'foods/kansi.jpeg', caption: 'Kansi')],
    name: 'Kansi',
    short: 'A rich and sour beef soup with the distinctive flavor of batuan.',
    title: 'The comforting richness of Ilonggo Kansi.',
    category: 'Ilonggo Soups and Traditional Cuisine',
    tags: ['Soup', 'Traditional Dish'],
    history: [
      'Kansi is a traditional Western Visayan beef soup closely associated with Iloilo and Negros.',
      'The dish is commonly prepared using beef shanks and bone marrow, slowly simmered until tender. Its distinctive sour flavor comes from batuan, a local fruit frequently used in Ilonggo cooking.',
      'Other ingredients may include unripe jackfruit, lemongrass, onions, and annatto seeds, which contribute to its characteristic flavor and color.',
      'Kansi is sometimes compared to a combination of bulalo and sinigang because of its rich beef broth and sour taste. However, its use of batuan gives it a distinctive regional identity.',
    ],
  ),
  ContentItem(
    id: 'food-mang-inasal',
    type: ContentType.food,
    slug: 'mang-inasal',
    image: 'foods/mangInasal.jpeg',
    gallery: [GalleryPhoto(image: 'foods/mangInasal.jpeg', caption: 'Chicken inasal')],
    name: 'Mang Inasal',
    short: 'A homegrown Filipino grilled-chicken brand that began in Iloilo.',
    title: 'From Iloilo’s streets to a nationwide favorite.',
    category: 'Ilonggo Cuisine and Filipino Food Heritage',
    tags: ['Chicken Inasal', 'Local Food'],
    history: [
      'Mang Inasal began in Iloilo City on December 12, 2003, when founder Edgar “Injap” Sia II opened its first restaurant at Robinsons Place Iloilo.',
      'The brand was built around the popularity of Chicken Inasal, a grilled chicken dish inspired by the grilling traditions of the Visayas.',
      'Its signature combination of grilled chicken and unlimited rice helped establish its identity and contributed to its rapid expansion across the Philippines.',
      'Mang Inasal’s beginnings in Iloilo represent the city’s influence on Filipino food entrepreneurship and the growth of homegrown food businesses.',
    ],
  ),
];

const List<ContentItem> kEvents = [
  ContentItem(
    id: 'event-1',
    type: ContentType.event,
    image: 'events/event1.jpg',
    name: '[INSERT EVENT NAME]',
    short: '[INSERT EVENT DESCRIPTION]',
    tags: [],
    date: '[INSERT EVENT DATE]',
    location: '[INSERT EVENT LOCATION]',
  ),
  ContentItem(
    id: 'event-2',
    type: ContentType.event,
    image: 'events/event2.jpg',
    name: '[INSERT EVENT NAME]',
    short: '[INSERT EVENT DESCRIPTION]',
    tags: [],
    date: '[INSERT EVENT DATE]',
    location: '[INSERT EVENT LOCATION]',
  ),
  ContentItem(
    id: 'event-3',
    type: ContentType.event,
    image: 'events/event3.jpg',
    name: '[INSERT EVENT NAME]',
    short: '[INSERT EVENT DESCRIPTION]',
    tags: [],
    date: '[INSERT EVENT DATE]',
    location: '[INSERT EVENT LOCATION]',
  ),
  ContentItem(
    id: 'event-4',
    type: ContentType.event,
    image: 'events/event4.jpg',
    name: '[INSERT EVENT NAME]',
    short: '[INSERT EVENT DESCRIPTION]',
    tags: [],
    date: '[INSERT EVENT DATE]',
    location: '[INSERT EVENT LOCATION]',
  ),
  ContentItem(
    id: 'event-5',
    type: ContentType.event,
    image: 'events/event5.jpg',
    name: '[INSERT EVENT NAME]',
    short: '[INSERT EVENT DESCRIPTION]',
    tags: [],
    date: '[INSERT EVENT DATE]',
    location: '[INSERT EVENT LOCATION]',
  ),
];

final List<ContentItem> kDiscoveryItems = [...kLandmarks, ...kFoods];

class HeroSlide {
  const HeroSlide({required this.image, required this.name});
  final String image;
  final String name;
}

final List<HeroSlide> kHeroSlides =
    kLandmarks.map((l) => HeroSlide(image: l.image, name: l.name)).toList();

ContentItem? getItem(String id) {
  for (final i in kDiscoveryItems) {
    if (i.id == id) return i;
  }
  return null;
}

List<ContentItem> getRelated(ContentItem item, [int limit = 3]) {
  if (item.relatedIds != null) {
    return item.relatedIds!.map(getItem).whereType<ContentItem>().toList();
  }
  final others =
      kDiscoveryItems.where((i) => i.type == item.type && i.id != item.id).toList();
  int score(ContentItem o) => o.tags.where((t) => item.tags.contains(t)).length;
  // stable sort (highest score first, original order for ties)
  final indexed = [for (var i = 0; i < others.length; i++) MapEntry(i, others[i])];
  indexed.sort((a, b) {
    final c = score(b.value).compareTo(score(a.value));
    return c != 0 ? c : a.key.compareTo(b.key);
  });
  return indexed.map((e) => e.value).take(limit).toList();
}

List<ContentItem> searchContent(String q) {
  final s = q.trim().toLowerCase();
  if (s.isEmpty) return [];
  return [...kDiscoveryItems, ...kEvents]
      .where((i) => [i.name, i.short, ...i.tags].join(' ').toLowerCase().contains(s))
      .toList();
}
