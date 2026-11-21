import wollok.game.*

class ZonaTexto {
    const casillas
    const imagen
    const posicionTexto = game.origin()
    var visible = false

    method position() = posicionTexto
    method image() = imagen
    method estaVivo() = false          

    method actualizar(pos) {
        if (casillas.contains(pos)) self.mostrar() else self.ocultar()
    }
    method mostrar() {
        if (!visible) { game.addVisual(self) visible = true }
    }
    method ocultar() {
        if (visible) { game.removeVisual(self) visible = false }
    }
}

class Npc {
    const posicion
    const imagen

    method position() = posicion
    method image() = imagen
    method estaVivo() = false

    // las casillas que rodean al mensaje en cuestion
    method casillasAlrededor() =
        [posicion.up(1), posicion.down(1), posicion.left(1), posicion.right(1)]
}