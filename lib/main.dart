import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/person.dart';
import 'pages/add_person_page.dart';
import 'pages/person_detail_page.dart';
import 'pages/family_tree_page.dart';

void main() {
  runApp(const FamilyTreeApp());
}

class FamilyTreeApp extends StatelessWidget {
  const FamilyTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'شجرة العائلة',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final String correctUser = 'family';
  final String correctPass = '12345';

  void _login() {
    if (userController.text == correctUser && passController.text == correctPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بيانات الدخول غير صحيحة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('تسجيل دخول العائلة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: userController,
                decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('دخول')),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Person> persons = [];

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    persons = await DatabaseHelper.instance.getAllPersons();
    if (mounted) setState(() {});
  }

  Future<void> _addPerson() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPersonPage()),
    );
    if (added == true) {
      _loadPersons();
    }
  }

  void _openTree(Person root) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FamilyTreePage(rootPerson: root)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شجرة العائلة')),
      body: persons.isEmpty
          ? const Center(child: Text('لا يوجد أشخاص بعد — ابدأ بالإضافة'))
          : ListView.builder(
              itemCount: persons.length,
              itemBuilder: (context, index) {
                final person = persons[index];
                return ListTile(
                  title: Text(person.name),
                  subtitle: Text(person.job ?? 'بدون مهنة'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PersonDetailPage(person: person)),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.account_tree),
                    onPressed: () => _openTree(person),
                    tooltip: 'عرض الشجرة من هذا الشخص',
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPerson,
        child: const Icon(Icons.add),
      ),
    );
  }
}