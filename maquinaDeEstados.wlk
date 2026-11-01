import mapas.*
import llaves.*

object juego {
    var estado = inicio
    const llaves = [llaveNula]

    method cambiarEstado(nuevo) {
        estado = nuevo
        estado.agregarLlave()
    }
    method estado() = estado
    method existeLlave(llave) = llaves.any({p => p.nombre() == llave.nombre()})
    method agregarLlave(llave) {
        if (!llaves.any({l => l.nombre() == llave.nombre()})) {
            llaves.add(llave)
        }
    }
}

class Estado {
    const sala
    const llaveOtorgada

    method sala() = sala
    method agregarLlave() {juego.agregarLlave(llaveOtorgada)}
}


const inicial = new Estado (
    sala = inicio,
    llaveOtorgada = llaveNula
)

const puebloCompletado = new Estado (
    sala = pueblo,
    llaveOtorgada = llaveIglesia
)

const peladoDerrotado = new Estado (
    sala = entradaCastillo,
    llaveOtorgada = llavePelado
)

const enanoDerrotado = new Estado (
    sala = entradaCastillo,  //cambiar cuando se tenga la sala
    llaveOtorgada = llaveEnano
)

const krauserDerrotado = new Estado (
    sala = salaKrauser,
    llaveOtorgada = llaveKrauser
)

const llaveEnano1Recogida = new Estado(
    sala = salaLlave1,
    llaveOtorgada = llavePreEnano1
)

const llaveEnano2Recogida = new Estado(
    sala = salaLlave2,
    llaveOtorgada = llavePreEnano2
)
const llaveGordoRecogida = new Estado(
    sala = bibiloteca,
    llaveOtorgada = llavePreEnano2
)

const gordoDerrotado = new Estado (
    sala = salaVacia,  //cambiar cuando se tenga la sala
    llaveOtorgada = llaveNula
)

const ciegoDerrotado = new Estado (
    sala = salaVacia,  //cambiar cuando se tenga la sala
    llaveOtorgada = llaveNula
)

