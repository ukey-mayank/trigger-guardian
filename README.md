# 🚨 Trigger Guardian

Trigger Guardian is a Salesforce-native application designed to help developers and admins orchestrate, manage, and monitor Apex Triggers in any Salesforce org. It enables trigger framework enforcement, conflict detection, and run-time toggle control — all in a low-code/no-code manner.

---

## 🔧 Features

- ✅ Centralized trigger orchestration engine
- ✅ Custom Metadata-based trigger control (Enable/Disable triggers without deployment)
- ✅ Trigger conflict and recursion prevention
- ✅ Logging of trigger execution per object and event
- ✅ Lightning Dashboard (LWC) for monitoring and management
- ✅ Compatible with Unlocked Package deployment

---

## 🏗 Tech Stack

- Salesforce Apex  
- Lightning Web Components (LWC)  
- Custom Metadata Types  
- Unlocked Packages  
- Salesforce DX  
- Git + GitHub

---

## 🚀 Getting Started

### 1. Prerequisites

- Salesforce CLI (`sf` or `sfdx`)
- Git installed
- Dev Hub enabled in your Salesforce org
- Authorized Dev Hub

### 2. Clone the Repository

```bash
git clone https://github.com/your-username/trigger-guardian.git
cd trigger-guardian
```

### 3. Create a Scratch Org

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias TriggerGuardianScratch --set-default --duration-days 7
```

### 4. Push Source to Scratch Org

```bash
sf project deploy start --target-org TriggerGuardianScratch
```

### 5. Assign Permissions & Open Org

```bash
sf org assign permset --name Trigger_Guardian_Admin --target-org TriggerGuardianScratch
sf org open --target-org TriggerGuardianScratch
```

---

## 📦 Packaging Commands

```bash
# Create Package (once)
sf package create --name "Trigger Guardian" --package-type unlocked --path force-app --description "Trigger orchestration and monitoring app"

# Create Version
sf package version create --package Trigger_Guardian --wait 10 --installation-key-bypass --target-dev-hub devhub
```

---

## 📂 Project Structure

```
force-app/
├── main/
│   └── default/
│       ├── apex/
│       ├── lwc/
│       ├── customMetadata/
│       ├── objects/
│       └── permissionsets/
config/
├── project-scratch-def.json
```

---

## 📈 Roadmap

- ✅ Trigger metadata configuration  
- ✅ Trigger execution logger  
- 🔲 UI-based control panel for enabling/disabling triggers  
- 🔲 Integration with Error Logging App  
- 🔲 Publish to AppExchange  

---

## 🤝 Contribution

We welcome feedback, bug reports, and feature suggestions! Please open an issue or submit a pull request.

---

## 🔒 License

MIT License. See [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

**Mayank Ukey**  
Salesforce Certified Developer | LWC, Apex, AppExchange  
📫 [LinkedIn](https://linkedin.com) | 🌐 [Your Portfolio](https://yourwebsite.com)