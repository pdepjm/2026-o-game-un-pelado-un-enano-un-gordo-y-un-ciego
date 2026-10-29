import wollok.game.*
import mapas.*
import personaje.*
import movimiento.*

object faseCuchillo {
    method msMovimiento() = 500
    method msGolpe() = 1500
    method danio() = 1
    method empuje() = 1
    method image() = "krauser.png"
}

object faseMutado {
    method msMovimiento() = 800   
    method msGolpe() = 2000
    method danio() = 2            
    method empuje() = 2
    method image() = "krauserMutado.png"
}

object jefeKrauser {
    const vidaMaxima = 10
    var vida = 10
    var posicion = game.at(12, 8)
    var direccion = abajo
    var fase = faseCuchillo
    var enEscena = false
    var ticksActivos = false

    method position() = posicion
    method image() = fase.image()
    method estaVivo() = vida > 0
    method vidaActual() = vida
    method direccion() = direccion
    method fuerzaEmpuje() = fase.empuje()
    method mutado() = fase == faseMutado

    method activo() = self.estaVivo() && mapa.salaActual() == salaKrauser

    method aparecer() {
        if (self.estaVivo() && !enEscena) {
            enEscena = true
            posicion = game.at(12, 8)
            game.addVisual(self)
            self.programarTicks()
        }
    }

    method desaparecer() {
        if (enEscena) {
            enEscena = false
            self.detenerTicks()
            game.removeVisual(self)
        }
    }

    method programarTicks() {
        self.detenerTicks()
        game.onTick(fase.msMovimiento(), "movimientoKrauser", { self.perseguir() })
        game.onTick(fase.msGolpe(), "golpeKrauser", { self.golpear() })
        ticksActivos = true
    }

    method detenerTicks() {
        if (ticksActivos) {
            game.removeTickEvent("movimientoKrauser")
            game.removeTickEvent("golpeKrauser")
            ticksActivos = false
        }
    }

    method puedeAvanzar(dir) {
        const destino = dir.desde(posicion, 1)
        return destino != personaje.position() && mapa.esPiso(destino)
    }

    method perseguir() {
        if (self.activo()) {
            const preferidas = movimiento.direccionesHacia(posicion, personaje.position())
                .filter({ d => self.puedeAvanzar(d) })
            if (!preferidas.isEmpty()) {
                direccion = preferidas.first()
                posicion = direccion.desde(posicion, 1)
            }
        }
    }

    // golpea cada msGolpe si el jugador esta en una celda adyacente
    method golpear() {
        if (self.activo() && posicion.distance(personaje.position()) <= 1) {
            direccion = movimiento.direccionesHacia(posicion, personaje.position()).first()
            personaje.empujado(self)
            personaje.recibirDanio(fase.danio())
        }
    }

    method recibirDanio(cantidad) {
        if (self.estaVivo()) {
            vida = (vida - cantidad).max(0)
            if (!self.estaVivo()) {
                self.desaparecer()
            } else if (!self.mutado() && vida <= vidaMaxima / 2) {
                self.mutar()
            }
        }
    }

    method mutar() {
        fase = faseMutado
        self.programarTicks()   
    }
}