# 📸 **Guia Completo de Screenshots - Projeto INFNET**

## 🎯 **Screenshots Obrigatórios para Documentação**

### **🔐 1. AUTENTICAÇÃO (3 screenshots)**

#### **📱 login.png**
- **Tela:** Login Screen
- **Conteúdo:** Formulário de login com campos email/senha
- **Dados exemplo:** `usuario@teste.com` / `123456`
- **Estado:** Campos preenchidos, botão visível

#### **📱 register.png**
- **Tela:** Register Screen  
- **Conteúdo:** Formulário de cadastro completo
- **Dados exemplo:** Nome, email, senha, confirmação
- **Estado:** Formulário preenchido, validações visíveis

#### **📱 reset.png**
- **Tela:** Password Reset Screen
- **Conteúdo:** Campo de email para recuperação
- **Estado:** Campo preenchido, botão "Enviar" visível

---

### **📋 2. TAREFAS (3 screenshots)**

#### **📱 home.png**
- **Tela:** Home Screen (Lista de Tarefas)
- **Conteúdo:** Lista com 4-5 tarefas variadas
- **Incluir:** Tarefas pendentes, concluídas, vencidas
- **Estado:** Lista populada, FAB visível

#### **📱 add_todo.png**
- **Tela:** Add Todo Screen
- **Conteúdo:** Formulário de nova tarefa
- **Campos:** Título, descrição, data, hora, localização
- **Estado:** Formulário parcialmente preenchido

#### **📱 todo_details.png**
- **Tela:** Todo Details/Edit Screen
- **Conteúdo:** Detalhes de uma tarefa específica
- **Estado:** Informações completas visíveis

---

### **👤 3. PERFIL (3 screenshots)**

#### **📱 profile.png**
- **Tela:** Profile Screen
- **Conteúdo:** Dados do usuário, avatar, informações
- **Estado:** Perfil completo com foto

#### **📱 edit_profile.png**
- **Tela:** Edit Profile Screen
- **Conteúdo:** Formulário de edição do perfil
- **Incluir:** Campos de endereço, CEP, dados pessoais
- **Estado:** Formulário preenchido

#### **📱 location.png**
- **Tela:** Location Selection Screen
- **Conteúdo:** Mapa com marcador de localização
- **Estado:** Localização selecionada, botões visíveis

---

## 🛠️ **Como Capturar Screenshots**

### **📱 Método 1: Android Studio/Emulador**
```bash
# 1. Abra o Android Studio
# 2. Inicie o emulador
# 3. Execute o projeto
flutter run

# 4. No emulador, clique no ícone de câmera (lateral direita)
# 5. Salve as imagens na pasta docs/screenshots/
```

### **📱 Método 2: Dispositivo Físico**
```bash
# 1. Conecte o dispositivo via USB
# 2. Execute o projeto
flutter run

# 3. Capture via ADB
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png docs/screenshots/nome_da_tela.png

# Ou use as teclas físicas: Volume Down + Power
```

### **📱 Método 3: VS Code + Flutter**
```bash
# 1. Abra o projeto no VS Code
# 2. Execute o projeto (F5)
# 3. Use Command Palette (Ctrl+Shift+P)
# 4. Digite: "Flutter: Take Screenshot"
# 5. Salve na pasta docs/screenshots/
```

---

## 📐 **Especificações Técnicas**

### **📏 Dimensões Recomendadas:**
- **Resolução:** 1080x1920 (Full HD)
- **Formato:** PNG (preferível) ou JPG
- **Orientação:** Portrait (vertical)
- **Qualidade:** Máxima

### **🎨 Padronização Visual:**
- **Tema:** Light mode (padrão)
- **Dados:** Realistas mas não pessoais
- **Interface:** Limpa, sem notificações
- **Status Bar:** Visível com bateria/hora

---

## 📋 **Checklist de Screenshots**

### **✅ Autenticação**
- [ ] `login.png` - Tela de login
- [ ] `register.png` - Tela de registro  
- [ ] `reset.png` - Recuperação de senha

### **✅ Tarefas**
- [ ] `home.png` - Lista principal
- [ ] `add_todo.png` - Nova tarefa
- [ ] `todo_details.png` - Detalhes da tarefa

### **✅ Perfil**
- [ ] `profile.png` - Perfil do usuário
- [ ] `edit_profile.png` - Edição do perfil
- [ ] `location.png` - Seleção de localização

### **✅ Extras (Opcionais)**
- [ ] `tests_passing.png` - Testes passando
- [ ] `flutter_doctor.png` - Flutter doctor
- [ ] `app_icon.png` - Ícone do app

---

## 🚀 **Comandos Rápidos**

### **Preparar o App para Screenshots:**
```bash
# 1. Limpar e reconstruir
flutter clean
flutter pub get

# 2. Executar em modo release (melhor performance)
flutter run --release

# 3. Popular com dados de teste
# (Execute as funcionalidades principais)
```

### **Organizar Screenshots:**
```bash
# Verificar se todas as imagens estão na pasta
ls docs/screenshots/

# Renomear se necessário
mv screenshot1.png docs/screenshots/login.png
mv screenshot2.png docs/screenshots/home.png
# ... etc
```

---

## 📊 **Após Capturar as Screenshots**

### **1. Verificar Qualidade:**
- ✅ Imagem nítida e clara
- ✅ Interface completa visível
- ✅ Sem informações pessoais
- ✅ Tamanho adequado (< 2MB cada)

### **2. Commit no Git:**
```bash
git add docs/screenshots/
git commit -m "📸 Adicionar screenshots das principais telas do app"
git push origin master
```

### **3. Verificar no GitHub:**
- Acesse: https://github.com/jfsts/flutterinfnet
- Navegue até `docs/screenshots/`
- Confirme que todas as imagens estão visíveis

---

## 🎯 **Resultado Final**

Após adicionar todas as screenshots, o README.md principal mostrará automaticamente as imagens organizadas em tabelas, demonstrando visualmente todas as funcionalidades implementadas no projeto INFNET.

**📱 Total de screenshots:** 9 obrigatórios + 3 opcionais  
**🎨 Padrão visual:** Profissional e consistente  
**📊 Impacto:** Documentação completa e atrativa

---

**👨‍💻 Desenvolvido por:** Jefferson Ferreira Santos  
**📅 Data:** Janeiro 2025  
**🎓 Projeto:** Flutter INFNET 