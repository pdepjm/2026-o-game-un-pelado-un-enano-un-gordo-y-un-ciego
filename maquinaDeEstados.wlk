import mapas.*
object juego {
    var estado = inicio

    method cambiarEstado(nuevo) {
        estado = nuevo
    }

    method estado() = estado
}

class Estado {
    const sala
    const escopetaConseguida
    const lanzapapaConseguida
}


const inicial = new Estado (
    sala = inicio,
    escopetaConseguida = false,
    lanzapapaConseguida = false
)

const puebloCompletado = new Estado (
    sala = pueblo,
    escopetaConseguida = false,
    lanzapapaConseguida = false
)

const peladoDerrotado = new Estado (
    sala = entradaCastillo,
    escopetaConseguida = false,
    lanzapapaConseguida = false
)

const enanoDerrotado = new Estado (
    sala = salaVacia,  //cambiar cuando se tenga la sala
    escopetaConseguida = true,
    lanzapapaConseguida = false
)

const gordoDerrotado = new Estado (
    sala = salaVacia,  //cambiar cuando se tenga la sala
    escopetaConseguida = true,
    lanzapapaConseguida = true
)

const ciegoDerrotado = new Estado (
    sala = salaVacia,  //cambiar cuando se tenga la sala
    escopetaConseguida = true,
    lanzapapaConseguida = true
)

