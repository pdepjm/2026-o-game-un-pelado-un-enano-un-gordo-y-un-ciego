import wollok.game.*

const alturaInterfaz = 1
object personaje {
    var posicion = game.center()
    var direccion = "abajo"
    const velocidad = 1
    const saludMaxima = 3
    var salud = saludMaxima
    method saludMaxima() = saludMaxima


    method position() = posicion
    method image() = "personaje_" + direccion + ".png"
    method text() = salud.toString()          // muestra la salud sobre el personaje

    method salud() = salud
    method estaVivo() = salud > 0

    method direccion() = direccion
    method direccion(nuevaDireccion) { direccion = nuevaDireccion }

    method puedeMoverA(pos) =
    pos.x() >= 0 && pos.x() < game.width() && pos.y() >= alturaInterfaz && pos.y() < game.height() && !mapa.hayPared(pos)
    method moverA(pos) {if (self.puedeMoverA(pos)) {posicion = pos}}

    method moverArriba() { self.moverA(posicion.up(velocidad)) }
    method moverAbajo() { self.moverA(posicion.down(velocidad)) }
    method moverIzquierda() { self.moverA(posicion.left(velocidad)) }
    method moverDerecha() { self.moverA(posicion.right(velocidad)) }

    method activarMovimiento() {
        const retraso = 100

        const tickArriba = game.tick(retraso, { self.moverArriba() }, false)
        const tickAbajo = game.tick(retraso, { self.moverAbajo() }, false)
        const tickIzquierda = game.tick(retraso, { self.moverIzquierda() }, false)
        const tickDerecha = game.tick(retraso, { self.moverDerecha() }, false)

        keyboard.up().onPressDo({
            self.direccion("arriba")
            tickArriba.start()
        })
        keyboard.up().onReleaseDo({ tickArriba.stop() })

        keyboard.down().onPressDo({
            self.direccion("abajo")
            tickAbajo.start()
        })
        keyboard.down().onReleaseDo({ tickAbajo.stop() })

        keyboard.left().onPressDo({
            self.direccion("izquierda")
            tickIzquierda.start()
        })
        keyboard.left().onReleaseDo({ tickIzquierda.stop() })

        keyboard.right().onPressDo({
            self.direccion("derecha")
            tickDerecha.start()
        })
        keyboard.right().onReleaseDo({ tickDerecha.stop() })
    }


    method activarDisparo() {
        keyboard.x().onPressDo({ inventario.seleccionarArma().disparar() })
    }

    method empujado(enemigo) {
        self.empujar(enemigo.direccion(), enemigo.fuerzaEmpuje())
    }

    method empujar(direccionEmpuje, fuerza) {
        (1..fuerza).forEach({ i =>
            if (direccionEmpuje == "arriba") { self.moverArriba() }
            if (direccionEmpuje == "abajo") { self.moverAbajo() }
            if (direccionEmpuje == "izquierda") { self.moverIzquierda() }
            if (direccionEmpuje == "derecha") { self.moverDerecha() }
        })
    }

    method recibirDanio(cantidad) {
        if (self.estaVivo()) {
            salud = (salud - cantidad).max(0)
            if (!self.estaVivo()) { self.morido() }
        }
    }

    method morido() {
        game.schedule(15, { game.stop() })
    }
}

/*
    ADVERTENCIA:
    Al ser proyectil un objeto único, cuando se dispara y se llama a addVisual existe la posibilidad
    de que el objeto ya haya sido agregado a la pantalla, por lo cual se debe buscar una solución,
    posiblemente con proyectiles independientes
*/
object proyectil {
    var orientacion = "abajo"
    var posicion = game.at(0,0)
    var direccionAvance = game.at(0, 0)
    var distanciaRecorrida = 1 //esta variable tiene un nombre largo, excesivamente largo, no deberia ser tan largo, pero voy a hacerlo largo, quiero hacerlo largo, tan largo como yo quiera, aunque solo almace un numero, no me importa, será largo, tan largo como yo quiera, porque si quiero hacerlo largo, lo hago largo, no me imnporta lo que vos quieras, largo, largo, largo
    var distanciaMaxima = 0
    var velocidad = 4

    method retraso() = 100/velocidad //alonso
    const tickAvance = game.tick(self.retraso(), {self.confirmarAvance()}, false)


    method position(nuevaPos) {posicion = nuevaPos}
    method position() = posicion
    method image() = "bala_" + orientacion + ".png"

    method avanzar(direccion, nombreDireccion, alcance, velProyectil) {
        direccionAvance = direccion
        orientacion = nombreDireccion
        distanciaMaxima = alcance
        velocidad = velProyectil
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

class Enemigo {
    const nombre               
    const imagen
    const danio
    const fuerzaEmpuje
    var posicion
    var direccion = "abajo"
    var pausa = false
    var velocidad 
    var salud

    method estaVivo() = salud > 0

    method position() = posicion
    method image() = imagen
    method direccion() = direccion
    method danio() = danio
    method fuerzaEmpuje() = fuerzaEmpuje

    method puedeMoverA(pos) = pos.x() >= 0 && pos.x() < game.width() && pos.y() >= 0 && pos.y() <game.height() && !mapa.hayPared(pos)

    method moverA(pos) {if (self.puedeMoverA(pos)) {posicion = pos}}

    method moverArriba() { self.moverA(posicion.up(velocidad)) }
    method moverAbajo() { self.moverA(posicion.down(velocidad)) }
    method moverIzquierda() { self.moverA(posicion.left(velocidad)) }
    method moverDerecha() { self.moverA(posicion.right(velocidad)) }

    method activar() {
        game.onTick(500, "movimiento" + nombre, { self.perseguir() })
    }

    method perseguir() {
        if (!pausa) {
            const objetivo = personaje.position()
            if (objetivo.x() > posicion.x()) {
                self.intentarMover(posicion.right(1), "derecha")
            } else if (objetivo.x() < posicion.x()) {
                self.intentarMover(posicion.left(1), "izquierda")
            } else if (objetivo.y() > posicion.y()) {
                self.intentarMover(posicion.up(1), "arriba")
            } else if (objetivo.y() < posicion.y()) {
                self.intentarMover(posicion.down(1), "abajo")
            }
        }
    }

    method intentarMover(nuevaPosicion, nuevaDireccion) {
        direccion = nuevaDireccion
        if (nuevaPosicion == personaje.position()) {
            self.atacar()
        } else {
            self.moverA(nuevaPosicion)
        }
    }

    method atacar() {
        personaje.recibirDanio(danio)
        personaje.empujado(self)
        self.pausar()
    }
     method empujado(enemigo) {
        self.empujar(enemigo.direccion(), enemigo.fuerzaEmpuje())
    }

    method empujar(direccionEmpuje, fuerza) {
        (1..fuerza).forEach({ i =>
            if (direccionEmpuje == "arriba") { self.moverArriba() }
            if (direccionEmpuje == "abajo") { self.moverAbajo() }
            if (direccionEmpuje == "izquierda") { self.moverIzquierda() }
            if (direccionEmpuje == "derecha") { self.moverDerecha() }
        })
    }

    method recibirDanio(cantidad) {
        if (self.estaVivo()) {
            salud = (salud - cantidad).max(0)
            self.empujado(self)
            if (!self.estaVivo()) { self.morido() }
        }
    }

    method pausar() {
        pausa = true
        game.schedule(1000, { pausa = false })
    }

    method morido(){
            game.removeVisual(self)
            game.removeTickEvent("movimiento" + nombre)
    }
}

class Arma {
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
           const vector = self.vectorDe(dir)
           game.addVisual(proyectil)
           proyectil.position(game.at(personaje.position().x() + vector.x(), personaje.position().y() + vector.y()))
              proyectil.avanzar(vector, dir, alcance, velProyectil)
        }
}

    method pausar() {
        pausa = true
        game.schedule(150, { pausa = false })
    }
}

const cuchillo = new Arma(
    alcance = 1,
    velProyectil = 2,
    imgSeleccionado= "cuchillo_seleccionado.png",
    imgNoSeleccionado = "cuchillo_noseleccionado.png"
)

const revolver = new Arma(
    alcance = 5,
    velProyectil = 4,
    imgSeleccionado ="revolver_seleccionado.png",
    imgNoSeleccionado = "revolver_noseleccionado.png"
)

const zombie = new Enemigo(
    nombre = "zombie",
    imagen = "spiderodo_128x128.png",
    danio = 1,
    fuerzaEmpuje = 1,
    posicion = game.at(5, 5),
    salud = 3,
    velocidad = 1
)



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


class Pared {
    const posicion

    method position() = posicion
    method image() = "hud_fondo.png"
}

object mapa {
    const paredes = []

    method agregarPared(x, y) {
        const pared = new Pared(posicion = game.at(x, y))
        paredes.add(pared)
        game.addVisual(pared)
    }

    method hayPared(pos) = paredes.any({ p => p.position() == pos })
}