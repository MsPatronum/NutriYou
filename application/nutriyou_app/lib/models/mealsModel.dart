class ItensRefeicaoData{
  ItensRefeicaoData({
    this.receitasNome,
    this.refeicaokcal,
  });
  String receitasNome;
  double refeicaokcal;

  factory ItensRefeicaoData.fromJson(Map<String, dynamic> json) {
    return ItensRefeicaoData(
      receitasNome: json["receitas"] == null ? null : json["receitas"],
      refeicaokcal: json["momento_kcal"] == null ? 0 : json["momento_kcal"],
    );
  }

}


class ItensRefeicaoMessage{
  final bool error;
  final String message;
  final ItensRefeicaoData data;

  ItensRefeicaoMessage({this.error, this.message, this.data});

  factory ItensRefeicaoMessage.fromJson(Map<String, dynamic> json) {
    return ItensRefeicaoMessage(
      error: json['error'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
            ? ItensRefeicaoData.fromJson(json['data'])
            : null,
    );
  }

}