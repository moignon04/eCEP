import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
Widget BuildSkeleton(double width, double height) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade600,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}