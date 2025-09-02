import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/person.dart';

class PersonDetailPage extends StatefulWidget {
  final Person person;
  const PersonDetailPage({super.key, required this.person});

  @override
  State<PersonDetailPage> createState() => _PersonDetailPageState();
}

class _PersonDetailPageState extends State<PersonDetailPage> {
  Person? parent;
  List<Person> children = [];

  @override
  void initState() {
    super.initState();
    _loadRelations();
  }

  Future<void> _loadRelations() async {
    if (widget.person.parentId != null) {
      parent = await DatabaseHelper.instance.getPersonById(widget.person.parentId!);
    }
    children = await DatabaseHelper.instance.getChildrenOf(widget.person.id!);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.person.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                const Text('الاسم: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.person.name),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('المهنة: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.person.job ?? 'غير محدد'),
              ],
            ),
            const SizedBox(height: 8),
            const Text('نبذة:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.person.bio ?? 'لا يوجد'),
            const Divider(height: 32),
            Row(
              children: [
                const Text('الأب: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(parent?.name ?? '—'),
              ],
            ),
            const SizedBox(height: 12),
            const Text('الأبناء:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (children.isEmpty) const Text('لا يوجد أبناء'),
            ...children.map((c) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c.name),
                  subtitle: Text(c.job ?? 'بدون مهنة'),
                )),
          ],
        ),
      ),
    );
  }
}