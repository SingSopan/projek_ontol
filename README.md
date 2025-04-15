# projek_ontol

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

LINK YOUTUBE : https://www.youtube.com/watch?v=IVZ2aYBTqF0

## TAHAPAN Pemrograman

** Menambahkan dependensi di pubspec.yaml **
``
dependencies:
flutter:
sdk: flutter
hive: ^2.2.3
hive_flutter: ^1.1.0
path_provider: ^2.0.15
fl_chart: ^0.63.0

dev_dependencies:
hive_generator: ^2.0.1
build_runner: ^2.4.6
``

** Membuat model hive **
Buat model Hive: candidate.dart
import 'package:hive/hive.dart';

part 'candidate.g.dart';

@HiveType(typeId: 0)
class Candidate extends HiveObject {
@HiveField(0)
String name;

@HiveField(1)
int vote;

Candidate({required this.name, required this.vote});
}
Generate file Hive dengan command:

flutter pub run build_runner build --delete-conflicting-outputs
Inisialisasi Hive di main.dart
Tambahkan:

void main() async {
WidgetsFlutterBinding.ensureInitialized();
final appDocumentDir = await getApplicationDocumentsDirectory();
Hive.init(appDocumentDir.path);
Hive.registerAdapter(CandidateAdapter());
await Hive.openBox<Candidate>('candidates');
runApp(const MyApp());
}

Pada Main tambahkan
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'candidate.dart';

modifikasi candidate menjadi hive box

late Box<Candidate> candidateBox;

@override
void initState() {
super.initState();
candidateBox = Hive.box<Candidate>('candidates');
}

Ganti semua manipulasi list dengan Hive
Tambah kandidat:

void _addCandidate(String name) {
final newCandidate = Candidate(name: name, vote: 0);
candidateBox.add(newCandidate);
setState(() {});
}

Update kandidat:

void _updateCandidate(int index, String name) {
final candidate = candidateBox.getAt(index);
if (candidate != null) {
candidate.name = name;
candidate.save();
setState(() {});
}
}
Delete kandidat:

void _deleteCandidate(int index) {
candidateBox.deleteAt(index);
setState(() {});
}
Vote kandidat:

void _voteCandidate(int index) {
final candidate = candidateBox.getAt(index);
if (candidate != null) {
candidate.vote += 1;
candidate.save();
setState(() {});
}
}