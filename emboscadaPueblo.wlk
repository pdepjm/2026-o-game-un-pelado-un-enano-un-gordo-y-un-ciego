import enemigo.*
import wollok.game.*
import maquinaDeEstados.*

object emboscadaPueblo {
    const ultimaOleada = 5
    var oleada = 0

    method aparecer() {
        self.siguienteOleada()
    }
    method desaparecer() {
        juego.cambiarEstado(puebloCompletado)
    }

    method siguienteOleada() {
        if (!spawner.hayZombiesVivos()){
            oleada += 1
            if (oleada >= ultimaOleada) self.desaparecer()
            else {
                spawner.crearZombiesAleatorios()
                game.schedule(3000, {self.siguienteOleada()})
            }
        }
        else game.schedule(3000, {self.siguienteOleada()})
    }
}