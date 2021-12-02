class FormValidator {
  static FormValidator _instance;
 
  factory FormValidator() => _instance ??= new FormValidator._();
 
  FormValidator._();
 
  String validatePassword(String value) {
    String patttern = r'(^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.isEmpty) {
      return "Necessário inserir sua senha";
    } else if (value.length < 8) {
      return "Mínimo de 8 caracteres";
    } else if (!regExp.hasMatch(value)) {
      return "A senha precisa de pelo menos uma letra maiúscula, \numa minúscula e um número";
    }
    return null;
  }

  String confirmPassword(String pass1, pass2) {
    if (pass1.isEmpty) {
      return "Digite sua senha";
    } else if (pass2 != pass1) {
      return "Senhas não coincidem";
    }
    return null;
  }
 
  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.isEmpty) {
      return "Necessário inserir o seu e-mail";
    } else if (!regExp.hasMatch(value)) {
      return "E-mail inválido";
    } else {
      return null;
    }
  }
}