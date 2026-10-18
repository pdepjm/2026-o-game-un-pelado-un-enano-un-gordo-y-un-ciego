import wollok.game.*
import armas.*
import mapas.*
import personaje.*
import movimiento.*
import interfaz.alturaInterfaz

class Enemigo {
    const nombre               
    const imagen
    const danio
    const fuerzaEmpuje
    var posicion
    var direccion = "abajo"
    var pausa = false
    const velocidad 
    method velocidad() = velocidad
    var salud

    method estaVivo() = salud > 0

    method position() = posicion
    method image() = imagen
    method direccion() = direccion
    method danio() = danio
    method fuerzaEmpuje() = fuerzaEmpuje

    method puedeMoverA(pos) = pos.x() >= 0 && pos.x() < game.width() && pos.y() >= 0 && pos.y() <game.height() && !mapa.hayPared(pos)

    method moverA(pos) {if (self.puedeMoverA(pos)) {posicion = pos}}

    method activar() {
        game.onTick(500, "movimiento" + nombre, { self.perseguir() })
    }

    
    method perseguir() {
        if (!pausa) {
            const dir = movimiento.haciaObjetivo(posicion, personaje.position())
            if (dir != null) { self.intentarMover(dir) }
        }
    }

    method intentarMover(dir) {
            direccion = dir
            const nuevaPosicion = dir.desde(posicion, 1)
            if (nuevaPosicion == personaje.position()) {
                self.atacar()
            } else {
                self.moverA(nuevaPosicion)
            }
        }

    method empujado(enemigo) {
        movimiento.empujar(self, enemigo.direccion(), enemigo.fuerzaEmpuje())
    }

    method recibirDanio(cantidad) {
        if (self.estaVivo()) {
            salud = (salud - cantidad).max(0)

            if (!self.estaVivo()) { self.morido() }
        }
    }

    method atacar(){
        personaje.empujado(self)
        personaje.recibirDanio(fuerzaEmpuje)
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

object spawner{
    var contador = 0

    method posicionAleaoria(){
        const x = 0.randomUpTo(game.width().truncate(0))
        const y = alturaInterfaz.randomUpTo(game.height().truncate(0))
        const pos = game.at(x,y)
        return if (mapa.hayPared(pos) || pos.distance(personaje.position()) < 4) 
            self.posicionAleaoria() 
        else 
            pos
    }

    method crearZombie(){
        contador += 1
        const nuevo = new Enemigo(
            nombre = "zombie" + contador,
            imagen = "spiderodo_128x128.png",
            danio = 1,
            fuerzaEmpuje = 1,
            posicion = self.posicionAleaoria(),
            salud = 3,
            velocidad = 1
        )
        game.addVisual(nuevo)
        nuevo.activar()
    }
    method crearZombiesAleatorios(){
        (1..[1,2].anyOne()).forEach({i => self.crearZombie()})
    }
}

const zombie = new Enemigo(
    nombre = "zombie",
    imagen = "spiderodo_128x128.png",
    danio = 1,
    fuerzaEmpuje = 1,
    posicion = game.at(5, 5),
    salud = 3,
    velocidad = 1
)

