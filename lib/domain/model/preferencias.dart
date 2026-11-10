enum ModoTema { sistema, claro, oscuro }

class Preferencias {
  final ModoTema modoTema;
  final bool recordatorioActivo;
  final int horaRecordatorio;
  final int minutoRecordatorio;

  const Preferencias({
    this.modoTema = ModoTema.sistema,
    this.recordatorioActivo = false,
    this.horaRecordatorio = 9,
    this.minutoRecordatorio = 0,
  });

  // Copiar las preferencias cambiando solo lo indicado
  Preferencias copiarCon({
    ModoTema? modoTema,
    bool? recordatorioActivo,
    int? horaRecordatorio,
    int? minutoRecordatorio,
  }) => Preferencias(
    modoTema: modoTema ?? this.modoTema,
    recordatorioActivo: recordatorioActivo ?? this.recordatorioActivo,
    horaRecordatorio: horaRecordatorio ?? this.horaRecordatorio,
    minutoRecordatorio: minutoRecordatorio ?? this.minutoRecordatorio,
  );
}
