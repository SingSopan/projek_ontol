// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CandidateAdapter extends TypeAdapter<Candidate> {
  @override
  final int typeId = 0;

  @override
  Candidate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Candidate(
      name: fields[0] as String,
      vote: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Candidate obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.vote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CandidateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
