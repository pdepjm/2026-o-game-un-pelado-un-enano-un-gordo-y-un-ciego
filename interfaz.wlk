import wollok.game.*
import armas.*
import mapas.*
import personaje.*
import movimiento.*


//Cositas de la interfaz
class Corazon {
    const indice

    method position() = game.at(indice - 1, 0)
    method image() = if (personaje.salud() >= indice) "corazon_lleno.png" else "corazon_vacio.png"
}

const corazon1 = new Corazon(
    indice = 1
)
const corazon2 = new Corazon(
    indice = 2
)
const corazon3 = new Corazon(
    indice = 3
)

const listaCorazones = (1..personaje.saludMaxima()).map({ i => new Corazon(indice = i) })

class IconoInventario {
    const arma
    const indice

    method position() = game.at(5 + indice, 0)
    method image() = if (inventario.estaSeleccionada(indice)) arma.imgSeleccionado() else arma.imgNoSeleccionado()
}

const listaIconos = (0..(inventario.armas().size() - 1)).map({ i => new IconoInventario(arma = inventario.arma(i), indice = i)})

class FondoHUD {
    const posicionX

    method position() = game.at(posicionX, 0)
    method image() = "hud_fondo.png"
}

const listaFondoHUD = (0..(24)).map({ x => new FondoHUD(posicionX = x) }) //24 provicional, la idea es que sea del ancho de la pantalla.

