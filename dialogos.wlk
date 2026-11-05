import wollok.game.*
import maquinaDeEstados.*
import llaves.*
import personaje.*

object cartelCuerda {
    method image() = "estaCuerdaPareceSospechosa.png"
    method position() = game.at(16, 14)
}

object cartelDobleLlave {
    method image() = "dialogoDobleLlave.png"

     method position() = game.at(12, 15)
}

object cartelPistaPalancas {
    method image() = "pistaPalanca1.png"

     method position() = game.at(12, 15)
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
    imagenes = ["pistaPalanca1.png", "pistaPalanca2.png"],
    posicion = game.at(12, 13)
)
object gestorDialogos {
    var dialogoActual = null
    var secuenciaActual = null
    var teclaActivada = false

    method puedeMostrarCuerda() =
        !juego.existeLlave(llavePelado)

    method puedeMostrarDobleLlave() =
        !juego.existeLlave(llavePreEnano1) ||
        !juego.existeLlave(llavePreEnano2)

    method mostrarCuerda() {
        if (self.puedeMostrarCuerda()) {
            self.mostrar(cartelCuerda)
        }
    }

    method mostrarDobleLlave() {
        if (self.puedeMostrarDobleLlave()) {
            self.mostrar(cartelDobleLlave)
        }
    }

    method mostrar(cartel) {
        self.cerrarDialogo()
        game.addVisual(cartel)
        dialogoActual = cartel
    }

    method actualizar() {
        if (dialogoActual == cartelDobleLlave &&
            !self.puedeMostrarDobleLlave()) {
            self.cerrarDialogo()
        }
    }
    method activarTecla() {
        if (!teclaActivada) {
            teclaActivada = true
            keyboard.space().onPressDo({ self.avanzar() })
        }
    }

    method mostrarSecuencia(cartel) {
        self.activarTecla()
        cartel.reiniciar()
        self.mostrar(cartel)
        secuenciaActual = cartel
    }

    method avanzar() {
        if (secuenciaActual != null) {
            if (secuenciaActual.hayMas()) secuenciaActual.avanzar()
            else self.cerrarDialogo()
        }
    }

    method cerrarDialogo() {
        if (dialogoActual != null) {
            game.removeVisual(dialogoActual)
            dialogoActual = null
        }
        secuenciaActual = null
    }
}