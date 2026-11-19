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
import npcs.*
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

    method agregarPared(pos) {
    const pared = new Pared(posicion = pos)
    paredes.add(pared)
    game.addVisual(pared)
    }

    method agregarPozo(pos) {
        const pozo = new Pozo(posicion = pos)
        pozos.add(pozo)
        game.addVisual(pozo)
    }

    method agregarPuerta(puerta, pos) {
        puerta.position(pos)
        game.addVisual(puerta)
    }

    method accionesDelMapa() {
    const acciones = new Dictionary()

    acciones.put("H", { pos => self.agregarPared(pos) })
    acciones.put("P", { pos => self.agregarPozo(pos) })

    acciones.put("1", { pos => self.agregarPuerta(puerta1, pos) })
    acciones.put("2", { pos => self.agregarPuerta(puerta2, pos) })
    acciones.put("3", { pos => self.agregarPuerta(puerta3, pos) })
    acciones.put("4", { pos => self.agregarPuerta(puerta4, pos) })

    acciones.put("I", { pos => bloqueosInvisibles.add(pos) })

    return acciones
}


    method cargar() {
    fondoNivel.cambiar(fondo)

    const acciones = self.accionesDelMapa()
    const filas = diseno.size()

    (0..filas - 1).forEach({ fila =>
        const linea = diseno.get(fila)
        const y = alturaInterfaz + (filas - 1 - fila)

        (0..linea.length() - 1).forEach({ x =>
            const c = linea.charAt(x)
            const pos = game.at(x, y)

            if (acciones.keys().contains(c)) {
                acciones.get(c).apply(pos)
            }
        })
    })

    items.forEach({ i =>
        if (!game.hasVisual(i)) {
            game.addVisual(i)
        }
        mapa.agregarItem(i)
    })

    destructibles.filter({ d => !d.roto() }).forEach({ d =>
        game.addVisual(d)
    })

    palancas.forEach({ p =>
        game.addVisual(p)
    })
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
    method bloqueaJugador(pos) =
    self.hayPared(pos) || self.hayPozo(pos) || salaActual.puertaBloqueadaEn(pos) || gestorNpcs.ocupa(pos)

method alPisar(pos) {
    const puerta = salaActual.puertaEn(pos)
    if (puerta != vacio && !salaActual.puertaBloqueadaEn(pos)) {
        self.cruzar(puerta)
    } else {
        gestorNpcs.alMoverse(pos)
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
    gestorNpcs.ocultarTodos()
    salaActual.jefe().desaparecer()
    itemsEnSuelo.forEach({ i => game.removeVisual(i) })
    itemsEnSuelo.clear()
    salaActual.descargar()
    gestorDialogos.cerrarDialogo()
    salaActual = destino
    salaActual.cargar()
    
    personaje.position(salaActual.entradaDe(puerta.puertaDeVuelta()))
    gestorNpcs.actualizar(salaActual) 
    gestorMusica.alEntrarA(salaActual)
    salaActual.jefe().aparecer()

    if (salaActual == iglesia) {
    gestorDialogos.mostrarCuerda()
    }

    if (salaActual == lobbyCastillo) {
    gestorDialogos.mostrarDobleLlave()
    }
    if (salaActual == salaFinal){
        gestorDialogos.mostrar(dialogoFinal)
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
    "IIIIIIIIII1IIIIIIIIIIIII",
    "IIIIIIIII   IIIIIIIIIIII",
    "IIIII  I     IIIIIIIIIII",
    "IIIII        IIIIIIIIIII",
    "IIIII              IIIII",
    "IIIII              IIIII",
    "IIIII               IIII",
    "IIIII               IIII",
    "IIIII    IIII       IIII",
    "IIIII    IIII      IIIII",
    "IIIII    IIII    IIIIIII",
    "IIIIIIIIIIIIIIIIIIIIIIII",
    "IIIIIIIIIIIIIIIIIIIIIIII",
    "IIIIIIIIIIIIIIIIIIIIIIII",
    "IIIIIIIIIIIIIIIIIIIIIIII"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    fondo = "fondo_inicio.png",
    puerta1 = puertaInicioPueblo,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio)

const pueblo = new Sala(diseno = [
    "IIIIIIIIIIIIIIIIIII4IIII",
    "I  IIIII               I",
    "I  IIIII               I",
    "I  IIIII               I",
    "I  III2I               I",
    "I                      I",
    "I              III     I",
    "I              III     I",
    "I              III     I",
    "I                      I",
    "I    III               I",
    "I    III               3",
    "I                      I",
    "I                      I",
    "IIIIIIIIIII1IIIIIIIIIIII"
    ],
    jefe = emboscadaPueblo,
    zombisAleatorios = true,
    fondo = fondoPueblo,
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
        "IIIIIIIIIIIIIIIIIIIIIIII",
        "I            IIIIIIIIIII",
        "I            IIIIIIIIIII",
        "I            IIIIIIIIIII",
        "I            IIIIIIIIIII",
        "I            IIIIIIIIIII",
        "I            IIIII2IIIII",
        "I                  IIIII",
        "I            IIIIIIIIIII",
        "I            IIIIIIIIIII",
        "I         IIIIIIIIIIIIII",
        "1         IIIIIIIIIIIIII",
        "I         IIIIIIIIIIIIII",
        "I         IIIIIIIIIIIIII",
        "IIIIIIIIIIIIIIIIIIIIIIII"
    ],
    jefe = jefeNulo,
    zombisAleatorios = true,
    fondo = "fondo_muelle.png",
    puerta1 = puertaMuellePueblo,
    puerta2 = puertaMuelleEntradaIsla,
    puerta3 = vacio,
    puerta4 = vacio
)

const entradaCastillo = new Sala(diseno = [
        "IIIIIIIIIIIIIIIIIIIIIIII",
        "IIIIIIIIIIIIIIIIIIIIIIII",
        "IIIIIIIIIIII2IIIIIIIIIII",
        "IIIII              IIIII",
        "IIIII               IIII",
        "IIIII               IIII",
        "IIIII      II      IIIII",
        "IIIII      II      IIIII",
        "IIIII              IIIII",
        "IIIII             IIIIII",
        "IIIII            IIIIIII",
        "IIIII III    IIIIIIIIIII",
        "IIIIIIIIIIII1IIIIIIIIIII",
        "IIIIIIIIIIIIIIIIIIIIIIII",
        "IIIIIIIIIIIIIIIIIIIIIIII"
    ],
    jefe = jefeNulo,
    zombisAleatorios = true,
    fondo = "fondo_entrada_castillo.png",
    puerta1 = puertaEntradaCastilloPueblo,
    puerta2 = puertaEntradaCastilloCastillo,
    puerta3 = vacio,
    puerta4 = vacio
)
const lobbyCastillo = new Sala(diseno = [
        "HIIIIIIIIIII4IIIIIIIIIIH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "I                      I",
        "2                      3",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HHHHHHHHHHHH1HHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = fondoLobby,
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
        "HHHIIIIIIIIIIIIIIIIIIHHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH    IIIIIIIIIIII  IHH",
        "HHH   IIIIIIIIIIIII  1HH",
        "HHH    IIIIIIIIIIII  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = "fondo_llave1.png",
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
        "HHHIIIIIIIIIIIIIIIIIIHHH",
        "HHHI     III       I HHH",
        "HHH   I  I  I IIIIII HHH",
        "HHH II   II     I  I HHH",
        "HHIIIII I  III     I HHH",
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
        "HIIIIIIIIIII2IIIIIIIIIIH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HI                    IH",
        "HHHHHHHHHHHH1HHHHHHHHHHH"
    ],
    jefe = jefeEnano,
    fondo = "fondo_enano.png",
    zombisAleatorios = false,
    puerta1 = puertaJefeEnanoLobby,
    puerta2 = puertaJefeEnanoPasillo0,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaPasillo0 =new Sala(
    diseno = [
        "HHHHHHHHHIIIIIIHHHHHHHHHH",
        "HHHHHHHHI      IHHHHHHHH",
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
    fondo = "fondo_pasillo0.png",
    zombisAleatorios = true,
    puerta1 = puertaPasillo0JefeEnano,
    puerta2 = puertaPasillo0Biblioteca,
    puerta3 = puertaPasillo0Pasillo1,
    puerta4 = vacio
)
const bibiloteca =new Sala(
    diseno = [
        "HHHIIIIIIIIIIIIIIIIIIHHH",
        "HHH                  HHH",
        "HHH   IIII           HHH",
        "HHH   IIII           1HH",
        "HHH   IIII           HHH",
        "HHH                  HHH",
        "HHH      IIIIIIIIIIIIHHH",
        "HHH      IIIIIIIIIIIIHHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHIIIIIIIIIIIII     HHH",
        "HHHIIIIIIIIIIIII     HHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = fondoBiblioteca,
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
        "HHHIIIIIIIIIIIIIIIIIIHHH",
        "HHH                  HHH",
        "HHI                  IHH",
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
    fondo = "fondo_pasillo1.png",
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
        "HHHIIIIIHHHHHHHHHHHHHHHH",
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
    fondo = "fondo_pasillo1.png",
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
        "HHHIIIIIIIIIIIIIII1IIHHH",
        "HHH                  HHH",
        "HHH                  HHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      HHHHHHHHHHHHHHH",
        "HHH      IIIIIIIIIIIIHHH",
        "HHH                  IHH",
        "HHH                  2HH",
        "HHH                  HHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    fondo = "fondo_pasillo2.png",
    zombisAleatorios = true,
    rapidinesAleatorios = true,
    puerta1 = puertaPasillo2Pasillo1,
    puerta2 = puertaPasillo2JefeGordo,
    puerta3 = vacio,
    puerta4 = vacio
)

const salaJefeGordo =new Sala(
    diseno = [
        "HHIIIIIIIIIIIIIIIIIIIIHH",
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
        "HI                    HH",
        "H1                    HH",
        "HH                    HH",
        "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeGordo,
    fondo = "fondo_gordo.png",
    zombisAleatorios = false,
    puerta1 = puertaJefeGordoPasillo2,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio
)
const entradaIsla = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HIIIIIIIIIIIIII2IIIIIHHH",
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
    fondo = "fondo_isla_lobby.png",
    puerta1 = puertaEntradaIslaMuelle,
    puerta2 = puertaIslaColumnaNorte,
    puerta3 = puertaIslaColumnaSur,
    puerta4 = vacio)

const columnaNorte = new Sala(diseno = [
    "HHHHHHHHHIII1IIHHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      IHHHHHHHH",
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
    fondo = "fondo_columna_n.png",
    puerta1 = puertaColumnaNorteSalaVerde,
    puerta2 = puertaColumnaNorteIsla,
    puerta3 = puertaColumnaNortePasilloNorte,
    puerta4 = vacio)

const salaVerde = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHIIIIIIIIHHHHHHHH",
    "HHHHHHHHIIIII   HHHHHHHH",
    "HHHHHHHH  III   HHHHHHHH",
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
    fondo = "fondo_palanca_verde.png",
    puerta1 = puertaSalaVerdeColumnaNorte,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio)

const columnaSur = new Sala(diseno = [
    "HHHHHHHHHIII1IIHHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      IHHHHHHHH",
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
    fondo = "fondo_isla_columna3.png",
    puerta1 = puertaColumnaSurIsla,
    puerta2 = puertaColumnaSurPasilloSurOeste,
    puerta3 = puertaColumnaSurSalaRoja,
    puerta4 = vacio)


const salaRoja = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHIIII1IIIHHHHHHHH",
    "HHHHHHHHII      HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHHIIII IIIHHHHHHHH",
    "HHHHHHHHIIII IIIHHHHHHHH",
    "HHHHHHHHIIII   IHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    palancas = [palancaRoja],
    fondo = "fondo_palanca_rojo.png",
    puerta1 = puertaSalaRojaColumnaSur,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio)

const pasilloNorte = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHIIIIIIIIIIIIIIIIIIIIHH",
    "HH                    HH",
    "HH                    HH",
    "HI                    HH",
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
    tankesAleatorios = true,
    fondo = "fondo_isla_pasillonorte.png",
    puerta1 = puertaPasilloNorteColumnaNorte,
    puerta2 = puertaPasilloNortePasilloCentral,
    puerta3 = vacio,
    puerta4 = vacio)


const pasilloCentral = new Sala(diseno = [
    "HHHHHHHHHIII1IIHHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHH      HHHHHHHHH",
    "HHHHHHHHI      HHHHHHHHH",
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
    fondo = "fondo_isla_columna2.png",
    puerta1 = puertaPasilloCentralPasilloNorte,
    puerta2 = puertaPasilloCentralSalaAzul,
    puerta3 = puertaPasilloCentralPasilloSurOeste,
    puerta4 = vacio)

const salaAzul = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHIIIIIIIIHHHHHHHH",
    "HHHHHHHHII I    HHHHHHHH",
    "HHHHHHHHII      HHHHHHHH",
    "HHHHHHHH        1HHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHHIIIIIIIIHHHHHHHH",
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
    fondo = "fondo_palanca_azul.png",
    puerta1 = puertaSalaAzulPasilloCentral,
    puerta2 = vacio,
    puerta3 = vacio,
    puerta4 = vacio)


const pasilloSurOeste = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHIIIIIIIIIIIIIII2IIIIHH",
    "HH                    HH",
    "HH                    HH",
    "HI                    IH",
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
    fondo = "fondo_isla_pasillosur.png",
    puerta1 = puertaPasilloSurOesteColumnaSur,
    puerta2 = puertaPasilloSurOestePasilloCentral,
    puerta3 = puertaPasilloSurOestePasilloSurEste,
    puerta4 = vacio)


const pasilloSurEste = new Sala(diseno = [
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHH      IIHHHHHHHH",
    "HHHHHHHH    II  HHHHHHHH",
    "HHHHHHHHIIII    HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHH1        2HHHHHHH",
    "HHHHHHHHIII     HHHHHHHH",
    "HHHHHHHH  I     HHHHHHHH",
    "HHHHHHHH  I     HHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    tankesAleatorios = false,
    palancas = [palancaAmarilla],
    fondo = "fondo_palancas_amarillo.png",
    puerta1 = puertaPasilloSurEstePasilloSurOeste,
    puerta2 = puertaPasilloSurEsteAntesala,
    puerta3 = vacio,
    puerta4 = vacio)


const antesalaKrauser = new Sala(diseno = [
    "HHHHHHHHIIII1IIIHHHHHHHH",
    "HHHHHHHHII    IIHHHHHHHH",
    "HHHHHHHHI      IHHHHHHHH",
    "HHHHHHHHI      IHHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH I  II  HHHHHHHH",
    "HHHHHHHH I  II  HHHHHHHH",
    "HHHHHHHH II II  HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHI        HHHHHHHH",
    "HHHHHHH2        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHH        HHHHHHHH",
    "HHHHHHHHHHHHHHHHHHHHHHHH"
    ],
    jefe = jefeNulo,
    zombisAleatorios = false,
    rapidinesAleatorios = true,
    tankesAleatorios = true,
    fondo = "fondo_antesala.png",
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
    puerta1 = puertaKrauserAntesala,
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
    fondo = "fondo_jefeFinal.png",
    puerta1 = puertaFinalKrauser,
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
const fondoLobby = "fondo_lobby.png"
const fondoPueblo = "fondo_pueblo.png"
const fondoBiblioteca = "fondo_biblioteca.png"
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