library flutter_easy_picker;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class FlutterEasyPicker extends StatefulWidget {
  final int? crossAxisCount;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;
  final imgQuality;
  FlutterEasyPicker({
    super.key,
    this.crossAxisCount,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.imgQuality,
    this.childAspectRatio,
  });

  @override
  State<FlutterEasyPicker> createState() => _FlutterEasyPickerState();
}

class _FlutterEasyPickerState extends State<FlutterEasyPicker> {
  var lstImgPath = <Map<String, dynamic>>[];

  void onSelected({required ImageSource source, bool? isMultiple}) async {
    final _picker = ImagePicker();
    try {
      var file;
      if (source == ImageSource.camera) {
        file = await _picker.pickImage(
          source: source,
          imageQuality: widget.imgQuality ?? 100,
        );
      }
      if (source == ImageSource.gallery) {
        if (isMultiple == true) {
          file = await _picker.pickMultiImage(
            imageQuality: widget.imgQuality ?? 100,
          );
        } else {
          file = await _picker.pickImage(
            source: source,
            imageQuality: widget.imgQuality ?? 100,
          );
        }
      }

      if (file != null) {
        lstImgPath.add({'image': file.path});
        setState(() {});
      }
    } on PlatformException catch (e) {
      // Handle the exception here
      print("PlatformException: ${e.message}");
    } catch (e) {
      // Handle other exceptions here
      print("Other Exception: $e");
    }
  }

  void removeImage(int index) {
    if (lstImgPath.isEmpty) return;
    lstImgPath.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          /// adding gridview builder to display image get from file
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              itemCount: lstImgPath.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount ?? 3,
                crossAxisSpacing: widget.crossAxisSpacing ?? 4.0,
                mainAxisSpacing: widget.mainAxisSpacing ?? 4.0,
                childAspectRatio: widget.childAspectRatio ?? 1.0,
              ),
              itemBuilder: (context, index) {
                if (lstImgPath.length == index) {
                  /// add some widget that can click to select images
                  return GestureDetector(
                    onTap: () {
                      onSelected(source: ImageSource.gallery);
                    },
                    child: Container(
                      height: size.height * 0.5,
                      width: size.width * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 50,
                      ),
                    ),
                  );
                }
                return Stack(
                  children: [
                    Container(
                      height: size.height * 0.5,
                      width: size.width * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoView(
                                imageProvider: FileImage(
                                  File(
                                    lstImgPath[index]['image'],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Image.file(
                          File(lstImgPath[index]['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          removeImage(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
