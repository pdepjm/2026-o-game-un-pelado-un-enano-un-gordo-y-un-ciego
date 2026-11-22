import wollok.game.*
import partida.*

object pantallaInicio {
    var estado = "menu"

    const musica = game.sound("menu_principal.mp3")
    const musicaPrologo = game.sound("prologo.mp3")

    method mostrar() {
        estado = "menu"
        game.boardGround("menu_principal.gif")

        musica.shouldLoop(true)
        musica.play()

        keyboard.enter().onPressDo({ self.comenzar() })
    }

    method comenzar() {
        if (estado == "menu") {
            estado = "controles"
            musica.stop()
            musicaPrologo.shouldLoop(true)
            musicaPrologo.play()
            game.boardGround("controles.png")

        } else if (estado == "controles") {
            estado = "contexto"
            game.boardGround("contexto.png")

        } else if (estado == "contexto") {
            estado = "jugando"
            musicaPrologo.stop()
            game.boardGround("fondo_nivel.png")
            partida.comenzar()
        }
    }
}