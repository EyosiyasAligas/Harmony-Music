abstract class AbstractAuthRemoteDataSource {
  Future<Map<String, dynamic>> signInWithSoundCloud();

  Future<void> signOut();
}