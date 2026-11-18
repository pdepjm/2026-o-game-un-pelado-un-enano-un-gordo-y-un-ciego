import wollok.game.*
import enemigo.*
import personaje.*
import musica.*

class EnemigoSandler inherits Enemigo {
override method image() = "prueba.png"
override method morido() {
    self.eliminar()
    jefeFinal.callar()
    finalJuego.mostrar()
}
}

class Frase {
    const property archivo
    const property duracionMs
}

object jefeFinal {
    var sandler = null
    var token = 0
    var sonidoActual = null
    var ultimaFrase = null
    const pausaMs = 3000

    const frases = [
        new Frase(archivo = "frase1.mp3", duracionMs = 2230),
        new Frase(archivo = "frase2.mp3", duracionMs = 5180),
        new Frase(archivo = "frase3.mp3", duracionMs = 3000)
    ]

    method aparecer() {
        if (sandler == null) {
            sandler = new EnemigoSandler(
                nombre = "sandler",
                imagen = "sandler",
                danio = 1,
                fuerzaEmpuje = 1,
                posicion = game.at(12, 10),
                salud = 1,
                velocidad = 1
            )
            game.addVisual(sandler)
            sandler.activar()

            token += 1
            const t = token
            game.schedule(1500, { self.hablar(t) })
        }
    }

    method hablar(t) {
        if (t == token && sandler != null && sandler.estaVivo()) {
            const frase = frases.filter({ f => f != ultimaFrase }).anyOne()
            ultimaFrase = frase
            sonidoActual = game.sound(frase.archivo())
            sonidoActual.play()
            game.schedule(frase.duracionMs() + pausaMs, { self.hablar(t) })
        }
    }

    method callar() {
        token += 1                           
        if (sonidoActual != null && sonidoActual.played()) sonidoActual.stop()
        sonidoActual = null
    }

    method desaparecer() {
        self.callar()
        if (sandler != null) {
            if (sandler.estaVivo()) sandler.eliminar()
            sandler = null
        }
    }
}

class Escena {
    const property imagen
    const property duracionMs
}

object finalJuego {
    var mostrado = false
    var indice = 0

    const escenas = [
        new Escena(imagen = "creditos1.gif", duracionMs = 6000)
    ]

    method image() = escenas.get(indice).imagen()
    method position() = game.origin()
    method estaVivo() = false

    method mostrar() {
        if (!mostrado) {
            mostrado = true
            personaje.bloquear()
            gestorMusica.detener()
            game.addVisual(self)
            game.sound("musica_creditos.mp3").play()
            self.programarSiguiente()
        }
    }

    method programarSiguiente() {
        game.schedule(escenas.get(indice).duracionMs(), { self.siguiente() })
    }

    method siguiente() {
        if (indice < escenas.size() - 1) {
            indice += 1
            self.programarSiguiente()
        } else {
            game.stop()
        }
    }
}