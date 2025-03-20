import 'package:cloud_firestore/cloud_firestore.dart';

class Projet {
  String _uid;
  String _titre;
  String _description;
  DateTime _dateDebut;
  DateTime _dateFin;
  String _priorite;
  String _statut;
  int _progress;
  DateTime _createdAt;
  String? _ownerId;
  Map<String, String> _memberRoles; // Dictionnaire pour stocker les rôles des membres

  // Getters
  String get uid => _uid;
  String get titre => _titre;
  String get description => _description;
  DateTime get dateDebut => _dateDebut;
  DateTime get dateFin => _dateFin;
  String get priorite => _priorite;
  String get statut => _statut;
  int get progress => _progress;
  DateTime get createdAt => _createdAt;
  String? get ownerId => _ownerId;
  Map<String, String> get memberRoles => _memberRoles;
  List<String> get members => _memberRoles.keys.toList();

  // Setters
  set uid(String value) => _uid = value;
  set titre(String value) => _titre = value;
  set description(String value) => _description = value;
  set dateDebut(DateTime value) => _dateDebut = value;
  set dateFin(DateTime value) => _dateFin = value;
  set priorite(String value) => _priorite = value;
  set statut(String value) => _statut = value;
  set progress(int value) => _progress = value;

  Projet({
    required String uid,
    required String titre,
    required String description,
    required DateTime dateDebut,
    required DateTime dateFin,
    required String priorite,
    required String statut,
    required int progress,
    required String? ownerId,
    Map<String, String>? memberRoles,
    required DateTime createdAt,
  }) :
        _uid = uid,
        _titre = titre,
        _description = description,
        _dateDebut = dateDebut,
        _dateFin = dateFin,
        _priorite = priorite,
        _statut = statut,
        _progress = progress,
        _ownerId = ownerId,
        _createdAt = createdAt,
        _memberRoles = memberRoles ?? {} {
    // Si le owner existe, on lui attribue automatiquement le rôle "Chef de projet"
    if (ownerId != null && ownerId.isNotEmpty) {
      _memberRoles[ownerId] = "Chef de projet";
    }
  }

  // Méthodes pour gérer les membres et leurs rôles
  void addMember(String memberId, String role) {
    _memberRoles[memberId] = role;
  }

  void removeMember(String memberId) {
    _memberRoles.remove(memberId);
  }

  void updateMemberRole(String memberId, String newRole) {
    if (_memberRoles.containsKey(memberId)) {
      _memberRoles[memberId] = newRole;
    }
  }

  String getMemberRole(String memberId) {
    return _memberRoles[memberId] ?? "Membre d'équipe";
  }

  bool isMember(String memberId) {
    return _memberRoles.containsKey(memberId);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _uid,
      'titre': _titre,
      'description': _description,
      'dateDebut': _dateDebut,
      'dateFin': _dateFin,
      'priorite': _priorite,
      'statut': _statut,
      'progress': _progress,
      'createdAt': _createdAt,
      'ownerId': _ownerId,
      'memberRoles': _memberRoles,
    };
  }

  factory Projet.fromMap(Map<String, dynamic> map, String documentId) {
    // Conversion de la map de rôles si elle existe
    final memberRolesData = map['memberRoles'];
    Map<String, String> memberRoles = {};

    if (memberRolesData != null) {
      memberRoles = Map<String, String>.from(memberRolesData);
    } else if (map['members'] != null) {
      // Migration: si on a l'ancienne structure avec juste members, on convertit
      final members = List<String>.from(map['members'] ?? []);
      for (final memberId in members) {
        final role = (memberId == map['ownerId']) ? "Chef de projet" : "Membre d'équipe";
        memberRoles[memberId] = role;
      }
    }

    // Gérer correctement les conversions de dates
    DateTime getDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return Projet(
      uid: documentId,
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      dateDebut: getDateTime(map['dateDebut']),
      dateFin: getDateTime(map['dateFin']),
      priorite: map['priorite'] ?? 'Moyenne',
      statut: map['statut'] ?? 'En attente',
      progress: map['progress'] ?? 0,
      createdAt: getDateTime(map['createdAt']),
      ownerId: map['ownerId'] ?? '',
      memberRoles: memberRoles,
    );
  }
}