import wollok.game.*
import mapas.*
import personaje.*
import movimiento.*
import jefePelado.*
import interfaz.*

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
    var orientacion      // objeto: arriba/abajo/izquierda/derecha
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
            const objetivo = golpeados.first()
            if (objetivo == jefePelado && jefePelado.reflejaBalas()) {
                self.rebotar()
            } else {
                objetivo.recibirDanio(1)
                self.detener()
            }
        }
    }

    method rebotar() {
        orientacion = orientacion.opuesto()
        recorrido = 1
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
    const tiempoPausa
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
        game.schedule(tiempoPausa, { pausa = false })
    }
}

class Escopeta inherits Arma {
    var balas = 0

    method balas() = balas
    method cargar(cantidad) { balas += cantidad }

    override method disparar() {
        if (!pausa && balas > 0) {
            self.pausar()
            balas -= 1
            const dir = personaje.direccion()
            const dirOrtogonal = if (dir.nombre() == "arriba" || dir.nombre() == "abajo") izquierda else arriba
            const pos = dir.desde(personaje.position(), 1)
            if (!mapa.hayPared(pos)) {
                game.schedule(200/velProyectil, {
                    new Proyectil(
                        nombreArma = nombre,
                        orientacion = dir,
                        alcance = alcance - 2,
                        retraso = 100 / velProyectil,
                        posicion = self.conoEn(3, dir, dirOrtogonal, 2)
                    ).lanzar()
                    new Proyectil(
                        nombreArma = nombre,
                        orientacion = dir,
                        alcance = alcance - 2,
                        retraso = 100 / velProyectil,
                        posicion = self.conoEn(3, dir, dirOrtogonal, -2)
                    ).lanzar()
                })
                game.schedule(100/velProyectil, {
                    new Proyectil(
                        nombreArma = nombre,
                        orientacion = dir,
                        alcance = alcance - 1,
                        retraso = 100 / velProyectil,
                        posicion = self.conoEn(2, dir, dirOrtogonal, 1)
                    ).lanzar()
                    new Proyectil(
                        nombreArma = nombre,
                        orientacion = dir,
                        alcance = alcance - 1,
                        retraso = 100 / velProyectil,
                        posicion = self.conoEn(2, dir, dirOrtogonal, -1)
                    ).lanzar()
                })
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

    /*expansion representa hacia qué sentido de la direccion ortogonal y con qué magnitud se expande el cono*/
    method conoEn(posicion, direccion, ortogonal, expansion) =
        if (posicion < 2) direccion.desde(personaje.position(), 1)
        else game.at(
            direccion.desde(personaje.position(), posicion).x() + ortogonal.desde(game.at(0,0), expansion).x(),
            direccion.desde(personaje.position(), posicion).y() + ortogonal.desde(game.at(0,0), expansion).y()
        )
}

const cuchillo = new Arma(
    nombre = "cuchillo",
    alcance = 1,
    velProyectil = 2,
    tiempoPausa = 150,
    imgSeleccionado= "cuchillo_seleccionado.png",
    imgNoSeleccionado = "cuchillo_noseleccionado.png"
)

const revolver = new Arma(
    nombre = "revolver",
    alcance = 7,
    velProyectil = 4,
    tiempoPausa = 350,
    imgSeleccionado ="revolver_seleccionado.png",
    imgNoSeleccionado = "revolver_noseleccionado.png"
)

const escopeta = new Escopeta(
    nombre = "escopeta",
    alcance = 3,
    velProyectil = 4,
    tiempoPausa = 1000,
    imgSeleccionado ="escopeta_seleccionada.png",
    imgNoSeleccionado = "escopeta_noseleccionada.png"
)

object inventario{
    const listaInventario = [cuchillo, revolver]
    var armaElegida = 0

    method aniadirArma(arma) {
        if (!listaInventario.contains(arma)) {
            listaInventario.add(arma)
            game.addVisual(new IconoInventario(arma = arma, indice = listaInventario.size() - 1))
        }
    }
    method cambiarArma(){
        keyboard.num(1).onPressDo({self.seleccionar(0)})
        keyboard.num(2).onPressDo({self.seleccionar(1)})
        keyboard.num(3).onPressDo({self.seleccionar(2)})
        keyboard.num(4).onPressDo({self.seleccionar(3)})
    }
    var soloCuchillo = false

    method soloCuchillo(valor) {
        soloCuchillo = valor
        if (valor) armaElegida = 0
    }

    method seleccionar(indice) {
        if (!soloCuchillo && self.tieneArma(indice)) armaElegida = indice
    }
    method armaSeleccionada() =  listaInventario.get(armaElegida)
    method tieneArma(indice) = listaInventario.size() > indice
    method arma(indice) = listaInventario.get(indice)
    method estaSeleccionada(indice) = armaElegida == indice
    method armas() = listaInventario 
}



object loot {
    method tirar(pos) {
        const tirada = 0.randomUpTo(1)
        const item =
            if (tirada < 0.2) new ItemCorazon(posicion = pos)
            else if (tirada < 0.5) new ItemBalas(posicion = pos, cantidad = 2)
            else null
        if (item != null) {
            mapa.agregarItem(item)
            game.addVisual(item)
        }
    }

    // Esto es para el jefe Gordo, así evitamos un softlock. Si le disparás mientras se lastra un sanguche, la bola de cebo va a soltar balas
    method tirarBalas(pos, cantidad) {
        const item = new ItemBalas(posicion = pos, cantidad = cantidad)
        mapa.agregarItem(item)
        game.addVisual(item)
    }
}

class ItemBalas {
    const posicion
    const cantidad

    method position() = posicion
    method image() = "balas_escopeta.png"
    method estaVivo() = false   

    method alPisar() {
    escopeta.cargar(cantidad)
    game.removeVisual(self)
    }

    

}

class ItemCorazon {
    const posicion
    const curacion = 1

    method position() = posicion
    method image() = "corazon_loot.png"
    method estaVivo() = false

    method alPisar() {
        personaje.curar(curacion)
        game.removeVisual(self)
    }
}

object itemEscopeta {
    method position() = game.at(7, 8)
    method image() = "escopeta_suelo.png"
    method alPisar() { inventario.aniadirArma(escopeta) }
}