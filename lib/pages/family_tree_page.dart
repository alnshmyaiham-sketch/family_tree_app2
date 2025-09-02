import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../db/database_helper.dart';
import '../models/person.dart';
import 'person_detail_page.dart';

class FamilyTreePage extends StatefulWidget {
  final Person rootPerson;
  const FamilyTreePage({super.key, required this.rootPerson});

  @override
  State<FamilyTreePage> createState() => _FamilyTreePageState();
}

class _FamilyTreePageState extends State<FamilyTreePage> {
  final Graph graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    super.initState();
    builder
      ..siblingSeparation = (20)
      ..levelSeparation = (40)
      ..subtreeSeparation = (30)
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
    _buildGraph(widget.rootPerson);
  }

  Future<void> _buildGraph(Person root) async {
    final allPersons = await DatabaseHelper.instance.getAllPersons();
    final Map<int, Person> personMap = {for (var p in allPersons) p.id!: p};

    graph.nodes.clear();
    final Node rootNode = Node.Id(root.id);
    graph.addNode(rootNode);

    void addChildren(Node parentNode, Person parentPerson) {
      final children = allPersons.where((p) => p.parentId == parentPerson.id);
      for (var child in children) {
        final childNode = Node.Id(child.id);
        graph.addNode(childNode);
        graph.addEdge(parentNode, childNode);
        addChildren(childNode, child);
      }
    }

    addChildren(rootNode, root);
    if (mounted) setState(() {});
  }

  Widget nodeWidget(Person person) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PersonDetailPage(person: person)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (person.job != null) Text(person.job!, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('شجرة ${widget.rootPerson.name}')),
      body: FutureBuilder<List<Person>>(
        future: DatabaseHelper.instance.getAllPersons(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allPersons = snapshot.data!;
          final personMap = {for (var p in allPersons) p.id!: p};

          return InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.01,
            maxScale: 5.0,
            child: GraphView(
              graph: graph,
              algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
              builder: (Node node) {
                final int id = node.key!.value as int;
                final person = personMap[id]!;
                return nodeWidget(person);
              },
            ),
          );
        },
      ),
    );
  }
}