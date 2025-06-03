import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  Timer? _retryTimer;
  bool _isRetrying = false;

  Stream<bool> get connectivityStream => _controller.stream;

  ConnectivityService() {
    _initConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _controller.add(false);
      _scheduleRetry();
    }
  }

  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _updateConnectionStatus(result);
      },
      onError: (error) {
        _controller.add(false);
        _scheduleRetry();
      },
    );
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;
    if (!_controller.isClosed) {
      _controller.add(isConnected);
    }
    
    if (isConnected && _isRetrying) {
      _cancelRetry();
    }
  }

  void _scheduleRetry() {
    if (!_isRetrying) {
      _isRetrying = true;
      _retryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _initConnectivity();
      });
    }
  }

  void _cancelRetry() {
    _isRetrying = false;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _cancelRetry();
    _controller.close();
  }
}
