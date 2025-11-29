import 'dart:io';

// 설정: 내용을 추출할 파일 확장자 및 제외할 폴더
const Set<String> allowedExtensions = {'.dart', '.yaml', '.json', '.xml', '.gradle'};
const Set<String> ignoreDirs = {'.git', '.idea', '.dart_tool', 'build', 'android', 'ios', 'web', 'linux', 'macos', 'windows', 'test'};

void main() async {
  final currentDir = Directory.current;
  final outputFile = File('project_context.txt');
  
  print('Extracting project from: ${currentDir.path}');
  
  final buffer = StringBuffer();
  
  // 1. 트리 구조 생성
  buffer.writeln('### [Project Structure] ###');
  await _generateTree(currentDir, buffer, currentDir.path);
  buffer.writeln();
  
  // 2. 파일 내용 추출
  buffer.writeln('### [File Contents] ###');
  await _extractContents(currentDir, buffer); // 여기서 buffer를 전달함
  
  // 3. 파일 저장
  await outputFile.writeAsString(buffer.toString());
  
  print('Done! All data saved to "project_context.txt"');
  print('Please upload this file to the AI.');
}

Future<void> _generateTree(Directory dir, StringBuffer buffer, String rootPath) async {
  final List<FileSystemEntity> entities = await dir.list().toList();
  
  // 폴더 우선, 그 다음 파일 순으로 정렬
  entities.sort((a, b) {
    if (a is Directory && b is File) return -1;
    if (a is File && b is Directory) return 1;
    return a.path.compareTo(b.path);
  });

  for (var entity in entities) {
    final name = entity.uri.pathSegments.where((e) => e.isNotEmpty).last;
    
    // 제외 폴더 건너뛰기
    if (entity is Directory && ignoreDirs.contains(name)) continue;
    if (name.startsWith('.')) continue; // 숨김 파일 건너뛰기

    final relativePath = entity.path.replaceFirst(rootPath, '');
    // 들여쓰기 계산
    final level = relativePath.split(Platform.pathSeparator).length - 1;
    final indent = '    ' * level;
    
    if (entity is Directory) {
      buffer.writeln('$indent$name/');
      await _generateTree(entity, buffer, rootPath);
    } else {
      buffer.writeln('$indent$name');
    }
  }
}

// [수정됨] StringBuffer buffer 매개변수 추가
Future<void> _extractContents(Directory dir, StringBuffer buffer) async {
  final List<FileSystemEntity> entities = await dir.list().toList();
  
  for (var entity in entities) {
    final name = entity.uri.pathSegments.where((e) => e.isNotEmpty).last;
    
    if (entity is Directory) {
      if (ignoreDirs.contains(name)) continue;
      if (name.startsWith('.')) continue;
      // 재귀 호출 시에도 buffer 전달
      await _extractContents(entity, buffer);
    } else if (entity is File) {
      // 확장자 확인
      bool isAllowed = false;
      for (var ext in allowedExtensions) {
        if (name.endsWith(ext)) {
          isAllowed = true;
          break;
        }
      }
      
      if (isAllowed) {
        try {
          final content = await entity.readAsString();
          buffer.writeln('\n--- START OF FILE: ${entity.path} ---');
          buffer.writeln(content);
          buffer.writeln('--- END OF FILE: ${entity.path} ---\n');
        } catch (e) {
          // 바이너리 파일이나 읽기 오류는 무시
        }
      }
    }
  }
}