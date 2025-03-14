import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/data/models/lesson.dart';
import 'package:client/app/extension/color.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CoursePlayerController extends GetxController {
  final lesson = Lesson(
    id: 0,
    title: '',
    type: '',
    duration: 0,
    content: '',
    isCompleted: false,
  ).obs;

  final isLoading = true.obs;
  final isBookmarked = false.obs;
  final isPlaying = false.obs;
  final isVideoInitialized = false.obs;
  final isAudioInitialized = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;

  VideoPlayerController? videoController;
  VideoPlayerController? audioController;
  ChewieController? chewieController;

  String courseName = '';
  Color courseColor = AppColors.primary;
  bool hasPreviousLesson = false;
  bool hasNextLesson = false;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final args = Get.arguments;
      lesson.value = args['lesson'];
      courseName = args['courseName'] ?? '';
      courseColor = args['courseColor'] ?? AppColors.primary;
      hasPreviousLesson = args['hasPrevious'] ?? false;
      hasNextLesson = args['hasNext'] ?? false;

      // Vérifier si la leçon est déjà en favoris
      checkBookmarkStatus();

      // Initialiser le média selon le type de leçon
      initializeMedia();
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    videoController?.dispose();
    audioController?.dispose();
    chewieController?.dispose();
    super.onClose();
  }

  void checkBookmarkStatus() {
    // Implémenter la vérification dans le stockage local
    // Exemple simplifié:
    isBookmarked.value = false;
  }

  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
    // Sauvegarder l'état dans le stockage local
  }

  void initializeMedia() {
    if (lesson.value.type.toLowerCase() == 'video') {
      initializeVideo();
    } else if (lesson.value.type.toLowerCase() == 'audio') {
      initializeAudio();
    }
  }

  void initializeVideo() {
    // Dans une application réelle, vous utiliseriez l'URL ou le fichier local
    videoController = VideoPlayerController.asset('assets/videos/sample.mp4');
    videoController!.initialize().then((_) {
      chewieController = ChewieController(
        videoPlayerController: videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Erreur de chargement de la vidéo',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
      isVideoInitialized.value = true;
    });
  }

  void initializeAudio() {
    // Dans une application réelle, vous utiliseriez l'URL ou le fichier local
    audioController = VideoPlayerController.asset('assets/audio/sample.mp3');
    audioController!.initialize().then((_) {
      duration.value = audioController!.value.duration;

      // Mettre à jour la position pendant la lecture
      audioController!.addListener(() {
        position.value = audioController!.value.position;
        isPlaying.value = audioController!.value.isPlaying;
      });

      isAudioInitialized.value = true;
    });
  }

  void togglePlay() {
    if (audioController == null) return;

    if (isPlaying.value) {
      audioController!.pause();
    } else {
      audioController!.play();
    }
    isPlaying.value = !isPlaying.value;
  }

  void seekTo(int seconds) {
    if (audioController == null) return;
    audioController!.seekTo(Duration(seconds: seconds));
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void launchInteractiveContent() {
    // Implémenter l'ouverture de contenu interactif
    Get.toNamed('/interactive-content', arguments: lesson.value);
  }

  void goToPreviousLesson() {
    // Implémenter la navigation vers la leçon précédente
    Get.back(result: 'previous');
  }

  void completeAndContinue() {
    // Marquer la leçon comme complétée
    if (!lesson.value.isCompleted) {
      // Appel API pour marquer la leçon comme complétée
      // Exemple simplifié:
      final updatedLesson = Lesson(
        id: lesson.value.id,
        title: lesson.value.title,
        type: lesson.value.type,
        duration: lesson.value.duration,
        content: lesson.value.content,
        isCompleted: true,
      );
      lesson.value = updatedLesson;
    }

    // Passer à la leçon suivante ou revenir à la liste des leçons
    if (hasNextLesson) {
      Get.back(result: 'next');
    } else {
      Get.back(result: 'completed');
    }
  }
}