class LoginResponseModel {
  final String pmobileno;
  final bool pstatus;
  final String? pToken;
  final int pRoleid;
  final String? onlineauctionavailability;
  final String? onboardingStatus;
  final String? psubscribername;
  final String? currency;

  LoginResponseModel({
    required this.pmobileno,
    required this.pstatus,
    required this.pToken,
    required this.pRoleid,
    this.onlineauctionavailability,
    this.onboardingStatus,
    this.psubscribername,
    this.currency,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      pmobileno: json["pmobileno"] ?? "",
      pstatus: json["pstatus"] ?? false,
      pToken: json["pToken"],
      pRoleid: json["pRoleid"] ?? 0,
      onlineauctionavailability: json["onlineauctionavailability"],
      onboardingStatus: json["onboardingStatus"],
      psubscribername: json["psubscribername"],
      currency: json["currency"],
    );
  }

  Map<String, dynamic> toJson() => {
    "pmobileno": pmobileno,
    "pstatus": pstatus,
    "pToken": pToken,
    "pRoleid": pRoleid,
    "onlineauctionavailability": onlineauctionavailability,
    "onboardingStatus": onboardingStatus,
    "psubscribername": psubscribername,
    "currency": currency,
  };
}
