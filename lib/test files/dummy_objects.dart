import 'package:finance_management_system/backend/drafts/draft_business.dart';
import 'package:finance_management_system/backend/drafts/draft_customer.dart';
import 'package:finance_management_system/backend/drafts/draft_item.dart';
import 'package:finance_management_system/backend/enums/source.dart';
import 'package:finance_management_system/backend/models/logo.dart';

List<DraftItem> testItems = [
  // 1–20: Original items
  DraftItem(
    name: 'Nike T-Shirt',
    description: 'A classic t-shirt from Nike',
    priceInCents: 500,
  ),
  DraftItem(
    name: 'Levi\'s Jeans',
    description: 'A pair of iconic jeans from Levi\'s',
    priceInCents: 800,
  ),
  DraftItem(
    name: 'Adidas Hoodie',
    description: 'A cozy hoodie from Adidas',
    priceInCents: 450,
  ),
  DraftItem(
    name: 'Converse Sneakers',
    description: 'A classic pair of sneakers from Converse',
    priceInCents: 600,
  ),
  DraftItem(
    name: 'Gucci Handbag',
    description: 'A stylish handbag from Gucci',
    priceInCents: 1200,
  ),
  DraftItem(
    name: 'Ray-Ban Sunglasses',
    description: 'A popular pair of sunglasses from Ray-Ban',
    priceInCents: 900,
  ),
  DraftItem(
    name: 'Apple Watch',
    description: 'A high-end smartwatch from Apple',
    priceInCents: 1500,
  ),
  DraftItem(
    name: 'Nike Air Jordan Shoes',
    description: 'A popular pair of basketball shoes from Nike',
    priceInCents: 1000,
  ),
  DraftItem(
    name: 'Oakley Prescription Sunglasses',
    description: 'High-quality prescription sunglasses from Oakley',
    priceInCents: 1100,
  ),
  DraftItem(
    name: 'Puma Fenty Trainer Shoes',
    description: 'Trainer shoes from Puma and Rihanna\'s Fenty line',
    priceInCents: 700,
  ),
  DraftItem(
    name: 'Supreme Hoodie',
    description: 'A limited-edition hoodie from Supreme',
    priceInCents: 5000,
  ),
  DraftItem(
    name: 'Hermes Handbag',
    description: 'A high-end handbag from Hermes',
    priceInCents: 2000,
  ),
  DraftItem(
    name: 'Reebok Classic Leather Shoes',
    description: 'Classic leather shoes from Reebok',
    priceInCents: 400,
  ),
  DraftItem(
    name: 'Prada Bag',
    description: 'A stylish bag from Prada',
    priceInCents: 1800,
  ),
  DraftItem(
    name: 'Vans Old Skool Shoes',
    description: 'Classic skateboarding shoes from Vans',
    priceInCents: 300,
  ),
  DraftItem(
    name: 'Fendi Baguette Handbag',
    description: 'A high-end baguette handbag from Fendi',
    priceInCents: 2500,
  ),
  DraftItem(
    name: 'New Balance Shoes',
    description: 'Running shoes from New Balance',
    priceInCents: 250,
  ),
  DraftItem(
    name: 'Polo Ralph Lauren Shirt',
    description: 'A classic Polo shirt from Ralph Lauren',
    priceInCents: 400,
  ),
  DraftItem(
    name: 'Gucci Belt',
    description: 'A high-end belt from Gucci',
    priceInCents: 800,
  ),
  DraftItem(
    name: 'Chanel Handbag',
    description: 'A luxurious handbag from Chanel',
    priceInCents: 2800,
  ),

  // 21–30: More clothing
  DraftItem(
    name: 'Adidas Track Pants',
    description: 'Comfortable athletic track pants from Adidas',
    priceInCents: 650,
  ),
  DraftItem(
    name: 'Zara Denim Jacket',
    description: 'A modern denim jacket from Zara',
    priceInCents: 950,
  ),
  DraftItem(
    name: 'H&M Cotton Hoodie',
    description: 'A soft everyday cotton hoodie from H&M',
    priceInCents: 350,
  ),
  DraftItem(
    name: 'Tommy Hilfiger Polo',
    description: 'A stylish casual polo shirt from Tommy Hilfiger',
    priceInCents: 750,
  ),
  DraftItem(
    name: 'Under Armour Sports Shirt',
    description: 'A breathable performance shirt from Under Armour',
    priceInCents: 550,
  ),
  DraftItem(
    name: 'Calvin Klein Boxer Briefs',
    description: 'Comfortable boxer briefs from Calvin Klein',
    priceInCents: 450,
  ),
  DraftItem(
    name: 'North Face Puffer Jacket',
    description: 'A warm insulated puffer jacket from The North Face',
    priceInCents: 2200,
  ),
  DraftItem(
    name: 'Burberry Trench Coat',
    description: 'A premium trench coat from Burberry',
    priceInCents: 6500,
  ),
  DraftItem(
    name: 'Lacoste Crew Neck Sweater',
    description: 'A classic crew neck sweater from Lacoste',
    priceInCents: 1300,
  ),
  DraftItem(
    name: 'Carhartt Workwear Jacket',
    description: 'A durable workwear jacket from Carhartt',
    priceInCents: 1700,
  ),

  // 31–40: Footwear
  DraftItem(
    name: 'Nike Air Max 90',
    description: 'Iconic lifestyle sneakers from Nike',
    priceInCents: 1400,
  ),
  DraftItem(
    name: 'Adidas Ultraboost',
    description: 'Cushioned running shoes from Adidas',
    priceInCents: 1600,
  ),
  DraftItem(
    name: 'Dr. Martens Boots',
    description: 'Durable leather boots from Dr. Martens',
    priceInCents: 1900,
  ),
  DraftItem(
    name: 'Timberland Boots',
    description: 'Classic rugged boots from Timberland',
    priceInCents: 1800,
  ),
  DraftItem(
    name: 'Crocs Classic Clogs',
    description: 'Lightweight everyday clogs from Crocs',
    priceInCents: 400,
  ),
  DraftItem(
    name: 'Birkenstock Arizona Sandals',
    description: 'Comfortable two-strap sandals from Birkenstock',
    priceInCents: 850,
  ),
  DraftItem(
    name: 'Asics Gel-Kayano',
    description: 'Supportive running shoes from Asics',
    priceInCents: 1200,
  ),
  DraftItem(
    name: 'Jordan Retro High',
    description: 'High-top basketball-inspired sneakers from Jordan',
    priceInCents: 2100,
  ),
  DraftItem(
    name: 'Clarks Desert Boots',
    description: 'Timeless suede desert boots from Clarks',
    priceInCents: 1100,
  ),
  DraftItem(
    name: 'Puma Suede Classic',
    description: 'Retro suede sneakers from Puma',
    priceInCents: 650,
  ),

  // 41–50: Accessories and premium items
  DraftItem(
    name: 'Michael Kors Wallet',
    description: 'A stylish everyday wallet from Michael Kors',
    priceInCents: 900,
  ),
  DraftItem(
    name: 'Coach Crossbody Bag',
    description: 'A versatile crossbody bag from Coach',
    priceInCents: 2400,
  ),
  DraftItem(
    name: 'Fossil Leather Watch',
    description: 'A classic leather-strap watch from Fossil',
    priceInCents: 1250,
  ),
  DraftItem(
    name: 'Casio G-Shock Watch',
    description: 'A rugged digital watch from Casio',
    priceInCents: 700,
  ),
  DraftItem(
    name: 'Oakley Sports Cap',
    description: 'A sporty everyday cap from Oakley',
    priceInCents: 350,
  ),
  DraftItem(
    name: 'New Era Baseball Cap',
    description: 'A classic fitted baseball cap from New Era',
    priceInCents: 300,
  ),
  DraftItem(
    name: 'Versace Sunglasses',
    description: 'Designer sunglasses from Versace',
    priceInCents: 2200,
  ),
  DraftItem(
    name: 'Montblanc Leather Belt',
    description: 'A premium leather belt from Montblanc',
    priceInCents: 1500,
  ),
  DraftItem(
    name: 'Balenciaga Sneakers',
    description: 'Luxury statement sneakers from Balenciaga',
    priceInCents: 7500,
  ),
  DraftItem(
    name: 'Louis Vuitton Backpack',
    description: 'A luxury designer backpack from Louis Vuitton',
    priceInCents: 8500,
  ),
];

final dummyBusiness = DraftBusiness(
  name: 'Venlik',
  logo: Logo(path: 'assets/logo.jpg', source: Source.asset),
  phoneNumber: '0719179674',
  email: 'venlik.dev@gmail.com',
  serviceLocation: "Karatina",
  configuredCurrency: "KES",
);

final dummyBusiness1 = DraftBusiness(
  name: "KONSOLE",
  logo: Logo(path: 'assets/logo.jpg', source: Source.file),
  phoneNumber: '000-222-333-546',
  email: "konsole@fedora.plasma",
  serviceLocation: 'hp elitebook 840 g5',
  configuredCurrency: 'KES',
);

final dummyCustomer = DraftCustomer(
  name: "Kelvin",
  address: "Karatina",
  phoneNumber: "222-666-233-456",
  email: 'nobody@people.collection',
);

final dummyCustomer1 = DraftCustomer(
  name: "Christine",
  address: "Nairobi",
  email: 'somebody@people.collection',
  phoneNumber: "056-473-583-045",
);
