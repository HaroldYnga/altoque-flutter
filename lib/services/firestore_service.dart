import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/emergency_contact.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<Map<String, EmergencyContact>> obtenerServicios(
      String distrito,
      ) async {
    final distritoNormalizado =
    _normalizarDistrito(distrito);

    debugPrint(
      'Buscando distrito en Firestore: $distritoNormalizado',
    );

    final doc = await _firestore
        .collection('distritos')
        .doc(distritoNormalizado)
        .get();

    if (!doc.exists) {
      throw Exception(
        'Distrito no encontrado en Firestore: '
            '$distritoNormalizado',
      );
    }

    final data = doc.data();

    if (data == null) {
      throw Exception(
        'El documento del distrito no contiene datos.',
      );
    }

    final servicios =
    <String, EmergencyContact>{};

    _agregarServicio(
      servicios,
      'policia',
      data['policia'],
    );

    _agregarServicio(
      servicios,
      'serenazgo',
      data['serenazgo'],
    );

    _agregarServicio(
      servicios,
      'bomberos',
      data['bomberos'],
    );

    _agregarServicio(
      servicios,
      'ambulancia',
      data['ambulancia'],
    );

    return servicios;
  }

  void _agregarServicio(
      Map<String, EmergencyContact> servicios,
      String tipo,
      dynamic data,
      ) {
    if (data is Map) {
      final mapa =
      Map<String, dynamic>.from(data);

      final contacto =
      EmergencyContact.fromMap(mapa);

      if (contacto.activo &&
          contacto.telefono.trim().isNotEmpty) {
        servicios[tipo] = contacto;
      }
    }
  }

  String _normalizarDistrito(
      String distrito,
      ) {
    final texto = distrito
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('ñ', 'n')
        .replaceAll('Ñ', 'N');

    switch (texto.toLowerCase()) {
      case 'villa el salvador':
        return 'villa_el_salvador';

      case 'mala':
        return 'Mala';

      default:
        return texto;
    }
  }
}