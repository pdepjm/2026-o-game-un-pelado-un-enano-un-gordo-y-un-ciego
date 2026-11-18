import wollok.game.*
import partida.*

object pantallaInicio {
    var fase = "titulo"    
    var tokenIntro = 0
    var sonidoIntro = null
    const msIntro = 20000      

    const musica = game.sound("menu_principal.mp3")

    method mostrar() {
        fase = "titulo"
        game.boardGround("menu_principal.gif")

        musica.shouldLoop(true)
        musica.play()

        keyboard.enter().onPressDo({ self.alApretarEnter() })
    }

    method alApretarEnter() {
        if (fase == "titulo") self.comenzarIntro()
        else if (fase == "intro") self.terminarIntro()
    }

    method comenzarIntro() {
        fase = "intro"
        musica.stop()
        game.boardGround("intro.gif")
        sonidoIntro = game.sound("intro.mp3")
        sonidoIntro.play()

        tokenIntro += 1
        const t = tokenIntro
        game.schedule(msIntro, { if (t == tokenIntro) self.terminarIntro() })
    }

    method terminarIntro() {
        if (fase == "intro") {
            fase = "juego"
            tokenIntro += 1               
            if (sonidoIntro != null) sonidoIntro.stop()
            game.boardGround("fondo_nivel.png")
            partida.comenzar()
        }
    }
}