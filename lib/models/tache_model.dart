import 'package:cloud_firestore/cloud_firestore.dart';

class Tache {
  String _uid;
  String _titre;
  String _description;
  String _projetId;
  DateTime _dateCreation;
  DateTime _dateLimite;
  String _priorite; // Basse, Moyenne, Haute, Urgente
  String _statut; // A faire, En cours, Terminé
  int _progression; // Pourcentage de complétion (0-100)
  List<String> _assignesIds; // IDs des membres assignés
  List<Map<String, dynamic>> _discussions; // Fil de discussion

  // Getters
  String get uid => _uid;
  String get titre => _titre;
  String get description => _description;
  String get projetId => _projetId;
  DateTime get dateCreation => _dateCreation;
  DateTime get dateLimite => _dateLimite;
  String get priorite => _priorite;
  String get statut => _statut;
  int get progression => _progression;
  List<String> get assignesIds => _assignesIds;
  List<Map<String, dynamic>> get discussions => _discussions;

  // Setters
  set titre(String value) => _titre = value;
  set description(String value) => _description = value;
  set dateLimite(DateTime value) => _dateLimite = value;
  set priorite(String value) => _priorite = value;
  set statut(String value) => _statut = value;
  set progression(int value) => _progression = value;

  Tache({
    required String uid,
    required String titre,
    required String description,
    required String projetId,
    required DateTime dateCreation,
    required DateTime dateLimite,
    required String priorite,
    String statut = 'A faire',
    int progression = 0,
    List<String>? assignesIds,
    List<Map<String, dynamic>>? discussions,
  }) :
        _uid = uid,
        _titre = titre,
        _description = description,
        _projetId = projetId,
        _dateCreation = dateCreation,
        _dateLimite = dateLimite,
        _priorite = priorite,
        _statut = statut,
        _progression = progression,
        _assignesIds = assignesIds ?? [],
        _discussions = discussions ?? [];

  // Méthodes pour gérer les assignations
  void assignerMembre(String membreId) {
    if (!_assignesIds.contains(membreId)) {
      _assignesIds.add(membreId);
    }
  }

  void retirerMembre(String membreId) {
    _assignesIds.remove(membreId);
  }

  // Méthodes pour gérer les discussions
  void ajouterCommentaire(String userId, String message) {
    _discussions.add({
      'userId': userId,
      'message': message,
      'date': DateTime.now(),
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': _uid,
      'titre': _titre,
      'description': _description,
      'projetId': _projetId,
      'dateCreation': Timestamp.fromDate(_dateCreation),
      'dateLimite': Timestamp.fromDate(_dateLimite),
      'priorite': _priorite,
      'statut': _statut,
      'progression': _progression,
      'assignesIds': _assignesIds,
      'discussions': _discussions,
    };
  }

  factory Tache.fromMap(Map<String, dynamic> map, String documentId) {
    // Conversion des timestamps en DateTime
    DateTime getDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    // Conversion des discussions
    List<Map<String, dynamic>> getDiscussions(dynamic data) {
      if (data == null) return [];
      if (data is List) {
        return List<Map<String, dynamic>>.from(
          data.map((item) => Map<String, dynamic>.from(item)),
        );
      }
      return [];
    }

    return Tache(
      uid: documentId,
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      projetId: map['projetId'] ?? '',
      dateCreation: getDateTime(map['dateCreation']),
      dateLimite: getDateTime(map['dateLimite']),
      priorite: map['priorite'] ?? 'Moyenne',
      statut: map['statut'] ?? 'A faire',
      progression: map['progression'] ?? 0,
      assignesIds: List<String>.from(map['assignesIds'] ?? []),
      discussions: getDiscussions(map['discussions']),
    );
  }
}