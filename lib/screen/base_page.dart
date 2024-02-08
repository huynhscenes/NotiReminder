import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/notification_manager.dart';
import 'package:flutter_application_1/widgets/settings_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BasePage extends StatefulWidget {
  @override
  BasePageState<BasePage> createState();
}

abstract class BasePageState<T extends BasePage> extends State<T> {
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _items = [];
  int? _notificationInterval;
  bool isAddButtonEnabled = false;
  bool isNotificationActive = false;
  int idValue = DateTime.now().millisecondsSinceEpoch % (2 ^ 31 - 1);

  // These are abstract getters that will be overridden in subclasses.
  String get type;
  String get title;
  String get hintText;
  String get preferenceKey;

  @override
  void initState() {
    super.initState();
    _loadItemsFromPrefs();
  }

  Future<void> _loadItemsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedItems = prefs.getStringList(preferenceKey);
    if (storedItems != null) {
      for (var item in storedItems) {
        var parts = item.split('|');
        _items.add({'id': '${type}_$idValue', 'content': _controller.text});
      }
    }
    setState(() {});
  }

  _saveItemsToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> toStore =
        _items.map((item) => "${item['id']}|${item['content']}").toList();
    await prefs.setStringList(preferenceKey, toStore);
  }

  void _scheduleNotification() async {
    if (_notificationInterval == null) {
      _showDialog("Lỗi", "Vui lòng đặt thời gian thông báo trước.");
      return;
    }

    NotificationManager.cancelAllNotifications();
    // Xáo trộn danh sách
    _items.shuffle();
    if (_items.isNotEmpty) {
      for (int i = 0; i < _items.length; i++) {
        DateTime scheduledTime = DateTime.now()
            .add(Duration(minutes: _notificationInterval! * (i + 1)));

        int itemId = int.parse(_items[i]['id'].split('_')[1]) % (2 ^ 31 - 1);
        NotificationManager.scheduleNotification(
            message: _items[i]['content'],
            scheduledTime: scheduledTime,
            id: itemId,
            type: type == 'vocabulary'
                ? NotificationType.vocabulary
                : NotificationType.grammar); // Truyền tham số type ở đây
      }

      DateTime finalNotificationTime = DateTime.now()
          .add(Duration(minutes: _notificationInterval! * _items.length + 1));

      int finalId = _items.length % (2 ^ 31 - 1);
      NotificationManager.scheduleNotification(
          message:
              "Đã hết tất cả các items trong danh sách. Hãy mở ứng dụng để thiết lập lại.",
          scheduledTime: finalNotificationTime,
          id: finalId + 1,
          type: type == 'vocabulary'
              ? NotificationType.vocabulary
              : NotificationType.grammar); // Truyền tham số type ở đây
    }
    setState(() {
      isNotificationActive = true;
    });
    _showDialog("Thông báo", "Đã bắt đầu gửi thông báo.");
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9ae2de),
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              var result = await showDialog<Map<String, Object>>(
                context: context,
                builder: (BuildContext context) => SettingsDialog(type: type),
              );

              if (result != null && result.containsKey('minutes')) {
                _notificationInterval = result['minutes'] as int;
              }
            },
          )
        ],
      ),
      backgroundColor: Color(0xFF9ae2de),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus(); // Đóng bàn phím khi nhấn ra ngoài
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                maxLength: 130,
                maxLines: 4,
                onChanged: (text) {
                  setState(() {
                    isAddButtonEnabled = text.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: hintText,
                  fillColor: Colors.white,
                  filled: true,
                  border: InputBorder.none, // Loại bỏ đường viền mặc định
                  focusedBorder: InputBorder
                      .none, // Loại bỏ đường viền khi `TextField` được focus
                ),
              ),
            ),
            SizedBox(height: 1.0),
            Padding(
              padding:
                  const EdgeInsets.only(top: 1.0), // nhích nút lên một chút
              child: Container(
                height: 50, // chiều cao của nút
                width: 150, // chiều rộng của nút
                child: ElevatedButton(
                  onPressed: isAddButtonEnabled
                      ? () {
                          setState(() {
                            _items.add({
                              'id':
                                  '${type}_${DateTime.now().millisecondsSinceEpoch}',
                              'content': _controller.text
                            });
                            _controller.clear();
                          });
                          _saveItemsToPrefs();
                        }
                      : null,
                  child: Text("Add"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: isAddButtonEnabled
                        ? Color(0xff9ae2de)
                        : Color(0xffbdbfbf),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // giảm chiều rộng từ cả hai bên
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Card(
                      child: ListTile(
                        title: Text(_items[index]['content']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _controller.text = _items[index]['content'];
                                setState(() {
                                  _items.removeAt(index);
                                });
                                _saveItemsToPrefs();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                });
                                _saveItemsToPrefs();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceAround, // Để có khoảng cách đều giữa các nút
              children: [
                // Nút "Set Thông Báo"
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Container(
                    height: 50,
                    width: 150,
                    child: ElevatedButton(
                      onPressed:
                          isNotificationActive ? null : _scheduleNotification,
                      child: Text("Set Thông Báo"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: isNotificationActive
                            ? Color(0xffbdbfbf)
                            : Color(0xff9ae2de),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ),
                // Nút "Dừng thông báo"
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    height: 50,
                    width: 150,
                    child: ElevatedButton(
                      onPressed: isNotificationActive
                          ? () {
                              NotificationManager.cancelAllNotifications();
                              _showDialog(
                                  "Thông báo", "Đã dừng gửi thông báo.");
                              setState(() {
                                isNotificationActive = false;
                              });
                            }
                          : null,
                      child: Text("Dừng thông báo"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: isNotificationActive
                            ? Color(0xff9ae2de)
                            : Color(0xffbdbfbf),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
