import wollok.game.*
import maquinaDeEstados.*
import llaves.*
import personaje.*

object cartelCuerda {
    method image() = "estaCuerdaPareceSospechosa.png"
    method position() = game.at(1,12)
    method hayMas() = false
    method avanzar() {}
    method reiniciar() {}
}

object cartelDobleLlave {
    method image() = "dialogoDobleLlave.png"
    method position() = game.at(9, 12)
    method hayMas() = false
    method avanzar() {}
    method reiniciar() {}
}

class CartelSecuencia {
    const imagenes
    const posicion
    var indice = 0
    

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

const dialogoFinalMuerto  = new CartelSecuencia(
    imagenes = ["dialogo_prueba7.png", "dialogo_prueba8.png", "dialogo_prueba9.png", 
    "dialogo_prueba10.png", "dialogo_prueba11.png"],
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

    method activo() = dialogoActual != null

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

    method avanzar() {
        if (dialogoActual != null) {
            if (dialogoActual.hayMas()) dialogoActual.avanzar()
            else self.cerrarDialogo()
        }
    }

    method cerrarDialogo() {
        if (dialogoActual != null) {
            game.removeVisual(dialogoActual)
            dialogoActual = null
        }
    }
    method reiniciar() {
        dialogoActual = null
        teclaActivada = false     
    }
}