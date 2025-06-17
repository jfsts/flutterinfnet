# Configuração de Variáveis de Ambiente

## Sobre as Mudanças de Segurança

Este projeto foi modificado para usar variáveis de ambiente para armazenar informações sensíveis do Firebase, seguindo melhores práticas de segurança.

## ⚠️ IMPORTANTE - Segurança

As chaves do Firebase foram movidas para um arquivo `.env` que **NÃO deve ser versionado** no Git. Isso previne que credenciais sensíveis sejam expostas publicamente.

## Configuração Inicial

### 1. Copiar o arquivo template
```bash
cp .env.example .env
```

### 2. Preencher as variáveis no arquivo `.env`

Abra o arquivo `.env` e substitua os valores de exemplo pelas suas chaves reais do Firebase:

```env
# Firebase Configuration - Chaves Sensíveis
# IMPORTANTE: Este arquivo contém informações confidenciais e NÃO deve ser versionado

# Web Firebase Configuration
FIREBASE_WEB_API_KEY=sua_web_api_key_aqui
FIREBASE_WEB_APP_ID=seu_web_app_id_aqui
FIREBASE_WEB_MEASUREMENT_ID=seu_measurement_id_aqui

# Android Firebase Configuration  
FIREBASE_ANDROID_API_KEY=sua_android_api_key_aqui
FIREBASE_ANDROID_APP_ID=seu_android_app_id_aqui

# iOS Firebase Configuration
FIREBASE_IOS_API_KEY=sua_ios_api_key_aqui
FIREBASE_IOS_APP_ID=seu_ios_app_id_aqui

# Windows Firebase Configuration
FIREBASE_WINDOWS_API_KEY=sua_windows_api_key_aqui
FIREBASE_WINDOWS_APP_ID=seu_windows_app_id_aqui
FIREBASE_WINDOWS_MEASUREMENT_ID=seu_windows_measurement_id_aqui

# Configurações Comuns
FIREBASE_MESSAGING_SENDER_ID=seu_messaging_sender_id
FIREBASE_PROJECT_ID=seu_project_id
FIREBASE_STORAGE_BUCKET=seu_storage_bucket
FIREBASE_AUTH_DOMAIN=seu_auth_domain
FIREBASE_IOS_BUNDLE_ID=seu_ios_bundle_id
```

### 3. Onde encontrar as chaves

As chaves podem ser encontradas:
- **Firebase Console**: https://console.firebase.google.com/
- **Arquivo `google-services.json`** (Android)
- **Arquivo `GoogleService-Info.plist`** (iOS)
- **Firebase Project Settings** (Web)

## Arquivos Modificados

### `lib/firebase_options.dart`
- Removidas as chaves hardcoded
- Adicionado uso do `flutter_dotenv` para carregar variáveis de ambiente
- Convertidos valores `const` para `get` methods

### `lib/main.dart`
- Adicionado carregamento do arquivo `.env` antes da inicialização do Firebase

### `pubspec.yaml`
- Adicionada dependência `flutter_dotenv: ^5.1.0`
- Adicionado `.env` como asset

### `.gitignore`
- Adicionado `.env` para prevenir versionamento de chaves sensíveis

## Verificação

Para verificar se tudo está funcionando:

1. Execute `flutter pub get`
2. Execute `flutter run`
3. Verifique se não há erros relacionados ao Firebase

## Troubleshooting

### Erro: "dotenv.env['FIREBASE_WEB_API_KEY'] returned null"
- Verifique se o arquivo `.env` existe na raiz do projeto
- Verifique se todas as variáveis estão preenchidas
- Verifique se o arquivo `.env` está listado em `assets` no `pubspec.yaml`

### Erro: "Unable to load asset"
- Execute `flutter clean` e `flutter pub get`
- Verifique se o arquivo `.env` está na raiz do projeto (mesmo nível do `pubspec.yaml`)

## Implantação

Para implantação em diferentes ambientes (dev, staging, prod), crie arquivos `.env` específicos:
- `.env.dev`
- `.env.staging` 
- `.env.prod`

E carregue o arquivo apropriado baseado no ambiente. 