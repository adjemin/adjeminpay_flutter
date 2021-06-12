class Application{

  final int id;
  final String title;
  final String logo;

  Application({this.id, this.title, this.logo});

  static Application fromJson(Map<String, dynamic> json) {
    return new Application(
        id: json['id'] as int,
        title: json['title'] as String,
        logo: json['logo'] as String,

    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['logo'] = this.logo;
    return data;
  }


}