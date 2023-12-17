import 'package:image_picker/image_picker.dart';

pickImage(ImageSource imageSource) async {
  final ImagePicker _imgPicker = ImagePicker();
  XFile? _file = await _imgPicker.pickImage(source: imageSource);
  if (_file != null) {
    return await _file.readAsBytes();
  }
  print("No Img select");
}


