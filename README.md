![3](https://github.com/user-attachments/assets/e30e3a5e-7b10-4295-9c44-a7c0d5782d58)

# ByteBeast-Tamagotchi Dojo ⛩️
This repository holds the Dojo smart contracts of ByteBeasts-Tamagotchi.

### ✅ Prerequisites  
Ensure the following dependencies are installed:

- **Dojo**: `v1.2.1`  
- **Scarb**: `v2.9.2`

---

### 🔨 Building Contracts  
To compile the smart contracts:

```bash
sozo build
```

---

### 🧪 Running Tests  
To execute the test suite:

```bash
sozo test
```

# Running Locally  

### 1️⃣ Start Katana (Terminal 1)  
Make sure this is running before proceeding:  

```bash
# Start Katana with disabled fees and open origins
katana --dev --dev.no-fee
```

### 2️⃣ Build, Migrate, and Start Torii (Terminal 2)  

```bash
# Build the example
sozo build

# Migrate the example (deploy the world locally)
sozo migrate

# Start Torii
# Replace <WORLD_ADDRESS> with the deployed world address from the previous step
torii --world <WA> --http.cors_origins "*"
```

---

# 🚀 Deploying to Sepolia

## 1️⃣ Set Up Environment Variables

Before deploying, set your Sepolia environment variables:

```bash
export STARKNET_RPC_URL="https://api.cartridge.gg/x/starknet/sepolia"
export DEPLOYER_ACCOUNT_ADDRESS="<your_deployer_account_address_here>"
export DEPLOYER_PRIVATE_KEY="<your_deployer_private_key_here>"
```

> ⚠️ **Make sure your deployer account is funded before proceeding.**

---

## 2️⃣ Update the Seed (Optional)

To deploy a new world instance, edit the `dojo_sepolia.toml` file and increment the seed value:

```toml
seed = "tamagotchi1"  # Change to "tamagotchi2", "tamagotchi3", etc. for a new world
```

If you want to continue using the same world, leave the seed as-is.

---

## 3️⃣ Deploy to Sepolia

Run the following command to deploy:

```bash
scarb run sepolia
```

Once the deployment finishes, you'll receive a **world address** — save this, as it will be required for interactions and indexing.

---

# 🔗 Integration

## 4️⃣ Generate TypeScript Bindings

Run:

```bash
sozo build --typescript
```

---

## 5️⃣ Configure Torii Indexer

1. **Install Slot**
   If you haven't already, install Slot:
   👉 [https://dojoengine.org/toolchain/slot](https://dojoengine.org/toolchain/slot)

2. **Authenticate with Slot**

   ```bash
   slot auth login
   ```

3. **Create a New Torii Instance**

   ```bash
   slot d create <name> torii \
     --sql.historical "tamagotchi-TrophyProgression" \
     --config "./torii-config.toml" \
     --version v1.5.1
   ```

   ✅ Verify the deployment:

   ```bash
   slot d describe <name> torii
   ```

4. **Or Update an Existing Torii Instance**

   Point your existing indexer to the new world address:

   ```bash
   slot d update <name> torii --config "./torii-config.toml"
   ```

