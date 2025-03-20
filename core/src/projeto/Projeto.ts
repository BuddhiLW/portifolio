import Tecnologia from "../tecnologia/Tecnologia"
import { Nivel } from "./Nivel"
import { Tipo } from "./Tipo"

export default interface Projeto {
	id: number
	nome: string
	descricao: string
	imagens: string
	repositorio: string
	tecnologias: Tecnologia[]
	nivel: Nivel
	tipo: Tipo
}
