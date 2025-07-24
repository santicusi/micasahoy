import 'package:flutter/material.dart';
import '../models/field_definition.dart';

// Importa aquí todos tus widgets de campo:
import 'fields/entrada_texto.dart';
import 'fields/entrada_numero.dart';
import 'fields/entrada_select.dart';
import 'fields/entrada_checkbox.dart';
import 'fields/entrada_radio.dart';
import 'fields/entrada_fecha.dart';
import 'fields/entrada_fecha_hora.dart';
import 'fields/entrada_boolean.dart';
import 'fields/entrada_slider.dart';
import 'fields/entrada_archivo.dart';
import 'fields/entrada_camara.dart';
import 'fields/entrada_gps.dart';
import 'fields/entrada_mapa.dart';
import 'fields/entrada_direccion.dart';
import 'fields/entrada_password.dart';

class FieldFactory {
  static Widget build(
      FieldDefinition def,
      ValueChanged<dynamic> onChanged, {
        dynamic initialValue,
        bool enabled = true,
        int? predioId, // ✨ NUEVO: Parámetro opcional para el ID del predio
      }) {
    switch (def.type) {
      case 'password':
        return EntradaPassword(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'text':
      case 'email':
        return EntradaTexto(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'number':
        return EntradaNumero(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'select':
        return EntradaSelect(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'radio':
        return EntradaRadio(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'checkbox':
        return EntradaCheckbox(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'date':
        return EntradaFecha(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'datetime':
        return EntradaFechaHora(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'boolean':
        return EntradaBoolean(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'range':
        return EntradaSlider(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'file':
        return EntradaArchivo(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'camera':
        return EntradaCamara(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'gps':
        return EntradaGPS(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      case 'map':
        return EntradaMapa(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
          predioId: predioId, // ✨ NUEVO: Pasar el predioId al EntradaMapa
        );

      case 'address':
        return EntradaDireccion(
          def: def,
          onChanged: onChanged,
          initialValue: initialValue,
          enabled: enabled,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
