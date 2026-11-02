import maquinaDeEstados.*
import mapas.*
class Llave {
    const nombre
    method nombre() = nombre
}

class LlaveReCogible {
    const estadoAsociado
    const posicion
    const imagen
    const nombre
    method nombre() = nombre 
    method image() = imagen
    method position() = posicion  

   var recogido = false
    method recogido() = recogido
    method alPisar() {
        recogido = true
        self.recoger()
    }
     method recoger() {
        juego.cambiarEstado(estadoAsociado)
    }
}

const llaveNula = new Llave(nombre = "ninguna")

const llaveInicio = new Llave(nombre = "llave inicio")
const llaveIglesia = new Llave(nombre = "llave iglesia")
const llavePelado = new Llave(nombre = "llave pelada")
const llaveEnano = new Llave(nombre = "llave enana")
const llaveGordo = new Llave(nombre = "llave gordo")
const llaveKrauser = new Llave(nombre = "llave Krauser")
const llavePreEnano1 = new LlaveReCogible(nombre = "llave preenano1",posicion = game.at(4,8), imagen = "llave_1.png", estadoAsociado = llaveEnano1Recogida) 
const llavePreEnano2 = new LlaveReCogible(nombre = "llave preenano2", posicion = game.at(20, 12), imagen = "llave_1.png", estadoAsociado = llaveEnano2Recogida) 
const llavePreGordo = new LlaveReCogible(nombre = "llave pregordo", posicion = game.at(4,3), imagen = "llave_2.png", estadoAsociado = llaveGordoRecogida)