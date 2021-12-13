// To parse this JSON data, do
//
//     final daysCalendarModel = daysCalendarModelFromJson(jsonString);

import 'dart:convert';

DaysCalendarModel daysCalendarModelFromJson(String str) => DaysCalendarModel.fromJson(json.decode(str));

String daysCalendarModelToJson(DaysCalendarModel data) => json.encode(data.toJson());

class DaysCalendarModel {
    DaysCalendarModel({
        this.error,
        this.cod,
        this.message,
        this.data,
    });

    bool error;
    int cod;
    String message;
    Data data;

    factory DaysCalendarModel.fromJson(Map<String, dynamic> json) => DaysCalendarModel(
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
        this.listDatas,
    });

    int usuarioId;
    List<ListData> listDatas;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        usuarioId: json["usuario_id"] == null ? null : json["usuario_id"],
        listDatas: json["list_datas"] == null ? null : List<ListData>.from(json["list_datas"].map((x) => ListData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "usuario_id": usuarioId == null ? null : usuarioId,
        "list_datas": listDatas == null ? null : List<dynamic>.from(listDatas.map((x) => x.toJson())),
    };
}

class ListData {
    ListData({
        this.data,
    });

    DateTime data;

    factory ListData.fromJson(Map<String, dynamic> json) => ListData(
        data: json["data"] == null ? null : DateTime.parse(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? null : "${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}",
    };
}
