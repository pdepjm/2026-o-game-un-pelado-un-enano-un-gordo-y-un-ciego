import mapas.*


class Puerta {
    var posicion = game.at(0,0)
    const destino
    const puertaDeVuelta

    method destino() = destino
    method puertaDeVuelta() = puertaDeVuelta
    method position(nuevaPos) {posicion = nuevaPos}
    method position() = posicion
    method image() = "hud_fondo.png"
}

    const puertaAB = new Puerta(destino = salaB, puertaDeVuelta = puertaBA)
    const puertaBA = new Puerta(destino = salaA, puertaDeVuelta = puertaAB)

    const puertaBJefePelado = new Puerta(destino = salaJefePelado, puertaDeVuelta = puertaJefePeladoB)
    const puertaJefePeladoB = new Puerta(destino = salaB,puertaDeVuelta = puertaBJefePelado)