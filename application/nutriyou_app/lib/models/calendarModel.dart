// To parse this JSON data, do
//
//     final calendarModel = calendarModelFromJson(jsonString);

import 'dart:convert';

CalendarModel calendarModelFromJson(String str) => CalendarModel.fromJson(json.decode(str));

String calendarModelToJson(CalendarModel data) => json.encode(data.toJson());

class CalendarModel {
    CalendarModel({
        this.error,
        this.cod,
        this.message,
        this.data,
    });

    bool error;
    int cod;
    String message;
    Data data;

    factory CalendarModel.fromJson(Map<String, dynamic> json) => CalendarModel(
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
        this.detalhes,
    });

    int usuarioId;
    List<Detalhe> detalhes;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        usuarioId: json["usuario_id"] == null ? null : json["usuario_id"],
        detalhes: json["detalhes"] == null ? null : List<Detalhe>.from(json["detalhes"].map((x) => Detalhe.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "usuario_id": usuarioId == null ? null : usuarioId,
        "detalhes": detalhes == null ? null : List<dynamic>.from(detalhes.map((x) => x.toJson())),
    };
}

class Detalhe {
    Detalhe({
        this.data,
        this.udcKcal,
        this.udmKcal,
        this.classcolor,
    });

    DateTime data;
    int udcKcal;
    double udmKcal;
    String classcolor;

    factory Detalhe.fromJson(Map<String, dynamic> json) => Detalhe(
        data: json["data"] == null ? null : DateTime.parse(json["data"]),
        udcKcal: json["udc_kcal"] == null ? null : json["udc_kcal"],
        udmKcal: json["udm_kcal"] == null ? null : json["udm_kcal"].toDouble(),
        classcolor: json["class"] == null ? null : json["class"],
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? null : "${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}",
        "udc_kcal": udcKcal == null ? null : udcKcal,
        "udm_kcal": udmKcal == null ? null : udmKcal,
        "class": classcolor == null ? null : classcolor,
    };
}