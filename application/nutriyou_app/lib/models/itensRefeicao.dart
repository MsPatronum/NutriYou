// To parse this JSON data, do
//
//     final itensRefeicao = itensRefeicaoFromJson(jsonString);

import 'dart:convert';

ItensRefeicao itensRefeicaoFromJson(String str) => ItensRefeicao.fromJson(json.decode(str));

String itensRefeicaoToJson(ItensRefeicao data) => json.encode(data.toJson());

class ItensRefeicao {
    ItensRefeicao({
        this.error,
        this.cod,
        this.message,
        this.data,
    });

    final bool error;
    final int cod;
    final String message;
    final List<Data> data;

    factory ItensRefeicao.fromJson(Map<String, dynamic> json) => ItensRefeicao(
        error: json["error"] == null ? null : json["error"],
        cod: json["cod"] == null ? null : json["cod"],
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "error": error == null ? null : error,
        "cod": cod == null ? null : cod,
        "message": message == null ? null : message,
        "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Data {
    Data({
        this.receitaId,
        this.receitaNome,
        this.receitaKcal,
    });

    final int receitaId;
    final String receitaNome;
    final double receitaKcal;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        receitaId: json["receita_id"] == null ? null : json["receita_id"],
        receitaNome: json["receita_nome"] == null ? null : json["receita_nome"],
        receitaKcal: json["receita_kcal"] == null ? null : json["receita_kcal"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "receita_id": receitaId == null ? null : receitaId,
        "receita_nome": receitaNome == null ? null : receitaNome,
        "receita_kcal": receitaKcal == null ? null : receitaKcal,
    };
}
