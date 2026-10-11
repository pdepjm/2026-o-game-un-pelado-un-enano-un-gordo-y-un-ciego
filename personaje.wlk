import wollok.game.*
import interfaz.*
import armas.*
import mapas.*
import movimiento.*

object personaje {
    var posicion = game.center()
    var direccion = abajo
    const velocidad = 1
    method velocidad() = velocidad
    const saludMaxima = 3
    var salud = saludMaxima
    method saludMaxima() = saludMaxima



    method image() = "personaje_" + direccion.nombre() + ".gif"
    method position() = posicion
    method position(nuevaPos) { posicion = nuevaPos }



    method salud() = salud
    method estaVivo() = salud > 0

    method direccion() = direccion
    method direccion(nuevaDireccion) { direccion = nuevaDireccion }

    method puedeMoverA(pos) =
    pos.x() >= 0 && pos.x() < game.width() && pos.y() >= alturaInterfaz && pos.y() < game.height() && !mapa.hayPared(pos)
    method moverA(pos) { 
        if (self.puedeMoverA(pos)) {
            posicion = pos 
            mapa.alPisar(pos)}
            }

    method activarMovimiento() { movimiento.activarTeclas(self) }

 
    method activarDisparo() {
        keyboard.x().onPressDo({ inventario.seleccionarArma().disparar() })
    }

       method empujado(enemigo) {
        movimiento.empujar(self, enemigo.direccion(), enemigo.fuerzaEmpuje())
    }


    method recibirDanio(cantidad) {
        if (self.estaVivo()) 
            salud = (salud - cantidad).max(0)
        else  self.morido() 
    }

    method morido() {
        game.schedule(15, { game.stop() })
    }
}


