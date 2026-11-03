import wollok.game.*
import armas.*
import maquinaDeEstados.*
import llaves.*
import mapas.*

class Destructible {
    const posicion
    const imagen
    const armaRequerida
    const llaveOtorgada
    const alRomperse
    var roto = false
     method position() = posicion
    method image() = imagen
    method roto() = roto
    method estaVivo() = !roto
    method recibirDanio(cantidad) {
        if (!roto && inventario.armaSeleccionada() == armaRequerida) {
            roto = true
            game.removeVisual(self)
            juego.agregarLlave(llaveOtorgada)
            alRomperse.apply()
        }
    }
}

const cuerdaIglesia = new Destructible(
    posicion = game.at(16, 13),
    imagen = "cuerda.png",
    armaRequerida = cuchillo,
    llaveOtorgada = llaveCuerda,
    alRomperse = { iglesia.cambiarFondo("fondo_iglesia_rota.png") }
)
class Palanca {
    const posicion
    const color
    const bajadaCorrecta
    var bajada = false

    method position() = posicion
    method image() = "palanca_" + color + "_" + (if (bajada) "abajo" else "arriba") + ".png"
    method estaVivo() = true                
    method correcta() = bajada == bajadaCorrecta

    method recibirDanio(cantidad) {
        if (inventario.armaSeleccionada() == cuchillo) bajada = !bajada
    }
}

const palancaRoja     = new Palanca(posicion = game.at(12, 7), color = "roja",     bajadaCorrecta = true)
const palancaAzul     = new Palanca(posicion = game.at(10, 8), color = "azul",     bajadaCorrecta = false)
const palancaVerde    = new Palanca(posicion = game.at(12, 8), color = "verde",    bajadaCorrecta = true)
const palancaAmarilla = new Palanca(posicion = game.at(12, 10), color = "amarilla", bajadaCorrecta = false)

object combinacion {
    method correcta() =
        [palancaRoja, palancaAzul, palancaVerde, palancaAmarilla].all({ p => p.correcta() })
}
