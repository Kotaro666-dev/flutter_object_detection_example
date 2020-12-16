import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_object_detection_example/data/entity/recognition.dart';
import 'package:flutter_object_detection_example/data/model/ml_camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ObjectDetectionPage extends StatelessWidget {
  static String routeName = '/object_detection';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Detection'),
      ),
      body: CameraView(),
    );
  }
}

class CameraView extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final recognitions = useProvider(recognitionsProvider);
    final size = MediaQuery.of(context).size;
    final mlCamera = useProvider(mlCameraProvider(size));
    return mlCamera.when(
      data: (mlCamera) {
        return Stack(
          children: [
            AspectRatio(
              aspectRatio: mlCamera.cameraController.value.aspectRatio,
              child: CameraPreview(
                mlCamera.cameraController,
              ),
            ),
            buildBoxes(
              recognitions.state,
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(
        child: Text(
          err.toString(),
        ),
      ),
    );
  }

  Widget buildBoxes(
    List<Recognition> recognitions,
  ) {
    if (recognitions == null || recognitions.isEmpty) {
      return const SizedBox();
    }
    return Stack(
      children: recognitions.map((result) {
        return BoundingBox(result);
      }).toList(),
    );
  }
}

class BoundingBox extends HookWidget {
  const BoundingBox(
    this.result,
  );
  final Recognition result;

  @override
  Widget build(BuildContext context) {
    final odController = useProvider(
      objectDetectionControllerProvider,
    );
    final renderLocation = result.getRenderLocation(
      odController.mlCamera.actualPreviewSize,
      odController.mlCamera.ratio,
    );
    return Positioned(
      left: renderLocation.left,
      top: renderLocation.top,
      width: renderLocation.width,
      height: renderLocation.height,
      child: Container(
        width: renderLocation.width,
        height: renderLocation.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
            width: 3,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(2),
          ),
        ),
        child: buildBoxLabel(result),
      ),
    );
  }

  Align buildBoxLabel(Recognition result) {
    return Align(
      alignment: Alignment.topLeft,
      child: FittedBox(
        child: ColoredBox(
          color: Colors.blue,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.label,
              ),
              Text(
                ' ${result.score.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
