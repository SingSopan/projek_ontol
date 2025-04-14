import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';

part 'main.g.dart';

@HiveType(typeId: 0)
class Candidate extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int vote;

  Candidate({required this.name, required this.vote});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(CandidateAdapter());
  await Hive.openBox<Candidate>('candidates');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Count',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      home: const MyHomePage(title: '2024 Ganti Presiden'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final TextEditingController nameController = TextEditingController();
  late Box<Candidate> candidateBox;

  @override
  void initState() {
    super.initState();
    candidateBox = Hive.box<Candidate>('candidates');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void _addCandidate(String name) {
    final newCandidate = Candidate(name: name, vote: 0);
    candidateBox.add(newCandidate);
    setState(() {});
  }

  void _updateCandidate(int index, String name) {
    final candidate = candidateBox.getAt(index);
    if (candidate != null) {
      candidate.name = name;
      candidate.save();
      setState(() {});
    }
  }

  void _deleteCandidate(int index) {
    candidateBox.deleteAt(index);
    setState(() {});
  }

  void _voteCandidate(int index) {
    final candidate = candidateBox.getAt(index);
    if (candidate != null) {
      candidate.vote += 1;
      candidate.save();
      setState(() {});
    }
  }

  void _showEditDialog(int index) {
    final candidate = candidateBox.getAt(index);
    if (candidate == null) return;
    nameController.text = candidate.name;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Candidate"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _updateCandidate(index, nameController.text);
              Navigator.of(context).pop();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    nameController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Candidate"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addCandidate(nameController.text);
              Navigator.of(context).pop();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bokbok.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 150,
                  height: 150,
                  color: Colors.white,
                  child: Image.asset('assets/pak-joko.png'),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                  child: const Icon(
                    Icons.account_balance_outlined,
                    color: Colors.greenAccent,
                    size: 70,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  color: Colors.black26,
                  child: const Text(
                    'quick count pilpres:',
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '$_counter',
                  style: const TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'List Orang penting:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 200,
                    child: ValueListenableBuilder(
                      valueListenable: candidateBox.listenable(),
                      builder: (context, Box<Candidate> box, _) {
                        if (box.isEmpty) return const Text("No data");
                        final totalVotes = box.values.fold<int>(0, (sum, c) => sum + c.vote);
                        return PieChart(
                          PieChartData(
                            sections: box.values.map((candidate) {
                              final percent = totalVotes == 0 ? 0 : candidate.vote / totalVotes * 100;
                              return PieChartSectionData(
                                value: candidate.vote.toDouble(),
                                title: '${candidate.name} (${percent.toStringAsFixed(1)}%)',
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: candidateBox.listenable(),
                  builder: (context, Box<Candidate> box, _) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        final candidate = box.getAt(index);
                        if (candidate == null) return const SizedBox.shrink();
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: ListTile(
                            title: Text(candidate.name),
                            subtitle: Text('Total Sogokan: ${candidate.vote}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.how_to_vote),
                                  onPressed: () => _voteCandidate(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditDialog(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteCandidate(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _decrementCounter,
                child: const Icon(Icons.remove),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20.0),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _incrementCounter,
                child: const Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
