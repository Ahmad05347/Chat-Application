import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _picketImageFile;

  void _pickImage() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _picketImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_picketImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _picketImageFile != null ? FileImage(_picketImageFile!) : null,
        ),
        TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: Text(
              "Add Image",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ))
      ],
    );
  }
}
