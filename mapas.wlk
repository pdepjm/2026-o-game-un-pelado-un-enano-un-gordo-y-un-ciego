import wollok.game.*

const alturaInterfaz = 1


class Pared {
    const posicion

    method position() = posicion
    method image() = "hud_fondo.png"
    method estaVivo() = false
}

object mapa {
    const paredes = []

    method agregarPared(x, y) {
        const pared = new Pared(posicion = game.at(x, y))
        paredes.add(pared)
        game.addVisual(pared)
    }

    method hayPared(pos) = paredes.any({ p => p.position() == pos })
}

