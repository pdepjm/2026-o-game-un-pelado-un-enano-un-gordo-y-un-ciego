import wollok.game.*

object personaje {
    var posicion = game.center()
    var direccion = "abajo"
    const velocidad = 1
    const saludMaxima = 3
    var salud = saludMaxima

    method position() = posicion
    method image() = "personaje_" + direccion + ".png"
    method text() = salud.toString()          // muestra la salud sobre el personaje

    method salud() = salud
    method estaVivo() = salud > 0

    method direccion(nuevaDireccion) { direccion = nuevaDireccion }

    method moverArriba() { if (posicion.y() < game.height() - 1) { posicion = posicion.up(velocidad) } }
    method moverAbajo() { if (posicion.y() > 0) { posicion = posicion.down(velocidad) } }
    method moverIzquierda() { if (posicion.x() > 0) { posicion = posicion.left(velocidad) } }
    method moverDerecha() { if (posicion.x() < game.width() - 1) { posicion = posicion.right(velocidad) } }

    method empujado(enemigo) {
        self.empujar(enemigo.direccion(), enemigo.fuerzaEmpuje())
    }

    method empujar(direccionEmpuje, fuerza) {
        (1..fuerza).forEach({ i =>
            if (direccionEmpuje == "arriba") { self.moverArriba() }
            if (direccionEmpuje == "abajo") { self.moverAbajo() }
            if (direccionEmpuje == "izquierda") { self.moverIzquierda() }
            if (direccionEmpuje == "derecha") { self.moverDerecha() }
        })
    }

    method recibirDanio(cantidad) {
        if (self.estaVivo()) {
            salud = (salud - cantidad).max(0)
            if (!self.estaVivo()) { self.morido() }
        }
    }

    method morido() {
        game.schedule(15, { game.stop() })
    }
}

class Enemigo {
    const nombre               
    const imagen
    const danio
    const fuerzaEmpuje
    var posicion
    var direccion = "abajo"
    var pausa = false

    method position() = posicion
    method image() = imagen
    method direccion() = direccion
    method danio() = danio
    method fuerzaEmpuje() = fuerzaEmpuje

    method activar() {
        game.onTick(500, "movimiento" + nombre, { self.perseguir() })
    }

    method perseguir() {
        if (!pausa) {
            const objetivo = personaje.position()
            if (objetivo.x() > posicion.x()) {
                self.intentarMover(posicion.right(1), "derecha")
            } else if (objetivo.x() < posicion.x()) {
                self.intentarMover(posicion.left(1), "izquierda")
            } else if (objetivo.y() > posicion.y()) {
                self.intentarMover(posicion.up(1), "arriba")
            } else if (objetivo.y() < posicion.y()) {
                self.intentarMover(posicion.down(1), "abajo")
            }
        }
    }

    method intentarMover(nuevaPosicion, nuevaDireccion) {
        direccion = nuevaDireccion
        if (nuevaPosicion == personaje.position()) {
            self.atacar()
        } else {
            posicion = nuevaPosicion
        }
    }

    method atacar() {
        personaje.recibirDanio(danio)
        personaje.empujado(self)
        self.pausar()
    }

    method pausar() {
        pausa = true
        game.schedule(1000, { pausa = false })
    }
}

const zombie = new Enemigo(
    nombre = "zombie",
    imagen = "spiderodo_128x128.png",
    danio = 1,
    fuerzaEmpuje = 1,
    posicion = game.at(5, 5)
)