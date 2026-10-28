import wollok.game.*
import mapas.*
import personaje.*
import movimiento.*
import enemigo.*

object jefeEnano{
    var posicion = game.at(12, 8)
    var vida = 6
    var estado = estadoClones
    const clones = []
    var pasoClones = 0
    var invulnerable = false
    var cooldownId = 0

    method position() = posicion
    method image() = "jefeEnano.png"
    method estaVivo() = vida > 0
    method vidaActual() = vida
    


    method cambiarEstado(nuevoEstado) {
        estado = nuevoEstado
    }

    method aparecer(){
        vida = 6
        invulnerable = false
        estado = estadoClones
        cooldownId += 1
        game.addVisual(self)
        self.iniciarMovimiento()
        self.iniciarClones()
    }

    method desaparecer() {
        self.detenerMovimiento()
        self.detenerClones()
        game.removeVisual(self)
    }

        method recibirDanio(cantidad) {
        if (self.estaVivo() && !invulnerable) {
            vida = (vida - cantidad).max(0)

            if (!self.estaVivo()) {
                self.desaparecer()
            } else {
                invulnerable = true
                estado.alRecibirDanio(self)

                cooldownId += 1
                const id = cooldownId

                game.schedule(3000, {
                    if (cooldownId == id) {
                        invulnerable = false
                    }
                })
            }
        }
    }

    method crearClones() {
    self.eliminarClones()

    (0..2).forEach({ numero =>
        const clon = new ClonJefeEnano(numero = numero, posicion = self.position())

        clones.add(clon)
        game.addVisual(clon)})
    
    }

    method eliminarClones(){
        clones.forEach({ clon => game.removeVisual(clon) })
        clones.clear()
    }

   method moverClones() {
    const centro = personaje.position()

    const posiciones = [
        centro.up(4),
        centro.up(3).right(3),
        centro.right(4),
        centro.down(3).right(3),
        centro.down(4),
        centro.down(3).left(3),
        centro.left(4),
        centro.up(3).left(3)
    ]

    clones.forEach({ clon =>
        const indice = (pasoClones + clon.numero() * 2) % 8
        const destino = posiciones.get(indice)

        if (clon.estaVivo() && mapa.esPiso(destino)) {
            clon.position(destino)
        }
    })

    pasoClones = (pasoClones + 1) % 8
    }

    method iniciarClones() {
        pasoClones = 0
        self.crearClones()
        self.moverClones()

        game.onTick(400, "movimientoClonesEnano", {
            if (self.estaVivo() && mapa.salaActual() == entradaCastillo) {
                self.moverClones()
            }
        })
    }

    method detenerClones(){
        game.removeTickEvent("movimientoClonesEnano")
        self.eliminarClones()
    }

    method moverA(nuevaPosicion) {
    if (mapa.esPiso(nuevaPosicion) && nuevaPosicion != personaje.position()) {
        posicion = nuevaPosicion
        }
    }

    method perseguir() {
        if (self.estaVivo() && mapa.salaActual() == entradaCastillo) {
            const direcciones = movimiento.direccionesHacia(
                posicion,
                personaje.position()
            )

            const posibles = direcciones.filter({ dir => mapa.esPiso(dir.desde(posicion, 1))})

            if (!posibles.isEmpty()) {
                self.moverA(posibles.first().desde(posicion, 1))
            }
        }
    }   

    method iniciarMovimiento() {
        game.onTick(700, "movimientoJefeEnano", {
            self.perseguir()
        })
    }

    method detenerMovimiento() {
        game.removeTickEvent("movimientoJefeEnano")
    }

}

object estadoClones{
    method alRecibirDanio(jefe){
        jefe.detenerClones()
        jefe.cambiarEstado(estadoTeletransporte)
    }
}

object estadoTeletransporte{
    method alRecibirDanio(jefe){
        jefe.cambiarEstado(estadoClones)
        jefe.iniciarClones()
    }
}

class ClonJefeEnano {
    var posicion
    const numero
    var vivo = true

    method position() = posicion
    method numero() = numero

    method position(nuevaPosicion) {
        posicion = nuevaPosicion
    }

    method image() = "clonesJefeEnano.png"

    method estaVivo() = vivo

    method recibirDanio(cantidad) {
    if (vivo) {
        vivo = false
        game.removeVisual(self)
        spawner.crearZombieEn(posicion)
        }
    }
}

