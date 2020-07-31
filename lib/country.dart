class Country {
  String _countryName;
  String _countryCode;
  int _totalConfirmed, _totalDeaths, _totalRecovered;

  Country(this._countryName, this._countryCode, this._totalConfirmed,
      this._totalDeaths, this._totalRecovered);

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
        json['Country'] as String,
        json['CountryCode'] as String,
        json['TotalConfirmed'] as int,
        json['TotalDeaths'] as int,
        json['TotalRecovered'] as int);
  }

  get totalRecovered => _totalRecovered;

  get totalDeaths => _totalDeaths;

  int get totalConfirmed => _totalConfirmed;

  String get countryCode => _countryCode;

  String get countryName => _countryName;
}
