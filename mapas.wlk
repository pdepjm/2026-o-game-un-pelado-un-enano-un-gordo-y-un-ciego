import wollok.game.*
import personaje.*
import puertas.*
import interfaz.alturaInterfaz
import enemigo.*
class Pared {
    const posicion

    method position() = posicion
    method image() = "arboleda.png"
    method estaVivo() = false
}

class Sala {
    const diseno
    const paredes = []
    
    const puerta1
    const puerta2
    const puerta3
    const puerta4

    method caracterEn(pos) {
        const filas = diseno.size()
        const fila = filas - 1 - (pos.y() - alturaInterfaz)
        if (fila < 0 || fila >= filas || pos.x() < 0 || pos.x() >= diseno.get(fila).length()) {
            return "H"
        }
        return diseno.get(fila).charAt(pos.x())
    }

    method esPiso(pos) = self.caracterEn(pos) == " "


    method cargar() {
        const filas = diseno.size()
        (0..filas - 1).forEach({ fila =>
            const linea = diseno.get(fila)
            const y = alturaInterfaz + (filas - 1 - fila)
            (0..linea.length() - 1).forEach({ x =>
                const c = linea.charAt(x)
                const pos = game.at(x, y)
                if (c == "H") {
                    const pared = new Pared(posicion = pos)
                    paredes.add(pared)
                    game.addVisual(pared)
                } else if (c == "1") {
                    puerta1.position(pos)
                    game.addVisual(puerta1)
                } else if (c == "2") {
                    puerta2.position(pos)
                    game.addVisual(puerta2)
                } else if (c == "3") {
                    puerta3.position(pos)
                    game.addVisual(puerta3)
                } else if (c == "4") {
                    puerta4.position(pos)
                    game.addVisual(puerta4)
                }
            })
        })
    }

    method descargar() {
        paredes.forEach({ p => game.removeVisual(p) })
        game.removeVisual(puerta1)
        game.removeVisual(puerta2)
        game.removeVisual(puerta3)
        game.removeVisual(puerta4)

        paredes.clear()
    }


    method hayPared(pos) = paredes.any({ p => p.position() == pos })
    method puertaEn(pos) = 
        if (puerta1 != null && puerta1.position() == pos) puerta1
        else if (puerta2 != null && puerta2.position() == pos) puerta2
        else if (puerta3 != null && puerta3.position() == pos) puerta3
        else if (puerta4 != null && puerta4.position() == pos) puerta4
        else null

    // celda libre pegada a la puerta (donde aparece el personaje al llegar)
    method entradaDe(puerta) {
        const p = puerta.position()
        const vecinos = [p.up(1), p.down(1), p.left(1), p.right(1)]
        return vecinos.find({ v => self.esPiso(v) })
    }
}

object mapa {
    var salaActual = null

    method empezarEn(sala, posicionInicial) {
        salaActual = sala
        salaActual.cargar()
        personaje.position(posicionInicial)
    }

    method hayPared(pos) = salaActual.hayPared(pos)
    method esPiso(pos) = salaActual.esPiso(pos)

    method alPisar(pos) {
        const puerta = salaActual.puertaEn(pos)
        if (puerta != null) { self.cruzar(puerta) }
    }

    method cruzar(puerta) {
        const destino = puerta.destino()
        spawner.limpiar()
        salaActual.descargar()
        salaActual = destino
        salaActual.cargar()
        personaje.position(salaActual.entradaDe(puerta.puertaDeVuelta()))
        spawner.crearZombiesAleatorios()
    }
}

// ================= SALAS=================
const salaA = new Sala(diseno = [
    "HHHHHHHHHHH1HHHHHHHHHHHH",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                       H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                       H",
    "H                      H",
    "H                      H",
    "H                      H",
    "                                                             "
    ],
    puerta1 = puertaAB,
    puerta2 = null,
    puerta3 = null,
    puerta4 = null)

const salaB = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "H                      H",
    "H                      H",
    "H                      H",
    "H    HHH               H",
    "H                      H",
    "H                      H",
    "1                      H",
    "H                      H",
    "H                      H",
    "H    HHH               H",
    "H                      H",
    "H                      H",
    "H                      H",
    "                                                                   "
    ],
    puerta1 = puertaBA,
    puerta2 = null,
    puerta3 = null,
    puerta4 = null)

object nivel {
    method cargar() {
        mapa.empezarEn(salaA, game.center())
    }
}