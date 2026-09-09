# Build local Linux — base para Omarchy

Validado em 2026-09-07, sem patches no aplicativo.

- Base: `v0.16.3`, commit `cca30662bf31eaf38bd711e2ec1a6b899a06c40e`.
- Host: Omarchy, Linux x64.
- Toolchain usada: Node `24.20.0`, seguindo a versão principal do CI.
- Electron empacotado: `40.10.2`; electron-builder: `26.8.1`.

## Reproduzir

Na raiz do checkout, use Node 24 no `PATH`. Neste host ele já existe em
`$HOME/.local/share/mise/installs/node/24.20.0/bin`.
Não é necessário alterar a versão global do Node.

```bash
export PATH="$HOME/.local/share/mise/installs/node/24.20.0/bin:$PATH"
set -e
(
  cd renderer
  npm ci --no-audit --no-fund
  npm run make-index-files
  npm run lint
  npm run build
  npm run test -- --run
)
(
  cd main
  npm ci --no-audit --no-fund
  npm run build
  npm run package -- --linux --dir --publish never
)
```

O alvo `--dir` foi confirmado pelo `--help` do builder instalado e executado
com sucesso. O pacote fica em `main/dist/linux-unpacked/`, com executável
`exiled-exchange-2`. Preserve o diretório completo: o binário depende dos
arquivos que o acompanham. Nenhum artefato foi publicado.

## Resultado observado

- Instalação com os dois lockfiles: passou, sem alterações nos lockfiles.
- Geração de índices, lint do renderer e build das duas partes: passaram.
- Vitest: 23 arquivos passaram; 527 testes passaram e 2 foram ignorados.
- Empacotamento Linux em diretório: passou, aproximadamente 346 MiB.
- O próprio Electron empacotado, em modo `ELECTRON_RUN_AS_NODE=1`, carregou
  os bindings Linux x64 de `electron-overlay-window` e `uiohook-napi`.
- O pacote contém `main.js`, `vision.js`, `index.html` e `icon.png`.
- SHA-256 de `main/dist/linux-unpacked/resources/app.asar` nesta execução:
  `05d967f34dc30932c995ae1ed77ac04b4c6e5cf98bd63ace87f90c92cf237618`.

Avisos não bloqueantes: dependências descontinuadas; scripts de instalação
sem declaração `allowScripts` para vue-demi/unrs-resolver; bundle acima de
500 kB; mock aninhado no setup do Vitest; avisos do builder sobre metadados,
referências duplicadas e API de subprocessos. Nenhuma atualização de
dependência foi feita para ocultar esses avisos.

## Limites e próxima etapa

Este é um build da base original, com módulos nativos pré-compilados fornecidos
pelas dependências (`npmRebuild: false` no projeto). Não é uma recompilação de
Electron ou de todo o código C/C++.

O aplicativo gráfico não foi iniciado por este procedimento. Carregar bindings
sem iniciar hooks não comprova atalhos, foco, clipboard ou overlay no jogo.
O AppImage, launcher e perfil existentes foram preservados.

A próxima etapa é preparar e conferir o isolamento do perfil, testar a sessão
gráfica via X11 e reproduzir os problemas no PoE2. Evitar duas instâncias
capturando os mesmos atalhos durante a comparação. A instalação definitiva e
o tratamento do updater do fork vêm após esse aceite. `--no-updates` impede
download automático, mas não elimina consultas ao canal oficial.

Os diretórios de dependências e os artefatos `dist` já são ignorados pelo Git.
Este documento é a única alteração versionável desta etapa; não houve commit
ou push.
