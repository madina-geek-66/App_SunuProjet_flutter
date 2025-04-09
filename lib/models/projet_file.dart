class ProjetFile {
  String _uid;
  String _nom;
  String _type;
  double _taille;
  String _ajoutePar;
  DateTime _dateAjout;
  String _projetId;
  String _fileUrl;

  // Getters
  String get uid => _uid;
  String get nom => _nom;
  String get type => _type;
  double get taille => _taille;
  String get ajoutePar => _ajoutePar;
  DateTime get dateAjout => _dateAjout;
  String get projetId => _projetId;
  String get fileUrl => _fileUrl;

  // Setters
  set nom(String value) => _nom = value;
  set type(String value) => _type = value;
  set taille(double value) => _taille = value;
  set ajoutePar(String value) => _ajoutePar = value;
  set dateAjout(DateTime value) => _dateAjout = value;
  set fileUrl(String value) => _fileUrl = value;

  ProjetFile({
    required String uid,
    required String nom,
    required String type,
    required double taille,
    required String ajoutePar,
    required DateTime dateAjout,
    required String projetId,
    required String fileUrl,
  }) :
        _uid = uid,
        _nom = nom,
        _type = type,
        _taille = taille,
        _ajoutePar = ajoutePar,
        _dateAjout = dateAjout,
        _projetId = projetId,
        _fileUrl = fileUrl;

  Map<String, dynamic> toMap() {
    return {
      'uid': _uid,
      'nom': _nom,
      'type': _type,
      'taille': _taille,
      'ajoutePar': _ajoutePar,
      'dateAjout': _dateAjout.toIso8601String(), // Format DateTime pour Supabase
      'projetId': _projetId,
      'fileUrl': _fileUrl,
    };
  }

  // Factory pour créer un objet à partir des données de Supabase
  // factory ProjetFile.fromSupabase(Map<String, dynamic> map) {
  //   return ProjetFile(
  //     uid: map['id']?.toString() ?? '',
  //     nom: map['nom'] ?? '',
  //     type: map['type'] ?? '',
  //     taille: (map['taille'] ?? 0.0).toDouble(),
  //     ajoutePar: map['ajoutePar'] ?? '',
  //     dateAjout: map['dateAjout'] != null
  //         ? DateTime.parse(map['dateAjout'])
  //         : DateTime.now(),
  //     projetId: map['projetId'] ?? '',
  //     fileUrl: map['fileUrl'] ?? '',
  //   );
  // }

  factory ProjetFile.fromSupabase(Map<String, dynamic> map) {
    return ProjetFile(
      uid: map['id']?.toString() ?? '',
      nom: map['nom'] ?? '',
      type: map['type'] ?? '',
      taille: (map['taille'] ?? 0.0).toDouble(),
      ajoutePar: map['ajoute_par'] ?? '',
      dateAjout: map['date_ajout'] != null
          ? DateTime.parse(map['date_ajout'])
          : DateTime.now(),
      projetId: map['projet_id'] ?? '',
      fileUrl: map['file_url'] ?? '',
    );
  }
}