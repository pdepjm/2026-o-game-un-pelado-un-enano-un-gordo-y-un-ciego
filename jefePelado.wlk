
import wollok.game.*

object jefePelado {
    var posicion = game.at(12, 9)
    var vida = 10
    var peladaBrillando = true

    method position() = posicion
    method image() = "fotoPruebaJefePelado.png"
    method estaVivo() = vida > 0
    method vidaActual() = vida

    method recibirDanio() {
        if (self.estaVivo() && !peladaBrillando) {
            vida -= 1
        }
    }

    method aparecer() {
        vida = 10
        peladaBrillando = true
        console.println("APARECIO EL PELADO")
        game.addVisual(self)
    }

    method desaparecer() {
        game.removeVisual(self)
    }
}
