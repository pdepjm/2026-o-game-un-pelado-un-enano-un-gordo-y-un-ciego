import maquinaDeEstados.*
class Llave {
    const nombre
    method nombre() = nombre
}

class LlaveReCogible {
    const estadoAsociado
    const posicion
    const imagen

    method position() = posicion
    method image() = imagen

    method recoger() {
        juego.cambiarEstado(estadoAsociado)
    }
}

const llaveNula = new Llave(nombre = "ninguna")

const llaveInicio = new Llave(nombre = "llave inicio")
const llaveIglesia = new Llave(nombre = "llave iglesia")
const llavePelado = new Llave(nombre = "llave pelada")
const llaveEnano = new Llave(nombre = "llave enana")
const llaveKrauser = new Llave(nombre = "llave Krauser")
const llavePreEnano1 = new LlaveReCogible(posicion = game.at(21,4), imagen = "llave_1.png", estadoAsociado = llaveEnano1Recogida) 
const llavePreEnano2 = new LlaveReCogible(posicion = game.at(4,8), imagen = "llave_1.png", estadoAsociado = llaveEnano2Recogida) 
const llavePreGordo = new LlaveReCogible(posicion = game.at(4,2), imagen = "llave_2.png", estadoAsociado = llaveGordoRecogida)