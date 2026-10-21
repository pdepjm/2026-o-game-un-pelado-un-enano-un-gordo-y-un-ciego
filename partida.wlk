
import wollok.game.*
import armas.*
import mapas.*
import personaje.*
import movimiento.*
import enemigo.*
import interfaz.*

object partida {
    var iniciada = false

    method comenzar() {
        if (!iniciada) {
            iniciada = true
            game.addVisual(fondoNivel)
            personaje.activarMovimiento()
            personaje.activarDisparo()
            inventario.cambiarArma()
            mapa.empezarEn(salaA, game.center())

            game.addVisual(personaje)
            spawner.crearZombiesAleatorios()

            listaFondoHUD.forEach({ a => game.addVisual(a) })
            listaCorazones.forEach({ a => game.addVisual(a) })
            listaIconos.forEach({ a => game.addVisual(a) })
        }
    }
}
