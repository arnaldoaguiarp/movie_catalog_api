# Movie Catalog API 🎬

Esta API permite gerenciar um catálogo de filmes, com endpoints para listar, criar e importar filmes a partir de um arquivo CSV.

## Índice
- [Propósito 📋](#propósito-📋)
- [Tecnologias Utilizadas 🚀](#tecnologias-utilizadas-🚀)
- [Pré-requisitos ⚠️](#pré-requisitos-⚠️)
- [Instalação e Configuração 📦](#instalação-e-configuração-📦)
- [Endpoints da API 🔍](#endpoints-da-api-🔍)
  - [Listar Filmes 📜](#listar-filmes-📜)
  - [Criar Filme 🎥](#criar-filme-🎥)
  - [Importar Filmes via CSV 🔠](#importar-filmes-via-csv-🔠)
- [Documentação da API 📄](#documentação-da-api-📄)
- [Testes 🧪](#testes-🧪)
- [Possíveis Melhorias 🔄](#possíveis-melhorias-🔄)
- [Contato ✉️](#contato-✉️)
- [Desafio lógica de programação 🎯](#desafio-lógica-de-programação🎯)

## Propósito 📋

A **Movie Catalog API** foi criada para fornecer uma forma fácil de gerenciar informações de filmes, oferecendo funcionalidades de:
- Listagem com filtros dinâmicos e busca parcial.
- Cadastro de novos filmes com validação de duplicidade e integridade dos dados.
- Importação em massa via arquivo CSV.

Esta API foi desenvolvida como parte de um desafio técnico utilizando Ruby on Rails com foco em boas práticas e documentação completa.

## Tecnologias Utilizadas 🚀

- **Ruby on Rails 7.x (API Mode)**
- **PostgreSQL** (Banco de dados relacional)
- **RSpec** para testes
- **Rswag** para documentação Swagger/OpenAPI
- **Rubocop** para linting de código

## Pré-requisitos ⚠️

- **Ruby 3.0.0** ou superior
- **Rails 7.x**
- **PostgreSQL 13** ou superior

## Instalação e Configuração 📦

Clone o repositório:

```bash
git clone https://github.com/seu_usuario/movie_catalog_api.git
cd movie_catalog_api
```

Instale as dependências:

```bash
bundle install
```

Configure o banco de dados: Crie e configure as variáveis de ambiente do banco de dados no arquivo `.env` ou diretamente em `config/database.yml`, e então rode:

```bash
rails db:create db:migrate
```

Execute o servidor Rails:

```bash
rails s
```

A API estará disponível em [http://localhost:3000](http://localhost:3000).

## Endpoints da API 🔍

### Listar Filmes 📜

- **Rota**: `GET /api/v1/movies`
- **Descrição**: Lista todos os filmes cadastrados com suporte a filtros dinâmicos.
- **Parâmetros de Filtro**:
  - `title`: Título do filme (busca parcial, ex: "Incep" para "Inception")
  - `year`: Ano de lançamento (ex: 2020)
  - `genre`: Gênero do filme (busca parcial, ex: "Dram" para "Drama")
  - `country`: País de origem (busca parcial, ex: "United" para "United States")
- **Exemplo de uso via cURL**:

  ```bash
  curl -X GET "http://localhost:3000/api/v1/movies?year=2020&genre=Dram&country=United"
  ```

### Criar Filme 🎥

- **Rota**: `POST /api/v1/movies`
- **Descrição**: Cadastra um novo filme no catálogo.
- **Corpo da Requisição (JSON)**:

  ```json
  {
    "title": "Example Movie",
    "genre": "Drama",
    "year": 2021,
    "country": "Brazil",
    "published_at": "2021-10-01",
    "description": "An example movie description."
  }
  ```

- **Exemplo de uso via cURL**:

  ```bash
  curl -X POST "http://localhost:3000/api/v1/movies" \
       -H "Content-Type: application/json" \
       -d '{"title":"Example Movie","genre":"Drama","year":2021,"country":"Brazil","published_at":"2021-10-01","description":"An example movie description."}'
  ```

### Importar Filmes via CSV 🔠

- **Rota**: `POST /api/v1/movies/import`
- **Descrição**: Permite a importação em massa de filmes a partir de um arquivo CSV.
- **Exemplo de uso via cURL**:

  ```bash
  curl -X POST "http://localhost:3000/api/v1/movies/import" \
       -H "Content-Type: multipart/form-data" \
       -F "file=@/caminho/para/seu_arquivo.csv"
  ```

Tabela de Campos
| Campo	       | Tipo	   | Rota `POST /api/v1/movies`     |	Rota `POST /api/v1/movies/import` (CSV) |
| ---          | ---     | ---                            | --- |
| title	       | String	 | Obrigatório	                  | Obrigatório (`title` no CSV) |
| year	       | Inteiro | Obrigatório                    |	Obrigatório (`release_year` no CSV) |
| genre	       | String  |	Opcional                      |	Opcional (`listed_in` no CSV) |
| country	     | String  |	Opcional                      |	Opcional (`country` no CSV) |
| published_at |	Data   |	Opcional (com formato válido) |	Opcional (`date_added` no CSV, formato válido) |
| description  |	String |	Opcional                      |	Opcional (`description` no CSV) |

## Documentação da API 📄

A documentação completa da API está disponível via Swagger. Após subir o servidor, acesse:

- **URL**: [http://localhost:3000/api-docs/index.html](http://localhost:3000/api-docs/index.html)

Nesta interface, você pode testar os endpoints diretamente.

## Testes 🧪

Os testes foram implementados utilizando RSpec e incluem testes de unidade, de integração e de documentação com o Swagger.

Para rodar os testes de unidade e integração:

```bash
rspec
```

## Possíveis Melhorias 🔄

Para demonstração de pensamento crítico sobre melhorias futuras, aqui estão algumas sugestões de aprimoramentos:

- **Cache de Consultas**: Implementar caching para melhorar a performance ao listar filmes com filtros dinâmicos.
- **Paginação**: Adicionar paginação à listagem de filmes para otimizar a resposta em catálogos extensos.
- **Autenticação e Autorização**: Integrar autenticação para garantir que apenas usuários autorizados possam criar ou importar filmes.
- **Validação Avançada de CSV**: Ampliar a validação do CSV, incluindo checagens de integridade dos dados para garantir a consistência do catálogo.
- **Testes de Performance**: Implementar testes de carga para verificar a escalabilidade da API.

## Contato ✉️

Para dúvidas ou sugestões, entre em contato com [arnaldoaguiarp@gmail.com](mailto:arnaldoaguiarp@gmail.com).

## Desafio lógica de programação 🎯

```
def contar_diamantes(expressao)
    diamantes = 0
  
    while expressao.include?('.')
        expressao.sub!('.', '')
    end

    while expressao.include?('<>')
        expressao.sub!('<>', '')
        diamantes += 1
    end

    diamantes
end

expressao = "<<.<<..>><>><.>.>.<<.>.<.>>>><>><>>"
diamantes_extraidos = contar_diamantes(expressao)

puts "Quantidade de diamantes extraídos: #{diamantes_extraidos}"
```

