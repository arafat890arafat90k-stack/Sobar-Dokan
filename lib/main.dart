
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

// ================= APP =================

class SobarDokanApp extends StatelessWidget {
  const SobarDokanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'সবার দোকান',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xfff5f8f5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ================= AUTH GATE =================

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? checkedUserId;
  Future<bool>? adminFuture;

  Future<bool> checkAdmin(String userId) async {
    final result = await supabase
        .from('app_admins')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = supabase.auth.currentUser;

        if (user == null) {
          checkedUserId = null;
          adminFuture = null;
          return const LoginPage();
        }

        if (checkedUserId != user.id) {
          checkedUserId = user.id;
          adminFuture = checkAdmin(user.id);
        }

        return FutureBuilder<bool>(
          future: adminFuture,
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                ),
              );
            }

            if (adminSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('অ্যাকাউন্ট যাচাই করা যায়নি।'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await supabase.auth.signOut();
                        },
                        child: const Text('আবার লগইন করুন'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (adminSnapshot.data == true) {
              return const AdminDashboardPage();
            }

            return const HomePage();
          },
        );
      },
    );
  }
}

// ================= PHONE HELPERS =================

String normalizePhone(String input) {
  String digits = input.replaceAll(RegExp(r'[^0-9]'), '');

  if (digits.startsWith('0088')) {
    digits = digits.substring(2);
  }

  if (digits.startsWith('01') && digits.length == 11) {
    digits = '88$digits';
  }

  if (digits.startsWith('8801') && digits.length == 13) {
    return digits;
  }

  throw Exception('সঠিক বাংলাদেশি মোবাইল নম্বর দিন।');
}

String phoneToEmail(String phone) {
  return '$phone@login.sobardokan.invalid';
}

// ================= LOGIN / REGISTER =================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool isRegister = false;
  bool loading = false;
  bool hidePassword = true;
  String accountType = 'buyer';

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final phone = normalizePhone(phoneController.text.trim());
      final password = passwordController.text;

      if (password.length < 6) {
        throw Exception('পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।');
      }

      final email = phoneToEmail(phone);

      if (isRegister) {
        final name = nameController.text.trim();

        if (name.isEmpty) {
          throw Exception('আপনার নাম লিখুন।');
        }

        final result = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final user = result.user;

        if (user == null) {
          throw Exception('অ্যাকাউন্ট তৈরি করা যায়নি।');
        }

        if (result.session == null) {
          throw Exception(
            'অ্যাকাউন্ট তৈরি হয়েছে। Supabase Authentication থেকে '
            'Email Confirmation বন্ধ করুন, তারপর লগইন করুন।',
          );
        }

        await supabase.from('user_profiles').upsert({
          'id': user.id,
          'full_name': name,
          'phone': phone,
          'account_type': accountType,
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে।'),
          ),
        );
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void openAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminLoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'সবার দোকান',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Text('আপনার দোকান, সবার বাজার!'),
                  const SizedBox(height: 35),
                  Text(
                    isRegister ? 'নতুন অ্যাকাউন্ট খুলুন' : 'লগইন করুন',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (isRegister)
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'আপনার নাম',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),

                  if (isRegister) const SizedBox(height: 14),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'মোবাইল নম্বর',
                      hintText: '01XXXXXXXXX',
                      prefixIcon: Icon(Icons.phone_android),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: 'পাসওয়ার্ড',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),

                  if (isRegister) ...[
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'অ্যাকাউন্টের ধরন',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    RadioGroup<String>(
                      groupValue: accountType,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => accountType = value);
                        }
                      },
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: 'buyer',
                            title: const Text('ক্রেতা'),
                          ),
                          RadioListTile<String>(
                            value: 'shop_owner',
                            title: const Text('দোকান মালিক'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: loading ? null : submit,
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              isRegister ? 'অ্যাকাউন্ট খুলুন' : 'লগইন',
                              style: const TextStyle(fontSize: 17),
                            ),
                    ),
                  ),

                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            setState(() {
                              isRegister = !isRegister;
                            });
                          },
                    child: Text(
                      isRegister
                          ? 'আগে অ্যাকাউন্ট আছে? লগইন করুন'
                          : 'নতুন অ্যাকাউন্ট খুলুন',
                    ),
                  ),

                  const Divider(height: 30),

                  TextButton.icon(
                    onPressed: openAdminLogin,
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('অ্যাডমিন লগইন'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= HOME =================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final pages = const [
    StoreHomePage(),
    CategoriesPage(),
    ShopsPage(),
    OrdersPage(),
    ProfilePage(),
  ];

  final titles = const [
    'সবার দোকান',
    'ক্যাটাগরি',
    'দোকানসমূহ',
    'আমার অর্ডার',
    'আমার প্রোফাইল',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: 'ক্যাটাগরি',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            label: 'দোকান',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'অর্ডার',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'প্রোফাইল',
          ),
        ],
      ),
    );
  }
}

// ================= STORE HOME =================

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  final searchController = TextEditingController();
  String search = '';

  Future<List<Map<String, dynamic>>> loadProducts() async {
    final data = await supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'স্বাগতম সবার দোকানে!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'এক জায়গায় খুঁজুন আপনার প্রয়োজনীয় পণ্য।',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() => search = value.toLowerCase());
            },
            decoration: InputDecoration(
              hintText: 'পণ্য খুঁজুন...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'সাম্প্রতিক পণ্য',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: loadProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Text('পণ্য লোড করা যায়নি।');
              }

              final products = snapshot.data ?? [];

              final filtered = products.where((product) {
                final name = (product['product_name'] ?? '')
                    .toString()
                    .toLowerCase();
                return name.contains(search);
              }).toList();

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(25),
                  child: Center(
                    child: Text('এখনো কোনো পণ্য পাওয়া যায়নি।'),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.76,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: filtered[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ================= PRODUCT CARD =================

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final image = product['image_url']?.toString();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: image != null && image.isNotEmpty
                ? Image.network(
                    image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 45,
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Icon(Icons.shopping_bag, size: 50),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['product_name']?.toString() ?? 'পণ্য',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  '৳ ${product['price'] ?? '0'}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CATEGORIES =================

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  final categories = const [
    'ইলেকট্রনিক্স',
    'কাপড় ও ফ্যাশন',
    'খাবার ও মুদি',
    'কৃষি পণ্য',
    'মোবাইল ও কম্পিউটার',
    'ঘর ও আসবাবপত্র',
    'প্রসাধনী',
    'অন্যান্য',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return Card(
          child: Center(
            child: Text(
              categories[index],
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ================= SHOPS =================

class ShopsPage extends StatelessWidget {
  const ShopsPage({super.key});

  Future<List<Map<String, dynamic>>> loadShops() async {
    final data = await supabase
        .from('shop_applications')
        .select()
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    final shops = List<Map<String, dynamic>>.from(data);

    for (final shop in shops) {
      String ownerName = (shop['owner_name'] ?? '').toString();

      if (ownerName.isEmpty || ownerName == 'অতিথি ব্যবহারকারী') {
        final ownerId = shop['owner_user_id'];
        final phone = shop['phone'];

        Map<String, dynamic>? profile;

        if (ownerId != null) {
          profile = await supabase
              .from('user_profiles')
              .select('full_name')
              .eq('id', ownerId)
              .maybeSingle();
        }

        if (profile == null && phone != null) {
          profile = await supabase
              .from('user_profiles')
              .select('full_name')
              .eq('phone', phone)
              .maybeSingle();
        }

        ownerName = (profile?['full_name'] ?? '').toString();

        if (ownerName.isNotEmpty) {
          shop['owner_name'] = ownerName;
        }
      }
    }

    return shops;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadShops(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('দোকান লোড করা যায়নি।'));
        }

        final shops = snapshot.data ?? [];

        if (shops.isEmpty) {
          return const Center(
            child: Text('এখনো কোনো অনুমোদিত দোকান নেই।'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            final shop = shops[index];

            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.store, color: Colors.white),
                ),
                title: Text(shop['shop_name'] ?? 'দোকান'),
                subtitle: Text(
                  'মালিক: ${shop['owner_name'] ?? 'তথ্য পাওয়া যায়নি'}\n'
                  '${shop['address'] ?? ''}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios),
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
    );
  }
}

// ================= SHOP DETAILS =================

class ShopDetailsPage extends StatelessWidget {
  final Map<String, dynamic> shop;

  const ShopDetailsPage({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shop['shop_name'] ?? 'দোকান'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.store, size: 70, color: Colors.green),
            const SizedBox(height: 15),
            Text(
              shop['shop_name'] ?? '',
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('মালিক: ${shop['owner_name'] ?? 'তথ্য পাওয়া যায়নি'}'),
            Text('ফোন: ${shop['phone'] ?? ''}'),
            Text('ঠিকানা: ${shop['address'] ?? ''}'),
          ],
        ),
      ),
    );
  }
}

// ================= ORDERS =================

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
            size: 65,
            color: Colors.green,
          ),
          SizedBox(height: 12),
          Text(
            'আপনার অর্ডার এখানে দেখা যাবে।',
            style: TextStyle(fontSize: 17),
          ),
          SizedBox(height: 5),
          Text('অর্ডার ব্যবস্থা পরবর্তী ধাপে যুক্ত হবে।'),
        ],
      ),
    );
  }
}

// ================= PROFILE =================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>?> profileFuture;

  @override
  void initState() {
    super.initState();
    profileFuture = loadProfile();
  }

  Future<Map<String, dynamic>?> loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  Future<void> refreshProfile() async {
    setState(() {
      profileFuture = loadProfile();
    });
  }

  Future<void> applyForShop() async {
    final nameController = TextEditingController();
    final shopController = TextEditingController();
    final addressController = TextEditingController();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('দোকানের আবেদন'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'আপনার নাম',
                    ),
                  ),
                  TextField(
                    controller: shopController,
                    decoration: const InputDecoration(
                      labelText: 'দোকানের নাম',
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
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('বাতিল'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('আবেদন করুন'),
              ),
            ],
          );
        },
      );

      if (result != true) return;

      if (nameController.text.trim().isEmpty ||
          shopController.text.trim().isEmpty ||
          addressController.text.trim().isEmpty) {
        showMessage('সব তথ্য পূরণ করুন।');
        return;
      }

      final user = supabase.auth.currentUser;
      if (user == null) return;

      final profile = await supabase
          .from('user_profiles')
          .select('phone')
          .eq('id', user.id)
          .single();

      final existing = await supabase
          .from('shop_applications')
          .select('id,status')
          .eq('owner_user_id', user.id)
          .eq('status', 'pending')
          .maybeSingle();

      if (existing != null) {
        showMessage('আপনার একটি আবেদন ইতিমধ্যে অপেক্ষমাণ আছে।');
        return;
      }

      await supabase.from('shop_applications').insert({
        'owner_name': nameController.text.trim(),
        'shop_name': shopController.text.trim(),
        'phone': profile['phone'],
        'address': addressController.text.trim(),
        'status': 'pending',
        'owner_user_id': user.id,
      });

      showMessage('দোকানের আবেদন জমা হয়েছে। অনুমোদনের অপেক্ষা করুন।');
    } catch (e) {
      showMessage('আবেদন জমা হয়নি: $e');
    } finally {
      nameController.dispose();
      shopController.dispose();
      addressController.dispose();
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('প্রোফাইল লোড করা যায়নি।'),
                TextButton(
                  onPressed: refreshProfile,
                  child: const Text('আবার চেষ্টা করুন'),
                ),
              ],
            ),
          );
        }

        final profile = snapshot.data;
        final user = supabase.auth.currentUser;

        if (user == null) {
          return const Center(child: Text('লগইন করুন।'));
        }

        final name = profile?['full_name']?.toString() ??
            user.userMetadata?['full_name']?.toString() ??
            'ব্যবহারকারী';

        final phone = profile?['phone']?.toString() ?? '';
        final type = profile?['account_type']?.toString() ?? 'buyer';

        return RefreshIndicator(
          onRefresh: refreshProfile,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const CircleAvatar(
                radius: 43,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(child: Text(phone)),
              const SizedBox(height: 25),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('অ্যাকাউন্টের ধরন'),
                  subtitle: Text(
                    type == 'shop_owner' ? 'দোকান মালিক' : 'ক্রেতা',
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.store),
                  title: const Text('দোকান খুলুন'),
                  subtitle: const Text(
                    'আপনার দোকানের জন্য আবেদন করুন',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: applyForShop,
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('প্রোফাইল আপডেট'),
                  onTap: refreshProfile,
                ),
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('লগআউট'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================= ADMIN LOGIN =================

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('অ্যাডমিন অ্যাকাউন্ট পাওয়া যায়নি।');
      }

      final admin = await supabase
          .from('app_admins')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (admin == null) {
        await supabase.auth.signOut();
        throw Exception('আপনার অ্যাডমিন অনুমতি নেই।');
      }

      if (!mounted) return;

      Navigator.pop(context);
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('অ্যাডমিন লগইন')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'অ্যাডমিন ইমেইল',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'পাসওয়ার্ড',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('লগইন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ADMIN DASHBOARD =================

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
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
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  void refreshApplications() {
    setState(() {
      applicationsFuture = loadApplications();
    });
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      await supabase
          .from('shop_applications')
          .update({
            'status': status,
            'reviewed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);

      refreshApplications();

      showMessage(
        status == 'approved'
            ? 'দোকান অনুমোদন করা হয়েছে।'
            : 'আবেদন বাতিল করা হয়েছে।',
      );
    } catch (e) {
      showMessage('পরিবর্তন করা যায়নি: $e');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাডমিন ড্যাশবোর্ড'),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('আবেদন লোড করা যায়নি: ${snapshot.error}'),
            );
          }

          final applications = snapshot.data ?? [];

          final pendingCount = applications
              .where((item) => item['status'] == 'pending')
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  color: Colors.green.shade50,
                  child: ListTile(
                    leading: const Icon(
                      Icons.store,
                      color: Colors.green,
                      size: 35,
                    ),
                    title: Text(
                      'মোট দোকানের আবেদন: ${applications.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('অনুমোদনের অপেক্ষায়: $pendingCount'),
                  ),
                ),
              ),

              Expanded(
                child: applications.isEmpty
                    ? const Center(
                        child: Text('কোনো দোকানের আবেদন নেই।'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          final item = applications[index];
                          final id = item['id'] as int;
                          final status =
                              item['status']?.toString() ?? 'pending';

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['shop_name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    'মালিক: ${item['owner_name'] ?? ''}',
                                  ),
                                  Text('ফোন: ${item['phone'] ?? ''}'),
                                  Text(
                                    'ঠিকানা: ${item['address'] ?? ''}',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'অবস্থা: $status',
                                    style: TextStyle(
                                      color: status == 'approved'
                                          ? Colors.green
                                          : status == 'rejected'
                                              ? Colors.red
                                              : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  if (status == 'pending') ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: () =>
                                                updateStatus(
                                              id,
                                              'approved',
                                            ),
                                            child: const Text('অনুমোদন'),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                updateStatus(
                                              id,
                                              'rejected',
                                            ),
                                            child: const Text('বাতিল'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
