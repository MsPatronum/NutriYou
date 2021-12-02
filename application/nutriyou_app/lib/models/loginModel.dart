class LoginData{
  final int id;
  final String email;
  final String token;
  final String nome;

  LoginData({this.id, this.email, this.token, this.nome});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      id: json['id'] == null ? "0" : json['id'],
      email: json['email'] == null ? "0" : json['email'],
      token : json['token'] == null ? "0" : json['token'],
      nome : json['nome'] == null ? "0" : json['nome'],
    );
  }
}

class LoginMessage {
  final bool error;
  final String message;
  LoginData data;
 
  LoginMessage({this.error, this.message, this.data});
 
  factory LoginMessage.fromJson(Map<String, dynamic> json) {
    return LoginMessage(
      error: json['error'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
            ? LoginData.fromJson(json['data'])
            : null,
    );
  }
}