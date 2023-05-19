class AbiEntity {
  List<Entrys>? entrys;

  AbiEntity({this.entrys});

  factory AbiEntity.fromJson(Map<String, dynamic> json) {
    final List<Entrys> entry = <Entrys>[];
    json['entrys'].forEach((v) {
      entry.add(new Entrys.fromJson(v));
    });

    return AbiEntity(entrys: entry);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.entrys != null) {
      data['entrys'] = this.entrys!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Entrys {
  String? name;
  List<Inputs>? inputs;
  List<Outputs>? outputs;
  String? type;
  String? stateMutability;
  bool? constant;

  Entrys({
    this.name,
    this.inputs,
    this.outputs,
    this.type,
    this.stateMutability,
    this.constant,
  });

  factory Entrys.fromJson(Map<String, dynamic> json) {
    final String name = json.containsKey('name') ? json['name'] : '';

    final List<Inputs> input = <Inputs>[];
    if(json.containsKey('inputs')){
      json['inputs'].forEach((v) {
        input.add(new Inputs.fromJson(v));
      });
    }

    final List<Outputs> output = <Outputs>[];
    if(json.containsKey('outputs')){
      json['outputs'].forEach((v) {
        output.add(new Outputs.fromJson(v));
      });
    }

    final String type = json['type'];
    final String stateMutability = json.containsKey('stateMutability') ? json['stateMutability'] : '';
    final bool constant = json.containsKey('constant') ? json['constant'] : false;

    return Entrys(
      name: name,
      inputs: input,
      outputs: output,
      type: type,
      stateMutability: stateMutability,
      constant: constant,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.inputs != null) {
      data['inputs'] = this.inputs!.map((v) => v.toJson()).toList();
    }
    if (this.outputs != null) {
      data['outputs'] = this.outputs!.map((v) => v.toJson()).toList();
    }
    data['type'] = this.type;
    data['stateMutability'] = this.stateMutability;
    data['constant'] = this.constant;
    return data;
  }
}

class Inputs {
  String? name;
  String? type;
  bool? indexed;

  Inputs({
    this.name,
    this.type,
    this.indexed,
  });

  factory Inputs.fromJson(Map<String, dynamic> json) {
    return Inputs(
      name: json['name'],
      type: json['type'],
      indexed: json['indexed'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type;
    data['indexed'] = this.indexed;
    return data;
  }
}

class Outputs {
  String? type;

  Outputs({
    this.type,
  });

  factory Outputs.fromJson(Map<String, dynamic> json) {
    return Outputs(
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    return data;
  }
}
