import 'package:arabasatis/screens/admin_dashboard_screen.dart';
import 'package:arabasatis/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:arabasatis/services/api_service.dart';


class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _isAdmin = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  // Admin paneline erişim kontrolü
  Future<void> _checkAdminAccess() async {
    try {
      bool result = await ApiService().checkAdminPanelAccess();
      setState(() {
        _isAdmin = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      // Eğer admin değilse login sayfasına yönlendirme
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  void _goToAdminDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
    );
  }

  /*void _viewUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminUsersScreen()),
    );
  }*/

  /*void _viewLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminLogsScreen()),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Paneli')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isAdmin
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Admin paneline başarılı şekilde giriş yaptınız.',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _goToAdminDashboard,
                    child: Text('Admin Dashboard'),
                  ),
                  /*SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _viewUsers,
                    child: Text('Kullanıcıları Görüntüle'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _viewLogs,
                    child: Text('Logları Görüntüle'),
                  ),*/
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage.isEmpty
                        ? 'Admin paneline erişim sağlanamadı.'
                        : _errorMessage),
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
      ),
    );
  }
}
