# App Android - ProjetoFlutterInfnet V2

Esta pasta contém o aplicativo Android compilado para instalação.

## Arquivos disponíveis:
- **app-release.aab** (25.9MB) - Android Application Bundle (AAB) em modo release com assinatura debug
- **app-release-signed.aab** (25.9MB) - Android Application Bundle (AAB) em modo release com assinatura personalizada

## Como instalar:
1. Para instalar em dispositivos Android, você precisa primeiro converter o AAB em APK usando o bundletool ou fazer upload para o Google Play Store
2. Para testar localmente, você pode usar: `bundletool build-apks --bundle=app-release.aab --output=app.apks`

## Informações do Build:
- Gerado em: $(Get-Date)
- Versão: Release
- Tamanho: 25.9MB
- Formato: AAB (Android Application Bundle)

## Próximos passos:
Este arquivo está pronto para ser enviado ao repositório Git e pode ser usado para distribuição da aplicação. 