// To parse this JSON data, do
//
//     final ingredienteReceitaModel = ingredienteReceitaModelFromJson(jsonString);

import 'dart:convert';

IngredienteReceitaModel ingredienteReceitaModelFromJson(String str) => IngredienteReceitaModel.fromJson(json.decode(str));

String ingredienteReceitaModelToJson(IngredienteReceitaModel data) => json.encode(data.toJson());

class IngredienteReceitaModel {
    IngredienteReceitaModel({
        this.error,
        this.cod,
        this.message,
        this.data,
    });

    bool error;
    int cod;
    String message;
    List<Datum> data;

    factory IngredienteReceitaModel.fromJson(Map<String, dynamic> json) => IngredienteReceitaModel(
        error: json["error"] == null ? null : json["error"],
        cod: json["cod"] == null ? null : json["cod"],
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "error": error == null ? null : error,
        "cod": cod == null ? null : cod,
        "message": message == null ? null : message,
        "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        this.receitaId,
        this.ingredientesId,
        this.ingredientesDesc,
        this.receitaIngredientesQtd,
        this.ingredientesBaseQtd,
        this.ingredientesBaseUnity,
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
    int ingredientesId;
    String ingredientesDesc;
    int receitaIngredientesQtd;
    int ingredientesBaseQtd;
    String ingredientesBaseUnity;
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

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        receitaId: json["receita_id"] == null ? null : json["receita_id"],
        ingredientesId: json["ingredientes_id"] == null ? null : json["ingredientes_id"],
        ingredientesDesc: json["ingredientes_desc"] == null ? null : json["ingredientes_desc"],
        receitaIngredientesQtd: json["receita_ingredientes_qtd"] == null ? null : json["receita_ingredientes_qtd"],
        ingredientesBaseQtd: json["ingredientes_base_qtd"] == null ? null : json["ingredientes_base_qtd"],
        ingredientesBaseUnity: json["ingredientes_base_unity"] == null ? null : json["ingredientes_base_unity"],
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
        "ingredientes_id": ingredientesId == null ? null : ingredientesId,
        "ingredientes_desc": ingredientesDesc == null ? null : ingredientesDesc,
        "receita_ingredientes_qtd": receitaIngredientesQtd == null ? null : receitaIngredientesQtd,
        "ingredientes_base_qtd": ingredientesBaseQtd == null ? null : ingredientesBaseQtd,
        "ingredientes_base_unity": ingredientesBaseUnity == null ? null : ingredientesBaseUnity,
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
