# Pacote local para Arch/Omarchy

`exiled-exchange-2-omarchy` instala o Electron empacotado e o app em
`/opt/exiled-exchange-2-omarchy`, com comando em `/usr/bin` e entrada própria
no menu. Não substitui o AppImage nem depende de Electron global.

## Construir

Na raiz do checkout, com Node 24 e npm no PATH:

```bash
export PATH="$HOME/.local/share/mise/installs/node/24.20.0/bin:$PATH"
./packaging/arch/build.sh
```

Requer Arch Linux x86_64, base-devel/makepkg, Git, Python 3 e acesso à rede
para as dependências npm/Electron. As bibliotecas de runtime são conferidas
pelo makepkg; o script não instala dependências nem usa sudo.

O script gera um snapshot dos caminhos `main`, `renderer`, `ipc`, `LICENSE`
e `packaging/arch`, incluindo mudanças locais e arquivos não ignorados.
Revise o checkout antes de distribuir um pacote. Dependências, `dist` e `.git`
ficam fora. Uma cópia do PKGBUILD recebe a versão e o SHA-256 do snapshot,
sem alterar o template versionado. Esse é um fluxo local, não uma receita
pronta para publicação no AUR.

Cada execução cria `main/dist/arch-build.XXXXXX/`, contendo:

- `source.tar.gz`, PKGBUILD com checksum e `provenance.txt`;
- fontes extraídos e diretório de staging do pacote;
- `exiled-exchange-2-omarchy-<versão>-<pkgrel>-x86_64.pkg.tar.zst`.

O build roda índices, lint, compilação, testes existentes e empacotamento.
Usa os lockfiles, módulos nativos fornecidos pelas dependências e Electron
embutido. Não compila Electron do zero. Mudanças distribuídas na mesma versão
devem incrementar `pkgrel` no PKGBUILD.

## Instalar e remover

Use o caminho exato do artefato exibido pelo build, sem um glob que selecione
pacotes de várias execuções:

```bash
sudo pacman -U /caminho/exato/exiled-exchange-2-omarchy-0.16.3-2-x86_64.pkg.tar.zst
exiled-exchange-2-omarchy
```

O launcher fixa X11 e usa
`${XDG_CONFIG_HOME:-$HOME/.config}/exiled-exchange-2-omarchy` como perfil.
Não copie cookies ou o perfil inteiro do AppImage. Para comparar atalhos no
jogo, encerre a outra distribuição antes de abrir esta.

O pacote não inclui feed `app-update.yml`, e o launcher passa `--no-updates`.
As atualizações são feitas reconstruindo e instalando o pacote. A tela de
atualizações upstream ainda existe e pode indicar erro/indisponibilidade;
não foi redesenhada nesta etapa. O app ainda usa a rede para preços e demais
serviços normais.

Para reverter a instalação:

```bash
sudo pacman -R exiled-exchange-2-omarchy
```

Isso preserva o perfil do fork. Não há autostart nem alterações nas regras do
Hyprland. Nesta máquina, o AppImage antigo, seu launcher e seu ícone foram
movidos à lixeira a pedido do usuário, após a instalação do pacote Arch.
O perfil anterior em `~/.config/exiled-exchange-2` foi preservado. Para voltar
àquela distribuição, restaure os três arquivos da lixeira ou obtenha novamente
o AppImage oficial.

## Validação desta etapa

Pacote `0.16.3-2` instalado pelo pacman. O catálogo GIO identificou uma única
entrada visível: `Exiled Exchange 2 (Omarchy)`. O launcher instalado foi
testado com XDG_CONFIG_HOME temporário: perfil isolado, X11, resposta HTTP e
preservação da configuração anterior passaram. A instância foi encerrada.

Em 2026-09-07, o build com Node 24.20.0 e Electron 40.10.2 passou; Vitest:
527 testes aprovados e 2 ignorados. O desktop file passou no
`desktop-file-validate`, e o pacman reconheceu metadados e dependências.

O aplicativo extraído do staging iniciou em X11 com um diretório de perfil
temporário, respondeu `/config` com versão 0.16.3 e configuração vazia, e
serviu `/index.html`. A instância de teste foi encerrada. Isso comprova
inicialização e serviço da interface, mas não comprova foco, atalhos,
clipboard, renderização visual correta ou funcionamento do overlay no PoE2.

O log dessa inicialização contém `XkbGetKeyboard failed to locate a valid
keyboard` e um aviso de prioridade de thread do uiohook, embora também registre
`uIOhook started`. Portanto a captura correta de teclado continua pendente;
esses sinais não foram tratados como prova de funcionamento dos atalhos.
