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

object gestorDialogos {
    var dialogoActual = null

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

    method cerrarDialogo() {
        if (dialogoActual != null) {
            game.removeVisual(dialogoActual)
            dialogoActual = null
        }
    }

    method actualizar() {
        if (dialogoActual == cartelDobleLlave &&
            !self.puedeMostrarDobleLlave()) {
            self.cerrarDialogo()
        }
    }
}