enum Environment {
  dev('DEV'),
  prod('PROD');

  const Environment(this.value);

  final String value;
}


extension TronDomain on Environment {
  String get tronDomain{
    final String testUrl = 'https://api.shasta.trongrid.io';
    final String mainUrl = 'https://api.trongrid.io';

    switch (this) {
      case Environment.dev:
        return testUrl;
      case Environment.prod:
        return mainUrl;
      default:
        return mainUrl;
    }
  }
}

extension ScanDomain on Environment {
  String get scanDomain {
    final String testUrl = "https://apilist.tronscanapi.com";
    final String mainUrl = "https://apilist.tronscanapi.com";

    switch (this) {
      case Environment.dev:
        return testUrl;
      case Environment.prod:
        return mainUrl;
      default:
        return mainUrl;
    }
  }
}
