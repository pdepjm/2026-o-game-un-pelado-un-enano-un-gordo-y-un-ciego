import mapas.*
import llaves.*
import maquinaDeEstados.juego

class Puerta {
    var posicion = game.at(0,0)

    const destino
    const puertaDeVuelta
    const llaveRequerida
    method estaVivo() = false
    method estaTrabada() = juego.existeLlave(llaveRequerida)

    method destino() = destino
    method puertaDeVuelta() = puertaDeVuelta
    method position(nuevaPos) {posicion = nuevaPos}
    method position() = posicion
}
class PuertaDobleLlave inherits Puerta {
    const segundaLlaveRequerida

    override method estaTrabada() =
        super() && juego.existeLlave(segundaLlaveRequerida)
}
    const vacio = new Puerta(
        destino = salaVacia,
        puertaDeVuelta = vacio,
        llaveRequerida = llaveNula
    )

    const puertaInicioPueblo = new Puerta(
        destino = pueblo,
        puertaDeVuelta = puertaPuebloInicio,
        llaveRequerida = llaveNula
    )
    const puertaPuebloInicio = new Puerta(
        destino = inicio,
        puertaDeVuelta = puertaInicioPueblo,
        llaveRequerida = llaveIglesia
    )

    const puertaPuebloIglesia = new Puerta(
        destino = iglesia,
        puertaDeVuelta = puertaIglesiaPueblo,
        llaveRequerida = llaveIglesia
    )
    const puertaIglesiaPueblo = new Puerta(
        destino = pueblo,
        puertaDeVuelta = puertaPuebloIglesia,
        llaveRequerida = llaveNula
    )

    const puertaPuebloMuelle = new Puerta(
        destino = muelle,
        puertaDeVuelta = puertaMuellePueblo,
        llaveRequerida = llaveIglesia
    )
    const puertaMuellePueblo = new Puerta(
        destino = pueblo,
        puertaDeVuelta = puertaPuebloMuelle,
        llaveRequerida = llaveNula
    )

    const puertaPuebloEntradaCastillo = new Puerta(
        destino = entradaCastillo,
        puertaDeVuelta = puertaEntradaCastilloPueblo,
        llaveRequerida = llaveIglesia
    )
    const puertaEntradaCastilloPueblo = new Puerta(
        destino = pueblo,
        puertaDeVuelta = puertaPuebloEntradaCastillo,
        llaveRequerida = llaveNula
    )

    const puertaIglesiaPelado = new Puerta(
        destino = salaJefePelado,
        puertaDeVuelta = puertaPeladoIglesia,
        llaveRequerida = llaveNula
    )
    const puertaPeladoIglesia = new Puerta(
        destino = iglesia,
    puertaDeVuelta = puertaIglesiaPelado,
        llaveRequerida = llavePelado
    )

    const puertaMuelleIsla = new Puerta(
        destino = isla,
        puertaDeVuelta = puertaIslaMuelle,
        llaveRequerida = llaveNula
    )
    const puertaIslaMuelle = new Puerta(
        destino = muelle,
        puertaDeVuelta = puertaMuelleIsla,
        llaveRequerida = llaveNula
    )


    //Puertas del castillo
    const puertaEntradaCastilloCastillo = new Puerta(
        destino = lobbyCastillo,
        puertaDeVuelta = puertaCastilloEntradaCastillo,
        llaveRequerida = llavePelado
    )
    const puertaCastilloEntradaCastillo = new Puerta(
        destino = entradaCastillo,
        puertaDeVuelta = puertaEntradaCastilloCastillo,
        llaveRequerida = llaveNula
    )

    const puertaLobbyLLaveEnano1 =new Puerta(
        destino = salaLlave1,
        puertaDeVuelta = puertaLLaveEnano1Lobby,
        llaveRequerida = llaveNula
    )
  
      const puertaLLaveEnano1Lobby =new Puerta(
        destino = lobbyCastillo,
        puertaDeVuelta = puertaLobbyLLaveEnano1,
        llaveRequerida = llaveNula
    )
    
        const puertaLobbyLLaveEnano2 =new Puerta(
        destino = salaLlave2,
        puertaDeVuelta = puertaLLaveEnano2Lobby,
        llaveRequerida = llaveNula
    )

       const puertaLLaveEnano2Lobby =new Puerta(
        destino = lobbyCastillo,
        puertaDeVuelta = puertaLobbyLLaveEnano2,
        llaveRequerida = llaveNula
    )

    const puertaLobbyJefeEnano = new PuertaDobleLlave(
       destino = salaJefeEnano,
       puertaDeVuelta = puertaJefeEnanoLobby,
       llaveRequerida = llavePreEnano1,
       segundaLlaveRequerida = llavePreEnano2
   )
        
        const puertaJefeEnanoLobby = new Puerta(
            destino = lobbyCastillo,
            puertaDeVuelta = puertaLobbyJefeEnano,
            llaveRequerida = llaveEnano
        )

        const puertaJefeEnanoPasillo0 = new Puerta(
            destino = salaPasillo0,
            puertaDeVuelta = puertaPasillo0JefeEnano,
            llaveRequerida = llaveEnano
        )
        
        const puertaPasillo0JefeEnano = new Puerta(
            destino = salaJefeEnano,
            puertaDeVuelta = puertaJefeEnanoPasillo0,
            llaveRequerida = llaveNula
        )

        const puertaPasillo0Biblioteca = new Puerta(
            destino = bibiloteca,
            puertaDeVuelta = puertaBibliotecaPasillo0,
            llaveRequerida = llaveNula
        )

        const puertaBibliotecaPasillo0 = new Puerta(
                destino = salaPasillo0,
                puertaDeVuelta = puertaPasillo0Biblioteca,
                llaveRequerida = llaveNula
        )

        const puertaPasillo0Pasillo1 = new Puerta(
                destino = salaPasillo1,
                puertaDeVuelta = puertaPasillo1Pasillo0,
                llaveRequerida= llaveNula
        )

        const puertaPasillo1Pasillo0 = new Puerta(
            destino = salaPasillo0,
            puertaDeVuelta = puertaPasillo0Pasillo1,
            llaveRequerida = llaveNula
        )
        
        const puertaPasillo1SalaEscopeta = new Puerta(
            destino = salaEscopeta,
            puertaDeVuelta = puertaSalaEscopetaPasillo1,
            llaveRequerida = llaveNula
        )

        const puertaSalaEscopetaPasillo1 = new Puerta(
            destino = salaPasillo1,
            puertaDeVuelta = puertaPasillo1SalaEscopeta,
            llaveRequerida = llaveNula
        )

         const puertaPasillo1Pasillo2 = new Puerta(
            destino = salaPasillo2,
            puertaDeVuelta = puertaPasillo2Pasillo1,
            llaveRequerida = llaveNula
        )

        const puertaPasillo2Pasillo1 = new Puerta(
            destino = salaPasillo1,
            puertaDeVuelta = puertaPasillo1Pasillo2,
            llaveRequerida = llaveNula
        )

        const puertaPasillo2JefeGordo = new Puerta(
            destino = salaJefeGordo,
            puertaDeVuelta = puertaJefeGordoPasillo2,
            llaveRequerida = llaveNula
        )

        const puertaJefeGordoPasillo2 = new Puerta(
            destino = salaPasillo2,
            puertaDeVuelta = puertaPasillo2JefeGordo,
            llaveRequerida = llaveGordo
        )
