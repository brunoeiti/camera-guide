# Camera Guide app

## Business Requirements

- Um aplicativo de camera que permite o usuário tirar fotos e salvar na galeria direto   
- Uma camada com transparencia sera exibida sobre a camera enquanto o usuário tira as fotos
- A foto salva na galeria não terá a camada de transparencia, apenas a foto capturada pela camera
- A foto da galeria deve ter a resolução original da camera, não deve ser redimensionada ou compactada
- Uma vez tirada uma foto uma miniatura da foto será exibida em um scroll na parte inferior da tela junto com as demais fotos tirada
- Ao clicar em uma das miniaturas o usuário pode ver a imagem em tela cheia
- O app deve apresentar as funcionalidades básicas de camera numa interface minimalista
- Um botao com icone indicando foto deve permitir o usuario escolher na galeria uma nova foto que será usada como transparencia sobre a view de camera
- A imagem de transparencia deve ocupar o máximo da área da tela, mantendo-se alinhada com a view de camera mas sem mudar a proporção da imagem escolhida
- Inicialmente o app usará a imagem esboco.jpg para a camada de transparencia

## Technical Details

- O app será implementado em Flutter
- Um script de preparação do ambiente deve ser adicionado tanto para MacOS quanto Windows
- Um script para rodar o app em Android e iOS deve ser criado
- Um manual de como usar os scripts deve ser criado
- Use bibliotecas populares
- Interface minimalista deixando a atenção do usuário na camera
- Usar versões mais atuais de bibliotecas sempre que possivel

## Color Scheme

- Accent Yellow: `#ecad0a` - accent lines, highlights
- Blue Primary: `#209dd7` - links, key sections
- Purple Secondary: `#753991` - submit buttons, important actions
- Dark Navy: `#032147` - main headings
- Gray Text: `#888888` - supporting text, labels

## Strategy

1. Write plan with success criteria for each phase to be checked off. Include project scaffolding, including .gitignore, and rigorous unit testing.
2. Execute the plan ensuring all critiera are met
3. Carry out extensive tests building running the app on iOS and Android
4. Only complete when the MVP is finished and tested, with the app running on iOS and Androi

## Coding standards

1. Use latest versions of libraries and idiomatic approaches as of today
2. Keep it simple - NEVER over-engineer, ALWAYS simplify, NO unnecessary defensive programming. No extra features - focus on simplicity.
3. Be concise. Keep README minimal. IMPORTANT: no emojis ever