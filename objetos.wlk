import wollok.game.*

object personaje {
    var posicion = game.center()
    var direccion = "abajo"
    const velocidad = 1
    const saludMaxima = 3
    var salud = saludMaxima

    var arma = revolver

    method position() = posicion
    method image() = "personaje_" + direccion + ".png"
    method text() = salud.toString()          // muestra la salud sobre el personaje

    method salud() = salud
    method estaVivo() = salud > 0

    method direccion() = direccion
    method direccion(nuevaDireccion) { direccion = nuevaDireccion }

    method moverArriba() { if (posicion.y() < game.height() - 1) { posicion = posicion.up(velocidad) } }
    method moverAbajo() { if (posicion.y() > 0) { posicion = posicion.down(velocidad) } }
    method moverIzquierda() { if (posicion.x() > 0) { posicion = posicion.left(velocidad) } }
    method moverDerecha() { if (posicion.x() < game.width() - 1) { posicion = posicion.right(velocidad) } }

    method activarMovimiento() {
        const retraso = 100

        const tickArriba = game.tick(retraso, { self.moverArriba() }, false)
        const tickAbajo = game.tick(retraso, { self.moverAbajo() }, false)
        const tickIzquierda = game.tick(retraso, { self.moverIzquierda() }, false)
        const tickDerecha = game.tick(retraso, { self.moverDerecha() }, false)

        keyboard.up().onPressDo({
            self.direccion("arriba")
            tickArriba.start()
        })
        keyboard.up().onReleaseDo({ tickArriba.stop() })

        keyboard.down().onPressDo({
            self.direccion("abajo")
            tickAbajo.start()
        })
        keyboard.down().onReleaseDo({ tickAbajo.stop() })

        keyboard.left().onPressDo({
            self.direccion("izquierda")
            tickIzquierda.start()
        })
        keyboard.left().onReleaseDo({ tickIzquierda.stop() })

        keyboard.right().onPressDo({
            self.direccion("derecha")
            tickDerecha.start()
        })
        keyboard.right().onReleaseDo({ tickDerecha.stop() })
    }

    method activarDisparo() {
        
        keyboard.x().onPressDo({arma.disparar()})
    }

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

/*
    ADVERTENCIA:
    Al ser proyectil un objeto único, cuando se dispara y se llama a addVisual existe la posibilidad
    de que el objeto ya haya sido agregado a la pantalla, por lo cual se debe buscar una solución,
    posiblemente con proyectiles independientes
*/
object proyectil {
    const imagen = "goat.png"
    var posicion = game.at(0,0)
    var direccionAvance = game.at(0, 0)
    var distanciaRecorrida = 1 //esta variable tiene un nombre largo, excesivamente largo, no deberia ser tan largo, pero voy a hacerlo largo, quiero hacerlo largo, tan largo como yo quiera, aunque solo almace un numero, no me importa, será largo, tan largo como yo quiera, porque si quiero hacerlo largo, lo hago largo, no me imnporta lo que vos quieras, largo, largo, largo
    var distanciaMaxima = 0
    var velocidad = 4

    method retraso() = 100/velocidad //alonso
    const tickAvance = game.tick(self.retraso(), {self.confirmarAvance()}, false)


    method position(nuevaPos) {posicion = nuevaPos}
    method position() = posicion
    method image() = imagen

    method avanzar(direccion, alcance, velProyectil) {
        direccionAvance = direccion
        distanciaMaxima = alcance
        velocidad = velProyectil
        tickAvance.start()
    }

    method confirmarAvance() {
        if (distanciaRecorrida < distanciaMaxima) {
            self.position(game.at(posicion.x()+direccionAvance.x(), posicion.y()+direccionAvance.y()))
            distanciaRecorrida += 1
        } else {
            tickAvance.stop()
            distanciaMaxima = 0
            distanciaRecorrida = 1
            game.removeVisual(self)
        }
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

class Arma {
    const alcance
    const velProyectil

    var pausa = false

    method disparar() {
        if (!pausa) {
            self.pausar()
            game.addVisual(proyectil)
            if (personaje.direccion() == "arriba") {
                proyectil.position(game.at(personaje.position().x(), personaje.position().y() + 1))
                proyectil.avanzar(game.at(0, 1), alcance, velProyectil)
            }
            if (personaje.direccion() == "abajo") { 
                proyectil.position(game.at(personaje.position().x(), personaje.position().y() - 1))
                proyectil.avanzar(game.at(0, -1), alcance, velProyectil)
            }
            if (personaje.direccion() == "izquierda") {
                proyectil.position(game.at(personaje.position().x() - 1, personaje.position().y()))
                proyectil.avanzar(game.at(-1, 0), alcance, velProyectil)
            }
            if (personaje.direccion() == "derecha") {
                proyectil.position(game.at(personaje.position().x() + 1, personaje.position().y()))
                proyectil.avanzar(game.at(1, 0), alcance, velProyectil)
            }
        }
    }
    method pausar() {
        pausa = true
        game.schedule(150, { pausa = false })
    }
}

const cuchillo = new Arma(
    alcance = 1,
    velProyectil = 2
)

const revolver = new Arma(
    alcance = 5,
    velProyectil = 4
)

const zombie = new Enemigo(
    nombre = "zombie",
    imagen = "spiderodo_128x128.png",
    danio = 1,
    fuerzaEmpuje = 1,
    posicion = game.at(5, 5)
)