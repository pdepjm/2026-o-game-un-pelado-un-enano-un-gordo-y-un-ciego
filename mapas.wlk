import wollok.game.*
import personaje.*
import puertas.*
import interfaz.alturaInterfaz
import enemigo.*
import jefePelado.*
import jefeEnano.*
import jefeGordo.*
import jefeKrauser.*
import jefeFinal.*
import emboscadaPueblo.*
import armas.*
import llaves.*
import objetosDestructibles.*
import dialogos.*
import musica.*
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
    const destructibles = []
    const pozos = []
    const items = []
    const palancas = []
    const zombisAleatorios
    const rapidinesAleatorios = false
    method rapidinesAleatorios() = rapidinesAleatorios
    const tankesAleatorios = false
    method tankesAleatorios() = tankesAleatorios
    const bloqueosInvisibles = []
    var fondo = "fondo_nivel.png"
    method fondo() = fondo
    method cambiarFondo(nuevo) {
    fondo = nuevo
    if (mapa.salaActual() == self) fondoNivel.cambiar(nuevo)
    }

    method jefe() = jefe

    method zombisAleatorios() = zombisAleatorios

    method hayPared(pos) = ["H", "I"].contains(self.caracterEn(pos))
    method hayPozo(pos) = self.caracterEn(pos) == "P"
    
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
        fondoNivel.cambiar(fondo)
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
                } else if (c == "I") {
                    bloqueosInvisibles.add(pos)
                }
            })
        })
       items.forEach({ i =>
    if (!game.hasVisual(i)) { game.addVisual(i) }
    mapa.agregarItem(i) 
    })
    destructibles.filter({ d => !d.roto() }).forEach({ d => game.addVisual(d) })
    palancas.forEach({ p => game.addVisual(p) })
    }

    method descargar() {
        paredes.forEach({ p => game.removeVisual(p) })
        pozos.forEach({ p => game.removeVisual(p) })
        palancas.forEach({ p => game.removeVisual(p) })
        destructibles.filter({ d => game.hasVisual(d) }).forEach({ d => game.removeVisual(d) })
        game.removeVisual(puerta1)
        game.removeVisual(puerta2)
        game.removeVisual(puerta3)
        game.removeVisual(puerta4)

        paredes.clear()
        pozos.clear()
        bloqueosInvisibles.clear()
    }

    method sacarItem(item) { items.remove(item) }
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
    const xMin = 2
    const xMax = diseno.get(2).length() - 3   
    const yMin = alturaInterfaz + 2
    const yMax = alturaInterfaz + diseno.size() - 3

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
    const recogidos = itemsEnSuelo.filter({ i => i.position() == pos })
    recogidos.forEach({ i =>
        itemsEnSuelo.remove(i)
        salaActual.sacarItem(i)
        game.removeVisual(i)
        i.alPisar()
    })
}

    method agregarItem(item) {
    if (!itemsEnSuelo.contains(item)) { itemsEnSuelo.add(item) }
}

    method cruzar(puerta) {
    const destino = puerta.destino()

    spawner.limpiar()

    salaActual.jefe().desaparecer()
    itemsEnSuelo.forEach({ i => game.removeVisual(i) })
    itemsEnSuelo.clear()
    salaActual.descargar()
    gestorDialogos.cerrarDialogo()
    salaActual = destino
    salaActual.cargar()
    
    personaje.position(salaActual.entradaDe(puerta.puertaDeVuelta()))

    gestorMusica.alEntrarA(salaActual)
    salaActual.jefe().aparecer()

    if (salaActual == iglesia) {
    gestorDialogos.mostrarCuerda()
    }

    if (salaActual == lobbyCastillo) {
    gestorDialogos.mostrarDobleLlave()
    }
    if (salaActual == entradaIsla) {
    gestorDialogos.mostrarDobleLlave()
    }

    if (salaActual.zombisAleatorios()) {
        spawner.crearZombiesAleatorios()
    }
    if (salaActual.rapidinesAleatorios()) {
    spawner.crearRapidinesAleatorios()
    }
    if (salaActual.tankesAleatorios()) {
    spawner.crearTankesAleatorios()
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
        "HHHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHIHHHHHHHHHHHHH",
        "HHHHHHHHHHHHIHHHHHHHHHHHHH",
        "HHHHHH    IIIII    HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHHIIII    IIIIIHHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHHIIII    IIIIIHHHHHHH",
        "HHHHHH       2     HHHHHHH",
        "HHHHHHIIII    IIIIIHHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHHIIII    IIIIIHHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHH             HHHHHHH",
        "HHHHHHHHHHHH1HHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = fondoIglesia,
    destructibles = [cuerdaIglesia],
    zombisAleatorios = false,
    puerta1 = puertaIglesiaPueblo,
    puerta2 = puertaIglesiaPelado,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaJefePelado = new Sala(diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHH1HHHHHHHHHHHHHHHHHHHH",
        "HHHHHH             HHHHHHHH",
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
    fondo = fondoPelado,
   zombisAleatorios = false,
    puerta1 = puertaPeladoIglesia,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio)

const muelle = new Sala(diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "H            HHHHHHHHHHH",
        "H            HHHHHHHHHHH",
        "H            HHHHHHHHHHH",
        "H            HHHHHHHHHHH",
        "H            HHHHHHHHHHH",
        "H            HHHHH2HHHHH",
        "H                  HHHHH",
        "H            HHHHHHHHHHH",
        "H            HHHHHHHHHHH",
        "H         HHHHHHHHHHHHHH",
        "1         HHHHHHHHHHHHHH",
        "H         HHHHHHHHHHHHHH",
        "H            HHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = true,
    puerta1 = puertaMuellePueblo,
    puerta2 = puertaMuelleEntradaIsla,
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
    zombisAleatorios = true,
    puerta1 = puertaEntradaCastilloPueblo,
    puerta2 = puertaEntradaCastilloCastillo,
    puerta3 = vacio,
    puerta4 = vacio
)
const lobbyCastillo = new Sala(diseno = [
        "HHHHHHHHHHHH4HHHHHHHHHHHH",
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
        "HHHHHHHHHHHH1HHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = fondoCastillo,
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
    fondo = fondoCastillo,
    zombisAleatorios = true,
    items = [llavePreEnano1],
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
        "HHHH     III       I HHH",
        "HHH   I  I  I IIIIII HHH",
        "HHH II   II     I  I HHH",
        "HHHIIII I  III     I HHH",
        "HH1  I      I  II I  HHH",
        "HHH I IIIII     I I  HHH",
        "HHH I       I I I    HHH",
        "HHH IIII IIIIIIII II HHH",
        "HHH        I       I HHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = fondoLaberinto,
    zombisAleatorios = true,
    items = [llavePreEnano2],
    puerta1 = puertaLLaveEnano2Lobby,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaJefeEnano =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHH2HHHHHHHHHHH",
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
        "HHHHHHHHHHHH1HHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeEnano,
    fondo = fondoCastillo,
    zombisAleatorios = false,
    puerta1 = puertaJefeEnanoLobby,
    puerta2 = puertaJefeEnanoPasillo0,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaPasillo0 =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHH2      3HHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHH      HHHHHHHHH",
        "HHHHHHHHHHH1HHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = fondoCastillo,
    zombisAleatorios = true,
    puerta1 = puertaPasillo0JefeEnano,
    puerta2 = puertaPasillo0Biblioteca,
    puerta3 = puertaPasillo0Pasillo1,
    puerta4 = vacio
)
const bibiloteca =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHH                  HHH",
        "HHH   HHHH           HHH",
        "HHH   HHHH           1HH",
        "HHH   HHHH           HHH",
        "HHH                  HHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHHHHHHHHHH     HHH",
        "HHHHHHHHHHHHHHHH     HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = fondoPelado,
    zombisAleatorios = true,
    rapidinesAleatorios = true,
    items = [llavePreGordo],
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
        "HHHHHHHHHHHHHHH      HHH",
        "HHHHHHHHHHHHHHH      HHH",
        "HHHHHHHHHHHHHHH      HHH",
        "HHHHHHHHHHHHHHHHHH2HHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = fondoCastillo,
    zombisAleatorios = true,
    rapidinesAleatorios = true,
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
        "HHH     HHHHHHHHHHHHHHHHH",
        "HHH     HHHHHHHHHHHHHHHHH",
        "HH1     HHHHHHHHHHHHHHHHH",
        "HHH     HHHHHHHHHHHHHHHHH",
        "HHH     HHHHHHHHHHHHHHHHH",
        "HHH     HHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = fondoCastillo,
    zombisAleatorios = false,
    items = [itemEscopeta],
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
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH                  HHH",
        "HHH                  2HH",
        "HHH                  HHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = fondoCastillo,
    zombisAleatorios = true,
    rapidinesAleatorios = true,
    puerta1 = puertaPasillo2Pasillo1,
    puerta2 = puertaPasillo2JefeGordo,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaJefeGordo =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
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
        "H1                    HH",
        "HH                    HH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeGordo,
    fondo = fondoCastillo,
    zombisAleatorios = false,
    puerta1 = puertaJefeGordoPasillo2,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio
)
const entradaIsla = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHH2HHHHHHHH",
    "H                    HHH",
    "H                    HHH",
    "H                    HHH",
    "H                    HHH",
    "1                    HHH",
    "H                    HHH",
    "H                    HHH",
    "H                    HHH",
    "H                    HHH",
    "HHHHHHHHHHHHHHH3HHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    fondo = fondoIsla,
    puerta1 = puertaEntradaIslaMuelle,
    puerta2 = puertaIslaColumnaNorte,
    puerta3 = puertaIslaColumnaSur,
    puerta4 = vacio)

const columnaNorte = new Sala(diseno = [
    "HHHHHHHHHHHH1HHHHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      3HHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHHHH2HHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    tankesAleatorios = true,
    fondo = fondoIsla,
    puerta1 = puertaColumnaNorteSalaVerde,
    puerta2 = puertaColumnaNorteIsla,
    puerta3 = puertaColumnaNortePasilloNorte,
    puerta4 = vacio)

const salaVerde = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHHHHHH1HHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    palancas = [palancaVerde],
    fondo = fondoPalanca,
    puerta1 = puertaSalaVerdeColumnaNorte,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio)

const columnaSur = new Sala(diseno = [
    "HHHHHHHHHHH1HHHHHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      2HHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHHHHH3HHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    tankesAleatorios = true,
    fondo = fondoIsla,
    puerta1 = puertaColumnaSurIsla,
    puerta2 = puertaColumnaSurPasilloSurOeste,
    puerta3 = puertaColumnaSurSalaRoja,
    puerta4 = vacio)


const salaRoja = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHH1HHHHHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    palancas = [palancaRoja],
    fondo = fondoPalanca,
    puerta1 = puertaSalaRojaColumnaSur,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio)

const pasilloNorte = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HH                    HH",
    "HH                    HH",
    "HH                    HH",
    "H1                    HH",
    "HH                    HH",
    "HH                    HH",
    "HH                    HH",
    "HHHHHHHHHHHHHHHHHH2HHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = true,
    fondo = fondoIsla,
    puerta1 = puertaPasilloNorteColumnaNorte,
    puerta2 = puertaPasilloNortePasilloCentral,
    puerta3 = vacio,
    puerta4 = vacio)


const pasilloCentral = new Sala(diseno = [
    "HHHHHHHHHHHH1HHHHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHH2      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHHHH3HHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = true,
    tankesAleatorios = true,
    fondo = fondoIsla,
    puerta1 = puertaPasilloCentralPasilloNorte,
    puerta2 = puertaPasilloCentralSalaAzul,
    puerta3 = puertaPasilloCentralPasilloSurOeste,
    puerta4 = vacio)

const salaAzul = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        1HHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    palancas = [palancaAzul],
    fondo = fondoPalanca,
    puerta1 = puertaSalaAzulPasilloCentral,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio)


const pasilloSurOeste = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHH2HHHHHH",
    "HH                    HH",
    "HH                    HH",
    "HH                    HH",
    "H1                    3H",
    "HH                    HH",
    "HH                    HH",
    "HH                    HH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = true,
    tankesAleatorios = true,
    fondo = fondoIsla,
    puerta1 = puertaPasilloSurOesteColumnaSur,
    puerta2 = puertaPasilloSurOestePasilloCentral,
    puerta3 = puertaPasilloSurOestePasilloSurEste,
    puerta4 = vacio)


const pasilloSurEste = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHH1        2HHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    tankesAleatorios = true,
    palancas = [palancaAmarilla],
    fondo = fondoPalanca,
    puerta1 = puertaPasilloSurEstePasilloSurOeste,
    puerta2 = puertaPasilloSurEsteAntesala,
    puerta3 = vacio,
    puerta4 = vacio)


const antesalaKrauser = new Sala(diseno = [
    "HHHHHHHHHHHH1HHHHHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHH2        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    fondo = fondoIsla,
    puerta1 = puertaAntesalaKrauser,
    puerta2 = puertaAntesalaPasilloSurEste,
    puerta3 = vacio,
    puerta4 = vacio)

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
    fondo = fondoIsla,
    puerta1 = antesalaKrauser,
    puerta2 = puertaKrauserFinal,
    puerta3 = vacio,
    puerta4 = vacio
)
const salaFinal =new Sala(
    diseno = [
        "HHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
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
    jefe = jefeFinal,
    zombisAleatorios = false,
    fondo = fondoIsla,
    puerta1 = puertaKrauserFinal,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio
)

//??????????????????????
const castillo = entradaCastillo
const fondo = "fondo_nivel.png"
const fondoCastillo = "fondo_castillo.png"
const fondoIglesia = "fondo_iglesia.png"
const fondoIsla = "fondo_isla.png"
const fondoPalanca = "fondo_palanca.png"
const fondoLaberinto = "fondo_laberinto.png"
const fondoPelado = "fondo_pelado.png"
const fondoLobby = "fondoLobby.png"
//??????????????????????

// ================= FONDO =================
object fondoNivel {
    var imagen = "fondo_nivel.png"
    method image() = imagen
    method position() = game.origin()
    method cambiar(nuevaImagen) { imagen = nuevaImagen }
}

object nivel {
    method cargar() {
        game.addVisual(fondoNivel)
        mapa.empezarEn(inicio, game.center())
    }
}