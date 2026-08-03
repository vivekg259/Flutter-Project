import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_next_app/models/program.dart';
import 'package:excelerate_next_app/providers/program_provider.dart';

void main() {
  group('ProgramProvider published list', () {
    late StreamController<List<Program>> controller;
    late ProgramProvider provider;

    Program program({
      required String id,
      required String title,
      String level = 'Beginner',
      String status = ProgramStatus.open,
      DateTime? publishAt,
      List<String> skills = const [],
    }) => Program(
      id: id,
      title: title,
      description: 'desc',
      instructor: 'Instructor',
      duration: '8 weeks',
      level: level,
      skills: skills,
      status: status,
      publishAt: publishAt,
      createdAt: DateTime(2026, 7, 1),
    );

    setUp(() {
      controller = StreamController<List<Program>>();
      provider = ProgramProvider.fromStream(controller.stream);
    });

    tearDown(() async {
      await controller.close();
      provider.dispose();
    });

    test(
      'publishedPrograms is stable and excludes unpublished programs',
      () async {
        final now = DateTime.now();
        controller.add([
          program(id: 'p1', title: 'Open Program'),
          program(
            id: 'p2',
            title: 'Scheduled Program',
            publishAt: now.add(const Duration(days: 7)),
          ),
          program(
            id: 'p3',
            title: 'Closed Program',
            status: ProgramStatus.closed,
          ),
        ]);
        await Future<void>.delayed(Duration.zero);

        // Published list contains the immediately-available and closed programs
        // but NOT the scheduled future-publish one.
        expect(provider.publishedPrograms.map((p) => p.id), contains('p1'));
        expect(provider.publishedPrograms.map((p) => p.id), contains('p3'));
        expect(
          provider.publishedPrograms.map((p) => p.id),
          isNot(contains('p2')),
        );
      },
    );

    test('search filters do not affect publishedPrograms count', () async {
      controller.add([
        program(id: 'p1', title: 'Flutter Bootcamp', skills: ['Flutter']),
        program(id: 'p2', title: 'Python Data Science', skills: ['Python']),
        program(id: 'p3', title: 'React Web', skills: ['React']),
      ]);
      await Future<void>.delayed(Duration.zero);

      final before = provider.publishedPrograms.length;
      provider.setSearchQuery('flutter');

      // The filtered list shrinks...
      expect(provider.programs.length, 1);
      // ...but the stable published count stays the same.
      expect(provider.publishedPrograms.length, before);
      expect(provider.publishedPrograms.length, 3);
    });

    test('level filter does not affect publishedPrograms', () async {
      controller.add([
        program(id: 'p1', title: 'A', level: 'Beginner'),
        program(id: 'p2', title: 'B', level: 'Advanced'),
      ]);
      await Future<void>.delayed(Duration.zero);

      provider.setLevelFilter('Advanced');
      expect(provider.programs.length, 1);
      expect(provider.publishedPrograms.length, 2);
    });

    test(
      'programs getter applies search + level + published filters',
      () async {
        controller.add([
          program(
            id: 'p1',
            title: 'Flutter Basics',
            level: 'Beginner',
            skills: ['Flutter'],
          ),
          program(
            id: 'p2',
            title: 'Flutter Advanced',
            level: 'Advanced',
            skills: ['Flutter'],
          ),
          program(
            id: 'p3',
            title: 'Kotlin',
            level: 'Beginner',
            skills: ['Kotlin'],
          ),
        ]);
        await Future<void>.delayed(Duration.zero);

        provider.setSearchQuery('flutter');
        provider.setLevelFilter('Beginner');

        expect(provider.programs.map((p) => p.id), ['p1']);
      },
    );
  });
}
