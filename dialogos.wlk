import wollok.game.*
import maquinaDeEstados.*
import llaves.*
import personaje.*
import musica.*
import mapas.*
import jefeFinal.*

object cartelCuerda {
    method image() = "estaCuerdaPareceSospechosa.png"
    method position() = game.at(1,12)
    method hayMas() = false
    method avanzar() {}
    method reiniciar() {}
    method alCerrar(natural) {}
}

object cartelDobleLlave {
    method image() = "dialogoDobleLlave.png"
    method position() = game.at(9, 12)
    method hayMas() = false
    method avanzar() {}
    method reiniciar() {}
    method alCerrar(natural) {}
}

class CartelSecuencia {
    const imagenes
    const posicion
    var indice = 0
    
    method alCerrar(natural) {}
    method image() = imagenes.get(indice)
    method position() = posicion
    method hayMas() = indice < imagenes.size() - 1
    method avanzar() { indice += 1 }
    method reiniciar() { indice = 0 }
}
const pistaPalancas = new CartelSecuencia(
    imagenes = ["pistaPalancas1.png", "pistaPalancas2.png"],
    posicion = game.at(9, 12)
)

const dialogoFinal = new CartelSecuencia(
    imagenes = ["dialogo_prueba1.png", "dialogo_prueba2.png", "dialogo_prueba3.png", 
    "dialogo_prueba4.png", "dialogo_prueba5.png", "dialogo_prueba6.png"],
    posicion = game.at(9, 12)
)

const dialogoEscopeta = new CartelSecuencia(
    imagenes = ["dialogo_escopeta1.png", "dialogo_escopeta2.png", "dialogo_escopeta3.png", "dialogo_escopeta4.png"],
    posicion = game.at(9, 12)
)

const dialogoPeladoMuerto = new CartelSecuencia(
    imagenes = ["dialogo_postpelado1.png", "dialogo_postpelado2.png"],
    posicion = game.at(9,12)
)

const dialogoEnanoMuerto = new CartelSecuencia(
    imagenes = ["dialogo_postenano1.png", "dialogo_postenano2.png"],
    posicion = game.at(9,12)
)

const dialogoKrauserMuerto = new CartelSecuencia(
    imagenes = ["dialogo_postkrauser1.png", "dialogo_postkrauser2.png"],
    posicion = game.at(9,12)
)

const dialogoFinalMuerto = new CartelConFinal(
    imagenes = ["dialogo_prueba7.png", "dialogo_prueba8.png", "dialogo_prueba9.png",
    "dialogo_prueba10.png", "dialogo_prueba11.png"],
    posicion = game.at(9,12)
)

const cartelTablas = new CartelSecuencia(
    imagenes = ["dialogo_tablas1.png", "dialogo_tablas2.png"],
    posicion = game.at(9,12)
)


const lore1 = new CartelSecuencia(
    imagenes = ["loreverde1.png", "loreverde2.png", "loreverde3.png", "loreverde4.png"],
    posicion = game.at(9,12)
)

const lore2 = new CartelSecuencia(
    imagenes = ["lorerojo1.png", "lorerojo2.png", "lorerojo3.png", "lorerojo4.png"],
    posicion = game.at(9,12)
)

const lore3 = new CartelSecuencia(
    imagenes = ["loreazul1.png", "loreazul2.png", "loreazul3.png", "loreazul4.png"],
    posicion = game.at(9,12)
)

const lore4 = new CartelSecuencia(
    imagenes = ["loreamarillo1.png", "loreamarillo2.png", "loreamarillo3.png", "loreamarillo4.png"],
    posicion = game.at(9,12)
)

const dialogoPuertaGordo = new CartelSecuencia(
    imagenes = ["dialogo_pregordo.png"],
    posicion = game.at(9,12)
)

const dialogoGordoMuerto = new CartelSecuencia(
    imagenes = ["dialogo_gordo1.png","dialogo_gordo2.png"],
    posicion = game.at(9,12)
)

const cartelBote = new CartelSecuencia(
    imagenes = ["dialogo_bote1.png"],
    posicion = game.at(9, 12)
)
object gestorDialogos {
    var dialogoActual = null
    var teclaActivada = false
    var cinematicaActual = null

    method activo() = dialogoActual != null || cinematicaActual != null

    method mostrarCinematica(cinematica, accion) {
        self.activarTecla()
        self.cerrarDialogo()
        cinematicaActual = cinematica
        cinematica.iniciar(accion)
    }

    method cinematicaTerminada() { cinematicaActual = null }

    method avanzar() {
        if (cinematicaActual != null) cinematicaActual.terminar()    
        else if (dialogoActual != null) {
            if (dialogoActual.hayMas()) dialogoActual.avanzar()
            else self.cerrar(true)

        }
    }

    method reiniciar() {
        dialogoActual = null
        cinematicaActual = null
        teclaActivada = false
    }


    method puedeMostrarCuerda() = !juego.existeLlave(llavePelado)
    method puedeMostrarDobleLlave() =
        !juego.existeLlave(llavePreEnano1) || !juego.existeLlave(llavePreEnano2)

    method mostrarCuerda() { if (self.puedeMostrarCuerda()) self.mostrar(cartelCuerda) }
    method mostrarDobleLlave() { if (self.puedeMostrarDobleLlave()) self.mostrar(cartelDobleLlave) }

    method activarTecla() {
        if (!teclaActivada) {
            teclaActivada = true
            keyboard.space().onPressDo({ self.avanzar() })
        }
    }

    method mostrar(cartel) {
        self.activarTecla()
        self.cerrarDialogo()
        cartel.reiniciar()
        game.addVisual(cartel)
        dialogoActual = cartel
    }

    method mostrarSecuencia(cartel) { self.mostrar(cartel) }

    method actualizar() {
        if (dialogoActual == cartelDobleLlave && !self.puedeMostrarDobleLlave()) {
            self.cerrarDialogo()
        }
    }

    method alCerrar(natural) {}


    method cerrarDialogo() { self.cerrar(false) }


    method cerrar(natural) {
        if (dialogoActual != null) {
            const cerrado = dialogoActual
            game.removeVisual(cerrado)
            dialogoActual = null
            cerrado.alCerrar(natural)
        }
    }

    method mostrarCinematica(cinematica) {
    if (!cinematica.vista()) {
        self.mostrar(cinematica)
        cinematica.iniciar()
    }
    }

    method terminarSi(cartel) {
        if (dialogoActual == cartel) self.cerrar(true)
    }


}

class Cinematica {
    const imagen
    const audio
    const duracion
    var vista = false
    var sonido = null
    var turno = 0
    var ocultos = []
    var alTerminar = {}
    const retrasoAudio = 0 

    method vista() = vista
    method olvidar() { vista = false }

   method iniciar(accion) {
        vista = true
        alTerminar = accion
        turno += 1
        const miTurno = turno

        gestorMusica.detener()

        ocultos = game.allVisuals().map({ v => v })
        ocultos.forEach({ v => game.removeVisual(v) })
        game.boardGround(imagen)

        sonido = game.sound(audio)
        game.schedule(retrasoAudio, { if (turno == miTurno) sonido.play() })
        game.schedule(duracion, { if (turno == miTurno) self.terminar() })
    }

    method terminar() {
        turno += 1
        if (sonido.played()) sonido.stop()  
        sonido = null

        game.boardGround("fondo_nivel.png")           
        ocultos.forEach({ v => game.addVisual(v) })
        ocultos = []

        gestorDialogos.cinematicaTerminada()
        alTerminar.apply()                            
    }
}

const cinematicaLobby = new Cinematica(
    imagen = "cinematica_lobby.gif",
    audio = "cinematica_lobby.mp3",
    duracion = 59000,
    retrasoAudio = 1000
)

const cinematicaKrauser = new Cinematica(
    imagen = "cinematica_krauser.gif",
    audio = "cinematica_krauser.mp3",
    duracion = 97000,
    retrasoAudio = 1000
)

class CartelConFinal inherits CartelSecuencia {
    override method alCerrar(natural) {
        if (natural) game.schedule(2000, { finalJuego.mostrar() })
    }
}
