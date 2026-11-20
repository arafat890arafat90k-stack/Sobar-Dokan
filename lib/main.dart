
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
   url: 'https://pivybwyqhlrimiqgjuak.supabase.co',
    anonKey: 'sb_publishable_UXSj9F-mf00LQ_vhsN0QDQ_FXLclpyX',
  );

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
  String selectedCategory = 'সব পণ্য';

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
    {'name': 'সুন্দর শার্ট', 'price': '৫৫০ টাকা',
      'category': 'পোশাক', 'icon': Icons.checkroom},
    {'name': 'স্মার্টফোন', 'price': '১২,০০০ টাকা',
      'category': 'মোবাইল', 'icon': Icons.phone_android},
    {'name': 'দেশি মুরগি', 'price': '৭০০ টাকা',
      'category': 'মুরগি', 'icon': Icons.egg_alt},
    {'name': 'গোল্ডফিশ', 'price': '১০০ টাকা',
      'category': 'মাছ', 'icon': Icons.water},
    {'name': 'চাল', 'price': '৭০ টাকা/কেজি',
      'category': 'খাবার', 'icon': Icons.rice_bowl},
    {'name': 'হেডফোন', 'price': '৩৫০ টাকা',
      'category': 'ইলেকট্রনিক্স', 'icon': Icons.headphones},
  ];

  Widget homeScreen() {
    final filteredProducts = products.where((product) {
      final categoryMatch = selectedCategory == 'সব পণ্য' ||
          product['category'] == selectedCategory;

      final searchMatch = product['name']
          .toString()
          .toLowerCase()
          .contains(searchText.toLowerCase());

      return categoryMatch && searchMatch;
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
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShopPage(),
                ),
              );
            },
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
            return ChoiceChip(
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: (_) {
                setState(() {
                  selectedCategory = category;
                  searchText = '';
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
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
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
                      product['icon'] as IconData,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product['name'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product['price'].toString(),
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
            child: Center(child: Text('কোনো পণ্য পাওয়া যায়নি')),
          ),
      ],
    );
  }

  Widget categoryScreen() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        const Text(
          'সকল ক্যাটাগরি',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        ...categories.map((category) => Card(
          child: ListTile(
            leading: const Icon(Icons.category, color: Colors.green),
            title: Text(category),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                selectedCategory = category;
                selectedIndex = 0;
              });
            },
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SimplePage(
                    title: 'নোটিফিকেশন',
                    message: 'আপনার নতুন নোটিফিকেশন এখানে দেখা যাবে।',
                    icon: Icons.notifications,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),

      body: IndexedStack(
        index: selectedIndex,
        children: [
          homeScreen(),
          categoryScreen(),
          const OrdersPage(),
          const ProfilePage(),
        ],
      ),

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

// PROFILE PAGE

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'অতিথি ব্যবহারকারী';
  String phone = '';
  String address = '';
  String shopName = '';
  bool notifications = true;

  Future<void> editProfile() async {
    final nameController = TextEditingController(text: userName);
    final phoneController = TextEditingController(text: phone);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ব্যক্তিগত তথ্য'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'আপনার নাম',
              ),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'মোবাইল নম্বর',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;

              setState(() {
                userName = nameController.text.trim();
                phone = phoneController.text.trim();
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('সংরক্ষণ করুন'),
          ),
        ],
      ),
    );

    nameController.dispose();
    phoneController.dispose();
  }

  Future<void> openShop() async {
    final nameController = TextEditingController(text: shopName);
    final phoneController = TextEditingController(text: phone);
    final addressController = TextEditingController(text: address);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
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

              setState(() {
                shopName = nameController.text.trim();
                phone = phoneController.text.trim();
                address = addressController.text.trim();
              });

              Navigator.pop(dialogContext);

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

    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }

  Future<void> editAddress() async {
    final controller = TextEditingController(text: address);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ডেলিভারি ঠিকানা'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'আপনার সম্পূর্ণ ঠিকানা লিখুন',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                address = controller.text.trim();
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  void openPage(String title, String message, IconData icon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimplePage(
          title: title,
          message: message,
          icon: icon,
        ),
      ),
    );
  }

  Widget menuItem(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      phone.isEmpty ? 'আপনার নম্বর যোগ করুন' : phone,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: editProfile,
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'আমার অ্যাকাউন্ট',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        menuItem('ব্যক্তিগত তথ্য', Icons.person, editProfile),

        menuItem(
          shopName.isEmpty ? 'আমার দোকান খুলুন' : 'আমার দোকান: $shopName',
          Icons.store,
          openShop,
        ),

        menuItem(
          'আমার অর্ডার',
          Icons.shopping_bag,
          () => openPage(
            'আমার অর্ডার',
            'আপনার করা অর্ডারগুলো এখানে দেখা যাবে।',
            Icons.shopping_bag,
          ),
        ),

        menuItem(
          'ডেলিভারি ঠিকানা',
          Icons.location_on,
          editAddress,
        ),

        const SizedBox(height: 12),

        const Text(
          'অন্যান্য সেটিংস',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Card(
          child: SwitchListTile(
            secondary: const Icon(
              Icons.notifications,
              color: Colors.green,
            ),
            title: const Text('নোটিফিকেশন'),
            subtitle: const Text('নতুন খবর ও আপডেট পান'),
            value: notifications,
            activeColor: Colors.green,
            onChanged: (value) {
              setState(() {
                notifications = value;
              });
            },
          ),
        ),

        menuItem(
          'কাস্টমার সাপোর্ট',
          Icons.support_agent,
          () => openPage(
            'কাস্টমার সাপোর্ট',
            'সবার দোকান অ্যাপ সংক্রান্ত সাহায্য পেতে আমাদের সাপোর্ট টিমের সাথে যোগাযোগ করুন।',
            Icons.support_agent,
          ),
        ),

        menuItem(
          'গোপনীয়তা নীতি',
          Icons.privacy_tip,
          () => openPage(
            'গোপনীয়তা নীতি',
            'আপনার ব্যক্তিগত তথ্যের নিরাপত্তা আমাদের কাছে গুরুত্বপূর্ণ।',
            Icons.privacy_tip,
          ),
        ),

        menuItem(
          'অ্যাপ সম্পর্কে',
          Icons.info,
          () => openPage(
            'সবার দোকান',
            'সবার দোকান — আপনার দোকান, সবার বাজার!',
            Icons.store,
          ),
        ),

        menuItem(
          'লগআউট',
          Icons.logout,
          () {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('লগআউট'),
                content: const Text(
                  'লগইন ব্যবস্থা এখনো যুক্ত করা হয়নি।',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('ঠিক আছে'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// SHOP PAGE

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('দোকান খোলার নিয়ম'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.store, size: 65, color: Colors.green),
            SizedBox(height: 15),
            Text(
              'সবার দোকানে আপনাকে স্বাগতম!',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'আপনার দোকান চালু করতে প্রোফাইল পেজের '
              'আমার দোকান খুলুন অপশন ব্যবহার করুন।',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ORDERS PAGE

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 75, color: Colors.green),
          SizedBox(height: 15),
          Text(
            'আমার অর্ডার',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('আপনার অর্ডার এখানে দেখা যাবে।'),
        ],
      ),
    );
  }
}

// GENERAL INFORMATION PAGE

class SimplePage extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const SimplePage({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 75, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
