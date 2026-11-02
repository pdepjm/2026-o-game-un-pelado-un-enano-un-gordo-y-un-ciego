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
    var direccion = abajo
    var pausa = false
    const velocidad 
    method velocidad() = velocidad
    var salud

    method estaVivo() = salud > 0

    method position() = posicion
    method image() = imagen +"_"+ self.direccion() + ".gif"
    method direccion() = direccion
    method danio() = danio
    method fuerzaEmpuje() = fuerzaEmpuje

    method puedeMoverA(pos) = mapa.esPiso(pos)
    method puedeAvanzar(dir) {
        const destino = dir.desde(posicion, 1)
        return destino == personaje.position() || self.puedeMoverA(destino)
    }
    method moverA(pos) {if (self.puedeMoverA(pos)) {posicion = pos}}

    method activar() {
    game.onTick(1000 / velocidad, "movimiento" + nombre, { self.perseguir() })
    }

    
   method perseguir() {
        if (!pausa) {
            const preferidas = movimiento.direccionesHacia(posicion, personaje.position())
                .filter({ d => self.puedeAvanzar(d) })
            if (!preferidas.isEmpty()) {
                self.intentarMover(preferidas.first())
            } else {
                const libres = movimiento.direcciones().filter({ d => self.puedeAvanzar(d) })
                if (!libres.isEmpty()) { self.intentarMover(libres.anyOne()) }
            }
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
        if (inventario.estaSeleccionada(0)){
            movimiento.empujar(self, personaje.direccion(), 1)
        }
        if (self.estaVivo()) {
            salud = (salud - cantidad).max(0)

            if (!self.estaVivo()) { self.morido() }
        }
    }
     method eliminar() {
        game.removeVisual(self)
        game.removeTickEvent("movimiento" + nombre)
    }
    method atacar(){
        personaje.empujado(self)
        personaje.recibirDanio(fuerzaEmpuje)
    }

    method pausar() {
        pausa = true
        game.schedule(1000, { pausa = false })
    }

     method morido() {
        loot.tirar(posicion)
        self.eliminar()
    }
}

object spawner {
    var contador = 0
    const enemigos = []

    method posicionAleatoria() {
        const x = 0.randomUpTo(game.width()).truncate(0)
        const y = alturaInterfaz.randomUpTo(game.height()).truncate(0)
        const pos = game.at(x, y)
        return if (!mapa.esPiso(pos) || pos.distance(personaje.position()) < 4)
            self.posicionAleatoria()
        else
            pos
    }

    method crearZombie() {
    self.crearZombieEn(self.posicionAleatoria())
    }

    method crearZombieEn(pos) {
        contador += 1

        const nuevo = new Enemigo(
            nombre = "zombie" + contador,
            imagen = "pueblerino",
            danio = 1,
            fuerzaEmpuje = 1,
            posicion = pos,
            salud = 3,
            velocidad = 1
        )

        enemigos.add(nuevo)
        game.addVisual(nuevo)
        nuevo.activar()
    }
    method crearZombiesAleatorios() {
        (1..[1, 2].anyOne()).forEach({ i => self.crearZombie() })
    }
    method hayZombiesVivos() = enemigos.any({ e => e.estaVivo() })
    method limpiar() {
        enemigos.filter({ e => e.estaVivo() }).forEach({ e => e.eliminar() })
        enemigos.clear()
    }

    method crearRapidinEn(pos) {
    contador += 1

    const nuevo = new Enemigo(
        nombre = "rapidin" + contador,
        imagen = "rapidin",
        danio = 1,
        fuerzaEmpuje = 2,
        posicion = pos,
        salud = 1,
        velocidad = 3
    )

    enemigos.add(nuevo)
    game.addVisual(nuevo)
    nuevo.activar()
    }

    method crearRapidin() {
        self.crearRapidinEn(self.posicionAleatoria())
    }

    method crearRapidinesAleatorios() {
        (1..[1, 3].anyOne()).forEach({ i => self.crearRapidin() })
    }
}


const tanke = new Enemigo(
    nombre = "tanke",
    imagen = "tanke",
    danio = 2,
    fuerzaEmpuje = 4,
    velocidad = 1,
    salud = 6,
    posicion = game.at(1,1)
)