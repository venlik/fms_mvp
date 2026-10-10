import 'package:finance_management_system/backend/drafts/draft_business.dart';
import 'package:finance_management_system/backend/drafts/draft_customer.dart';
import 'package:finance_management_system/backend/drafts/draft_item.dart';
import 'package:finance_management_system/backend/enums/source.dart';
import 'package:finance_management_system/backend/models/logo.dart';

List<DraftItem> popularClothingItems = [
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
    description: 'A high-quality pair of prescription sunglasses from Oakley',
    priceInCents: 1100,
  ),
  DraftItem(
    name: 'Puma Fenty Trainer Shoes',
    description:
        'A popular pair of trainer shoes from Puma and Rihanna\'s Fenty line',
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
    description: 'A popular pair of classic leather shoes from Reebok',
    priceInCents: 400,
  ),
  DraftItem(
    name: 'Prada Bag',
    description: 'A stylish bag from Prada',
    priceInCents: 1800,
  ),
  DraftItem(
    name: 'Vans Old Skool Shoes',
    description: 'A classic pair of skateboarding shoes from Vans',
    priceInCents: 300,
  ),
  DraftItem(
    name: 'Fendi Baguette Handbag',
    description: 'A high-end baguette handbag from Fendi',
    priceInCents: 2500,
  ),
  DraftItem(
    name: 'New Balance Shoes',
    description: 'A popular pair of running shoes from New Balance',
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
