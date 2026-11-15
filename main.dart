import 'package:flutter/material.dart';

void main() => runApp(const SobarDokanApp());

const green = Color(0xFF168B45);
const pale = Color(0xFFF3F8F4);

class SobarDokanApp extends StatelessWidget {
  const SobarDokanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'সবার দোকান',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: pale,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: green,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class Product {
  final String name;
  final String price;
  final String category;
  final IconData icon;
  const Product(this.name, this.price, this.category, this.icon);
}

const sampleProducts = <Product>[
  Product('ইউরোপিয়ান সিল্কি মুরগি', '১,২০০ টাকা', 'মুরগি ও পাখি', Icons.egg),
  Product('কলম্বিয়ান ব্রাহামা', '২,৫০০ টাকা', 'মুরগি ও পাখি', Icons.egg_alt),
  Product('কিং কোয়েল পাখি', '৩০০ টাকা', 'মুরগি ও পাখি', Icons.flutter_dash),
  Product('অ্যাকুরিয়ামের মাছ', '১৫০ টাকা', 'মাছ', Icons.set_meal),
  Product('জৈব সার', '২৫০ টাকা', 'কৃষি পণ্য', Icons.grass),
  Product('সুতি টি-শার্ট', '৪৫০ টাকা', 'পোশাক', Icons.checkroom),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int tab = 0;
  String search = '';
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        search: search,
        onSearch: (value) => setState(() => search = value),
        onSell: () => setState(() => tab = 2),
      ),
      const CategoriesPage(),
      const SellPage(),
      const OrdersPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.storefront, size: 27),
            SizedBox(width: 9),
            Text('সবার দোকান', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'নোটিফিকেশন',
            onPressed: () => _message('নতুন নোটিফিকেশন এখনো নেই'),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: IndexedStack(index: tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'হোম'),
          NavigationDestination(icon: Icon(Icons.category_outlined), label: 'বিভাগ'),
          NavigationDestination(icon: Icon(Icons.add_business_outlined), label: 'বিক্রি'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'অর্ডার'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'প্রোফাইল'),
        ],
      ),
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class HomePage extends StatelessWidget {
  final String search;
  final ValueChanged<String> onSearch;
  final VoidCallback onSell;
  const HomePage({super.key, required this.search, required this.onSearch, required this.onSell});

  static const categories = [
    ( 'মুরগি ও পাখি', Icons.egg ),
    ( 'মাছ', Icons.set_meal ),
    ( 'কৃষি পণ্য', Icons.grass ),
    ( 'পোশাক', Icons.checkroom ),
    ( 'ইলেকট্রনিক্স', Icons.devices ),
    ( 'ঘর ও আসবাব', Icons.chair ),
    ( 'খাবার', Icons.restaurant ),
    ( 'অন্যান্য', Icons.shopping_bag ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = sampleProducts.where((p) =>
      p.name.toLowerCase().contains(search.toLowerCase()) ||
      p.category.toLowerCase().contains(search.toLowerCase())).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 12),
          child: TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'আপনি কী খুঁজছেন?',
              prefixIcon: const Icon(Icons.search, color: green),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [green, Color(0xFF35A85F)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('আপনার দোকান, সবার বাজার!', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 7),
            const Text('নিজের দোকান খুলুন, সারা দেশে পণ্য বিক্রি করুন।', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 13),
            FilledButton.icon(
              onPressed: onSell,
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: green),
              icon: const Icon(Icons.storefront),
              label: const Text('দোকান খুলুন'),
            ),
          ]),
        ),
        _SectionTitle(title: 'পণ্যের বিভাগ', action: 'সব দেখুন'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: .9, crossAxisSpacing: 7, mainAxisSpacing: 7),
            itemBuilder: (context, i) => Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${categories[i].$1} বিভাগ নির্বাচিত'))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(categories[i].$2, color: green, size: 27),
                  const SizedBox(height: 7),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Text(categories[i].$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5))),
                ]),
              ),
            ),
          ),
        ),
        _SectionTitle(title: search.isEmpty ? 'জনপ্রিয় পণ্য' : 'খোঁজার ফলাফল', action: '${filtered.length}টি পণ্য'),
        if (filtered.isEmpty)
          const Padding(padding: EdgeInsets.all(25), child: Center(child: Text('কোনো পণ্য পাওয়া যায়নি')))
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .88, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemBuilder: (context, i) => ProductCard(product: filtered[i]),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  const _SectionTitle({required this.title, required this.action});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 21, 16, 11),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text(action, style: const TextStyle(color: green, fontSize: 12)),
    ]),
  );
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    elevation: 1,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(22),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Icon(product.icon, color: green, size: 65)),
            const SizedBox(height: 15),
            Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(product.category, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(product.price, style: const TextStyle(color: green, fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.shopping_cart), label: const Text('অর্ডার করতে যোগাযোগ করুন'))),
            const SizedBox(height: 10),
            const Text('এটি নমুনা পণ্য। বাস্তব অর্ডার ব্যবস্থা পরে যুক্ত হবে।', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFE7F3EA),
            child: Icon(product.icon, color: green, size: 57),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
          child: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
          child: Text(product.price, style: const TextStyle(color: green, fontWeight: FontWeight.bold)),
        ),
      ]),
    ),
  );
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(15),
    children: const [
      Text('সব পণ্যের বিভাগ', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      SizedBox(height: 12),
      _CategoryTile('মুরগি ও পাখি', Icons.egg),
      _CategoryTile('মাছ', Icons.set_meal),
      _CategoryTile('কৃষি পণ্য', Icons.grass),
      _CategoryTile('পোশাক', Icons.checkroom),
      _CategoryTile('ইলেকট্রনিক্স', Icons.devices),
      _CategoryTile('ঘর ও আসবাব', Icons.chair),
      _CategoryTile('খাবার', Icons.restaurant),
      _CategoryTile('অন্যান্য', Icons.shopping_bag),
    ],
  );
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final IconData icon;
  const _CategoryTile(this.name, this.icon);
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFFE4F2E8), child: Icon(icon, color: green)),
      title: Text(name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name বিভাগ'))),
    ),
  );
}

class SellPage extends StatefulWidget {
  const SellPage({super.key});
  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final shop = TextEditingController();
  final item = TextEditingController();
  final price = TextEditingController();

  @override
  void dispose() { shop.dispose(); item.dispose(); price.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const Text('আপনার দোকান খুলুন', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('নমুনা ফর্ম: তথ্য লিখে দেখুন। এখনো অনলাইনে সংরক্ষণ হবে না।', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 18),
      _Field(controller: shop, label: 'দোকানের নাম', hint: 'যেমন: আরাফাত এগ্রো ফার্ম'),
      _Field(controller: item, label: 'পণ্যের নাম', hint: 'পণ্যের নাম লিখুন'),
      _Field(controller: price, label: 'দাম', hint: 'যেমন: ১২০০ টাকা', keyboard: TextInputType.number),
      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: () {
          if (shop.text.trim().isEmpty || item.text.trim().isEmpty || price.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সব ঘর পূরণ করুন')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('নমুনা তথ্য নেওয়া হয়েছে: ${item.text}')));
          }
        },
        icon: const Icon(Icons.add_business),
        label: const Text('দোকান ও পণ্যের তথ্য জমা দিন'),
      ),
    ],
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboard;
  const _Field({required this.controller, required this.label, required this.hint, this.keyboard = TextInputType.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    ),
  );
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.receipt_long_outlined, color: green, size: 65),
      SizedBox(height: 12),
      Text('এখনো কোনো অর্ডার নেই', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text('আপনার অর্ডার এখানে দেখা যাবে।', style: TextStyle(color: Colors.grey)),
    ]),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const CircleAvatar(radius: 42, backgroundColor: Color(0xFFDDF0E2), child: Icon(Icons.person, color: green, size: 48)),
      const SizedBox(height: 12),
      const Center(child: Text('স্বাগতম!', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold))),
      const Center(child: Text('সবার দোকানে কেনাকাটা ও বিক্রি করুন', style: TextStyle(color: Colors.grey))),
      const SizedBox(height: 22),
      const _ProfileTile(Icons.login, 'লগইন / অ্যাকাউন্ট তৈরি'),
      const _ProfileTile(Icons.store, 'আমার দোকান'),
      const _ProfileTile(Icons.location_on_outlined, 'ঠিকানা'),
      const _ProfileTile(Icons.help_outline, 'সাহায্য ও যোগাযোগ'),
      const _ProfileTile(Icons.policy_outlined, 'নীতিমালা'),
      const SizedBox(height: 12),
      const Center(child: Text('সবার দোকান • আপনার দোকান, সবার বাজার!', style: TextStyle(color: green, fontSize: 12))),
    ],
  );
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ProfileTile(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: ListTile(
      leading: Icon(icon, color: green),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('এই সুবিধাটি পরের সংস্করণে যুক্ত হবে'))),
    ),
  );
}
