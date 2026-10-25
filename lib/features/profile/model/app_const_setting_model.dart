class AppConstSettingModel {
  final String? id;
  final String? laws;
  final String? vetCooperationLaws;
  final String? sellerCooperationLaws;
  final String? handoverLaws;
  final int? minVersion;
  final int? currentVersion;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final List<String>? jobTitle;
  final List<String>? sendingGoodsType;
  final List<String>? shopHistory;
  final List<String>? shopType;

  const AppConstSettingModel({
    this.id,
    this.laws,
    this.vetCooperationLaws,
    this.sellerCooperationLaws,
    this.handoverLaws,
    this.minVersion,
    this.currentVersion,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.jobTitle,
    this.sendingGoodsType,
    this.shopHistory,
    this.shopType,
  });

  factory AppConstSettingModel.fromJson(Map<String, dynamic> json) {
    return AppConstSettingModel(
      id: json['_id'],
      laws: json['laws'],
      vetCooperationLaws: json['vetCooperationLaws'],
      sellerCooperationLaws: json['sellerCooperationLaws'],
      handoverLaws: json['handoverLaws'],
      minVersion: json['minVersion'],
      currentVersion: json['currentVersion'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      jobTitle: (json['jobTitle'] as List?)?.map((e) => e.toString()).toList(),
      sendingGoodsType: (json['sendingGoodsType'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      shopHistory: (json['shopHistory'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      shopType: (json['shopType'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}
