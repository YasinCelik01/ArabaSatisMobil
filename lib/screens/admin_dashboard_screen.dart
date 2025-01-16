import 'package:flutter/material.dart';
import 'package:arabasatis/services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _pendingCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingCars();
  }

  // Onay bekleyen araçları yükle
  Future<void> _loadPendingCars() async {
    try {
      final cars = await _apiService.getPendingCars();
      setState(() {
        _pendingCars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kapat'),
            ),
          ],
        ),
      );
    }
  }

  // Araba onayla
  Future<void> _approveCar(int carId) async {
    try {
      final message = await _apiService.updateCarStatus(carId, 1);
      _showSuccessDialog(message);
      _loadPendingCars();
    } catch (e) {
      _showErrorDialog('Onay işlemi sırasında bir hata oluştu: $e');
    }
  }

  // Araba reddet
  Future<void> _rejectCar(int carId) async {
    try {
      final message = await _apiService.updateCarStatus(carId, 0);
      _showSuccessDialog(message);
      _loadPendingCars();
    } catch (e) {
      _showErrorDialog('Reddetme işlemi sırasında bir hata oluştu: $e');
    }
  }

  // Başarı mesajı
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Başarı'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Hata mesajı
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _pendingCars.length,
              itemBuilder: (context, index) {
                final car = _pendingCars[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('${car['Marka']} - ${car['Model']}'),
                    subtitle: Text('Yıl: ${car['Yil']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => _approveCar(car['ArabaId']),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => _rejectCar(car['ArabaId']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
