
import wollok.game.*
import armas.*
import mapas.*
import personaje.*
import movimiento.*
import enemigo.*
import interfaz.*
import dialogos.*
import musica.*
import jefeFinal.*

object partida {
    var iniciada = false

    method reiniciar() { iniciada = false }

    method comenzar() {
        if (!iniciada) {
            iniciada = true
            game.addVisual(fondoNivel)
            personaje.activarMovimiento()
            personaje.activarDisparo()
            inventario.cambiarArma()
            mapa.empezarEn(inicio, game.center())

            game.addVisual(personaje)
           

            listaFondoHUD.forEach({ a => game.addVisual(a) })
            listaCorazones.forEach({ a => game.addVisual(a) })
            listaIconos.forEach({ a => game.addVisual(a) })
            game.addVisual(decenasEscopeta)
            game.addVisual(unidadesEscopeta)
            game.addVisual(iconoGranadas)
            game.addVisual(decenasGranadas)
            game.addVisual(unidadesGranadas)
        }
    }
}
