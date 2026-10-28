import mapas.*


class Puerta {
    var posicion = game.at(0,0)
    var trabada = false

    const destino
    const puertaDeVuelta

    method trabar() {trabada = true}
    method destrabar() {trabada = false}
    method estaTrabada() = trabada

    method destino() = destino
    method puertaDeVuelta() = puertaDeVuelta
    method position(nuevaPos) {posicion = nuevaPos}
    method position() = posicion
}

    const vacio = new Puerta(destino = salaVacia, puertaDeVuelta = vacio)

    const puertaInicioPueblo = new Puerta(destino = pueblo, puertaDeVuelta = puertaPuebloInicio)
    const puertaPuebloInicio = new Puerta(destino = inicio, puertaDeVuelta = puertaInicioPueblo)

    const puertaPuebloIglesia = new Puerta(destino = iglesia, puertaDeVuelta = puertaIglesiaPueblo)
    const puertaIglesiaPueblo = new Puerta(destino = pueblo, puertaDeVuelta = puertaPuebloIglesia)

    const puertaPuebloMuelle = new Puerta(destino = muelle, puertaDeVuelta = puertaMuellePueblo)
    const puertaMuellePueblo = new Puerta(destino = pueblo, puertaDeVuelta = puertaPuebloMuelle)

    const puertaPuebloEntradaCastillo = new Puerta(destino = entradaCastillo, puertaDeVuelta = puertaEntradaCastilloPueblo)
    const puertaEntradaCastilloPueblo = new Puerta(destino = pueblo, puertaDeVuelta = puertaPuebloEntradaCastillo)

    const puertaIglesiaPelado = new Puerta(destino = salaJefePelado, puertaDeVuelta = puertaPeladoIglesia)
    const puertaPeladoIglesia = new Puerta(destino = iglesia, puertaDeVuelta = puertaIglesiaPelado)

    const puertaMuelleIsla = new Puerta(destino = isla, puertaDeVuelta = puertaIslaMuelle)
    const puertaIslaMuelle = new Puerta(destino = muelle, puertaDeVuelta = puertaMuelleIsla)

    const puertaEntradaCastilloCastillo = new Puerta(destino = castillo, puertaDeVuelta = puertaCastilloEntradaCastillo)
    const puertaCastilloEntradaCastillo = new Puerta(destino = entradaCastillo, puertaDeVuelta = puertaEntradaCastilloCastillo)

  
    

  