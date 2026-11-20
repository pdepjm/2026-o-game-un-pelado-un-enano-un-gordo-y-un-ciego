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
    imagenes = ["dialogo_prueba1.png", "dialogo_prueba2.png", "dialogo_prueba3.png", "dialogo_prueba4.png"],
    posicion = game.at(9, 12)
)

const dialogoEscopeta = new CartelSecuencia(
    imagenes = ["dialogo_escopeta1.png", "dialogo_escopeta2.png", "dialogo_escopeta3.png", "dialogo_escopeta4.png"],
    posicion = game.at(9, 12)
)

const dialogoEnanoMuerto = new CartelSecuencia(
    imagenes = ["dialogo_postenano.png"],
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
}