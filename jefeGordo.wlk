import wollok.game.*
import armas.*
import mapas.*
import personaje.*
import movimiento.*
import maquinaDeEstados.*
import llaves.*

object jefeGordo {
    const vidaMaxima = 5
    var posicion = game.at(11, 14)
    var vida = vidaMaxima
    var estado = estadoSiguiendoGordo     
    var pared = arriba            
    var faseFinal = false
    var rodadasRestantes = 0
    var token = 0
    var direccion = abajo 
    method direccion() = direccion

    method position() = posicion
    method image() = estado.imagen(direccion)
    method estaVivo() = vida > 0
    method vidaActual() = vida
    method faseFinal() = faseFinal

   
    method aparecer() {
        if (!juego.existeLlave(llaveGordo)) {   
            vida = vidaMaxima
            faseFinal = false
            posicion = game.at(11, 14)
            pared = arriba
            game.addVisual(self)
            self.seguir()
        }
    }

    method desaparecer() {
        token += 1                            
        if (game.hasVisual(self)) game.removeVisual(self)
    }

    method nuevoToken() {
        token += 1
        return token
    }

    method seguir() {
        estado = estadoSiguiendoGordo
        self.seguirLinea(self.nuevoToken(), 0)
    }

    method msSeguimiento() = if (faseFinal) 90 else 150
    method pasosMinimos() = if (faseFinal) 2 else 8
    method msAviso() = if (faseFinal) 300 else 800


    method direccionAlineacion() {
        const eje = pared.ejeDeDeslizamiento()
        const mia = eje.coordenada(posicion)
        const suya = eje.coordenada(personaje.position())
        return if (suya > mia) eje.haciaPositivo()
            else if (suya < mia) eje.haciaNegativo()
            else null
    }

    method seguirLinea(t, pasos) {
        if (t == token && self.estaVivo()) {
            const dir = self.direccionAlineacion()
            if (dir == null && pasos >= self.pasosMinimos()) {
            direccion = pared.opuesto()        // el aviso mira hacia la embestida
            game.schedule(self.msAviso(), { if (t == token) self.embestir() })
        } else {
            if (dir != null) self.moverEn(dir)
            game.schedule(self.msSeguimiento(), { self.seguirLinea(t, pasos + 1) })
        }
        }
    }

   method moverEn(dir) {
    const destino = dir.desde(posicion, 1)
    direccion = dir                    // gira aunque no pueda avanzar
    if (mapa.esPiso(destino)) {
        posicion = destino
        self.danarSiTocaJugador()
    }
}

    method danarSiTocaJugador() {
        if (posicion == personaje.position()) personaje.recibirDanio(1)
    }

    method embestir() {
        estado = estadoRodandoGordo 
        direccion = pared.opuesto()
        const t = self.nuevoToken()
        self.avanzarRodada(t, pared.opuesto(), if (faseFinal) 40 else 70)
    }

    method avanzarRodada(t, dir, ms) {
        if (t == token) {
            const siguiente = dir.desde(posicion, 1)
            if (mapa.esPiso(siguiente)) {
                posicion = siguiente
                self.danarSiTocaJugador()
                game.schedule(ms, { self.avanzarRodada(t, dir, ms) })
            } else {
                pared = pared.opuesto()
                self.terminoRodada()
            }
        }
    }

    method terminoRodada() {
        if (faseFinal) {
            rodadasRestantes -= 1
            if (rodadasRestantes > 0) self.seguir() else self.stunear()
        } else {
            self.seguir()
        }
    }


    method stunear() {
        estado = estadoStunGordo
        const t = self.nuevoToken()
        game.schedule(5000, { if (t == token) self.recuperarse() })
    }

    method recuperarse() {
        if (faseFinal) self.rafaga() else self.seguir()
    }

 
    method recibirDanio(cantidad) {
    const conEscopeta = inventario.armaSeleccionada() == escopeta
    estado.recibirDanio(self, cantidad, conEscopeta)
    }

    method perderVida(cantidad) {
        vida = (vida - cantidad).max(0)
        if (!self.estaVivo()) {
            juego.cambiarEstado(gordoDerrotado)
            loot.tirarCorazonDoradinno(posicion)
            //El Gordo se lastró el lanzaPapas
            loot.tirarLanzaGranadas(posicion)               
            self.desaparecer()
        } else if (vida == 1) {
            self.rafaga()
        } else {
            self.entreFases()
        }
    }

    method entreFases() {
        if (vida < vidaMaxima && 0.randomUpTo(1) < 0.5) self.lastrar() else self.seguir()
    }

    method lastrar() {
        estado = estadoLastrandoGordo
        const t = self.nuevoToken()
        loot.tirarBalas(posicion, 2)       // evita el softlock (hay que reventarle el orto a ecopetazo)
        game.schedule(5000, {
            if (t == token) {
                vida = (vida + 1).min(vidaMaxima)
                self.seguir()
            }
        })
    }


    method rafaga() {
        faseFinal = true
        rodadasRestantes = 4
        self.seguir()
    }
}

object estadoSiguiendoGordo {
    method imagen(direccion) = "jefeGordo_siguiendo_" + direccion.nombre() + ".gif"

    method recibirDanio(jefe, cantidad, conEscopeta) {
    }
}

object estadoRodandoGordo {
    method imagen(direccion) =
        "jefeGordo_rodando_" + direccion.nombre() + ".gif"

    method recibirDanio(jefe, cantidad, conEscopeta) {
        if (conEscopeta && !jefe.faseFinal()) {
            jefe.stunear()
        }
    }
}

object estadoStunGordo {
    method imagen(direccion) = "jefeGordo_stun.png"

    method recibirDanio(jefe, cantidad, conEscopeta) {
        if (!conEscopeta) {
            jefe.perderVida(cantidad)
        }
    }
}

object estadoLastrandoGordo {
    method imagen(direccion) =
        "jefeGordo_lastrando_" + direccion.nombre() + ".gif"

    method recibirDanio(jefe, cantidad, conEscopeta) {
        jefe.stunear()
    }
}