# 🚀 Guia de Instalação e Execução - Projeto Flutter INFNET

## 📋 **Pré-requisitos**

### **🛠️ Ferramentas Necessárias**
- **Flutter SDK** >= 3.2.3
- **Dart SDK** >= 3.2.3
- **Android Studio** ou **VS Code**
- **Git** para controle de versão
- **Conta Firebase** (gratuita)

### **📱 Para Desenvolvimento**
- **Android Studio** com SDK Android
- **Emulador Android** ou dispositivo físico
- **Xcode** (apenas para iOS - macOS)

---

## 📥 **Instalação**

### **1️⃣ Clone o Repositório**
```bash
git clone https://github.com/jefferson-santos/projeto-flutter-infnet.git
cd projeto-flutter-infnet
```

### **2️⃣ Instale as Dependências**
```bash
# Dependências do projeto principal
flutter pub get

# Dependências do package interno
cd packages/infnet_validators
flutter pub get
cd ../..
```

### **3️⃣ Verificar Instalação Flutter**
```bash
flutter doctor
```
**Resultado esperado:**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.2.3, on Microsoft Windows)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Visual Studio - develop for Windows
[✓] Android Studio
[✓] VS Code
[✓] Connected device (2 available)
[✓] HTTP Host Availability

• No issues found!
```

---

## 🔥 **Configuração Firebase**

### **4️⃣ Criar Projeto Firebase**

1. **Acesse o [Firebase Console](https://console.firebase.google.com)**
2. **Clique em "Criar um projeto"**
3. **Nome do projeto:** `lista-tarefas-infnet`
4. **Habilite Google Analytics** (opcional)

### **5️⃣ Configurar Authentication**

1. **No Firebase Console, vá em Authentication**
2. **Clique em "Começar"**
3. **Na aba "Sign-in method":**
   - Habilite **"Email/senha"**
   - Clique em **"Salvar"**

### **6️⃣ Configurar Firestore Database**

1. **No Firebase Console, vá em Firestore Database**
2. **Clique em "Criar banco de dados"**
3. **Escolha "Iniciar no modo de teste"**
4. **Selecione uma localização** (ex: southamerica-east1)

### **7️⃣ Configurar Android**

1. **No Firebase Console, clique no ícone Android**
2. **Preencha os dados:**
   - **Nome do pacote:** `com.infnet.projetoflutterinfnet_v2`
   - **Apelido do app:** `Lista de Tarefas`
3. **Baixe o arquivo `google-services.json`**
4. **Coloque o arquivo em:** `android/app/google-services.json`

### **8️⃣ Configurar iOS (Opcional)**

1. **No Firebase Console, clique no ícone iOS**
2. **Preencha os dados:**
   - **ID do pacote:** `com.infnet.projetoflutterinfnetV2`
3. **Baixe o arquivo `GoogleService-Info.plist`**
4. **Coloque o arquivo em:** `ios/Runner/GoogleService-Info.plist`

---

## ▶️ **Executar o Projeto**

### **9️⃣ Executar em Modo Debug**
```bash
# Listar dispositivos disponíveis
flutter devices

# Executar no dispositivo/emulador
flutter run

# Executar com hot reload ativo
flutter run --hot
```

### **🔟 Executar Testes**
```bash
# Todos os testes
flutter test

# Testes com relatório detalhado
flutter test --reporter=expanded

# Testes do package interno
cd packages/infnet_validators
flutter test
cd ../..

# Gerar coverage report
flutter test --coverage
```

### **1️⃣1️⃣ Build para Produção**
```bash
# Build APK Android
flutter build apk

# Build App Bundle Android (recomendado para Play Store)
flutter build appbundle

# Build iOS (apenas no macOS)
flutter build ios
```

---

## 🧪 **Verificar Funcionalidades**

### **✅ Checklist de Testes**

#### **🔐 Autenticação**
- [ ] Criar conta com email/senha
- [ ] Fazer login
- [ ] Recuperar senha
- [ ] Logout

#### **📋 Tarefas**
- [ ] Criar nova tarefa
- [ ] Marcar como concluída
- [ ] Editar tarefa
- [ ] Excluir tarefa
- [ ] Agendar data/hora

#### **👤 Perfil**
- [ ] Editar nome
- [ ] Alterar avatar (câmera/galeria)
- [ ] Buscar endereço por CEP
- [ ] Capturar localização GPS

#### **🧪 Testes Automatizados**
```bash
# Verificar se todos os testes passam
flutter test
# Resultado esperado: 30 tests passed!
```

---

## 🐛 **Solução de Problemas**

### **❌ Erro: "No Firebase App '[DEFAULT]' has been created"**
**Solução:**
1. Verifique se `google-services.json` está em `android/app/`
2. Execute `flutter clean && flutter pub get`
3. Reinicie o emulador/dispositivo

### **❌ Erro: "MissingPluginException"**
**Solução:**
```bash
flutter clean
flutter pub get
flutter run
```

### **❌ Erro: "Gradle build failed"**
**Solução:**
1. Verifique se Android SDK está atualizado
2. Execute `flutter doctor` e resolva problemas
3. Limpe o cache: `flutter clean`

### **❌ Erro: "Permission denied" (GPS/Câmera)**
**Solução:**
1. Verifique permissões no `AndroidManifest.xml`
2. Aceite permissões no dispositivo/emulador
3. Reinicie o app após conceder permissões

### **❌ Erro: "ViaCEP API não responde"**
**Solução:**
1. Verifique conexão com internet
2. Teste com CEP válido (ex: 01310-100)
3. Aguarde alguns segundos entre requisições

---

## 📱 **Dispositivos Testados**

### **✅ Android**
- **Emulador:** Pixel 6 API 34
- **Versões:** Android 10+ (API 29+)
- **Resolução:** 1080x2400, 720x1600

### **✅ iOS (Configurado)**
- **Simulador:** iPhone 14
- **Versões:** iOS 12+
- **Resolução:** 390x844, 375x667

---

## 🔧 **Configurações Avançadas**

### **🎯 Variáveis de Ambiente**
Crie arquivo `.env` na raiz do projeto:
```env
# Firebase (opcional - já configurado via google-services.json)
FIREBASE_PROJECT_ID=lista-tarefas-infnet

# ViaCEP (não requer chave)
VIACEP_BASE_URL=https://viacep.com.br/ws
```

### **📊 Análise de Performance**
```bash
# Profile mode para análise
flutter run --profile

# Análise de tamanho do app
flutter build apk --analyze-size
```

### **🧹 Limpeza e Manutenção**
```bash
# Limpar cache Flutter
flutter clean

# Atualizar dependências
flutter pub upgrade

# Verificar dependências desatualizadas
flutter pub outdated
```

---

## 📞 **Suporte**

### **🆘 Problemas Comuns**
1. **Firebase não conecta:** Verifique `google-services.json`
2. **Testes falham:** Execute `flutter clean` primeiro
3. **Build falha:** Atualize Android SDK
4. **GPS não funciona:** Verifique permissões

### **📧 Contato**
- **Desenvolvedor:** Jefferson Ferreira Santos
- **Email:** jefferson.santos@al.infnet.edu.br
- **GitHub:** [jefferson-santos](https://github.com/jefferson-santos)

### **📚 Recursos Úteis**
- [Documentação Flutter](https://docs.flutter.dev/)
- [Firebase para Flutter](https://firebase.flutter.dev/)
- [Pub.dev Packages](https://pub.dev/)

---

## 🎯 **Próximos Passos**

Após a instalação bem-sucedida:

1. **📱 Teste todas as funcionalidades**
2. **🧪 Execute os testes automatizados**
3. **📊 Verifique métricas de performance**
4. **🚀 Faça o build para produção**

**🎉 Parabéns! Seu projeto Flutter INFNET está pronto para uso!**

---

**📅 Última atualização:** Junho 2025  
**🏆 Status:** Guia completo e testado 