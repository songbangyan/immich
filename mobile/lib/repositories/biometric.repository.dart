import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/models/auth/biometric_status.model.dart';
import 'package:local_auth/local_auth.dart';

final biometricRepositoryProvider = Provider((ref) => BiometricRepository(LocalAuthentication()));

class BiometricRepository {
  final LocalAuthentication _localAuth;

  const BiometricRepository(this._localAuth);

  Future<BiometricStatus> getStatus() async {
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    final availableBiometric = await _localAuth.getAvailableBiometrics();

    return BiometricStatus(canAuthenticate: canAuthenticate, availableBiometrics: availableBiometric);
  }

  Future<bool> authenticate(String? message) async {
    return _localAuth.authenticate(localizedReason: message ?? 'please_auth_to_access'.tr());
  }
}
