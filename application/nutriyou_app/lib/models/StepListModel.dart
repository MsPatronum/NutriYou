// To parse this JSON data, do
//
//     final stepListModel = stepListModelFromJson(jsonString);

import 'dart:convert';

StepListModel stepListModelFromJson(String str) => StepListModel.fromJson(json.decode(str));

String stepListModelToJson(StepListModel data) => json.encode(data.toJson());

class StepListModel {
    StepListModel({
        this.error,
        this.message,
        this.data,
    });

    bool error;
    String message;
    List<Datum> data;

    factory StepListModel.fromJson(Map<String, dynamic> json) => StepListModel(
        error: json["error"] == null ? null : json["error"],
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "error": error == null ? null : error,
        "message": message == null ? null : message,
        "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        this.receitaId,
        this.rpNumero,
        this.rpDesc,
    });

    int receitaId;
    int rpNumero;
    String rpDesc;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        receitaId: json["receita_id"] == null ? null : json["receita_id"],
        rpNumero: json["rp_numero"] == null ? null : json["rp_numero"],
        rpDesc: json["rp_desc"] == null ? null : json["rp_desc"],
    );

    Map<String, dynamic> toJson() => {
        "receita_id": receitaId == null ? null : receitaId,
        "rp_numero": rpNumero == null ? null : rpNumero,
        "rp_desc": rpDesc == null ? null : rpDesc,
    };
}
