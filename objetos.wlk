import wollok.game.*

object personaje {
    var posicion = game.center()
    var direccion = "abajo"
    const velocidad = 1
   // var salud = 100
    method position() = posicion
    method image() = "personaje_" + direccion + ".png"

    method direccion(nuevaDireccion) {
        direccion = nuevaDireccion
    }

    method moverArriba() {if (posicion.y() < game.height() - 1) { posicion = posicion.up(velocidad) }}
    method moverAbajo() {if (posicion.y() > 0) { posicion = posicion.down(velocidad) }}
    method moverIzquierda() {if (posicion.x() > 0) { posicion = posicion.left(velocidad) }}
    method moverDerecha() {if (posicion.x() < game.width() - 1) { posicion = posicion.right(velocidad) }}

   method empujado(zombie, fuerza) {
    const posZombie = zombie.position()
    if (posicion.y() > posZombie.y()) { self.empujarVeces("arriba", fuerza) }
    if (posicion.y() < posZombie.y()) { self.empujarVeces("abajo", fuerza) }
    if (posicion.x() > posZombie.x()) { self.empujarVeces("derecha", fuerza) }
    if (posicion.x() < posZombie.x()) { self.empujarVeces("izquierda", fuerza) }

    if (posicion == posZombie) {
        self.empujarVeces(zombie.direccion(), fuerza)
    }

    //method salud(){
        
   // }


    zombie.pausar()
}

method empujarVeces(direccionEmpuje, veces) {
    (1..veces).forEach({ i =>
        if (direccionEmpuje == "arriba") { self.moverArriba() }
        if (direccionEmpuje == "abajo") { self.moverAbajo() }
        if (direccionEmpuje == "izquierda") { self.moverIzquierda() }
        if (direccionEmpuje == "derecha") { self.moverDerecha() }
    })
}
}



object zombie {
    var direccion = "abajo"
    var posicion = game.at(5, 5)
    var pausa = false
    method position() = posicion
    method direccion() = direccion
    method image() = "spiderodo_128x128.png"

    method moverZombie() {
        game.onTick(500, "movimientoZombie", { self.perseguir() })
    }

    method perseguir() {
        if (!pausa){
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
        personaje.empujado(self, 2)
    }
    if (nuevaPosicion != personaje.position()) {
        posicion = nuevaPosicion
    }
}
method pausar(){
        pausa = true
        game.schedule(1000, {pausa = false})
    }
}




