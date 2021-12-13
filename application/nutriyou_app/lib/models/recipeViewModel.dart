// To parse this JSON data, do
//
//     final recipeViewModel = recipeViewModelFromJson(jsonString);

import 'dart:convert';

RecipeViewModel recipeViewModelFromJson(String str) => RecipeViewModel.fromJson(json.decode(str));

String recipeViewModelToJson(RecipeViewModel data) => json.encode(data.toJson());

class RecipeViewModel {
    RecipeViewModel({
        this.error,
        this.cod,
        this.message,
        this.infoReceita,
        this.passos,
        this.ingredientes,
        this.imagens,
    });

    bool error;
    int cod;
    String message;
    InfoReceita infoReceita;
    List<Passo> passos;
    List<Ingrediente> ingredientes;
    List<Imagem> imagens;

    factory RecipeViewModel.fromJson(Map<String, dynamic> json) => RecipeViewModel(
        error: json["error"] == null ? null : json["error"],
        cod: json["cod"] == null ? null : json["cod"],
        message: json["message"] == null ? null : json["message"],
        infoReceita: json["info_receita"] == null ? null : InfoReceita.fromJson(json["info_receita"]),
        passos: json["passos"] == null ? null : List<Passo>.from(json["passos"].map((x) => Passo.fromJson(x))),
        ingredientes: json["ingredientes"] == null ? null : List<Ingrediente>.from(json["ingredientes"].map((x) => Ingrediente.fromJson(x))),
        imagens: json["imagens"] == null ? null : List<Imagem>.from(json["imagens"].map((x) => Imagem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "error": error == null ? null : error,
        "cod": cod == null ? null : cod,
        "message": message == null ? null : message,
        "info_receita": infoReceita == null ? null : infoReceita.toJson(),
        "passos": passos == null ? null : List<dynamic>.from(passos.map((x) => x.toJson())),
        "ingredientes": ingredientes == null ? null : List<dynamic>.from(ingredientes.map((x) => x.toJson())),
        "imagens": imagens == null ? null : List<dynamic>.from(imagens.map((x) => x.toJson())),
    };
}

class Imagem {
    Imagem({
        this.receitaImagensPath,
    });

    String receitaImagensPath;

    factory Imagem.fromJson(Map<String, dynamic> json) => Imagem(
        receitaImagensPath: json["receita_imagens_path"] == null ? null : json["receita_imagens_path"],
    );

    Map<String, dynamic> toJson() => {
        "receita_imagens_path": receitaImagensPath == null ? null : receitaImagensPath,
    };
}

class InfoReceita {
    InfoReceita({
        this.receitaId,
        this.receitaNome,
        this.receitaDesc,
        this.receitaPorcoes,
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
        this.aval,
    });

    int receitaId;
    String receitaNome;
    String receitaDesc;
    int receitaPorcoes;
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
    double aval;

    factory InfoReceita.fromJson(Map<String, dynamic> json) => InfoReceita(
        receitaId: json["receita_id"] == null ? null : json["receita_id"],
        receitaNome: json["receita_nome"] == null ? null : json["receita_nome"],
        receitaDesc: json["receita_desc"] == null ? null : json["receita_desc"],
        receitaPorcoes: json["receita_porcoes"] == null ? null : json["receita_porcoes"],
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
        aval: json["aval"] == null ? 0 : json["aval"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "receita_id": receitaId == null ? null : receitaId,
        "receita_nome": receitaNome == null ? null : receitaNome,
        "receita_desc": receitaDesc == null ? null : receitaDesc,
        "receita_porcoes": receitaPorcoes == null ? null : receitaPorcoes,
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
        "aval" : aval == null ? 0 : aval,
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
    int ingredientesId;
    String ingredientesDesc;
    double receitaIngredientesQtd;
    int ingredientesBaseQtd;
    String ingredientesBaseUnity;

    factory Ingrediente.fromJson(Map<String, dynamic> json) => Ingrediente(
        receitaId: json["receita_id"] == null ? null : json["receita_id"],
        ingredientesId: json["ingredientes_id"] == null ? null : json["ingredientes_id"],
        ingredientesDesc: json["ingredientes_desc"] == null ? null : json["ingredientes_desc"],
        receitaIngredientesQtd: json["receita_ingredientes_qtd"] == null ? null : json["receita_ingredientes_qtd"].toDouble(),
        ingredientesBaseQtd: json["ingredientes_base_qtd"] == null ? null : json["ingredientes_base_qtd"],
        ingredientesBaseUnity: json["ingredientes_base_unity"] == null ? null : json["ingredientes_base_unity"],
    );

    Map<String, dynamic> toJson() => {
        "receita_id": receitaId == null ? null : receitaId,
        "ingredientes_id": ingredientesId == null ? null : ingredientesId,
        "ingredientes_desc": ingredientesDesc == null ? null : ingredientesDesc,
        "receita_ingredientes_qtd": receitaIngredientesQtd == null ? null : receitaIngredientesQtd,
        "ingredientes_base_qtd": ingredientesBaseQtd == null ? null : ingredientesBaseQtd,
        "ingredientes_base_unity": ingredientesBaseUnity == null ? null : ingredientesBaseUnity,
    };
}

class Passo {
    Passo({
        this.rpNumero,
        this.rpDesc,
    });

    int rpNumero;
    String rpDesc;

    factory Passo.fromJson(Map<String, dynamic> json) => Passo(
        rpNumero: json["rp_numero"] == null ? null : json["rp_numero"],
        rpDesc: json["rp_desc"] == null ? null : json["rp_desc"],
    );

    Map<String, dynamic> toJson() => {
        "rp_numero": rpNumero == null ? null : rpNumero,
        "rp_desc": rpDesc == null ? null : rpDesc,
    };
}
