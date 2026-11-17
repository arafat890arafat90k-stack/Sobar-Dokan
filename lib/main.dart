
import 'package:flutter/material.dart';

void main() {
  runApp(const SobarDokanApp());
}

class SobarDokanApp extends StatelessWidget {
  const SobarDokanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'সবার দোকান',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF168A45),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  String searchText = '';

  final List<String> categories = [
    'সব পণ্য',
    'মোবাইল',
    'পোশাক',
    'খাবার',
    'মাছ',
    'মুরগি',
    'ইলেকট্রনিক্স',
  ];

  final List<Map<String, dynamic>> products = [
    {'name': 'সুন্দর শার্ট', 'price': '৫৫০ টাকা', 'icon': Icons.checkroom},
    {'name': 'স্মার্টফোন', 'price': '১২,০০০ টাকা', 'icon': Icons.phone_android},
    {'name': 'দেশি মুরগি', 'price': '৭০০ টাকা', 'icon': Icons.egg},
    {'name': 'গোল্ডফিশ', 'price': '১০০ টাকা', 'icon': Icons.water},
    {'name': 'চাল', 'price': '৭০ টাকা/কেজি', 'icon': Icons.rice_bowl},
    {'name': 'হেডফোন', 'price': '৩৫০ টাকা', 'icon': Icons.headphones},
  ];

  void openShop() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('আপনার দোকান খুলুন'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'দোকানের নাম',
                ),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'মোবাইল নম্বর',
                ),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'দোকানের ঠিকানা',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty ||
                  addressController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('সব তথ্য পূরণ করুন'),
                  ),
                );
                return;
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('দোকানের আবেদন গ্রহণ করা হয়েছে (ডেমো)'),
                ),
              );
            },
            child: const Text('আবেদন করুন'),
          ),
        ],
      ),
    );
  }

  Widget homeScreen() {
    final filteredProducts = products.where((product) {
      return product['name'].toString().contains(searchText);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'আপনার প্রয়োজনীয় পণ্য খুঁজুন...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.green.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'সবার দোকান',
                style: TextStyle(
                  fontSize: 27,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'আপনার দোকান, সবার বাজার!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: openShop,
            icon: const Icon(Icons.store),
            label: const Text('আপনার দোকান খুলুন'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(15),
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'পণ্যের ক্যাটাগরি',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            return ActionChip(
              label: Text(category),
              onPressed: () {
                setState(() {
                  searchText = category == 'সব পণ্য' ? '' : category;
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        const Text(
          'জনপ্রিয় পণ্যসমূহ',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.95,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final product = filteredProducts[index];

            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      product['icon'],
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product['price'],
                      style: const TextStyle(color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'পণ্য দেখুন',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        if (filteredProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('কোনো পণ্য পাওয়া যায়নি'),
          ),
      ],
    );
  }

  Widget otherScreen(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 70, color: Colors.green),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      homeScreen(),
      otherScreen('সকল ক্যাটাগরি', Icons.category),
      otherScreen('আমার অর্ডার', Icons.shopping_bag),
      otherScreen('আমার প্রোফাইল', Icons.person),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text(
          'সবার দোকান',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('নোটিফিকেশন')),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.category),
            label: 'ক্যাটাগরি',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag),
            label: 'অর্ডার',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'প্রোফাইল',
          ),
        ],
      ),
    );
  }
}
