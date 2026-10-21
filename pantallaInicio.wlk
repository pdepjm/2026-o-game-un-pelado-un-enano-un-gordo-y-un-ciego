
import wollok.game.*
import partida.*

object pantallaInicio {
    var comenzo = false
    var mostrarSegundoFrame = false

    const animacion = game.tick(350, {self.animar()}, false)

    method mostrar() {
        game.boardGround("menu_principal.png")

        animacion.start()

        keyboard.enter().onPressDo({self.comenzar()})
    }

    method animar() {
        if (!comenzo) {
            if (mostrarSegundoFrame) {
                game.boardGround("menu_principal.png")
            } else {
                game.boardGround("menu_principal2.png")
            }

            mostrarSegundoFrame = !mostrarSegundoFrame
        }
    }

    method comenzar() {
        if (!comenzo) {
            comenzo = true

            animacion.stop()
            game.boardGround("")

            partida.comenzar()
        }
    }
}
