import mapas.*
import llaves.*
import maquinaDeEstados.juego

class Puerta {
    var posicion = game.at(0,0)

    const destino
    const puertaDeVuelta
    const llaveRequerida

    method estaTrabada() = juego.existeLlave(llaveRequerida)

    method destino() = destino
    method puertaDeVuelta() = puertaDeVuelta
    method position(nuevaPos) {posicion = nuevaPos}
    method position() = posicion
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
        llaveRequerida = llaveEnano
    )
    const puertaMuellePueblo = new Puerta(
        destino = pueblo,
        puertaDeVuelta = puertaPuebloMuelle,
        llaveRequerida = llaveNula
    )

    const puertaPuebloEntradaCastillo = new Puerta(
        destino = entradaCastillo,
        puertaDeVuelta = puertaEntradaCastilloPueblo,
        llaveRequerida = llavePelado
    )
    const puertaEntradaCastilloPueblo = new Puerta(
        destino = pueblo,
        puertaDeVuelta = puertaPuebloEntradaCastillo,
        llaveRequerida = llaveEnano
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

    const puertaEntradaCastilloCastillo = new Puerta(
        destino = castillo,
        puertaDeVuelta = puertaCastilloEntradaCastillo,
        llaveRequerida = llaveNula
    )
    const puertaCastilloEntradaCastillo = new Puerta(
        destino = entradaCastillo,
        puertaDeVuelta = puertaEntradaCastilloCastillo,
        llaveRequerida = llaveNula
    )


//Puertas de la isla
const puertaCastilloColumnaNorte = new Puerta(destino = columnaNorte, puertaDeVuelta = puertaColumnaNorteCastillo, llaveRequerida = llaveNula)
const puertaColumnaNorteCastillo = new Puerta(destino = castillo, puertaDeVuelta = puertaCastilloColumnaNorte, llaveRequerida = llaveNula)

const puertaCastilloColumnaSur = new Puerta(destino = columnaSur, puertaDeVuelta = puertaColumnaSurCastillo, llaveRequerida = llaveNula)
const puertaColumnaSurCastillo = new Puerta(destino = castillo, puertaDeVuelta = puertaCastilloColumnaSur, llaveRequerida = llaveNula)

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

const puertaPasilloSurEsteAntesala = new Puerta(destino = antesalaKrauser, puertaDeVuelta = puertaAntesalaPasilloSurEste, llaveRequerida = llaveNula)
const puertaAntesalaPasilloSurEste = new Puerta(destino = pasilloSurEste, puertaDeVuelta = puertaPasilloSurEsteAntesala, llaveRequerida = llaveNula)

const puertaAntesalaKrauser = new Puerta(destino = salaKrauser, puertaDeVuelta = puertaKrauserAntesala, llaveRequerida = llaveNula)
const puertaKrauserAntesala = new Puerta(destino = antesalaKrauser, puertaDeVuelta = puertaAntesalaKrauser, llaveRequerida = llaveNula)
    

  