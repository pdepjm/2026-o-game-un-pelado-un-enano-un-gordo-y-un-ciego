import wollok.game.*
import mapas.*
import llaves.*
import dialogos.*
import maquinaDeEstados.juego
import enemigo.*

class Npc {
    var posicion
    const imagen = null
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

class Cartel inherits Npc {
    const salaDondeAparece
    const dialogoCartel

    override method aparece(sala) = sala == salaDondeAparece
    override method dialogo() = dialogoCartel

    override method mostrar() { visible = true }
    override method ocultar() {
        visible = false
        cerca = false
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

    override method mostrar() {
        if (!visible) {
            posicion = spawner.posicionAleatoria()
        }
        super()
     }
     
    method posicionLibre() {
        const pos = spawner.posicionAleatoria()
        const vecinosLibres = [pos.up(1), pos.down(1), pos.left(1), pos.right(1)]
            .count({ p => mapa.esPiso(p) })
        return if (vecinosLibres >= 3) pos else self.posicionLibre()
    }
}

class Bote inherits Npc {
    const dialogoFijo
    const llave         

    override method aparece(sala) = sala == muelle && !juego.existeLlave(llave)

    override method dialogo() = dialogoFijo
}

class Gordo inherits Npc {
    const dialogoFijo         

    override method aparece(sala) = sala == salaPasillo2 && !juego.existeLlave(llavePreGordo)

    override method dialogo() = dialogoFijo
}

class Bitacora inherits Npc {
    const dialogoFijo 
    const salaDondeAparece        

    override method aparece(sala) = sala == salaDondeAparece

    override method dialogo() = dialogoFijo
}

const dialogoLuisito = new CartelSecuencia(
    imagenes = ["luisito1.png", "luisito2.png", "luisito3.png"],
    posicion = game.at(10, 12)
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


const palancas = new Cartel(posicion = game.at(8,13),salaDondeAparece = entradaIsla ,dialogoCartel = pistaPalancas)
const luisito = new Luisito(posicion = game.at(12, 9), imagen = "npc_luisito.png", dialogoFijo = dialogoLuisito)
const ashley  = new Ashley(posicion = game.at(10, 12), imagen = "npc_ashley.png", dialogos = dialogosAshley)
const moto = new Bote(posicion = game.at(17, 9), dialogoFijo =  cartelBote, llave = llaveGordo)
const pregordo = new Gordo(posicion = game.at(22,3), dialogoFijo = dialogoPuertaGordo)
const bitacoraVerde = new Bitacora(salaDondeAparece = salaVerde, posicion = game.at(15,11), dialogoFijo = lore1)
const bitacoraRoja = new Bitacora(salaDondeAparece = salaRoja, posicion = game.at(15,11), dialogoFijo = lore2)
const bitacoraAzul = new Bitacora(salaDondeAparece = salaAzul, posicion = game.at(15,11), dialogoFijo = lore3)
const bitacoraAmarilla = new Bitacora(salaDondeAparece = pasilloSurEste, posicion = game.at(15,11), dialogoFijo = lore4)
const tablas = new Bote(posicion = game.at(18, 3), dialogoFijo =  cartelTablas, llave = llaveTablas)
object gestorNpcs {
    const npcs = [luisito, ashley, palancas, moto, pregordo, bitacoraVerde, 
    bitacoraRoja, bitacoraAzul, bitacoraAmarilla]
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