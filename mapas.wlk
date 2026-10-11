import wollok.game.*
import personaje.*

const alturaInterfaz = 1

class Pared {
    const posicion

    method position() = posicion
    method image() = "arboleda.png"   
    method estaVivo() = false
}

class Puerta {
    const posicion
    const id

    method position() = posicion
    method id() = id
    method image() = "hud_fondo.png"   
    method estaVivo() = false
}

class Sala {
    const diseno
    const paredes = []
    const puertas = []
    const conexiones = new Dictionary()   // id de puerta -> [salaDestino, idDestino]


    method conexion(id, destino, idDestino) { conexiones.put(id, [destino, idDestino]) }
    method destinoDe(id) = conexiones.get(id)


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
                } else if (c != " ") {
                    const puerta = new Puerta(posicion = pos, id = c)
                    puertas.add(puerta)
                    game.addVisual(puerta)
                }
            })
        })
    }

    method descargar() {
        paredes.forEach({ p => game.removeVisual(p) })
        puertas.forEach({ p => game.removeVisual(p) })
        paredes.clear()
        puertas.clear()
    }


    method hayPared(pos) = paredes.any({ p => p.position() == pos })
    method puertaEn(pos) = puertas.findOrDefault({ p => p.position() == pos }, null)

    // celda libre pegada a la puerta (donde aparece el personaje al llegar)
    method entradaDe(id) {
        const p = puertas.find({ d => d.id() == id }).position()
        const vecinos = [p.up(1), p.down(1), p.left(1), p.right(1)]
        return vecinos.find({ v => self.esPiso(v) })
    }
}

object mapa {
    var salaActual = null

    method conectar(salaA, idA, salaB, idB) {
        salaA.conexion(idA, salaB, idB)
        salaB.conexion(idB, salaA, idA)
    }

    method empezarEn(sala, posicionInicial) {
        salaActual = sala
        salaActual.cargar()
        personaje.position(posicionInicial)
    }

    method hayPared(pos) = salaActual.hayPared(pos)

    method alPisar(pos) {
        const puerta = salaActual.puertaEn(pos)
        if (puerta != null) { self.cruzar(puerta) }
    }

    method cruzar(puerta) {
        const destino = salaActual.destinoDe(puerta.id())
        const salaDestino = destino.get(0)
        const idDestino = destino.get(1)

        salaActual.descargar()
        salaActual = salaDestino
        salaActual.cargar()
        personaje.position(salaActual.entradaDe(idDestino))
    }
}

// ================= SALAS=================
const salaA = new Sala(diseno = [
    "HHHHHHHHHHH1111111111HHHHHHHH",
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
])

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
])

object nivel {
    method cargar() {
        mapa.conectar(salaA, "1", salaB, "1")   // ida y vuelta
        mapa.empezarEn(salaA, game.center())
    }
}