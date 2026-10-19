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
object municion {
    var contador = 0
    method siguienteId() {
        contador += 1
        return contador
    }
}

class Proyectil {
    const id = municion.siguienteId()
    const nombreArma
    const orientacion      // objeto: arriba/abajo/izquierda/derecha
    const alcance
    const retraso
    var posicion
    var recorrido = 1
    var activo = true

    method position() = posicion
    method image() = nombreArma + "_" + orientacion.nombre() + ".png"
    method estaVivo() = false   // para que otros proyectiles no cuenten como enemigos

    method lanzar() {
        game.addVisual(self)
        game.onTick(retraso, "proyectil" + id, { self.avanzar() })
        self.verificarColision()
    }

   method avanzar() {
        if (activo) {
            const siguiente = orientacion.desde(posicion, 1)
            if (recorrido < alcance && !mapa.hayPared(siguiente)) {
                posicion = siguiente
                recorrido += 1
                self.verificarColision()
            } else {
                self.detener()
            }
        }
    }

    method verificarColision() {
        const golpeados = game.colliders(self).filter({ b => b.estaVivo() })
        if (!golpeados.isEmpty()) {
            golpeados.first().recibirDanio(1)
            self.detener()
        }
    }

    method detener() {
        if (activo) {
            activo = false
            game.removeTickEvent("proyectil" + id)
            game.removeVisual(self)
        }
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
            const pos = dir.desde(personaje.position(), 1)
            if (!mapa.hayPared(pos)) {
                new Proyectil(
                    nombreArma = nombre,
                    orientacion = dir,
                    alcance = alcance,
                    retraso = 100 / velProyectil,
                    posicion = pos
                ).lanzar()
            }
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



