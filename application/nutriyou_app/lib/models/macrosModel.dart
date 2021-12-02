class MacrosData{
  final int userId;
  final DateTime userDia;
  final double userDiaKcal;
  final double userDiaAgua;
  final double userDiaCarbs;
  final double userDiaGord;
  final double userDiaProt;
  final double configKcaldia;
  final double configAguadia;
  final double configCarbsdia;
  final double configGorddia;
  final double configProtdia;

  MacrosData({
    this.userId, this.userDia, this.userDiaKcal, this.userDiaAgua, this.userDiaCarbs, this.userDiaGord, this.userDiaProt, this.configKcaldia, this.configAguadia, this.configCarbsdia, this.configGorddia, this.configProtdia,
  });

  factory MacrosData.fromJson(Map<String, dynamic> json) {
    return MacrosData(
      configKcaldia: json["userConfigKcal"] == null ? null : json["userConfigKcal"].toDouble(),
      configProtdia: json["userConfigProt"] == null ? null : json["userConfigProt"].toDouble(),
      configCarbsdia: json["userConfigCarb"] == null ? null : json["userConfigCarb"].toDouble(),
      configGorddia: json["userConfigGord"] == null ? null : json["userConfigGord"].toDouble(),
      userDiaKcal: json["userDiaKcal"] == null ? 0 : json["userDiaKcal"].toDouble(),
      userDiaProt: json["userDiaProt"] == null ? 0 : json["userDiaProt"].toDouble(),
      userDiaCarbs: json["userDiaCarb"] == null ? 0 : json["userDiaCarb"].toDouble(),
      userDiaGord: json["userDiaGord"] == null ? 0 : json["userDiaGord"].toDouble(),
    );
  }

}

class MacrosMessage{
  final bool error;
  final String message;
  final MacrosData data;

  MacrosMessage({this.error, this.message, this.data});

  factory MacrosMessage.fromJson(Map<String, dynamic> json) {
    return MacrosMessage(
      error: json['error'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
            ? MacrosData.fromJson(json['data'])
            : null,
    );
  }

}