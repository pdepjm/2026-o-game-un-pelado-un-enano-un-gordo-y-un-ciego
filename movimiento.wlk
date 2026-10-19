object arriba {
    method nombre() = "arriba"
    method tecla() = keyboard.up()
    method desde(pos, pasos) = pos.up(pasos)
}

object abajo {
    method nombre() = "abajo"
    method tecla() = keyboard.down()
    method desde(pos, pasos) = pos.down(pasos)
}

object izquierda {
    method nombre() = "izquierda"
    method tecla() = keyboard.left()
    method desde(pos, pasos) = pos.left(pasos)
}

object derecha {
    method nombre() = "derecha"
    method tecla() = keyboard.right()
    method desde(pos, pasos) = pos.right(pasos)
}

object movimiento {
    method direcciones() = [arriba, abajo, izquierda, derecha]

    method mover(quien, dir) {
        quien.moverA(dir.desde(quien.position(), quien.velocidad()))
    }

    method empujar(quien, dir, fuerza) {
        fuerza.times({ i => self.mover(quien, dir) })
    }

    // Reemplaza los 4 bloques de activarMovimiento
    method activarTeclas(quien) {
        self.direcciones().forEach({ dir =>
            const tick = game.tick(100, { self.mover(quien, dir) }, false)
            dir.tecla().onPressDo({
                quien.direccion(dir)
                tick.start()
            })
            dir.tecla().onReleaseDo({ tick.stop() })
        })
    }
    // Direcciones hacia el objetivo, la del eje más lejano primero
    method direccionesHacia(desde, hasta) {
        const dx = hasta.x() - desde.x()
        const dy = hasta.y() - desde.y()
        const horizontal = if (dx > 0) [derecha] else if (dx < 0) [izquierda] else []
        const vertical = if (dy > 0) [arriba] else if (dy < 0) [abajo] else []
        return if (dx.abs() >= dy.abs()) horizontal + vertical else vertical + horizontal
    }
    // Reemplaza la cadena de if de perseguir
    method haciaObjetivo(desde, hasta) =
        if (hasta.x() > desde.x()) derecha
        else if (hasta.x() < desde.x()) izquierda
        else if (hasta.y() > desde.y()) arriba
        else if (hasta.y() < desde.y()) abajo
        else null
}

