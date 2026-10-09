import wollok.game.*
import mapas.*
import personaje.*
import movimiento.*


/*
    ADVERTENCIA:
    Al ser proyectil un objeto único, cuando se dispara y se llama a addVisual existe la posibilidad
    de que el objeto ya haya sido agregado a la pantalla, por lo cual se debe buscar una solución,
    posiblemente con proyectiles independientes
*/
object proyectil {
    var orientacion = "abajo"
    var nombreArma = "cuchillo"
    var posicion = game.at(0,0)
    var direccionAvance = game.at(0, 0)
    var distanciaRecorrida = 1 //esta variable tiene un nombre largo, excesivamente largo, no deberia ser tan largo, pero voy a hacerlo largo, quiero hacerlo largo, tan largo como yo quiera, aunque solo almace un numero, no me importa, será largo, tan largo como yo quiera, porque si quiero hacerlo largo, lo hago largo, no me imnporta lo que vos quieras, largo, largo, largo
    var distanciaMaxima = 0
    var velocidad = 4

    method retraso() = 100/velocidad //alonso
    const tickAvance = game.tick(self.retraso(), {self.confirmarAvance()}, false)


    method position(nuevaPos) {posicion = nuevaPos}
    method position() = posicion
    method image() = nombreArma + "_" + orientacion + ".png"

     method avanzar(direccion, nombreDireccion, alcance, velProyectil, nomArma) {
        direccionAvance = direccion
        orientacion = nombreDireccion
        distanciaMaxima = alcance
        velocidad = velProyectil
        nombreArma = nomArma
        tickAvance.start()
    }

   method confirmarAvance() {
    const siguiente = game.at(posicion.x() + direccionAvance.x(), posicion.y() + direccionAvance.y()) 
    if (distanciaRecorrida < distanciaMaxima && !mapa.hayPared(siguiente)) {
       self.position(siguiente)
        distanciaRecorrida += 1
        self.verificarColision()
    } else {
        self.detener()
    }
    }

    method verificarColision() {
        const enemigoGolpeado = game.colliders(self).filter({ bicho => bicho.estaVivo() })
        if (enemigoGolpeado.size() > 0) {
            enemigoGolpeado.first().recibirDanio(1)
            self.detener()
        }
        }

    method detener() {
        tickAvance.stop()
        distanciaMaxima = 0
        distanciaRecorrida = 1
        game.removeVisual(self)
    }
        
}

class Arma {
    const nombre 
    const alcance
    const velProyectil
    const imgSeleccionado
    const imgNoSeleccionado
    method imgSeleccionado() = imgSeleccionado
    method imgNoSeleccionado() = imgNoSeleccionado
    var pausa = false

    method vectorDe(dir)=
        if (dir == "arriba") game.at(0, 1)
        else if (dir == "abajo") game.at(0, -1)
        else if (dir == "izquierda") game.at(-1, 0)
        else if (dir == "derecha") game.at(1, 0)

    method disparar() {
        if (!pausa) {
            self.pausar()
            const dir = personaje.direccion()
            const vector = dir.desde(game.origin(), 1)
            game.addVisual(proyectil)
            proyectil.position(dir.desde(personaje.position(), 1))
            proyectil.avanzar(vector, dir.nombre(), alcance, velProyectil, nombre)
        }
    }

        method pausar() {
        pausa = true
        game.schedule(150, { pausa = false })
    }
}

const cuchillo = new Arma(
    nombre = "cuchillo",
    alcance = 1,
    velProyectil = 2,
    imgSeleccionado= "cuchillo_seleccionado.png",
    imgNoSeleccionado = "cuchillo_noseleccionado.png"
)

const revolver = new Arma(
    nombre = "revolver",
    alcance = 5,
    velProyectil = 4,
    imgSeleccionado ="revolver_seleccionado.png",
    imgNoSeleccionado = "revolver_noseleccionado.png"
)

object inventario{
    const listaInventario = [cuchillo,revolver]
    var armaElegida = 0

    method aniadirArma(arma){
        listaInventario.add(arma)
    }
    method cambiarArma(){
        keyboard.num(1).onPressDo({armaElegida = 0})
        keyboard.num(2).onPressDo({armaElegida = 1})
        keyboard.num(3).onPressDo({armaElegida = 2})
        keyboard.num(4).onPressDo({armaElegida = 3})
    }
    method seleccionarArma() = listaInventario.get(armaElegida)
    method tieneArma(indice) = listaInventario.size() > indice
    method arma(indice) = listaInventario.get(indice)
    method estaSeleccionada(indice) = armaElegida == indice
    method armas() = listaInventario 
}



