import wollok.game.*
import personaje.*
import puertas.*
import interfaz.alturaInterfaz
import enemigo.*
import jefePelado.*
import jefeEnano.*
import jefeKrauser.*
import emboscadaPueblo.*
class Pared {
    const posicion

    method position() = posicion
    method image() = "hud_fondo.png"
    method estaVivo() = false
}

class Pozo {
    const posicion

    method position() = posicion
    method image() = "hud_fondo.png"  
    method estaVivo() = false
}

class Sala {
    const diseno
    const jefe
    const paredes = []
    const pozos = []

    const zombisAleatorios

    method jefe() = jefe

    method zombisAleatorios() = zombisAleatorios

    method hayPozo(pos) = pozos.any({ p => p.position() == pos })
    
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
                } else if (c == "P") {
                    const pozo = new Pozo(posicion = pos)
                    pozos.add(pozo)
                    game.addVisual(pozo)
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
        pozos.forEach({ p => game.removeVisual(p) })
        game.removeVisual(puerta1)
        game.removeVisual(puerta2)
        game.removeVisual(puerta3)
        game.removeVisual(puerta4)

        paredes.clear()
    }


    method hayPared(pos) = paredes.any({ p => p.position() == pos })
    method puertaEn(pos) = 
        if (puerta1 != vacio && puerta1.position() == pos) puerta1
        else if (puerta2 != vacio && puerta2.position() == pos) puerta2
        else if (puerta3 != vacio && puerta3.position() == pos) puerta3
        else if (puerta4 != vacio && puerta4.position() == pos) puerta4
        else vacio

    // celda libre pegada a la puerta (donde aparece el personaje al llegar)
    method entradaDe(puerta) {
        const p = puerta.position()
        const vecinos = [p.up(1), p.down(1), p.left(1), p.right(1)]
        return vecinos.find({ v => self.esPiso(v) })
    }

    method recorridoPerimetral() {
    const xMin = 1
    const xMax = diseno.first().length() - 2
    const yMin = alturaInterfaz + 1
    const yMax = alturaInterfaz + diseno.size() - 2

    const ruta = []
    (xMin..xMax).forEach({ x => ruta.add(game.at(x, yMin)) })                              // abajo, de izq. a der.
    ((yMin + 1)..yMax).forEach({ y => ruta.add(game.at(xMax, y)) })                        // derecha, subiendo
    (xMin..(xMax - 1)).asList().reverse().forEach({ x => ruta.add(game.at(x, yMax)) })     // arriba, de der. a izq.
    ((yMin + 1)..(yMax - 1)).asList().reverse().forEach({ y => ruta.add(game.at(xMin, y)) }) // izquierda, bajando
    return ruta.filter({ p => self.esPiso(p) })
}

    method puertaBloqueadaEn(pos) = self.puertaEn(pos) != vacio && !self.puertaEn(pos).estaTrabada()

}

object jefeNulo {
    method aparecer() {}
    method desaparecer() {}
}

object mapa {
    var salaActual = salaVacia
    const itemsEnSuelo = []

    
    method salaActual() = salaActual

    method empezarEn(sala, posicionInicial) {
        salaActual = sala
        salaActual.cargar()
        personaje.position(posicionInicial)
    }

    method hayPared(pos) = salaActual.hayPared(pos)
    method esPiso(pos) = salaActual.esPiso(pos)

    method hayPozo(pos) = salaActual.hayPozo(pos)
    method bloqueaJugador(pos) = self.hayPared(pos) || self.hayPozo(pos) || salaActual.puertaBloqueadaEn(pos)

method alPisar(pos) {
    const puerta = salaActual.puertaEn(pos)
    if (puerta != vacio) {
        if (!salaActual.puertaBloqueadaEn(pos)) { self.cruzar(puerta) }
    }
    const items = itemsEnSuelo.filter({ i => i.position() == pos })
        items.forEach({ i =>i.alPisar() itemsEnSuelo.remove(i)})
}
    method agregarItem(item) { itemsEnSuelo.add(item) }

    method cruzar(puerta) {
    const destino = puerta.destino()

    spawner.limpiar()

    salaActual.jefe().desaparecer()

    salaActual.descargar()
    salaActual = destino
    salaActual.cargar()

    personaje.position(salaActual.entradaDe(puerta.puertaDeVuelta()))

    salaActual.jefe().aparecer()

    if (salaActual.zombisAleatorios()) {
        spawner.crearZombiesAleatorios()
    }
}
    
}



// ================= SALAS=================

const salaVacia = new Sala (
    diseno = [""],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = vacio,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio
)

const inicio = new Sala(diseno = [
    "HHHHHHHHHHHHH1HHHHHHHHHH",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H",
    "H                      H"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = puertaInicioPueblo,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio)

const pueblo = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHH4HHHH",
    "H                      H",
    "H    HHH               H",
    "H    HHH               H",
    "H    H2H               H",
    "H                      H",
    "H              HHH     H",
    "H              HHH     H",
    "H              HHH     H",
    "H                      H",
    "H    HHH               H",
    "H    HHH               3",
    "H                      H",
    "H                      H",
    "HHHHHHHHHHH1HHHHHHHHHHHHHH"
    ],
    jefe = emboscadaPueblo,
    zombisAleatorios = true,
    puerta1 = puertaPuebloInicio,
    puerta2 = puertaPuebloIglesia,
    puerta3 = puertaPuebloMuelle,
    puerta4 = puertaPuebloEntradaCastillo) //odio que sea un nombre tan largo, pero este chiste ya lo hice y nadie lo borró, así que no voy a volver a hacer lo mismo porque eso sería desconsiderado de mi parte y no me parece que tenga que ser de esta manera para el equipo de ayudantes de la cursada de Paradigmas de Programación, ya que ellos han sido muy buenas personas y buenos catedráticos, los quiero mucho Atte: Lechuza-N

const iglesia = new Sala(diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH      2      HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH      1      HHHHHHH",
        "HHHHHH             HHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = puertaIglesiaPueblo,
    puerta2 = puertaIglesiaPelado,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaJefePelado = new Sala(diseno = [
        "HHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHHHHH 1           HHHHHHHH",
        "HHHHHH             HHHHHHHH",
        "HHHHHH             HHHHHHHH",
        "HHHHHH             HHHHHHHH",
        "HHHHHH             HHHHHHHH",
        "HHHHHH     PPP     HHHHHHHH",
        "HHHHHH     P P     HHHHHHHH",
        "HHHHHH     PPP     HHHHHHHH",
        "HHHHHH             HHHHHHHH",
        "HHHHHH             HHHHHHHH",
        "HHHHHH             HHHHHHHH",
        "HHHHHH             HHHHHHHH",
        "HHHHHH             HHHHHHHH"
    ],
    jefe = jefePelado,
   zombisAleatorios = false,
    puerta1 = puertaPeladoIglesia,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio)

const muelle = new Sala(diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "H                      H",
        "H                      H",
        "H                      H",
        "H                      2",
        "H                      H",
        "H                      H",
        "H                      H",
        "H                      H",
        "H                      H",
        "H                      H",
        "1                      H",
        "H                      H",
        "H                      H",
        "HHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = true,
    puerta1 = puertaMuellePueblo,
    puerta2 = puertaMuelleIsla,
    puerta3 = vacio,
    puerta4 = vacio
)

const entradaCastillo = new Sala(diseno = [
        "HHHHHHHHHHHH2HHHHHHHHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHH              HHHHH",
        "HHHHHHHHHHHHH1HHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = puertaEntradaCastilloPueblo,
    puerta2 = puertaEntradaCastilloCastillo,
    puerta3 = vacio,
    puerta4 = vacio
)
const lobbyCastillo = new Sala(diseno = [
        "HHHHHHHHHHHHH4HHHHHHHHHHH",
        "H                      H",
        "H                      H",
        "H                      H",
        "H                      H",
        "H                      H",
        "H                      H",
        "H                      H",
        "2                      3",
        "H                      H",
        "H                      H",
        "H                      H",
        "H                      H",
        "H                      H",
        "HHHHHHHHHHHHH1HHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = puertaCastilloEntradaCastillo,
    puerta2 = puertaLobbyLLaveEnano1,
    puerta3 = puertaLobbyLLaveEnano2,
    puerta4 = puertaLobbyJefeEnano
)


const salaLlave1 =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  1HH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = true,
    puerta1 = puertaLLaveEnano1Lobby,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaLlave2 =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HH1                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = true,
    puerta1 = puertaLLaveEnano2Lobby,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaJefeEnano =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHH2HHHHHHHHHH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HHHHHHHHHHHHH1HHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeEnano,
    zombisAleatorios = false,
    puerta1 = puertaJefeEnanoLobby,
    puerta2 = puertaJefeEnanoPasillo0,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaPasillo0 =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHH                  HHH",
        "HH2                  3HH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHHHHH1HHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = puertaPasillo0JefeEnano,
    puerta2 = puertaPasillo0Biblioteca,
    puerta3 = puertaPasillo0Pasillo1,
    puerta4 = vacio
)
const bibiloteca =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHH                  HHH",
        "HHH       HHHH       HHH",
        "HHH       HHHH       1HH",
        "HHH       HHHH       HHH",
        "HHH                  HHH",
        "HHH          HHHHHHHHHHH",
        "HHH          HHHHHHHHHHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHH             HHH",
        "HHHHHHHH            HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHHHHH1HHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = puertaBibliotecaPasillo0,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaPasillo1 =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HH1                  3HH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHHH            HHH",
        "HHHHHHHHH            HHH",
        "HHHHHHHHH            HHH",
        "HHHHHHHHHHH2HHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = puertaPasillo1Pasillo0,
    puerta2 = puertaPasillo1Pasillo2,
    puerta3 = puertaPasillo1SalaEscopeta,
    puerta4 = vacio
)

const salaEscopeta =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HH1                   HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = puertaSalaEscopetaPasillo1,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaPasillo2 =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHH1HHHHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH      HHHHHHHHHHH",
        "HHH      HHHHHHHHHHH",
        "HHH      HHHHHHHHHHH",
        "HHH      HHHHHHHHHHH",
        "HHH      HHHHHHHHHHH",
        "HHH      HHHHHHHHHHH",
        "HHH                  HHH",
        "HHH                  2HH",
        "HHH                  HHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = puertaPasillo2Pasillo1,
    puerta2 = puertaPasillo2JefeGordo,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaJefeGordo =new Sala(
    diseno = [
        "HHHHHHHHHHHHH2HHHHHHHHHHH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HHHHHHHHHHHHH1HHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    puerta1 = puertaJefeGordoPasillo2,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaKrauser =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHH2HHHHHHHHHH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HH                    HH",
        "HHHHHHHHHHHHH1HHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeKrauser,
    zombisAleatorios = false,
    puerta1 = antesalaKrauser,
    puerta2 = salaSandler,
    puerta3 = vacio,
    puerta4 = vacio
)

//??????????????????????
const castillo = entradaCastillo
const salaSandler = salaVacia
const antesalaKrauser = salaVacia
const isla = salaVacia
//??????????????????????

// ================= FONDO =================
object fondoNivel {
    method image() = "fondo_nivel.png"
    method position() = game.origin()
}

object nivel {
    method cargar() {
        game.addVisual(fondoNivel)
        mapa.empezarEn(inicio, game.center())
    }
}