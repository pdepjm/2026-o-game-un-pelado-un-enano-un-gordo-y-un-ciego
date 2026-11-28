import dialogos.*
import wollok.game.*
import interfaz.*
import armas.*
import mapas.*
import movimiento.*
import musica.*
import maquinaDeEstados.*
import pantallaInicio.*
import partida.*


object personaje {
    var posicion = game.center()
    var direccion = abajo
    const velocidad = 1
    method velocidad() = velocidad
    var saludMaxima = 3
    var salud = saludMaxima
    method saludMaxima() = saludMaxima
    var caminando = false
    var herido = false
    var pasoId = 0


    method image() {
    const estado =
        if (herido) "herido"
        else if (caminando) "caminando"
        else "quieto"
    return "personaje_" + estado + "_" + direccion.nombre() + ".gif"
}

    method position() = posicion
    method position(nuevaPos) { posicion = nuevaPos }



    method salud() = salud
    method estaVivo() = salud > 0
    method curar(cantidad) {
    salud = (salud + cantidad).min(saludMaxima)
}

    method direccion() = direccion
    method direccion(nuevaDireccion) { direccion = nuevaDireccion }

    method puedeMoverA(pos) = pos.x() >= 0 && pos.x() < game.width() && pos.y() >= alturaInterfaz && pos.y() < game.height() && !mapa.bloqueaJugador(pos)
       
        method moverA(pos) {
               if (self.estaVivo() && self.puedeMoverA(pos) && !gestorDialogos.activo()) {
                posicion = pos
                self.marcarCaminando()
                mapa.alPisar(pos)
            }
        }

    method activarMovimiento() { movimiento.activarTeclas(self) }

        method marcarCaminando() {
        caminando = true
        pasoId += 1
        const id = pasoId
        game.schedule(150, { if (pasoId == id) caminando = false })
    }
    method activarDisparo() {
        keyboard.x().onPressDo({ inventario.armaSeleccionada().disparar() })
    }

       method empujado(enemigo) {
        movimiento.empujar(self, enemigo.direccion(), enemigo.fuerzaEmpuje())
    }


    var invulnerable = false

    

    method recibirDanio(cantidad) {
        if (!invulnerable && !muerto) {
            salud = (salud - cantidad).max(0)
            if (!self.estaVivo()) {
                self.morido()
            } else {
                invulnerable = true
                herido = true
                game.schedule(400, { herido = false })
                game.schedule(1000, { invulnerable = false })
            }
        }
    }
    var muerto = false

    method morido() {
        if (!muerto) {
            muerto = true
            gestorMusica.detener()
            game.schedule(700, { gameOver.mostrar() })
        }
    }

    method reiniciar() {
        saludMaxima = 3
        salud = saludMaxima
        muerto = false
        invulnerable = false
        herido = false
        caminando = false
        direccion = abajo
        posicion = game.center()
    }
    method aniadirVida() {
        if (saludMaxima < 5) {
            saludMaxima += 1
            game.addVisual(new Corazon(indice = saludMaxima))
        }
    }
}

object gameOver {
    var activo = false

    method mostrar() {
        activo = true
        mapa.limpiarTodo()
        gestorDialogos.cerrarDialogo()
        game.clear()
        game.boardGround("gameover.png")
        keyboard.enter().onPressDo({ if (activo) self.volverAlMenu() })
    }

    method volverAlMenu() {
        activo = false
        personaje.reiniciar()
        partida.reiniciar()  
        juego.reiniciar()
        inventario.reiniciar()
        gestorDialogos.reiniciar()
        pantallaInicio.mostrar()
        mapa.reiniciarMundo()
    }
}