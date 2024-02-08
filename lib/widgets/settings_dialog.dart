import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDialog extends StatefulWidget {
  final String type; // 'vocabulary' or 'grammar'

  // Dynamic keys based on type
  String get notificationIntervalKey => "${type}_notification_interval";
  String get repeatNotificationKey => "${type}_repeat_notification";

  SettingsDialog({required this.type});

  Future<int?> getNotificationInterval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(notificationIntervalKey);
  }

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  int? currentInterval;
  bool isRepeat = false;
  bool isValueChanged = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentSettings();
  }

  _getCurrentSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentInterval = await widget.getNotificationInterval();
    controller.text = currentInterval?.toString() ?? "";
    isRepeat = prefs.getBool(widget.repeatNotificationKey) ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Settings for ${widget.type}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Nhập thời gian (phút) của ${widget.type}",
            ),
            onChanged: (value) {
              setState(() {
                isValueChanged = true;
              });
            },
          ),
          SwitchListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lặp lại"),
                SizedBox(height: 4.0),
                Text(
                  "Chú ý: Dùng để lặp lại các thông báo đã được gửi trước đó.",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            value: isRepeat,
            onChanged: (bool value) {
              setState(() {
                isRepeat = value;
              });
            },
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: Text("Set"),
          onPressed: !isValueChanged
              ? null
              : () {
                  _saveNotificationSettings();
                  Navigator.pop(context, {
                    'minutes': int.tryParse(controller.text) ?? 0,
                    'repeat': isRepeat
                  });
                },
        )
      ],
    );
  }

  _saveNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        widget.notificationIntervalKey, int.tryParse(controller.text) ?? 0);
    await prefs.setBool(widget.repeatNotificationKey, isRepeat);
  }
}
