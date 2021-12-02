class MealListData{
  MealListData({
    this.receitaId,
    this.nomeReceita,
    this.receitaKcal,
});

  String nomeReceita;
  double receitaKcal;
  int receitaId;

  factory MealListData.fromJson(Map<String, dynamic> json){
    return MealListData(receitaId: json["receita_id"] == null ? '0' : json["receita_id"],
      nomeReceita: json["receita_nome"] == null ? '0' : json["receita_nome"],
      receitaKcal: json["receita_kcal"] == null ? '0' : json["receita_kcal"],
    );
  }

}

class ItensMealList{
  final bool error;
  final int cod;
  final String message;
  final MealListData data;

  ItensMealList({this.error, this.message, this.data, this.cod});

  factory ItensMealList.fromJson(Map<String, dynamic> json) {
    return ItensMealList(
      error: json['error'] as bool,
      message: json['message'] as String,
      cod : json['cod'] as int,
      data: json['data'] != null
            ? MealListData.fromJson(json['data'])
            : null,
    );
  }

}
