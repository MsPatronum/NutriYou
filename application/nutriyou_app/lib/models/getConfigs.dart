// To parse this JSON data, do
//
//     final configModel = configModelFromJson(jsonString);

import 'dart:convert';

ConfigModel configModelFromJson(String str) => ConfigModel.fromJson(json.decode(str));

String configModelToJson(ConfigModel data) => json.encode(data.toJson());

class ConfigModel {
    ConfigModel({
        this.error,
        this.message,
        this.data,
    });

    bool error;
    String message;
    Data data;

    factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        error: json["error"] == null ? null : json["error"],
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "error": error == null ? null : error,
        "message": message == null ? null : message,
        "data": data == null ? null : data.toJson(),
    };
}

class Data {
    Data({
        this.usuarioId,
        this.usuarioPermitProfissional,
    });

    int usuarioId;
    int usuarioPermitProfissional;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        usuarioId: json["usuario_id"] == null ? null : json["usuario_id"],
        usuarioPermitProfissional: json["usuario_permit_profissional"] == null ? null : json["usuario_permit_profissional"],
    );

    Map<String, dynamic> toJson() => {
        "usuario_id": usuarioId == null ? null : usuarioId,
        "usuario_permit_profissional": usuarioPermitProfissional == null ? null : usuarioPermitProfissional,
    };
}
