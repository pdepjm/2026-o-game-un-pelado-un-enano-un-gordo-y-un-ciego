import wollok.game.*
import mapas.*

object gestorMusica {
    var archivoActual = null
    var sonido = null

    method archivoDe(sala) =
        if ([pueblo, iglesia, muelle, entradaCastillo].contains(sala))
            "musica_pueblo.mp3"
        else if ([lobbyCastillo, salaLlave1, salaLlave2,
                  salaPasillo0, bibiloteca, salaPasillo1, salaEscopeta, salaPasillo2].contains(sala))
            "musica_castillo.mp3"
        else if ([entradaIsla, columnaNorte, columnaSur, salaVerde, salaRoja, salaAzul,
                  pasilloNorte, pasilloCentral, pasilloSurOeste, pasilloSurEste,
                  antesalaKrauser].contains(sala))
            "musica_isla.mp3"
        else if ([salaJefePelado, salaJefeEnano,salaJefeGordo, salaKrauser].contains(sala))
            "musica_jefe.mp3"
        else if ([salaFinal].contains(sala))
            "musica_jefeFinal.mp3"
        else null   
        

    method alEntrarA(sala) {
        const archivo = self.archivoDe(sala)
        if (archivo != archivoActual) {
            self.detener()
            archivoActual = archivo
            if (archivo != null) {
                sonido = game.sound(archivo)
                sonido.shouldLoop(true)
                sonido.volume(0.2)
                sonido.play()
            }
        }
    }

    method detener() {
        if (sonido != null) {
            sonido.stop()
            sonido = null
        }
    }
}