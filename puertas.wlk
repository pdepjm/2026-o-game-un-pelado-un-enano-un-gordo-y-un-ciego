import mapas.*
import llaves.*
import maquinaDeEstados.juego
import objetosDestructibles.*

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
class PuertaPalancas inherits Puerta {
    override method estaTrabada() = combinacion.correcta()
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
        llaveRequerida = llaveCuerda
    )
    const puertaPeladoIglesia = new Puerta(
        destino = iglesia,
    puertaDeVuelta = puertaIglesiaPelado,
        llaveRequerida = llavePelado
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
            llaveRequerida = llavePreGordo
        )

        const puertaJefeGordoPasillo2 = new Puerta(
            destino = salaPasillo2,
            puertaDeVuelta = puertaPasillo2JefeGordo,
            llaveRequerida = llaveGordo
        )

        //Puertas de la isla de Sandler

        const puertaMuelleEntradaIsla = new Puerta(destino = entradaIsla, puertaDeVuelta = puertaEntradaIslaMuelle, llaveRequerida = llaveNula) 
        const puertaEntradaIslaMuelle = new Puerta(destino = muelle, puertaDeVuelta = puertaMuelleEntradaIsla, llaveRequerida = llaveNula)

        const puertaIslaColumnaNorte = new Puerta(destino = columnaNorte, puertaDeVuelta = puertaColumnaNorteIsla, llaveRequerida = llaveNula)
        const puertaColumnaNorteIsla = new Puerta(destino = entradaIsla, puertaDeVuelta = puertaIslaColumnaNorte, llaveRequerida = llaveNula)

        const puertaIslaColumnaSur = new Puerta(destino = columnaSur, puertaDeVuelta = puertaColumnaSurIsla, llaveRequerida = llaveNula)
        const puertaColumnaSurIsla = new Puerta(destino = entradaIsla, puertaDeVuelta = puertaIslaColumnaSur, llaveRequerida = llaveNula)

        const puertaColumnaNorteSalaVerde = new Puerta(destino = salaVerde, puertaDeVuelta = puertaSalaVerdeColumnaNorte, llaveRequerida = llaveNula)
        const puertaSalaVerdeColumnaNorte = new Puerta(destino = columnaNorte, puertaDeVuelta = puertaColumnaNorteSalaVerde, llaveRequerida = llaveNula)

        const puertaColumnaNortePasilloNorte = new Puerta(destino = pasilloNorte, puertaDeVuelta = puertaPasilloNorteColumnaNorte, llaveRequerida = llaveNula)
        const puertaPasilloNorteColumnaNorte = new Puerta(destino = columnaNorte, puertaDeVuelta = puertaColumnaNortePasilloNorte, llaveRequerida = llaveNula)

        const puertaColumnaSurSalaRoja = new Puerta(destino = salaRoja, puertaDeVuelta = puertaSalaRojaColumnaSur, llaveRequerida = llaveNula)
        const puertaSalaRojaColumnaSur = new Puerta(destino = columnaSur, puertaDeVuelta = puertaColumnaSurSalaRoja, llaveRequerida = llaveNula)

        const puertaColumnaSurPasilloSurOeste = new Puerta(destino = pasilloSurOeste, puertaDeVuelta = puertaPasilloSurOesteColumnaSur, llaveRequerida = llaveNula)
        const puertaPasilloSurOesteColumnaSur = new Puerta(destino = columnaSur, puertaDeVuelta = puertaColumnaSurPasilloSurOeste, llaveRequerida = llaveNula)

        const puertaPasilloNortePasilloCentral = new Puerta(destino = pasilloCentral, puertaDeVuelta = puertaPasilloCentralPasilloNorte, llaveRequerida = llaveNula)
        const puertaPasilloCentralPasilloNorte = new Puerta(destino = pasilloNorte, puertaDeVuelta = puertaPasilloNortePasilloCentral, llaveRequerida = llaveNula)

        const puertaPasilloCentralSalaAzul = new Puerta(destino = salaAzul, puertaDeVuelta = puertaSalaAzulPasilloCentral, llaveRequerida = llaveNula)
        const puertaSalaAzulPasilloCentral = new Puerta(destino = pasilloCentral, puertaDeVuelta = puertaPasilloCentralSalaAzul, llaveRequerida = llaveNula)

        const puertaPasilloCentralPasilloSurOeste = new Puerta(destino = pasilloSurOeste, puertaDeVuelta = puertaPasilloSurOestePasilloCentral, llaveRequerida = llaveNula)
        const puertaPasilloSurOestePasilloCentral = new Puerta(destino = pasilloCentral, puertaDeVuelta = puertaPasilloCentralPasilloSurOeste, llaveRequerida = llaveNula)

        const puertaPasilloSurOestePasilloSurEste = new Puerta(destino = pasilloSurEste, puertaDeVuelta = puertaPasilloSurEstePasilloSurOeste, llaveRequerida = llaveNula)
        const puertaPasilloSurEstePasilloSurOeste = new Puerta(destino = pasilloSurOeste, puertaDeVuelta = puertaPasilloSurOestePasilloSurEste, llaveRequerida = llaveNula)

        const puertaPasilloSurEsteAntesala = new PuertaPalancas(destino = antesalaKrauser, puertaDeVuelta = puertaAntesalaPasilloSurEste, llaveRequerida = llaveNula)
        const puertaAntesalaPasilloSurEste = new Puerta(destino = pasilloSurEste, puertaDeVuelta = puertaPasilloSurEsteAntesala, llaveRequerida = llaveNula)

        const puertaAntesalaKrauser = new Puerta(destino = salaKrauser, puertaDeVuelta = puertaKrauserAntesala, llaveRequerida = llaveNula)
        const puertaKrauserAntesala = new Puerta(destino = antesalaKrauser, puertaDeVuelta = puertaAntesalaKrauser, llaveRequerida = llaveNula)

        const puertaKrauserFinal = new Puerta(destino = salaFinal, puertaDeVuelta = vacio, llaveRequerida = llaveNula)
        const puertaFinalKrauser = new Puerta(destino = salaKrauser, puertaDeVuelta = vacio, llaveRequerida = llaveFinal)
        