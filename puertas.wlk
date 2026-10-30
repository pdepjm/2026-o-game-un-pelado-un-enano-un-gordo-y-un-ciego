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

  
    

  