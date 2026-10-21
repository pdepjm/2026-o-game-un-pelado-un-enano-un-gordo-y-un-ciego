import wollok.game.*
import partida.*

object pantallaInicio {
    var comenzo = false

    const musica = game.sound("menu_principal.mp3")

    method mostrar() {
        comenzo = false
        game.boardGround("menu_principal.gif")

        musica.shouldLoop(true)
        musica.play()

        keyboard.enter().onPressDo({ self.comenzar() })
    }

    method comenzar() {
        if (!comenzo) {
            comenzo = true

            musica.stop()
            game.boardGround("fondo_vacio.png")

            partida.comenzar()
        }
    }
}