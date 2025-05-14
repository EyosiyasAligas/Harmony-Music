class ApiConstants {
  /// SoundCloud API credentials
  static const String clientId = 'JAquiQKPfTJAM1Mcfm17qazMYW7KdmGa';
  static const String clientSecret = 'a4ea1njVWV9EsMRNPgZTJDrMhTEnG0dQ';
  static const String redirectUri = 'eyosharmonymusic://callback';
  static const List<String> scopes = ['non-expiring'];

  /// Base URLs for the API
  static const String baseUrl = 'https://api.soundcloud.com';

  /// auth URL
  static const String authorise = 'https://secure.soundcloud.com/authorize?display=popup';
  static const String getToken = 'https://secure.soundcloud.com/oauth/token'; // for token grantType = 'authorization_code' for refresh grantType = 'refresh_token'
  static const String signOut = 'https://secure.soundcloud.com/sign-out';

  /// me
  static const String getMe = '/me';

  /// users
  static const String getUsers = '/users';

  /// tracks
  static const String getTracks = '/tracks';

  /// playlists
  static const String getPlaylists = '/playlists';
}
