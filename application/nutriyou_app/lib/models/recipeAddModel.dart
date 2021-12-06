// To parse this JSON data, do
//
//     final recipeAdd = recipeAddFromJson(jsonString);

import 'dart:convert';

RecipeAdd recipeAddFromJson(String str) => RecipeAdd.fromJson(json.decode(str));

String recipeAddToJson(RecipeAdd data) => json.encode(data.toJson());

class RecipeAdd {
    RecipeAdd({
        this.error,
        this.message,
        this.data,
    });

    bool error;
    String message;
    Data data;

    factory RecipeAdd.fromJson(Map<String, dynamic> json) => RecipeAdd(
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
        this.receitaId,
        this.usuarioId,
        this.nome,
        this.descricao,
        this.nivel,
        this.modo,
        this.tempoPreparo,
        this.porcoes,
        this.status,
    });

    int receitaId;
    int usuarioId;
    String nome;
    String descricao;
    int nivel;
    int modo;
    String tempoPreparo;
    int porcoes;
    int status;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        receitaId: json["receita_id"] == null ? null : json["receita_id"],
        usuarioId: json["usuario_id"] == null ? null : json["usuario_id"],
        nome: json["nome"] == null ? null : json["nome"],
        descricao: json["descricao"] == null ? null : json["descricao"],
        nivel: json["nivel"] == null ? null : json["nivel"],
        modo: json["modo"] == null ? null : json["modo"],
        tempoPreparo: json["tempo_preparo"] == null ? null : json["tempo_preparo"],
        porcoes: json["porcoes"] == null ? null : json["porcoes"],
        status: json["status"] == null ? null : json["status"],
    );

    Map<String, dynamic> toJson() => {
        "receita_id": receitaId == null ? null : receitaId,
        "usuario_id": usuarioId == null ? null : usuarioId,
        "nome": nome == null ? null : nome,
        "descricao": descricao == null ? null : descricao,
        "nivel": nivel == null ? null : nivel,
        "modo": modo == null ? null : modo,
        "tempo_preparo": tempoPreparo == null ? null : tempoPreparo,
        "porcoes": porcoes == null ? null : porcoes,
        "status": status == null ? null : status,
    };
}
