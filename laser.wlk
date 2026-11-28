import wollok.game.*
import armas.*
import interfaz.*
import personaje.*
import mapas.*
import jefePelado.*

class CeldaLaser {
    const property position
    method image() = "laser.png"
    method estaVivo() = false   // para que las balas lo ignoren
}

class Laser {
    const origen
    const direcciones
    const msPorBloque
    const msTrasLimite
    const alTerminar
    const id = municion.siguienteId()
    const celdas = []
    var paso = 0
    var activas = direcciones
    var creciendo = true
    var limiteAlcanzado = false

    method dentro(pos) =
        pos.x() >= 0 && pos.x() < game.width() &&
        pos.y() >= alturaInterfaz && pos.y() < game.height()

    method celdaEn(d) = game.at(origen.x() + d.x() * paso, origen.y() + d.y() * paso)

    method puedeOcupar(pos) = self.dentro(pos) && !mapa.hayPared(pos)

    method lanzar() {
        game.onTick(msPorBloque, "laser" + id, { self.crecer() })
        game.onTick(200, "laserDanio" + id, { self.danar() })
    }

    method crecer() {
        if (creciendo) {
            paso += 1
            const cantidadAntes = activas.size()
            activas = activas.filter({ d => self.puedeOcupar(self.celdaEn(d)) })

            // Primer choque contra una pared: se alcanzó el límite
            if (activas.size() < cantidadAntes && !limiteAlcanzado) {
                self.llegoAlLimite()
            }

            if (activas.isEmpty()) {
                self.dejarDeCrecer()
            } else {
                activas.forEach({ d =>
                    const celda = new CeldaLaser(position = self.celdaEn(d))
                    celdas.add(celda)
                    game.addVisual(celda)
                })
            }
        }
    }

    method llegoAlLimite() {
        limiteAlcanzado = true
        game.schedule(msTrasLimite, { self.apagar() })
    }

    method dejarDeCrecer() {
        if (creciendo) {
            creciendo = false
            game.removeTickEvent("laser" + id)
        }
    }

    method danar() {
        if (celdas.any({ c => c.position() == personaje.position() })) {
            personaje.recibirDanio(1)
        }
    }

    method apagar() {
        self.dejarDeCrecer()
        game.removeTickEvent("laserDanio" + id)
        celdas.forEach({ c => game.removeVisual(c) })
        alTerminar.apply()
    }
}