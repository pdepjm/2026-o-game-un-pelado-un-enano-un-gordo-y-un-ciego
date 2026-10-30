import wollok.game.*
import mapas.*
import personaje.*
import movimiento.*
import enemigo.*
import maquinaDeEstados.*


object jefeEnano {
    var posicion = game.at(12, 8)
    var vida = 6
    var estado = estadoClones
    const clones = []
    var ruta = []
    var indice = 0
    var invulnerable = false
    var cooldownId = 0
    var enEscena = false
    const msPorCelda = 400 
    const msTeletransporte = 5000

    method position() = posicion
    method image() = "jefeEnano.png"
    method estaVivo() = vida > 0
    method vidaActual() = vida

method cambiarEstado(nuevoEstado) {
    estado.salir(self)
    estado = nuevoEstado
    estado.entrar(self)
}


method detenerClones() { self.eliminarClones() }


method aparecer() {
    if (!juego.existeLlave(llaves.llaveEnano)){
        vida = 6
        invulnerable = false
        cooldownId += 1
        ruta = entradaCastillo.recorridoPerimetral()
        indice = 0
        posicion = ruta.get(0)
        enEscena = true
        game.addVisual(self)
        estado = estadoClones
        estado.entrar(self)
        game.onTick(msPorCelda, "carreraEnano", { self.correr() })
    }
}

method desaparecer() {
    if (enEscena) {
        enEscena = false
        game.removeTickEvent("carreraEnano")
        estado.salir(self)
        game.removeVisual(self)
    }
}
method correr() {
    if (self.estaVivo() && mapa.salaActual() == entradaCastillo) {
        estado.alCorrer(self)
    }
}

method avanzarEnRuta() {
    indice = (indice + 1) % ruta.size()
    posicion = ruta.get(indice)
    self.tePegaSiTeToka(self)

    clones.filter({ c => c.estaVivo() }).forEach({ c =>
        const separacion = (ruta.size() * (c.numero() + 1) / 4).truncate(0)
        c.position(ruta.get((indice + separacion) % ruta.size()))
        self.tePegaSiTeToka(c)
    })
}
    method tePegaSiTeToka(quien) {
        if (quien.position() == personaje.position()) {
            personaje.recibirDanio(1)
        }
    }

    method recibirDanio(cantidad) {
        if (self.estaVivo() && !invulnerable) {
            vida = (vida - cantidad).max(0)
            if (!self.estaVivo()) {
                juego.cambiarEstado(enanoDerrotado)
                self.desaparecer()
            } else {
                invulnerable = true
                estado.alRecibirDanio(self)
                cooldownId += 1
                const id = cooldownId
                game.schedule(1000, { if (cooldownId == id) invulnerable = false })
            }
        }
    }

    method crearClones() {
        self.eliminarClones()
        (0..2).forEach({ numero =>
            const clon = new ClonJefeEnano(numero = numero, posicion = ruta.get(0))
            clones.add(clon)
            game.addVisual(clon)
        })
    }

    method eliminarClones() {
        clones.filter({ c => c.estaVivo() }).forEach({ c => game.removeVisual(c) })
        clones.clear()
    }

method iniciarTeletransporte() {
    game.onTick(msTeletransporte, "teletransporteEnano", { self.teletransportar() })
}

method detenerTeletransporte() {
    game.removeTickEvent("teletransporteEnano")
}
method teletransportar() {
    if (self.estaVivo() && mapa.salaActual() == entradaCastillo) {
        const origen = posicion
        posicion = spawner.posicionAleatoria()
        spawner.crearZombieEn(origen)
    }
}

method iniciarClones() {
    var mejor = 0
    var mejorDistancia = ruta.get(0).distance(posicion)
    (1..ruta.size() - 1).forEach({ i =>
        const d = ruta.get(i).distance(posicion)
        if (d < mejorDistancia) {
            mejor = i
            mejorDistancia = d
        }
    })
    indice = mejor
    posicion = ruta.get(indice)
    self.crearClones()
}
}

object estadoClones {
    method entrar(jefe) { jefe.iniciarClones() }
    method salir(jefe) { jefe.detenerClones() }
    method alCorrer(jefe) { jefe.avanzarEnRuta() }
    method alRecibirDanio(jefe) { jefe.cambiarEstado(estadoTeletransporte) }
}

object estadoTeletransporte {
    method entrar(jefe) { jefe.iniciarTeletransporte() }
    method salir(jefe) { jefe.detenerTeletransporte() }
    method alCorrer(jefe) { }
    method alRecibirDanio(jefe) { jefe.cambiarEstado(estadoClones) }
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

