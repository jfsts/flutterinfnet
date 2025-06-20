# 🔐 Configuração de Keystore Personalizada

Este projeto foi configurado para usar uma **keystore personalizada** para assinar o aplicativo Android em produção (Cenário 2).

## 📋 Arquivos Relacionados

### Configuração:
- `android/key.properties` - Arquivo com configurações da keystore (não versionado no Git por segurança)
- `android/final-keystore.jks` - Arquivo da keystore personalizada (não versionado no Git)
- `android/app/build.gradle.kts` - Configurado para usar a keystore personalizada

### Aplicativo Gerado:
- `app-release-signed.aab` - AAB assinado com keystore personalizada (✅ Pronto para produção)

## 🔧 Como foi Configurado

### 1. Criação da Keystore
```bash
keytool -genkey -v -keystore android/final-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Arquivo key.properties
```properties
storePassword=<SENHA_SECRETA>
keyPassword=<SENHA_SECRETA>
keyAlias=upload
storeFile=final-keystore.jks
```

### 3. Configuração do build.gradle.kts
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = keystoreProperties["storeFile"]?.let { file("../$it") }
        storePassword = keystoreProperties["storePassword"] as String?
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

## 🚨 Segurança

- **key.properties**: Contém senhas e não deve ser versionado no Git
- **final-keystore.jks**: Arquivo da keystore, backup seguro é essencial
- **Senha**: Mantenha sempre segura, sem ela não é possível assinar novos builds

## 🚀 Como Gerar Novo Build

```bash
flutter build appbundle --release
```

O AAB será gerado em: `build/app/outputs/bundle/release/app-release.aab`

## ✅ Vantagens da Keystore Personalizada

1. **Controle Total**: Você possui e controla suas chaves de assinatura
2. **Produção**: AAB pronto para upload na Google Play Store
3. **Consistência**: Sempre o mesmo certificado para atualizações
4. **Segurança**: Implementação seguindo melhores práticas do Android 