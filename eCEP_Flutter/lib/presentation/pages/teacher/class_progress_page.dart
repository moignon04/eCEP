// lib/presentation/pages/teacher/class_progress_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../app/extension/color.dart';
import '../../../app/data/models/user_model.dart';
import '../../widgets/teacher/teacher_bottom_nav.dart';
import '../../widgets/teacher/student_progress_card.dart';
import '../../widgets/teacher/progress_chart.dart';
import 'student_detail_page.dart';

class ClassProgressPage extends StatefulWidget {
  const ClassProgressPage({Key? key}) : super(key: key);

  @override
  _ClassProgressPageState createState() => _ClassProgressPageState();
}

class _ClassProgressPageState extends State<ClassProgressPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Mock class data
  final String className = 'CM2-A';
  final int classSize = 28;

  // Mock data for subject filter
  final List<String> subjects = [
    'Tous',
    'Mathématiques',
    'Français',
    'Histoire-Géographie',
    'Sciences',
  ];
  String _selectedSubject = 'Tous';

  // Mock chart data
  final Map<String, double> subjectScores = {
    'Mathématiques': 72.5,
    'Français': 80.2,
    'Histoire-Géographie': 68.7,
    'Sciences': 77.9,
  };

  // Mock students data
  final List<Map<String, dynamic>> students = [
    {
      'id': 1,
      'firstName': 'Lucas',
      'lastName': 'Dupont',
      'avatar': 'assets/avatars/boy1.png',
      'completedExercises': 28,
      'averageScore': 78.5,
    },
    {
      'id': 2,
      'firstName': 'Emma',
      'lastName': 'Martin',
      'avatar': 'assets/avatars/girl1.png',
      'completedExercises': 32,
      'averageScore': 85.0,
    },
    {
      'id': 3,
      'firstName': 'Noah',
      'lastName': 'Petit',
      'avatar': 'assets/avatars/boy2.png',
      'completedExercises': 18,
      'averageScore': 62.5,
    },
    {
      'id': 4,
      'firstName': 'Chloé',
      'lastName': 'Dubois',
      'avatar': 'assets/avatars/girl2.png',
      'completedExercises': 25,
      'averageScore': 75.0,
    },
    {
      'id': 5,
      'firstName': 'Louis',
      'lastName': 'Bernard',
      'avatar': 'assets/avatars/boy3.png',
      'completedExercises': 15,
      'averageScore': 58.0,
    },
    {
      'id': 6,
      'firstName': 'Inès',
      'lastName': 'Thomas',
      'avatar': 'assets/avatars/girl3.png',
      'completedExercises': 30,
      'averageScore': 90.5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return students.where((student) {
      final fullName = '${student['firstName']} ${student['lastName']}'.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return fullName.contains(searchLower);
    }).toList()
      ..sort((a, b) => _selectedSubject == 'À revoir'
          ? a['averageScore'].compareTo(b['averageScore'])
          : b['averageScore'].compareTo(a['averageScore']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Classe $className',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMedium,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Vue d\'ensemble'),
            Tab(text: 'Élèves'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Vue d'ensemble tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Classe $className',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$classSize élèves',
                          style: TextStyle(
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem('Note moyenne', '${subjectScores.values.reduce((a, b) => a + b) / subjectScores.length}%'),
                            _buildStatItem('Élèves en difficulté', '${(students.where((s) => s['averageScore'] < 60).length)}'),
                            _buildStatItem('Exercices terminés', '${students.fold<int>(0, (sum, s) => sum + s['completedExercises'])}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Performance par matière',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                SubjectProgressChart(
                  subjectScores: subjectScores,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Meilleurs élèves',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _tabController.animateTo(1);
                      },
                      child: Text(
                        'Voir tous',
                        style: TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Top 3 students
                ...List.generate(
                  _filteredStudents.length > 3 ? 3 : _filteredStudents.length,
                      (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: StudentProgressCard(
                      name: '${_filteredStudents[index]['firstName']} ${_filteredStudents[index]['lastName']}',
                      avatar: _filteredStudents[index]['avatar'],
                      completedExercises: _filteredStudents[index]['completedExercises'],
                      averageScore: _filteredStudents[index]['averageScore'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentDetailPage(
                              studentId: _filteredStudents[index]['id'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Élèves tab
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un élève',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.textLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.textLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Subject filter chips
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          FilterChip(
                            label: Text('À revoir'),
                            selected: _selectedSubject == 'À revoir',
                            onSelected: (selected) {
                              setState(() {
                                _selectedSubject = selected ? 'À revoir' : 'Tous';
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.warning.withOpacity(0.3),
                            checkmarkColor: AppColors.warning,
                            labelStyle: TextStyle(
                              color: _selectedSubject == 'À revoir'
                                  ? AppColors.warning
                                  : AppColors.textMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ...subjects.map((subject) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(subject),
                              selected: _selectedSubject == subject,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSubject = selected ? subject : 'Tous';
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AppColors.primary.withOpacity(0.3),
                              checkmarkColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: _selectedSubject == subject
                                    ? AppColors.primary
                                    : AppColors.textMedium,
                              ),
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filteredStudents.isEmpty
                    ? Center(
                  child: Text(
                    'Aucun élève ne correspond à votre recherche',
                    style: TextStyle(color: AppColors.textMedium),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = _filteredStudents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: StudentProgressCard(
                        name: '${student['firstName']} ${student['lastName']}',
                        avatar: student['avatar'],
                        completedExercises: student['completedExercises'],
                        averageScore: student['averageScore'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailPage(
                                studentId: student['id'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: TeacherBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index != 1) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMedium,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}