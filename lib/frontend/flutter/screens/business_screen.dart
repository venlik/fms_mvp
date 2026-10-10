import 'package:flutter/material.dart';

class BusinessScreen extends StatelessWidget {
  final String name;
  final String logo;
  final String phone;
  final String email;
  final String serviceLocation;
  final String configuredCurrency;

  const BusinessScreen({
    super.key,
    this.name = "Venlik",
    this.logo = "assets/logo.jpg",
    this.phone = '0111265590',
    this.email = 'venlik.dev@gmail.com',
    this.serviceLocation = 'Karatina',
    this.configuredCurrency = "KES",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Center(child: const Text('BUSINESS')),
            backgroundColor: Colors.blue,
            // pinned: true,
            expandedHeight: 300.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Image.asset(
                logo,
                //  width: 100,
                // height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 350,
                  width: 300,
                  child: Card(
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Logo
                        CircleAvatar(
                          minRadius: 50,
                          maxRadius: 100,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.amber,
                          backgroundImage: AssetImage(logo),
                        ),
                        SizedBox(height: 10),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text('Phone: $phone', style: TextStyle(fontSize: 16)),
                        Text('Email: $email', style: TextStyle(fontSize: 16)),
                        Text(
                          'Service Location: $serviceLocation',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Currency: $configuredCurrency',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: 20),
          ),
        ],
      ),
    );
  }
}
