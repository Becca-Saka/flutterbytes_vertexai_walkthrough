import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class FilePickerService {
  final imagePicker = ImagePicker();
  final filePicker = FilePicker.platform;

  Future<List<CustomFile>?> pickFile() async {
    final file = await filePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (file?.files != null) {
      file!.files.removeWhere((element) => element.path == null);
      final mappedFiles = file.files.map((e) {
        XFileType type = XFileType.fromPath(e.path!);
        final fileMimeType = getMimeType(e.path!, type);
        final extension = getExtension(e.path!);
        return CustomFile(basename(file.files.first.path!), e.path!, type,
            e.xFile, fileMimeType, extension);
      }).toList();
      return mappedFiles;
    }

    return [];
  }

  Future<bool?> clearFiles() async {
    return await filePicker.clearTemporaryFiles();
  }
}

class CustomFile {
  final String name;
  final String path;
  final XFile file;
  final XFileType type;
  final String mimeType;
  final String extension;
  const CustomFile(
    this.name,
    this.path,
    this.type,
    this.file,
    this.mimeType,
    this.extension,
  );
}

enum XFileType {
  image('image', 'image/jpeg'),
  pdf('pdf', 'application/pdf'),
  audio('audio', 'audio/mp3');

  final String value;
  final String mimeType;
  const XFileType(this.value, this.mimeType);

  factory XFileType.fromPath(String path) {
    final extension = path.split('.').last;
    if (extension == 'pdf') {
      return XFileType.pdf;
    }
    if (extension == 'mp3') {
      return XFileType.audio;
    }
    return XFileType.image;
  }
}

String getMimeType(String name, XFileType type) {
  if (type == XFileType.audio) {
    return 'audio/${getExtension(name)}';
  }
  return type == XFileType.pdf ? 'application/pdf' : 'image/jpeg';
  // : 'image/${getExtension(name)}';
}

String getExtension(String path) {
  return path.split('.').last.toLowerCase();
}
