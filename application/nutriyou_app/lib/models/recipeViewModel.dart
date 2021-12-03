// To parse this JSON data, do
//
//     final recipeView = recipeViewFromJson(jsonString);

import 'dart:convert';

RecipeView recipeViewFromJson(String str) => RecipeView.fromJson(json.decode(str));

String recipeViewToJson(RecipeView data) => json.encode(data.toJson());

class RecipeView {
    RecipeView({
        this.error,
        this.cod,
        this.message,
        this.infoReceita,
        this.passos,
        this.ingredientes,
    });

    bool error;
    int cod;
    String message;
    InfoReceita infoReceita;
    List<Passo> passos;
    List<Ingrediente> ingredientes;

    factory RecipeView.fromJson(Map<String, dynamic> json) => RecipeView(
        error: json["error"] == null ? null : json["error"],
        cod: json["cod"] == null ? null : json["cod"],
        message: json["message"] == null ? null : json["message"],
        infoReceita: json["info_receita"] == null ? null : InfoReceita.fromJson(json["info_receita"]),
        passos: json["passos"] == null ? null : List<Passo>.from(json["passos"].map((x) => Passo.fromJson(x))),
        ingredientes: json["ingredientes"] == null ? null : List<Ingrediente>.from(json["ingredientes"].map((x) => Ingrediente.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "error": error == null ? null : error,
        "cod": cod == null ? null : cod,
        "message": message == null ? null : message,
        "info_receita": infoReceita == null ? null : infoReceita.toJson(),
        "passos": passos == null ? null : List<dynamic>.from(passos.map((x) => x.toJson())),
        "ingredientes": ingredientes == null ? null : List<dynamic>.from(ingredientes.map((x) => x.toJson())),
    };
}

class InfoReceita {
    InfoReceita({
        this.receitaId,
        this.receitaNome,
        this.receitaDesc,
        this.receitaTempoPreparo,
        this.rnNivel,
        this.momento,
        this.humidityQtd,
        this.humidityUnit,
        this.proteinQtd,
        this.proteinUnit,
        this.lipidQtd,
        this.lipidUnit,
        this.carbohydrateQtd,
        this.carbohydrateUnit,
        this.fiberQtd,
        this.fiberUnit,
        this.energyKcal,
        this.energyKj,
    });

    int receitaId;
    String receitaNome;
    String receitaDesc;
    String receitaTempoPreparo;
    String rnNivel;
    String momento;
    double humidityQtd;
    String humidityUnit;
    double proteinQtd;
    String proteinUnit;
    double lipidQtd;
    String lipidUnit;
    double carbohydrateQtd;
    String carbohydrateUnit;
    double fiberQtd;
    String fiberUnit;
    double energyKcal;
    double energyKj;

    factory InfoReceita.fromJson(Map<String, dynamic> json) => InfoReceita(
        receitaId: json["receita_id"] == null ? null : json["receita_id"],
        receitaNome: json["receita_nome"] == null ? null : json["receita_nome"],
        receitaDesc: json["receita_desc"] == null ? null : json["receita_desc"],
        receitaTempoPreparo: json["receita_tempo_preparo"] == null ? null : json["receita_tempo_preparo"],
        rnNivel: json["rn_nivel"] == null ? null : json["rn_nivel"],
        momento: json["momento"] == null ? null : json["momento"],
        humidityQtd: json["humidity_qtd"] == null ? null : json["humidity_qtd"].toDouble(),
        humidityUnit: json["humidity_unit"] == null ? null : json["humidity_unit"],
        proteinQtd: json["protein_qtd"] == null ? null : json["protein_qtd"].toDouble(),
        proteinUnit: json["protein_unit"] == null ? null : json["protein_unit"],
        lipidQtd: json["lipid_qtd"] == null ? null : json["lipid_qtd"].toDouble(),
        lipidUnit: json["lipid_unit"] == null ? null : json["lipid_unit"],
        carbohydrateQtd: json["carbohydrate_qtd"] == null ? null : json["carbohydrate_qtd"].toDouble(),
        carbohydrateUnit: json["carbohydrate_unit"] == null ? null : json["carbohydrate_unit"],
        fiberQtd: json["fiber_qtd"] == null ? null : json["fiber_qtd"].toDouble(),
        fiberUnit: json["fiber_unit"] == null ? null : json["fiber_unit"],
        energyKcal: json["energy_kcal"] == null ? null : json["energy_kcal"].toDouble(),
        energyKj: json["energy_kj"] == null ? null : json["energy_kj"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "receita_id": receitaId == null ? null : receitaId,
        "receita_nome": receitaNome == null ? null : receitaNome,
        "receita_desc": receitaDesc == null ? null : receitaDesc,
        "receita_tempo_preparo": receitaTempoPreparo == null ? null : receitaTempoPreparo,
        "rn_nivel": rnNivel == null ? null : rnNivel,
        "momento": momento == null ? null : momento,
        "humidity_qtd": humidityQtd == null ? null : humidityQtd,
        "humidity_unit": humidityUnit == null ? null : humidityUnit,
        "protein_qtd": proteinQtd == null ? null : proteinQtd,
        "protein_unit": proteinUnit == null ? null : proteinUnit,
        "lipid_qtd": lipidQtd == null ? null : lipidQtd,
        "lipid_unit": lipidUnit == null ? null : lipidUnit,
        "carbohydrate_qtd": carbohydrateQtd == null ? null : carbohydrateQtd,
        "carbohydrate_unit": carbohydrateUnit == null ? null : carbohydrateUnit,
        "fiber_qtd": fiberQtd == null ? null : fiberQtd,
        "fiber_unit": fiberUnit == null ? null : fiberUnit,
        "energy_kcal": energyKcal == null ? null : energyKcal,
        "energy_kj": energyKj == null ? null : energyKj,
    };
}

class Ingrediente {
    Ingrediente({
        this.receitaId,
        this.ingredientesId,
        this.ingredientesDesc,
        this.receitaIngredientesQtd,
        this.ingredientesBaseQtd,
        this.ingredientesBaseUnity,
    });

    int receitaId;
    dynamic ingredientesId;
    dynamic ingredientesDesc;
    dynamic receitaIngredientesQtd;
    dynamic ingredientesBaseQtd;
    dynamic ingredientesBaseUnity;

    factory Ingrediente.fromJson(Map<String, dynamic> json) => Ingrediente(
        receitaId: json["receita_id"] == null ? null : json["receita_id"],
        ingredientesId: json["ingredientes_id"],
        ingredientesDesc: json["ingredientes_desc"],
        receitaIngredientesQtd: json["receita_ingredientes_qtd"],
        ingredientesBaseQtd: json["ingredientes_base_qtd"],
        ingredientesBaseUnity: json["ingredientes_base_unity"],
    );

    Map<String, dynamic> toJson() => {
        "receita_id": receitaId == null ? null : receitaId,
        "ingredientes_id": ingredientesId,
        "ingredientes_desc": ingredientesDesc,
        "receita_ingredientes_qtd": receitaIngredientesQtd,
        "ingredientes_base_qtd": ingredientesBaseQtd,
        "ingredientes_base_unity": ingredientesBaseUnity,
    };
}

class Passo {
    Passo({
        this.rpNumero,
        this.rpDesc,
    });

    dynamic rpNumero;
    dynamic rpDesc;

    factory Passo.fromJson(Map<String, dynamic> json) => Passo(
        rpNumero: json["rp_numero"],
        rpDesc: json["rp_desc"],
    );

    Map<String, dynamic> toJson() => {
        "rp_numero": rpNumero,
        "rp_desc": rpDesc,
    };
}
