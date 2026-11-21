import enemigo.*
import wollok.game.*
import maquinaDeEstados.*
import dialogos.*

object emboscadaPueblo {
    const ultimaOleada = 5
    var oleada = 0
    var token = 0

    method aparecer() {
        token += 1
        self.siguienteOleada(token)
    }
    method desaparecer() {
        juego.cambiarEstado(puebloCompletado)
    }
    method reiniciar() {
        token += 1         
        oleada = 0
    }

    method siguienteOleada(t) {
        if (t == token) {
            if (gestorDialogos.activo()) {
                game.schedule(3000, { self.siguienteOleada(t) })
            } else if (!spawner.hayZombiesVivos()) {
                oleada += 1
                if (oleada >= ultimaOleada) self.desaparecer()
                else {
                    spawner.crearZombiesAleatorios()
                    game.schedule(3000, { self.siguienteOleada(t) })
                }
            } else {
                game.schedule(3000, { self.siguienteOleada(t) })
            }
        }
    }
}