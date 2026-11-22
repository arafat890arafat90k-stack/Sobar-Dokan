
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const SobarDokanApp());
}

// APP

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

// HOME PAGE

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
    {
      'name': 'সুন্দর শার্ট',
      'price': '৫৫০ টাকা',
      'category': 'পোশাক',
      'icon': Icons.checkroom,
    },
    {
      'name': 'স্মার্টফোন',
      'price': '১২,০০০ টাকা',
      'category': 'মোবাইল',
      'icon': Icons.phone_android,
    },
    {
      'name': 'দেশি মুরগি',
      'price': '৭০০ টাকা',
      'category': 'মুরগি',
      'icon': Icons.egg_alt,
    },
    {
      'name': 'গোল্ডফিশ',
      'price': '১০০ টাকা',
      'category': 'মাছ',
      'icon': Icons.water,
    },
    {
      'name': 'চাল',
      'price': '৭০ টাকা/কেজি',
      'category': 'খাবার',
      'icon': Icons.rice_bowl,
    },
    {
      'name': 'হেডফোন',
      'price': '৩৫০ টাকা',
      'category': 'ইলেকট্রনিক্স',
      'icon': Icons.headphones,
    },
  ];

  Widget homeScreen() {
    final filtered = products.where((p) {
      final categoryMatch =
          selectedCategory == 'সব পণ্য' ||
          p['category'] == selectedCategory;

      final searchMatch = p['name']
          .toString()
          .toLowerCase()
          .contains(searchText.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        TextField(
          onChanged: (v) => setState(() => searchText = v),
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
        ElevatedButton.icon(
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
        const SizedBox(height: 20),
        const Text(
          'পণ্যের ক্যাটাগরি',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
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
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.95,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final p = filtered[index];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      p['icon'] as IconData,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p['price'],
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
        if (filtered.isEmpty)
          const Center(child: Text('কোনো পণ্য পাওয়া যায়নি')),
      ],
    );
  }

  Widget categoryScreen() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        const Text(
          'সকল ক্যাটাগরি',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ...categories.map(
          (category) => Card(
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      homeScreen(),
      categoryScreen(),
      const ApprovedShopsPage(),
      const OrdersPage(),
      const ProfilePage(),
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
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
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
            icon: Icon(Icons.store),
            label: 'দোকান',
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
    final name = TextEditingController(text: userName);
    final mobile = TextEditingController(text: phone);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ব্যক্তিগত তথ্য'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'আপনার নাম'),
            ),
            TextField(
              controller: mobile,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'মোবাইল নম্বর'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              setState(() {
                userName = name.text.trim();
                phone = mobile.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('সংরক্ষণ করুন'),
          ),
        ],
      ),
    );

    name.dispose();
    mobile.dispose();
  }

  Future<void> openShop() async {
    final name = TextEditingController(text: shopName);
    final mobile = TextEditingController(text: phone);
    final location = TextEditingController(text: address);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('আপনার দোকান খুলুন'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'দোকানের নাম'),
              ),
              TextField(
                controller: mobile,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'মোবাইল নম্বর'),
              ),
              TextField(
                controller: location,
                decoration: const InputDecoration(labelText: 'দোকানের ঠিকানা'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (name.text.trim().isEmpty ||
                  mobile.text.trim().isEmpty ||
                  location.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('সব তথ্য পূরণ করুন')),
                );
                return;
              }

              try {
                await supabase.from('shop_applications').insert({
                  'owner_name': userName,
                  'shop_name': name.text.trim(),
                  'phone': mobile.text.trim(),
                  'address': location.text.trim(),
                });

                if (!mounted) return;

                setState(() {
                  shopName = name.text.trim();
                  phone = mobile.text.trim();
                  address = location.text.trim();
                });

                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('দোকানের আবেদন সফলভাবে জমা হয়েছে'),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('আবেদন জমা হয়নি: $e')),
                );
              }
            },
            child: const Text('আবেদন করুন'),
          ),
        ],
      ),
    );

    name.dispose();
    mobile.dispose();
    location.dispose();
  }

  Future<void> editAddress() async {
    final controller = TextEditingController(text: address);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => address = controller.text.trim());
              Navigator.pop(ctx);
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

  Widget menuItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
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
                child: Icon(Icons.person, size: 40, color: Colors.green),
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
        menuItem('ডেলিভারি ঠিকানা', Icons.location_on, editAddress),
        const SizedBox(height: 12),
        const Text(
          'অন্যান্য সেটিংস',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.green),
            title: const Text('নোটিফিকেশন'),
            subtitle: const Text('নতুন খবর ও আপডেট পান'),
            value: notifications,
            activeColor: Colors.green,
            onChanged: (v) => setState(() => notifications = v),
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
        const Divider(height: 25),
        const Text(
          'অ্যাডমিন নিয়ন্ত্রণ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        menuItem(
          'অ্যাডমিন লগইন',
          Icons.admin_panel_settings,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminLoginPage(),
              ),
            );
          },
        ),
        if (supabase.auth.currentUser != null)
          menuItem(
            'লগআউট',
            Icons.logout,
            () async {
              await supabase.auth.signOut();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('লগআউট হয়েছে')),
                );
                setState(() {});
              }
            },
          ),
      ],
    );
  }
}

// ADMIN LOGIN PAGE

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ইমেইল ও পাসওয়ার্ড লিখুন')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('লগইন পাওয়া যায়নি');
      }

      final admin = await supabase
          .from('app_admins')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (admin == null) {
        await supabase.auth.signOut();
        throw Exception('আপনার অ্যাডমিন অনুমতি নেই');
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboardPage(
            role: admin['role'].toString(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('লগইন হয়নি: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাডমিন লগইন'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 85,
                color: Colors.green,
              ),
              const SizedBox(height: 15),
              const Text(
                'সবার দোকান অ্যাডমিন',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'অ্যাডমিন ইমেইল',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  labelText: 'পাসওয়ার্ড',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => hidePassword = !hidePassword);
                    },
                    icon: Icon(
                      hidePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('লগইন করুন'),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'শুধু অনুমোদিত অ্যাডমিন প্রবেশ করতে পারবেন।',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ADMIN DASHBOARD

class AdminDashboardPage extends StatefulWidget {
  final String role;

  const AdminDashboardPage({
    super.key,
    required this.role,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<List<Map<String, dynamic>>> applicationsFuture;

  @override
  void initState() {
    super.initState();
    applicationsFuture = loadApplications();
  }

  Future<List<Map<String, dynamic>>> loadApplications() async {
    final data = await supabase
        .from('shop_applications')
        .select('id, owner_name, shop_name, phone, address, status, created_at')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  void refreshApplications() {
    setState(() {
      applicationsFuture = loadApplications();
    });
  }

  Future<void> changeStatus(
    Map<String, dynamic> application,
    String status,
  ) async {
    try {
      await supabase
          .from('shop_applications')
          .update({'status': status})
          .eq('id', application['id']);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'দোকানের আবেদন অনুমোদন করা হয়েছে'
                : 'দোকানের আবেদন বাতিল করা হয়েছে',
          ),
        ),
      );

      refreshApplications();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('সমস্যা হয়েছে: $e')),
      );
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  Widget applicationCard(Map<String, dynamic> item) {
    final status = item['status']?.toString() ?? 'pending';

    final statusText = status == 'approved'
        ? 'অনুমোদিত'
        : status == 'rejected'
            ? 'বাতিল'
            : 'অপেক্ষমাণ';

    final statusColor = status == 'approved'
        ? Colors.green
        : status == 'rejected'
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE5F5E9),
                  child: Icon(Icons.store, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['shop_name']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(statusText),
                  backgroundColor: statusColor.withAlpha(30),
                  labelStyle: TextStyle(color: statusColor),
                ),
              ],
            ),
            const Divider(),
            Text('মালিক: ${item['owner_name'] ?? ''}'),
            Text('মোবাইল: ${item['phone'] ?? ''}'),
            Text('ঠিকানা: ${item['address'] ?? ''}'),
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => changeStatus(item, 'approved'),
                      icon: const Icon(Icons.check),
                      label: const Text('অনুমোদন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => changeStatus(item, 'rejected'),
                      icon: const Icon(Icons.close),
                      label: const Text('বাতিল'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাডমিন ড্যাশবোর্ড'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: refreshApplications,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('আবেদন লোড করা যায়নি'),
                    const SizedBox(height: 10),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: refreshApplications,
                      child: const Text('আবার চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            );
          }

          final applications = snapshot.data ?? [];

          final pending = applications
              .where((a) => a['status'] == 'pending')
              .length;

          final approved = applications
              .where((a) => a['status'] == 'approved')
              .length;

          final rejected = applications
              .where((a) => a['status'] == 'rejected')
              .length;

          return RefreshIndicator(
            onRefresh: () async => refreshApplications(),
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'সবার দোকান',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.role == 'super_admin'
                            ? 'সুপার অ্যাডমিন'
                            : 'অ্যাডমিন',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        'নতুন আবেদন',
                        pending,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statCard(
                        'অনুমোদিত',
                        approved,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statCard(
                        'বাতিল',
                        rejected,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'দোকানের আবেদনসমূহ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (applications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text('এখনো কোনো আবেদন পাওয়া যায়নি'),
                    ),
                  ),
                ...applications.map(applicationCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
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
          Icon(
            Icons.shopping_bag_outlined,
            size: 75,
            color: Colors.green,
          ),
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

// SIMPLE PAGE

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

// APPROVED SHOPS PAGE

class ApprovedShopsPage extends StatefulWidget {
  const ApprovedShopsPage({super.key});

  @override
  State<ApprovedShopsPage> createState() => _ApprovedShopsPageState();
}

class _ApprovedShopsPageState extends State<ApprovedShopsPage> {
  late Future<List<Map<String, dynamic>>> shopsFuture;

  @override
  void initState() {
    super.initState();
    shopsFuture = loadShops();
  }

  Future<List<Map<String, dynamic>>> loadShops() async {
    final response = await supabase
        .from('shop_applications')
        .select('owner_name, shop_name, phone, address')
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  void refreshShops() {
    setState(() => shopsFuture = loadShops());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অনুমোদিত দোকান'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: refreshShops,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: shopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('দোকানের তথ্য লোড হয়নি'),
                    const SizedBox(height: 10),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: refreshShops,
                      child: const Text('আবার চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            );
          }

          final shops = snapshot.data ?? [];

          if (shops.isEmpty) {
            return const Center(
              child: Text('এখনো কোনো অনুমোদিত দোকান নেই'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.store, color: Colors.green),
                  ),
                  title: Text(shop['shop_name'] ?? ''),
                  subtitle: Text(
                    'মালিক: ${shop['owner_name'] ?? ''}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 17),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopDetailsPage(shop: shop),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// SHOP DETAILS

class ShopDetailsPage extends StatelessWidget {
  final Map<String, dynamic> shop;

  const ShopDetailsPage({
    super.key,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('দোকানের বিস্তারিত'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFFE5F5E9),
            child: Icon(Icons.store, size: 50, color: Colors.green),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              shop['shop_name'] ?? '',
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.green),
                  title: const Text('দোকানের মালিক'),
                  subtitle: Text(shop['owner_name'] ?? ''),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: const Text('মোবাইল নম্বর'),
                  subtitle: Text(shop['phone'] ?? ''),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: const Text('দোকানের ঠিকানা'),
                  subtitle: Text(shop['address'] ?? ''),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
