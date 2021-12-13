// To parse this JSON data, do
//
//     final listPatientsModel = listPatientsModelFromJson(jsonString);

import 'dart:convert';

ListPatientsModel listPatientsModelFromJson(String str) => ListPatientsModel.fromJson(json.decode(str));

String listPatientsModelToJson(ListPatientsModel data) => json.encode(data.toJson());

class ListPatientsModel {
    ListPatientsModel({
        this.error,
        this.cod,
        this.message,
        this.data,
    });

    bool error;
    int cod;
    String message;
    Data data;

    factory ListPatientsModel.fromJson(Map<String, dynamic> json) => ListPatientsModel(
        error: json["error"] == null ? null : json["error"],
        cod: json["cod"] == null ? null : json["cod"],
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "error": error == null ? null : error,
        "cod": cod == null ? null : cod,
        "message": message == null ? null : message,
        "data": data == null ? null : data.toJson(),
    };
}

class Data {
    Data({
        this.usuarioId,
        this.listPatients,
    });

    int usuarioId;
    List<ListPatient> listPatients;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        usuarioId: json["usuario_id"] == null ? null : json["usuario_id"],
        listPatients: json["list_patients"] == null ? null : List<ListPatient>.from(json["list_patients"].map((x) => ListPatient.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "usuario_id": usuarioId == null ? null : usuarioId,
        "list_patients": listPatients == null ? null : List<dynamic>.from(listPatients.map((x) => x.toJson())),
    };
}

class ListPatient {
    ListPatient({
        this.pacienteId,
        this.nomeCompleto,
        this.pacienteToken,
    });

    int pacienteId;
    String nomeCompleto;
    String pacienteToken;

    factory ListPatient.fromJson(Map<String, dynamic> json) => ListPatient(
        pacienteId: json["paciente_id"] == null ? null : json["paciente_id"],
        nomeCompleto: json["nome_completo"] == null ? null : json["nome_completo"],
        pacienteToken: json["paciente_token"] == null ? null : json["paciente_token"],
    );

    Map<String, dynamic> toJson() => {
        "paciente_id": pacienteId == null ? null : pacienteId,
        "nome_completo": nomeCompleto == null ? null : nomeCompleto,
        "paciente_token": pacienteToken == null ? null : pacienteToken,
    };
}
