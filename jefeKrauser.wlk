import wollok.game.*
import maquinaDeEstados.*
import armas.*
import mapas.*
import personaje.*
import movimiento.*
import llaves.*

object faseCuchillo {
    method msMovimiento() = 500
    method msGolpe() = 1500
    method danio() = 1
    method empuje() = 1
    method image(dir) = "krauser_" + dir.nombre() + ".gif"

    method debeMutar(vida, vidaMaxima) = vida <= vidaMaxima / 2
    method siguiente() = faseMutado
}

object faseMutado {
    method msMovimiento() = 800
    method msGolpe() = 2000
    method danio() = 2
    method empuje() = 2
    method image(dir) = "krauser_mutado_" + dir.nombre() + ".gif"

    method debeMutar(vida, vidaMaxima) = false
    method siguiente() = self
}

object jefeKrauser {
    const vidaMaxima = 10
    var vida = vidaMaxima
    var posicion = game.at(12, 8)
    var direccion = abajo
    var fase = faseCuchillo
    var enEscena = false
    var enfriando = false

    method velocidad() = 1
    method position() = posicion
    method image() = fase.image(direccion)
    method estaVivo() = vida > 0
    method vidaActual() = vida
    method direccion() = direccion
    method fuerzaEmpuje() = fase.empuje()


    method aparecer() {
        if (!juego.existeLlave(llaveKrauser)) {
            inventario.soloCuchillo(true)        
            if (!enEscena) {
                enEscena = true
                vida = vidaMaxima
                fase = faseCuchillo
                posicion = game.at(12, 8)
                direccion = abajo
                enfriando = false
                game.addVisual(self)
                self.iniciarTick()
            }
        }
    }

    method desaparecer() {
        inventario.soloCuchillo(false)          
        if (enEscena) {
            enEscena = false
            game.removeTickEvent("krauser")
            game.removeVisual(self)
        }
    }

    method iniciarTick() {
        game.onTick(fase.msMovimiento(), "krauser", { self.actuar() })
    }

  
    method actuar() {
        if (self.estaVivo() && mapa.salaActual() == salaKrauser) {
            if (self.jugadorCerca()) self.golpear() else self.perseguir()
        }
    }

    method jugadorCerca() = posicion.distance(personaje.position()) <= 1

    method puedeAvanzar(dir) {
        const destino = dir.desde(posicion, 1)
        return destino != personaje.position() && mapa.esPiso(destino)
    }

    method perseguir() {
        const preferidas = movimiento.direccionesHacia(posicion, personaje.position())
            .filter({ d => self.puedeAvanzar(d) })
        if (preferidas.isEmpty()) {
            self.mirarAlJugador()
        } else {
            direccion = preferidas.first()
            posicion = direccion.desde(posicion, 1)
        }
    }

    method mirarAlJugador() {
        const hacia = movimiento.direccionesHacia(posicion, personaje.position())
        if (!hacia.isEmpty()) direccion = hacia.first()
    }

    method golpear() {
        if (!enfriando) {
            enfriando = true
            self.mirarAlJugador()                 
            personaje.empujado(self)
            personaje.recibirDanio(fase.danio())
            game.schedule(fase.msGolpe(), { enfriando = false })
        }
    }

    method moverA(pos) {                      
        if (mapa.esPiso(pos) && pos != personaje.position()) posicion = pos
    }

   method recibirDanio(cantidad) {
    if (self.estaVivo()) {
        vida = (vida - cantidad).max(0)
        if (!self.estaVivo()) {
            self.morir()
        } else if (fase.debeMutar(vida, vidaMaxima)) {
            self.mutar()
        }
    }
}

    method mutar() {
        fase = fase.siguiente()
        game.removeTickEvent("krauser")
        self.iniciarTick()
    }

    method morir() {
        juego.cambiarEstado(krauserDerrotado)
        self.desaparecer()
    }
}