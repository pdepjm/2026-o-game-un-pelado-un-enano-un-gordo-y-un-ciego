import wollok.game.*
import armas.*
import laser.*

object jefePelado {
    var posicion = game.at(12, 8)
    var vida = 5
    var brillando = true
    var faseFinalUsada = false
    var rafagaActiva = false

    const cruz = [game.at(0, 1), game.at(0, -1), game.at(1, 0), game.at(-1, 0)]
    const equis = [game.at(1, 1), game.at(1, -1), game.at(-1, 1), game.at(-1, -1)]

    method position() = posicion
    method image() = "fotoPruebaJefePelado.png"
    method estaVivo() = vida > 0
    method vidaActual() = vida
    method reflejaBalas() = brillando

    method recibirDanio(cantidad) {
        if (self.estaVivo() && !brillando) {
            vida = (vida - cantidad).max(0)
            if (!self.estaVivo()) self.desaparecer()
        }
    }

    method aparecer() {
        vida = 5
        brillando = true
        faseFinalUsada = false
        game.addVisual(self)
        // Ventana vulnerable de 3 s cada 10 s
        game.onTick(10000, "brilloJefe", {
            brillando = false
            game.schedule(3000, { brillando = true })
        })
        game.schedule(2000, { self.siguienteAtaque() })
    }

    method desaparecer() {
        game.removeTickEvent("brilloJefe")
        game.removeVisual(self)
    }

    method lanzarLaser(direcciones, msPorBloque, msTrasLimite, alTerminar) {
        new Laser(
            origen = posicion,
            direcciones = direcciones,
            msPorBloque = msPorBloque,
            msTrasLimite = msTrasLimite,
            alTerminar = alTerminar
        ).lanzar()
    }

    method siguienteAtaque() {
        if (self.estaVivo()) {
            if (vida == 1 && !faseFinalUsada) {
                self.faseFinal()
            } else {
                // 2000 ms por bloque = 0,5 bloques/seg
                self.lanzarLaser([cruz, equis].anyOne(), 500, 3000,
                    { game.schedule(5000, { self.siguienteAtaque() }) })
            }
        }
    }

    method faseFinal() {
        faseFinalUsada = true
        rafagaActiva = true
        game.schedule(10000, { rafagaActiva = false })
        self.alternar(0)
    }

    method alternar(i) {
        if (self.estaVivo()) {
            if (rafagaActiva) {
                // En la ráfaga los láseres son más rápidos para que entren varios en 10 s
                self.lanzarLaser([cruz, equis].get(i % 2), 400, 500, { self.alternar(i + 1) })
            } else {
                game.schedule(2000, { self.siguienteAtaque() })
            }
        }
    }
}