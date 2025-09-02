import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/person.dart';

class AddPersonPage extends StatefulWidget {
  const AddPersonPage({super.key});

  @override
  State<AddPersonPage> createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();
  final _bioController = TextEditingController();

  List<Person> _allPersons = [];
  Person? _selectedParent;

  @override
  void initState() {
    super.initState();
    _loadParents();
  }

  Future<void> _loadParents() async {
    _allPersons = await DatabaseHelper.instance.getAllPersons();
    setState(() {});
  }

  Future<void> _savePerson() async {
    if (!_formKey.currentState!.validate()) return;

    await DatabaseHelper.instance.insertPerson(
      Person(
        name: _nameController.text.trim(),
        job: _jobController.text.trim().isEmpty ? null : _jobController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        parentId: _selectedParent?.id,
      ),
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة شخص')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _jobController,
                decoration: const InputDecoration(labelText: 'المهنة (اختياري)'),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'نبذة (اختياري)'),
                maxLines: 3,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Person>(
                value: _selectedParent,
                items: _allPersons.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.name, textDirection: TextDirection.rtl),
                )).toList(),
                onChanged: (newParent) => setState(() => _selectedParent = newParent),
                decoration: const InputDecoration(labelText: 'اختر الأب (اختياري)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _savePerson, child: const Text('حفظ')),
            ],
          ),
        ),
      ),
    );
  }
}