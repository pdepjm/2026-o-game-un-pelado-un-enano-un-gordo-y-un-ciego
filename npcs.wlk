import wollok.game.*
import mapas.*
import llaves.*
import dialogos.*
import maquinaDeEstados.juego

class Npc {
    const posicion
    const imagen
    var visible = false
    var cerca = false

    method position() = posicion
    method image() = imagen
    method estaVivo() = false
    method visible() = visible

    method aparece(sala)
    method dialogo()

    method mostrar() {
        if (!visible) {
            visible = true
            game.addVisual(self)
        }
    }

    method ocultar() {
        if (visible) {
            visible = false
            game.removeVisual(self)
        }
        cerca = false
    }


    method estaAlLado(pos) =
        (posicion.x() == pos.x() && (posicion.y() - pos.y()).abs() == 1) ||
        (posicion.y() == pos.y() && (posicion.x() - pos.x()).abs() == 1)

    method alMoverseJugador(pos) {
        const ahoraCerca = self.estaAlLado(pos)
        if (ahoraCerca && !cerca) gestorDialogos.mostrarSecuencia(self.dialogo())
        cerca = ahoraCerca
    }
}



class Luisito inherits Npc {
    const dialogoFijo

    override method aparece(sala) =
        sala == pueblo && !juego.existeLlave(llavePelado)

    override method dialogo() = dialogoFijo
}

class Ashley inherits Npc {
    const dialogos          

    override method aparece(sala) =
        [pueblo, iglesia, salaJefePelado, muelle, entradaCastillo, lobbyCastillo].contains(sala)
        && juego.existeLlave(llavePelado)
        && !juego.existeLlave(llaveEnano)

    override method dialogo() = dialogos.anyOne()
}


const dialogoLuisito = new CartelSecuencia(
    imagenes = ["luisito1.png", "luisito2.png", "luisito3.png"],
    posicion = game.at(12, 13)
)

const dialogosAshley = [
    new CartelSecuencia(imagenes = ["ashley_a1.png"], posicion = game.at(1, 1)),
    new CartelSecuencia(imagenes = ["ashley_b1.png", "ashley_b2.png"], posicion = game.at(1, 1)),
    new CartelSecuencia(imagenes = ["ashley_c1.png", "ashley_c2.png", "ashley_c3.png"], posicion = game.at(1, 1)),
    new CartelSecuencia(imagenes = ["ashley_d1.png", "ashley_d2.png"], posicion = game.at(1, 1)),
    new CartelSecuencia(imagenes = ["ashley_e1.png"], posicion = game.at(1, 1)),
    new CartelSecuencia(imagenes = ["ashley_f1.png", "ashley_f2.png"], posicion = game.at(1, 1)),
    new CartelSecuencia(imagenes = ["ashley_g1.png"], posicion = game.at(1, 1))

]


const luisito = new Luisito(posicion = game.at(12, 9), imagen = "npc_luisito.png", dialogoFijo = dialogoLuisito)
const ashley  = new Ashley(posicion = game.at(10, 12), imagen = "npc_ashley.png", dialogos = dialogosAshley)

object gestorNpcs {
    const npcs = [luisito, ashley]
    const activos = []          

    method actualizar(sala) {
        activos.clear()
        npcs.forEach({ n =>
            if (n.aparece(sala)) {
                n.mostrar()
                activos.add(n)
            } else {
                n.ocultar()
            }
        })
    }

    method ocultarTodos() {
        activos.forEach({ n => n.ocultar() })
        activos.clear()
    }

    method alMoverse(pos) {
        if (!activos.isEmpty()) activos.forEach({ n => n.alMoverseJugador(pos) })
    }

    method ocupa(pos) = !activos.isEmpty() && activos.any({ n => n.position() == pos })
}